/* ================================================================================================
   NAIA INC. · PROCEDIMIENTOS ALMACENADOS
   Base de datos: NaiaInc  ·  Ejecutar DESPUÉS del script de tablas.
   ================================================================================================

   ÍNDICE
   ------------------------------------------------------------------------------------------------
     SECCIÓN 1  · AUDITORÍA ............ SP_INSERTA_AUDITORIA, SP_LISTAR_AUDITORIA, SP_FILTRAR_AUDITORIA
     SECCIÓN 2  · CATÁLOGOS GLOBALES ... Planes, Roles, Tipos de identificación, Prioridades,
                                         Estados de tiquete y Transiciones (solo consultar;
                                         los planes también se pueden editar)
     SECCIÓN 3  · INSTITUCIÓN .......... Registrar universidad, consultar, editar, desactivar
     SECCIÓN 4  · SEGURIDAD ............ Iniciar sesión
     SECCIÓN 5  · CARRERAS ............. CRUD completo
     SECCIÓN 6  · DEPARTAMENTOS ........ CRUD completo
     SECCIÓN 7  · EQUIPOS DE SOPORTE ... CRUD completo
     SECCIÓN 8  · UBICACIONES .......... CRUD completo
     SECCIÓN 9  · CATEGORÍAS ........... CRUD completo
     SECCIÓN 10 · USUARIOS ............. CRUD completo
     SECCIÓN 11 · TIQUETES ............. Crear, consultar, editar, asignar, cambiar estado, cancelar
     SECCIÓN 12 · COMENTARIOS .......... Crear, consultar y editar (solo el autor)
     SECCIÓN 13 · ADJUNTOS ............. Crear y consultar
     SECCIÓN 14 · HISTORIAL DE ESTADOS . Solo consultar (lo llena SECCIÓN 11)

   CONVENCIÓN DE NOMBRES
   ------------------------------------------------------------------------------------------------
     SP_LISTAR_X    -> trae todos los registros de la universidad (para la tabla de la pantalla)
     SP_FILTRAR_X   -> igual que LISTAR pero con un texto de búsqueda (la barra de búsqueda)
     SP_INFO_X      -> trae UN registro (para cargar el formulario de edición)
     SP_INSERTA_X   -> crea
     SP_ACTUALIZA_X -> edita (también sirve para reactivar: se manda @Activo = 1)
     SP_ELIMINA_X   -> NO borra la fila: la desactiva (Activo = 0). Así los tiquetes y la
                       auditoría que apuntan a ese registro no se rompen.

   PARÁMETROS QUE SE REPITEN
   ------------------------------------------------------------------------------------------------
     @InstitucionId    -> la universidad del usuario que inició sesión (se guarda en Session).
                          TODOS los SP filtran por ella: una universidad nunca ve datos de otra.
     @IdUsuarioGlobal  -> el UsuarioId de quien está haciendo la acción (Session).
     @DireccionIp      -> IP del cliente. En C#: Request.UserHostAddress

   CÓDIGOS DE RETORNO (los SP de escritura devuelven UN número con SELECT -> ExecuteScalar en C#)
   ------------------------------------------------------------------------------------------------
      > 0  Éxito. Es el Id del registro creado o modificado.
       -1  Duplicado. Ya existe un registro con ese nombre / correo / identificación.
       -2  El registro no existe (o no es de esta universidad).
       -3  Sin permisos para esa acción.
       -4  Dato inválido o vacío (el motivo exacto queda en Auditoría).
       -5  Se alcanzó el límite de usuarios del plan.
       -6  Regla del negocio (ej. desactivar al único administrador, editar un tiquete cerrado).
        0  Error inesperado (cayó en el CATCH; el mensaje técnico queda en Auditoría).

   Ejemplo en la capa de datos (C#):
       int resultado = Convert.ToInt32(cmd.ExecuteScalar());
       if (resultado > 0) { /* éxito */ }
       else switch (resultado) { case -1: ... case -2: ... }

   VALORES FIJOS DE LOS CATÁLOGOS GLOBALES (son los Id que se mandan a los SP)
   ------------------------------------------------------------------------------------------------
     RolId                 1 Estudiante       -> crea tiquetes y ve solo los suyos. Usa Carné.
                           2 Profesor         -> crea tiquetes y ve solo los suyos. Usa N.º de empleado.
                           3 Soporte técnico  -> atiende tiquetes. Pertenece a un departamento y a un equipo.
                           4 Administrativo   -> atiende tiquetes y además administra usuarios,
                                                 catálogos, configuración y auditoría.
         * Estudiante y Profesor llevan CarreraId (DepartamentoId = NULL).
         * Soporte técnico y Administrativo llevan DepartamentoId (CarreraId = NULL).
         * Solo Soporte técnico lleva EquipoId.

     TipoIdentificacionId  1 Cédula de identidad · 2 DIMEX · 3 Pasaporte · 4 Otro

     PrioridadId           1 Crítica  -> se debe resolver en  2 horas  (color #7E2F3A)
                           2 Alta     -> se debe resolver en  4 horas  (color #A9545E)
                           3 Media    -> se debe resolver en  8 horas  (color #D1BEB0)
                           4 Baja     -> se debe resolver en 24 horas  (color #3C4F76)
         * El número MÁS BAJO es el MÁS URGENTE.
         * Al crear un tiquete, la prioridad sale de la categoría (Categoria.PrioridadInicialId).
           Soporte la puede cambiar después.

     EstadoId (tiquete)    1 Nuevo        -> recién creado, nadie lo ha tomado
                           2 Asignado     -> ya tiene técnico responsable
                           3 En progreso  -> el técnico está trabajando en él
                           4 En espera    -> se espera algo (respuesta del usuario, un repuesto…)
                           5 Resuelto     -> soporte escribió la solución; falta que el usuario confirme
                           6 Cerrado      -> el usuario confirmó. FINAL
                           7 Cancelado    -> se anuló. FINAL
         * Un tiquete en estado FINAL (6 o 7) ya no se puede editar, comentar ni adjuntar.

     TransicionEstado      Es la "tabla de reglas" de los botones del tiquete: dice de qué estado se
                           puede pasar a cuál, quién puede hacerlo y si debe escribir un motivo.
                           La pantalla NO decide qué botones mostrar: llama a
                           SP_LISTAR_TRANSICIONES_DISPONIBLES y pinta un botón por cada fila.

     PlanId                1 Básico (500 usuarios, $149) · 2 Profesional (3000, $399)
                           3 Institucional (ilimitado, $899)

   AUDITORÍA
   ------------------------------------------------------------------------------------------------
     Cada SP de escritura registra en Auditoria tanto el ÉXITO como el FALLO, con este formato:
       ElementoAfectado -> "Carlos Pérez Mora (2026-00001)", "INC0010001", "Carrera: Derecho"
       Detalle (éxito)  -> "Creó el usuario con rol Estudiante y correo …"
       Detalle (edición)-> "Campo: anterior → nuevo; Campo: anterior → nuevo; "
       Detalle (fallo)  -> "Intento fallido de …: motivo"
     Los -2 (registro inexistente) no se registran: desde la pantalla no deberían ocurrir.
   ================================================================================================ */


/* ================================================================================================
   SECCIÓN 1 · AUDITORÍA
   La tabla Auditoria solo admite INSERT (un trigger bloquea UPDATE y DELETE).
   ================================================================================================ */
USE NaiaInc
GO

-- USO INTERNO: lo llaman los demás SP. La aplicación nunca lo llama directamente.
CREATE OR ALTER PROCEDURE SP_INSERTA_AUDITORIA
(
@InstitucionId     INT,
@IdUsuarioGlobal   INT,
@Accion            NVARCHAR(30),     -- Crear | Actualizar | Desactivar | Asignar | CambiarEstado | InicioSesion
@SeccionSistema    NVARCHAR(30),     -- Tiquetes | Usuarios | Catálogos | Configuración | Seguridad
@ElementoAfectado  NVARCHAR(150),
@Detalle           NVARCHAR(MAX),
@Exitoso           BIT,
@DireccionIp       VARCHAR(45)
)
AS BEGIN
	SET NOCOUNT ON;

	-- Si un Id no existe (ej. intento fallido), se guarda NULL para que la auditoría nunca falle
	IF @InstitucionId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Institucion WHERE InstitucionId=@InstitucionId)
		SET @InstitucionId = NULL

	IF @IdUsuarioGlobal IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Usuario WHERE UsuarioId=@IdUsuarioGlobal)
		SET @IdUsuarioGlobal = NULL

	INSERT INTO Auditoria
	(
	InstitucionId, UsuarioId, Accion, SeccionSistema, ElementoAfectado, Detalle, Exitoso, DireccionIp
	)
	VALUES
	(
	@InstitucionId, @IdUsuarioGlobal, @Accion, @SeccionSistema,
	LEFT(RTRIM(LTRIM(@ElementoAfectado)),150), LEFT(RTRIM(LTRIM(@Detalle)),500), @Exitoso, @DireccionIp
	)
END
GO

USE NaiaInc
GO

-- Pantalla de Auditoría (solo administradores). Si quien consulta no es admin, no devuelve filas.
-- Devuelve los 1000 movimientos más recientes de la universidad.
CREATE OR ALTER PROCEDURE SP_LISTAR_AUDITORIA
(
@InstitucionId    INT,
@IdUsuarioGlobal  INT
)
AS BEGIN
	SET NOCOUNT ON;

	SELECT TOP (1000)
	       AUD.AuditoriaId,
	       CONVERT(VARCHAR(10), AUD.Fecha, 103) + ' ' + CONVERT(VARCHAR(5), AUD.Fecha, 108) AS FechaHora,  -- dd/mm/aaaa hh:mm
	       AUD.Fecha,
	       AUD.UsuarioId,
	       ISNULL(USR.Nombre + ' ' + USR.Apellidos, N'Desconocido') AS Usuario,
	       AUD.Accion,
	       CASE AUD.Accion
	            WHEN N'CambiarEstado' THEN N'Cambio de estado'
	            WHEN N'InicioSesion'  THEN N'Inicio de sesión'
	            ELSE AUD.Accion
	       END AS AccionTexto,
	       AUD.SeccionSistema,
	       AUD.ElementoAfectado,
	       AUD.Detalle,
	       AUD.Exitoso,
	       CASE AUD.Exitoso WHEN 1 THEN N'Exitoso' ELSE N'Fallido' END AS Resultado,
	       AUD.DireccionIp
	FROM Auditoria AUD
	LEFT JOIN Usuario USR ON USR.UsuarioId = AUD.UsuarioId
	WHERE AUD.InstitucionId = @InstitucionId
	  AND EXISTS (SELECT 1 FROM Usuario ADM INNER JOIN Rol ROL ON ROL.RolId = ADM.RolId
	              WHERE ADM.UsuarioId = @IdUsuarioGlobal AND ADM.InstitucionId = @InstitucionId
	                AND ADM.Activo = 1 AND ROL.PuedeAdministrar = 1)
	ORDER BY AUD.Fecha DESC, AUD.AuditoriaId DESC
END
GO

USE NaiaInc
GO

-- Filtros de la pantalla de Auditoría. Cualquier parámetro en NULL = "todos".
CREATE OR ALTER PROCEDURE SP_FILTRAR_AUDITORIA
(
@InstitucionId    INT,
@IdUsuarioGlobal  INT,
@FechaInicio      DATE,             -- NULL = sin límite
@FechaFin         DATE,             -- NULL = sin límite (incluye todo ese día)
@SeccionSistema   NVARCHAR(30),     -- NULL = todas
@Accion           NVARCHAR(30),     -- NULL = todas
@UsuarioId        INT,              -- NULL = todos
@Exitoso          BIT,              -- NULL = todos · 1 = solo exitosos · 0 = solo fallidos
@Filtro           NVARCHAR(100)     -- texto en Elemento o Detalle · NULL = sin texto
)
AS BEGIN
	SET NOCOUNT ON;

	SELECT TOP (1000)
	       AUD.AuditoriaId,
	       CONVERT(VARCHAR(10), AUD.Fecha, 103) + ' ' + CONVERT(VARCHAR(5), AUD.Fecha, 108) AS FechaHora,
	       AUD.Fecha,
	       AUD.UsuarioId,
	       ISNULL(USR.Nombre + ' ' + USR.Apellidos, N'Desconocido') AS Usuario,
	       AUD.Accion,
	       CASE AUD.Accion
	            WHEN N'CambiarEstado' THEN N'Cambio de estado'
	            WHEN N'InicioSesion'  THEN N'Inicio de sesión'
	            ELSE AUD.Accion
	       END AS AccionTexto,
	       AUD.SeccionSistema,
	       AUD.ElementoAfectado,
	       AUD.Detalle,
	       AUD.Exitoso,
	       CASE AUD.Exitoso WHEN 1 THEN N'Exitoso' ELSE N'Fallido' END AS Resultado,
	       AUD.DireccionIp
	FROM Auditoria AUD
	LEFT JOIN Usuario USR ON USR.UsuarioId = AUD.UsuarioId
	WHERE AUD.InstitucionId = @InstitucionId
	  AND EXISTS (SELECT 1 FROM Usuario ADM INNER JOIN Rol ROL ON ROL.RolId = ADM.RolId
	              WHERE ADM.UsuarioId = @IdUsuarioGlobal AND ADM.InstitucionId = @InstitucionId
	                AND ADM.Activo = 1 AND ROL.PuedeAdministrar = 1)
	  AND (@FechaInicio IS NULL    OR AUD.Fecha >= @FechaInicio)
	  AND (@FechaFin IS NULL       OR AUD.Fecha <  DATEADD(DAY, 1, @FechaFin))
	  AND (@SeccionSistema IS NULL OR AUD.SeccionSistema = @SeccionSistema)
	  AND (@Accion IS NULL         OR AUD.Accion = @Accion)
	  AND (@UsuarioId IS NULL      OR AUD.UsuarioId = @UsuarioId)
	  AND (@Exitoso IS NULL        OR AUD.Exitoso = @Exitoso)
	  AND (@Filtro IS NULL         OR AUD.ElementoAfectado LIKE '%' + @Filtro + '%'
	                               OR AUD.Detalle          LIKE '%' + @Filtro + '%')
	ORDER BY AUD.Fecha DESC, AUD.AuditoriaId DESC
END
GO


/* ================================================================================================
   SECCIÓN 2 · CATÁLOGOS GLOBALES
   Son iguales para todas las universidades y los define Naia. Solo se consultan
   (para llenar los dropdowns). Los planes, además, se pueden editar (cambio de precios).
   ================================================================================================ */
USE NaiaInc
GO

-- Pantalla "Registra tu universidad": tarjetas de planes. @SoloActivos = 1 para mostrar solo los vigentes.
CREATE OR ALTER PROCEDURE SP_LISTAR_PLANES
(
@SoloActivos BIT
)
AS BEGIN
	SELECT PlanId, Nombre AS NombrePlan, MaxUsuarios,
	       ISNULL(CAST(MaxUsuarios AS NVARCHAR(10)), N'Ilimitado') AS MaxUsuariosTexto,
	       PrecioMensual, Activo
	FROM PlanSuscripcion
	WHERE (@SoloActivos = 0 OR Activo = 1)
	ORDER BY PrecioMensual
END
GO

USE NaiaInc
GO

-- USO INTERNO DE NAIA (no tiene pantalla en la app de las universidades): cambiar precios o límites.
-- @MaxUsuarios = NULL significa ilimitado.
CREATE OR ALTER PROCEDURE SP_ACTUALIZA_PLANES
(
@PlanId         INT,
@Nombre         NVARCHAR(50),
@MaxUsuarios    INT,
@PrecioMensual  DECIMAL(10,2),
@Activo         BIT,
@DireccionIp    VARCHAR(45)
)
AS BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @Codigo INT = 0
	DECLARE @Motivo NVARCHAR(300)
	DECLARE @Cambios NVARCHAR(MAX) = N''
	DECLARE @DSC NVARCHAR(MAX)
	DECLARE @ELEMENTO NVARCHAR(150)
	DECLARE @AntNombre NVARCHAR(50), @AntMax INT, @AntPrecio DECIMAL(10,2), @AntActivo BIT

	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM PlanSuscripcion WHERE PlanId=@PlanId)
		BEGIN
			SELECT -2 /*EL PLAN NO EXISTE*/
			RETURN
		END

		SET @Nombre = LTRIM(RTRIM(@Nombre))
		SELECT @AntNombre=Nombre, @AntMax=MaxUsuarios, @AntPrecio=PrecioMensual, @AntActivo=Activo
		FROM PlanSuscripcion WHERE PlanId=@PlanId
		SET @ELEMENTO = N'Plan: ' + @AntNombre

		---------------------------------------- VALIDACIONES ----------------------------------------
		IF ISNULL(@Nombre,N'')=N''
			SELECT @Codigo = -4, @Motivo = N'El nombre del plan es obligatorio.'
		ELSE IF @PrecioMensual IS NULL OR @PrecioMensual < 0
			SELECT @Codigo = -4, @Motivo = N'El precio no es válido.'
		ELSE IF @MaxUsuarios IS NOT NULL AND @MaxUsuarios <= 0
			SELECT @Codigo = -4, @Motivo = N'El máximo de usuarios debe ser mayor que cero.'
		ELSE IF EXISTS (SELECT 1 FROM PlanSuscripcion WHERE Nombre=@Nombre AND PlanId<>@PlanId)
			SELECT @Codigo = -1, @Motivo = N'Ya existe un plan con ese nombre.'
		-- No se puede bajar el límite por debajo de los usuarios activos de una universidad con ese plan
		ELSE IF @MaxUsuarios IS NOT NULL AND EXISTS (
		        SELECT 1 FROM Institucion INS
		        WHERE INS.PlanId=@PlanId
		          AND (SELECT COUNT(*) FROM Usuario USR WHERE USR.InstitucionId=INS.InstitucionId AND USR.Activo=1) > @MaxUsuarios)
			SELECT @Codigo = -6, @Motivo = N'Hay universidades con este plan que superan el nuevo límite de usuarios.'

		IF @Codigo < 0
		BEGIN
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Intento fallido de modificar el plan: ' + @Motivo
			EXEC SP_INSERTA_AUDITORIA NULL, NULL, N'Actualizar', N'Configuración', @ELEMENTO, @DSC, 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT @Codigo
			RETURN
		END

		---------------------------------------- DETALLE DE CAMBIOS ----------------------------------------
		IF @AntNombre <> @Nombre
			SET @Cambios = @Cambios + N'Nombre: ' + @AntNombre + N' → ' + @Nombre + N'; '
		IF ISNULL(@AntMax,-1) <> ISNULL(@MaxUsuarios,-1)
			SET @Cambios = @Cambios + N'Máximo de usuarios: ' + ISNULL(CAST(@AntMax AS NVARCHAR(10)),N'Ilimitado')
			             + N' → ' + ISNULL(CAST(@MaxUsuarios AS NVARCHAR(10)),N'Ilimitado') + N'; '
		IF @AntPrecio <> @PrecioMensual
			SET @Cambios = @Cambios + N'Precio mensual: $' + CAST(@AntPrecio AS NVARCHAR(20)) + N' → $' + CAST(@PrecioMensual AS NVARCHAR(20)) + N'; '
		IF @AntActivo <> @Activo
			SET @Cambios = @Cambios + N'Estado: ' + CASE @AntActivo WHEN 1 THEN N'Activo' ELSE N'Inactivo' END
			             + N' → ' + CASE @Activo WHEN 1 THEN N'Activo' ELSE N'Inactivo' END + N'; '
		IF @Cambios = N'' SET @Cambios = N'Se guardó sin cambios.'

		BEGIN TRANSACTION
			UPDATE PlanSuscripcion
			SET Nombre=@Nombre, MaxUsuarios=@MaxUsuarios, PrecioMensual=@PrecioMensual, Activo=@Activo
			WHERE PlanId=@PlanId

			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			EXEC SP_INSERTA_AUDITORIA NULL, NULL, N'Actualizar', N'Configuración', @ELEMENTO, @Cambios, 1, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		COMMIT TRANSACTION

		SELECT @PlanId
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SET @DSC = N'Error al modificar el plan: ' + ERROR_MESSAGE()
		EXEC SP_INSERTA_AUDITORIA NULL, NULL, N'Actualizar', N'Configuración', @ELEMENTO, @DSC, 0, @DireccionIp
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SELECT 0
	END CATCH
END
GO

USE NaiaInc
GO

-- Dropdown "Rol" del formulario de usuario. TipoNumeroInterno es la etiqueta del campo (Carné / N.º de empleado).
CREATE OR ALTER PROCEDURE SP_LISTAR_ROLES
AS BEGIN
	SELECT RolId, Nombre AS Rol, Descripcion, TipoNumeroInterno, PuedeResolverTickets, PuedeAdministrar
	FROM Rol
	ORDER BY RolId
END
GO

USE NaiaInc
GO

-- Dropdown "Tipo de identificación".
CREATE OR ALTER PROCEDURE SP_LISTAR_TIPOS_IDENTIFICACION
AS BEGIN
	SELECT TipoIdentificacionId, Nombre AS TipoIdentificacion
	FROM TipoIdentificacion
	WHERE Activo = 1
	ORDER BY TipoIdentificacionId
END
GO

USE NaiaInc
GO

-- Dropdown "Prioridad" y colores de las etiquetas. Ordenado de la más urgente (1) a la menos urgente (4).
CREATE OR ALTER PROCEDURE SP_LISTAR_PRIORIDADES
AS BEGIN
	SELECT PrioridadId, Nombre AS Prioridad, Nivel, SlaHoras, ColorHex
	FROM Prioridad
	ORDER BY Nivel
END
GO

USE NaiaInc
GO

-- Filtro "Estado" de la lista de tiquetes. EsFinal = 1 para Cerrado y Cancelado.
CREATE OR ALTER PROCEDURE SP_LISTAR_ESTADOS_TICKET
AS BEGIN
	SELECT EstadoId, Nombre AS Estado, Orden, EsFinal
	FROM EstadoTicket
	ORDER BY Orden
END
GO

USE NaiaInc
GO

-- Todas las reglas de cambio de estado con sus nombres (para documentación o una pantalla de ayuda).
CREATE OR ALTER PROCEDURE SP_LISTAR_TRANSICIONES
AS BEGIN
	SELECT TRA.EstadoOrigenId,  ORI.Nombre AS EstadoOrigen,
	       TRA.EstadoDestinoId, DES.Nombre AS EstadoDestino,
	       TRA.RequiereMotivo, TRA.PermiteSolicitante, TRA.PermiteSoporte
	FROM TransicionEstado TRA
	INNER JOIN EstadoTicket ORI ON ORI.EstadoId = TRA.EstadoOrigenId
	INNER JOIN EstadoTicket DES ON DES.EstadoId = TRA.EstadoDestinoId
	ORDER BY ORI.Orden, DES.Orden
END
GO


/* ================================================================================================
   SECCIÓN 3 · INSTITUCIÓN (la universidad cliente)
   ================================================================================================ */
USE NaiaInc
GO

-- Pantalla "Registra tu universidad". En UNA sola transacción crea:
--   1. La universidad con el plan elegido
--   2. El departamento "Administración General"
--   3. Tres ubicaciones virtuales (para tiquetes que no ocurren en un aula)
--   4. El primer usuario administrador (RolId 4) dentro de ese departamento
-- Si algo falla, no se crea nada. Devuelve el InstitucionId nuevo.
-- @DominioCorreo se escribe sin @, ej. 'uam.ac.cr'. @Correo del admin debe terminar en ese dominio.
CREATE OR ALTER PROCEDURE SP_INSERTA_INSTITUCIONES
(
@PlanId                INT,
@NombreInstitucion     NVARCHAR(150),
@Siglas                NVARCHAR(10),
@DominioCorreo         VARCHAR(100),
@LogoUrl               NVARCHAR(300),     -- puede ser NULL
@TipoIdentificacionId  TINYINT,           -- datos del administrador ↓
@Identificacion        VARCHAR(30),
@NumeroInterno         VARCHAR(30),
@Nombre                NVARCHAR(60),
@Apellidos             NVARCHAR(80),
@Correo                VARCHAR(150),
@Contrasena            VARCHAR(256),
@DireccionIp           VARCHAR(45)
)
AS BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @Codigo INT = 0
	DECLARE @Motivo NVARCHAR(300)
	DECLARE @NuevaInstitucionId INT
	DECLARE @DepartamentoId INT
	DECLARE @AdminId INT
	DECLARE @DSC NVARCHAR(MAX)
	DECLARE @ELEMENTO NVARCHAR(150)

	BEGIN TRY
		SET @NombreInstitucion = LTRIM(RTRIM(@NombreInstitucion))
		SET @Siglas            = LTRIM(RTRIM(@Siglas))
		SET @DominioCorreo     = LOWER(REPLACE(LTRIM(RTRIM(@DominioCorreo)), '@', ''))
		SET @Correo            = LOWER(LTRIM(RTRIM(@Correo)))
		SET @ELEMENTO          = N'Universidad: ' + ISNULL(@NombreInstitucion,N'') + N' (' + ISNULL(@Siglas,N'') + N')'

		---------------------------------------- VALIDACIONES ----------------------------------------
		IF NOT EXISTS (SELECT 1 FROM PlanSuscripcion WHERE PlanId=@PlanId AND Activo=1)
			SELECT @Codigo = -4, @Motivo = N'El plan seleccionado no es válido.'

		ELSE IF ISNULL(@NombreInstitucion,N'')=N'' OR ISNULL(@Siglas,N'')=N'' OR ISNULL(@DominioCorreo,'')=''
		     OR LTRIM(RTRIM(ISNULL(@Nombre,'')))='' OR LTRIM(RTRIM(ISNULL(@Apellidos,'')))=''
		     OR LTRIM(RTRIM(ISNULL(@Identificacion,'')))='' OR LTRIM(RTRIM(ISNULL(@NumeroInterno,'')))=''
		     OR ISNULL(@Correo,'')='' OR ISNULL(@Contrasena,'')=''
			SELECT @Codigo = -4, @Motivo = N'Hay campos obligatorios vacíos.'

		ELSE IF @DominioCorreo NOT LIKE '%_._%' OR @DominioCorreo LIKE '% %'
			SELECT @Codigo = -4, @Motivo = N'El dominio de correo no es válido.'

		ELSE IF NOT EXISTS (SELECT 1 FROM TipoIdentificacion WHERE TipoIdentificacionId=@TipoIdentificacionId AND Activo=1)
			SELECT @Codigo = -4, @Motivo = N'El tipo de identificación no es válido.'

		ELSE IF @Correo NOT LIKE '%@' + @DominioCorreo
			SELECT @Codigo = -4, @Motivo = N'El correo del administrador no pertenece al dominio de la universidad.'

		ELSE IF EXISTS (SELECT 1 FROM Institucion WHERE DominioCorreo=@DominioCorreo)
			SELECT @Codigo = -1, @Motivo = N'Ya existe una universidad registrada con ese dominio.'

		ELSE IF EXISTS (SELECT 1 FROM Usuario WHERE Correo=@Correo)
			SELECT @Codigo = -1, @Motivo = N'Ya existe un usuario con ese correo.'

		IF @Codigo < 0
		BEGIN
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Intento fallido de registrar la universidad: ' + @Motivo
			EXEC SP_INSERTA_AUDITORIA NULL, NULL, N'Crear', N'Configuración', @ELEMENTO, @DSC, 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT @Codigo
			RETURN
		END

		---------------------------------------- REGISTRO ----------------------------------------
		BEGIN TRANSACTION

			-- 1. Universidad
			INSERT INTO Institucion (PlanId, Nombre, Siglas, DominioCorreo, LogoUrl)
			VALUES (@PlanId, @NombreInstitucion, @Siglas, @DominioCorreo, @LogoUrl)
			SET @NuevaInstitucionId = SCOPE_IDENTITY()

			-- 2. Departamento por defecto del administrador
			INSERT INTO Departamento (InstitucionId, Nombre)
			VALUES (@NuevaInstitucionId, N'Administración General')
			SET @DepartamentoId = SCOPE_IDENTITY()

			-- 3. Ubicaciones virtuales (EsFisica = 0, sin edificio)
			INSERT INTO Ubicacion (InstitucionId, Nombre, Edificio, EsFisica) VALUES
			(@NuevaInstitucionId, N'Remoto (fuera del campus)', NULL, 0),
			(@NuevaInstitucionId, N'Plataforma o sistema en línea', NULL, 0),
			(@NuevaInstitucionId, N'Otro / No aplica', NULL, 0)

			-- 4. Primer administrador
			INSERT INTO Usuario
			(
			InstitucionId, RolId, CarreraId, DepartamentoId, EquipoId, TipoIdentificacionId,
			Identificacion, NumeroInterno, Nombre, Apellidos, Correo, Contrasena
			)
			VALUES
			(
			@NuevaInstitucionId, 4, NULL, @DepartamentoId, NULL, @TipoIdentificacionId,
			LTRIM(RTRIM(@Identificacion)), LTRIM(RTRIM(@NumeroInterno)), LTRIM(RTRIM(@Nombre)), LTRIM(RTRIM(@Apellidos)),
			@Correo, @Contrasena
			)
			SET @AdminId = SCOPE_IDENTITY()

			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Registró la universidad con el plan ' + (SELECT Nombre FROM PlanSuscripcion WHERE PlanId=@PlanId)
			         + N', dominio ' + @DominioCorreo + N' y administrador ' + LTRIM(RTRIM(@Nombre)) + N' ' + LTRIM(RTRIM(@Apellidos))
			         + N' (' + @Correo + N').'
			EXEC SP_INSERTA_AUDITORIA @NuevaInstitucionId, @AdminId, N'Crear', N'Configuración', @ELEMENTO, @DSC, 1, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------

		COMMIT TRANSACTION

		SELECT @NuevaInstitucionId
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SET @DSC = N'Error al registrar la universidad: ' + ERROR_MESSAGE()
		EXEC SP_INSERTA_AUDITORIA NULL, NULL, N'Crear', N'Configuración', @ELEMENTO, @DSC, 0, @DireccionIp
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SELECT 0
	END CATCH
END
GO

USE NaiaInc
GO

-- USO INTERNO DE NAIA: lista de universidades clientes con su plan y cantidad de usuarios.
CREATE OR ALTER PROCEDURE SP_LISTAR_INSTITUCIONES
AS BEGIN
	SELECT INS.InstitucionId, INS.Nombre AS NombreInstitucion, INS.Siglas, INS.DominioCorreo,
	       INS.PlanId, PLA.Nombre AS NombrePlan, PLA.MaxUsuarios, PLA.PrecioMensual,
	       (SELECT COUNT(*) FROM Usuario USR WHERE USR.InstitucionId=INS.InstitucionId AND USR.Activo=1) AS UsuariosActivos,
	       INS.Activa, INS.FechaCreacion
	FROM Institucion INS
	INNER JOIN PlanSuscripcion PLA ON PLA.PlanId = INS.PlanId
	ORDER BY INS.Activa DESC, INS.Nombre
END
GO

USE NaiaInc
GO

-- Pantalla "Configuración" de la universidad y encabezado de la app (nombre, siglas, logo).
CREATE OR ALTER PROCEDURE SP_INFO_INSTITUCION
(
@InstitucionId INT
)
AS BEGIN
	SELECT INS.InstitucionId, INS.Nombre AS NombreInstitucion, INS.Siglas, INS.DominioCorreo, INS.LogoUrl,
	       INS.PlanId, PLA.Nombre AS NombrePlan, PLA.MaxUsuarios, PLA.PrecioMensual,
	       (SELECT COUNT(*) FROM Usuario USR WHERE USR.InstitucionId=INS.InstitucionId AND USR.Activo=1) AS UsuariosActivos,
	       INS.Activa, INS.FechaCreacion
	FROM Institucion INS
	INNER JOIN PlanSuscripcion PLA ON PLA.PlanId = INS.PlanId
	WHERE INS.InstitucionId = @InstitucionId
END
GO

USE NaiaInc
GO

-- Pantalla "Configuración": el administrador edita nombre, siglas, logo o cambia de plan.
-- El dominio de correo NO se puede cambiar: todos los correos de los usuarios dependen de él.
CREATE OR ALTER PROCEDURE SP_ACTUALIZA_INSTITUCIONES
(
@InstitucionId      INT,
@PlanId             INT,
@NombreInstitucion  NVARCHAR(150),
@Siglas             NVARCHAR(10),
@LogoUrl            NVARCHAR(300),
@IdUsuarioGlobal    INT,
@DireccionIp        VARCHAR(45)
)
AS BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @Codigo INT = 0
	DECLARE @Motivo NVARCHAR(300)
	DECLARE @Cambios NVARCHAR(MAX) = N''
	DECLARE @DSC NVARCHAR(MAX)
	DECLARE @ELEMENTO NVARCHAR(150)
	DECLARE @MaxUsuarios INT
	DECLARE @AntPlanId INT, @AntPlan NVARCHAR(50), @AntNombre NVARCHAR(150), @AntSiglas NVARCHAR(10), @AntLogo NVARCHAR(300)

	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM Institucion WHERE InstitucionId=@InstitucionId)
		BEGIN
			SELECT -2 /*LA UNIVERSIDAD NO EXISTE*/
			RETURN
		END

		SET @NombreInstitucion = LTRIM(RTRIM(@NombreInstitucion))
		SET @Siglas = LTRIM(RTRIM(@Siglas))

		SELECT @AntPlanId=INS.PlanId, @AntPlan=PLA.Nombre, @AntNombre=INS.Nombre, @AntSiglas=INS.Siglas, @AntLogo=INS.LogoUrl
		FROM Institucion INS INNER JOIN PlanSuscripcion PLA ON PLA.PlanId=INS.PlanId
		WHERE INS.InstitucionId=@InstitucionId

		SET @ELEMENTO = N'Universidad: ' + @AntNombre + N' (' + @AntSiglas + N')'

		---------------------------------------- VALIDACIONES ----------------------------------------
		IF NOT EXISTS (SELECT 1 FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
		               WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId
		                 AND USR.Activo = 1 AND ROL.PuedeAdministrar = 1)
			SELECT @Codigo = -3, @Motivo = N'No tiene permisos para modificar la configuración.'

		ELSE IF ISNULL(@NombreInstitucion,N'')=N'' OR ISNULL(@Siglas,N'')=N''
			SELECT @Codigo = -4, @Motivo = N'El nombre y las siglas son obligatorios.'

		ELSE IF NOT EXISTS (SELECT 1 FROM PlanSuscripcion WHERE PlanId=@PlanId AND (Activo=1 OR PlanId=@AntPlanId))
			SELECT @Codigo = -4, @Motivo = N'El plan seleccionado no es válido.'

		ELSE
		BEGIN
			-- Si baja de plan, los usuarios activos deben caber en el nuevo límite
			SELECT @MaxUsuarios = MaxUsuarios FROM PlanSuscripcion WHERE PlanId=@PlanId
			IF @MaxUsuarios IS NOT NULL
			   AND (SELECT COUNT(*) FROM Usuario WHERE InstitucionId=@InstitucionId AND Activo=1) > @MaxUsuarios
				SELECT @Codigo = -5, @Motivo = N'La universidad tiene más usuarios activos de los que permite el plan elegido.'
		END

		IF @Codigo < 0
		BEGIN
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Intento fallido de modificar la universidad: ' + @Motivo
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Actualizar', N'Configuración', @ELEMENTO, @DSC, 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT @Codigo
			RETURN
		END

		---------------------------------------- DETALLE DE CAMBIOS ----------------------------------------
		IF @AntNombre <> @NombreInstitucion
			SET @Cambios = @Cambios + N'Nombre: ' + @AntNombre + N' → ' + @NombreInstitucion + N'; '
		IF @AntSiglas <> @Siglas
			SET @Cambios = @Cambios + N'Siglas: ' + @AntSiglas + N' → ' + @Siglas + N'; '
		IF @AntPlanId <> @PlanId
			SET @Cambios = @Cambios + N'Plan: ' + @AntPlan + N' → ' + (SELECT Nombre FROM PlanSuscripcion WHERE PlanId=@PlanId) + N'; '
		IF ISNULL(@AntLogo,N'') <> ISNULL(@LogoUrl,N'')
			SET @Cambios = @Cambios + N'Logo: actualizado; '
		IF @Cambios = N'' SET @Cambios = N'Se guardó sin cambios.'

		BEGIN TRANSACTION
			UPDATE Institucion
			SET PlanId=@PlanId, Nombre=@NombreInstitucion, Siglas=@Siglas, LogoUrl=@LogoUrl
			WHERE InstitucionId=@InstitucionId

			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Actualizar', N'Configuración', @ELEMENTO, @Cambios, 1, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		COMMIT TRANSACTION

		SELECT @InstitucionId
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SET @DSC = N'Error al modificar la universidad: ' + ERROR_MESSAGE()
		EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Actualizar', N'Configuración', @ELEMENTO, @DSC, 0, @DireccionIp
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SELECT 0
	END CATCH
