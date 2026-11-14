// =====================================================================================
// INICIO DE USUARIO · InicioUsuario.js   (Estudiante / Profesor)
// Flujo de la lista: CargarTickets() → WebMethod ListarTickets → BLL → SP_LISTAR_TICKETS
// Flujo del detalle: al abrir una fila → WebMethod DetalleTicket → SP_INFO_TICKET + SP_LISTAR_COMENTARIOS
// Usa g_UsuarioId, g_InstitucionId y g_RolId de Sesion.js
// =====================================================================================

// Estados que se consideran "abiertos" (el resto va al historial)
var ESTADOS_ABIERTOS = [1, 2, 3, 4];   // Nuevo, Asignado, En progreso, En espera

$(document).ready(function () {

    // ---------- Datos del usuario en el encabezado ----------
    var nombreCompleto = $.cookie('USRNOM') || "";
    var partes = nombreCompleto.trim().split(" ");
    var iniciales = (partes[0] ? partes[0].charAt(0) : "") + (partes[1] ? partes[1].charAt(0) : "");

    $("#lblIniciales").text(iniciales.toUpperCase());
    $("#lblPrimerNombre").text(partes[0] || "");
    $("#lblRol").text(g_RolId == "2" ? "Profesor" : "Estudiante");

    // ---------- Panel lateral ----------
    $("#btnReportar").on("click", AbrirPanel);
    $("#btnCerrarPanel, #btnCancelarTicket, #ovlReportar").on("click", CerrarPanel);

    $(document).on("keydown", function (e) {
        if (e.key === "Escape" && $("#pnlReportar").hasClass("is-open")) {
            CerrarPanel();
        }
    });

    // ---------- Contador de caracteres de la descripción ----------
    $("#txtDescripcion").on("input", function () {
        $("#lblContador").text($(this).val().length);
    });

    // ---------- Al elegir categoría: descripción + filtrar ubicaciones ----------
    $("#cboCategoria").on("change", function () {
        var opcion = $(this).find("option:selected");
        var descripcion = opcion.data("descripcion");
        var requiereFisica = String(opcion.data("requiere-fisica")) === "1" || String(opcion.data("requiere-fisica")) === "true";

        if (descripcion) {
            $("#lblCategoriaDescripcion span").text(descripcion);
            $("#lblCategoriaDescripcion").removeClass("is-hidden");
        } else {
            $("#lblCategoriaDescripcion").addClass("is-hidden");
        }

        $("#cboUbicacion optgroup[data-fisica='0']").prop("hidden", requiereFisica).prop("disabled", requiereFisica);
        $("#lblRequiereFisica").toggleClass("is-hidden", !requiereFisica);

        if (requiereFisica && $("#cboUbicacion option:selected").closest("optgroup").data("fisica") == 0) {
            $("#cboUbicacion").val("");
        }
    });

    // ---------- Detalle: se pide a la BD solo la primera vez que se abre una fila ----------
    // El evento "toggle" de <details> no "burbujea", por eso se escucha en modo captura (true)
    document.getElementById("lstAbiertas").addEventListener("toggle", function (e) {
        var fila = e.target;
        if (fila.open && fila.dataset.cargado !== "1") {
            CargarDetalleTicket(fila);
        }
    }, true);

    // ---------- Carga inicial ----------
    CargarTickets();
    // PENDIENTE: CargarCategorias();   → SP_LISTAR_CATEGORIAS (@SoloActivas = 1)
    // PENDIENTE: CargarUbicaciones();  → SP_LISTAR_UBICACIONES (@SoloActivas = 1)
});


