<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="frmInicioSoporte.aspx.cs" Inherits="PL_Naia_ASPNET.Inicio.frmInicioSoporte" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Soporte · Naia</title>

    <!-- Rutas relativas a /Inicio/ (donde vive esta página) -->
    <link rel="icon" type="image/png" href="Images/favicon.png">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <!-- Base compartida con el inicio de usuario (encabezado, panel lateral, botones, chat) -->
    <link rel="stylesheet" href="CSS/inicio-usuario.css?v=2">
    <!-- Lo propio de soporte (tarjetas, tabla, panel de dos columnas) -->
    <link rel="stylesheet" href="CSS/inicio-soporte.css?v=1">
</head>

<!-- data-roles: 3 Soporte técnico · 4 Administrativo (lo revisa Sesion.js) -->
<body data-roles="3,4">

    <!-- ===================== ENCABEZADO ===================== -->
    <header class="topbar">
        <div class="topbar__inner topbar__inner--ancho">
            <div class="topbar__brand">
                <img class="topbar__logo" src="Images/naia-icon.png" alt="">
                <span class="topbar__name">Naia</span>
                <span class="topbar__uni js-usuario-universidad"></span>
            </div>

            <div class="topbar__user">
                <span class="avatar" id="lblIniciales" aria-hidden="true"></span>
                <div class="topbar__who">
                    <span class="topbar__username js-usuario-nombre"></span>
                    <span class="topbar__role" id="lblRol"></span>
                </div>
                <a href="#" class="btn btn--ghost js-cerrar-sesion">Cerrar sesión</a>
            </div>
        </div>
    </header>

    <main class="page page--ancha">

        <!-- ===================== TARJETAS ===================== -->
        <!-- InicioSoporte.js → CargarResumen() → WebMethod ResumenSoporte → SP_DASHBOARD_TICKETS -->
        <section class="kpis" aria-label="Resumen">
            <div class="kpi">
                <span class="kpi__label">Sin asignar</span>
                <span class="kpi__valor kpi__valor--azul" id="lblKpiSinAsignar">–</span>
            </div>
            <div class="kpi">
                <span class="kpi__label">Mis tiquetes abiertos</span>
                <span class="kpi__valor" id="lblKpiMios">–</span>
            </div>
            <div class="kpi">
                <span class="kpi__label">Vencen hoy</span>
                <span class="kpi__valor kpi__valor--ambar" id="lblKpiVencenHoy">–</span>
            </div>
            <div class="kpi kpi--alerta">
                <span class="kpi__label">SLA vencido</span>
                <span class="kpi__valor" id="lblKpiVencidos">–</span>
            </div>
        </section>

        <!-- ===================== BANDEJA ===================== -->
        <!-- InicioSoporte.js → CargarBandeja() → WebMethod FiltrarTickets → SP_FILTRAR_TICKETS -->
        <section class="bandeja">
            <div class="bandeja__barra">
                <!-- Pestañas: cambian el filtro de responsable -->
                <div class="tabs" role="tablist" aria-label="Qué tiquetes ver">
                    <button type="button" class="tab is-active" role="tab" aria-selected="true" data-vista="sinasignar">
                        Sin asignar <span class="tab__num" id="lblTabSinAsignar"></span>
                    </button>
                    <button type="button" class="tab" role="tab" aria-selected="false" data-vista="mios">
                        Mis tiquetes <span class="tab__num" id="lblTabMios"></span>
                    </button>
                    <button type="button" class="tab" role="tab" aria-selected="false" data-vista="todos">
                        Todos
                    </button>
                </div>

                <!-- Filtros -->
                <div class="filtros">
                    <label class="sr-only" for="txtBuscar">Buscar</label>
                    <input class="field__control filtros__buscar" type="search" id="txtBuscar" maxlength="100"
                           placeholder="Buscar número, título o solicitante…">

                    <label class="filtros__item" for="cboFiltroPrioridad">Prioridad
                        <select class="field__control filtros__select" id="cboFiltroPrioridad">
                            <option value="">Todas</option>
                        </select>
                    </label>

                    <label class="filtros__check">
                        <input type="checkbox" id="chkSoloVencidos"> Solo vencidos
                    </label>
                </div>
            </div>

            <div class="tabla-wrap">
                <table class="tabla">
                    <thead>
                        <tr>
                            <th scope="col">Número</th>
                            <th scope="col">Problema</th>
                            <th scope="col">Categoría</th>
                            <th scope="col">Prioridad</th>
                            <th scope="col">Estado</th>
                            <th scope="col">Vence</th>
                            <th scope="col"><span class="sr-only">Acciones</span></th>
                        </tr>
                    </thead>
                    <tbody id="tblTickets">
                        <tr><td colspan="7" class="tabla__vacia">Cargando tiquetes…</td></tr>
                    </tbody>
                </table>
            </div>
        </section>

    </main>

    <!-- ===================== PANEL LATERAL: DETALLE ===================== -->
    <div class="overlay" id="ovlDetalle" hidden></div>

    <aside class="drawer drawer--soporte" id="pnlDetalle" aria-labelledby="lblDetTitulo" aria-hidden="true">
        <div class="drawer__header drawer__header--top">
            <div class="detalle__head">
                <div class="detalle__meta">
                    <span id="lblDetNumero"></span>
                    <span class="estado" id="lblDetEstado"></span>
                    <span class="sla is-hidden" id="lblDetSlaChip"></span>
                </div>
                <h2 class="drawer__title" id="lblDetTitulo">Cargando…</h2>
                <span class="detalle__solicitante" id="lblDetSolicitante"></span>
            </div>
            <button type="button" class="drawer__close" id="btnCerrarDetalle" aria-label="Cerrar">
                <img src="Images/icon-close.png" alt="" aria-hidden="true" width="20" height="20">
            </button>
        </div>

        <div class="drawer__columnas">

            <!-- ---------- Columna izquierda: descripción, conversación y acciones ---------- -->
            <div class="drawer__principal">
                <div class="drawer__body" id="pnlDetalleCuerpo">

                    <div class="ticket__block">
                        <span class="ticket__label" id="lblDetFecha"></span>
                        <p class="detalle__descripcion" id="lblDetDescripcion"></p>
                    </div>

                    <div class="conversacion">
                        <span class="conversacion__titulo">Conversación</span>
                        <div class="conversacion__lista" id="lstConversacion"></div>
                    </div>

                    <!-- Solución ya registrada (Resuelto / Cerrado): solo lectura -->
                    <div class="solucion is-hidden" id="boxSolucionLeida">
                        <strong class="solucion__titulo">Solución registrada</strong>
                        <p class="solucion__texto" id="lblDetSolucion"></p>
                    </div>

                    <!-- Escribir la solución: solo si la BD permite pasar a 5 Resuelto -->
                    <div class="solucion solucion--editar is-hidden" id="boxSolucionEditar">
                        <label class="solucion__titulo" for="txtSolucion">Solución (para marcar como resuelto)</label>
                        <textarea class="field__control field__control--area solucion__texto-area" id="txtSolucion" rows="3" maxlength="2000"
                                  placeholder="Qué hiciste para resolverlo…"></textarea>
                    </div>
                </div>

                <div class="drawer__footer">
                    <form class="responder responder--linea is-hidden" id="frmResponder" action="javascript: ResponderTicket()">
                        <label class="sr-only" for="txtRespuesta">Mensaje</label>
                        <input class="field__control" type="text" id="txtRespuesta" maxlength="500"
                               placeholder="Escribe un mensaje para el usuario…" required>
                        <button type="submit" class="btn btn--primary" id="btnResponder">Enviar</button>
                    </form>

                    <p class="detalle__cerrado is-hidden" id="msgDetalleCerrado">Este tiquete está cerrado; ya no se pueden enviar mensajes.</p>

                    <!-- Tomar / En progreso / En espera / Resolver / Cancelar (los decide la BD) -->
                    <div class="detalle__acciones" id="accionesFooter"></div>
                </div>
            </div>

            <!-- ---------- Columna derecha: datos del tiquete ---------- -->
            <div class="datos" aria-label="Datos del tiquete">
                <div class="datos__item">
                    <span class="datos__label">Estado</span>
                    <span class="estado" id="lblDetEstado2"></span>
                </div>

                <div class="datos__item" id="boxTiempo">
                    <span class="datos__label">Tiempo restante</span>
                    <span class="datos__tiempo" id="lblDetTiempo"></span>
                    <div class="barra"><div class="barra__relleno" id="barSla"></div></div>
                    <span class="datos__nota" id="lblDetPlazo"></span>
                </div>

                <div class="field field--compacto">
                    <label class="datos__label" for="cboDetPrioridad">Prioridad</label>
                    <select class="field__control" id="cboDetPrioridad"></select>
                </div>

                <div class="field field--compacto">
                    <label class="datos__label" for="cboDetResponsable">Responsable</label>
                    <select class="field__control" id="cboDetResponsable"></select>
                </div>

                <div class="field field--compacto">
                    <label class="datos__label" for="cboDetCategoria">Categoría</label>
                    <select class="field__control" id="cboDetCategoria"></select>
                </div>

                <div class="field field--compacto">
                    <label class="datos__label" for="cboDetUbicacion">Ubicación</label>
                    <select class="field__control" id="cboDetUbicacion"></select>
                    <span class="field__hint is-hidden" id="lblDetRequiereFisica">Esta categoría necesita un lugar del campus.</span>
                </div>

                <button type="button" class="btn btn--primary" id="btnGuardarCambios">Guardar cambios</button>

                <div class="datos__item">
                    <span class="datos__label">Correo del usuario</span>
                    <span class="datos__valor" id="lblDetCorreo"></span>
                </div>
            </div>
        </div>
    </aside>

    <!-- Librerías, sesión y lógica de esta página -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="../JavaScript/jquery.cookie.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="../JavaScript/Sesion.js?v=2"></script>
    <script src="JS/InicioSoporte.js?v=1"></script>
</body>
</html>