END
GO

USE NaiaInc
GO

-- "Cancelar suscripción": el administrador desactiva la universidad. Nadie de esa universidad
-- podrá volver a iniciar sesión (SP_INICIAR_SESION devuelve -6). No se borra ningún dato.
-- Reactivarla es una tarea interna del equipo Naia.
CREATE OR ALTER PROCEDURE SP_ELIMINA_INSTITUCIONES
(
@InstitucionId    INT,
@IdUsuarioGlobal  INT,
@DireccionIp      VARCHAR(45)
)
AS BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @Codigo INT = 0
	DECLARE @Motivo NVARCHAR(300)
	DECLARE @DSC NVARCHAR(MAX)
	DECLARE @ELEMENTO NVARCHAR(150)
	DECLARE @Activa BIT

	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM Institucion WHERE InstitucionId=@InstitucionId)
		BEGIN
			SELECT -2 /*LA UNIVERSIDAD NO EXISTE*/
			RETURN
		END

		SELECT @ELEMENTO = N'Universidad: ' + Nombre + N' (' + Siglas + N')', @Activa = Activa
		FROM Institucion WHERE InstitucionId=@InstitucionId

		IF NOT EXISTS (SELECT 1 FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
		               WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId
		                 AND USR.Activo = 1 AND ROL.PuedeAdministrar = 1)
			SELECT @Codigo = -3, @Motivo = N'No tiene permisos para cancelar la suscripción.'
		ELSE IF @Activa = 0
			SELECT @Codigo = -6, @Motivo = N'La universidad ya está desactivada.'

		IF @Codigo < 0
		BEGIN
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Intento fallido de desactivar la universidad: ' + @Motivo
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Desactivar', N'Configuración', @ELEMENTO, @DSC, 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT @Codigo
			RETURN
		END

		BEGIN TRANSACTION
			UPDATE Institucion SET Activa = 0 WHERE InstitucionId=@InstitucionId

			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Canceló la suscripción. Ningún usuario de la universidad podrá iniciar sesión.'
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Desactivar', N'Configuración', @ELEMENTO, @DSC, 1, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		COMMIT TRANSACTION

		SELECT @InstitucionId
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SET @DSC = N'Error al desactivar la universidad: ' + ERROR_MESSAGE()
		EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Desactivar', N'Configuración', @ELEMENTO, @DSC, 0, @DireccionIp
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SELECT 0
	END CATCH
END
GO


/* ================================================================================================
   SECCIÓN 4 · SEGURIDAD
   ================================================================================================ */
USE NaiaInc
GO

-- Pantalla de login. SIEMPRE devuelve una fila cuya primera columna se llama "Codigo":
--   Codigo > 0  -> éxito. Codigo es el UsuarioId y la fila trae los datos para guardar en Session.
--   Codigo -1   -> correo o contraseña incorrectos (no se dice cuál de los dos, por seguridad)
--   Codigo -3   -> la cuenta del usuario está desactivada
--   Codigo -6   -> la universidad está desactivada (suscripción cancelada)
--   Codigo  0   -> error inesperado
-- En C#: ExecuteReader, leer "Codigo"; si es > 0 leer el resto de columnas.
-- La contraseña se compara respetando mayúsculas y minúsculas.
-- Si el correo no existe, el intento se guarda en la auditoría de la universidad de ese dominio.
CREATE OR ALTER PROCEDURE SP_INICIAR_SESION
(
@Correo       VARCHAR(150),
@Contrasena   VARCHAR(256),
@DireccionIp  VARCHAR(45)
)
AS BEGIN
	SET NOCOUNT ON;

	DECLARE @UsuarioId INT
	DECLARE @InstitucionId INT
	DECLARE @Activo BIT
	DECLARE @InstitucionActiva BIT
	DECLARE @ContrasenaGuardada VARCHAR(256)
	DECLARE @ELEMENTO NVARCHAR(150)

	BEGIN TRY
		SET @Correo = LOWER(LTRIM(RTRIM(@Correo)))
		SET @ELEMENTO = @Correo

		SELECT @UsuarioId = USR.UsuarioId, @InstitucionId = USR.InstitucionId, @Activo = USR.Activo,
		       @InstitucionActiva = INS.Activa, @ContrasenaGuardada = USR.Contrasena
		FROM Usuario USR
		INNER JOIN Institucion INS ON INS.InstitucionId = USR.InstitucionId
		WHERE USR.Correo = @Correo

		-- 1. El correo no existe
		IF @UsuarioId IS NULL
		BEGIN
			SELECT @InstitucionId = InstitucionId FROM Institucion WHERE @Correo LIKE '%@' + DominioCorreo
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, NULL, N'InicioSesion', N'Seguridad', @ELEMENTO,
			     N'Intento fallido de inicio de sesión: el correo no está registrado.', 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT -1 AS Codigo
			RETURN
		END

		-- 2. Contraseña incorrecta (comparación sensible a mayúsculas)
		IF CAST(@ContrasenaGuardada AS VARBINARY(256)) <> CAST(ISNULL(@Contrasena,'') AS VARBINARY(256))
		BEGIN
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @UsuarioId, N'InicioSesion', N'Seguridad', @ELEMENTO,
			     N'Intento fallido de inicio de sesión: contraseña incorrecta.', 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT -1 AS Codigo
			RETURN
		END

		-- 3. Universidad desactivada
		IF @InstitucionActiva = 0
		BEGIN
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @UsuarioId, N'InicioSesion', N'Seguridad', @ELEMENTO,
			     N'Intento fallido de inicio de sesión: la universidad está desactivada.', 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT -6 AS Codigo
			RETURN
		END

		-- 4. Usuario desactivado
		IF @Activo = 0
		BEGIN
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @UsuarioId, N'InicioSesion', N'Seguridad', @ELEMENTO,
			     N'Intento fallido de inicio de sesión: la cuenta está desactivada.', 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT -3 AS Codigo
			RETURN
		END

		-- 5. Éxito
		UPDATE Usuario SET UltimoAcceso = SYSDATETIME() WHERE UsuarioId = @UsuarioId

		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		EXEC SP_INSERTA_AUDITORIA @InstitucionId, @UsuarioId, N'InicioSesion', N'Seguridad', @ELEMENTO,
		     N'Inició sesión.', 1, @DireccionIp
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------

		SELECT USR.UsuarioId AS Codigo,
		       USR.UsuarioId, USR.InstitucionId, USR.RolId, ROL.Nombre AS Rol,
		       ROL.PuedeResolverTickets, ROL.PuedeAdministrar,
		       USR.Nombre, USR.Apellidos, USR.Nombre + ' ' + USR.Apellidos AS NombreCompleto, USR.Correo,
		       INS.Nombre AS NombreInstitucion, INS.Siglas, INS.LogoUrl
		FROM Usuario USR
		INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
		INNER JOIN Institucion INS ON INS.InstitucionId = USR.InstitucionId
		WHERE USR.UsuarioId = @UsuarioId
	END TRY
	BEGIN CATCH
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		DECLARE @DSC NVARCHAR(MAX) = N'Error al iniciar sesión: ' + ERROR_MESSAGE()
		EXEC SP_INSERTA_AUDITORIA @InstitucionId, @UsuarioId, N'InicioSesion', N'Seguridad', @ELEMENTO, @DSC, 0, @DireccionIp
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SELECT 0 AS Codigo
	END CATCH
END
GO


/* ================================================================================================
   SECCIÓN 5 · CARRERAS
   Las usan Estudiantes y Profesores (Usuario.CarreraId). Las crea el administrador.
   ================================================================================================ */
USE NaiaInc
GO

-- Tabla de la pantalla de mantenimiento (@SoloActivos = 0) o dropdown del formulario de usuario (@SoloActivos = 1).
-- UsuariosActivos = cuántos usuarios activos tiene la carrera (no se puede desactivar si es mayor que 0).
CREATE OR ALTER PROCEDURE SP_LISTAR_CARRERAS
(
@InstitucionId INT,
@SoloActivos   BIT
)
AS BEGIN
	SELECT X.CarreraId, X.Nombre AS Carrera, X.Activo,
	       CASE X.Activo WHEN 1 THEN N'Activo' ELSE N'Inactivo' END AS EstadoTexto,
	       (SELECT COUNT(*) FROM Usuario USR WHERE USR.CarreraId = X.CarreraId AND USR.Activo = 1) AS UsuariosActivos
	FROM Carrera X
	WHERE X.InstitucionId = @InstitucionId
	  AND (@SoloActivos = 0 OR X.Activo = 1)
	ORDER BY X.Activo DESC, X.Nombre
END
GO

USE NaiaInc
GO

-- Barra de búsqueda de la pantalla de mantenimiento.
CREATE OR ALTER PROCEDURE SP_FILTRAR_CARRERAS
(
@InstitucionId INT,
@Filtro        NVARCHAR(100)
)
AS BEGIN
	SELECT X.CarreraId, X.Nombre AS Carrera, X.Activo,
	       CASE X.Activo WHEN 1 THEN N'Activo' ELSE N'Inactivo' END AS EstadoTexto,
	       (SELECT COUNT(*) FROM Usuario USR WHERE USR.CarreraId = X.CarreraId AND USR.Activo = 1) AS UsuariosActivos
	FROM Carrera X
	WHERE X.InstitucionId = @InstitucionId
	  AND X.Nombre LIKE '%' + @Filtro + '%'
	ORDER BY X.Activo DESC, X.Nombre
END
GO

USE NaiaInc
GO

-- Carga el formulario de edición.
CREATE OR ALTER PROCEDURE SP_INFO_CARRERA
(
@InstitucionId INT,
@CarreraId  INT
)
AS BEGIN
	SELECT CarreraId, Nombre AS Carrera, Activo
	FROM Carrera
	WHERE CarreraId = @CarreraId AND InstitucionId = @InstitucionId
END
GO

USE NaiaInc
GO

CREATE OR ALTER PROCEDURE SP_INSERTA_CARRERAS
(
@InstitucionId    INT,
@Nombre           NVARCHAR(100),
@IdUsuarioGlobal  INT,
@DireccionIp      VARCHAR(45)
)
AS BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @Codigo INT = 0
	DECLARE @Motivo NVARCHAR(300)
	DECLARE @NuevoId INT
	DECLARE @DSC NVARCHAR(MAX)
	DECLARE @ELEMENTO NVARCHAR(150)

	BEGIN TRY
		SET @Nombre = LTRIM(RTRIM(@Nombre))
		SET @ELEMENTO = N'Carrera: ' + ISNULL(@Nombre,N'')

		---------------------------------------- VALIDACIONES ----------------------------------------
		IF NOT EXISTS (SELECT 1 FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
		               WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId
		                 AND USR.Activo = 1 AND ROL.PuedeAdministrar = 1)
			SELECT @Codigo = -3, @Motivo = N'No tiene permisos para crear carreras.'

		ELSE IF ISNULL(@Nombre,N'') = N''
			SELECT @Codigo = -4, @Motivo = N'El nombre es obligatorio.'

		ELSE IF EXISTS (SELECT 1 FROM Carrera WHERE InstitucionId=@InstitucionId AND Nombre=@Nombre)
			SELECT @Codigo = -1, @Motivo = N'Ya existe una carrera con ese nombre.'

		IF @Codigo < 0
		BEGIN
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Intento fallido de crear la carrera: ' + @Motivo
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Crear', N'Catálogos', @ELEMENTO, @DSC, 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT @Codigo
			RETURN
		END

		BEGIN TRANSACTION
			INSERT INTO Carrera (InstitucionId, Nombre) VALUES (@InstitucionId, @Nombre)
			SET @NuevoId = SCOPE_IDENTITY()

			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Creó la carrera ' + @Nombre + N'.'
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Crear', N'Catálogos', @ELEMENTO, @DSC, 1, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		COMMIT TRANSACTION

		SELECT @NuevoId
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SET @DSC = N'Error al crear la carrera: ' + ERROR_MESSAGE()
		EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Crear', N'Catálogos', @ELEMENTO, @DSC, 0, @DireccionIp
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SELECT 0
	END CATCH
END
GO

USE NaiaInc
GO

