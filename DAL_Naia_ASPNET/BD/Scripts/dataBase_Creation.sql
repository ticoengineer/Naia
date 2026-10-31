/* ============================================================================
   NAIA INC. · Plataforma SaaS de mesa de ayuda para universidades
   Creación de la base de datos, tablas, relaciones, índices y catálogos fijos
   Motor: Microsoft SQL Server 2016 o superior
   ============================================================================ */

USE master;
GO
IF DB_ID(N'NaiaInc') IS NULL
    CREATE DATABASE NaiaInc;
GO
USE NaiaInc;
GO

/* ============================================================================
   1. SAAS
   ============================================================================ */

-- Planes de suscripción que se le venden a cada universidad
CREATE TABLE dbo.PlanSuscripcion (
    PlanId         INT IDENTITY(1,1)  CONSTRAINT PK_PlanSuscripcion PRIMARY KEY,
    Nombre         NVARCHAR(50)       NOT NULL CONSTRAINT UQ_PlanSuscripcion_Nombre UNIQUE,
    MaxUsuarios    INT                NULL,                 -- NULL = ilimitado
    PrecioMensual  DECIMAL(10,2)      NOT NULL,
    Activo         BIT                NOT NULL CONSTRAINT DF_PlanSuscripcion_Activo DEFAULT (1),
    CONSTRAINT CK_PlanSuscripcion_Precio      CHECK (PrecioMensual >= 0),
    CONSTRAINT CK_PlanSuscripcion_MaxUsuarios CHECK (MaxUsuarios IS NULL OR MaxUsuarios > 0)
);
GO

-- Universidades clientes
CREATE TABLE dbo.Institucion (
    InstitucionId  INT IDENTITY(1,1)  CONSTRAINT PK_Institucion PRIMARY KEY,
    PlanId         INT                NOT NULL,
    Nombre         NVARCHAR(150)      NOT NULL,
    Siglas         NVARCHAR(10)       NOT NULL,
    DominioCorreo  VARCHAR(100)       NOT NULL CONSTRAINT UQ_Institucion_DominioCorreo UNIQUE,  -- ej. uam.ac.cr
    LogoUrl        NVARCHAR(300)      NULL,
    Activa         BIT                NOT NULL CONSTRAINT DF_Institucion_Activa DEFAULT (1),
    FechaCreacion  DATETIME2(0)       NOT NULL CONSTRAINT DF_Institucion_Fecha  DEFAULT (SYSDATETIME()),
    CONSTRAINT FK_Institucion_Plan FOREIGN KEY (PlanId) REFERENCES dbo.PlanSuscripcion (PlanId)
);
GO

/* ============================================================================
   2. CATÁLOGOS GLOBALES (fijos, los define Naia; iguales para todas)
   ============================================================================ */

-- 1 Estudiante · 2 Profesor · 3 Soporte técnico · 4 Administrativo
CREATE TABLE dbo.Rol (
    RolId                 TINYINT        CONSTRAINT PK_Rol PRIMARY KEY,
    Nombre                NVARCHAR(30)   NOT NULL CONSTRAINT UQ_Rol_Nombre UNIQUE,
    Descripcion           NVARCHAR(200)  NULL,
    TipoNumeroInterno     NVARCHAR(30)   NOT NULL,          -- 'Carné' o 'N.º de empleado'
    PuedeResolverTickets  BIT            NOT NULL CONSTRAINT DF_Rol_Resolver    DEFAULT (0),
    PuedeAdministrar      BIT            NOT NULL CONSTRAINT DF_Rol_Administrar DEFAULT (0)
);
GO

-- 1 Cédula de identidad · 2 DIMEX · 3 Pasaporte
CREATE TABLE dbo.TipoIdentificacion (
    TipoIdentificacionId  TINYINT       CONSTRAINT PK_TipoIdentificacion PRIMARY KEY,
    Nombre                NVARCHAR(40)  NOT NULL CONSTRAINT UQ_TipoIdentificacion_Nombre UNIQUE,
    Activo                BIT           NOT NULL CONSTRAINT DF_TipoIdentificacion_Activo DEFAULT (1)
);
GO

