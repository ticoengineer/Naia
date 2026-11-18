
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="frmPanelAdmin.aspx.cs" Inherits="PL_Naia_ASPNET.Admin.frmPanelAdmin" %>
<%@ Register Src="ucUbicaciones.ascx" TagPrefix="uc" TagName="Ubicaciones" %>
<%@ Register Src="ucCategorias.ascx" TagPrefix="uc" TagName="Categorias" %>
<%@ Register Src="ucAuditoria.ascx" TagPrefix="uc" TagName="Auditoria" %>
<%@ Register Src="ucConfiguracion.ascx" TagPrefix="uc" TagName="Configuracion" %>
<%@ Register Src="ucResumen.ascx" TagPrefix="uc" TagName="Resumen" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Panel Admin · Naia</title>
    <link rel="stylesheet" href="CSS/panel-admin.css">
</head>

<!-- data-roles controla visibilidad en el cliente.
     La autorizacion real debe comprobarse tambien en el servidor. -->
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
                <a href="#"
                   class="js-cerrar-sesion topbar__logout">
                    Cerrar sesión
                </a>
            </div>
        </header>

        <!-- ====== Contenedor principal ====== -->
        <div class="admin-layout">

            <!-- Navegacion lateral -->
            <nav class="admin-nav">
                <h3 class="admin-nav__heading">Secciones</h3>

                <!-- Resumen -->
                <button class="admin-nav__item"
                        type="button"
                        data-seccion="seccionResumen"
                        onclick="panel_Navegar(this)">
                    &#128202; Resumen
                </button>

                <!-- Ubicaciones -->
                <button class="admin-nav__item admin-nav__item--active"
                        type="button"
                        data-seccion="seccionUbicaciones"
                        onclick="panel_Navegar(this)">
                    &#128205; Ubicaciones
                </button>

                <!-- Categorias -->
                <button class="admin-nav__item"
                        type="button"
                        data-seccion="seccionCategorias"
                        onclick="panel_Navegar(this)">
                    &#128278; Categorías
                </button>

                <!-- Auditoria -->
                <button class="admin-nav__item"
                        type="button"
                        data-seccion="seccionAuditoria"
                        onclick="panel_Navegar(this)">
                    &#128203; Auditoría
                </button>

                <!-- Configuracion -->
                <button class="admin-nav__item"
                        type="button"
                        data-seccion="seccionConfiguracion"
                        onclick="panel_Navegar(this)">
                    &#9881; Configuración
                </button>

            </nav>

            <!-- Area de contenido: User Controls -->
            <main class="admin-content">

                <!-- Seccion Resumen -->
                <uc:Resumen
                    runat="server"
                    ID="ucResumen1" />

                <!-- Seccion Ubicaciones -->
                <uc:Ubicaciones
                    runat="server"
                    ID="ucUbicaciones1" />

                <!-- Seccion Categorias -->
                <uc:Categorias
                    runat="server"
                    ID="ucCategorias1" />

                <!-- Seccion Auditoria -->
                <uc:Auditoria
                    runat="server"
                    ID="ucAuditoria1" />

                <!-- Seccion Configuracion -->
                <uc:Configuracion
                    runat="server"
                    ID="ucConfiguracion1" />

            </main>

        </div>

    </form>

    <!-- ====== Scripts ====== -->

    <!-- Librerias -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="../JavaScript/jquery.cookie.js"></script>

    <!-- Control de sesion -->
    <script src="../JavaScript/Sesion.js"></script>

    <!-- Navegacion del panel -->
    <script src="JS/Panel.js"></script>

    <!-- Funcionalidades existentes -->
    <script src="JS/Ubicaciones.js"></script>
    <script src="JS/Categorias.js"></script>

    <!-- Nuestra seccion de Auditoria -->
    <script src="JS/Auditoria.js"></script>

    <!-- Nuestra seccion de Configuracion -->
    <script src="JS/Configuracion.js"></script>

    <!-- Nuestra seccion de Resumen -->
    <script src="JS/Resumen.js"></script>

</body>
</html>