-- Editar el nombre. @Activo = 1 reactiva · @Activo = 0 desactiva (mismas reglas que SP_ELIMINA_CARRERAS).
CREATE OR ALTER PROCEDURE SP_ACTUALIZA_CARRERAS
(
@InstitucionId    INT,
@CarreraId  INT,
@Nombre           NVARCHAR(100),
@Activo           BIT,
@IdUsuarioGlobal  INT,
@DireccionIp      VARCHAR(45)
)
AS BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @Codigo INT = 0
	DECLARE @Motivo NVARCHAR(300)
	DECLARE @Cambios NVARCHAR(MAX) = N''
	DECLARE @DSC NVARCHAR(MAX)
	DECLARE @ELEMENTO NVARCHAR(150)
	DECLARE @AntNombre NVARCHAR(100), @AntActivo BIT

	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM Carrera WHERE CarreraId=@CarreraId AND InstitucionId=@InstitucionId)
		BEGIN
			SELECT -2 /*NO SE PUEDE ACTUALIZAR: EL REGISTRO NO EXISTE*/
			RETURN
		END

		SET @Nombre = LTRIM(RTRIM(@Nombre))
		SELECT @AntNombre = Nombre, @AntActivo = Activo FROM Carrera WHERE CarreraId=@CarreraId
		SET @ELEMENTO = N'Carrera: ' + @AntNombre

		---------------------------------------- VALIDACIONES ----------------------------------------
		IF NOT EXISTS (SELECT 1 FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
		               WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId
		                 AND USR.Activo = 1 AND ROL.PuedeAdministrar = 1)
			SELECT @Codigo = -3, @Motivo = N'No tiene permisos para modificar carreras.'

		ELSE IF ISNULL(@Nombre,N'') = N''
			SELECT @Codigo = -4, @Motivo = N'El nombre es obligatorio.'

		ELSE IF EXISTS (SELECT 1 FROM Carrera WHERE InstitucionId=@InstitucionId AND Nombre=@Nombre AND CarreraId<>@CarreraId)
			SELECT @Codigo = -1, @Motivo = N'Ya existe una carrera con ese nombre.'

		ELSE IF @AntActivo = 1 AND @Activo = 0
		     AND EXISTS (SELECT 1 FROM Usuario WHERE CarreraId=@CarreraId AND Activo=1)
			SELECT @Codigo = -6, @Motivo = N'No se puede desactivar: tiene usuarios activos. Muévalos primero a otra carrera.'

		IF @Codigo < 0
		BEGIN
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Intento fallido de modificar la carrera: ' + @Motivo
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Actualizar', N'Catálogos', @ELEMENTO, @DSC, 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT @Codigo
			RETURN
		END

		---------------------------------------- DETALLE DE CAMBIOS ----------------------------------------
		IF @AntNombre <> @Nombre
			SET @Cambios = @Cambios + N'Nombre: ' + @AntNombre + N' → ' + @Nombre + N'; '
		IF @AntActivo <> @Activo
			SET @Cambios = @Cambios + N'Estado: ' + CASE @AntActivo WHEN 1 THEN N'Activo' ELSE N'Inactivo' END
			             + N' → ' + CASE @Activo WHEN 1 THEN N'Activo' ELSE N'Inactivo' END + N'; '
		IF @Cambios = N'' SET @Cambios = N'Se guardó sin cambios.'

		BEGIN TRANSACTION
			UPDATE Carrera SET Nombre=@Nombre, Activo=@Activo
			WHERE CarreraId=@CarreraId AND InstitucionId=@InstitucionId

			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Actualizar', N'Catálogos', @ELEMENTO, @Cambios, 1, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		COMMIT TRANSACTION

		SELECT @CarreraId
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SET @DSC = N'Error al modificar la carrera: ' + ERROR_MESSAGE()
		EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Actualizar', N'Catálogos', @ELEMENTO, @DSC, 0, @DireccionIp
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SELECT 0
	END CATCH
END
GO

USE NaiaInc
GO

-- Desactivar (Activo = 0). No se permite si todavía tiene usuarios activos.
CREATE OR ALTER PROCEDURE SP_ELIMINA_CARRERAS
(
@InstitucionId    INT,
@CarreraId  INT,
@IdUsuarioGlobal  INT,
@DireccionIp      VARCHAR(45)
)
AS BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @Codigo INT = 0
	DECLARE @Motivo NVARCHAR(300)
	DECLARE @DSC NVARCHAR(MAX)
	DECLARE @ELEMENTO NVARCHAR(150)
	DECLARE @Activo BIT

	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM Carrera WHERE CarreraId=@CarreraId AND InstitucionId=@InstitucionId)
		BEGIN
			SELECT -2 /*NO SE PUEDE ELIMINAR: EL REGISTRO NO EXISTE*/
			RETURN
		END

		SELECT @ELEMENTO = N'Carrera: ' + Nombre, @Activo = Activo FROM Carrera WHERE CarreraId=@CarreraId

		---------------------------------------- VALIDACIONES ----------------------------------------
		IF NOT EXISTS (SELECT 1 FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
		               WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId
		                 AND USR.Activo = 1 AND ROL.PuedeAdministrar = 1)
			SELECT @Codigo = -3, @Motivo = N'No tiene permisos para desactivar carreras.'

		ELSE IF @Activo = 0
			SELECT @Codigo = -6, @Motivo = N'Ya está desactivada.'

		ELSE IF EXISTS (SELECT 1 FROM Usuario WHERE CarreraId=@CarreraId AND Activo=1)
			SELECT @Codigo = -6, @Motivo = N'No se puede desactivar: tiene usuarios activos. Muévalos primero a otra carrera.'

		IF @Codigo < 0
		BEGIN
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Intento fallido de desactivar la carrera: ' + @Motivo
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Desactivar', N'Catálogos', @ELEMENTO, @DSC, 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT @Codigo
			RETURN
		END

		BEGIN TRANSACTION
			UPDATE Carrera SET Activo = 0 WHERE CarreraId=@CarreraId AND InstitucionId=@InstitucionId

			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Desactivó la carrera. Ya no aparecerá en los formularios.'
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Desactivar', N'Catálogos', @ELEMENTO, @DSC, 1, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		COMMIT TRANSACTION

		SELECT @CarreraId
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SET @DSC = N'Error al desactivar la carrera: ' + ERROR_MESSAGE()
		EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Desactivar', N'Catálogos', @ELEMENTO, @DSC, 0, @DireccionIp
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SELECT 0
	END CATCH
END
GO

/* ================================================================================================
   SECCIÓN 6 · DEPARTAMENTOS
   Los usan Soporte técnico y Administrativos (Usuario.DepartamentoId). "Administración General" se crea solo al registrar la universidad.
   ================================================================================================ */
USE NaiaInc
GO

-- Tabla de la pantalla de mantenimiento (@SoloActivos = 0) o dropdown del formulario de usuario (@SoloActivos = 1).
-- UsuariosActivos = cuántos usuarios activos tiene el departamento (no se puede desactivar si es mayor que 0).
CREATE OR ALTER PROCEDURE SP_LISTAR_DEPARTAMENTOS
(
@InstitucionId INT,
@SoloActivos   BIT
)
AS BEGIN
	SELECT X.DepartamentoId, X.Nombre AS Departamento, X.Activo,
	       CASE X.Activo WHEN 1 THEN N'Activo' ELSE N'Inactivo' END AS EstadoTexto,
	       (SELECT COUNT(*) FROM Usuario USR WHERE USR.DepartamentoId = X.DepartamentoId AND USR.Activo = 1) AS UsuariosActivos
	FROM Departamento X
	WHERE X.InstitucionId = @InstitucionId
	  AND (@SoloActivos = 0 OR X.Activo = 1)
	ORDER BY X.Activo DESC, X.Nombre
END
GO

USE NaiaInc
GO

-- Barra de búsqueda de la pantalla de mantenimiento.
CREATE OR ALTER PROCEDURE SP_FILTRAR_DEPARTAMENTOS
(
@InstitucionId INT,
@Filtro        NVARCHAR(100)
)
AS BEGIN
	SELECT X.DepartamentoId, X.Nombre AS Departamento, X.Activo,
	       CASE X.Activo WHEN 1 THEN N'Activo' ELSE N'Inactivo' END AS EstadoTexto,
	       (SELECT COUNT(*) FROM Usuario USR WHERE USR.DepartamentoId = X.DepartamentoId AND USR.Activo = 1) AS UsuariosActivos
	FROM Departamento X
	WHERE X.InstitucionId = @InstitucionId
	  AND X.Nombre LIKE '%' + @Filtro + '%'
	ORDER BY X.Activo DESC, X.Nombre
END
GO

USE NaiaInc
GO

-- Carga el formulario de edición.
CREATE OR ALTER PROCEDURE SP_INFO_DEPARTAMENTO
(
@InstitucionId INT,
@DepartamentoId  INT
)
AS BEGIN
	SELECT DepartamentoId, Nombre AS Departamento, Activo
	FROM Departamento
	WHERE DepartamentoId = @DepartamentoId AND InstitucionId = @InstitucionId
END
GO

USE NaiaInc
GO

CREATE OR ALTER PROCEDURE SP_INSERTA_DEPARTAMENTOS
(
@InstitucionId    INT,
@Nombre           NVARCHAR(100),
@IdUsuarioGlobal  INT,
@DireccionIp      VARCHAR(45)
)
AS BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @Codigo INT = 0
	DECLARE @Motivo NVARCHAR(300)
	DECLARE @NuevoId INT
	DECLARE @DSC NVARCHAR(MAX)
	DECLARE @ELEMENTO NVARCHAR(150)

	BEGIN TRY
		SET @Nombre = LTRIM(RTRIM(@Nombre))
		SET @ELEMENTO = N'Departamento: ' + ISNULL(@Nombre,N'')

		---------------------------------------- VALIDACIONES ----------------------------------------
		IF NOT EXISTS (SELECT 1 FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
		               WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId
		                 AND USR.Activo = 1 AND ROL.PuedeAdministrar = 1)
			SELECT @Codigo = -3, @Motivo = N'No tiene permisos para crear departamentos.'

		ELSE IF ISNULL(@Nombre,N'') = N''
			SELECT @Codigo = -4, @Motivo = N'El nombre es obligatorio.'

		ELSE IF EXISTS (SELECT 1 FROM Departamento WHERE InstitucionId=@InstitucionId AND Nombre=@Nombre)
			SELECT @Codigo = -1, @Motivo = N'Ya existe un departamento con ese nombre.'

		IF @Codigo < 0
		BEGIN
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Intento fallido de crear el departamento: ' + @Motivo
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Crear', N'Catálogos', @ELEMENTO, @DSC, 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT @Codigo
			RETURN
		END

		BEGIN TRANSACTION
			INSERT INTO Departamento (InstitucionId, Nombre) VALUES (@InstitucionId, @Nombre)
			SET @NuevoId = SCOPE_IDENTITY()

			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Creó el departamento ' + @Nombre + N'.'
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Crear', N'Catálogos', @ELEMENTO, @DSC, 1, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		COMMIT TRANSACTION

		SELECT @NuevoId
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SET @DSC = N'Error al crear el departamento: ' + ERROR_MESSAGE()
		EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Crear', N'Catálogos', @ELEMENTO, @DSC, 0, @DireccionIp
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SELECT 0
	END CATCH
END
GO

USE NaiaInc
GO

-- Editar el nombre. @Activo = 1 reactiva · @Activo = 0 desactiva (mismas reglas que SP_ELIMINA_DEPARTAMENTOS).
CREATE OR ALTER PROCEDURE SP_ACTUALIZA_DEPARTAMENTOS
(
@InstitucionId    INT,
@DepartamentoId  INT,
@Nombre           NVARCHAR(100),
@Activo           BIT,
@IdUsuarioGlobal  INT,
@DireccionIp      VARCHAR(45)
)
AS BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @Codigo INT = 0
	DECLARE @Motivo NVARCHAR(300)
	DECLARE @Cambios NVARCHAR(MAX) = N''
	DECLARE @DSC NVARCHAR(MAX)
	DECLARE @ELEMENTO NVARCHAR(150)
	DECLARE @AntNombre NVARCHAR(100), @AntActivo BIT

	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM Departamento WHERE DepartamentoId=@DepartamentoId AND InstitucionId=@InstitucionId)
		BEGIN
			SELECT -2 /*NO SE PUEDE ACTUALIZAR: EL REGISTRO NO EXISTE*/
			RETURN
		END

		SET @Nombre = LTRIM(RTRIM(@Nombre))
		SELECT @AntNombre = Nombre, @AntActivo = Activo FROM Departamento WHERE DepartamentoId=@DepartamentoId
		SET @ELEMENTO = N'Departamento: ' + @AntNombre

		---------------------------------------- VALIDACIONES ----------------------------------------
		IF NOT EXISTS (SELECT 1 FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
		               WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId
		                 AND USR.Activo = 1 AND ROL.PuedeAdministrar = 1)
			SELECT @Codigo = -3, @Motivo = N'No tiene permisos para modificar departamentos.'

		ELSE IF ISNULL(@Nombre,N'') = N''
			SELECT @Codigo = -4, @Motivo = N'El nombre es obligatorio.'

		ELSE IF EXISTS (SELECT 1 FROM Departamento WHERE InstitucionId=@InstitucionId AND Nombre=@Nombre AND DepartamentoId<>@DepartamentoId)
			SELECT @Codigo = -1, @Motivo = N'Ya existe un departamento con ese nombre.'

		ELSE IF @AntActivo = 1 AND @Activo = 0
		     AND EXISTS (SELECT 1 FROM Usuario WHERE DepartamentoId=@DepartamentoId AND Activo=1)
			SELECT @Codigo = -6, @Motivo = N'No se puede desactivar: tiene usuarios activos. Muévalos primero a otro departamento.'

		IF @Codigo < 0
		BEGIN
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Intento fallido de modificar el departamento: ' + @Motivo
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Actualizar', N'Catálogos', @ELEMENTO, @DSC, 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT @Codigo
			RETURN
		END

		---------------------------------------- DETALLE DE CAMBIOS ----------------------------------------
		IF @AntNombre <> @Nombre
			SET @Cambios = @Cambios + N'Nombre: ' + @AntNombre + N' → ' + @Nombre + N'; '
		IF @AntActivo <> @Activo
			SET @Cambios = @Cambios + N'Estado: ' + CASE @AntActivo WHEN 1 THEN N'Activo' ELSE N'Inactivo' END
			             + N' → ' + CASE @Activo WHEN 1 THEN N'Activo' ELSE N'Inactivo' END + N'; '
		IF @Cambios = N'' SET @Cambios = N'Se guardó sin cambios.'

		BEGIN TRANSACTION
			UPDATE Departamento SET Nombre=@Nombre, Activo=@Activo
			WHERE DepartamentoId=@DepartamentoId AND InstitucionId=@InstitucionId

			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Actualizar', N'Catálogos', @ELEMENTO, @Cambios, 1, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		COMMIT TRANSACTION

		SELECT @DepartamentoId
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SET @DSC = N'Error al modificar el departamento: ' + ERROR_MESSAGE()
		EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Actualizar', N'Catálogos', @ELEMENTO, @DSC, 0, @DireccionIp
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SELECT 0
	END CATCH
END
GO

USE NaiaInc
GO

-- Desactivar (Activo = 0). No se permite si todavía tiene usuarios activos.
CREATE OR ALTER PROCEDURE SP_ELIMINA_DEPARTAMENTOS
(
@InstitucionId    INT,
@DepartamentoId  INT,
@IdUsuarioGlobal  INT,
@DireccionIp      VARCHAR(45)
)
AS BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @Codigo INT = 0
	DECLARE @Motivo NVARCHAR(300)
	DECLARE @DSC NVARCHAR(MAX)
	DECLARE @ELEMENTO NVARCHAR(150)
	DECLARE @Activo BIT

	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM Departamento WHERE DepartamentoId=@DepartamentoId AND InstitucionId=@InstitucionId)
		BEGIN
			SELECT -2 /*NO SE PUEDE ELIMINAR: EL REGISTRO NO EXISTE*/
			RETURN
		END

		SELECT @ELEMENTO = N'Departamento: ' + Nombre, @Activo = Activo FROM Departamento WHERE DepartamentoId=@DepartamentoId

		---------------------------------------- VALIDACIONES ----------------------------------------
		IF NOT EXISTS (SELECT 1 FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
		               WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId
		                 AND USR.Activo = 1 AND ROL.PuedeAdministrar = 1)
			SELECT @Codigo = -3, @Motivo = N'No tiene permisos para desactivar departamentos.'

		ELSE IF @Activo = 0
			SELECT @Codigo = -6, @Motivo = N'Ya está desactivado.'

		ELSE IF EXISTS (SELECT 1 FROM Usuario WHERE DepartamentoId=@DepartamentoId AND Activo=1)
			SELECT @Codigo = -6, @Motivo = N'No se puede desactivar: tiene usuarios activos. Muévalos primero a otro departamento.'

		IF @Codigo < 0
		BEGIN
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Intento fallido de desactivar el departamento: ' + @Motivo
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Desactivar', N'Catálogos', @ELEMENTO, @DSC, 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT @Codigo
			RETURN
		END

		BEGIN TRANSACTION
			UPDATE Departamento SET Activo = 0 WHERE DepartamentoId=@DepartamentoId AND InstitucionId=@InstitucionId

			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Desactivó el departamento. Ya no aparecerá en los formularios.'
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Desactivar', N'Catálogos', @ELEMENTO, @DSC, 1, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		COMMIT TRANSACTION

		SELECT @DepartamentoId
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SET @DSC = N'Error al desactivar el departamento: ' + ERROR_MESSAGE()
		EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Desactivar', N'Catálogos', @ELEMENTO, @DSC, 0, @DireccionIp
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SELECT 0
	END CATCH
END
GO

/* ================================================================================================
   SECCIÓN 7 · EQUIPOS DE SOPORTE
   Grupos de técnicos (Redes, Laboratorios, Aplicaciones…). Cada técnico (RolId 3) pertenece a uno.
   Una categoría puede tener un equipo predeterminado (Categoria.EquipoPredeterminadoId).
   ================================================================================================ */
USE NaiaInc
GO

-- @SoloActivos = 0 para la pantalla de mantenimiento, 1 para dropdowns.
CREATE OR ALTER PROCEDURE SP_LISTAR_EQUIPOS
(
@InstitucionId INT,
@SoloActivos   BIT
)
AS BEGIN
	SELECT EQU.EquipoId, EQU.Nombre AS Equipo, EQU.Descripcion, EQU.Activo,
	       CASE EQU.Activo WHEN 1 THEN N'Activo' ELSE N'Inactivo' END AS EstadoTexto,
	       (SELECT COUNT(*) FROM Usuario USR WHERE USR.EquipoId = EQU.EquipoId AND USR.Activo = 1) AS TecnicosActivos
	FROM EquipoSoporte EQU
	WHERE EQU.InstitucionId = @InstitucionId
	  AND (@SoloActivos = 0 OR EQU.Activo = 1)
	ORDER BY EQU.Activo DESC, EQU.Nombre
END
GO

USE NaiaInc
GO

CREATE OR ALTER PROCEDURE SP_FILTRAR_EQUIPOS
(
@InstitucionId INT,
@Filtro        NVARCHAR(100)
)
AS BEGIN
	SELECT EQU.EquipoId, EQU.Nombre AS Equipo, EQU.Descripcion, EQU.Activo,
	       CASE EQU.Activo WHEN 1 THEN N'Activo' ELSE N'Inactivo' END AS EstadoTexto,
	       (SELECT COUNT(*) FROM Usuario USR WHERE USR.EquipoId = EQU.EquipoId AND USR.Activo = 1) AS TecnicosActivos
	FROM EquipoSoporte EQU
	WHERE EQU.InstitucionId = @InstitucionId
	  AND (EQU.Nombre LIKE '%' + @Filtro + '%' OR EQU.Descripcion LIKE '%' + @Filtro + '%')
	ORDER BY EQU.Activo DESC, EQU.Nombre
END
GO

USE NaiaInc
GO

CREATE OR ALTER PROCEDURE SP_INFO_EQUIPO
(
@InstitucionId INT,
@EquipoId      INT
)
AS BEGIN
	SELECT EquipoId, Nombre AS Equipo, Descripcion, Activo
	FROM EquipoSoporte
	WHERE EquipoId = @EquipoId AND InstitucionId = @InstitucionId
END
GO

USE NaiaInc
GO

CREATE OR ALTER PROCEDURE SP_INSERTA_EQUIPOS
(
@InstitucionId    INT,
@Nombre           NVARCHAR(80),
@Descripcion      NVARCHAR(250),     -- puede ser NULL
@IdUsuarioGlobal  INT,
@DireccionIp      VARCHAR(45)
)
AS BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @Codigo INT = 0
	DECLARE @Motivo NVARCHAR(300)
	DECLARE @NuevoId INT
	DECLARE @DSC NVARCHAR(MAX)
	DECLARE @ELEMENTO NVARCHAR(150)

	BEGIN TRY
		SET @Nombre = LTRIM(RTRIM(@Nombre))
		SET @Descripcion = NULLIF(LTRIM(RTRIM(@Descripcion)), N'')
		SET @ELEMENTO = N'Equipo: ' + ISNULL(@Nombre,N'')

		IF NOT EXISTS (SELECT 1 FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
		               WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId
		                 AND USR.Activo = 1 AND ROL.PuedeAdministrar = 1)
			SELECT @Codigo = -3, @Motivo = N'No tiene permisos para crear equipos.'
		ELSE IF ISNULL(@Nombre,N'') = N''
			SELECT @Codigo = -4, @Motivo = N'El nombre es obligatorio.'
		ELSE IF EXISTS (SELECT 1 FROM EquipoSoporte WHERE InstitucionId=@InstitucionId AND Nombre=@Nombre)
			SELECT @Codigo = -1, @Motivo = N'Ya existe un equipo con ese nombre.'

		IF @Codigo < 0
		BEGIN
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Intento fallido de crear el equipo: ' + @Motivo
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Crear', N'Catálogos', @ELEMENTO, @DSC, 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT @Codigo
			RETURN
		END

		BEGIN TRANSACTION
			INSERT INTO EquipoSoporte (InstitucionId, Nombre, Descripcion) VALUES (@InstitucionId, @Nombre, @Descripcion)
			SET @NuevoId = SCOPE_IDENTITY()

			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Creó el equipo de soporte ' + @Nombre + N'.'
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Crear', N'Catálogos', @ELEMENTO, @DSC, 1, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		COMMIT TRANSACTION

		SELECT @NuevoId
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SET @DSC = N'Error al crear el equipo: ' + ERROR_MESSAGE()
		EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Crear', N'Catálogos', @ELEMENTO, @DSC, 0, @DireccionIp
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SELECT 0
	END CATCH
END
GO

USE NaiaInc
GO

-- @Activo = 1 reactiva · @Activo = 0 desactiva (mismas reglas que SP_ELIMINA_EQUIPOS).
CREATE OR ALTER PROCEDURE SP_ACTUALIZA_EQUIPOS
(
@InstitucionId    INT,
@EquipoId         INT,
@Nombre           NVARCHAR(80),
@Descripcion      NVARCHAR(250),
@Activo           BIT,
@IdUsuarioGlobal  INT,
@DireccionIp      VARCHAR(45)
)
AS BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @Codigo INT = 0
	DECLARE @Motivo NVARCHAR(300)
	DECLARE @Cambios NVARCHAR(MAX) = N''
	DECLARE @DSC NVARCHAR(MAX)
	DECLARE @ELEMENTO NVARCHAR(150)
	DECLARE @AntNombre NVARCHAR(80), @AntDescripcion NVARCHAR(250), @AntActivo BIT

	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM EquipoSoporte WHERE EquipoId=@EquipoId AND InstitucionId=@InstitucionId)
		BEGIN
			SELECT -2 /*NO SE PUEDE ACTUALIZAR: EL REGISTRO NO EXISTE*/
			RETURN
		END

		SET @Nombre = LTRIM(RTRIM(@Nombre))
		SET @Descripcion = NULLIF(LTRIM(RTRIM(@Descripcion)), N'')
		SELECT @AntNombre=Nombre, @AntDescripcion=Descripcion, @AntActivo=Activo FROM EquipoSoporte WHERE EquipoId=@EquipoId
		SET @ELEMENTO = N'Equipo: ' + @AntNombre

		IF NOT EXISTS (SELECT 1 FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
		               WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId
		                 AND USR.Activo = 1 AND ROL.PuedeAdministrar = 1)
			SELECT @Codigo = -3, @Motivo = N'No tiene permisos para modificar equipos.'
		ELSE IF ISNULL(@Nombre,N'') = N''
			SELECT @Codigo = -4, @Motivo = N'El nombre es obligatorio.'
		ELSE IF EXISTS (SELECT 1 FROM EquipoSoporte WHERE InstitucionId=@InstitucionId AND Nombre=@Nombre AND EquipoId<>@EquipoId)
			SELECT @Codigo = -1, @Motivo = N'Ya existe un equipo con ese nombre.'
		ELSE IF @AntActivo = 1 AND @Activo = 0 AND EXISTS (SELECT 1 FROM Usuario WHERE EquipoId=@EquipoId AND Activo=1)
			SELECT @Codigo = -6, @Motivo = N'No se puede desactivar: tiene técnicos activos. Muévalos primero a otro equipo.'
		ELSE IF @AntActivo = 1 AND @Activo = 0 AND EXISTS (SELECT 1 FROM Categoria WHERE EquipoPredeterminadoId=@EquipoId AND Activa=1)
			SELECT @Codigo = -6, @Motivo = N'No se puede desactivar: hay categorías activas que lo usan como equipo predeterminado.'

		IF @Codigo < 0
		BEGIN
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Intento fallido de modificar el equipo: ' + @Motivo
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Actualizar', N'Catálogos', @ELEMENTO, @DSC, 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT @Codigo
			RETURN
		END

		IF @AntNombre <> @Nombre
			SET @Cambios = @Cambios + N'Nombre: ' + @AntNombre + N' → ' + @Nombre + N'; '
		IF ISNULL(@AntDescripcion,N'') <> ISNULL(@Descripcion,N'')
			SET @Cambios = @Cambios + N'Descripción: ' + ISNULL(@AntDescripcion,N'—') + N' → ' + ISNULL(@Descripcion,N'—') + N'; '
		IF @AntActivo <> @Activo
			SET @Cambios = @Cambios + N'Estado: ' + CASE @AntActivo WHEN 1 THEN N'Activo' ELSE N'Inactivo' END
			             + N' → ' + CASE @Activo WHEN 1 THEN N'Activo' ELSE N'Inactivo' END + N'; '
		IF @Cambios = N'' SET @Cambios = N'Se guardó sin cambios.'

		BEGIN TRANSACTION
			UPDATE EquipoSoporte SET Nombre=@Nombre, Descripcion=@Descripcion, Activo=@Activo
			WHERE EquipoId=@EquipoId AND InstitucionId=@InstitucionId

			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Actualizar', N'Catálogos', @ELEMENTO, @Cambios, 1, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		COMMIT TRANSACTION

		SELECT @EquipoId
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SET @DSC = N'Error al modificar el equipo: ' + ERROR_MESSAGE()
		EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Actualizar', N'Catálogos', @ELEMENTO, @DSC, 0, @DireccionIp
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SELECT 0
	END CATCH