// =====================================================================================
// LISTA DE TIQUETES
// =====================================================================================
function CargarTickets() {
    // EL ORDEN IMPORTA: el WebMethod lo lee por posición
    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;   // @InstitucionId
    obj_Parametros_JS[1] = g_UsuarioId;       // @IdUsuarioGlobal

    jQuery.ajax({
        type: "POST",
        url: "frmInicioUsuario.aspx/ListarTickets",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            var tickets = msg.d || [];

            var abiertos = $.grep(tickets, function (t) { return ESTADOS_ABIERTOS.indexOf(parseInt(t.EstadoId)) !== -1; });
            var historial = $.grep(tickets, function (t) { return ESTADOS_ABIERTOS.indexOf(parseInt(t.EstadoId)) === -1; });

            PintarAbiertos(abiertos);
            PintarHistorial(historial);
        },
        error: function () {
            $("#lstAbiertas").html('<p class="loading loading--error">No se pudieron cargar tus solicitudes. Recarga la página para intentarlo de nuevo.</p>');
        }
    });
}

// Una fila desplegable (<details>) por cada tiquete abierto
function PintarAbiertos(tickets) {
    if (tickets.length === 0) {
        $("#lstAbiertas").empty();
        $("#msgSinAbiertas").removeClass("is-hidden");
        return;
    }

    $("#msgSinAbiertas").addClass("is-hidden");
    var html = "";

    $.each(tickets, function (i, t) {
        html +=
            '<details class="ticket" data-ticket-id="' + t.TicketId + '">' +
                '<summary class="ticket__summary">' +
                    '<span class="ticket__main">' +
                        '<span class="ticket__meta">' + Esc(t.Numero) + ' · ' + Esc(t.Categoria) + ' · ' + Esc(t.FechaCreacion) + '</span>' +
                        '<span class="ticket__title">' + Esc(t.Titulo) + '</span>' +
                    '</span>' +
                    '<span class="estado estado--' + t.EstadoId + '">' + Esc(t.Estado) + '</span>' +
                    '<img class="ticket__chevron" src="Images/icon-chevron-down.png" alt="" aria-hidden="true" width="20" height="20">' +
                '</summary>' +
                '<div class="ticket__body">' +
                    '<div class="ticket__data">' +
                        '<div><span class="ticket__data-label">¿Dónde ocurre?</span><span class="ticket__data-value">' + Esc(t.Ubicacion) + '</span></div>' +
                        '<div><span class="ticket__data-label">Prioridad</span><span class="ticket__data-value">' + Esc(t.Prioridad) + '</span></div>' +
                        '<div><span class="ticket__data-label">Técnico asignado</span><span class="ticket__data-value">' + Esc(t.Responsable) + '</span></div>' +
                        '<div><span class="ticket__data-label">Equipo</span><span class="ticket__data-value js-equipo">—</span></div>' +
                    '</div>' +
                    '<div class="ticket__block">' +
                        '<span class="ticket__label">Lo que reportaste</span>' +
                        '<p class="ticket__text js-descripcion">Cargando…</p>' +
                    '</div>' +
                    '<div class="ticket__message is-hidden js-mensaje">' +
                        '<span class="ticket__label js-mensaje-autor"></span>' +
                        '<p class="ticket__text js-mensaje-texto"></p>' +
                    '</div>' +
                    '<div class="ticket__actions">' +
                        // PENDIENTE: página de detalle / conversación del tiquete
                        '<a class="btn btn--primary" href="#" data-ticket-id="' + t.TicketId + '">Ver y responder</a>' +
                    '</div>' +
                '</div>' +
            '</details>';
    });

    $("#lstAbiertas").html(html);
}

// Filas simples del historial (resueltos, cerrados y cancelados)
function PintarHistorial(tickets) {
    if (tickets.length === 0) {
        $("#pnlHistorial").addClass("is-hidden");
        return;
    }

    $("#lblTotalHistorial").text(tickets.length);
    $("#lblTextoHistorial").text(tickets.length === 1 ? "solicitud" : "solicitudes");
    $("#pnlHistorial").removeClass("is-hidden");

    var html = "";
    $.each(tickets, function (i, t) {
        html +=
            '<div class="history__row">' +
                '<span class="history__number">' + Esc(t.Numero) + '</span>' +
                '<span class="history__title">' + Esc(t.Titulo) + '</span>' +
                '<span class="history__info">' + Esc(t.Categoria) + '</span>' +
                '<span class="estado estado--' + t.EstadoId + '">' + Esc(t.Estado) + '</span>' +
                // PENDIENTE: página de detalle del tiquete
                '<a class="link" href="#" data-ticket-id="' + t.TicketId + '">Ver detalle</a>' +
            '</div>';
    });

    $("#lstHistorial").html(html);
}


