<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="frmInicioUsuario.aspx.cs" Inherits="PL_Naia_ASPNET.Inicio.frmInicioUsuario" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Inicio · Naia</title>
</head>
<!-- data-roles: qué RolId pueden ver esta página (lo revisa Sesion.js) -->
<body data-roles="1,2" style="font-family: Inter, sans-serif; padding: 2rem;">

    <h1>Mis Tiquetes</h1>
    <p>Hola, <strong class="js-usuario-nombre"></strong> · <span class="js-usuario-universidad"></span></p>
    <p>Correo: <span class="js-usuario-correo"></span></p>
    <a href="#" class="js-cerrar-sesion">Cerrar sesión</a>

    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="../JavaScript/jquery.cookie.js"></script>
    <script src="../JavaScript/Sesion.js"></script>
</body>
</html>