END
GO

USE NaiaInc
GO

-- Desactivar. No se permite si tiene técnicos activos o si una categoría activa lo usa por defecto.
CREATE OR ALTER PROCEDURE SP_ELIMINA_EQUIPOS
(
@InstitucionId    INT,
@EquipoId         INT,
@IdUsuarioGlobal  INT,
@DireccionIp      VARCHAR(45)
)
AS BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @Codigo INT = 0
	DECLARE @Motivo NVARCHAR(300)
	DECLARE @DSC NVARCHAR(MAX)
	DECLARE @ELEMENTO NVARCHAR(150)
	DECLARE @Activo BIT

	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM EquipoSoporte WHERE EquipoId=@EquipoId AND InstitucionId=@InstitucionId)
		BEGIN
			SELECT -2 /*NO SE PUEDE ELIMINAR: EL REGISTRO NO EXISTE*/
			RETURN
		END

		SELECT @ELEMENTO = N'Equipo: ' + Nombre, @Activo = Activo FROM EquipoSoporte WHERE EquipoId=@EquipoId

		IF NOT EXISTS (SELECT 1 FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
		               WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId
		                 AND USR.Activo = 1 AND ROL.PuedeAdministrar = 1)
			SELECT @Codigo = -3, @Motivo = N'No tiene permisos para desactivar equipos.'
		ELSE IF @Activo = 0
			SELECT @Codigo = -6, @Motivo = N'Ya está desactivado.'
		ELSE IF EXISTS (SELECT 1 FROM Usuario WHERE EquipoId=@EquipoId AND Activo=1)
			SELECT @Codigo = -6, @Motivo = N'No se puede desactivar: tiene técnicos activos. Muévalos primero a otro equipo.'
		ELSE IF EXISTS (SELECT 1 FROM Categoria WHERE EquipoPredeterminadoId=@EquipoId AND Activa=1)
			SELECT @Codigo = -6, @Motivo = N'No se puede desactivar: hay categorías activas que lo usan como equipo predeterminado.'

		IF @Codigo < 0
		BEGIN
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Intento fallido de desactivar el equipo: ' + @Motivo
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Desactivar', N'Catálogos', @ELEMENTO, @DSC, 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT @Codigo
			RETURN
		END

		BEGIN TRANSACTION
			UPDATE EquipoSoporte SET Activo = 0 WHERE EquipoId=@EquipoId AND InstitucionId=@InstitucionId

			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Desactivó el equipo. Ya no aparecerá en los formularios.'
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Desactivar', N'Catálogos', @ELEMENTO, @DSC, 1, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		COMMIT TRANSACTION

		SELECT @EquipoId
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SET @DSC = N'Error al desactivar el equipo: ' + ERROR_MESSAGE()
		EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Desactivar', N'Catálogos', @ELEMENTO, @DSC, 0, @DireccionIp
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SELECT 0
	END CATCH
END
GO


/* ================================================================================================
   SECCIÓN 8 · UBICACIONES
   Dónde ocurre el problema del tiquete.
     EsFisica = 1 -> lugar del campus (Edificio obligatorio). Ej. Edificio B · Aula B-204
     EsFisica = 0 -> virtual, sin edificio. Ej. Remoto, Plataforma en línea (3 se crean al registrar la universidad)
   ================================================================================================ */
USE NaiaInc
GO

-- @SoloActivas = 0 para mantenimiento, 1 para el dropdown al crear tiquetes.
-- UbicacionTexto ya viene armado para mostrar: "Edificio B · Aula B-204" o "Remoto (fuera del campus)".
CREATE OR ALTER PROCEDURE SP_LISTAR_UBICACIONES
(
@InstitucionId INT,
@SoloActivas   BIT
)
AS BEGIN
	SELECT UbicacionId, Nombre, Edificio, EsFisica,
	       CASE EsFisica WHEN 1 THEN N'Física' ELSE N'Virtual' END AS TipoTexto,
	       ISNULL(Edificio + N' · ', N'') + Nombre AS UbicacionTexto,
	       Activa,
	       CASE Activa WHEN 1 THEN N'Activa' ELSE N'Inactiva' END AS EstadoTexto
	FROM Ubicacion
	WHERE InstitucionId = @InstitucionId
	  AND (@SoloActivas = 0 OR Activa = 1)
	ORDER BY Activa DESC, EsFisica, Edificio, Nombre
END
GO

USE NaiaInc
GO

CREATE OR ALTER PROCEDURE SP_FILTRAR_UBICACIONES
(
@InstitucionId INT,
@Filtro        NVARCHAR(100)
)
AS BEGIN
	SELECT UbicacionId, Nombre, Edificio, EsFisica,
	       CASE EsFisica WHEN 1 THEN N'Física' ELSE N'Virtual' END AS TipoTexto,
	       ISNULL(Edificio + N' · ', N'') + Nombre AS UbicacionTexto,
	       Activa,
	       CASE Activa WHEN 1 THEN N'Activa' ELSE N'Inactiva' END AS EstadoTexto
	FROM Ubicacion
	WHERE InstitucionId = @InstitucionId
	  AND (Nombre LIKE '%' + @Filtro + '%' OR Edificio LIKE '%' + @Filtro + '%')
	ORDER BY Activa DESC, EsFisica, Edificio, Nombre
END
GO

USE NaiaInc
GO

CREATE OR ALTER PROCEDURE SP_INFO_UBICACION
(
@InstitucionId INT,
@UbicacionId   INT
)
AS BEGIN
	SELECT UbicacionId, Nombre, Edificio, EsFisica, Activa
	FROM Ubicacion
	WHERE UbicacionId = @UbicacionId AND InstitucionId = @InstitucionId
END
GO

USE NaiaInc
GO

CREATE OR ALTER PROCEDURE SP_INSERTA_UBICACIONES
(
@InstitucionId    INT,
@Nombre           NVARCHAR(80),
@Edificio         NVARCHAR(80),      -- obligatorio si @EsFisica = 1; se ignora si @EsFisica = 0
@EsFisica         BIT,
@IdUsuarioGlobal  INT,
@DireccionIp      VARCHAR(45)
)
AS BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @Codigo INT = 0
	DECLARE @Motivo NVARCHAR(300)
	DECLARE @NuevoId INT
	DECLARE @DSC NVARCHAR(MAX)
	DECLARE @ELEMENTO NVARCHAR(150)

	BEGIN TRY
		SET @Nombre = LTRIM(RTRIM(@Nombre))
		SET @Edificio = CASE WHEN @EsFisica = 1 THEN NULLIF(LTRIM(RTRIM(@Edificio)), N'') ELSE NULL END
		SET @ELEMENTO = N'Ubicación: ' + ISNULL(@Edificio + N' · ', N'') + ISNULL(@Nombre,N'')

		IF NOT EXISTS (SELECT 1 FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
		               WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId
		                 AND USR.Activo = 1 AND ROL.PuedeAdministrar = 1)
			SELECT @Codigo = -3, @Motivo = N'No tiene permisos para crear ubicaciones.'
		ELSE IF ISNULL(@Nombre,N'') = N'' OR @EsFisica IS NULL
			SELECT @Codigo = -4, @Motivo = N'El nombre y el tipo de ubicación son obligatorios.'
		ELSE IF @EsFisica = 1 AND @Edificio IS NULL
			SELECT @Codigo = -4, @Motivo = N'Una ubicación física debe indicar el edificio.'
		ELSE IF EXISTS (SELECT 1 FROM Ubicacion WHERE InstitucionId=@InstitucionId AND Nombre=@Nombre
		                AND ISNULL(Edificio,N'') = ISNULL(@Edificio,N''))
			SELECT @Codigo = -1, @Motivo = N'Ya existe esa ubicación.'

		IF @Codigo < 0
		BEGIN
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Intento fallido de crear la ubicación: ' + @Motivo
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Crear', N'Catálogos', @ELEMENTO, @DSC, 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT @Codigo
			RETURN
		END

		BEGIN TRANSACTION
			INSERT INTO Ubicacion (InstitucionId, Nombre, Edificio, EsFisica) VALUES (@InstitucionId, @Nombre, @Edificio, @EsFisica)
			SET @NuevoId = SCOPE_IDENTITY()

			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Creó la ubicación ' + CASE @EsFisica WHEN 1 THEN N'física ' ELSE N'virtual ' END
			         + ISNULL(@Edificio + N' · ', N'') + @Nombre + N'.'
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Crear', N'Catálogos', @ELEMENTO, @DSC, 1, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		COMMIT TRANSACTION

		SELECT @NuevoId
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SET @DSC = N'Error al crear la ubicación: ' + ERROR_MESSAGE()
		EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Crear', N'Catálogos', @ELEMENTO, @DSC, 0, @DireccionIp
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SELECT 0
	END CATCH
END
GO

USE NaiaInc
GO

-- @Activa = 1 reactiva · @Activa = 0 desactiva. Los tiquetes viejos conservan su ubicación.
CREATE OR ALTER PROCEDURE SP_ACTUALIZA_UBICACIONES
(
@InstitucionId    INT,
@UbicacionId      INT,
@Nombre           NVARCHAR(80),
@Edificio         NVARCHAR(80),
@EsFisica         BIT,
@Activa           BIT,
@IdUsuarioGlobal  INT,
@DireccionIp      VARCHAR(45)
)
AS BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @Codigo INT = 0
	DECLARE @Motivo NVARCHAR(300)
	DECLARE @Cambios NVARCHAR(MAX) = N''
	DECLARE @DSC NVARCHAR(MAX)
	DECLARE @ELEMENTO NVARCHAR(150)
	DECLARE @AntNombre NVARCHAR(80), @AntEdificio NVARCHAR(80), @AntEsFisica BIT, @AntActiva BIT

	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM Ubicacion WHERE UbicacionId=@UbicacionId AND InstitucionId=@InstitucionId)
		BEGIN
			SELECT -2 /*NO SE PUEDE ACTUALIZAR: EL REGISTRO NO EXISTE*/
			RETURN
		END

		SET @Nombre = LTRIM(RTRIM(@Nombre))
		SET @Edificio = CASE WHEN @EsFisica = 1 THEN NULLIF(LTRIM(RTRIM(@Edificio)), N'') ELSE NULL END
		SELECT @AntNombre=Nombre, @AntEdificio=Edificio, @AntEsFisica=EsFisica, @AntActiva=Activa
		FROM Ubicacion WHERE UbicacionId=@UbicacionId
		SET @ELEMENTO = N'Ubicación: ' + ISNULL(@AntEdificio + N' · ', N'') + @AntNombre

		IF NOT EXISTS (SELECT 1 FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
		               WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId
		                 AND USR.Activo = 1 AND ROL.PuedeAdministrar = 1)
			SELECT @Codigo = -3, @Motivo = N'No tiene permisos para modificar ubicaciones.'
		ELSE IF ISNULL(@Nombre,N'') = N'' OR @EsFisica IS NULL
			SELECT @Codigo = -4, @Motivo = N'El nombre y el tipo de ubicación son obligatorios.'
		ELSE IF @EsFisica = 1 AND @Edificio IS NULL
			SELECT @Codigo = -4, @Motivo = N'Una ubicación física debe indicar el edificio.'
		ELSE IF EXISTS (SELECT 1 FROM Ubicacion WHERE InstitucionId=@InstitucionId AND Nombre=@Nombre
		                AND ISNULL(Edificio,N'') = ISNULL(@Edificio,N'') AND UbicacionId<>@UbicacionId)
			SELECT @Codigo = -1, @Motivo = N'Ya existe esa ubicación.'

		IF @Codigo < 0
		BEGIN
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Intento fallido de modificar la ubicación: ' + @Motivo
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Actualizar', N'Catálogos', @ELEMENTO, @DSC, 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT @Codigo
			RETURN
		END

		IF @AntNombre <> @Nombre
			SET @Cambios = @Cambios + N'Nombre: ' + @AntNombre + N' → ' + @Nombre + N'; '
		IF ISNULL(@AntEdificio,N'') <> ISNULL(@Edificio,N'')
			SET @Cambios = @Cambios + N'Edificio: ' + ISNULL(@AntEdificio,N'—') + N' → ' + ISNULL(@Edificio,N'—') + N'; '
		IF @AntEsFisica <> @EsFisica
			SET @Cambios = @Cambios + N'Tipo: ' + CASE @AntEsFisica WHEN 1 THEN N'Física' ELSE N'Virtual' END
			             + N' → ' + CASE @EsFisica WHEN 1 THEN N'Física' ELSE N'Virtual' END + N'; '
		IF @AntActiva <> @Activa
			SET @Cambios = @Cambios + N'Estado: ' + CASE @AntActiva WHEN 1 THEN N'Activa' ELSE N'Inactiva' END
			             + N' → ' + CASE @Activa WHEN 1 THEN N'Activa' ELSE N'Inactiva' END + N'; '
		IF @Cambios = N'' SET @Cambios = N'Se guardó sin cambios.'

		BEGIN TRANSACTION
			UPDATE Ubicacion SET Nombre=@Nombre, Edificio=@Edificio, EsFisica=@EsFisica, Activa=@Activa
			WHERE UbicacionId=@UbicacionId AND InstitucionId=@InstitucionId

			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Actualizar', N'Catálogos', @ELEMENTO, @Cambios, 1, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		COMMIT TRANSACTION

		SELECT @UbicacionId
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SET @DSC = N'Error al modificar la ubicación: ' + ERROR_MESSAGE()
		EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Actualizar', N'Catálogos', @ELEMENTO, @DSC, 0, @DireccionIp
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SELECT 0
	END CATCH
END
GO

USE NaiaInc
GO

-- Desactivar. Deja de salir al crear tiquetes; los tiquetes que ya la usan no cambian.
CREATE OR ALTER PROCEDURE SP_ELIMINA_UBICACIONES
(
@InstitucionId    INT,
@UbicacionId      INT,
@IdUsuarioGlobal  INT,
@DireccionIp      VARCHAR(45)
)
AS BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @Codigo INT = 0
	DECLARE @Motivo NVARCHAR(300)
	DECLARE @DSC NVARCHAR(MAX)
	DECLARE @ELEMENTO NVARCHAR(150)
	DECLARE @Activa BIT

	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM Ubicacion WHERE UbicacionId=@UbicacionId AND InstitucionId=@InstitucionId)
		BEGIN
			SELECT -2 /*NO SE PUEDE ELIMINAR: EL REGISTRO NO EXISTE*/
			RETURN
		END

		SELECT @ELEMENTO = N'Ubicación: ' + ISNULL(Edificio + N' · ', N'') + Nombre, @Activa = Activa
		FROM Ubicacion WHERE UbicacionId=@UbicacionId

		IF NOT EXISTS (SELECT 1 FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
		               WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId
		                 AND USR.Activo = 1 AND ROL.PuedeAdministrar = 1)
			SELECT @Codigo = -3, @Motivo = N'No tiene permisos para desactivar ubicaciones.'
		ELSE IF @Activa = 0
			SELECT @Codigo = -6, @Motivo = N'Ya está desactivada.'

		IF @Codigo < 0
		BEGIN
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Intento fallido de desactivar la ubicación: ' + @Motivo
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Desactivar', N'Catálogos', @ELEMENTO, @DSC, 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT @Codigo
			RETURN
		END

		BEGIN TRANSACTION
			UPDATE Ubicacion SET Activa = 0 WHERE UbicacionId=@UbicacionId AND InstitucionId=@InstitucionId

			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Desactivó la ubicación. Ya no aparecerá al crear tiquetes.'
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Desactivar', N'Catálogos', @ELEMENTO, @DSC, 1, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		COMMIT TRANSACTION

		SELECT @UbicacionId
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SET @DSC = N'Error al desactivar la ubicación: ' + ERROR_MESSAGE()
		EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Desactivar', N'Catálogos', @ELEMENTO, @DSC, 0, @DireccionIp
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SELECT 0
	END CATCH
END
GO


/* ================================================================================================
   SECCIÓN 9 · CATEGORÍAS DE TIQUETE
   Ej. "Red e Internet", "Laboratorios", "Audiovisual".
     PrioridadInicialId      -> prioridad que recibe el tiquete al crearse (1 Crítica … 4 Baja)
     EquipoPredeterminadoId  -> equipo que normalmente lo atiende (opcional; ayuda a elegir técnico)
     RequiereUbicacionFisica -> 1 = al crear el tiquete se obliga a elegir una ubicación física
     ColorHex                -> color de la etiqueta, ej. '#3C4F76'
   ================================================================================================ */
USE NaiaInc
GO

-- @SoloActivas = 0 para mantenimiento, 1 para el dropdown al crear tiquetes.
CREATE OR ALTER PROCEDURE SP_LISTAR_CATEGORIAS
(
@InstitucionId INT,
@SoloActivas   BIT
)
AS BEGIN
	SELECT CAT.CategoriaId, CAT.Nombre AS Categoria, CAT.Descripcion, CAT.ColorHex,
	       CAT.PrioridadInicialId, PRI.Nombre AS PrioridadInicial, PRI.ColorHex AS PrioridadColor,
	       CAT.EquipoPredeterminadoId, EQU.Nombre AS EquipoPredeterminado,
	       CAT.RequiereUbicacionFisica, CAT.Activa,
	       CASE CAT.Activa WHEN 1 THEN N'Activa' ELSE N'Inactiva' END AS EstadoTexto
	FROM Categoria CAT
	INNER JOIN Prioridad PRI    ON PRI.PrioridadId = CAT.PrioridadInicialId
	LEFT JOIN EquipoSoporte EQU ON EQU.EquipoId = CAT.EquipoPredeterminadoId
	WHERE CAT.InstitucionId = @InstitucionId
	  AND (@SoloActivas = 0 OR CAT.Activa = 1)
	ORDER BY CAT.Activa DESC, CAT.Nombre
END
GO

USE NaiaInc
GO

CREATE OR ALTER PROCEDURE SP_FILTRAR_CATEGORIAS
(
@InstitucionId INT,
@Filtro        NVARCHAR(100)
)
AS BEGIN
	SELECT CAT.CategoriaId, CAT.Nombre AS Categoria, CAT.Descripcion, CAT.ColorHex,
	       CAT.PrioridadInicialId, PRI.Nombre AS PrioridadInicial, PRI.ColorHex AS PrioridadColor,
	       CAT.EquipoPredeterminadoId, EQU.Nombre AS EquipoPredeterminado,
	       CAT.RequiereUbicacionFisica, CAT.Activa,
	       CASE CAT.Activa WHEN 1 THEN N'Activa' ELSE N'Inactiva' END AS EstadoTexto
	FROM Categoria CAT
	INNER JOIN Prioridad PRI    ON PRI.PrioridadId = CAT.PrioridadInicialId
	LEFT JOIN EquipoSoporte EQU ON EQU.EquipoId = CAT.EquipoPredeterminadoId
	WHERE CAT.InstitucionId = @InstitucionId
	  AND (CAT.Nombre LIKE '%' + @Filtro + '%' OR CAT.Descripcion LIKE '%' + @Filtro + '%')
	ORDER BY CAT.Activa DESC, CAT.Nombre
END
GO

USE NaiaInc
GO

CREATE OR ALTER PROCEDURE SP_INFO_CATEGORIA
(
@InstitucionId INT,
@CategoriaId   INT
)
AS BEGIN
	SELECT CategoriaId, Nombre AS Categoria, Descripcion, ColorHex, PrioridadInicialId,
	       EquipoPredeterminadoId, RequiereUbicacionFisica, Activa
	FROM Categoria
	WHERE CategoriaId = @CategoriaId AND InstitucionId = @InstitucionId
END
GO

USE NaiaInc
GO

CREATE OR ALTER PROCEDURE SP_INSERTA_CATEGORIAS
(
@InstitucionId            INT,
@Nombre                   NVARCHAR(80),
@Descripcion              NVARCHAR(250),   -- puede ser NULL
@ColorHex                 CHAR(7),         -- ej. '#3C4F76'
@PrioridadInicialId       TINYINT,         -- 1 Crítica · 2 Alta · 3 Media · 4 Baja
@EquipoPredeterminadoId   INT,             -- puede ser NULL
@RequiereUbicacionFisica  BIT,
@IdUsuarioGlobal          INT,
@DireccionIp              VARCHAR(45)
)
AS BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @Codigo INT = 0
	DECLARE @Motivo NVARCHAR(300)
	DECLARE @NuevoId INT
	DECLARE @DSC NVARCHAR(MAX)
	DECLARE @ELEMENTO NVARCHAR(150)

	BEGIN TRY
		SET @Nombre = LTRIM(RTRIM(@Nombre))
		SET @Descripcion = NULLIF(LTRIM(RTRIM(@Descripcion)), N'')
		SET @ColorHex = UPPER(LTRIM(RTRIM(@ColorHex)))
		SET @ELEMENTO = N'Categoría: ' + ISNULL(@Nombre,N'')

		IF NOT EXISTS (SELECT 1 FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
		               WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId
		                 AND USR.Activo = 1 AND ROL.PuedeAdministrar = 1)
			SELECT @Codigo = -3, @Motivo = N'No tiene permisos para crear categorías.'
		ELSE IF ISNULL(@Nombre,N'') = N''
			SELECT @Codigo = -4, @Motivo = N'El nombre es obligatorio.'
		ELSE IF ISNULL(@ColorHex,'') NOT LIKE '#[0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F]'
			SELECT @Codigo = -4, @Motivo = N'El color no es válido (formato #RRGGBB).'
		ELSE IF NOT EXISTS (SELECT 1 FROM Prioridad WHERE PrioridadId=@PrioridadInicialId)
			SELECT @Codigo = -4, @Motivo = N'La prioridad no es válida.'
		ELSE IF @EquipoPredeterminadoId IS NOT NULL
		     AND NOT EXISTS (SELECT 1 FROM EquipoSoporte WHERE EquipoId=@EquipoPredeterminadoId AND InstitucionId=@InstitucionId AND Activo=1)
			SELECT @Codigo = -4, @Motivo = N'El equipo de soporte no es válido.'
		ELSE IF EXISTS (SELECT 1 FROM Categoria WHERE InstitucionId=@InstitucionId AND Nombre=@Nombre)
			SELECT @Codigo = -1, @Motivo = N'Ya existe una categoría con ese nombre.'

		IF @Codigo < 0
		BEGIN
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Intento fallido de crear la categoría: ' + @Motivo
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Crear', N'Catálogos', @ELEMENTO, @DSC, 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT @Codigo
			RETURN
		END

		BEGIN TRANSACTION
			INSERT INTO Categoria (InstitucionId, Nombre, Descripcion, ColorHex, PrioridadInicialId, EquipoPredeterminadoId, RequiereUbicacionFisica)
			VALUES (@InstitucionId, @Nombre, @Descripcion, @ColorHex, @PrioridadInicialId, @EquipoPredeterminadoId, ISNULL(@RequiereUbicacionFisica,0))
			SET @NuevoId = SCOPE_IDENTITY()

			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Creó la categoría con prioridad inicial ' + (SELECT Nombre FROM Prioridad WHERE PrioridadId=@PrioridadInicialId)
			         + ISNULL(N' y equipo predeterminado ' + (SELECT Nombre FROM EquipoSoporte WHERE EquipoId=@EquipoPredeterminadoId), N'') + N'.'
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Crear', N'Catálogos', @ELEMENTO, @DSC, 1, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		COMMIT TRANSACTION

		SELECT @NuevoId
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SET @DSC = N'Error al crear la categoría: ' + ERROR_MESSAGE()
		EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Crear', N'Catálogos', @ELEMENTO, @DSC, 0, @DireccionIp
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SELECT 0
	END CATCH
END
GO

USE NaiaInc
GO