// =====================================================================================
// DETALLE DE UN TIQUETE (al abrir la fila)
// =====================================================================================
function CargarDetalleTicket(fila) {
    var $fila = $(fila);

    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;          // @InstitucionId
    obj_Parametros_JS[1] = $fila.data("ticket-id");  // @TicketId
    obj_Parametros_JS[2] = g_UsuarioId;              // @IdUsuarioGlobal

    jQuery.ajax({
        type: "POST",
        url: "frmInicioUsuario.aspx/DetalleTicket",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            var d = msg.d;

            if (!d || !d.Descripcion) {
                $fila.find(".js-descripcion").text("No se pudo cargar el detalle.");
                return;
            }

            fila.dataset.cargado = "1";   // ya no se vuelve a pedir
            $fila.find(".js-descripcion").text(d.Descripcion);
            $fila.find(".js-equipo").text(d.Equipo || "—");

            if (d.UltimoMensaje) {
                $fila.find(".js-mensaje-autor").text("Último mensaje · " + d.UltimoAutor + " · " + d.UltimaFecha);
                $fila.find(".js-mensaje-texto").text(d.UltimoMensaje);
                $fila.find(".js-mensaje").removeClass("is-hidden");
            }
        },
        error: function () {
            $fila.find(".js-descripcion").text("No se pudo cargar el detalle.");
        }
    });
}


// =====================================================================================
// PANEL LATERAL
// =====================================================================================
function AbrirPanel() {
    $("#ovlReportar").prop("hidden", false);
    setTimeout(function () { $("#ovlReportar").addClass("is-open"); }, 10);

    $("#pnlReportar").addClass("is-open").attr("aria-hidden", "false");
    $("#btnReportar").attr("aria-expanded", "true");
    $("body").addClass("no-scroll");

    setTimeout(function () { $("#txtTitulo").trigger("focus"); }, 350);
}

function CerrarPanel() {
    $("#ovlReportar").removeClass("is-open");
    setTimeout(function () { $("#ovlReportar").prop("hidden", true); }, 300);

    $("#pnlReportar").removeClass("is-open").attr("aria-hidden", "true");
    $("#btnReportar").attr("aria-expanded", "false").trigger("focus");
    $("body").removeClass("no-scroll");
}

function LimpiarFormulario() {
    $("#frmNuevoTicket")[0].reset();
    $("#lblContador").text("0");
    $("#lblCategoriaDescripcion, #lblRequiereFisica").addClass("is-hidden");
    $("#cboUbicacion optgroup").prop("hidden", false).prop("disabled", false);
}

// Se ejecuta al enviar el formulario (action="javascript: InsertarTicket()")
function InsertarTicket() {
    // PENDIENTE: WebMethod que ejecuta SP_INSERTA_TICKETS.
    //   [0] InstitucionId · [1] Titulo · [2] Descripcion · [3] CategoriaId · [4] UbicacionId · [5] IdUsuarioGlobal
    // Al responder con éxito: Swal, LimpiarFormulario(), CerrarPanel() y CargarTickets().
    LimpiarFormulario();
    CerrarPanel();
}


// =====================================================================================
// UTILIDADES
// =====================================================================================

// Escapa el texto antes de meterlo en el HTML. Los títulos los escriben los usuarios:
// sin esto, alguien podría escribir <script> en un tiquete y se ejecutaría en la página.
function Esc(texto) {
    return $("<div>").text(texto == null ? "" : String(texto)).html();
}
