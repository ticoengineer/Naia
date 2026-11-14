<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="frmPanelAdmin.aspx.cs" Inherits="PL_Naia_ASPNET.Admin.frmPanelAdmin" %>
<%@ Register Src="~/Admin/Secciones/ucUsuarios.ascx" TagPrefix="naia" TagName="Usuarios" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <title>Naia - Prueba Panel Admin (Parte A)</title>
    <link href="CSS/panel.css" rel="stylesheet" />
</head>
<body data-roles="4">
    <form id="form1" runat="server">
        <main style="padding: 20px;">
            <section id="seccion-usuarios" class="seccion">
                <naia:Usuarios runat="server" />
            </section>
        </main>
    </form>

    <!-- Ajusta la ruta de Sesion.js según donde esté en tu proyecto (ej. ../JS/Sesion.js o ~/JS/Sesion.js) -->
    <script src="../JS/Sesion.js"></script>
    <script src="JS/Usuarios.js"></script>
    <script>
// Dispara la carga inicial igual que lo hará Panel.js
window.addEventListener("DOMContentLoaded", function () {
    if (typeof Usuarios_AlAbrir === "function") {
        Usuarios_AlAbrir();
    }
        });
    </script>
</body>
</html>