-- @Activa = 1 reactiva · @Activa = 0 desactiva. Los cambios NO afectan a los tiquetes ya creados.
CREATE OR ALTER PROCEDURE SP_ACTUALIZA_CATEGORIAS
(
@InstitucionId            INT,
@CategoriaId              INT,
@Nombre                   NVARCHAR(80),
@Descripcion              NVARCHAR(250),
@ColorHex                 CHAR(7),
@PrioridadInicialId       TINYINT,
@EquipoPredeterminadoId   INT,
@RequiereUbicacionFisica  BIT,
@Activa                   BIT,
@IdUsuarioGlobal          INT,
@DireccionIp              VARCHAR(45)
)
AS BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @Codigo INT = 0
	DECLARE @Motivo NVARCHAR(300)
	DECLARE @Cambios NVARCHAR(MAX) = N''
	DECLARE @DSC NVARCHAR(MAX)
	DECLARE @ELEMENTO NVARCHAR(150)
	DECLARE @AntNombre NVARCHAR(80), @AntDescripcion NVARCHAR(250), @AntColor CHAR(7)
	DECLARE @AntPrioridadId TINYINT, @AntPrioridad NVARCHAR(30)
	DECLARE @AntEquipoId INT, @AntEquipo NVARCHAR(80)
	DECLARE @AntRequiere BIT, @AntActiva BIT

	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM Categoria WHERE CategoriaId=@CategoriaId AND InstitucionId=@InstitucionId)
		BEGIN
			SELECT -2 /*NO SE PUEDE ACTUALIZAR: EL REGISTRO NO EXISTE*/
			RETURN
		END

		SET @Nombre = LTRIM(RTRIM(@Nombre))
		SET @Descripcion = NULLIF(LTRIM(RTRIM(@Descripcion)), N'')
		SET @ColorHex = UPPER(LTRIM(RTRIM(@ColorHex)))
		SET @RequiereUbicacionFisica = ISNULL(@RequiereUbicacionFisica, 0)

		SELECT @AntNombre=CAT.Nombre, @AntDescripcion=CAT.Descripcion, @AntColor=CAT.ColorHex,
		       @AntPrioridadId=CAT.PrioridadInicialId, @AntPrioridad=PRI.Nombre,
		       @AntEquipoId=CAT.EquipoPredeterminadoId, @AntEquipo=EQU.Nombre,
		       @AntRequiere=CAT.RequiereUbicacionFisica, @AntActiva=CAT.Activa
		FROM Categoria CAT
		INNER JOIN Prioridad PRI    ON PRI.PrioridadId = CAT.PrioridadInicialId
		LEFT JOIN EquipoSoporte EQU ON EQU.EquipoId = CAT.EquipoPredeterminadoId
		WHERE CAT.CategoriaId=@CategoriaId

		SET @ELEMENTO = N'Categoría: ' + @AntNombre

		IF NOT EXISTS (SELECT 1 FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
		               WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId
		                 AND USR.Activo = 1 AND ROL.PuedeAdministrar = 1)
			SELECT @Codigo = -3, @Motivo = N'No tiene permisos para modificar categorías.'
		ELSE IF ISNULL(@Nombre,N'') = N''
			SELECT @Codigo = -4, @Motivo = N'El nombre es obligatorio.'
		ELSE IF ISNULL(@ColorHex,'') NOT LIKE '#[0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F]'
			SELECT @Codigo = -4, @Motivo = N'El color no es válido (formato #RRGGBB).'
		ELSE IF NOT EXISTS (SELECT 1 FROM Prioridad WHERE PrioridadId=@PrioridadInicialId)
			SELECT @Codigo = -4, @Motivo = N'La prioridad no es válida.'
		ELSE IF @EquipoPredeterminadoId IS NOT NULL AND ISNULL(@AntEquipoId,-1) <> @EquipoPredeterminadoId
		     AND NOT EXISTS (SELECT 1 FROM EquipoSoporte WHERE EquipoId=@EquipoPredeterminadoId AND InstitucionId=@InstitucionId AND Activo=1)
			SELECT @Codigo = -4, @Motivo = N'El equipo de soporte no es válido.'
		ELSE IF EXISTS (SELECT 1 FROM Categoria WHERE InstitucionId=@InstitucionId AND Nombre=@Nombre AND CategoriaId<>@CategoriaId)
			SELECT @Codigo = -1, @Motivo = N'Ya existe una categoría con ese nombre.'

		IF @Codigo < 0
		BEGIN
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Intento fallido de modificar la categoría: ' + @Motivo
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Actualizar', N'Catálogos', @ELEMENTO, @DSC, 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT @Codigo
			RETURN
		END

		IF @AntNombre <> @Nombre
			SET @Cambios = @Cambios + N'Nombre: ' + @AntNombre + N' → ' + @Nombre + N'; '
		IF ISNULL(@AntDescripcion,N'') <> ISNULL(@Descripcion,N'')
			SET @Cambios = @Cambios + N'Descripción: ' + ISNULL(@AntDescripcion,N'—') + N' → ' + ISNULL(@Descripcion,N'—') + N'; '
		IF @AntColor <> @ColorHex
			SET @Cambios = @Cambios + N'Color: ' + @AntColor + N' → ' + @ColorHex + N'; '
		IF @AntPrioridadId <> @PrioridadInicialId
			SET @Cambios = @Cambios + N'Prioridad inicial: ' + @AntPrioridad + N' → ' + (SELECT Nombre FROM Prioridad WHERE PrioridadId=@PrioridadInicialId) + N'; '
		IF ISNULL(@AntEquipoId,-1) <> ISNULL(@EquipoPredeterminadoId,-1)
			SET @Cambios = @Cambios + N'Equipo predeterminado: ' + ISNULL(@AntEquipo,N'—') + N' → '
			             + ISNULL((SELECT Nombre FROM EquipoSoporte WHERE EquipoId=@EquipoPredeterminadoId),N'—') + N'; '
		IF @AntRequiere <> @RequiereUbicacionFisica
			SET @Cambios = @Cambios + N'Requiere ubicación física: ' + CASE @AntRequiere WHEN 1 THEN N'Sí' ELSE N'No' END
			             + N' → ' + CASE @RequiereUbicacionFisica WHEN 1 THEN N'Sí' ELSE N'No' END + N'; '
		IF @AntActiva <> @Activa
			SET @Cambios = @Cambios + N'Estado: ' + CASE @AntActiva WHEN 1 THEN N'Activa' ELSE N'Inactiva' END
			             + N' → ' + CASE @Activa WHEN 1 THEN N'Activa' ELSE N'Inactiva' END + N'; '
		IF @Cambios = N'' SET @Cambios = N'Se guardó sin cambios.'

		BEGIN TRANSACTION
			UPDATE Categoria
			SET Nombre=@Nombre, Descripcion=@Descripcion, ColorHex=@ColorHex, PrioridadInicialId=@PrioridadInicialId,
			    EquipoPredeterminadoId=@EquipoPredeterminadoId, RequiereUbicacionFisica=@RequiereUbicacionFisica, Activa=@Activa
			WHERE CategoriaId=@CategoriaId AND InstitucionId=@InstitucionId

			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Actualizar', N'Catálogos', @ELEMENTO, @Cambios, 1, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		COMMIT TRANSACTION

		SELECT @CategoriaId
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SET @DSC = N'Error al modificar la categoría: ' + ERROR_MESSAGE()
		EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Actualizar', N'Catálogos', @ELEMENTO, @DSC, 0, @DireccionIp
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SELECT 0
	END CATCH
END
GO

USE NaiaInc
GO

-- Desactivar. Deja de salir al crear tiquetes; los tiquetes que ya la usan no cambian.
CREATE OR ALTER PROCEDURE SP_ELIMINA_CATEGORIAS
(
@InstitucionId    INT,
@CategoriaId      INT,
@IdUsuarioGlobal  INT,
@DireccionIp      VARCHAR(45)
)
AS BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @Codigo INT = 0
	DECLARE @Motivo NVARCHAR(300)
	DECLARE @DSC NVARCHAR(MAX)
	DECLARE @ELEMENTO NVARCHAR(150)
	DECLARE @Activa BIT

	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM Categoria WHERE CategoriaId=@CategoriaId AND InstitucionId=@InstitucionId)
		BEGIN
			SELECT -2 /*NO SE PUEDE ELIMINAR: EL REGISTRO NO EXISTE*/
			RETURN
		END

		SELECT @ELEMENTO = N'Categoría: ' + Nombre, @Activa = Activa FROM Categoria WHERE CategoriaId=@CategoriaId

		IF NOT EXISTS (SELECT 1 FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
		               WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId
		                 AND USR.Activo = 1 AND ROL.PuedeAdministrar = 1)
			SELECT @Codigo = -3, @Motivo = N'No tiene permisos para desactivar categorías.'
		ELSE IF @Activa = 0
			SELECT @Codigo = -6, @Motivo = N'Ya está desactivada.'

		IF @Codigo < 0
		BEGIN
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Intento fallido de desactivar la categoría: ' + @Motivo
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Desactivar', N'Catálogos', @ELEMENTO, @DSC, 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT @Codigo
			RETURN
		END

		BEGIN TRANSACTION
			UPDATE Categoria SET Activa = 0 WHERE CategoriaId=@CategoriaId AND InstitucionId=@InstitucionId

			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Desactivó la categoría. Ya no aparecerá al crear tiquetes.'
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Desactivar', N'Catálogos', @ELEMENTO, @DSC, 1, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		COMMIT TRANSACTION

		SELECT @CategoriaId
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SET @DSC = N'Error al desactivar la categoría: ' + ERROR_MESSAGE()
		EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Desactivar', N'Catálogos', @ELEMENTO, @DSC, 0, @DireccionIp
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SELECT 0
	END CATCH
END
GO


/* ================================================================================================
   SECCIÓN 10 · USUARIOS
   Los crea el administrador (no hay autorregistro). Reglas que valida la base:
     - El correo debe terminar en el dominio de la universidad (ej. @uam.ac.cr)
     - Estudiante/Profesor -> CarreraId obligatorio · Soporte/Administrativo -> DepartamentoId obligatorio
     - Solo Soporte técnico (RolId 3) puede tener EquipoId
     - No se puede pasar el límite de usuarios del plan
     - Siempre debe quedar al menos un administrador activo
   ================================================================================================ */
USE NaiaInc
GO

CREATE OR ALTER PROCEDURE SP_LISTAR_USUARIOS
(
@InstitucionId INT
)
AS BEGIN
	SELECT USR.UsuarioId, USR.RolId, ROL.Nombre AS Rol, ROL.TipoNumeroInterno,
	       USR.CarreraId, CAR.Nombre AS Carrera,
	       USR.DepartamentoId, DEP.Nombre AS Departamento,
	       USR.EquipoId, EQU.Nombre AS Equipo,
	       USR.TipoIdentificacionId, TID.Nombre AS TipoIdentificacion, USR.Identificacion,
	       USR.NumeroInterno, USR.Nombre, USR.Apellidos,
	       USR.Nombre + ' ' + USR.Apellidos AS NombreCompleto,
	       USR.Correo, USR.Activo, USR.FechaCreacion, USR.UltimoAcceso
	FROM Usuario USR
	INNER JOIN Rol ROL                ON ROL.RolId = USR.RolId
	INNER JOIN TipoIdentificacion TID ON TID.TipoIdentificacionId = USR.TipoIdentificacionId
	LEFT JOIN Carrera CAR             ON CAR.CarreraId = USR.CarreraId
	LEFT JOIN Departamento DEP        ON DEP.DepartamentoId = USR.DepartamentoId
	LEFT JOIN EquipoSoporte EQU       ON EQU.EquipoId = USR.EquipoId
	WHERE USR.InstitucionId = @InstitucionId
	ORDER BY USR.Activo DESC, USR.Nombre, USR.Apellidos
END
GO

USE NaiaInc
GO

CREATE OR ALTER PROCEDURE SP_FILTRAR_USUARIOS
(
@InstitucionId INT,
@Filtro        NVARCHAR(100)   -- nombre, apellidos, correo, identificación o número interno
)
AS BEGIN
	SELECT USR.UsuarioId, USR.RolId, ROL.Nombre AS Rol, ROL.TipoNumeroInterno,
	       USR.CarreraId, CAR.Nombre AS Carrera,
	       USR.DepartamentoId, DEP.Nombre AS Departamento,
	       USR.EquipoId, EQU.Nombre AS Equipo,
	       USR.TipoIdentificacionId, TID.Nombre AS TipoIdentificacion, USR.Identificacion,
	       USR.NumeroInterno, USR.Nombre, USR.Apellidos,
	       USR.Nombre + ' ' + USR.Apellidos AS NombreCompleto,
	       USR.Correo, USR.Activo, USR.FechaCreacion, USR.UltimoAcceso
	FROM Usuario USR
	INNER JOIN Rol ROL                ON ROL.RolId = USR.RolId
	INNER JOIN TipoIdentificacion TID ON TID.TipoIdentificacionId = USR.TipoIdentificacionId
	LEFT JOIN Carrera CAR             ON CAR.CarreraId = USR.CarreraId
	LEFT JOIN Departamento DEP        ON DEP.DepartamentoId = USR.DepartamentoId
	LEFT JOIN EquipoSoporte EQU       ON EQU.EquipoId = USR.EquipoId
	WHERE USR.InstitucionId = @InstitucionId
	  AND (USR.Nombre         LIKE '%' + @Filtro + '%'
	    OR USR.Apellidos      LIKE '%' + @Filtro + '%'
	    OR USR.Correo         LIKE '%' + @Filtro + '%'
	    OR USR.Identificacion LIKE '%' + @Filtro + '%'
	    OR USR.NumeroInterno  LIKE '%' + @Filtro + '%')
	ORDER BY USR.Activo DESC, USR.Nombre, USR.Apellidos
END
GO

USE NaiaInc
GO

-- Datos de un solo usuario (para cargar el formulario de edición). No devuelve la contraseña.
CREATE OR ALTER PROCEDURE SP_INFO_USUARIO
(
@InstitucionId INT,
@UsuarioId     INT
)
AS BEGIN
	SELECT USR.UsuarioId, USR.RolId, ROL.Nombre AS Rol, ROL.TipoNumeroInterno,
	       USR.CarreraId, USR.DepartamentoId, USR.EquipoId,
	       USR.TipoIdentificacionId, USR.Identificacion, USR.NumeroInterno,
	       USR.Nombre, USR.Apellidos, USR.Correo, USR.Activo,
	       USR.FechaCreacion, USR.UltimoAcceso
	FROM Usuario USR
	INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
	WHERE USR.UsuarioId = @UsuarioId AND USR.InstitucionId = @InstitucionId
END
GO

USE NaiaInc
GO

CREATE OR ALTER PROCEDURE SP_INSERTA_USUARIOS
(
@InstitucionId         INT,
@RolId                 TINYINT,
@CarreraId             INT,            -- Estudiante y Profesor (NULL en los demás)
@DepartamentoId        INT,            -- Soporte técnico y Administrativo (NULL en los demás)
@EquipoId              INT,            -- solo Soporte técnico (puede ser NULL)
@TipoIdentificacionId  TINYINT,
@Identificacion        VARCHAR(30),
@NumeroInterno         VARCHAR(30),
@Nombre                NVARCHAR(60),
@Apellidos             NVARCHAR(80),
@Correo                VARCHAR(150),
@Contrasena            VARCHAR(256),
@IdUsuarioGlobal       INT,            -- administrador que realiza la acción
@DireccionIp           VARCHAR(45)
)
AS BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @Codigo INT = 0
	DECLARE @Motivo NVARCHAR(300)
	DECLARE @NuevoId INT
	DECLARE @MaxUsuarios INT
	DECLARE @UsuariosActivos INT
	DECLARE @DSC NVARCHAR(500)
	DECLARE @ELEMENTO NVARCHAR(150) = @Nombre + N' ' + @Apellidos + N' (' + @NumeroInterno + N')'

	BEGIN TRY
		SET @Correo = LOWER(LTRIM(RTRIM(@Correo)))

		---------------------------------------- VALIDACIONES ----------------------------------------
		IF NOT EXISTS (SELECT 1 FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
		               WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId
		                 AND USR.Activo = 1 AND ROL.PuedeAdministrar = 1)
			SELECT @Codigo = -3, @Motivo = N'No tiene permisos para crear usuarios.'

		ELSE IF LTRIM(RTRIM(ISNULL(@Nombre,'')))='' OR LTRIM(RTRIM(ISNULL(@Apellidos,'')))=''
		     OR LTRIM(RTRIM(ISNULL(@Identificacion,'')))='' OR LTRIM(RTRIM(ISNULL(@NumeroInterno,'')))=''
		     OR LTRIM(RTRIM(ISNULL(@Correo,'')))='' OR ISNULL(@Contrasena,'')=''
			SELECT @Codigo = -4, @Motivo = N'Hay campos obligatorios vacíos.'

		ELSE IF NOT EXISTS (SELECT 1 FROM Rol WHERE RolId=@RolId)
			SELECT @Codigo = -4, @Motivo = N'El rol no es válido.'

		ELSE IF NOT EXISTS (SELECT 1 FROM TipoIdentificacion WHERE TipoIdentificacionId=@TipoIdentificacionId)
			SELECT @Codigo = -4, @Motivo = N'El tipo de identificación no es válido.'

		ELSE IF (@RolId IN (1,2) AND (@CarreraId IS NULL OR @DepartamentoId IS NOT NULL))
		     OR (@RolId IN (3,4) AND (@DepartamentoId IS NULL OR @CarreraId IS NOT NULL))
			SELECT @Codigo = -4, @Motivo = N'Estudiante y Profesor llevan carrera; Soporte técnico y Administrativo llevan departamento.'

		ELSE IF @RolId <> 3 AND @EquipoId IS NOT NULL
			SELECT @Codigo = -4, @Motivo = N'Solo el rol Soporte técnico puede pertenecer a un equipo.'

		ELSE IF NOT EXISTS (SELECT 1 FROM Institucion WHERE InstitucionId = @InstitucionId AND @Correo LIKE '%@' + DominioCorreo)
			SELECT @Codigo = -4, @Motivo = N'El correo no pertenece al dominio de la universidad.'

		ELSE IF @CarreraId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Carrera WHERE CarreraId=@CarreraId AND InstitucionId=@InstitucionId AND Activo=1)
			SELECT @Codigo = -4, @Motivo = N'La carrera no es válida.'

		ELSE IF @DepartamentoId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Departamento WHERE DepartamentoId=@DepartamentoId AND InstitucionId=@InstitucionId AND Activo=1)
			SELECT @Codigo = -4, @Motivo = N'El departamento no es válido.'

		ELSE IF @EquipoId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM EquipoSoporte WHERE EquipoId=@EquipoId AND InstitucionId=@InstitucionId AND Activo=1)
			SELECT @Codigo = -4, @Motivo = N'El equipo de soporte no es válido.'

		ELSE IF EXISTS (SELECT 1 FROM Usuario WHERE Correo = @Correo)
			SELECT @Codigo = -1, @Motivo = N'Ya existe un usuario con ese correo.'

		ELSE IF EXISTS (SELECT 1 FROM Usuario WHERE InstitucionId=@InstitucionId AND TipoIdentificacionId=@TipoIdentificacionId AND Identificacion=@Identificacion)
			SELECT @Codigo = -1, @Motivo = N'Ya existe un usuario con esa identificación.'

		ELSE IF EXISTS (SELECT 1 FROM Usuario WHERE InstitucionId=@InstitucionId AND NumeroInterno=@NumeroInterno)
			SELECT @Codigo = -1, @Motivo = N'Ya existe un usuario con ese carné o número de empleado.'

		ELSE
		BEGIN
			SELECT @MaxUsuarios = PLA.MaxUsuarios
			FROM Institucion INS INNER JOIN PlanSuscripcion PLA ON PLA.PlanId = INS.PlanId
			WHERE INS.InstitucionId = @InstitucionId

			SELECT @UsuariosActivos = COUNT(*) FROM Usuario WHERE InstitucionId=@InstitucionId AND Activo=1

			IF @MaxUsuarios IS NOT NULL AND @UsuariosActivos >= @MaxUsuarios
				SELECT @Codigo = -5, @Motivo = N'Se alcanzó el límite de usuarios del plan.'
		END

		---------------------------------------- SI NO PASA LAS VALIDACIONES ----------------------------------------
		IF @Codigo < 0
		BEGIN
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Intento fallido de crear el usuario: ' + @Motivo
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Crear', N'Usuarios', @ELEMENTO, @DSC, 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT @Codigo
			RETURN
		END

		---------------------------------------- INSERCION ----------------------------------------
		BEGIN TRANSACTION

			INSERT INTO Usuario
			(
			InstitucionId, RolId, CarreraId, DepartamentoId, EquipoId, TipoIdentificacionId,
			Identificacion, NumeroInterno, Nombre, Apellidos, Correo, Contrasena
			)
			VALUES
			(
			@InstitucionId, @RolId, @CarreraId, @DepartamentoId, @EquipoId, @TipoIdentificacionId,
			@Identificacion, @NumeroInterno, @Nombre, @Apellidos, @Correo, @Contrasena
			)

			SET @NuevoId = SCOPE_IDENTITY()

			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Creó el usuario con rol ' + (SELECT Nombre FROM Rol WHERE RolId=@RolId) + N' y correo ' + @Correo
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Crear', N'Usuarios', @ELEMENTO, @DSC, 1, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------

		COMMIT TRANSACTION

		SELECT @NuevoId
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION

		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SET @DSC = N'Error al crear el usuario: ' + ERROR_MESSAGE()
		EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Crear', N'Usuarios', @ELEMENTO, @DSC, 0, @DireccionIp
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------

		SELECT 0
	END CATCH
END
GO

USE NaiaInc
GO