-- 1 Crítica · 2 Alta · 3 Media · 4 Baja
CREATE TABLE dbo.Prioridad (
    PrioridadId  TINYINT       CONSTRAINT PK_Prioridad PRIMARY KEY,
    Nombre       NVARCHAR(30)  NOT NULL CONSTRAINT UQ_Prioridad_Nombre UNIQUE,
    Nivel        TINYINT       NOT NULL CONSTRAINT UQ_Prioridad_Nivel  UNIQUE,   -- 1 = más urgente
    SlaHoras     INT           NOT NULL,
    ColorHex     CHAR(7)       NOT NULL,
    CONSTRAINT CK_Prioridad_Sla   CHECK (SlaHoras > 0),
    CONSTRAINT CK_Prioridad_Color CHECK (ColorHex LIKE '#[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]')
);
GO

-- 1 Nuevo · 2 Asignado · 3 En progreso · 4 En espera · 5 Resuelto · 6 Cerrado · 7 Cancelado
CREATE TABLE dbo.EstadoTicket (
    EstadoId  TINYINT       CONSTRAINT PK_EstadoTicket PRIMARY KEY,
    Nombre    NVARCHAR(30)  NOT NULL CONSTRAINT UQ_EstadoTicket_Nombre UNIQUE,
    Orden     TINYINT       NOT NULL,
    EsFinal   BIT           NOT NULL CONSTRAINT DF_EstadoTicket_EsFinal DEFAULT (0)
);
GO

-- Reglas: de qué estado se puede pasar a cuál y quién puede hacerlo
CREATE TABLE dbo.TransicionEstado (
    EstadoOrigenId      TINYINT  NOT NULL,
    EstadoDestinoId     TINYINT  NOT NULL,
    RequiereMotivo      BIT      NOT NULL CONSTRAINT DF_Transicion_Motivo      DEFAULT (0),
    PermiteSolicitante  BIT      NOT NULL CONSTRAINT DF_Transicion_Solicitante DEFAULT (0),
    PermiteSoporte      BIT      NOT NULL CONSTRAINT DF_Transicion_Soporte     DEFAULT (0),
    CONSTRAINT PK_TransicionEstado PRIMARY KEY (EstadoOrigenId, EstadoDestinoId),
    CONSTRAINT FK_Transicion_Origen  FOREIGN KEY (EstadoOrigenId)  REFERENCES dbo.EstadoTicket (EstadoId),
    CONSTRAINT FK_Transicion_Destino FOREIGN KEY (EstadoDestinoId) REFERENCES dbo.EstadoTicket (EstadoId),
    CONSTRAINT CK_Transicion_Distinto CHECK (EstadoOrigenId <> EstadoDestinoId),
    CONSTRAINT CK_Transicion_Permiso  CHECK (PermiteSolicitante = 1 OR PermiteSoporte = 1)
);
GO

/* ============================================================================
   3. CATÁLOGOS DE CADA UNIVERSIDAD (los crea el administrador)
   ============================================================================ */

-- Carreras (estudiantes y profesores)
CREATE TABLE dbo.Carrera (
    CarreraId      INT IDENTITY(1,1)  CONSTRAINT PK_Carrera PRIMARY KEY,
    InstitucionId  INT                NOT NULL,
    Nombre         NVARCHAR(100)      NOT NULL,
    Activo         BIT                NOT NULL CONSTRAINT DF_Carrera_Activo DEFAULT (1),
    CONSTRAINT FK_Carrera_Institucion FOREIGN KEY (InstitucionId) REFERENCES dbo.Institucion (InstitucionId),
    CONSTRAINT UQ_Carrera_Nombre UNIQUE (InstitucionId, Nombre)
);
GO

-- Departamentos (soporte técnico y administrativos)
-- "Administración General" se crea automáticamente al registrar la universidad
CREATE TABLE dbo.Departamento (
    DepartamentoId  INT IDENTITY(1,1)  CONSTRAINT PK_Departamento PRIMARY KEY,
    InstitucionId   INT                NOT NULL,
    Nombre          NVARCHAR(100)      NOT NULL,
    Activo          BIT                NOT NULL CONSTRAINT DF_Departamento_Activo DEFAULT (1),
    CONSTRAINT FK_Departamento_Institucion FOREIGN KEY (InstitucionId) REFERENCES dbo.Institucion (InstitucionId),
    CONSTRAINT UQ_Departamento_Nombre UNIQUE (InstitucionId, Nombre)
);
GO

