<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="frmInicioUsuario.aspx.cs" Inherits="PL_Naia_ASPNET.Inicio.frmInicioUsuario" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Inicio · Naia</title>

    <!-- Rutas relativas a /Inicio/ (donde vive esta página) -->
    <link rel="icon" type="image/png" href="Images/favicon.png">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="CSS/inicio-usuario.css?v=2">
</head>

<!-- data-roles: 1 Estudiante · 2 Profesor (lo revisa Sesion.js) -->
<body data-roles="1,2">

    <!-- ===================== ENCABEZADO ===================== -->
    <header class="topbar">
        <div class="topbar__inner">
            <div class="topbar__brand">
                <img class="topbar__logo" src="Images/naia-icon.png" alt="">
                <span class="topbar__name">Naia</span>
                <!-- Sesion.js llena la universidad desde la cookie USRUNV -->
                <span class="topbar__uni js-usuario-universidad"></span>
            </div>

            <div class="topbar__user">
                <!-- InicioUsuario.js calcula las iniciales y el rol -->
                <span class="avatar" id="lblIniciales" aria-hidden="true"></span>
                <div class="topbar__who">
                    <span class="topbar__username js-usuario-nombre"></span>
                    <span class="topbar__role" id="lblRol"></span>
                </div>
                <a href="#" class="btn btn--ghost js-cerrar-sesion">Cerrar sesión</a>
            </div>
        </div>
    </header>

    <main class="page">

        <!-- ===================== BANNER ===================== -->
        <section class="hero">
            <div class="hero__text">
                <h1 class="hero__title">Hola, <span id="lblPrimerNombre"></span>. ¿Algo no funciona?</h1>
                <p class="hero__lead">
                    Cuéntanos qué pasa con tus palabras. No necesitas saber de tecnología:
                    nosotros lo revisamos y te avisamos cada avance.
                </p>
            </div>
            <button type="button" class="btn btn--hero" id="btnReportar" aria-controls="pnlReportar" aria-expanded="false">
                Reportar un problema
            </button>
        </section>

                <!-- ===================== POR CONFIRMAR ===================== -->
        <!-- Tiquetes en EstadoId 5 Resuelto: soporte dice que ya quedó y el usuario tiene que confirmar.
             Solo se muestra si hay alguno. -->
        <section class="section confirmar is-hidden" id="pnlConfirmar" aria-labelledby="ttlConfirmar">
            <div class="confirmar__encabezado">
                <h2 class="section__title" id="ttlConfirmar">Necesitan tu confirmación</h2>
                <span class="confirmar__contador" id="lblTotalConfirmar"></span>
            </div>
            <p class="confirmar__lead">
                Soporte marcó estas solicitudes como resueltas. Revisa la solución y dinos si quedó arreglado;
                si no, la reabrimos.
            </p>
            <div class="ticket-list" id="lstConfirmar"></div>
        </section>

        <!-- ===================== SOLICITUDES ABIERTAS ===================== -->
        <!-- Se llena con InicioUsuario.js → CargarTickets() → SP_LISTAR_TICKETS
             Abiertas = EstadoId 1 Nuevo, 2 Asignado, 3 En progreso, 4 En espera -->
        <section class="section" aria-labelledby="ttlAbiertas">
            <h2 class="section__title" id="ttlAbiertas">Tus solicitudes abiertas</h2>

            <div class="ticket-list" id="lstAbiertas" aria-live="polite">
                <p class="loading">Cargando tus solicitudes…</p>
            </div>

            <!-- Se muestra cuando el usuario no tiene tiquetes abiertos -->
            <div class="empty is-hidden" id="msgSinAbiertas">
                <img src="Images/icon-inbox.png" alt="" aria-hidden="true" width="40" height="40">
                <p>No tienes solicitudes abiertas. Si algo no funciona, usa el botón <strong>Reportar un problema</strong>.</p>
            </div>
        </section>

        <!-- ===================== HISTORIAL ===================== -->
        <!-- Historial = EstadoId 5 Resuelto, 6 Cerrado, 7 Cancelado (mismo SP_LISTAR_TICKETS) -->
        <details class="history is-hidden" id="pnlHistorial">
            <summary class="history__summary">
                <span><strong id="lblTotalHistorial">0</strong> <span id="lblTextoHistorial">solicitudes</span> en tu historial</span>
                <span class="history__toggle">
                    Ver historial
                    <img class="history__chevron" src="Images/icon-chevron-down.png" alt="" aria-hidden="true" width="18" height="18">
                </span>
            </summary>

            <div id="lstHistorial"></div>
        </details>

    </main>

    <!-- ===================== PANEL LATERAL: NUEVO TIQUETE ===================== -->
    <!-- Fondo oscuro: al hacer clic afuera se cierra el panel -->
    <div class="overlay" id="ovlReportar" hidden></div>

    <aside class="drawer" id="pnlReportar" aria-labelledby="ttlReportar" aria-hidden="true">
        <div class="drawer__header">
            <h2 class="drawer__title" id="ttlReportar">Reportar un problema</h2>
            <button type="button" class="drawer__close" id="btnCerrarPanel" aria-label="Cerrar">
                <img src="Images/icon-close.png" alt="" aria-hidden="true" width="20" height="20">
            </button>
        </div>

        <!--
            SP_INSERTA_TICKETS (@InstitucionId, @Titulo, @Descripcion, @CategoriaId, @UbicacionId, @IdUsuarioGlobal, @DireccionIp)
            InstitucionId e IdUsuarioGlobal salen de la sesión (cookies). La prioridad y el estado
            los pone el SP: la prioridad viene de la categoría y el estado inicial es Nuevo.
        -->
        <form class="drawer__form" id="frmNuevoTicket" action="javascript: InsertarTicket()">

            <!-- @Titulo · NVARCHAR(150) -->
            <div class="field">
                <label class="field__label" for="txtTitulo">¿Qué pasa? <span class="required">*</span></label>
                <input class="field__control" type="text" id="txtTitulo" maxlength="150"
                       placeholder="Ej. El proyector del aula 112 no enciende" required>
                <span class="field__hint">Una frase corta, como se lo dirías a un compañero.</span>
            </div>

            <!-- @CategoriaId · SP_LISTAR_CATEGORIAS (@SoloActivas = 1)
                 Cada <option> lleva data-descripcion y data-requiere-fisica (RequiereUbicacionFisica) -->
            <div class="field">
                <label class="field__label" for="cboCategoria">Tipo de problema <span class="required">*</span></label>
                <select class="field__control" id="cboCategoria" required>
                    <option value="">Selecciona una opción</option>
                </select>
                <!-- Muestra la Descripcion de la categoría elegida -->
                <p class="field__info is-hidden" id="lblCategoriaDescripcion">
                    <img src="Images/icon-info.png" alt="" aria-hidden="true" width="16" height="16">
                    <span></span>
                </p>
            </div>

            <!-- @UbicacionId · SP_LISTAR_UBICACIONES (@SoloActivas = 1)
                 Se agrupan con <optgroup> "En el campus" (EsFisica = 1) y "En línea" (EsFisica = 0).
                 Si la categoría requiere ubicación física, el JS oculta las virtuales. -->
            <div class="field">
                <label class="field__label" for="cboUbicacion">¿Dónde ocurre? <span class="required">*</span></label>
                <select class="field__control" id="cboUbicacion" required>
                    <option value="">Selecciona una opción</option>
                </select>
                <span class="field__hint is-hidden" id="lblRequiereFisica">Este tipo de problema necesita un lugar del campus.</span>
            </div>

            <!-- @Descripcion · NVARCHAR(2000) -->
            <div class="field">
                <label class="field__label" for="txtDescripcion">Cuéntanos más <span class="required">*</span></label>
                <textarea class="field__control field__control--area" id="txtDescripcion" rows="6" maxlength="2000"
                          placeholder="¿Qué estabas haciendo? ¿Desde cuándo pasa? ¿Aparece algún mensaje?" required></textarea>
                <span class="field__counter"><span id="lblContador">0</span> / 2000</span>
            </div>

            <div class="drawer__actions">
                <button type="button" class="btn btn--secondary" id="btnCancelarTicket">Cancelar</button>
                <button type="submit" class="btn btn--primary btn--grow" id="btnEnviarTicket">Enviar solicitud</button>
            </div>
        </form>
    </aside>

        <!-- ===================== PANEL LATERAL: VER Y RESPONDER ===================== -->
    <!-- Lo llena InicioUsuario.js → AbrirDetalle() → WebMethod VerTicket -->
    <aside class="drawer drawer--wide" id="pnlDetalle" aria-labelledby="lblDetTitulo" aria-hidden="true">
        <div class="drawer__header drawer__header--top">
            <div class="detalle__head">
                <div class="detalle__meta">
                    <span id="lblDetNumero"></span>
                    <span class="estado" id="lblDetEstado"></span>
                </div>
                <h2 class="drawer__title" id="lblDetTitulo">Cargando…</h2>
            </div>
            <button type="button" class="drawer__close" id="btnCerrarDetalle" aria-label="Cerrar">
                <img src="Images/icon-close.png" alt="" aria-hidden="true" width="20" height="20">
            </button>
        </div>

        <div class="drawer__body" id="pnlDetalleCuerpo">

            <!-- Datos del tiquete -->
            <div class="ticket__data detalle__datos">
                <div><span class="ticket__data-label">Tipo de problema</span><span class="ticket__data-value" id="lblDetCategoria"></span></div>
                <div><span class="ticket__data-label">¿Dónde ocurre?</span><span class="ticket__data-value" id="lblDetUbicacion"></span></div>
                <div><span class="ticket__data-label">Prioridad</span><span class="ticket__data-value" id="lblDetPrioridad"></span></div>
                <div><span class="ticket__data-label">Técnico asignado</span><span class="ticket__data-value" id="lblDetResponsable"></span></div>
            </div>

            <div class="ticket__block">
                <span class="ticket__label" id="lblDetFecha"></span>
                <p class="detalle__descripcion" id="lblDetDescripcion"></p>
            </div>

            <!-- Solo si está Resuelto (EstadoId = 5) -->
            <div class="solucion is-hidden" id="boxSolucion">
                <strong class="solucion__titulo">Soporte marcó tu solicitud como resuelta</strong>
                <p class="solucion__texto" id="lblDetSolucion"></p>
                <span class="solucion__pregunta">¿Se resolvió tu problema?</span>
                <div class="solucion__acciones" id="accionesSolucion"></div>
            </div>

            <!-- Conversación -->
            <div class="conversacion">
                <span class="conversacion__titulo">Conversación</span>
                <div class="conversacion__lista" id="lstConversacion"></div>
            </div>
        </div>

        <div class="drawer__footer">
            <!-- Responder (solo si PuedeComentar = 1) -->
            <form class="responder is-hidden" id="frmResponder" action="javascript: ResponderTicket()">
                <label class="field__label" for="txtRespuesta">Responder</label>
                <textarea class="field__control field__control--area responder__texto" id="txtRespuesta" rows="3" maxlength="500"
                          placeholder="Escribe tu mensaje para soporte…" required></textarea>
                <div class="responder__fila">
                    <span class="field__counter"><span id="lblContadorRespuesta">0</span> / 500</span>
                    <button type="submit" class="btn btn--primary" id="btnResponder">Enviar</button>
                </div>
            </form>

            <!-- Si ya no se puede comentar -->
            <p class="detalle__cerrado is-hidden" id="msgDetalleCerrado">Esta solicitud está cerrada; ya no se pueden enviar mensajes.</p>

            <!-- Otros botones de estado (ej. Cancelar esta solicitud) -->
            <div class="detalle__acciones" id="accionesFooter"></div>
        </div>
    </aside>

    <!-- Librerías, sesión y lógica de esta página -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="../JavaScript/jquery.cookie.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="../JavaScript/Sesion.js?v=2"></script>
    <script src="JS/InicioUsuario.js?v=3"></script>
</body>
</html>
