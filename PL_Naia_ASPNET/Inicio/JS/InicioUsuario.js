// =====================================================================================
// INICIO DE USUARIO · InicioUsuario.js   (Estudiante / Profesor)
// Flujo de la lista: CargarTickets() → WebMethod ListarTickets → BLL → SP_LISTAR_TICKETS
// Flujo del detalle: al abrir una fila → WebMethod DetalleTicket → SP_INFO_TICKET + SP_LISTAR_COMENTARIOS
// Ver y responder:   panel lateral → WebMethod VerTicket / ResponderTicket / CambiarEstadoTicket
// Usa g_UsuarioId, g_InstitucionId y g_RolId de Sesion.js
// =====================================================================================

// Estados que se consideran "abiertos" (el resto va al historial)
var ESTADOS_ABIERTOS = [1, 2, 3, 4];   // Nuevo, Asignado, En progreso, En espera
var g_TicketActual = 0;   // tiquete abierto en el panel "Ver y responder"

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
    $("#btnCerrarPanel, #btnCancelarTicket").on("click", CerrarPanel);

    // El fondo oscuro y Escape cierran el panel que esté abierto
    $("#ovlReportar").on("click", CerrarTodo);
    $(document).on("keydown", function (e) {
        if (e.key === "Escape") CerrarTodo();
    });

    // ---------- Panel "Ver y responder" ----------
    // Los botones se crean con JS, por eso se escuchan desde el document
    $(document).on("click", ".js-ver-ticket", function (e) {
        e.preventDefault();
        AbrirDetalle($(this).data("ticket-id"));
    });
    $("#btnCerrarDetalle").on("click", CerrarDetalle);

    $("#txtRespuesta").on("input", function () {
        $("#lblContadorRespuesta").text($(this).val().length);
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
    CargarCategorias();
    CargarUbicaciones();
});


// =====================================================================================
// LISTA DE TIQUETES
// =====================================================================================
function CargarTickets() {
    if (!ValidarSesion()) return;

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

            // 5 Resuelto va aparte: el usuario tiene que confirmar (no se puede perder en el historial)
            var porConfirmar = $.grep(tickets, function (t) { return parseInt(t.EstadoId) === 5; });
            var abiertos = $.grep(tickets, function (t) { return ESTADOS_ABIERTOS.indexOf(parseInt(t.EstadoId)) !== -1; });
            var historial = $.grep(tickets, function (t) {
                var estado = parseInt(t.EstadoId);
                return ESTADOS_ABIERTOS.indexOf(estado) === -1 && estado !== 5;   // solo Cerrado y Cancelado
            });

            PintarPorConfirmar(porConfirmar);
            PintarAbiertos(abiertos);
            PintarHistorial(historial);
        },
        error: function () {
            $("#lstAbiertas").html('<p class="loading loading--error">No se pudieron cargar tus solicitudes. Recarga la página para intentarlo de nuevo.</p>');
        }
    });
}

// Tiquetes Resueltos que esperan que el usuario confirme. El botón abre el panel "Ver y responder",
// que ya tiene "Sí, se resolvió" y "No, sigue el problema".
function PintarPorConfirmar(tickets) {
    if (tickets.length === 0) {
        $("#pnlConfirmar").addClass("is-hidden");
        $("#lstConfirmar").empty();
        return;
    }

    $("#lblTotalConfirmar").text(tickets.length);
    $("#pnlConfirmar").removeClass("is-hidden");

    var html = "";
    $.each(tickets, function (i, t) {
        html +=
            '<div class="confirmar__fila">' +
            '<span class="ticket__main">' +
            '<span class="ticket__meta">' + Esc(t.Numero) + ' · ' + Esc(t.Categoria) + ' · ' + Esc(t.FechaCreacion) + '</span>' +
            '<span class="ticket__title">' + Esc(t.Titulo) + '</span>' +
            '<span class="confirmar__nota">Lo resolvió ' + Esc(t.Responsable) + '</span>' +
            '</span>' +
            '<a class="btn btn--exito js-ver-ticket" href="#" data-ticket-id="' + t.TicketId + '">Revisar y confirmar</a>' +
            '</div>';
    });

    $("#lstConfirmar").html(html);
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
            '<a class="btn btn--primary js-ver-ticket" href="#" data-ticket-id="' + t.TicketId + '">Ver y responder</a>' +
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
            '<a class="link js-ver-ticket" href="#" data-ticket-id="' + t.TicketId + '">Ver detalle</a>' +
            '</div>';
    });

    $("#lstHistorial").html(html);
}