-- Equipos de soporte (Redes, Laboratorios, Aplicaciones…)
CREATE TABLE dbo.EquipoSoporte (
    EquipoId       INT IDENTITY(1,1)  CONSTRAINT PK_EquipoSoporte PRIMARY KEY,
    InstitucionId  INT                NOT NULL,
    Nombre         NVARCHAR(80)       NOT NULL,
    Descripcion    NVARCHAR(250)      NULL,
    Activo         BIT                NOT NULL CONSTRAINT DF_EquipoSoporte_Activo DEFAULT (1),
    CONSTRAINT FK_EquipoSoporte_Institucion FOREIGN KEY (InstitucionId) REFERENCES dbo.Institucion (InstitucionId),
    CONSTRAINT UQ_EquipoSoporte_Nombre UNIQUE (InstitucionId, Nombre)
);
GO

-- Ubicaciones físicas (aulas, laboratorios) y virtuales (remoto, sistema en línea)
-- Las virtuales se crean automáticamente al registrar la universidad
CREATE TABLE dbo.Ubicacion (
    UbicacionId    INT IDENTITY(1,1)  CONSTRAINT PK_Ubicacion PRIMARY KEY,
    InstitucionId  INT                NOT NULL,
    Nombre         NVARCHAR(80)       NOT NULL,
    Edificio       NVARCHAR(80)       NULL,
    EsFisica       BIT                NOT NULL,      -- 1 = en el campus · 0 = virtual
    Activa         BIT                NOT NULL CONSTRAINT DF_Ubicacion_Activa DEFAULT (1),
    CONSTRAINT FK_Ubicacion_Institucion FOREIGN KEY (InstitucionId) REFERENCES dbo.Institucion (InstitucionId),
    CONSTRAINT UQ_Ubicacion UNIQUE (InstitucionId, Edificio, Nombre),
    CONSTRAINT CK_Ubicacion_Edificio CHECK (EsFisica = 0 OR Edificio IS NOT NULL)
);
GO

-- Categorías de tiquete
CREATE TABLE dbo.Categoria (
    CategoriaId              INT IDENTITY(1,1)  CONSTRAINT PK_Categoria PRIMARY KEY,
    InstitucionId            INT                NOT NULL,
    Nombre                   NVARCHAR(80)       NOT NULL,
    Descripcion              NVARCHAR(250)      NULL,
    ColorHex                 CHAR(7)            NOT NULL CONSTRAINT DF_Categoria_Color DEFAULT ('#3C4F76'),
    PrioridadInicialId       TINYINT            NOT NULL,
    EquipoPredeterminadoId   INT                NULL,
    RequiereUbicacionFisica  BIT                NOT NULL CONSTRAINT DF_Categoria_Ubicacion DEFAULT (0),
    Activa                   BIT                NOT NULL CONSTRAINT DF_Categoria_Activa DEFAULT (1),
    CONSTRAINT FK_Categoria_Institucion FOREIGN KEY (InstitucionId)          REFERENCES dbo.Institucion (InstitucionId),
    CONSTRAINT FK_Categoria_Prioridad   FOREIGN KEY (PrioridadInicialId)     REFERENCES dbo.Prioridad (PrioridadId),
    CONSTRAINT FK_Categoria_Equipo      FOREIGN KEY (EquipoPredeterminadoId) REFERENCES dbo.EquipoSoporte (EquipoId),
    CONSTRAINT UQ_Categoria_Nombre UNIQUE (InstitucionId, Nombre),
    CONSTRAINT CK_Categoria_Color  CHECK (ColorHex LIKE '#[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]')
);
GO

/* ============================================================================
   4. USUARIOS
   ============================================================================ */

