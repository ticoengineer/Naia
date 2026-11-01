/* ================================================================================================
   NAIA INC. · PRUEBAS DE LOS PROCEDIMIENTOS ALMACENADOS (flujo real del sistema)
   ------------------------------------------------------------------------------------------------
   Orden de ejecución:  dataBase_Creation.sql
                        storedProcedures_Script.sql → este archivo (todo de una vez con F5)

   Simula el uso real del programa, en orden:
     1. Una universidad se registra (casos buenos y malos)
     2. Su administradora inicia sesión (correcto, contraseña mala, correo inexistente)
     3. La administradora configura los catálogos (carreras, departamento, equipo, ubicaciones, categorías)
     4. La administradora crea usuarios (estudiante, técnico, profesora) y prueba las reglas
     5. Un estudiante reporta un problema y soporte lo atiende de principio a fin (conversación incluida)
     6. Casos de seguridad que necesitan datos previos (cuenta desactivada, universidad desactivada)
     7. Consultas de pantalla (dashboard, historial, auditoría)

   Al final aparece UNA tabla con cada prueba: Esperado, Obtenido, ✔ OK / ✖ FALLÓ y el último
   detalle escrito en Auditoría (ahí se lee el motivo exacto de cada -1, -3, -4 o -6).

   Cada corrida crea una universidad NUEVA con un dominio único (ej. ufic143015.ac.cr), así que
   el resultado siempre es el mismo sin importar cuántas veces se ejecute. Todos los datos son
   ficticios.
   ================================================================================================ */
USE NaiaInc
GO

SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#R') IS NOT NULL DROP TABLE #R;
IF OBJECT_ID('tempdb..#Sesion') IS NOT NULL DROP TABLE #Sesion;
IF OBJECT_ID('tempdb..#Resultado') IS NOT NULL DROP TABLE #Resultado;

-- Lo que devuelve un SP de escritura (un solo número)
CREATE TABLE #R (Codigo INT);

-- Lo que devuelve SP_INICIAR_SESION cuando el login es correcto (lo que C# guardaría en Session)
CREATE TABLE #Sesion (
    Codigo INT, UsuarioId INT, InstitucionId INT, RolId TINYINT, Rol NVARCHAR(30),
    PuedeResolverTickets BIT, PuedeAdministrar BIT, Nombre NVARCHAR(60), Apellidos NVARCHAR(80),
    NombreCompleto NVARCHAR(150), Correo VARCHAR(150), NombreInstitucion NVARCHAR(150),
    Siglas NVARCHAR(10), LogoUrl NVARCHAR(300)
);

CREATE TABLE #Resultado (
    Orden INT IDENTITY(1,1), Prueba NVARCHAR(200), Esperado NVARCHAR(10), Obtenido INT,
    Resultado NVARCHAR(10), UltimaAuditoria NVARCHAR(600)
);
GO