// =====================================================================================
// DETALLE DE UN TIQUETE (al abrir la fila)
// =====================================================================================
function CargarDetalleTicket(fila) {

    if (!ValidarSesion()) return;

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
// COMBOS DEL FORMULARIO
// =====================================================================================

// "Tipo de problema" → SP_LISTAR_CATEGORIAS (solo activas)
function CargarCategorias() {
    if (!ValidarSesion()) return;

    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;   // @InstitucionId

    jQuery.ajax({
        type: "POST",
        url: "frmInicioUsuario.aspx/ListarCategorias",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            var categorias = msg.d || [];
            var html = '<option value="">Selecciona una opción</option>';

            $.each(categorias, function (i, c) {
                html += '<option value="' + c.CategoriaId + '"' +
                    ' data-descripcion="' + Esc(c.Descripcion) + '"' +
                    ' data-requiere-fisica="' + c.RequiereFisica + '">' +
                    Esc(c.Nombre) + '</option>';
            });

            $("#cboCategoria").html(html);

            if (categorias.length === 0) {
                $("#cboCategoria").html('<option value="">No hay tipos de problema disponibles</option>');
            }
        },
        error: function () {
            $("#cboCategoria").html('<option value="">No se pudieron cargar los tipos de problema</option>');
        }
    });
}