-- @Contrasena = NULL -> se mantiene la contraseña actual
-- @Activo permite reactivar (0 -> 1) o desactivar (1 -> 0) desde el formulario de edición
CREATE OR ALTER PROCEDURE SP_ACTUALIZA_USUARIOS
(
@InstitucionId         INT,
@UsuarioId             INT,
@RolId                 TINYINT,
@CarreraId             INT,
@DepartamentoId        INT,
@EquipoId              INT,
@TipoIdentificacionId  TINYINT,
@Identificacion        VARCHAR(30),
@NumeroInterno         VARCHAR(30),
@Nombre                NVARCHAR(60),
@Apellidos             NVARCHAR(80),
@Correo                VARCHAR(150),
@Contrasena            VARCHAR(256),
@Activo                BIT,
@IdUsuarioGlobal       INT,
@DireccionIp           VARCHAR(45)
)
AS BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @Codigo INT = 0
	DECLARE @Motivo NVARCHAR(300)
	DECLARE @MaxUsuarios INT
	DECLARE @UsuariosActivos INT
	DECLARE @Cambios NVARCHAR(MAX) = N''
	DECLARE @DSC NVARCHAR(500)
	DECLARE @ELEMENTO NVARCHAR(150) = @Nombre + N' ' + @Apellidos + N' (' + @NumeroInterno + N')'

	-- Valores anteriores (para la auditoría)
	DECLARE @AntRolId TINYINT, @AntRol NVARCHAR(30)
	DECLARE @AntCarreraId INT, @AntCarrera NVARCHAR(100)
	DECLARE @AntDepartamentoId INT, @AntDepartamento NVARCHAR(100)
	DECLARE @AntEquipoId INT, @AntEquipo NVARCHAR(80)
	DECLARE @AntTipoIdentificacionId TINYINT, @AntTipoIdentificacion NVARCHAR(40)
	DECLARE @AntIdentificacion VARCHAR(30), @AntNumeroInterno VARCHAR(30)
	DECLARE @AntNombre NVARCHAR(60), @AntApellidos NVARCHAR(80), @AntCorreo VARCHAR(150)
	DECLARE @AntActivo BIT

	BEGIN TRY
		-- Validamos primero que el registro exista antes de intentar actualizarlo
		IF NOT EXISTS (SELECT 1 FROM Usuario WHERE UsuarioId=@UsuarioId AND InstitucionId=@InstitucionId)
		BEGIN
			SELECT -2 /*NO SE PUEDE ACTUALIZAR: EL REGISTRO NO EXISTE*/
			RETURN
		END

		SET @Correo = LOWER(LTRIM(RTRIM(@Correo)))

		SELECT @AntRolId = USR.RolId,                      @AntRol = ROL.Nombre,
		       @AntCarreraId = USR.CarreraId,              @AntCarrera = CAR.Nombre,
		       @AntDepartamentoId = USR.DepartamentoId,    @AntDepartamento = DEP.Nombre,
		       @AntEquipoId = USR.EquipoId,                @AntEquipo = EQU.Nombre,
		       @AntTipoIdentificacionId = USR.TipoIdentificacionId, @AntTipoIdentificacion = TID.Nombre,
		       @AntIdentificacion = USR.Identificacion,    @AntNumeroInterno = USR.NumeroInterno,
		       @AntNombre = USR.Nombre,                    @AntApellidos = USR.Apellidos,
		       @AntCorreo = USR.Correo,                    @AntActivo = USR.Activo
		FROM Usuario USR
		INNER JOIN Rol ROL                ON ROL.RolId = USR.RolId
		INNER JOIN TipoIdentificacion TID ON TID.TipoIdentificacionId = USR.TipoIdentificacionId
		LEFT JOIN Carrera CAR             ON CAR.CarreraId = USR.CarreraId
		LEFT JOIN Departamento DEP        ON DEP.DepartamentoId = USR.DepartamentoId
		LEFT JOIN EquipoSoporte EQU       ON EQU.EquipoId = USR.EquipoId
		WHERE USR.UsuarioId = @UsuarioId

		---------------------------------------- VALIDACIONES ----------------------------------------
		IF NOT EXISTS (SELECT 1 FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
		               WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId
		                 AND USR.Activo = 1 AND ROL.PuedeAdministrar = 1)
			SELECT @Codigo = -3, @Motivo = N'No tiene permisos para modificar usuarios.'

		ELSE IF LTRIM(RTRIM(ISNULL(@Nombre,'')))='' OR LTRIM(RTRIM(ISNULL(@Apellidos,'')))=''
		     OR LTRIM(RTRIM(ISNULL(@Identificacion,'')))='' OR LTRIM(RTRIM(ISNULL(@NumeroInterno,'')))=''
		     OR LTRIM(RTRIM(ISNULL(@Correo,'')))=''
			SELECT @Codigo = -4, @Motivo = N'Hay campos obligatorios vacíos.'

		ELSE IF NOT EXISTS (SELECT 1 FROM Rol WHERE RolId=@RolId)
			SELECT @Codigo = -4, @Motivo = N'El rol no es válido.'

		ELSE IF NOT EXISTS (SELECT 1 FROM TipoIdentificacion WHERE TipoIdentificacionId=@TipoIdentificacionId)
			SELECT @Codigo = -4, @Motivo = N'El tipo de identificación no es válido.'

		ELSE IF (@RolId IN (1,2) AND (@CarreraId IS NULL OR @DepartamentoId IS NOT NULL))
		     OR (@RolId IN (3,4) AND (@DepartamentoId IS NULL OR @CarreraId IS NOT NULL))
			SELECT @Codigo = -4, @Motivo = N'Estudiante y Profesor llevan carrera; Soporte técnico y Administrativo llevan departamento.'

		ELSE IF @RolId <> 3 AND @EquipoId IS NOT NULL
			SELECT @Codigo = -4, @Motivo = N'Solo el rol Soporte técnico puede pertenecer a un equipo.'

		ELSE IF NOT EXISTS (SELECT 1 FROM Institucion WHERE InstitucionId = @InstitucionId AND @Correo LIKE '%@' + DominioCorreo)
			SELECT @Codigo = -4, @Motivo = N'El correo no pertenece al dominio de la universidad.'

		ELSE IF @CarreraId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Carrera WHERE CarreraId=@CarreraId AND InstitucionId=@InstitucionId AND Activo=1)
			SELECT @Codigo = -4, @Motivo = N'La carrera no es válida.'

		ELSE IF @DepartamentoId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Departamento WHERE DepartamentoId=@DepartamentoId AND InstitucionId=@InstitucionId AND Activo=1)
			SELECT @Codigo = -4, @Motivo = N'El departamento no es válido.'

		ELSE IF @EquipoId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM EquipoSoporte WHERE EquipoId=@EquipoId AND InstitucionId=@InstitucionId AND Activo=1)
			SELECT @Codigo = -4, @Motivo = N'El equipo de soporte no es válido.'

		ELSE IF EXISTS (SELECT 1 FROM Usuario WHERE Correo=@Correo AND UsuarioId<>@UsuarioId)
			SELECT @Codigo = -1, @Motivo = N'Ya existe un usuario con ese correo.'

		ELSE IF EXISTS (SELECT 1 FROM Usuario WHERE InstitucionId=@InstitucionId AND TipoIdentificacionId=@TipoIdentificacionId
		                AND Identificacion=@Identificacion AND UsuarioId<>@UsuarioId)
			SELECT @Codigo = -1, @Motivo = N'Ya existe un usuario con esa identificación.'

		ELSE IF EXISTS (SELECT 1 FROM Usuario WHERE InstitucionId=@InstitucionId AND NumeroInterno=@NumeroInterno AND UsuarioId<>@UsuarioId)
			SELECT @Codigo = -1, @Motivo = N'Ya existe un usuario con ese carné o número de empleado.'

		-- Un administrador no puede cambiarse su propio rol ni desactivarse
		ELSE IF @UsuarioId = @IdUsuarioGlobal AND (@RolId <> @AntRolId OR @Activo = 0)
			SELECT @Codigo = -6, @Motivo = N'No puede cambiar su propio rol ni desactivar su propia cuenta.'

		-- Siempre debe quedar al menos un administrador activo
		ELSE IF @AntRolId = 4 AND @AntActivo = 1 AND (@RolId <> 4 OR @Activo = 0)
		     AND (SELECT COUNT(*) FROM Usuario WHERE InstitucionId=@InstitucionId AND RolId=4 AND Activo=1) <= 1
			SELECT @Codigo = -6, @Motivo = N'No se puede quitar al único administrador activo.'

		-- Si se reactiva, se revisa el límite del plan
		ELSE IF @AntActivo = 0 AND @Activo = 1
		BEGIN
			SELECT @MaxUsuarios = PLA.MaxUsuarios
			FROM Institucion INS INNER JOIN PlanSuscripcion PLA ON PLA.PlanId = INS.PlanId
			WHERE INS.InstitucionId = @InstitucionId

			SELECT @UsuariosActivos = COUNT(*) FROM Usuario WHERE InstitucionId=@InstitucionId AND Activo=1

			IF @MaxUsuarios IS NOT NULL AND @UsuariosActivos >= @MaxUsuarios
				SELECT @Codigo = -5, @Motivo = N'Se alcanzó el límite de usuarios del plan.'
		END

		---------------------------------------- SI NO PASA LAS VALIDACIONES ----------------------------------------
		IF @Codigo < 0
		BEGIN
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Intento fallido de modificar el usuario: ' + @Motivo
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Actualizar', N'Usuarios', @ELEMENTO, @DSC, 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT @Codigo
			RETURN
		END

		---------------------------------------- DETALLE DE CAMBIOS ----------------------------------------
		IF @AntNombre <> @Nombre
			SET @Cambios = @Cambios + N'Nombre: ' + @AntNombre + N' → ' + @Nombre + N'; '
		IF @AntApellidos <> @Apellidos
			SET @Cambios = @Cambios + N'Apellidos: ' + @AntApellidos + N' → ' + @Apellidos + N'; '
		IF @AntCorreo <> @Correo
			SET @Cambios = @Cambios + N'Correo: ' + @AntCorreo + N' → ' + @Correo + N'; '
		IF @AntRolId <> @RolId
			SET @Cambios = @Cambios + N'Rol: ' + @AntRol + N' → ' + (SELECT Nombre FROM Rol WHERE RolId=@RolId) + N'; '
		IF @AntTipoIdentificacionId <> @TipoIdentificacionId OR @AntIdentificacion <> @Identificacion
			SET @Cambios = @Cambios + N'Identificación: ' + @AntTipoIdentificacion + N' ' + @AntIdentificacion + N' → '
			             + (SELECT Nombre FROM TipoIdentificacion WHERE TipoIdentificacionId=@TipoIdentificacionId) + N' ' + @Identificacion + N'; '
		IF @AntNumeroInterno <> @NumeroInterno
			SET @Cambios = @Cambios + N'Número interno: ' + @AntNumeroInterno + N' → ' + @NumeroInterno + N'; '
		IF ISNULL(@AntCarreraId,-1) <> ISNULL(@CarreraId,-1)
			SET @Cambios = @Cambios + N'Carrera: ' + ISNULL(@AntCarrera,N'—') + N' → '
			             + ISNULL((SELECT Nombre FROM Carrera WHERE CarreraId=@CarreraId),N'—') + N'; '
		IF ISNULL(@AntDepartamentoId,-1) <> ISNULL(@DepartamentoId,-1)
			SET @Cambios = @Cambios + N'Departamento: ' + ISNULL(@AntDepartamento,N'—') + N' → '
			             + ISNULL((SELECT Nombre FROM Departamento WHERE DepartamentoId=@DepartamentoId),N'—') + N'; '
		IF ISNULL(@AntEquipoId,-1) <> ISNULL(@EquipoId,-1)
			SET @Cambios = @Cambios + N'Equipo: ' + ISNULL(@AntEquipo,N'—') + N' → '
			             + ISNULL((SELECT Nombre FROM EquipoSoporte WHERE EquipoId=@EquipoId),N'—') + N'; '
		IF @AntActivo <> @Activo
			SET @Cambios = @Cambios + N'Estado: ' + CASE @AntActivo WHEN 1 THEN N'Activo' ELSE N'Inactivo' END
			             + N' → ' + CASE @Activo WHEN 1 THEN N'Activo' ELSE N'Inactivo' END + N'; '
		IF @Contrasena IS NOT NULL
			SET @Cambios = @Cambios + N'Contraseña: actualizada; '   -- nunca se guarda el valor

		IF @Cambios = N'' SET @Cambios = N'Se guardó sin cambios.'

		---------------------------------------- ACTUALIZACION ----------------------------------------
		BEGIN TRANSACTION

			UPDATE Usuario
			SET RolId=@RolId, CarreraId=@CarreraId, DepartamentoId=@DepartamentoId, EquipoId=@EquipoId,
			    TipoIdentificacionId=@TipoIdentificacionId, Identificacion=@Identificacion,
			    NumeroInterno=@NumeroInterno, Nombre=@Nombre, Apellidos=@Apellidos, Correo=@Correo,
			    Contrasena=ISNULL(@Contrasena, Contrasena), Activo=@Activo
			WHERE UsuarioId=@UsuarioId AND InstitucionId=@InstitucionId

			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = LEFT(@Cambios, 500)
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Actualizar', N'Usuarios', @ELEMENTO, @DSC, 1, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------

		COMMIT TRANSACTION

		SELECT @UsuarioId
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION

		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SET @DSC = N'Error al modificar el usuario: ' + ERROR_MESSAGE()
		EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Actualizar', N'Usuarios', @ELEMENTO, @DSC, 0, @DireccionIp
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------

		SELECT 0
	END CATCH
END
GO

USE NaiaInc
GO

-- "Eliminar" = desactivar. No se borra la fila para conservar tiquetes, comentarios y auditoría.
CREATE OR ALTER PROCEDURE SP_ELIMINA_USUARIOS
(
@InstitucionId    INT,
@UsuarioId        INT,
@IdUsuarioGlobal  INT,
@DireccionIp      VARCHAR(45)
)
AS BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @Codigo INT = 0
	DECLARE @Motivo NVARCHAR(300)
	DECLARE @DSC NVARCHAR(500)
	DECLARE @ELEMENTO NVARCHAR(150)
	DECLARE @RolId TINYINT
	DECLARE @Activo BIT

	BEGIN TRY
		-- Validamos primero que el registro exista antes de intentar desactivarlo
		IF NOT EXISTS (SELECT 1 FROM Usuario WHERE UsuarioId=@UsuarioId AND InstitucionId=@InstitucionId)
		BEGIN
			SELECT -2 /*NO SE PUEDE ELIMINAR: EL REGISTRO NO EXISTE*/
			RETURN
		END

		SELECT @ELEMENTO = Nombre + N' ' + Apellidos + N' (' + NumeroInterno + N')',
		       @RolId = RolId, @Activo = Activo
		FROM Usuario
		WHERE UsuarioId = @UsuarioId

		---------------------------------------- VALIDACIONES ----------------------------------------
		IF NOT EXISTS (SELECT 1 FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
		               WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId
		                 AND USR.Activo = 1 AND ROL.PuedeAdministrar = 1)
			SELECT @Codigo = -3, @Motivo = N'No tiene permisos para desactivar usuarios.'

		ELSE IF @Activo = 0
			SELECT @Codigo = -6, @Motivo = N'El usuario ya está desactivado.'

		ELSE IF @UsuarioId = @IdUsuarioGlobal
			SELECT @Codigo = -6, @Motivo = N'No puede desactivar su propia cuenta.'

		ELSE IF @RolId = 4 AND (SELECT COUNT(*) FROM Usuario WHERE InstitucionId=@InstitucionId AND RolId=4 AND Activo=1) <= 1
			SELECT @Codigo = -6, @Motivo = N'No se puede desactivar al único administrador activo.'

		---------------------------------------- SI NO PASA LAS VALIDACIONES ----------------------------------------
		IF @Codigo < 0
		BEGIN
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Intento fallido de desactivar el usuario: ' + @Motivo
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Desactivar', N'Usuarios', @ELEMENTO, @DSC, 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT @Codigo
			RETURN
		END

		---------------------------------------- DESACTIVACION ----------------------------------------
		BEGIN TRANSACTION

			UPDATE Usuario
			SET Activo = 0
			WHERE UsuarioId=@UsuarioId AND InstitucionId=@InstitucionId

			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Desactivó al usuario. Ya no podrá iniciar sesión.'
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Desactivar', N'Usuarios', @ELEMENTO, @DSC, 1, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------

		COMMIT TRANSACTION

		SELECT @UsuarioId
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION

		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SET @DSC = N'Error al desactivar el usuario: ' + ERROR_MESSAGE()
		EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Desactivar', N'Usuarios', @ELEMENTO, @DSC, 0, @DireccionIp
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------

		SELECT 0
	END CATCH
END
GO


/* ================================================================================================
   SECCIÓN 11 · TIQUETES
   ------------------------------------------------------------------------------------------------
   QUIÉN VE QUÉ
     - Estudiante y Profesor (PuedeResolverTickets = 0) -> solo SUS tiquetes.
     - Soporte técnico y Administrativo (PuedeResolverTickets = 1) -> todos los de la universidad.

   CICLO DE VIDA (cada cambio de estado queda en HistorialEstado y en Auditoria)
     SP_INSERTA_TICKETS ........ crea el tiquete en estado 1 Nuevo
     SP_ASIGNA_TICKETS ......... pone o cambia el técnico responsable -> estado 2 Asignado
     SP_CAMBIA_ESTADO_TICKETS .. cualquier otro cambio de estado (En progreso, En espera,
                                 Resuelto, Cerrado, reabrir…). Valida contra TransicionEstado.
     SP_ELIMINA_TICKETS ........ "eliminar" un tiquete = cancelarlo (estado 7). No se borra.
     SP_ACTUALIZA_TICKETS ...... corregir título, descripción, categoría, prioridad o ubicación

   BOTONES DE LA PANTALLA DE DETALLE
     SP_LISTAR_TRANSICIONES_DISPONIBLES devuelve un renglón por botón de cambio de estado que el
     usuario puede usar en ese momento. SP_INFO_TICKET trae PuedeEditar, PuedeAsignar y PuedeComentar.

   SLA (tiempo para resolver)
     FechaLimiteSla = FechaCreacion + Prioridad.SlaHoras. SlaVencido = 1 si pasó esa fecha y el
     tiquete todavía no está Resuelto, Cerrado ni Cancelado.
   ================================================================================================ */
USE NaiaInc
GO

-- Formulario "Nuevo tiquete". El solicitante es quien inicia sesión (@IdUsuarioGlobal).
-- La prioridad y el SLA salen de la categoría. Devuelve el TicketId (el número visible es "INC" + 7 dígitos).
CREATE OR ALTER PROCEDURE SP_INSERTA_TICKETS
(
@InstitucionId    INT,
@Titulo           NVARCHAR(150),
@Descripcion      NVARCHAR(2000),
@CategoriaId      INT,
@UbicacionId      INT,
@IdUsuarioGlobal  INT,
@DireccionIp      VARCHAR(45)
)
AS BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @Codigo INT = 0
	DECLARE @Motivo NVARCHAR(300)
	DECLARE @NuevoId INT
	DECLARE @PrioridadId TINYINT
	DECLARE @SlaHoras INT
	DECLARE @RequiereFisica BIT
	DECLARE @DSC NVARCHAR(MAX)
	DECLARE @ELEMENTO NVARCHAR(150)

	BEGIN TRY
		SET @Titulo = LTRIM(RTRIM(@Titulo))
		SET @Descripcion = LTRIM(RTRIM(@Descripcion))
		SET @ELEMENTO = N'Tiquete nuevo: ' + LEFT(ISNULL(@Titulo,N''), 120)

		SELECT @PrioridadId = CAT.PrioridadInicialId, @SlaHoras = PRI.SlaHoras, @RequiereFisica = CAT.RequiereUbicacionFisica
		FROM Categoria CAT INNER JOIN Prioridad PRI ON PRI.PrioridadId = CAT.PrioridadInicialId
		WHERE CAT.CategoriaId = @CategoriaId AND CAT.InstitucionId = @InstitucionId AND CAT.Activa = 1

		---------------------------------------- VALIDACIONES ----------------------------------------
		IF NOT EXISTS (SELECT 1 FROM Usuario WHERE UsuarioId=@IdUsuarioGlobal AND InstitucionId=@InstitucionId AND Activo=1)
			SELECT @Codigo = -3, @Motivo = N'El usuario no puede crear tiquetes en esta universidad.'
		ELSE IF ISNULL(@Titulo,N'') = N'' OR ISNULL(@Descripcion,N'') = N''
			SELECT @Codigo = -4, @Motivo = N'El título y la descripción son obligatorios.'
		ELSE IF @PrioridadId IS NULL
			SELECT @Codigo = -4, @Motivo = N'La categoría no es válida.'
		ELSE IF NOT EXISTS (SELECT 1 FROM Ubicacion WHERE UbicacionId=@UbicacionId AND InstitucionId=@InstitucionId AND Activa=1)
			SELECT @Codigo = -4, @Motivo = N'La ubicación no es válida.'
		ELSE IF @RequiereFisica = 1 AND EXISTS (SELECT 1 FROM Ubicacion WHERE UbicacionId=@UbicacionId AND EsFisica=0)
			SELECT @Codigo = -4, @Motivo = N'Esta categoría requiere una ubicación física del campus.'

		IF @Codigo < 0
		BEGIN
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Intento fallido de crear el tiquete: ' + @Motivo
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Crear', N'Tiquetes', @ELEMENTO, @DSC, 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT @Codigo
			RETURN
		END

		BEGIN TRANSACTION
			INSERT INTO Ticket
			(
			InstitucionId, Titulo, Descripcion, CategoriaId, PrioridadId, EstadoId,
			SolicitanteId, UbicacionId, FechaLimiteSla
			)
			VALUES
			(
			@InstitucionId, @Titulo, @Descripcion, @CategoriaId, @PrioridadId, 1,
			@IdUsuarioGlobal, @UbicacionId, DATEADD(HOUR, @SlaHoras, SYSDATETIME())
			)
			SET @NuevoId = SCOPE_IDENTITY()

			-- Primer renglón del historial: (nada) → Nuevo
			INSERT INTO HistorialEstado (TicketId, EstadoAnteriorId, EstadoNuevoId, UsuarioId, Motivo)
			VALUES (@NuevoId, NULL, 1, @IdUsuarioGlobal, NULL)

			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT @ELEMENTO = Numero FROM Ticket WHERE TicketId=@NuevoId
			SET @DSC = N'Creó el tiquete "' + LEFT(@Titulo, 150) + N'" en la categoría '
			         + (SELECT Nombre FROM Categoria WHERE CategoriaId=@CategoriaId)
			         + N' con prioridad ' + (SELECT Nombre FROM Prioridad WHERE PrioridadId=@PrioridadId) + N'.'
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Crear', N'Tiquetes', @ELEMENTO, @DSC, 1, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		COMMIT TRANSACTION

		SELECT @NuevoId
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SET @DSC = N'Error al crear el tiquete: ' + ERROR_MESSAGE()
		EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Crear', N'Tiquetes', @ELEMENTO, @DSC, 0, @DireccionIp
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SELECT 0
	END CATCH
END
GO

USE NaiaInc
GO

-- Lista de tiquetes. Abiertos primero, luego por urgencia (1 Crítica primero) y por antigüedad.
CREATE OR ALTER PROCEDURE SP_LISTAR_TICKETS
(
@InstitucionId    INT,
@IdUsuarioGlobal  INT
)
AS BEGIN
	SET NOCOUNT ON;

	DECLARE @RolUsuario TINYINT, @PuedeResolver BIT
	SELECT @RolUsuario = USR.RolId, @PuedeResolver = ROL.PuedeResolverTickets
	FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
	WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId AND USR.Activo = 1

	SELECT TIC.TicketId, TIC.Numero, TIC.Titulo,
	       TIC.CategoriaId, CAT.Nombre AS Categoria, CAT.ColorHex AS CategoriaColor,
	       TIC.PrioridadId, PRI.Nombre AS Prioridad, PRI.ColorHex AS PrioridadColor,
	       TIC.EstadoId, EST.Nombre AS Estado, EST.EsFinal,
	       TIC.SolicitanteId, SOL.Nombre + ' ' + SOL.Apellidos AS Solicitante,
	       TIC.ResponsableId, ISNULL(RES.Nombre + ' ' + RES.Apellidos, N'Sin asignar') AS Responsable,
	       ISNULL(UBI.Edificio + N' · ', N'') + UBI.Nombre AS Ubicacion,
	       TIC.FechaCreacion,
	       CONVERT(VARCHAR(10), TIC.FechaCreacion, 103) + ' ' + CONVERT(VARCHAR(5), TIC.FechaCreacion, 108) AS FechaCreacionTexto,
	       TIC.FechaLimiteSla,
	       CASE WHEN EST.EsFinal = 0 AND TIC.EstadoId <> 5 AND SYSDATETIME() > TIC.FechaLimiteSla THEN 1 ELSE 0 END AS SlaVencido
	FROM Ticket TIC
	INNER JOIN Categoria CAT    ON CAT.CategoriaId = TIC.CategoriaId
	INNER JOIN Prioridad PRI    ON PRI.PrioridadId = TIC.PrioridadId
	INNER JOIN EstadoTicket EST ON EST.EstadoId = TIC.EstadoId
	INNER JOIN Usuario SOL      ON SOL.UsuarioId = TIC.SolicitanteId
	LEFT JOIN Usuario RES       ON RES.UsuarioId = TIC.ResponsableId
	INNER JOIN Ubicacion UBI    ON UBI.UbicacionId = TIC.UbicacionId
	WHERE TIC.InstitucionId = @InstitucionId
	  AND @RolUsuario IS NOT NULL
	  AND (TIC.SolicitanteId = @IdUsuarioGlobal OR @PuedeResolver = 1)
	ORDER BY EST.EsFinal, PRI.Nivel, TIC.FechaCreacion
END
GO

USE NaiaInc
GO

-- Filtros de la lista de tiquetes. Cualquier parámetro en NULL = "todos".
CREATE OR ALTER PROCEDURE SP_FILTRAR_TICKETS
(
@InstitucionId    INT,
@IdUsuarioGlobal  INT,
@Filtro           NVARCHAR(100),   -- número (INC0010001), título, descripción o nombre del solicitante
@EstadoId         TINYINT,         -- 1 Nuevo … 7 Cancelado
@PrioridadId      TINYINT,         -- 1 Crítica … 4 Baja
@CategoriaId      INT,
@ResponsableId    INT,             -- 0 = solo los que están "Sin asignar"
@SoloVencidos     BIT              -- 1 = solo los que pasaron su SLA
)
AS BEGIN
	SET NOCOUNT ON;

	DECLARE @RolUsuario TINYINT, @PuedeResolver BIT
	SELECT @RolUsuario = USR.RolId, @PuedeResolver = ROL.PuedeResolverTickets
	FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
	WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId AND USR.Activo = 1

	SELECT TIC.TicketId, TIC.Numero, TIC.Titulo,
	       TIC.CategoriaId, CAT.Nombre AS Categoria, CAT.ColorHex AS CategoriaColor,
	       TIC.PrioridadId, PRI.Nombre AS Prioridad, PRI.ColorHex AS PrioridadColor,
	       TIC.EstadoId, EST.Nombre AS Estado, EST.EsFinal,
	       TIC.SolicitanteId, SOL.Nombre + ' ' + SOL.Apellidos AS Solicitante,
	       TIC.ResponsableId, ISNULL(RES.Nombre + ' ' + RES.Apellidos, N'Sin asignar') AS Responsable,
	       ISNULL(UBI.Edificio + N' · ', N'') + UBI.Nombre AS Ubicacion,
	       TIC.FechaCreacion,
	       CONVERT(VARCHAR(10), TIC.FechaCreacion, 103) + ' ' + CONVERT(VARCHAR(5), TIC.FechaCreacion, 108) AS FechaCreacionTexto,
	       TIC.FechaLimiteSla,
	       CASE WHEN EST.EsFinal = 0 AND TIC.EstadoId <> 5 AND SYSDATETIME() > TIC.FechaLimiteSla THEN 1 ELSE 0 END AS SlaVencido
	FROM Ticket TIC
	INNER JOIN Categoria CAT    ON CAT.CategoriaId = TIC.CategoriaId
	INNER JOIN Prioridad PRI    ON PRI.PrioridadId = TIC.PrioridadId
	INNER JOIN EstadoTicket EST ON EST.EstadoId = TIC.EstadoId
	INNER JOIN Usuario SOL      ON SOL.UsuarioId = TIC.SolicitanteId
	LEFT JOIN Usuario RES       ON RES.UsuarioId = TIC.ResponsableId
	INNER JOIN Ubicacion UBI    ON UBI.UbicacionId = TIC.UbicacionId
	WHERE TIC.InstitucionId = @InstitucionId
	  AND @RolUsuario IS NOT NULL
	  AND (TIC.SolicitanteId = @IdUsuarioGlobal OR @PuedeResolver = 1)
	  AND (@Filtro IS NULL      OR TIC.Numero LIKE '%' + @Filtro + '%'
	                            OR TIC.Titulo LIKE '%' + @Filtro + '%'
	                            OR TIC.Descripcion LIKE '%' + @Filtro + '%'
	                            OR SOL.Nombre + ' ' + SOL.Apellidos LIKE '%' + @Filtro + '%')
	  AND (@EstadoId IS NULL    OR TIC.EstadoId = @EstadoId)
	  AND (@PrioridadId IS NULL OR TIC.PrioridadId = @PrioridadId)
	  AND (@CategoriaId IS NULL OR TIC.CategoriaId = @CategoriaId)
	  AND (@ResponsableId IS NULL
	       OR (@ResponsableId = 0 AND TIC.ResponsableId IS NULL)
	       OR TIC.ResponsableId = @ResponsableId)
	  AND (ISNULL(@SoloVencidos,0) = 0
	       OR (EST.EsFinal = 0 AND TIC.EstadoId <> 5 AND SYSDATETIME() > TIC.FechaLimiteSla))
	ORDER BY EST.EsFinal, PRI.Nivel, TIC.FechaCreacion
