
<%@ Page Language="C#" AutoEventWireup="true"
    CodeBehind="frmPanelAdmin.aspx.cs"
    Inherits="PL_Naia_ASPNET.Admin.frmPanelAdmin" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    <title>Panel del administrador | Naia</title>

    <link rel="stylesheet" href="CSS/panel.css" />
</head>

<body data-roles="4">

    <form id="form1" runat="server">

        <div class="panel-admin">

            <!-- MENÚ LATERAL -->
            <aside class="panel-sidebar">

                <div class="panel-logo">
                    <span>✦</span> Naia
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

                    <div class="panel-universidad" id="panel-nombreUniversidad">
                        Universidad
                    </div>

                    <div class="panel-usuario">

                        <span id="panel-nombreAdmin">
                            Administrador
                        </span>

                        <!-- Se conectará al cierre de sesión existente -->
                        <span id="panel-cerrarSesion">
                            Cerrar sesión
                        </span>

                    </div>

                </header>

                <!-- CONTENIDO DE LAS SECCIONES -->
                <div class="panel-contenido">

                    <section id="seccion-resumen" class="panel-seccion seccion">
                        <h1>Resumen general</h1>
                        <p>
                            Indicadores generales de la universidad,
                            tiquetes y usuarios activos.
                        </p>
                    </section>

                    <section id="seccion-tiquetes" class="panel-seccion seccion" hidden>
                        <h1>Tiquetes</h1>
                        <p>Sección pendiente de integración.</p>
                    </section>

                    <section id="seccion-usuarios" class="panel-seccion seccion" hidden>
                        <h1>Usuarios</h1>
                        <p>Sección pendiente de integración.</p>
                    </section>

                    <section id="seccion-carreras" class="panel-seccion seccion" hidden>
                        <h1>Carreras</h1>
                        <p>Sección pendiente de integración.</p>
                    </section>

                    <section id="seccion-departamentos" class="panel-seccion seccion" hidden>
                        <h1>Departamentos</h1>
                        <p>Sección pendiente de integración.</p>
                    </section>

                    <section id="seccion-equipos" class="panel-seccion seccion" hidden>
                        <h1>Equipos de soporte</h1>
                        <p>Sección pendiente de integración.</p>
                    </section>

                    <section id="seccion-ubicaciones" class="panel-seccion seccion" hidden>
                        <h1>Ubicaciones</h1>
                        <p>Sección pendiente de integración.</p>
                    </section>

                    <section id="seccion-categorias" class="panel-seccion seccion" hidden>
                        <h1>Categorías</h1>
                        <p>Sección pendiente de integración.</p>
                    </section>

                    <section id="seccion-auditoria" class="panel-seccion seccion" hidden>
                        <h1>Auditoría</h1>
                        <p>
                            Consulta de movimientos y actividades
                            registradas en el sistema.
                        </p>
                    </section>

                    <section id="seccion-configuracion" class="panel-seccion seccion" hidden>
                        <h1>Configuración</h1>
                        <p>
                            Administración de los datos y del plan
                            de suscripción de la universidad.
                        </p>
                    </section>

                </div>

            </main>

        </div>

        </form>

    <script src="JS/Panel.js"></script>

</body>
</html>
