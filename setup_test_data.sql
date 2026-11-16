-- =====================================================
-- Setup test data for Naia local development
-- Run against NaiaInc database as sa or db_owner
-- =====================================================
USE NaiaInc;
GO

-- Step 1: Ensure Windows Auth user has db_owner
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = '5CD5166KMJ\scasco')
BEGIN
    CREATE USER [5CD5166KMJ\scasco] FOR LOGIN [5CD5166KMJ\scasco];
END
ALTER ROLE db_owner ADD MEMBER [5CD5166KMJ\scasco];
GO

-- Step 2: Insert test institution (UAM)
IF NOT EXISTS (SELECT 1 FROM dbo.Institucion WHERE DominioCorreo = 'uam.cr')
BEGIN
    INSERT INTO dbo.Institucion (PlanId, Nombre, Siglas, DominioCorreo, Activa)
    VALUES (1, N'Universidad Americana', N'UAM', 'uam.cr', 1);
    PRINT 'Institucion UAM insertada.';
END
ELSE
    PRINT 'Institucion UAM ya existe.';
GO

-- Step 3: Insert test department (required by CK_Usuario_CarreraDepto for RolId 3,4)
DECLARE @InstId INT = (SELECT InstitucionId FROM dbo.Institucion WHERE DominioCorreo = 'uam.cr');

IF NOT EXISTS (SELECT 1 FROM dbo.Departamento WHERE InstitucionId = @InstId AND Nombre = N'Soporte TI')
BEGIN
    INSERT INTO dbo.Departamento (InstitucionId, Nombre, Activo)
    VALUES (@InstId, N'Soporte TI', 1);
    PRINT 'Departamento Soporte TI insertado.';
END
ELSE
    PRINT 'Departamento Soporte TI ya existe.';
GO

-- Step 4: Insert admin user (RolId=4 requires DepartamentoId NOT NULL, CarreraId NULL)
DECLARE @InstId2 INT = (SELECT InstitucionId FROM dbo.Institucion WHERE DominioCorreo = 'uam.cr');
DECLARE @DeptoId INT = (SELECT DepartamentoId FROM dbo.Departamento WHERE InstitucionId = @InstId2 AND Nombre = N'Soporte TI');

IF @InstId2 IS NULL OR @DeptoId IS NULL
BEGIN
    PRINT 'ERROR: No se encontro la institucion o el departamento.';
    RETURN;
END

IF NOT EXISTS (SELECT 1 FROM dbo.Usuario WHERE Correo = 'admin@uam.cr')
BEGIN
    INSERT INTO dbo.Usuario
        (InstitucionId, RolId, DepartamentoId, TipoIdentificacionId, Identificacion, NumeroInterno,
         Nombre, Apellidos, Correo, Contrasena, Activo)
    VALUES
        (@InstId2, 4, @DeptoId, 1, '000000001', 'ADM-001',
         N'Admin', N'Naia Test', 'admin@uam.cr', 'Admin123', 1);
    PRINT 'Usuario admin@uam.cr insertado (contrasena: Admin123).';
END
ELSE
    PRINT 'Usuario admin@uam.cr ya existe.';
GO

-- Step 5: Verify
SELECT 'Institucion' AS Tabla, InstitucionId, Nombre, DominioCorreo
FROM dbo.Institucion WHERE DominioCorreo = 'uam.cr';

SELECT 'Departamento' AS Tabla, DepartamentoId, InstitucionId, Nombre
FROM dbo.Departamento WHERE Nombre = N'Soporte TI';

SELECT 'Usuario' AS Tabla, UsuarioId, Nombre, Apellidos, Correo, RolId, DepartamentoId
FROM dbo.Usuario WHERE Correo = 'admin@uam.cr';
GO

PRINT '=== Setup completo ===';
GO