// "¿Dónde ocurre?" → SP_LISTAR_UBICACIONES (solo activas), agrupadas en campus / en línea
function CargarUbicaciones() {
    if (!ValidarSesion()) return;

    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;   // @InstitucionId

    jQuery.ajax({
        type: "POST",
        url: "frmInicioUsuario.aspx/ListarUbicaciones",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            var ubicaciones = msg.d || [];

            if (ubicaciones.length === 0) {
                $("#cboUbicacion").html('<option value="">No hay ubicaciones disponibles</option>');
                return;
            }

            var campus = "", enLinea = "";

            $.each(ubicaciones, function (i, u) {
                var opcion = '<option value="' + u.UbicacionId + '">' + Esc(u.Nombre) + '</option>';
                if (u.EsFisica === "1") campus += opcion; else enLinea += opcion;
            });

            var html = '<option value="">Selecciona una opción</option>';
            if (campus) html += '<optgroup label="En el campus" data-fisica="1">' + campus + '</optgroup>';
            if (enLinea) html += '<optgroup label="En línea" data-fisica="0">' + enLinea + '</optgroup>';

            $("#cboUbicacion").html(html);
        },
        error: function () {
            $("#cboUbicacion").html('<option value="">No se pudieron cargar las ubicaciones</option>');
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
// WebMethod InsertarTicket → BLL → SP_INSERTA_TICKETS
function InsertarTicket() {
    if (!ValidarSesion()) return;

    var titulo = $("#txtTitulo").val().trim();
    var descripcion = $("#txtDescripcion").val().trim();
    var categoriaId = $("#cboCategoria").val();
    var ubicacionId = $("#cboUbicacion").val();

    // Validación antes de enviar (el SP también valida, pero así el mensaje es más claro)
    if (!titulo || !descripcion || !categoriaId || !ubicacionId) {
        Swal.fire({ icon: 'warning', title: 'Reportar un problema', text: 'Completa todos los campos marcados con *.' });
        return;
    }

    // EL ORDEN IMPORTA: el WebMethod lo lee por posición
    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;   // @InstitucionId
    obj_Parametros_JS[1] = titulo;            // @Titulo
    obj_Parametros_JS[2] = descripcion;       // @Descripcion
    obj_Parametros_JS[3] = categoriaId;       // @CategoriaId
    obj_Parametros_JS[4] = ubicacionId;       // @UbicacionId
    obj_Parametros_JS[5] = g_UsuarioId;       // @IdUsuarioGlobal

    $("#btnEnviarTicket").prop("disabled", true);   // evita que se envíe dos veces

    jQuery.ajax({
        type: "POST",
        url: "frmInicioUsuario.aspx/InsertarTicket",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            var res = msg.d;
            $("#btnEnviarTicket").prop("disabled", false);

            if (res === undefined) {
                Swal.fire({ icon: 'error', title: 'Error en la conexión', text: 'Error en la conexión a la base de datos' });
                return;
            }

            var arreglo = res.split("<SPLITER>");

            if (parseInt(arreglo[0]) > 0) {
                LimpiarFormulario();
                CerrarPanel();
                CargarTickets();   // la solicitud nueva aparece de una vez en la lista

                Swal.fire({
                    icon: 'success', title: '¡Solicitud enviada!', text: arreglo[1],
                    showConfirmButton: false, timer: 3000, timerProgressBar: true
                });
            }
            else {
                Swal.fire({ icon: 'error', title: 'No se pudo enviar', text: arreglo[1] });
            }
        },
        error: function () {
            $("#btnEnviarTicket").prop("disabled", false);
            Swal.fire({ icon: 'error', title: 'Error en la conexión', text: 'No se pudo conectar con el servidor.' });
        }
    });
}


// =====================================================================================
// VER Y RESPONDER (panel lateral)
// =====================================================================================

function AbrirDetalle(ticketId) {
    if (!ValidarSesion()) return;

    g_TicketActual = ticketId;

    // Limpiar lo que había del tiquete anterior
    $("#lblDetTitulo").text("Cargando…");
    $("#lblDetNumero, #lblDetEstado, #lblDetDescripcion, #lblDetFecha").text("");
    $("#lstConversacion, #accionesSolucion, #accionesFooter").empty();
    $("#boxSolucion, #frmResponder, #msgDetalleCerrado").addClass("is-hidden");
    $("#txtRespuesta").val("");
    $("#lblContadorRespuesta").text("0");

    $("#ovlReportar").prop("hidden", false);
    setTimeout(function () { $("#ovlReportar").addClass("is-open"); }, 10);
    $("#pnlDetalle").addClass("is-open").attr("aria-hidden", "false");
    $("body").addClass("no-scroll");

    CargarDetalle();
}

// Pide todo el tiquete en una sola llamada (datos + conversación + botones)
function CargarDetalle() {
    if (!ValidarSesion()) return;

    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;   // @InstitucionId
    obj_Parametros_JS[1] = g_TicketActual;    // @TicketId
    obj_Parametros_JS[2] = g_UsuarioId;       // @IdUsuarioGlobal

    jQuery.ajax({
        type: "POST",
        url: "frmInicioUsuario.aspx/VerTicket",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            var d = msg.d;

            if (!d || !d.Ticket) {
                CerrarDetalle();
                Swal.fire({ icon: 'error', title: 'Solicitud', text: 'No se pudo cargar la solicitud.' });
                return;
            }

            PintarDetalle(d);
        },
        error: function () {
            CerrarDetalle();
            Swal.fire({ icon: 'error', title: 'Error en la conexión', text: 'No se pudo conectar con el servidor.' });
        }
    });
}

function PintarDetalle(d) {
    var t = d.Ticket;

    // Encabezado y datos
    $("#lblDetNumero").text(t.Numero);
    $("#lblDetEstado").text(t.Estado).attr("class", "estado estado--" + t.EstadoId);
    $("#lblDetTitulo").text(t.Titulo);
    $("#lblDetCategoria").text(t.Categoria);
    $("#lblDetUbicacion").text(t.Ubicacion);
    $("#lblDetPrioridad").text(t.Prioridad);
    $("#lblDetResponsable").text(t.Responsable + (t.Equipo ? " · " + t.Equipo : ""));
    $("#lblDetFecha").text("Lo que reportaste · " + t.FechaCreacion);
    $("#lblDetDescripcion").text(t.Descripcion);

    // Conversación
    PintarActividad(d.Comentarios, "#lstConversacion", "Todavía no hay mensajes.");

    // Recuadro de solución (solo Resuelto)
    var resuelto = t.EstadoId === "5";
    $("#boxSolucion").toggleClass("is-hidden", !resuelto);
    $("#lblDetSolucion").text(t.Solucion);

    // Botones de estado: SOLO los que la BD dice que este usuario puede usar
    var solucion = "", footer = "";
    $.each(d.Acciones, function (i, a) {
        var destino = parseInt(a.EstadoDestinoId);
        var atributos = ' data-destino="' + destino + '" data-motivo="' + a.RequiereMotivo + '"';

        if (resuelto && destino === 6) {
            solucion += '<button type="button" class="btn btn--exito js-cambiar-estado"' + atributos + ' data-texto="confirmar">Sí, se resolvió</button>';
        } else if (resuelto && destino === 2) {
            solucion += '<button type="button" class="btn btn--secondary js-cambiar-estado"' + atributos + ' data-texto="reabrir">No, sigue el problema</button>';
        } else if (destino === 7) {
            footer += '<button type="button" class="btn btn--peligro js-cambiar-estado"' + atributos + ' data-texto="cancelar">Cancelar esta solicitud</button>';
        } else {
            footer += '<button type="button" class="btn btn--secondary js-cambiar-estado"' + atributos + ' data-texto="otro">Pasar a ' + Esc(a.EstadoDestino) + '</button>';
        }
    });
    $("#accionesSolucion").html(solucion);
    $("#accionesFooter").html(footer);

    // Responder o mensaje de cerrado
    var puedeComentar = t.PuedeComentar === "1";
    $("#frmResponder").toggleClass("is-hidden", !puedeComentar);
    $("#msgDetalleCerrado").toggleClass("is-hidden", puedeComentar);

    // Mostrar el último mensaje
    var cuerpo = document.getElementById("pnlDetalleCuerpo");
    cuerpo.scrollTop = cuerpo.scrollHeight;
}

// Se ejecuta al enviar el formulario (action="javascript: ResponderTicket()")
// WebMethod ResponderTicket → BLL → SP_INSERTA_COMENTARIOS
function ResponderTicket() {
    if (!ValidarSesion()) return;

    var texto = $("#txtRespuesta").val().trim();
    if (!texto) return;

    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;   // @InstitucionId
    obj_Parametros_JS[1] = g_TicketActual;    // @TicketId
    obj_Parametros_JS[2] = texto;             // @Texto
    obj_Parametros_JS[3] = g_UsuarioId;       // @IdUsuarioGlobal

    $("#btnResponder").prop("disabled", true);   // evita que se envíe dos veces

    jQuery.ajax({
        type: "POST",
        url: "frmInicioUsuario.aspx/ResponderTicket",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            $("#btnResponder").prop("disabled", false);
            var arreglo = (msg.d || "0<SPLITER>Error en la conexión a la base de datos").split("<SPLITER>");

            if (parseInt(arreglo[0]) > 0) {
                $("#txtRespuesta").val("");
                $("#lblContadorRespuesta").text("0");
                CargarDetalle();   // la conversación se actualiza con el mensaje nuevo
                CargarTickets();   // la fila de la lista también
            } else {
                Swal.fire({ icon: 'error', title: 'No se pudo enviar', text: arreglo[1] });
            }
        },
        error: function () {
            $("#btnResponder").prop("disabled", false);
            Swal.fire({ icon: 'error', title: 'Error en la conexión', text: 'No se pudo conectar con el servidor.' });
        }
    });
}

