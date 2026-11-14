<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="frmPanelAdmin.aspx.cs" Inherits="PL_Naia_ASPNET.Admin.frmPanelAdmin" %>
<%@ Register Src="ucUbicaciones.ascx" TagPrefix="uc" TagName="Ubicaciones" %>
<%@ Register Src="ucCategorias.ascx" TagPrefix="uc" TagName="Categorias" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Panel Admin · Naia</title>
    <link rel="stylesheet" href="CSS/panel-admin.css">
</head>
<!-- data-roles: solo RolId 4 (Administrador) puede ver esta pagina -->
<body data-roles="4">
    <form id="form1" runat="server">

        <!-- ====== Barra superior ====== -->
        <header class="topbar">
            <div class="topbar__brand">
                <span class="topbar__logo">N</span>
                <span class="topbar__title">Naia <small>Admin</small></span>
            </div>
            <div class="topbar__user">
                <span class="js-usuario-nombre"></span>
                &middot;
                <span class="js-usuario-universidad"></span>
                &nbsp;|&nbsp;
                <a href="#" class="js-cerrar-sesion topbar__logout">Cerrar sesión</a>
            </div>
        </header>

        <!-- ====== Contenedor principal ====== -->
        <div class="admin-layout">

            <!-- Navegacion lateral -->
            <nav class="admin-nav">
                <h3 class="admin-nav__heading">Secciones</h3>
                <button class="admin-nav__item admin-nav__item--active" type="button"
                        data-seccion="seccionUbicaciones" onclick="panel_Navegar(this)">
                    &#128205; Ubicaciones
                </button>
                <button class="admin-nav__item" type="button"
                        data-seccion="seccionCategorias" onclick="panel_Navegar(this)">
                    &#128278; Categorías
                </button>
            </nav>

            <!-- Area de contenido: aqui se muestran los user controls -->
            <main class="admin-content">
                <uc:Ubicaciones runat="server" ID="ucUbicaciones1" />
                <uc:Categorias  runat="server" ID="ucCategorias1" />
            </main>

        </div>

    </form>

    <!-- ====== Scripts ====== -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="../JavaScript/jquery.cookie.js"></script>
    <script src="../JavaScript/Sesion.js"></script>
    <script src="JS/Panel.js"></script>
    <script src="JS/Ubicaciones.js"></script>
    <script src="JS/Categorias.js"></script>
</body>
</html>