CREATE TABLE dbo.Usuario (
    UsuarioId             INT IDENTITY(1,1)  CONSTRAINT PK_Usuario PRIMARY KEY,
    InstitucionId         INT                NOT NULL,
    RolId                 TINYINT            NOT NULL,
    CarreraId             INT                NULL,      -- Estudiante y Profesor
    DepartamentoId        INT                NULL,      -- Soporte técnico y Administrativo
    EquipoId              INT                NULL,      -- solo Soporte técnico
    TipoIdentificacionId  TINYINT            NOT NULL,
    Identificacion        VARCHAR(30)        NOT NULL,  -- documento del gobierno
    NumeroInterno         VARCHAR(30)        NOT NULL,  -- carné o N.º de empleado
    Nombre                NVARCHAR(60)       NOT NULL,
    Apellidos             NVARCHAR(80)       NOT NULL,
    Correo                VARCHAR(150)       NOT NULL CONSTRAINT UQ_Usuario_Correo UNIQUE,
    Contrasena            VARCHAR(256)       NOT NULL,
    Activo                BIT                NOT NULL CONSTRAINT DF_Usuario_Activo DEFAULT (1),
    FechaCreacion         DATETIME2(0)       NOT NULL CONSTRAINT DF_Usuario_Fecha  DEFAULT (SYSDATETIME()),
    UltimoAcceso          DATETIME2(0)       NULL,
    CONSTRAINT FK_Usuario_Institucion        FOREIGN KEY (InstitucionId)        REFERENCES dbo.Institucion (InstitucionId),
    CONSTRAINT FK_Usuario_Rol                FOREIGN KEY (RolId)                REFERENCES dbo.Rol (RolId),
    CONSTRAINT FK_Usuario_Carrera            FOREIGN KEY (CarreraId)            REFERENCES dbo.Carrera (CarreraId),
    CONSTRAINT FK_Usuario_Departamento       FOREIGN KEY (DepartamentoId)       REFERENCES dbo.Departamento (DepartamentoId),
    CONSTRAINT FK_Usuario_Equipo             FOREIGN KEY (EquipoId)             REFERENCES dbo.EquipoSoporte (EquipoId),
    CONSTRAINT FK_Usuario_TipoIdentificacion FOREIGN KEY (TipoIdentificacionId) REFERENCES dbo.TipoIdentificacion (TipoIdentificacionId),
    CONSTRAINT UQ_Usuario_Identificacion UNIQUE (InstitucionId, TipoIdentificacionId, Identificacion),
    CONSTRAINT UQ_Usuario_NumeroInterno  UNIQUE (InstitucionId, NumeroInterno),
    CONSTRAINT CK_Usuario_Correo CHECK (Correo LIKE '%_@_%._%'),
    -- Estudiante/Profesor → carrera · Soporte técnico/Administrativo → departamento
    CONSTRAINT CK_Usuario_CarreraDepto CHECK (
           (RolId IN (1, 2) AND CarreraId IS NOT NULL AND DepartamentoId IS NULL)
        OR (RolId IN (3, 4) AND DepartamentoId IS NOT NULL AND CarreraId IS NULL)
    ),
    -- Solo Soporte técnico pertenece a un equipo
    CONSTRAINT CK_Usuario_Equipo CHECK (RolId = 3 OR EquipoId IS NULL)
);
GO

/* ============================================================================
   5. TIQUETES
   ============================================================================ */