// Botones de estado (confirmar, reabrir, cancelar). Se crean con JS, por eso se escuchan desde el document
$(document).on("click", ".js-cambiar-estado", function () {
    var destino = $(this).data("destino");
    var requiereMotivo = String($(this).data("motivo")) === "1";
    var tipo = $(this).data("texto");

    var textos = {
        confirmar: { titulo: '¿Se resolvió tu problema?', texto: 'La solicitud se va a cerrar.', boton: 'Sí, cerrarla' },
        reabrir: { titulo: 'Reabrir la solicitud', texto: 'Cuéntanos qué sigue fallando.', boton: 'Reabrir' },
        cancelar: { titulo: 'Cancelar la solicitud', texto: '¿Por qué ya no la necesitas?', boton: 'Cancelar solicitud' },
        otro: { titulo: 'Cambiar el estado', texto: 'Escribe el motivo del cambio.', boton: 'Confirmar' }
    };
    var t = textos[tipo] || textos.otro;

    var opciones = {
        title: t.titulo, text: t.texto, icon: 'question',
        showCancelButton: true, confirmButtonText: t.boton, cancelButtonText: 'Volver'
    };

    // Si la regla pide motivo, el SweetAlert muestra un cuadro de texto obligatorio
    if (requiereMotivo) {
        opciones.input = 'textarea';
        opciones.inputPlaceholder = 'Escribe el motivo…';
        opciones.inputAttributes = { maxlength: 500 };
        opciones.inputValidator = function (valor) {
            if (!valor || !valor.trim()) return 'El motivo es obligatorio.';
        };
    }

    Swal.fire(opciones).then(function (r) {
        if (r.isConfirmed) {
            CambiarEstadoTicket(destino, requiereMotivo ? r.value.trim() : "");
        }
    });
});

// WebMethod CambiarEstadoTicket → BLL → SP_CAMBIA_ESTADO_TICKETS
function CambiarEstadoTicket(estadoNuevoId, motivo) {
    if (!ValidarSesion()) return;

    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;   // @InstitucionId
    obj_Parametros_JS[1] = g_TicketActual;    // @TicketId
    obj_Parametros_JS[2] = estadoNuevoId;     // @EstadoNuevoId
    obj_Parametros_JS[3] = motivo;            // @Motivo ("" = NULL)
    obj_Parametros_JS[4] = g_UsuarioId;       // @IdUsuarioGlobal

    jQuery.ajax({
        type: "POST",
        url: "frmInicioUsuario.aspx/CambiarEstadoTicket",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            var arreglo = (msg.d || "0<SPLITER>Error en la conexión a la base de datos").split("<SPLITER>");

            if (parseInt(arreglo[0]) > 0) {
                Swal.fire({
                    icon: 'success', title: 'Solicitud actualizada', text: arreglo[1],
                    showConfirmButton: false, timer: 2000, timerProgressBar: true
                });
                CargarDetalle();   // el panel muestra el nuevo estado y los nuevos botones
                CargarTickets();   // la fila pasa de abiertas a historial (o al revés)
            } else {
                Swal.fire({ icon: 'error', title: 'No se pudo actualizar', text: arreglo[1] });
            }
        },
        error: function () {
            Swal.fire({ icon: 'error', title: 'Error en la conexión', text: 'No se pudo conectar con el servidor.' });
        }
    });
}