-- Compara lo obtenido con lo esperado y lo anota en #Resultado.
-- @Esperado: '>0' (éxito) o un código ('-1', '-4'…). Si no se manda @Valor, lee el número de #R.
IF OBJECT_ID('tempdb..#Verificar') IS NOT NULL DROP PROCEDURE #Verificar;
GO
CREATE PROCEDURE #Verificar
(
@Prueba    NVARCHAR(200),
@Esperado  NVARCHAR(10),
@Valor     INT = NULL
)
AS BEGIN
	SET NOCOUNT ON;
	DECLARE @Obtenido INT = ISNULL(@Valor, (SELECT TOP 1 Codigo FROM #R))
	DECLARE @Ok BIT = CASE WHEN @Esperado = '>0' AND @Obtenido > 0 THEN 1
	                       WHEN @Esperado <> '>0' AND @Obtenido = TRY_CAST(@Esperado AS INT) THEN 1
	                       ELSE 0 END
	INSERT INTO #Resultado (Prueba, Esperado, Obtenido, Resultado, UltimaAuditoria)
	SELECT @Prueba, @Esperado, @Obtenido,
	       CASE @Ok WHEN 1 THEN N'✔ OK' ELSE N'✖ FALLÓ' END,
	       (SELECT TOP 1 CASE Exitoso WHEN 1 THEN N'[Éxito] ' ELSE N'[Fallo] ' END + ISNULL(ElementoAfectado + N' · ', N'') + ISNULL(Detalle, N'')
	        FROM Auditoria ORDER BY AuditoriaId DESC)
END
GO

/* ================================================================================================
   TODAS LAS PRUEBAS VAN EN UN SOLO BLOQUE para poder usar las variables de principio a fin
   (como si fueran la Session de la aplicación).
   ================================================================================================ */
DECLARE @Sufijo     VARCHAR(10) = FORMAT(SYSDATETIME(), 'HHmmss')
DECLARE @Dominio    VARCHAR(100) = 'ufic' + @Sufijo + '.ac.cr'
DECLARE @Dominio2   VARCHAR(100) = 'ufic' + @Sufijo + 'b.ac.cr'
DECLARE @CorreoAna  VARCHAR(150) = 'ana.demo@'     + @Dominio
DECLARE @CorreoCar  VARCHAR(150) = 'carlos.demo@'  + @Dominio
DECLARE @CorreoTom  VARCHAR(150) = 'tomas.demo@'   + @Dominio
DECLARE @CorreoLau  VARCHAR(150) = 'laura.demo@'   + @Dominio
DECLARE @CorreoMal  VARCHAR(150)
DECLARE @IP VARCHAR(45) = '10.0.0.15'

DECLARE @PlanBasico INT = (SELECT PlanId FROM PlanSuscripcion WHERE Nombre = N'Básico')
DECLARE @Inst INT, @Inst2 INT
DECLARE @Admin INT, @Admin2 INT, @Carlos INT, @Tomas INT, @Laura INT
DECLARE @CarIng INT, @CarAdm INT, @DepSop INT, @DepAdmGen INT, @Equipo INT
DECLARE @UbiAula INT, @UbiRemoto INT, @CatRed INT, @CatPlat INT
DECLARE @T1 INT, @T2 INT, @Com INT, @Cuenta INT

IF @PlanBasico IS NULL
BEGIN
	RAISERROR(N'No hay planes cargados. Ejecute primero 01b_catalogos_fijos.sql', 16, 1)
	RETURN
END

---------------------------------------- 1. REGISTRO DE LA UNIVERSIDAD ----------------------------------------
-- Pantalla "Registra tu universidad": plan + datos de la universidad + primer administrador
DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_INSTITUCIONES @PlanBasico, N'Universidad Ficticia', N'UFIC', @Dominio, NULL,
     1, '1-1111-1111', 'EMP-0001', N'Ana', N'Demo Admin', @CorreoAna, 'Admin123', @IP
SELECT @Inst = Codigo FROM #R
EXEC #Verificar N'1.1 Registrar universidad correctamente', '>0'

SELECT @Cuenta = COUNT(*) FROM Departamento WHERE InstitucionId = @Inst AND Nombre = N'Administración General'
EXEC #Verificar N'1.2 Se creó el departamento "Administración General" (cuenta = 1)', '1', @Cuenta

SELECT @Cuenta = COUNT(*) FROM Ubicacion WHERE InstitucionId = @Inst AND EsFisica = 0
EXEC #Verificar N'1.3 Se crearon las 3 ubicaciones virtuales (cuenta = 3)', '3', @Cuenta

SET @CorreoMal = 'otra.persona@' + @Dominio
DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_INSTITUCIONES @PlanBasico, N'Universidad Repetida', N'UREP', @Dominio, NULL,
     1, '1-2222-0000', 'EMP-0001', N'Otra', N'Persona', @CorreoMal, 'Admin123', @IP
EXEC #Verificar N'1.4 Registrar otra universidad con el MISMO dominio', '-1'

DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_INSTITUCIONES @PlanBasico, N'Universidad Otra', N'UOTR', @Dominio2, NULL,
     1, '1-3333-0000', 'EMP-0001', N'Beto', N'Prueba', 'beto.prueba@gmail.com', 'Admin123', @IP
EXEC #Verificar N'1.5 Correo del administrador que no es del dominio', '-4'

DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_INSTITUCIONES 999, N'Universidad Otra', N'UOTR', @Dominio2, NULL,
     1, '1-3333-0000', 'EMP-0001', N'Beto', N'Prueba', 'beto@ufic.ac.cr', 'Admin123', @IP
EXEC #Verificar N'1.6 Plan que no existe', '-4'

DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_INSTITUCIONES @PlanBasico, N'', N'UOTR', @Dominio2, NULL,
     1, '1-3333-0000', 'EMP-0001', N'Beto', N'Prueba', 'beto@ufic.ac.cr', 'Admin123', @IP
EXEC #Verificar N'1.7 Nombre de la universidad vacío', '-4'

DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_INSTITUCIONES @PlanBasico, N'Universidad Otra', N'UOTR', 'sinpunto', NULL,
     1, '1-3333-0000', 'EMP-0001', N'Beto', N'Prueba', 'beto@sinpunto', 'Admin123', @IP
EXEC #Verificar N'1.8 Dominio inválido (sin punto)', '-4'

---------------------------------------- 2. INICIO DE SESIÓN ----------------------------------------
DELETE FROM #Sesion
INSERT INTO #Sesion EXEC SP_INICIAR_SESION @CorreoAna, 'Admin123', @IP
SELECT @Admin = UsuarioId FROM #Sesion WHERE Codigo > 0 AND InstitucionId = @Inst AND PuedeAdministrar = 1
EXEC #Verificar N'2.1 Login correcto de la administradora (Session con su UsuarioId)', '>0', @Admin

DELETE FROM #R
INSERT INTO #R EXEC SP_INICIAR_SESION @CorreoAna, 'admin123', @IP
EXEC #Verificar N'2.2 Login con la contraseña en minúscula (distingue mayúsculas)', '-1'

SET @CorreoMal = 'nadie@' + @Dominio
DELETE FROM #R
INSERT INTO #R EXEC SP_INICIAR_SESION @CorreoMal, 'Loquesea1', '10.0.0.99'
EXEC #Verificar N'2.3 Login con un correo que no existe', '-1'

SELECT @Cuenta = COUNT(*) FROM Auditoria WHERE InstitucionId = @Inst AND ElementoAfectado = @CorreoMal AND Exitoso = 0
EXEC #Verificar N'2.4 El intento 2.3 quedó en la auditoría de ESTA universidad (cuenta = 1)', '1', @Cuenta

---------------------------------------- 3. LA ADMIN CONFIGURA LOS CATÁLOGOS ----------------------------------------
-- Carreras
DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_CARRERAS @Inst, N'Ingeniería de Sistemas Demo', @Admin, @IP
SELECT @CarIng = Codigo FROM #R
EXEC #Verificar N'3.1 Crear carrera', '>0'

DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_CARRERAS @Inst, N'Ingeniería de Sistemas Demo', @Admin, @IP
EXEC #Verificar N'3.2 Crear la MISMA carrera', '-1'

DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_CARRERAS @Inst, N'   ', @Admin, @IP
EXEC #Verificar N'3.3 Crear carrera con nombre vacío', '-4'

DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_CARRERAS @Inst, N'Administración Demo', @Admin, @IP
SELECT @CarAdm = Codigo FROM #R
EXEC #Verificar N'3.4 Crear segunda carrera', '>0'

DELETE FROM #R
INSERT INTO #R EXEC SP_ACTUALIZA_CARRERAS @Inst, @CarAdm, N'Administración de Empresas Demo', 1, @Admin, @IP
EXEC #Verificar N'3.5 Cambiar el nombre de la segunda carrera', '>0'

DELETE FROM #R
INSERT INTO #R EXEC SP_ACTUALIZA_CARRERAS @Inst, @CarAdm, N'Ingeniería de Sistemas Demo', 1, @Admin, @IP
EXEC #Verificar N'3.6 Renombrarla igual que la primera', '-1'

DELETE FROM #R
INSERT INTO #R EXEC SP_ACTUALIZA_CARRERAS @Inst, 999999, N'No existe', 1, @Admin, @IP
EXEC #Verificar N'3.7 Editar una carrera que no existe', '-2'

-- Departamento y equipo de soporte
DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_DEPARTAMENTOS @Inst, N'Soporte TI Demo', @Admin, @IP
SELECT @DepSop = Codigo FROM #R
EXEC #Verificar N'3.8 Crear departamento', '>0'

SELECT @DepAdmGen = DepartamentoId FROM Departamento WHERE InstitucionId = @Inst AND Nombre = N'Administración General'

DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_EQUIPOS @Inst, N'Redes Demo', N'Wifi, cableado e internet', @Admin, @IP
SELECT @Equipo = Codigo FROM #R
EXEC #Verificar N'3.9 Crear equipo de soporte', '>0'

DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_EQUIPOS @Inst, N'Redes Demo', NULL, @Admin, @IP
EXEC #Verificar N'3.10 Crear el MISMO equipo', '-1'

-- Ubicaciones
DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_UBICACIONES @Inst, N'Laboratorio Demo 3', NULL, 1, @Admin, @IP
EXEC #Verificar N'3.11 Ubicación física sin edificio', '-4'

DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_UBICACIONES @Inst, N'Laboratorio Demo 3', N'Edificio Ficticio A', 1, @Admin, @IP
SELECT @UbiAula = Codigo FROM #R
EXEC #Verificar N'3.12 Crear ubicación física', '>0'

DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_UBICACIONES @Inst, N'Laboratorio Demo 3', N'Edificio Ficticio A', 1, @Admin, @IP
EXEC #Verificar N'3.13 Crear la MISMA ubicación', '-1'

SELECT @UbiRemoto = UbicacionId FROM Ubicacion WHERE InstitucionId = @Inst AND EsFisica = 0 AND Nombre = N'Remoto (fuera del campus)'

-- Categorías
DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_CATEGORIAS @Inst, N'Red e internet Demo', N'Wifi, cable o sin conexión', '#3C4F76', 2, @Equipo, 1, @Admin, @IP
SELECT @CatRed = Codigo FROM #R
EXEC #Verificar N'3.14 Crear categoría (prioridad 2 Alta, pide ubicación física)', '>0'

DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_CATEGORIAS @Inst, N'Color malo', NULL, 'azul', 3, NULL, 0, @Admin, @IP
EXEC #Verificar N'3.15 Categoría con color inválido', '-4'

DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_CATEGORIAS @Inst, N'Prioridad mala', NULL, '#3C4F76', 9, NULL, 0, @Admin, @IP
EXEC #Verificar N'3.16 Categoría con prioridad que no existe (9)', '-4'

DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_CATEGORIAS @Inst, N'Plataforma virtual Demo', NULL, '#AB9F9D', 3, NULL, 0, @Admin, @IP
SELECT @CatPlat = Codigo FROM #R
EXEC #Verificar N'3.17 Crear categoría (prioridad 3 Media, sin ubicación física)', '>0'

---------------------------------------- 4. LA ADMIN CREA USUARIOS ----------------------------------------
DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_USUARIOS @Inst, 1, @CarIng, NULL, NULL, 1, '2-2222-2222', '2026-00001',
     N'Carlos', N'Demo Estudiante', @CorreoCar, 'Clave123', @Admin, @IP
SELECT @Carlos = Codigo FROM #R
EXEC #Verificar N'4.1 Crear estudiante', '>0'

DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_USUARIOS @Inst, 1, @CarIng, NULL, NULL, 1, '2-9999-9999', '2026-00099',
     N'Carlos', N'Duplicado', @CorreoCar, 'Clave123', @Admin, @IP
EXEC #Verificar N'4.2 Otro usuario con el MISMO correo', '-1'

SET @CorreoMal = 'otro.carlos@' + @Dominio
DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_USUARIOS @Inst, 1, @CarIng, NULL, NULL, 1, '2-2222-2222', '2026-00098',
     N'Otro', N'Carlos', @CorreoMal, 'Clave123', @Admin, @IP
EXEC #Verificar N'4.3 Otro usuario con la MISMA cédula', '-1'

DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_USUARIOS @Inst, 1, @CarIng, NULL, NULL, 1, '2-5555-5555', '2026-00002',
     N'Pedro', N'Demo', 'pedro.demo@gmail.com', 'Clave123', @Admin, @IP
EXEC #Verificar N'4.4 Usuario con correo de otro dominio', '-4'

SET @CorreoMal = 'pedro.demo@' + @Dominio
DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_USUARIOS @Inst, 1, NULL, @DepSop, NULL, 1, '2-5555-5555', '2026-00002',
     N'Pedro', N'Demo', @CorreoMal, 'Clave123', @Admin, @IP
EXEC #Verificar N'4.5 Estudiante con departamento en vez de carrera', '-4'

DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_USUARIOS @Inst, 3, NULL, @DepSop, @Equipo, 1, '3-3333-3333', 'EMP-0002',
     N'Tomás', N'Demo Técnico', @CorreoTom, 'Clave123', @Admin, @IP
SELECT @Tomas = Codigo FROM #R
EXEC #Verificar N'4.6 Crear técnico de soporte en el equipo Redes Demo', '>0'

DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_USUARIOS @Inst, 2, @CarIng, NULL, NULL, 1, '4-4444-4444', 'EMP-0003',
     N'Laura', N'Demo Profesora', @CorreoLau, 'Clave123', @Admin, @IP
SELECT @Laura = Codigo FROM #R
EXEC #Verificar N'4.7 Crear profesora', '>0'

DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_USUARIOS @Inst, 1, @CarIng, NULL, NULL, 1, '2-6666-6666', '2026-00003',
     N'Pedro', N'Demo', @CorreoMal, 'Clave123', @Carlos, @IP
EXEC #Verificar N'4.8 El estudiante intenta crear un usuario', '-3'

DELETE FROM #R
INSERT INTO #R EXEC SP_ACTUALIZA_USUARIOS @Inst, @Laura, 2, @CarAdm, NULL, NULL, 1, '4-4444-4444', 'EMP-0003',
     N'Laura', N'Demo Profesora', @CorreoLau, NULL, 1, @Admin, @IP
EXEC #Verificar N'4.9 Cambiar la carrera de la profesora (detalle anterior → nuevo en Auditoría)', '>0'

DELETE FROM #R
INSERT INTO #R EXEC SP_ACTUALIZA_USUARIOS @Inst, @Admin, 3, NULL, @DepAdmGen, NULL, 1, '1-1111-1111', 'EMP-0001',
     N'Ana', N'Demo Admin', @CorreoAna, NULL, 1, @Admin, @IP
EXEC #Verificar N'4.10 La admin intenta quitarse su propio rol', '-6'

DELETE FROM #R
INSERT INTO #R EXEC SP_ELIMINA_USUARIOS @Inst, @Admin, @Admin, @IP
EXEC #Verificar N'4.11 La admin intenta desactivarse a sí misma', '-6'

DELETE FROM #R
INSERT INTO #R EXEC SP_ELIMINA_CARRERAS @Inst, @CarIng, @Admin, @IP
EXEC #Verificar N'4.12 Desactivar una carrera que tiene usuarios activos', '-6'

DELETE FROM #R
INSERT INTO #R EXEC SP_ELIMINA_USUARIOS @Inst, @Laura, @Admin, @IP
EXEC #Verificar N'4.13 Desactivar a la profesora', '>0'

DELETE FROM #R
INSERT INTO #R EXEC SP_ELIMINA_USUARIOS @Inst, @Laura, @Admin, @IP
EXEC #Verificar N'4.14 Desactivarla otra vez', '-6'

DELETE FROM #R
INSERT INTO #R EXEC SP_INICIAR_SESION @CorreoLau, 'Clave123', @IP
EXEC #Verificar N'4.15 La profesora desactivada intenta iniciar sesión', '-3'

DELETE FROM #R
INSERT INTO #R EXEC SP_ACTUALIZA_USUARIOS @Inst, @Laura, 2, @CarAdm, NULL, NULL, 1, '4-4444-4444', 'EMP-0003',
     N'Laura', N'Demo Profesora', @CorreoLau, NULL, 1, @Admin, @IP
EXEC #Verificar N'4.16 Reactivarla desde el formulario de edición (@Activo = 1)', '>0'

---------------------------------------- 5. UN TIQUETE DE PRINCIPIO A FIN ----------------------------------------
-- Carlos inicia sesión y reporta que no tiene internet en el laboratorio
DELETE FROM #Sesion
INSERT INTO #Sesion EXEC SP_INICIAR_SESION @CorreoCar, 'Clave123', '10.0.0.31'
SELECT @Cuenta = UsuarioId FROM #Sesion WHERE Codigo > 0
EXEC #Verificar N'5.1 Login del estudiante', '>0', @Cuenta

DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_TICKETS @Inst, N'No hay internet en el laboratorio', N'El wifi no conecta desde la mañana.',
     @CatRed, @UbiRemoto, @Carlos, '10.0.0.31'
EXEC #Verificar N'5.2 Crear tiquete de red en ubicación "Remoto" (la categoría pide ubicación física)', '-4'

DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_TICKETS @Inst, N'No hay internet en el laboratorio', N'El wifi no conecta desde la mañana.',
     @CatRed, @UbiAula, @Carlos, '10.0.0.31'
SELECT @T1 = Codigo FROM #R
EXEC #Verificar N'5.3 Crear tiquete en el laboratorio', '>0'

SELECT @Cuenta = PrioridadId FROM Ticket WHERE TicketId = @T1
EXEC #Verificar N'5.4 El tiquete tomó la prioridad de la categoría (2 = Alta)', '2', @Cuenta

DELETE FROM #R
INSERT INTO #R EXEC SP_ACTUALIZA_TICKETS @Inst, @T1, N'No hay internet en el laboratorio 3', N'El wifi no conecta desde la mañana.',
     @CatRed, 2, @UbiAula, @Carlos, '10.0.0.31'
EXEC #Verificar N'5.5 El estudiante corrige el título mientras está Nuevo', '>0'

DELETE FROM #R
INSERT INTO #R EXEC SP_ACTUALIZA_TICKETS @Inst, @T1, N'No hay internet en el laboratorio 3', N'El wifi no conecta desde la mañana.',
     @CatRed, 1, @UbiAula, @Carlos, '10.0.0.31'
EXEC #Verificar N'5.6 El estudiante intenta subirle la prioridad a Crítica', '-3'

DELETE FROM #R
INSERT INTO #R EXEC SP_CAMBIA_ESTADO_TICKETS @Inst, @T1, 3, NULL, NULL, @Carlos, '10.0.0.31'
EXEC #Verificar N'5.7 El estudiante intenta pasarlo a En progreso (no existe la regla Nuevo → En progreso)', '-6'

DELETE FROM #R
INSERT INTO #R EXEC SP_ASIGNA_TICKETS @Inst, @T1, @Tomas, NULL, @Carlos, '10.0.0.31'
EXEC #Verificar N'5.8 El estudiante intenta asignarlo', '-3'

DELETE FROM #R
INSERT INTO #R EXEC SP_ASIGNA_TICKETS @Inst, @T1, @Carlos, NULL, @Admin, @IP
EXEC #Verificar N'5.9 La admin intenta asignárselo a un estudiante', '-4'

DELETE FROM #R
INSERT INTO #R EXEC SP_ASIGNA_TICKETS @Inst, @T1, @Tomas, NULL, @Admin, @IP
EXEC #Verificar N'5.10 La admin se lo asigna al técnico (Nuevo → Asignado)', '>0'

DELETE FROM #R
INSERT INTO #R EXEC SP_ACTUALIZA_TICKETS @Inst, @T1, N'Cambio tardío', N'El wifi no conecta desde la mañana.',
     @CatRed, 2, @UbiAula, @Carlos, '10.0.0.31'
EXEC #Verificar N'5.11 El estudiante intenta editarlo ya Asignado', '-6'

DECLARE @Botones TABLE (EstadoDestinoId TINYINT, EstadoDestino NVARCHAR(30), RequiereMotivo BIT, RequiereSolucion BIT)
INSERT INTO @Botones EXEC SP_LISTAR_TRANSICIONES_DISPONIBLES @Inst, @T1, @Tomas
SELECT @Cuenta = COUNT(*) FROM @Botones
EXEC #Verificar N'5.12 Botones que ve el técnico: En progreso, En espera, Cancelado (cuenta = 3)', '3', @Cuenta

DELETE FROM @Botones
INSERT INTO @Botones EXEC SP_LISTAR_TRANSICIONES_DISPONIBLES @Inst, @T1, @Carlos
SELECT @Cuenta = COUNT(*) FROM @Botones
EXEC #Verificar N'5.13 Botones que ve el estudiante: solo Cancelado (cuenta = 1)', '1', @Cuenta

DELETE FROM #R
INSERT INTO #R EXEC SP_CAMBIA_ESTADO_TICKETS @Inst, @T1, 3, NULL, NULL, @Tomas, '10.0.0.40'
EXEC #Verificar N'5.14 El técnico lo pasa a En progreso', '>0'

-- La conversación: el técnico pide la IP y deja el tiquete En espera
DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_COMENTARIOS @Inst, @T1, N'Hola Carlos, ¿me pasas la IP de tu computadora? Abre cmd y escribe ipconfig.', @Tomas, '10.0.0.40'
EXEC #Verificar N'5.15 El técnico pide la dirección IP (comentario)', '>0'

DELETE FROM #R
INSERT INTO #R EXEC SP_CAMBIA_ESTADO_TICKETS @Inst, @T1, 4, NULL, NULL, @Tomas, '10.0.0.40'
EXEC #Verificar N'5.16 Pasarlo a En espera SIN motivo', '-4'

DELETE FROM #R
INSERT INTO #R EXEC SP_CAMBIA_ESTADO_TICKETS @Inst, @T1, 4, N'Esperando la IP del usuario', NULL, @Tomas, '10.0.0.40'
EXEC #Verificar N'5.17 Pasarlo a En espera con motivo', '>0'

DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_COMENTARIOS @Inst, @T1, N'Es 192.168.4.27', @Carlos, '10.0.0.31'
SELECT @Com = Codigo FROM #R
EXEC #Verificar N'5.18 El estudiante responde con la IP', '>0'

DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_ADJUNTOS @Inst, @T1, N'ipconfig.txt', 'text/plain', 0x4950, @Carlos, '10.0.0.31'
EXEC #Verificar N'5.19 Adjuntar un archivo .txt (no permitido)', '-4'

DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_ADJUNTOS @Inst, @T1, N'captura-ipconfig.png', 'image/png', 0x89504E470D0A1A0A, @Carlos, '10.0.0.31'
EXEC #Verificar N'5.20 Adjuntar una captura PNG', '>0'

DELETE FROM #R
INSERT INTO #R EXEC SP_ACTUALIZA_COMENTARIOS @Inst, @Com, N'Texto cambiado por soporte', @Tomas, '10.0.0.40'
EXEC #Verificar N'5.21 El técnico intenta editar el comentario del estudiante', '-3'

DELETE FROM #R
INSERT INTO #R EXEC SP_ACTUALIZA_COMENTARIOS @Inst, @Com, N'Es 192.168.4.27 (en la laptop del laboratorio)', @Carlos, '10.0.0.31'
EXEC #Verificar N'5.22 El estudiante edita su propio comentario', '>0'

DELETE FROM #R
INSERT INTO #R EXEC SP_CAMBIA_ESTADO_TICKETS @Inst, @T1, 3, NULL, NULL, @Tomas, '10.0.0.40'
EXEC #Verificar N'5.23 El técnico lo retoma (En espera → En progreso)', '>0'

DELETE FROM #R
INSERT INTO #R EXEC SP_ACTUALIZA_TICKETS @Inst, @T1, N'No hay internet en el laboratorio 3',
     N'IP duplicada (192.168.4.27) en la red del laboratorio por una reserva DHCP mal configurada.',
     @CatRed, 2, @UbiAula, @Tomas, '10.0.0.40'
EXEC #Verificar N'5.24 El técnico corrige la descripción con la causa real', '>0'

DELETE FROM #R
INSERT INTO #R EXEC SP_CAMBIA_ESTADO_TICKETS @Inst, @T1, 5, NULL, NULL, @Tomas, '10.0.0.40'
EXEC #Verificar N'5.25 Marcar Resuelto SIN escribir la solución', '-4'

DELETE FROM #R
INSERT INTO #R EXEC SP_CAMBIA_ESTADO_TICKETS @Inst, @T1, 5, NULL, N'Se liberó la reserva DHCP duplicada y se renovó la IP del equipo.', @Tomas, '10.0.0.40'
EXEC #Verificar N'5.26 Marcar Resuelto con la solución', '>0'

DELETE FROM #R
INSERT INTO #R EXEC SP_CAMBIA_ESTADO_TICKETS @Inst, @T1, 6, NULL, NULL, @Tomas, '10.0.0.40'
EXEC #Verificar N'5.27 El técnico intenta cerrarlo (solo el estudiante confirma)', '-3'

DELETE FROM #R
INSERT INTO #R EXEC SP_CAMBIA_ESTADO_TICKETS @Inst, @T1, 2, NULL, NULL, @Carlos, '10.0.0.31'
EXEC #Verificar N'5.28 El estudiante intenta reabrirlo SIN motivo', '-4'

DELETE FROM #R
INSERT INTO #R EXEC SP_CAMBIA_ESTADO_TICKETS @Inst, @T1, 6, NULL, NULL, @Carlos, '10.0.0.31'
EXEC #Verificar N'5.29 El estudiante confirma y lo cierra', '>0'

DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_COMENTARIOS @Inst, @T1, N'¿Sigue abierto?', @Carlos, '10.0.0.31'
EXEC #Verificar N'5.30 Comentar en un tiquete cerrado', '-6'

DELETE FROM #R
INSERT INTO #R EXEC SP_ACTUALIZA_COMENTARIOS @Inst, @Com, N'Cambio después de cerrar', @Carlos, '10.0.0.31'
EXEC #Verificar N'5.31 Editar un comentario de un tiquete cerrado', '-6'

SELECT @Cuenta = COUNT(*) FROM HistorialEstado WHERE TicketId = @T1
EXEC #Verificar N'5.32 Historial: Nuevo, Asignado, En progreso, En espera, En progreso, Resuelto, Cerrado (cuenta = 7)', '7', @Cuenta

-- Un segundo tiquete que el estudiante abrió por error y cancela
DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_TICKETS @Inst, N'No puedo entrar al aula virtual', N'Me sale error al iniciar sesión.',
     @CatPlat, @UbiRemoto, @Carlos, '10.0.0.31'
SELECT @T2 = Codigo FROM #R
EXEC #Verificar N'5.33 Crear un segundo tiquete en ubicación Remoto (categoría sin ubicación física)', '>0'

DELETE FROM #R
INSERT INTO #R EXEC SP_ELIMINA_TICKETS @Inst, @T2, NULL, @Carlos, '10.0.0.31'
EXEC #Verificar N'5.34 Cancelarlo SIN motivo', '-4'

DELETE FROM #R
INSERT INTO #R EXEC SP_ELIMINA_TICKETS @Inst, @T2, N'Ya pude entrar, era mi contraseña.', @Carlos, '10.0.0.31'
EXEC #Verificar N'5.35 Cancelarlo con motivo', '>0'

-- La profesora no es dueña ni es soporte: no debe poder hacer nada con el tiquete de Carlos
DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_COMENTARIOS @Inst, @T1, N'Hola', @Laura, @IP
EXEC #Verificar N'5.36 La profesora intenta comentar en un tiquete ajeno', '-3'

---------------------------------------- 6. SEGURIDAD: UNIVERSIDAD DESACTIVADA ----------------------------------------
SET @CorreoMal = 'admin.b@' + @Dominio2
DELETE FROM #R
INSERT INTO #R EXEC SP_INSERTA_INSTITUCIONES @PlanBasico, N'Universidad Ficticia B', N'UFB', @Dominio2, NULL,
     1, '5-5555-5555', 'EMP-0001', N'Beatriz', N'Demo Admin', @CorreoMal, 'Admin123', @IP
SELECT @Inst2 = Codigo FROM #R
EXEC #Verificar N'6.1 Registrar una segunda universidad', '>0'

SELECT @Admin2 = UsuarioId FROM Usuario WHERE Correo = @CorreoMal

DELETE FROM #R
INSERT INTO #R EXEC SP_ELIMINA_INSTITUCIONES @Inst2, @Admin, @IP
EXEC #Verificar N'6.2 La admin de la PRIMERA universidad intenta cancelar la segunda', '-3'

DELETE FROM #R
INSERT INTO #R EXEC SP_ELIMINA_INSTITUCIONES @Inst2, @Admin2, @IP
EXEC #Verificar N'6.3 Su propia admin cancela la suscripción', '>0'

DELETE FROM #R
INSERT INTO #R EXEC SP_INICIAR_SESION @CorreoMal, 'Admin123', @IP
EXEC #Verificar N'6.4 Login en una universidad desactivada', '-6'

-- Editar un plan con sus mismos valores (no cambia nada; prueba el SP sin tocar los precios reales)
DECLARE @PlanNombre NVARCHAR(50), @PlanMax INT, @PlanPrecio DECIMAL(10,2)
SELECT @PlanNombre = Nombre, @PlanMax = MaxUsuarios, @PlanPrecio = PrecioMensual FROM PlanSuscripcion WHERE PlanId = @PlanBasico
DELETE FROM #R
INSERT INTO #R EXEC SP_ACTUALIZA_PLANES @PlanBasico, @PlanNombre, @PlanMax, @PlanPrecio, 1, @IP
EXEC #Verificar N'6.5 Editar el plan Básico con los mismos valores ("Se guardó sin cambios")', '>0'

DELETE FROM #R
INSERT INTO #R EXEC SP_ACTUALIZA_PLANES @PlanBasico, @PlanNombre, @PlanMax, -5, 1, @IP
EXEC #Verificar N'6.6 Editar el plan con precio negativo', '-4'

---------------------------------------- 7. CONSULTAS DE PANTALLA ----------------------------------------
PRINT N'=== Tiquete INC del flujo principal ==='
EXEC SP_INFO_TICKET @Inst, @T1, @Admin
EXEC SP_LISTAR_HISTORIAL_ESTADO @Inst, @T1, @Admin
EXEC SP_LISTAR_COMENTARIOS @Inst, @T1, @Carlos
EXEC SP_LISTAR_ADJUNTOS @Inst, @T1, @Carlos

PRINT N'=== Lo que ve Carlos (solo lo suyo) y el dashboard de la admin ==='
EXEC SP_LISTAR_TICKETS @Inst, @Carlos
EXEC SP_DASHBOARD_TICKETS @Inst, @Admin

PRINT N'=== Pantalla de Auditoría de la admin ==='
EXEC SP_LISTAR_AUDITORIA @Inst, @Admin

---------------------------------------- RESUMEN ----------------------------------------
SELECT Orden, Prueba, Esperado, Obtenido, Resultado, UltimaAuditoria FROM #Resultado ORDER BY Orden

SELECT COUNT(*) AS TotalPruebas,
       SUM(CASE WHEN Resultado = N'✔ OK' THEN 1 ELSE 0 END) AS Correctas,
       SUM(CASE WHEN Resultado <> N'✔ OK' THEN 1 ELSE 0 END) AS Fallidas
FROM #Resultado
GO