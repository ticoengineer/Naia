<%@ Page Language="C#" AutoEventWireup="true"
    CodeBehind="frmPanelAdmin.aspx.cs"
    Inherits="PL_Naia_ASPNET.Admin.frmPanelAdmin" %>

<%@ Register Src="~/Admin/ucUbicaciones.ascx" TagPrefix="naia" TagName="Ubicaciones" %>
<%@ Register Src="~/Admin/ucCategorias.ascx" TagPrefix="naia" TagName="Categorias" %>
<%@ Register Src="~/Admin/ucCarreras.ascx" TagPrefix="naia" TagName="Carreras" %>
<%@ Register Src="~/Admin/ucDepartamentos.ascx" TagPrefix="naia" TagName="Departamentos" %>
<%@ Register Src="~/Admin/ucEquipos.ascx" TagPrefix="naia" TagName="Equipos" %>
<%@ Register Src="~/Admin/ucUsuarios.ascx" TagPrefix="naia" TagName="Usuarios" %>
<%@ Register Src="~/Admin/ucAuditoria.ascx" TagPrefix="naia" TagName="Auditoria" %>
<%@ Register Src="~/Admin/ucConfiguracion.ascx" TagPrefix="naia" TagName="Configuracion" %>
<%@ Register Src="~/Admin/ucResumen.ascx" TagPrefix="naia" TagName="Resumen" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    <title>Panel del administrador | Naia</title>

    <link rel="stylesheet" href="CSS/panel.css" />
    <link rel="stylesheet" href="CSS/panel-admin.css?v=3" />
</head>

<!-- data-roles: 4 Administrativo (lo revisa Sesion.js) -->
<body data-roles="4">

    <form id="form1" runat="server">

        <div class="panel-admin">

            <!-- MENÚ LATERAL -->
            <aside class="panel-sidebar">

                <div class="panel-logo">
                    <img src="Images/naia-icon.png" alt="Naia" width="24" height="24" style="vertical-align: middle;" /> Naia
                </div>

                <nav class="panel-menu" aria-label="Menú del administrador">

                    <a href="#resumen" class="activo" data-seccion="resumen">
                        Resumen
                    </a>

                    <a href="#tiquetes" data-seccion="tiquetes">
                        Tiquetes
                    </a>

                    <a href="#usuarios" data-seccion="usuarios">
                        Usuarios
                    </a>

                    <div class="panel-menu-titulo">
                        CATÁLOGOS
                    </div>

                    <a href="#carreras" data-seccion="carreras">
                        Carreras
                    </a>

                    <a href="#departamentos" data-seccion="departamentos">
                        Departamentos
                    </a>

                    <a href="#equipos" data-seccion="equipos">
                        Equipos de soporte
                    </a>

                    <a href="#ubicaciones" data-seccion="ubicaciones">
                        Ubicaciones
                    </a>

                    <a href="#categorias" data-seccion="categorias">
                        Categorías
                    </a>

                    <div class="panel-menu-titulo">
                        SISTEMA
                    </div>

                    <a href="#auditoria" data-seccion="auditoria">
                        Auditoría
                    </a>

                    <a href="#configuracion" data-seccion="configuracion">
                        Configuración
                    </a>

                </nav>

            </aside>

            <!-- ÁREA PRINCIPAL -->
            <main class="panel-principal">

                <!-- BARRA SUPERIOR -->
                <header class="panel-header">

                    <!-- Sesion.js llena la universidad desde la cookie USRUNV -->
                    <div class="panel-universidad js-usuario-universidad" id="panel-nombreUniversidad">
                        Universidad
                    </div>

                    <div class="panel-usuario">

                        <!-- Sesion.js llena el nombre desde la cookie USRNOM -->
                        <span id="panel-nombreAdmin" class="js-usuario-nombre">
                            Administrador
                        </span>

                        <!-- Sesion.js conecta este enlace con CerrarSesion() (clase js-cerrar-sesion) -->
                        <a href="#" id="panel-cerrarSesion" class="js-cerrar-sesion"
                           style="color: inherit; text-decoration: none; cursor: pointer;">
                            Cerrar sesión
                        </a>

                    </div>

                </header>

                <!-- CONTENIDO DE LAS SECCIONES -->
                <div class="panel-contenido">

                    <section id="seccion-resumen" class="panel-seccion seccion">
                        <naia:Resumen runat="server" />
                    </section>

                    <section id="seccion-tiquetes" class="panel-seccion seccion" hidden>
                        <h1>Tiquetes</h1>
                        <p>Sección pendiente de integración.</p>
                    </section>

                    <section id="seccion-usuarios" class="panel-seccion seccion" hidden>
                        <naia:Usuarios runat="server" />
                    </section>

                    <section id="seccion-carreras" class="panel-seccion seccion" hidden>
                        <naia:Carreras runat="server" />
                    </section>

                    <section id="seccion-departamentos" class="panel-seccion seccion" hidden>
                        <naia:Departamentos runat="server" />
                    </section>

                    <section id="seccion-equipos" class="panel-seccion seccion" hidden>
                        <naia:Equipos runat="server" />
                    </section>

                    <section id="seccion-ubicaciones" class="panel-seccion seccion" hidden>
                        <naia:Ubicaciones runat="server" />
                    </section>

                    <section id="seccion-categorias" class="panel-seccion seccion" hidden>
                        <naia:Categorias runat="server" />
                    </section>

                    <section id="seccion-auditoria" class="panel-seccion seccion" hidden>
                        <naia:Auditoria runat="server" />
                    </section>

                    <section id="seccion-configuracion" class="panel-seccion seccion" hidden>
                        <naia:Configuracion runat="server" />
                    </section>

                </div>

            </main>

        </div>

    </form>

    <!-- Librerías externas (SweetAlert va ANTES de Sesion.js porque Sesion.js lo usa) -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="../JavaScript/jquery.cookie.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<!-- Sesión: valida cookies, rol, datos del usuario y cierre de sesión -->
<script src="../JavaScript/Sesion.js?v=2"></script>

<!-- Scripts de secciones -->
<script src="JS/Ubicaciones.js?v=2"></script>
<script src="JS/Categorias.js?v=2"></script>
<script src="JS/Carreras.js?v=3"></script>
<script src="JS/Departamentos.js?v=3"></script>
<script src="JS/Equipos.js?v=5"></script>
<script src="JS/Usuarios.js?v=3"></script>
<script src="JS/Auditoria.js?v=3"></script>
<script src="JS/Configuracion.js?v=3"></script>
<script src="JS/Resumen.js?v=3"></script>
<script src="JS/Panel.js"></script>

</body>
</html>