function CerrarDetalle() {
    g_TicketActual = 0;
    $("#pnlDetalle").removeClass("is-open").attr("aria-hidden", "true");
    $("#ovlReportar").removeClass("is-open");
    setTimeout(function () { $("#ovlReportar").prop("hidden", true); }, 300);
    $("body").removeClass("no-scroll");
}

// Cierra el panel que esté abierto (fondo oscuro o Escape)
function CerrarTodo() {
    if ($("#pnlDetalle").hasClass("is-open")) CerrarDetalle();
    if ($("#pnlReportar").hasClass("is-open")) CerrarPanel();
}


// =====================================================================================
// ACTIVIDAD DEL TIQUETE (SP_LISTAR_ACTIVIDAD_TICKET)
// Mensajes (burbujas) y cambios de estado (línea centrada + motivo o solución) en orden.
// =====================================================================================
function PintarActividad(lista, contenedor, textoVacio) {
    if (!lista || lista.length === 0) {
        $(contenedor).html('<p class="conversacion__vacia">' + textoVacio + '</p>');
        return;
    }

    var html = "";
    $.each(lista, function (i, a) {
        var mio = a.EsMio === "1";

        // Si no viene Tipo (respaldo con solo comentarios), se pinta como mensaje
        if (a.Tipo !== "Estado") {
            html +=
                '<div class="mensaje' + (mio ? ' mensaje--mio' : '') + '">' +
                '<span class="mensaje__autor">' + (mio ? 'Tú' : Esc(a.Autor) + ' · ' + Esc(a.Rol)) + ' · ' + Esc(a.Fecha) + '</span>' +
                '<div class="mensaje__burbuja">' + Esc(a.Texto) + '</div>' +
                '</div>';
            return;
        }

        var e = DescribirEvento(parseInt(a.EstadoAnteriorId), parseInt(a.EstadoNuevoId), a.EstadoNuevo);
        html +=
            '<div class="evento ' + e.clase + '">' +
            '<span class="evento__linea"><strong>' + e.titulo + '</strong> · ' + (mio ? 'por ti' : 'por ' + Esc(a.Autor)) + ' · ' + Esc(a.Fecha) + '</span>' +
            (a.Texto ? '<div class="evento__detalle">' + (e.prefijo ? '<strong>' + e.prefijo + ':</strong> ' : '') + Esc(a.Texto) + '</div>' : '') +
            '</div>';
    });
    $(contenedor).html(html);
}

// Texto corto para cada cambio de estado (anterior → nuevo)
function DescribirEvento(anterior, nuevo, nombreNuevo) {
    if (nuevo === 5) return { titulo: 'Marcado como resuelto', prefijo: 'Solución', clase: 'evento--resuelto' };
    if (anterior === 5 && nuevo === 2) return { titulo: 'Reabierto: el problema sigue', prefijo: 'Motivo', clase: 'evento--reabierto' };
    if (anterior === 5 && nuevo === 6) return { titulo: 'Confirmado y cerrado', prefijo: '', clase: 'evento--resuelto' };
    if (anterior === 1 && nuevo === 2) return { titulo: 'Asignado', prefijo: 'Motivo', clase: '' };
    if (nuevo === 2) return { titulo: 'Reasignado', prefijo: 'Motivo', clase: '' };
    if (nuevo === 7) return { titulo: 'Cancelado', prefijo: 'Motivo', clase: 'evento--reabierto' };
    return { titulo: 'Pasó a ' + Esc(nombreNuevo), prefijo: 'Motivo', clase: '' };
}


// =====================================================================================
// UTILIDADES
// =====================================================================================

// Escapa el texto antes de meterlo en el HTML. Los títulos los escriben los usuarios:
// sin esto, alguien podría escribir <script> en un tiquete y se ejecutaría en la página.
function Esc(texto) {
    return $("<div>").text(texto == null ? "" : String(texto)).html();
}