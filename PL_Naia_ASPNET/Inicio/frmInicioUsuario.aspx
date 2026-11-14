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
    <link rel="stylesheet" href="CSS/inicio-usuario.css">
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

    <!-- Librerías, sesión y lógica de esta página -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="../JavaScript/jquery.cookie.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="../JavaScript/Sesion.js"></script>
    <script src="JS/InicioUsuario.js"></script>
</body>
</html>