END
GO

USE NaiaInc
GO

-- Pantalla de detalle del tiquete. Si el usuario no tiene permiso de verlo, no devuelve filas.
-- PuedeEditar / PuedeAsignar / PuedeComentar (1 o 0) indican qué botones mostrar.
CREATE OR ALTER PROCEDURE SP_INFO_TICKET
(
@InstitucionId    INT,
@TicketId         INT,
@IdUsuarioGlobal  INT
)
AS BEGIN
	SET NOCOUNT ON;

	DECLARE @RolUsuario TINYINT, @PuedeResolver BIT
	SELECT @RolUsuario = USR.RolId, @PuedeResolver = ROL.PuedeResolverTickets
	FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
	WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId AND USR.Activo = 1

	SELECT TIC.TicketId, TIC.Numero, TIC.Titulo, TIC.Descripcion,
	       TIC.CategoriaId, CAT.Nombre AS Categoria, CAT.ColorHex AS CategoriaColor,
	       TIC.PrioridadId, PRI.Nombre AS Prioridad, PRI.ColorHex AS PrioridadColor, PRI.SlaHoras,
	       TIC.EstadoId, EST.Nombre AS Estado, EST.EsFinal,
	       TIC.SolicitanteId, SOL.Nombre + ' ' + SOL.Apellidos AS Solicitante, SOL.Correo AS CorreoSolicitante,
	       ROLS.Nombre AS RolSolicitante,
	       TIC.ResponsableId, ISNULL(RES.Nombre + ' ' + RES.Apellidos, N'Sin asignar') AS Responsable,
	       EQU.Nombre AS EquipoResponsable,
	       TIC.UbicacionId, ISNULL(UBI.Edificio + N' · ', N'') + UBI.Nombre AS Ubicacion,
	       TIC.Solucion,
	       TIC.FechaCreacion, TIC.FechaActualizacion, TIC.FechaLimiteSla, TIC.FechaResolucion, TIC.FechaCierre,
	       CASE WHEN EST.EsFinal = 0 AND TIC.EstadoId <> 5 AND SYSDATETIME() > TIC.FechaLimiteSla THEN 1 ELSE 0 END AS SlaVencido,
	       -- Permisos para los botones
	       CASE WHEN EST.EsFinal = 0 AND (@PuedeResolver = 1 OR (TIC.SolicitanteId = @IdUsuarioGlobal AND TIC.EstadoId = 1))
	            THEN 1 ELSE 0 END AS PuedeEditar,
	       CASE WHEN @PuedeResolver = 1 AND TIC.EstadoId IN (1,2,3,4) THEN 1 ELSE 0 END AS PuedeAsignar,
	       CASE WHEN EST.EsFinal = 0 AND (@PuedeResolver = 1 OR TIC.SolicitanteId = @IdUsuarioGlobal)
	            THEN 1 ELSE 0 END AS PuedeComentar
	FROM Ticket TIC
	INNER JOIN Categoria CAT    ON CAT.CategoriaId = TIC.CategoriaId
	INNER JOIN Prioridad PRI    ON PRI.PrioridadId = TIC.PrioridadId
	INNER JOIN EstadoTicket EST ON EST.EstadoId = TIC.EstadoId
	INNER JOIN Usuario SOL      ON SOL.UsuarioId = TIC.SolicitanteId
	INNER JOIN Rol ROLS         ON ROLS.RolId = SOL.RolId
	LEFT JOIN Usuario RES       ON RES.UsuarioId = TIC.ResponsableId
	LEFT JOIN EquipoSoporte EQU ON EQU.EquipoId = RES.EquipoId
	INNER JOIN Ubicacion UBI    ON UBI.UbicacionId = TIC.UbicacionId
	WHERE TIC.TicketId = @TicketId
	  AND TIC.InstitucionId = @InstitucionId
	  AND @RolUsuario IS NOT NULL
	  AND (TIC.SolicitanteId = @IdUsuarioGlobal OR @PuedeResolver = 1)
END
GO

USE NaiaInc
GO

-- Corregir los datos del tiquete (ej. soporte aclara la descripción después de hablar con el usuario).
--   Solicitante: puede editar título, descripción, categoría y ubicación SOLO mientras esté Nuevo.
--   Soporte / Administrativo: puede editar todo, incluida la prioridad, mientras no esté Cerrado/Cancelado.
-- Si cambia la prioridad, se recalcula la fecha límite (SLA) desde la fecha de creación.
CREATE OR ALTER PROCEDURE SP_ACTUALIZA_TICKETS
(
@InstitucionId    INT,
@TicketId         INT,
@Titulo           NVARCHAR(150),
@Descripcion      NVARCHAR(2000),
@CategoriaId      INT,
@PrioridadId      TINYINT,
@UbicacionId      INT,
@IdUsuarioGlobal  INT,
@DireccionIp      VARCHAR(45)
)
AS BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @Codigo INT = 0
	DECLARE @Motivo NVARCHAR(300)
	DECLARE @Cambios NVARCHAR(MAX) = N''
	DECLARE @DSC NVARCHAR(MAX)
	DECLARE @ELEMENTO NVARCHAR(150)
	DECLARE @RolUsuario TINYINT, @PuedeResolver BIT
	DECLARE @AntTitulo NVARCHAR(150), @AntDescripcion NVARCHAR(2000)
	DECLARE @AntCategoriaId INT, @AntCategoria NVARCHAR(80)
	DECLARE @AntPrioridadId TINYINT, @AntPrioridad NVARCHAR(30)
	DECLARE @AntUbicacionId INT, @AntUbicacion NVARCHAR(170)
	DECLARE @EstadoId TINYINT, @EsFinal BIT, @SolicitanteId INT
	DECLARE @RequiereFisica BIT, @NuevaSla INT

	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM Ticket WHERE TicketId=@TicketId AND InstitucionId=@InstitucionId)
		BEGIN
			SELECT -2 /*EL TIQUETE NO EXISTE*/
			RETURN
		END

		SET @Titulo = LTRIM(RTRIM(@Titulo))
		SET @Descripcion = LTRIM(RTRIM(@Descripcion))

		SELECT @AntTitulo = TIC.Titulo, @AntDescripcion = TIC.Descripcion,
		       @AntCategoriaId = TIC.CategoriaId, @AntCategoria = CAT.Nombre,
		       @AntPrioridadId = TIC.PrioridadId, @AntPrioridad = PRI.Nombre,
		       @AntUbicacionId = TIC.UbicacionId, @AntUbicacion = ISNULL(UBI.Edificio + N' · ', N'') + UBI.Nombre,
		       @EstadoId = TIC.EstadoId, @EsFinal = EST.EsFinal, @SolicitanteId = TIC.SolicitanteId,
		       @ELEMENTO = TIC.Numero
		FROM Ticket TIC
		INNER JOIN Categoria CAT    ON CAT.CategoriaId = TIC.CategoriaId
		INNER JOIN Prioridad PRI    ON PRI.PrioridadId = TIC.PrioridadId
		INNER JOIN Ubicacion UBI    ON UBI.UbicacionId = TIC.UbicacionId
		INNER JOIN EstadoTicket EST ON EST.EstadoId = TIC.EstadoId
		WHERE TIC.TicketId = @TicketId

		SELECT @RolUsuario = USR.RolId, @PuedeResolver = ROL.PuedeResolverTickets
		FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
		WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId AND USR.Activo = 1

		SELECT @RequiereFisica = RequiereUbicacionFisica FROM Categoria WHERE CategoriaId=@CategoriaId AND InstitucionId=@InstitucionId

		---------------------------------------- VALIDACIONES ----------------------------------------
		IF @RolUsuario IS NULL OR (@PuedeResolver = 0 AND @SolicitanteId <> @IdUsuarioGlobal)
			SELECT @Codigo = -3, @Motivo = N'No tiene permisos para editar este tiquete.'
		ELSE IF @EsFinal = 1
			SELECT @Codigo = -6, @Motivo = N'No se puede editar un tiquete cerrado o cancelado.'
		ELSE IF @PuedeResolver = 0 AND @EstadoId <> 1
			SELECT @Codigo = -6, @Motivo = N'Solo puede editar su tiquete mientras esté en estado Nuevo.'
		ELSE IF @PuedeResolver = 0 AND @PrioridadId <> @AntPrioridadId
			SELECT @Codigo = -3, @Motivo = N'Solo soporte puede cambiar la prioridad.'
		ELSE IF ISNULL(@Titulo,N'') = N'' OR ISNULL(@Descripcion,N'') = N''
			SELECT @Codigo = -4, @Motivo = N'El título y la descripción son obligatorios.'
		ELSE IF @CategoriaId <> @AntCategoriaId
		     AND NOT EXISTS (SELECT 1 FROM Categoria WHERE CategoriaId=@CategoriaId AND InstitucionId=@InstitucionId AND Activa=1)
			SELECT @Codigo = -4, @Motivo = N'La categoría no es válida.'
		ELSE IF NOT EXISTS (SELECT 1 FROM Prioridad WHERE PrioridadId=@PrioridadId)
			SELECT @Codigo = -4, @Motivo = N'La prioridad no es válida.'
		ELSE IF @UbicacionId <> @AntUbicacionId
		     AND NOT EXISTS (SELECT 1 FROM Ubicacion WHERE UbicacionId=@UbicacionId AND InstitucionId=@InstitucionId AND Activa=1)
			SELECT @Codigo = -4, @Motivo = N'La ubicación no es válida.'
		ELSE IF @RequiereFisica = 1 AND EXISTS (SELECT 1 FROM Ubicacion WHERE UbicacionId=@UbicacionId AND EsFisica=0)
			SELECT @Codigo = -4, @Motivo = N'Esta categoría requiere una ubicación física del campus.'

		IF @Codigo < 0
		BEGIN
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Intento fallido de modificar el tiquete: ' + @Motivo
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Actualizar', N'Tiquetes', @ELEMENTO, @DSC, 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT @Codigo
			RETURN
		END

		---------------------------------------- DETALLE DE CAMBIOS ----------------------------------------
		IF @AntTitulo <> @Titulo
			SET @Cambios = @Cambios + N'Título: ' + LEFT(@AntTitulo,80) + N' → ' + LEFT(@Titulo,80) + N'; '
		IF @AntDescripcion <> @Descripcion
			SET @Cambios = @Cambios + N'Descripción: «' + LEFT(@AntDescripcion,100) + CASE WHEN LEN(@AntDescripcion) > 100 THEN N'…' ELSE N'' END
			             + N'» → «' + LEFT(@Descripcion,100) + CASE WHEN LEN(@Descripcion) > 100 THEN N'…' ELSE N'' END + N'»; '
		IF @AntCategoriaId <> @CategoriaId
			SET @Cambios = @Cambios + N'Categoría: ' + @AntCategoria + N' → ' + (SELECT Nombre FROM Categoria WHERE CategoriaId=@CategoriaId) + N'; '
		IF @AntPrioridadId <> @PrioridadId
			SET @Cambios = @Cambios + N'Prioridad: ' + @AntPrioridad + N' → ' + (SELECT Nombre FROM Prioridad WHERE PrioridadId=@PrioridadId) + N'; '
		IF @AntUbicacionId <> @UbicacionId
			SET @Cambios = @Cambios + N'Ubicación: ' + @AntUbicacion + N' → '
			             + (SELECT ISNULL(Edificio + N' · ', N'') + Nombre FROM Ubicacion WHERE UbicacionId=@UbicacionId) + N'; '
		IF @Cambios = N'' SET @Cambios = N'Se guardó sin cambios.'

		SELECT @NuevaSla = SlaHoras FROM Prioridad WHERE PrioridadId=@PrioridadId

		BEGIN TRANSACTION
			UPDATE Ticket
			SET Titulo=@Titulo, Descripcion=@Descripcion, CategoriaId=@CategoriaId, PrioridadId=@PrioridadId,
			    UbicacionId=@UbicacionId, FechaActualizacion=SYSDATETIME(),
			    FechaLimiteSla = CASE WHEN @PrioridadId <> @AntPrioridadId THEN DATEADD(HOUR, @NuevaSla, FechaCreacion) ELSE FechaLimiteSla END
			WHERE TicketId=@TicketId AND InstitucionId=@InstitucionId

			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Actualizar', N'Tiquetes', @ELEMENTO, @Cambios, 1, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		COMMIT TRANSACTION

		SELECT @TicketId
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SET @DSC = N'Error al modificar el tiquete: ' + ERROR_MESSAGE()
		EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Actualizar', N'Tiquetes', @ELEMENTO, @DSC, 0, @DireccionIp
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SELECT 0
	END CATCH
END
GO

USE NaiaInc
GO

-- Dropdown "Asignar a…": técnicos y administrativos activos con su carga de trabajo.
-- @EquipoId = NULL trae a todos; con un Id trae solo ese equipo (útil con Categoria.EquipoPredeterminadoId).
CREATE OR ALTER PROCEDURE SP_LISTAR_RESPONSABLES
(
@InstitucionId INT,
@EquipoId      INT
)
AS BEGIN
	SELECT USR.UsuarioId, USR.Nombre + ' ' + USR.Apellidos AS NombreCompleto,
	       ROL.Nombre AS Rol, USR.EquipoId, EQU.Nombre AS Equipo,
	       (SELECT COUNT(*) FROM Ticket TIC INNER JOIN EstadoTicket EST ON EST.EstadoId = TIC.EstadoId
	        WHERE TIC.ResponsableId = USR.UsuarioId AND EST.EsFinal = 0) AS TiquetesAbiertos
	FROM Usuario USR
	INNER JOIN Rol ROL          ON ROL.RolId = USR.RolId
	LEFT JOIN EquipoSoporte EQU ON EQU.EquipoId = USR.EquipoId
	WHERE USR.InstitucionId = @InstitucionId
	  AND USR.Activo = 1
	  AND ROL.PuedeResolverTickets = 1
	  AND (@EquipoId IS NULL OR USR.EquipoId = @EquipoId)
	ORDER BY TiquetesAbiertos, NombreCompleto
END
GO

USE NaiaInc
GO

-- Asignar o reasignar el técnico responsable. El tiquete queda en estado 2 Asignado.
--   Desde Nuevo o Asignado -> no pide motivo.
--   Desde En progreso o En espera -> es una reasignación y SÍ pide motivo (regla de TransicionEstado).
-- Solo Soporte técnico y Administrativo pueden asignar. El responsable debe poder resolver tiquetes.
CREATE OR ALTER PROCEDURE SP_ASIGNA_TICKETS
(
@InstitucionId    INT,
@TicketId         INT,
@ResponsableId    INT,
@Motivo           NVARCHAR(500),     -- obligatorio solo si estaba En progreso o En espera
@IdUsuarioGlobal  INT,
@DireccionIp      VARCHAR(45)
)
AS BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @Codigo INT = 0
	DECLARE @MotivoFallo NVARCHAR(300)
	DECLARE @DSC NVARCHAR(MAX)
	DECLARE @ELEMENTO NVARCHAR(150)
	DECLARE @EstadoId TINYINT, @Estado NVARCHAR(30), @AntResponsableId INT, @AntResponsable NVARCHAR(150)
	DECLARE @NuevoResponsable NVARCHAR(150)
	DECLARE @RequiereMotivo BIT

	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM Ticket WHERE TicketId=@TicketId AND InstitucionId=@InstitucionId)
		BEGIN
			SELECT -2 /*EL TIQUETE NO EXISTE*/
			RETURN
		END

		SET @Motivo = NULLIF(LTRIM(RTRIM(@Motivo)), N'')

		SELECT @EstadoId = TIC.EstadoId, @Estado = EST.Nombre, @AntResponsableId = TIC.ResponsableId,
		       @AntResponsable = RES.Nombre + ' ' + RES.Apellidos, @ELEMENTO = TIC.Numero
		FROM Ticket TIC
		INNER JOIN EstadoTicket EST ON EST.EstadoId = TIC.EstadoId
		LEFT JOIN Usuario RES       ON RES.UsuarioId = TIC.ResponsableId
		WHERE TIC.TicketId = @TicketId

		SELECT @NuevoResponsable = Nombre + ' ' + Apellidos FROM Usuario WHERE UsuarioId=@ResponsableId

		-- ¿Pasar de su estado actual a Asignado pide motivo?
		SELECT @RequiereMotivo = RequiereMotivo FROM TransicionEstado WHERE EstadoOrigenId=@EstadoId AND EstadoDestinoId=2

		---------------------------------------- VALIDACIONES ----------------------------------------
		IF NOT EXISTS (SELECT 1 FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
		               WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId
		                 AND USR.Activo = 1 AND ROL.PuedeResolverTickets = 1)
			SELECT @Codigo = -3, @MotivoFallo = N'No tiene permisos para asignar tiquetes.'
		ELSE IF @EstadoId NOT IN (1,2,3,4)
			SELECT @Codigo = -6, @MotivoFallo = N'No se puede asignar un tiquete en estado ' + @Estado + N'.'
		ELSE IF NOT EXISTS (SELECT 1 FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
		                    WHERE USR.UsuarioId = @ResponsableId AND USR.InstitucionId = @InstitucionId
		                      AND USR.Activo = 1 AND ROL.PuedeResolverTickets = 1)
			SELECT @Codigo = -4, @MotivoFallo = N'La persona elegida no puede atender tiquetes.'
		ELSE IF @EstadoId = 2 AND @AntResponsableId = @ResponsableId
			SELECT @Codigo = -6, @MotivoFallo = N'El tiquete ya está asignado a esa persona.'
		ELSE IF ISNULL(@RequiereMotivo,0) = 1 AND @Motivo IS NULL
			SELECT @Codigo = -4, @MotivoFallo = N'Debe indicar el motivo de la reasignación.'

		IF @Codigo < 0
		BEGIN
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Intento fallido de asignar el tiquete: ' + @MotivoFallo
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Asignar', N'Tiquetes', @ELEMENTO, @DSC, 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT @Codigo
			RETURN
		END

		BEGIN TRANSACTION
			UPDATE Ticket
			SET ResponsableId = @ResponsableId, EstadoId = 2, FechaActualizacion = SYSDATETIME()
			WHERE TicketId = @TicketId AND InstitucionId = @InstitucionId

			-- Si cambió el estado, queda en el historial
			IF @EstadoId <> 2
				INSERT INTO HistorialEstado (TicketId, EstadoAnteriorId, EstadoNuevoId, UsuarioId, Motivo)
				VALUES (@TicketId, @EstadoId, 2, @IdUsuarioGlobal, @Motivo)

			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Responsable: ' + ISNULL(@AntResponsable, N'Sin asignar') + N' → ' + @NuevoResponsable + N'; '
			         + CASE WHEN @EstadoId <> 2 THEN N'Estado: ' + @Estado + N' → Asignado; ' ELSE N'' END
			         + ISNULL(N'Motivo: ' + @Motivo, N'')
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Asignar', N'Tiquetes', @ELEMENTO, @DSC, 1, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		COMMIT TRANSACTION

		SELECT @TicketId
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SET @DSC = N'Error al asignar el tiquete: ' + ERROR_MESSAGE()
		EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Asignar', N'Tiquetes', @ELEMENTO, @DSC, 0, @DireccionIp
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SELECT 0
	END CATCH
END
GO

USE NaiaInc
GO

-- Botones de cambio de estado para la pantalla de detalle. Un renglón = un botón.
--   RequiereMotivo = 1   -> antes de guardar, pedir un motivo (cuadro de texto)
--   RequiereSolucion = 1 -> antes de guardar, pedir la solución (solo para pasar a Resuelto)
-- El paso de Nuevo a Asignado NO sale aquí: se hace con el botón "Asignar" (SP_ASIGNA_TICKETS).
CREATE OR ALTER PROCEDURE SP_LISTAR_TRANSICIONES_DISPONIBLES
(
@InstitucionId    INT,
@TicketId         INT,
@IdUsuarioGlobal  INT
)
AS BEGIN
	SET NOCOUNT ON;

	DECLARE @RolUsuario TINYINT, @PuedeResolver BIT
	SELECT @RolUsuario = USR.RolId, @PuedeResolver = ROL.PuedeResolverTickets
	FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
	WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId AND USR.Activo = 1

	SELECT TRA.EstadoDestinoId, DES.Nombre AS EstadoDestino, TRA.RequiereMotivo,
	       CASE WHEN TRA.EstadoDestinoId = 5 THEN 1 ELSE 0 END AS RequiereSolucion
	FROM Ticket TIC
	INNER JOIN TransicionEstado TRA ON TRA.EstadoOrigenId = TIC.EstadoId
	INNER JOIN EstadoTicket DES     ON DES.EstadoId = TRA.EstadoDestinoId
	WHERE TIC.TicketId = @TicketId
	  AND TIC.InstitucionId = @InstitucionId
	  AND @RolUsuario IS NOT NULL
	  AND NOT (TIC.EstadoId = 1 AND TRA.EstadoDestinoId = 2)
	  AND (   (TRA.PermiteSolicitante = 1 AND TIC.SolicitanteId = @IdUsuarioGlobal)
	       OR (TRA.PermiteSoporte = 1 AND @PuedeResolver = 1
	           AND (@RolUsuario = 4 OR TIC.ResponsableId = @IdUsuarioGlobal OR TIC.ResponsableId IS NULL)))
	ORDER BY DES.Orden
END
GO

USE NaiaInc
GO

-- Cambiar el estado del tiquete. Valida contra la tabla TransicionEstado:
--   1. Que exista la regla "estado actual → estado nuevo" (si no, devuelve -6).
--   2. Que el usuario tenga permiso: el solicitante si PermiteSolicitante = 1; soporte si
--      PermiteSoporte = 1 (un técnico solo en sus tiquetes; un administrativo en cualquiera).
--   3. Que venga @Motivo si RequiereMotivo = 1, y @Solucion si el nuevo estado es 5 Resuelto.
-- Guarda el cambio en HistorialEstado y llena las fechas (FechaResolucion, FechaCierre).
CREATE OR ALTER PROCEDURE SP_CAMBIA_ESTADO_TICKETS
(
@InstitucionId    INT,
@TicketId         INT,
@EstadoNuevoId    TINYINT,           -- 1 Nuevo · 2 Asignado · 3 En progreso · 4 En espera · 5 Resuelto · 6 Cerrado · 7 Cancelado
@Motivo           NVARCHAR(500),     -- obligatorio cuando la regla lo pide
@Solucion         NVARCHAR(2000),    -- obligatorio para pasar a 5 Resuelto
@IdUsuarioGlobal  INT,
@DireccionIp      VARCHAR(45)
)
AS BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @Codigo INT = 0
	DECLARE @MotivoFallo NVARCHAR(300)
	DECLARE @DSC NVARCHAR(MAX)
	DECLARE @ELEMENTO NVARCHAR(150)
	DECLARE @RolUsuario TINYINT, @PuedeResolver BIT
	DECLARE @EstadoId TINYINT, @Estado NVARCHAR(30), @EstadoNuevo NVARCHAR(30)
	DECLARE @SolicitanteId INT, @ResponsableId INT
	DECLARE @ExisteRegla BIT = 0, @RequiereMotivo BIT, @PermiteSolicitante BIT, @PermiteSoporte BIT

	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM Ticket WHERE TicketId=@TicketId AND InstitucionId=@InstitucionId)
		BEGIN
			SELECT -2 /*EL TIQUETE NO EXISTE*/
			RETURN
		END

		SET @Motivo = NULLIF(LTRIM(RTRIM(@Motivo)), N'')
		SET @Solucion = NULLIF(LTRIM(RTRIM(@Solucion)), N'')

		SELECT @EstadoId = TIC.EstadoId, @Estado = EST.Nombre, @SolicitanteId = TIC.SolicitanteId,
		       @ResponsableId = TIC.ResponsableId, @ELEMENTO = TIC.Numero
		FROM Ticket TIC INNER JOIN EstadoTicket EST ON EST.EstadoId = TIC.EstadoId
		WHERE TIC.TicketId = @TicketId

		SELECT @EstadoNuevo = Nombre FROM EstadoTicket WHERE EstadoId = @EstadoNuevoId

		SELECT @RolUsuario = USR.RolId, @PuedeResolver = ROL.PuedeResolverTickets
		FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
		WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId AND USR.Activo = 1

		SELECT @ExisteRegla = 1, @RequiereMotivo = RequiereMotivo,
		       @PermiteSolicitante = PermiteSolicitante, @PermiteSoporte = PermiteSoporte
		FROM TransicionEstado
		WHERE EstadoOrigenId = @EstadoId AND EstadoDestinoId = @EstadoNuevoId

		---------------------------------------- VALIDACIONES ----------------------------------------
		IF @RolUsuario IS NULL
			SELECT @Codigo = -3, @MotivoFallo = N'No tiene permisos sobre este tiquete.'
		ELSE IF @EstadoId = 1 AND @EstadoNuevoId = 2
			SELECT @Codigo = -6, @MotivoFallo = N'Para pasar a Asignado use la opción Asignar.'
		ELSE IF @ExisteRegla = 0
			SELECT @Codigo = -6, @MotivoFallo = N'No se puede pasar de ' + @Estado + N' a ' + ISNULL(@EstadoNuevo, N'(estado inválido)') + N'.'
		ELSE IF NOT (   (@PermiteSolicitante = 1 AND @SolicitanteId = @IdUsuarioGlobal)
		             OR (@PermiteSoporte = 1 AND @PuedeResolver = 1
		                 AND (@RolUsuario = 4 OR @ResponsableId = @IdUsuarioGlobal OR @ResponsableId IS NULL)))
			SELECT @Codigo = -3, @MotivoFallo = N'No tiene permiso para pasar el tiquete de ' + @Estado + N' a ' + @EstadoNuevo + N'.'
		ELSE IF @RequiereMotivo = 1 AND @Motivo IS NULL
			SELECT @Codigo = -4, @MotivoFallo = N'Debe indicar el motivo del cambio.'
		ELSE IF @EstadoNuevoId = 5 AND @Solucion IS NULL
			SELECT @Codigo = -4, @MotivoFallo = N'Debe escribir la solución para marcarlo como Resuelto.'

		IF @Codigo < 0
		BEGIN
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Intento fallido de cambiar el estado: ' + @MotivoFallo
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'CambiarEstado', N'Tiquetes', @ELEMENTO, @DSC, 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT @Codigo
			RETURN
		END

		BEGIN TRANSACTION
			UPDATE Ticket
			SET EstadoId           = @EstadoNuevoId,
			    FechaActualizacion = SYSDATETIME(),
			    Solucion           = CASE WHEN @EstadoNuevoId = 5 THEN @Solucion ELSE Solucion END,
			    FechaResolucion    = CASE WHEN @EstadoNuevoId = 5 THEN SYSDATETIME()
			                              WHEN @EstadoNuevoId = 2 THEN NULL          -- reabierto
			                              ELSE FechaResolucion END,
			    FechaCierre        = CASE WHEN @EstadoNuevoId IN (6,7) THEN SYSDATETIME() ELSE FechaCierre END
			WHERE TicketId = @TicketId AND InstitucionId = @InstitucionId

			INSERT INTO HistorialEstado (TicketId, EstadoAnteriorId, EstadoNuevoId, UsuarioId, Motivo)
			VALUES (@TicketId, @EstadoId, @EstadoNuevoId, @IdUsuarioGlobal, @Motivo)

			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Estado: ' + @Estado + N' → ' + @EstadoNuevo + N'; '
			         + ISNULL(N'Motivo: ' + @Motivo + N'; ', N'')
			         + ISNULL(N'Solución: ' + LEFT(@Solucion, 250), N'')
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'CambiarEstado', N'Tiquetes', @ELEMENTO, @DSC, 1, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		COMMIT TRANSACTION

		SELECT @TicketId
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SET @DSC = N'Error al cambiar el estado: ' + ERROR_MESSAGE()
		EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'CambiarEstado', N'Tiquetes', @ELEMENTO, @DSC, 0, @DireccionIp
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SELECT 0
	END CATCH