CREATE TABLE dbo.Ticket (
    TicketId            INT IDENTITY(10001,1)  CONSTRAINT PK_Ticket PRIMARY KEY,
    Numero AS (CAST('INC' + RIGHT('0000000' + CAST(TicketId AS VARCHAR(10)), 7) AS VARCHAR(10))),  -- INC0010142
    InstitucionId       INT                NOT NULL,
    Titulo              NVARCHAR(150)      NOT NULL,
    Descripcion         NVARCHAR(2000)     NOT NULL,
    CategoriaId         INT                NOT NULL,
    PrioridadId         TINYINT            NOT NULL,
    EstadoId            TINYINT            NOT NULL CONSTRAINT DF_Ticket_Estado DEFAULT (1),
    SolicitanteId       INT                NOT NULL,      -- quien reporta
    ResponsableId       INT                NULL,          -- técnico asignado
    UbicacionId         INT                NOT NULL,
    Solucion            NVARCHAR(2000)     NULL,
    FechaCreacion       DATETIME2(0)       NOT NULL CONSTRAINT DF_Ticket_FechaCreacion      DEFAULT (SYSDATETIME()),
    FechaActualizacion  DATETIME2(0)       NOT NULL CONSTRAINT DF_Ticket_FechaActualizacion DEFAULT (SYSDATETIME()),
    FechaLimiteSla      DATETIME2(0)       NULL,
    FechaResolucion     DATETIME2(0)       NULL,
    FechaCierre         DATETIME2(0)       NULL,          -- al llegar a Cerrado o Cancelado
    CONSTRAINT FK_Ticket_Institucion FOREIGN KEY (InstitucionId) REFERENCES dbo.Institucion (InstitucionId),
    CONSTRAINT FK_Ticket_Categoria   FOREIGN KEY (CategoriaId)   REFERENCES dbo.Categoria (CategoriaId),
    CONSTRAINT FK_Ticket_Prioridad   FOREIGN KEY (PrioridadId)   REFERENCES dbo.Prioridad (PrioridadId),
    CONSTRAINT FK_Ticket_Estado      FOREIGN KEY (EstadoId)      REFERENCES dbo.EstadoTicket (EstadoId),
    CONSTRAINT FK_Ticket_Solicitante FOREIGN KEY (SolicitanteId) REFERENCES dbo.Usuario (UsuarioId),
    CONSTRAINT FK_Ticket_Responsable FOREIGN KEY (ResponsableId) REFERENCES dbo.Usuario (UsuarioId),
    CONSTRAINT FK_Ticket_Ubicacion   FOREIGN KEY (UbicacionId)   REFERENCES dbo.Ubicacion (UbicacionId),
    -- Sin responsable solo si está Nuevo (o se canceló estando Nuevo)
    CONSTRAINT CK_Ticket_Responsable CHECK (EstadoId IN (1, 7) OR ResponsableId IS NOT NULL),
    -- La solución es obligatoria en Resuelto y Cerrado
    CONSTRAINT CK_Ticket_Solucion CHECK (EstadoId NOT IN (5, 6) OR Solucion IS NOT NULL)
);
GO

-- Comentarios: máximo 500 caracteres; no se editan ni se eliminan
CREATE TABLE dbo.Comentario (
    ComentarioId   INT IDENTITY(1,1)  CONSTRAINT PK_Comentario PRIMARY KEY,
    TicketId       INT                NOT NULL,
    UsuarioId      INT                NOT NULL,
    Texto          NVARCHAR(500)      NOT NULL,
    FechaCreacion  DATETIME2(0)       NOT NULL CONSTRAINT DF_Comentario_Fecha DEFAULT (SYSDATETIME()),
    CONSTRAINT FK_Comentario_Ticket  FOREIGN KEY (TicketId)  REFERENCES dbo.Ticket (TicketId),
    CONSTRAINT FK_Comentario_Usuario FOREIGN KEY (UsuarioId) REFERENCES dbo.Usuario (UsuarioId),
    CONSTRAINT CK_Comentario_Texto CHECK (LEN(Texto) > 0)
);
GO

-- Adjuntos: el archivo se guarda dentro de la base (JPG, PNG o PDF, máximo 5 MB)
CREATE TABLE dbo.Adjunto (
    AdjuntoId       INT IDENTITY(1,1)  CONSTRAINT PK_Adjunto PRIMARY KEY,
    TicketId        INT                NOT NULL,
    UsuarioId       INT                NOT NULL,
    NombreOriginal  NVARCHAR(255)      NOT NULL,
    TipoContenido   VARCHAR(50)        NOT NULL,
    Contenido       VARBINARY(MAX)     NOT NULL,
    FechaCarga      DATETIME2(0)       NOT NULL CONSTRAINT DF_Adjunto_Fecha DEFAULT (SYSDATETIME()),
    CONSTRAINT FK_Adjunto_Ticket  FOREIGN KEY (TicketId)  REFERENCES dbo.Ticket (TicketId),
    CONSTRAINT FK_Adjunto_Usuario FOREIGN KEY (UsuarioId) REFERENCES dbo.Usuario (UsuarioId),
    CONSTRAINT CK_Adjunto_Tipo   CHECK (TipoContenido IN ('image/jpeg', 'image/png', 'application/pdf')),
    CONSTRAINT CK_Adjunto_Tamano CHECK (DATALENGTH(Contenido) <= 5242880)
);
GO