END
GO

USE NaiaInc
GO

-- "Eliminar" un tiquete = CANCELARLO (estado 7). El tiquete no se borra: conserva su número,
-- historial y comentarios. Aplica las mismas reglas que SP_CAMBIA_ESTADO_TICKETS
-- (el motivo es obligatorio; el solicitante solo puede cancelar mientras esté Nuevo o Asignado).
CREATE OR ALTER PROCEDURE SP_ELIMINA_TICKETS
(
@InstitucionId    INT,
@TicketId         INT,
@Motivo           NVARCHAR(500),
@IdUsuarioGlobal  INT,
@DireccionIp      VARCHAR(45)
)
AS BEGIN
	SET NOCOUNT ON;
	EXEC SP_CAMBIA_ESTADO_TICKETS @InstitucionId, @TicketId, 7, @Motivo, NULL, @IdUsuarioGlobal, @DireccionIp
END
GO

USE NaiaInc
GO

-- Tarjetas del dashboard. Devuelve UNA fila con los contadores, respetando qué tiquetes ve el usuario.
CREATE OR ALTER PROCEDURE SP_DASHBOARD_TICKETS
(
@InstitucionId    INT,
@IdUsuarioGlobal  INT
)
AS BEGIN
	SET NOCOUNT ON;

	DECLARE @RolUsuario TINYINT, @PuedeResolver BIT
	DECLARE @InicioMes DATE = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)

	SELECT @RolUsuario = USR.RolId, @PuedeResolver = ROL.PuedeResolverTickets
	FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
	WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId AND USR.Activo = 1

	SELECT ISNULL(SUM(CASE WHEN EST.EsFinal = 0 THEN 1 ELSE 0 END), 0)      AS Abiertos,
	       ISNULL(SUM(CASE WHEN TIC.EstadoId = 1 THEN 1 ELSE 0 END), 0)     AS Nuevos,
	       ISNULL(SUM(CASE WHEN TIC.EstadoId = 2 THEN 1 ELSE 0 END), 0)     AS Asignados,
	       ISNULL(SUM(CASE WHEN TIC.EstadoId = 3 THEN 1 ELSE 0 END), 0)     AS EnProgreso,
	       ISNULL(SUM(CASE WHEN TIC.EstadoId = 4 THEN 1 ELSE 0 END), 0)     AS EnEspera,
	       ISNULL(SUM(CASE WHEN TIC.EstadoId = 5 THEN 1 ELSE 0 END), 0)     AS Resueltos,
	       ISNULL(SUM(CASE WHEN TIC.EstadoId = 6 AND TIC.FechaCierre >= @InicioMes THEN 1 ELSE 0 END), 0) AS CerradosEsteMes,
	       ISNULL(SUM(CASE WHEN EST.EsFinal = 0 AND TIC.EstadoId <> 5 AND SYSDATETIME() > TIC.FechaLimiteSla THEN 1 ELSE 0 END), 0) AS Vencidos,
	       ISNULL(SUM(CASE WHEN EST.EsFinal = 0 AND TIC.ResponsableId = @IdUsuarioGlobal THEN 1 ELSE 0 END), 0) AS AsignadosAMi
	FROM Ticket TIC
	INNER JOIN EstadoTicket EST ON EST.EstadoId = TIC.EstadoId
	WHERE TIC.InstitucionId = @InstitucionId
	  AND @RolUsuario IS NOT NULL
	  AND (TIC.SolicitanteId = @IdUsuarioGlobal OR @PuedeResolver = 1)
END
GO


/* ================================================================================================
   SECCIÓN 12 · COMENTARIOS
   Conversación del tiquete entre el solicitante y soporte (máximo 500 caracteres cada uno).
   Solo el AUTOR puede editar su propio comentario, y solo mientras el tiquete no esté Cerrado
   ni Cancelado. El texto anterior queda guardado en Auditoría. Nadie puede editar el comentario
   de otra persona: si soporte necesita aclarar el problema, edita la descripción del tiquete
   (SP_ACTUALIZA_TICKETS) o escribe su propio comentario.
   ================================================================================================ */
USE NaiaInc
GO

-- Comentarios del tiquete, del más viejo al más nuevo. EsMio = 1 para mostrar el botón "Editar".
CREATE OR ALTER PROCEDURE SP_LISTAR_COMENTARIOS
(
@InstitucionId    INT,
@TicketId         INT,
@IdUsuarioGlobal  INT
)
AS BEGIN
	SET NOCOUNT ON;

	DECLARE @RolUsuario TINYINT, @PuedeResolver BIT
	SELECT @RolUsuario = USR.RolId, @PuedeResolver = ROL.PuedeResolverTickets
	FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
	WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId AND USR.Activo = 1

	SELECT COM.ComentarioId, COM.UsuarioId, USR.Nombre + ' ' + USR.Apellidos AS Autor, ROL.Nombre AS RolAutor,
	       COM.Texto, COM.FechaCreacion,
	       CONVERT(VARCHAR(10), COM.FechaCreacion, 103) + ' ' + CONVERT(VARCHAR(5), COM.FechaCreacion, 108) AS FechaTexto,
	       CASE WHEN COM.UsuarioId = @IdUsuarioGlobal AND EST.EsFinal = 0 THEN 1 ELSE 0 END AS EsMio
	FROM Comentario COM
	INNER JOIN Ticket TIC       ON TIC.TicketId = COM.TicketId
	INNER JOIN EstadoTicket EST ON EST.EstadoId = TIC.EstadoId
	INNER JOIN Usuario USR      ON USR.UsuarioId = COM.UsuarioId
	INNER JOIN Rol ROL          ON ROL.RolId = USR.RolId
	WHERE COM.TicketId = @TicketId
	  AND TIC.InstitucionId = @InstitucionId
	  AND @RolUsuario IS NOT NULL
	  AND (TIC.SolicitanteId = @IdUsuarioGlobal OR @PuedeResolver = 1)
	ORDER BY COM.FechaCreacion, COM.ComentarioId
END
GO

USE NaiaInc
GO

CREATE OR ALTER PROCEDURE SP_INSERTA_COMENTARIOS
(
@InstitucionId    INT,
@TicketId         INT,
@Texto            NVARCHAR(4000),    -- se valida que no pase de 500 caracteres
@IdUsuarioGlobal  INT,
@DireccionIp      VARCHAR(45)
)
AS BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @Codigo INT = 0
	DECLARE @Motivo NVARCHAR(300)
	DECLARE @NuevoId INT
	DECLARE @DSC NVARCHAR(MAX)
	DECLARE @ELEMENTO NVARCHAR(150)
	DECLARE @RolUsuario TINYINT, @PuedeResolver BIT
	DECLARE @SolicitanteId INT, @EsFinal BIT

	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM Ticket WHERE TicketId=@TicketId AND InstitucionId=@InstitucionId)
		BEGIN
			SELECT -2 /*EL TIQUETE NO EXISTE*/
			RETURN
		END

		SET @Texto = LTRIM(RTRIM(@Texto))

		SELECT @SolicitanteId = TIC.SolicitanteId, @EsFinal = EST.EsFinal, @ELEMENTO = TIC.Numero
		FROM Ticket TIC INNER JOIN EstadoTicket EST ON EST.EstadoId = TIC.EstadoId
		WHERE TIC.TicketId = @TicketId

		SELECT @RolUsuario = USR.RolId, @PuedeResolver = ROL.PuedeResolverTickets
		FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
		WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId AND USR.Activo = 1

		IF @RolUsuario IS NULL OR (@PuedeResolver = 0 AND @SolicitanteId <> @IdUsuarioGlobal)
			SELECT @Codigo = -3, @Motivo = N'No tiene permisos para comentar en este tiquete.'
		ELSE IF @EsFinal = 1
			SELECT @Codigo = -6, @Motivo = N'No se puede comentar en un tiquete cerrado o cancelado.'
		ELSE IF ISNULL(@Texto,N'') = N''
			SELECT @Codigo = -4, @Motivo = N'El comentario está vacío.'
		ELSE IF LEN(@Texto) > 500
			SELECT @Codigo = -4, @Motivo = N'El comentario pasa de 500 caracteres.'

		IF @Codigo < 0
		BEGIN
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Intento fallido de comentar: ' + @Motivo
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Crear', N'Tiquetes', @ELEMENTO, @DSC, 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT @Codigo
			RETURN
		END

		BEGIN TRANSACTION
			INSERT INTO Comentario (TicketId, UsuarioId, Texto) VALUES (@TicketId, @IdUsuarioGlobal, @Texto)
			SET @NuevoId = SCOPE_IDENTITY()

			UPDATE Ticket SET FechaActualizacion = SYSDATETIME() WHERE TicketId = @TicketId

			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Agregó un comentario: «' + LEFT(@Texto, 300) + CASE WHEN LEN(@Texto) > 300 THEN N'…' ELSE N'' END + N'»'
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Crear', N'Tiquetes', @ELEMENTO, @DSC, 1, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		COMMIT TRANSACTION

		SELECT @NuevoId
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SET @DSC = N'Error al comentar: ' + ERROR_MESSAGE()
		EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Crear', N'Tiquetes', @ELEMENTO, @DSC, 0, @DireccionIp
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SELECT 0
	END CATCH
END
GO

USE NaiaInc
GO

-- Editar un comentario propio. El texto anterior queda en Auditoría (anterior → nuevo).
CREATE OR ALTER PROCEDURE SP_ACTUALIZA_COMENTARIOS
(
@InstitucionId    INT,
@ComentarioId     INT,
@Texto            NVARCHAR(4000),
@IdUsuarioGlobal  INT,
@DireccionIp      VARCHAR(45)
)
AS BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @Codigo INT = 0
	DECLARE @Motivo NVARCHAR(300)
	DECLARE @DSC NVARCHAR(MAX)
	DECLARE @ELEMENTO NVARCHAR(150)
	DECLARE @AutorId INT, @AntTexto NVARCHAR(500), @EsFinal BIT

	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM Comentario COM INNER JOIN Ticket TIC ON TIC.TicketId = COM.TicketId
		               WHERE COM.ComentarioId = @ComentarioId AND TIC.InstitucionId = @InstitucionId)
		BEGIN
			SELECT -2 /*EL COMENTARIO NO EXISTE*/
			RETURN
		END

		SET @Texto = LTRIM(RTRIM(@Texto))

		SELECT @AutorId = COM.UsuarioId, @AntTexto = COM.Texto, @EsFinal = EST.EsFinal, @ELEMENTO = TIC.Numero
		FROM Comentario COM
		INNER JOIN Ticket TIC       ON TIC.TicketId = COM.TicketId
		INNER JOIN EstadoTicket EST ON EST.EstadoId = TIC.EstadoId
		WHERE COM.ComentarioId = @ComentarioId

		IF @AutorId <> @IdUsuarioGlobal
		   OR NOT EXISTS (SELECT 1 FROM Usuario WHERE UsuarioId=@IdUsuarioGlobal AND InstitucionId=@InstitucionId AND Activo=1)
			SELECT @Codigo = -3, @Motivo = N'Solo el autor puede editar su comentario.'
		ELSE IF @EsFinal = 1
			SELECT @Codigo = -6, @Motivo = N'No se puede editar un comentario de un tiquete cerrado o cancelado.'
		ELSE IF ISNULL(@Texto,N'') = N''
			SELECT @Codigo = -4, @Motivo = N'El comentario está vacío.'
		ELSE IF LEN(@Texto) > 500
			SELECT @Codigo = -4, @Motivo = N'El comentario pasa de 500 caracteres.'

		IF @Codigo < 0
		BEGIN
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Intento fallido de editar un comentario: ' + @Motivo
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Actualizar', N'Tiquetes', @ELEMENTO, @DSC, 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT @Codigo
			RETURN
		END

		BEGIN TRANSACTION
			UPDATE Comentario SET Texto = @Texto WHERE ComentarioId = @ComentarioId

			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Comentario: «' + LEFT(@AntTexto, 200) + CASE WHEN LEN(@AntTexto) > 200 THEN N'…' ELSE N'' END
			         + N'» → «' + LEFT(@Texto, 200) + CASE WHEN LEN(@Texto) > 200 THEN N'…' ELSE N'' END + N'»; '
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Actualizar', N'Tiquetes', @ELEMENTO, @DSC, 1, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		COMMIT TRANSACTION

		SELECT @ComentarioId
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SET @DSC = N'Error al editar el comentario: ' + ERROR_MESSAGE()
		EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Actualizar', N'Tiquetes', @ELEMENTO, @DSC, 0, @DireccionIp
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SELECT 0
	END CATCH
END
GO


/* ================================================================================================
   SECCIÓN 13 · ADJUNTOS
   Archivos del tiquete guardados dentro de la base (VARBINARY). Solo JPG, PNG o PDF, máximo 5 MB.
   TipoContenido: 'image/jpeg' · 'image/png' · 'application/pdf'
   En C#: FileUpload.PostedFile.ContentType y FileUpload.FileBytes
   ================================================================================================ */
USE NaiaInc
GO

-- Lista de archivos del tiquete SIN el contenido (para que cargue rápido). TamanoKB para mostrar.
CREATE OR ALTER PROCEDURE SP_LISTAR_ADJUNTOS
(
@InstitucionId    INT,
@TicketId         INT,
@IdUsuarioGlobal  INT
)
AS BEGIN
	SET NOCOUNT ON;

	DECLARE @RolUsuario TINYINT, @PuedeResolver BIT
	SELECT @RolUsuario = USR.RolId, @PuedeResolver = ROL.PuedeResolverTickets
	FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
	WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId AND USR.Activo = 1

	SELECT ADJ.AdjuntoId, ADJ.NombreOriginal, ADJ.TipoContenido,
	       CAST(DATALENGTH(ADJ.Contenido) / 1024.0 AS DECIMAL(10,1)) AS TamanoKB,
	       ADJ.UsuarioId, USR.Nombre + ' ' + USR.Apellidos AS SubidoPor,
	       ADJ.FechaCarga,
	       CONVERT(VARCHAR(10), ADJ.FechaCarga, 103) + ' ' + CONVERT(VARCHAR(5), ADJ.FechaCarga, 108) AS FechaTexto
	FROM Adjunto ADJ
	INNER JOIN Ticket TIC  ON TIC.TicketId = ADJ.TicketId
	INNER JOIN Usuario USR ON USR.UsuarioId = ADJ.UsuarioId
	WHERE ADJ.TicketId = @TicketId
	  AND TIC.InstitucionId = @InstitucionId
	  AND @RolUsuario IS NOT NULL
	  AND (TIC.SolicitanteId = @IdUsuarioGlobal OR @PuedeResolver = 1)
	ORDER BY ADJ.FechaCarga
END
GO

USE NaiaInc
GO

-- Descargar o ver un archivo: trae el contenido (bytes).
CREATE OR ALTER PROCEDURE SP_INFO_ADJUNTO
(
@InstitucionId    INT,
@AdjuntoId        INT,
@IdUsuarioGlobal  INT
)
AS BEGIN
	SET NOCOUNT ON;

	DECLARE @RolUsuario TINYINT, @PuedeResolver BIT
	SELECT @RolUsuario = USR.RolId, @PuedeResolver = ROL.PuedeResolverTickets
	FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
	WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId AND USR.Activo = 1

	SELECT ADJ.AdjuntoId, ADJ.TicketId, ADJ.NombreOriginal, ADJ.TipoContenido, ADJ.Contenido
	FROM Adjunto ADJ
	INNER JOIN Ticket TIC ON TIC.TicketId = ADJ.TicketId
	WHERE ADJ.AdjuntoId = @AdjuntoId
	  AND TIC.InstitucionId = @InstitucionId
	  AND @RolUsuario IS NOT NULL
	  AND (TIC.SolicitanteId = @IdUsuarioGlobal OR @PuedeResolver = 1)
END
GO

USE NaiaInc
GO

CREATE OR ALTER PROCEDURE SP_INSERTA_ADJUNTOS
(
@InstitucionId    INT,
@TicketId         INT,
@NombreOriginal   NVARCHAR(255),
@TipoContenido    VARCHAR(50),
@Contenido        VARBINARY(MAX),
@IdUsuarioGlobal  INT,
@DireccionIp      VARCHAR(45)
)
AS BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @Codigo INT = 0
	DECLARE @Motivo NVARCHAR(300)
	DECLARE @NuevoId INT
	DECLARE @DSC NVARCHAR(MAX)
	DECLARE @ELEMENTO NVARCHAR(150)
	DECLARE @RolUsuario TINYINT, @PuedeResolver BIT
	DECLARE @SolicitanteId INT, @EsFinal BIT

	BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM Ticket WHERE TicketId=@TicketId AND InstitucionId=@InstitucionId)
		BEGIN
			SELECT -2 /*EL TIQUETE NO EXISTE*/
			RETURN
		END

		SET @NombreOriginal = LTRIM(RTRIM(@NombreOriginal))
		SET @TipoContenido = LOWER(LTRIM(RTRIM(@TipoContenido)))

		SELECT @SolicitanteId = TIC.SolicitanteId, @EsFinal = EST.EsFinal, @ELEMENTO = TIC.Numero
		FROM Ticket TIC INNER JOIN EstadoTicket EST ON EST.EstadoId = TIC.EstadoId
		WHERE TIC.TicketId = @TicketId

		SELECT @RolUsuario = USR.RolId, @PuedeResolver = ROL.PuedeResolverTickets
		FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
		WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId AND USR.Activo = 1

		IF @RolUsuario IS NULL OR (@PuedeResolver = 0 AND @SolicitanteId <> @IdUsuarioGlobal)
			SELECT @Codigo = -3, @Motivo = N'No tiene permisos para adjuntar archivos en este tiquete.'
		ELSE IF @EsFinal = 1
			SELECT @Codigo = -6, @Motivo = N'No se pueden adjuntar archivos a un tiquete cerrado o cancelado.'
		ELSE IF ISNULL(@NombreOriginal,N'') = N'' OR @Contenido IS NULL OR DATALENGTH(@Contenido) = 0
			SELECT @Codigo = -4, @Motivo = N'El archivo está vacío.'
		ELSE IF @TipoContenido NOT IN ('image/jpeg', 'image/png', 'application/pdf')
			SELECT @Codigo = -4, @Motivo = N'Tipo de archivo no permitido (solo JPG, PNG o PDF).'
		ELSE IF DATALENGTH(@Contenido) > 5242880
			SELECT @Codigo = -4, @Motivo = N'El archivo pasa de 5 MB.'

		IF @Codigo < 0
		BEGIN
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Intento fallido de adjuntar "' + ISNULL(LEFT(@NombreOriginal,150),N'') + N'": ' + @Motivo
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Crear', N'Tiquetes', @ELEMENTO, @DSC, 0, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SELECT @Codigo
			RETURN
		END

		BEGIN TRANSACTION
			INSERT INTO Adjunto (TicketId, UsuarioId, NombreOriginal, TipoContenido, Contenido)
			VALUES (@TicketId, @IdUsuarioGlobal, @NombreOriginal, @TipoContenido, @Contenido)
			SET @NuevoId = SCOPE_IDENTITY()

			UPDATE Ticket SET FechaActualizacion = SYSDATETIME() WHERE TicketId = @TicketId

			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
			SET @DSC = N'Adjuntó el archivo "' + LEFT(@NombreOriginal,150) + N'" ('
			         + CAST(CAST(DATALENGTH(@Contenido) / 1024.0 AS DECIMAL(10,1)) AS NVARCHAR(20)) + N' KB).'
			EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Crear', N'Tiquetes', @ELEMENTO, @DSC, 1, @DireccionIp
			-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		COMMIT TRANSACTION

		SELECT @NuevoId
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SET @DSC = N'Error al adjuntar el archivo: ' + ERROR_MESSAGE()
		EXEC SP_INSERTA_AUDITORIA @InstitucionId, @IdUsuarioGlobal, N'Crear', N'Tiquetes', @ELEMENTO, @DSC, 0, @DireccionIp
		-----------------------PARA EL CONTROL DE AUDITORIA DEL SISTEMA-------------------------------------------
		SELECT 0
	END CATCH
END
GO


/* ================================================================================================
   SECCIÓN 14 · HISTORIAL DE ESTADOS
   Línea de tiempo del tiquete. Solo se consulta: la llenan automáticamente SP_INSERTA_TICKETS,
   SP_ASIGNA_TICKETS y SP_CAMBIA_ESTADO_TICKETS. Sirve para la pantalla de detalle
   ("Nuevo → Asignado por Ana el 02/11 9:14", etc.) y para medir tiempos de atención.
   ================================================================================================ */
USE NaiaInc
GO

CREATE OR ALTER PROCEDURE SP_LISTAR_HISTORIAL_ESTADO
(
@InstitucionId    INT,
@TicketId         INT,
@IdUsuarioGlobal  INT
)
AS BEGIN
	SET NOCOUNT ON;

	DECLARE @RolUsuario TINYINT, @PuedeResolver BIT
	SELECT @RolUsuario = USR.RolId, @PuedeResolver = ROL.PuedeResolverTickets
	FROM Usuario USR INNER JOIN Rol ROL ON ROL.RolId = USR.RolId
	WHERE USR.UsuarioId = @IdUsuarioGlobal AND USR.InstitucionId = @InstitucionId AND USR.Activo = 1

	SELECT HIS.HistorialId,
	       HIS.EstadoAnteriorId, ISNULL(ANT.Nombre, N'—') AS EstadoAnterior,
	       HIS.EstadoNuevoId, NUE.Nombre AS EstadoNuevo,
	       HIS.UsuarioId, USR.Nombre + ' ' + USR.Apellidos AS Usuario,
	       HIS.Motivo, HIS.Fecha,
	       CONVERT(VARCHAR(10), HIS.Fecha, 103) + ' ' + CONVERT(VARCHAR(5), HIS.Fecha, 108) AS FechaTexto
	FROM HistorialEstado HIS
	INNER JOIN Ticket TIC         ON TIC.TicketId = HIS.TicketId
	LEFT JOIN EstadoTicket ANT    ON ANT.EstadoId = HIS.EstadoAnteriorId
	INNER JOIN EstadoTicket NUE   ON NUE.EstadoId = HIS.EstadoNuevoId
	INNER JOIN Usuario USR        ON USR.UsuarioId = HIS.UsuarioId
	WHERE HIS.TicketId = @TicketId
	  AND TIC.InstitucionId = @InstitucionId
	  AND @RolUsuario IS NOT NULL
	  AND (TIC.SolicitanteId = @IdUsuarioGlobal OR @PuedeResolver = 1)
	ORDER BY HIS.Fecha, HIS.HistorialId
END
GO

PRINT N'NaiaInc: procedimientos almacenados creados.';
GO