-- Historial de cambios de estado de cada tiquete
CREATE TABLE dbo.HistorialEstado (
    HistorialId       BIGINT IDENTITY(1,1)  CONSTRAINT PK_HistorialEstado PRIMARY KEY,
    TicketId          INT                   NOT NULL,
    EstadoAnteriorId  TINYINT               NULL,     -- NULL al crearse el tiquete
    EstadoNuevoId     TINYINT               NOT NULL,
    UsuarioId         INT                   NOT NULL,
    Motivo            NVARCHAR(500)         NULL,
    Fecha             DATETIME2(0)          NOT NULL CONSTRAINT DF_HistorialEstado_Fecha DEFAULT (SYSDATETIME()),
    CONSTRAINT FK_Historial_Ticket   FOREIGN KEY (TicketId)         REFERENCES dbo.Ticket (TicketId),
    CONSTRAINT FK_Historial_Anterior FOREIGN KEY (EstadoAnteriorId) REFERENCES dbo.EstadoTicket (EstadoId),
    CONSTRAINT FK_Historial_Nuevo    FOREIGN KEY (EstadoNuevoId)    REFERENCES dbo.EstadoTicket (EstadoId),
    CONSTRAINT FK_Historial_Usuario  FOREIGN KEY (UsuarioId)        REFERENCES dbo.Usuario (UsuarioId)
);
GO

/* ============================================================================
   6. AUDITORÍA (bitácora inmutable)
   ============================================================================ */

CREATE TABLE dbo.Auditoria (
    AuditoriaId       BIGINT IDENTITY(1,1)  CONSTRAINT PK_Auditoria PRIMARY KEY,
    InstitucionId     INT                   NULL,
    UsuarioId         INT                   NULL,      -- NULL si el login falló con un correo inexistente
    Accion            NVARCHAR(30)          NOT NULL,
    SeccionSistema    NVARCHAR(30)          NOT NULL,
    ElementoAfectado  NVARCHAR(150)         NULL,      -- INC0010142 · Daniela Arias (EMP-0453) · Categoría: Audiovisual
    Detalle           NVARCHAR(500)         NULL,      -- mensaje armado por el procedimiento almacenado
    Exitoso           BIT                   NOT NULL,
    DireccionIp       VARCHAR(45)           NULL,
    Fecha             DATETIME2(3)          NOT NULL CONSTRAINT DF_Auditoria_Fecha DEFAULT (SYSDATETIME()),
    CONSTRAINT FK_Auditoria_Institucion FOREIGN KEY (InstitucionId) REFERENCES dbo.Institucion (InstitucionId),
    CONSTRAINT FK_Auditoria_Usuario     FOREIGN KEY (UsuarioId)     REFERENCES dbo.Usuario (UsuarioId),
    CONSTRAINT CK_Auditoria_Accion  CHECK (Accion IN (N'Crear', N'Actualizar', N'Desactivar', N'Asignar', N'CambiarEstado', N'InicioSesion')),
    CONSTRAINT CK_Auditoria_Seccion CHECK (SeccionSistema IN (N'Tiquetes', N'Usuarios', N'Catálogos', N'Configuración', N'Seguridad'))
);
GO

-- Los registros de auditoría no se pueden modificar ni eliminar
CREATE TRIGGER dbo.TR_Auditoria_Inmutable
ON dbo.Auditoria
INSTEAD OF UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    THROW 50001, N'Los registros de auditoría no pueden modificarse ni eliminarse.', 1;
END;
GO

/* ============================================================================
   7. ÍNDICES PARA LAS CONSULTAS MÁS FRECUENTES
   ============================================================================ */

CREATE INDEX IX_Usuario_Rol            ON dbo.Usuario (InstitucionId, RolId) INCLUDE (Nombre, Apellidos, Activo);
CREATE INDEX IX_Ticket_Estado          ON dbo.Ticket (InstitucionId, EstadoId) INCLUDE (PrioridadId, CategoriaId, ResponsableId);
CREATE INDEX IX_Ticket_Solicitante     ON dbo.Ticket (SolicitanteId, EstadoId);
CREATE INDEX IX_Ticket_Responsable     ON dbo.Ticket (ResponsableId, EstadoId);
CREATE INDEX IX_Comentario_Ticket      ON dbo.Comentario (TicketId, FechaCreacion);
CREATE INDEX IX_Adjunto_Ticket         ON dbo.Adjunto (TicketId);
CREATE INDEX IX_HistorialEstado_Ticket ON dbo.HistorialEstado (TicketId, Fecha);
CREATE INDEX IX_Auditoria_Fecha        ON dbo.Auditoria (InstitucionId, Fecha DESC);
GO