// =====================================================================================
// VISTA DE SOPORTE · InicioSoporte.js   (Soporte técnico / Administrativo)
// Tarjetas:  CargarResumen()  → WebMethod ResumenSoporte  → SP_DASHBOARD_TICKETS
// Tabla:     CargarBandeja()  → WebMethod FiltrarTickets  → SP_FILTRAR_TICKETS
// Panel:     AbrirDetalle()   → WebMethod VerTicket       → SP_INFO_TICKET + SP_LISTAR_COMENTARIOS
//                                                           + SP_LISTAR_TRANSICIONES_DISPONIBLES
// Acciones:  TomarTicket · GuardarCambiosTicket · CambiarEstadoTicket (esta página)
//            ResponderTicket, ListarCategorias, ListarUbicaciones (de frmInicioUsuario.aspx)
// Usa g_UsuarioId, g_InstitucionId y g_RolId de Sesion.js
// =====================================================================================

var g_Vista = "sinasignar";   // pestaña activa: sinasignar · mios · todos
var g_TicketActual = 0;       // tiquete abierto en el panel
var g_Detalle = null;         // datos del tiquete abierto (para saber qué cambió al guardar)
var g_Responsables = [];      // técnicos y administrativos para el combo "Responsable"
var g_TimerBusqueda = null;   // espera a que el usuario termine de escribir

var URL_PAGINA = "frmInicioSoporte.aspx/";
var URL_USUARIO = "frmInicioUsuario.aspx/";   // WebMethods que se reutilizan del inicio de usuario

$(document).ready(function () {

    // ---------- Encabezado ----------
    var partes = ($.cookie('USRNOM') || "").trim().split(" ");
    var iniciales = (partes[0] ? partes[0].charAt(0) : "") + (partes[1] ? partes[1].charAt(0) : "");
    $("#lblIniciales").text(iniciales.toUpperCase());
    $("#lblRol").text(g_RolId == "4" ? "Administrativo" : "Soporte técnico");

    // ---------- Pestañas ----------
    $(".tab").on("click", function () {
        $(".tab").removeClass("is-active").attr("aria-selected", "false");
        $(this).addClass("is-active").attr("aria-selected", "true");
        g_Vista = $(this).data("vista");
        CargarBandeja();
    });

    // ---------- Filtros ----------
    $("#txtBuscar").on("input", function () {
        clearTimeout(g_TimerBusqueda);
        g_TimerBusqueda = setTimeout(CargarBandeja, 350);   // busca al dejar de escribir
    });
    $("#cboFiltroPrioridad, #chkSoloVencidos").on("change", CargarBandeja);

    // ---------- Tabla (las filas se crean con JS, por eso se escuchan desde el document) ----------
    $(document).on("click", ".js-ver-ticket", function () {
        AbrirDetalle($(this).data("ticket-id"));
    });
    $(document).on("click", ".js-tomar", function (e) {
        e.stopPropagation();
        TomarTicket($(this).data("ticket-id"));
    });

    // ---------- Panel ----------
    $("#btnCerrarDetalle, #ovlDetalle").on("click", CerrarDetalle);
    $(document).on("keydown", function (e) {
        if (e.key === "Escape" && $("#pnlDetalle").hasClass("is-open")) CerrarDetalle();
    });
    $("#cboDetCategoria").on("change", FiltrarUbicaciones);
    $("#btnGuardarCambios").on("click", GuardarCambios);
    $(document).on("click", ".js-estado", ClickCambiarEstado);

    // ---------- Primera carga ----------
    CargarPrioridades();
    CargarCategorias();
    CargarUbicaciones();
    CargarResponsables();
    CargarResumen();
    CargarBandeja();

    // El tiempo restante cambia solo: cada minuto se refresca la tabla (si el panel está cerrado)
    setInterval(function () {
        if (!$("#pnlDetalle").hasClass("is-open")) {
            CargarResumen();
            CargarBandeja();
        }
    }, 60000);
});


// =====================================================================================
// LLAMADA AL SERVIDOR (todas las funciones usan esta para no repetir el $.ajax)
// =====================================================================================
// url:          "frmInicioSoporte.aspx/Metodo"
// parametros:   arreglo obj_Parametros_JS, o null si el WebMethod no recibe nada
// alResponder:  función que recibe msg.d
// alFallar:     opcional; si no viene, se muestra un SweetAlert de error de conexión
function LlamarWebMethod(url, parametros, alResponder, alFallar) {
    jQuery.ajax({
        type: "POST",
        url: url,
        data: parametros === null ? "{}" : JSON.stringify({ "obj_Parametros_JS": parametros }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) { alResponder(msg.d); },
        error: function () {
            if (alFallar) alFallar();
            else Swal.fire({ icon: 'error', title: 'Error en la conexión', text: 'No se pudo conectar con el servidor.' });
        }
    });
}

// "código<SPLITER>mensaje" → { ok, codigo, mensaje }
function LeerRespuesta(d) {
    var arreglo = (d || "0<SPLITER>Error en la conexión a la base de datos").split("<SPLITER>");
    return { ok: parseInt(arreglo[0]) > 0, codigo: parseInt(arreglo[0]), mensaje: arreglo[1] };
}

function Aviso(titulo, texto) {
    Swal.fire({ icon: 'success', title: titulo, text: texto, showConfirmButton: false, timer: 1800, timerProgressBar: true });
}


// =====================================================================================
// TARJETAS
// =====================================================================================
function CargarResumen() {
    if (!ValidarSesion()) return;

    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;   // @InstitucionId
    obj_Parametros_JS[1] = g_UsuarioId;       // @IdUsuarioGlobal

    LlamarWebMethod(URL_PAGINA + "ResumenSoporte", obj_Parametros_JS, function (r) {
        if (!r || r.SinAsignar === undefined) return;   // se quedan en "–"

        $("#lblKpiSinAsignar, #lblTabSinAsignar").text(r.SinAsignar);
        $("#lblKpiMios, #lblTabMios").text(r.AsignadosAMi);
        $("#lblKpiVencenHoy").text(r.VencenHoy);
        $("#lblKpiVencidos").text(r.Vencidos);
    }, function () { /* si falla, las tarjetas se quedan en "–" */ });
}


// =====================================================================================
// TABLA
// =====================================================================================
function CargarBandeja() {
    if (!ValidarSesion()) return;

    // Cada pestaña es un filtro de responsable distinto
    var responsable = "", soloAbiertos = "1";
    if (g_Vista === "sinasignar") responsable = "0";          // ResponsableId IS NULL
    else if (g_Vista === "mios") responsable = g_UsuarioId;   // los míos
    else soloAbiertos = "0";                                  // "Todos" incluye cerrados (para buscar)

    // EL ORDEN IMPORTA: el WebMethod lo lee por posición
    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;                                     // @InstitucionId
    obj_Parametros_JS[1] = g_UsuarioId;                                         // @IdUsuarioGlobal
    obj_Parametros_JS[2] = $("#txtBuscar").val().trim();                        // @Filtro
    obj_Parametros_JS[3] = $("#cboFiltroPrioridad").val();                      // @PrioridadId ("" = todas)
    obj_Parametros_JS[4] = responsable;                                         // @ResponsableId
    obj_Parametros_JS[5] = $("#chkSoloVencidos").is(":checked") ? "1" : "0";   // @SoloVencidos
    obj_Parametros_JS[6] = soloAbiertos;                                        // @SoloAbiertos

    LlamarWebMethod(URL_PAGINA + "FiltrarTickets", obj_Parametros_JS, PintarBandeja, function () {
        $("#tblTickets").html('<tr><td colspan="7" class="tabla__vacia">No se pudieron cargar los tiquetes. Recarga la página.</td></tr>');
    });
}

function PintarBandeja(tickets) {
    if (!tickets || tickets.length === 0) {
        var vacio = {
            sinasignar: "No hay tiquetes sin asignar. ¡Todo al día!",
            mios: "No tienes tiquetes abiertos.",
            todos: "No hay tiquetes con esos filtros."
        };
        $("#tblTickets").html('<tr><td colspan="7" class="tabla__vacia">' + vacio[g_Vista] + '</td></tr>');
        return;
    }

    var html = "";
    $.each(tickets, function (i, t) {
        var id = t.TicketId;
        var sinResponsable = t.ResponsableId === "" && parseInt(t.EstadoId) <= 4;

        // Debajo del título: quién lo reportó (y en "Todos", quién lo tiene)
        var sub = Esc(t.Solicitante) + ' · ' + Esc(t.RolSolicitante) + ' · ' + Esc(t.FechaCreacion);
        if (g_Vista === "todos") sub += ' · ' + Esc(t.Responsable);

        var boton = sinResponsable
            ? '<button type="button" class="btn btn--primary btn--chico js-tomar" data-ticket-id="' + id + '">Tomar</button>'
            : '<button type="button" class="btn btn--secondary btn--chico js-ver-ticket" data-ticket-id="' + id + '">Abrir</button>';

        html +=
            '<tr data-ticket-id="' + id + '"' + (id == g_TicketActual ? ' class="is-selected"' : '') + '>' +
            '<td class="tabla__numero">' + Esc(t.Numero) + '</td>' +
            '<td><div class="tabla__problema">' +
            '<button type="button" class="tabla__titulo js-ver-ticket" data-ticket-id="' + id + '">' + Esc(t.Titulo) + '</button>' +
            '<span class="tabla__sub">' + sub + '</span>' +
            '</div></td>' +
            '<td>' + Esc(t.Categoria) + '</td>' +
            '<td><span class="prioridad prioridad--' + t.PrioridadId + '">' + Esc(t.Prioridad) + '</span></td>' +
            '<td><span class="estado estado--' + t.EstadoId + '">' + Esc(t.Estado) + '</span></td>' +
            '<td>' + ChipSla(t.MinutosRestantes, t.EstadoId) + '</td>' +
            '<td>' + boton + '</td>' +
            '</tr>';
    });
    $("#tblTickets").html(html);
}


// =====================================================================================
// COMBOS (se cargan una vez al abrir la página)
// =====================================================================================
function CargarPrioridades() {
    LlamarWebMethod(URL_PAGINA + "ListarPrioridades", null, function (lista) {
        $.each(lista || [], function (i, p) {
            $("#cboFiltroPrioridad").append($("<option>").val(p.PrioridadId).text(p.Prioridad));
            $("#cboDetPrioridad").append($("<option>").val(p.PrioridadId).text(p.Prioridad + " · " + p.SlaHoras + " h"));
        });
    }, function () { });
}

// Reutiliza el WebMethod del inicio de usuario (solo categorías activas)
function CargarCategorias() {
    if (!ValidarSesion()) return;

    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;   // @InstitucionId

    LlamarWebMethod(URL_USUARIO + "ListarCategorias", obj_Parametros_JS, function (lista) {
        var combo = $("#cboDetCategoria").empty();
        $.each(lista || [], function (i, c) {
            combo.append($("<option>").val(c.CategoriaId).text(c.Nombre).attr("data-requiere-fisica", c.RequiereFisica));
        });
    }, function () { });
}

// Reutiliza el WebMethod del inicio de usuario. Se agrupan en "En el campus" y "En línea".
function CargarUbicaciones() {
    if (!ValidarSesion()) return;

    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;   // @InstitucionId

    LlamarWebMethod(URL_USUARIO + "ListarUbicaciones", obj_Parametros_JS, function (lista) {
        var campus = $('<optgroup label="En el campus" data-fisica="1">');
        var enLinea = $('<optgroup label="En línea" data-fisica="0">');

        $.each(lista || [], function (i, u) {
            var opcion = $("<option>").val(u.UbicacionId).text(u.Nombre);
            (u.EsFisica === "1" ? campus : enLinea).append(opcion);
        });

        var combo = $("#cboDetUbicacion").empty().append('<option value="">Selecciona una ubicación</option>');
        if (campus.children().length) combo.append(campus);
        if (enLinea.children().length) combo.append(enLinea);
    }, function () { });
}

function CargarResponsables() {
    if (!ValidarSesion()) return;

    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;   // @InstitucionId

    LlamarWebMethod(URL_PAGINA + "ListarResponsables", obj_Parametros_JS, function (lista) {
        g_Responsables = lista || [];
        if (g_Detalle) PintarResponsables(g_Detalle);   // si el panel ya está abierto
    }, function () { });
}

// Si la categoría necesita un lugar del campus, se bloquean las ubicaciones "En línea"
function FiltrarUbicaciones() {
    var requiereFisica = String($("#cboDetCategoria option:selected").attr("data-requiere-fisica")) === "1";
    var enLinea = $('#cboDetUbicacion optgroup[data-fisica="0"]');

    enLinea.prop("disabled", requiereFisica);
    $("#lblDetRequiereFisica").toggleClass("is-hidden", !requiereFisica);

    // Si la ubicación elegida era en línea, se limpia para que escoja una del campus
    if (requiereFisica && $("#cboDetUbicacion option:selected").parent().attr("data-fisica") === "0") {
        $("#cboDetUbicacion").val("");
    }
}


// =====================================================================================
// PANEL LATERAL
// =====================================================================================
function AbrirDetalle(ticketId) {
    if (!ValidarSesion()) return;

    g_TicketActual = ticketId;
    g_Detalle = null;

    // Limpiar lo del tiquete anterior
    $("#lblDetTitulo").text("Cargando…");
    $("#lblDetNumero, #lblDetEstado, #lblDetEstado2, #lblDetSolicitante, #lblDetFecha, #lblDetDescripcion, #lblDetCorreo").text("");
    $("#lstConversacion, #accionesFooter").empty();
    $("#boxSolucionLeida, #boxSolucionEditar, #frmResponder, #msgDetalleCerrado, #lblDetSlaChip").addClass("is-hidden");
    $("#txtRespuesta, #txtSolucion").val("");

    // Marcar la fila en la tabla
    $("#tblTickets tr").removeClass("is-selected");
    $('#tblTickets tr[data-ticket-id="' + ticketId + '"]').addClass("is-selected");

    $("#ovlDetalle").prop("hidden", false);
    setTimeout(function () { $("#ovlDetalle").addClass("is-open"); }, 10);
    $("#pnlDetalle").addClass("is-open").attr("aria-hidden", "false");
    $("body").addClass("no-scroll");

    CargarDetalle();
}

function CargarDetalle() {
    if (!ValidarSesion()) return;

    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;   // @InstitucionId
    obj_Parametros_JS[1] = g_TicketActual;    // @TicketId
    obj_Parametros_JS[2] = g_UsuarioId;       // @IdUsuarioGlobal

    LlamarWebMethod(URL_PAGINA + "VerTicket", obj_Parametros_JS, function (d) {
        if (!d || !d.Ticket) {
            CerrarDetalle();
            Swal.fire({ icon: 'error', title: 'Tiquete', text: 'No se pudo cargar el tiquete.' });
            return;
        }
        PintarDetalle(d);
    }, function () {
        CerrarDetalle();
        Swal.fire({ icon: 'error', title: 'Error en la conexión', text: 'No se pudo conectar con el servidor.' });
    });
}

function PintarDetalle(d) {
    var t = d.Ticket;
    g_Detalle = t;

    // ---------- Encabezado ----------
    $("#lblDetNumero").text(t.Numero);
    $("#lblDetEstado, #lblDetEstado2").text(t.Estado).attr("class", "estado estado--" + t.EstadoId);
    $("#lblDetTitulo").text(t.Titulo);
    $("#lblDetSolicitante").text(t.Solicitante + " · " + t.RolSolicitante);
    $("#lblDetFecha").text("Reportado el " + t.FechaCreacion);
    $("#lblDetDescripcion").text(t.Descripcion);
    $("#lblDetCorreo").text(t.CorreoSolicitante);

    PintarTiempo(t);

    // ---------- Combos de la derecha ----------
    $("#cboDetPrioridad").val(t.PrioridadId);
    SeleccionarOAgregar($("#cboDetCategoria"), t.CategoriaId, t.Categoria);
    FiltrarUbicaciones();
    SeleccionarOAgregar($("#cboDetUbicacion"), t.UbicacionId, t.Ubicacion);
    PintarResponsables(t);

    var puedeEditar = t.PuedeEditar === "1";      // la BD dice si se puede editar (no Cerrado/Cancelado)
    var puedeAsignar = t.PuedeAsignar === "1";    // y si se puede asignar (Nuevo a En espera)
    $("#cboDetPrioridad, #cboDetCategoria, #cboDetUbicacion").prop("disabled", !puedeEditar);
    $("#cboDetResponsable").prop("disabled", !puedeAsignar);
    $("#btnGuardarCambios").toggleClass("is-hidden", !puedeEditar && !puedeAsignar);

    // ---------- Conversación ----------
    if (d.Comentarios.length === 0) {
        $("#lstConversacion").html('<p class="conversacion__vacia">Todavía no hay mensajes en este tiquete.</p>');
    } else {
        var html = "";
        $.each(d.Comentarios, function (i, c) {
            var mio = c.EsMio === "1";
            html +=
                '<div class="mensaje' + (mio ? ' mensaje--mio' : '') + '">' +
                '<span class="mensaje__autor">' + (mio ? 'Tú' : Esc(c.Autor) + ' · ' + Esc(c.Rol)) + ' · ' + Esc(c.Fecha) + '</span>' +
                '<div class="mensaje__burbuja">' + Esc(c.Texto) + '</div>' +
                '</div>';
        });
        $("#lstConversacion").html(html);
    }

    // ---------- Solución ya registrada (Resuelto o Cerrado) ----------
    var tieneSolucion = t.Solucion !== "" && (t.EstadoId === "5" || t.EstadoId === "6");
    $("#boxSolucionLeida").toggleClass("is-hidden", !tieneSolucion);
    $("#lblDetSolucion").text(t.Solucion);

    // ---------- Botones: SOLO los que la BD permite ----------
    var botones = "";
    var puedeResolver = false;

    // "Tomar" no es una transición: es SP_ASIGNA_TICKETS conmigo como responsable
    if (t.ResponsableId === "" && puedeAsignar) {
        botones += '<button type="button" class="btn btn--primary js-tomar" data-ticket-id="' + t.TicketId + '">Tomar</button>';
    }

    $.each(d.Acciones, function (i, a) {
        var destino = parseInt(a.EstadoDestinoId);
        var datos = ' data-destino="' + destino + '" data-motivo="' + a.RequiereMotivo + '"';

        if (destino === 2) return;   // reasignar se hace con el combo "Responsable"

        if (destino === 5) {
            puedeResolver = true;
            botones += '<button type="button" class="btn btn--exito js-estado"' + datos + '>Marcar como resuelto</button>';
        } else if (destino === 3) {
            botones += '<button type="button" class="btn btn--secondary js-estado"' + datos + '>Pasar a En progreso</button>';
        } else if (destino === 4) {
            botones += '<button type="button" class="btn btn--secondary js-estado"' + datos + '>Poner en espera</button>';
        } else if (destino === 7) {
            botones += '<button type="button" class="btn btn--peligro js-estado"' + datos + '>Cancelar tiquete</button>';
        } else {
            botones += '<button type="button" class="btn btn--secondary js-estado"' + datos + '>Pasar a ' + Esc(a.EstadoDestino) + '</button>';
        }
    });
    $("#accionesFooter").html(botones);

    // El cuadro de la solución solo aparece cuando se puede resolver (En progreso)
    $("#boxSolucionEditar").toggleClass("is-hidden", !puedeResolver);

    // ---------- Responder ----------
    var puedeComentar = t.PuedeComentar === "1";
    $("#frmResponder").toggleClass("is-hidden", !puedeComentar);
    $("#msgDetalleCerrado").toggleClass("is-hidden", puedeComentar);

    var cuerpo = document.getElementById("pnlDetalleCuerpo");
    cuerpo.scrollTop = cuerpo.scrollHeight;   // mostrar el último mensaje
}

// Tiempo restante: chip del encabezado + bloque con barra de la derecha
function PintarTiempo(t) {
    var chip = $("#lblDetSlaChip");

    if (t.MinutosRestantes === "") {
        // Resuelto, Cerrado o Cancelado: el reloj ya no corre
        chip.addClass("is-hidden");
        $("#lblDetTiempo").text("—").css("color", "");
        $("#barSla").css("width", "100%").attr("class", "barra__relleno");
        $("#lblDetPlazo").text(t.EstadoId === "5" ? "Resuelto: esperando que el usuario confirme." : "Tiquete finalizado.");
        return;
    }

    var minutos = parseInt(t.MinutosRestantes);
    var plazo = parseInt(t.SlaHoras) * 60;
    var consumido = Math.min(100, Math.max(0, Math.round((plazo - minutos) * 100 / plazo)));
    var clase = ClaseSla(minutos);

    chip.removeClass("is-hidden").attr("class", "sla sla--" + clase).text(TextoSla(minutos));

    $("#lblDetTiempo").text(minutos < 0 ? "Vencido" : TextoTiempo(minutos))
        .css("color", clase === "vencido" ? "#8E3B47" : (clase === "pronto" ? "#80604A" : ""));
    $("#barSla").css("width", consumido + "%")
        .attr("class", "barra__relleno" + (clase === "vencido" ? " is-vencido" : (clase === "pronto" ? " is-pronto" : "")));
    $("#lblDetPlazo").text(t.Prioridad + " · " + t.SlaHoras + " h de plazo");
}

// Combo "Responsable". Si no tiene, se agrega la opción "Sin asignar" para que se vea.
function PintarResponsables(t) {
    var combo = $("#cboDetResponsable").empty();

    if (t.ResponsableId === "") {
        combo.append('<option value="">Sin asignar</option>');
    }

    var encontrado = false;
    $.each(g_Responsables, function (i, r) {
        // Ej.: "Luis Brenes · 3 abiertos" (la carga ayuda a repartir el trabajo)
        var texto = r.Nombre + (r.UsuarioId == g_UsuarioId ? " (yo)" : "") + " · " + r.TiquetesAbiertos + " abiertos";
        combo.append($("<option>").val(r.UsuarioId).text(texto));
        if (r.UsuarioId === t.ResponsableId) encontrado = true;
    });

    // El responsable actual puede no salir en la lista (ej. lo desactivaron)
    if (t.ResponsableId !== "" && !encontrado) {
        combo.prepend($("<option>").val(t.ResponsableId).text("Responsable actual (inactivo)"));
    }

    combo.val(t.ResponsableId);
}

function CerrarDetalle() {
    g_TicketActual = 0;
    g_Detalle = null;
    $("#tblTickets tr").removeClass("is-selected");
    $("#pnlDetalle").removeClass("is-open").attr("aria-hidden", "true");
    $("#ovlDetalle").removeClass("is-open");
    setTimeout(function () { $("#ovlDetalle").prop("hidden", true); }, 300);
    $("body").removeClass("no-scroll");
}

// Después de cualquier acción: panel (si está abierto), tabla, tarjetas y carga de los técnicos
function Refrescar() {
    if (g_TicketActual) CargarDetalle();
    CargarBandeja();
    CargarResumen();
    CargarResponsables();
}


// =====================================================================================
// ACCIONES
// =====================================================================================

// "Tomar": SP_ASIGNA_TICKETS con ResponsableId = yo
function TomarTicket(ticketId) {
    if (!ValidarSesion()) return;

    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;   // @InstitucionId
    obj_Parametros_JS[1] = ticketId;          // @TicketId
    obj_Parametros_JS[2] = g_UsuarioId;       // @IdUsuarioGlobal (y @ResponsableId)

    $(".js-tomar").prop("disabled", true);   // evita el doble clic

    LlamarWebMethod(URL_PAGINA + "TomarTicket", obj_Parametros_JS, function (d) {
        $(".js-tomar").prop("disabled", false);
        var r = LeerRespuesta(d);

        if (r.ok) {
            Aviso('Tiquete asignado', r.mensaje);
            Refrescar();
        } else {
            Swal.fire({ icon: 'error', title: 'No se pudo tomar', text: r.mensaje });
            Refrescar();   // probablemente otro técnico lo tomó primero
        }
    }, function () {
        $(".js-tomar").prop("disabled", false);
        Swal.fire({ icon: 'error', title: 'Error en la conexión', text: 'No se pudo conectar con el servidor.' });
    });
}

// "Guardar cambios": prioridad, categoría, ubicación y responsable
function GuardarCambios() {
    if (!ValidarSesion() || !g_Detalle) return;

    var t = g_Detalle;
    var categoriaId = $("#cboDetCategoria").val();
    var prioridadId = $("#cboDetPrioridad").val();
    var ubicacionId = $("#cboDetUbicacion").val();
    var responsableId = $("#cboDetResponsable").val() || "";

    if (!categoriaId || !prioridadId || !ubicacionId) {
        Swal.fire({ icon: 'warning', title: 'Guardar cambios', text: 'Escoge la categoría, la prioridad y la ubicación.' });
        return;
    }

    var cambiaDatos = categoriaId !== t.CategoriaId || prioridadId !== t.PrioridadId || ubicacionId !== t.UbicacionId;
    var cambiaResponsable = responsableId !== "" && responsableId !== t.ResponsableId;

    if (!cambiaDatos && !cambiaResponsable) {
        Swal.fire({ icon: 'info', title: 'Guardar cambios', text: 'No hay cambios para guardar.' });
        return;
    }

    // Reasignar un tiquete que ya estaba En progreso o En espera pide motivo (regla de TransicionEstado)
    if (cambiaResponsable && (t.EstadoId === "3" || t.EstadoId === "4")) {
        Swal.fire({
            title: 'Reasignar el tiquete', text: '¿Por qué se lo pasas a otra persona?', icon: 'question',
            input: 'textarea', inputPlaceholder: 'Escribe el motivo…', inputAttributes: { maxlength: 500 },
            inputValidator: function (valor) { if (!valor || !valor.trim()) return 'El motivo es obligatorio.'; },
            showCancelButton: true, confirmButtonText: 'Reasignar', cancelButtonText: 'Volver'
        }).then(function (r) {
            if (r.isConfirmed) EnviarCambios(categoriaId, prioridadId, ubicacionId, responsableId, r.value.trim());
        });
        return;
    }

    EnviarCambios(categoriaId, prioridadId, ubicacionId, cambiaResponsable ? responsableId : "", "");
}

function EnviarCambios(categoriaId, prioridadId, ubicacionId, responsableId, motivo) {
    if (!ValidarSesion()) return;

    // EL ORDEN IMPORTA: el WebMethod lo lee por posición
    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;   // @InstitucionId
    obj_Parametros_JS[1] = g_TicketActual;    // @TicketId
    obj_Parametros_JS[2] = g_UsuarioId;       // @IdUsuarioGlobal
    obj_Parametros_JS[3] = categoriaId;       // @CategoriaId
    obj_Parametros_JS[4] = prioridadId;       // @PrioridadId
    obj_Parametros_JS[5] = ubicacionId;       // @UbicacionId
    obj_Parametros_JS[6] = responsableId;     // @ResponsableId ("" = no se cambia)
    obj_Parametros_JS[7] = motivo;            // @Motivo de la reasignación

    $("#btnGuardarCambios").prop("disabled", true);

    LlamarWebMethod(URL_PAGINA + "GuardarCambiosTicket", obj_Parametros_JS, function (d) {
        $("#btnGuardarCambios").prop("disabled", false);
        var r = LeerRespuesta(d);

        if (r.ok) Aviso('Tiquete actualizado', r.mensaje);
        else Swal.fire({ icon: 'error', title: 'No se pudo guardar', text: r.mensaje });

        Refrescar();   // aunque falle, se recarga para que los combos muestren lo que hay en la BD
    }, function () {
        $("#btnGuardarCambios").prop("disabled", false);
        Swal.fire({ icon: 'error', title: 'Error en la conexión', text: 'No se pudo conectar con el servidor.' });
    });
}

// Botones de estado (En progreso, En espera, Resuelto, Cancelado)
function ClickCambiarEstado() {
    var destino = parseInt($(this).data("destino"));
    var requiereMotivo = String($(this).data("motivo")) === "1";

    // Resolver: la solución sale del cuadro verde, no de un SweetAlert
    if (destino === 5) {
        var solucion = $("#txtSolucion").val().trim();
        if (!solucion) {
            Swal.fire({ icon: 'warning', title: 'Falta la solución', text: 'Escribe qué hiciste para resolverlo antes de marcarlo como resuelto.' })
                .then(function () { $("#txtSolucion").trigger("focus"); });
            return;
        }
        Swal.fire({
            title: '¿Marcar como resuelto?', text: 'El usuario va a ver la solución y tendrá que confirmar si se arregló.',
            icon: 'question', showCancelButton: true, confirmButtonText: 'Sí, resolver', cancelButtonText: 'Volver'
        }).then(function (r) {
            if (r.isConfirmed) CambiarEstadoTicket(5, "", solucion);
        });
        return;
    }

    // Pasar a En progreso no pide nada: se hace directo
    if (!requiereMotivo && destino === 3) {
        CambiarEstadoTicket(3, "", "");
        return;
    }

    var textos = {
        4: { titulo: 'Poner en espera', texto: '¿Qué estás esperando? (una respuesta del usuario, un repuesto…)', boton: 'Poner en espera' },
        7: { titulo: 'Cancelar el tiquete', texto: '¿Por qué se cancela?', boton: 'Cancelar tiquete' }
    };
    var t = textos[destino] || { titulo: 'Cambiar el estado', texto: 'Escribe el motivo del cambio.', boton: 'Confirmar' };

    var opciones = {
        title: t.titulo, text: t.texto, icon: 'question',
        showCancelButton: true, confirmButtonText: t.boton, cancelButtonText: 'Volver'
    };

    if (requiereMotivo) {
        opciones.input = 'textarea';
        opciones.inputPlaceholder = 'Escribe el motivo…';
        opciones.inputAttributes = { maxlength: 500 };
        opciones.inputValidator = function (valor) {
            if (!valor || !valor.trim()) return 'El motivo es obligatorio.';
        };
    }

    Swal.fire(opciones).then(function (r) {
        if (r.isConfirmed) CambiarEstadoTicket(destino, requiereMotivo ? r.value.trim() : "", "");
    });
}

// WebMethod CambiarEstadoTicket → BLL → SP_CAMBIA_ESTADO_TICKETS
function CambiarEstadoTicket(estadoNuevoId, motivo, solucion) {
    if (!ValidarSesion()) return;

    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;   // @InstitucionId
    obj_Parametros_JS[1] = g_TicketActual;    // @TicketId
    obj_Parametros_JS[2] = estadoNuevoId;     // @EstadoNuevoId
    obj_Parametros_JS[3] = motivo;            // @Motivo ("" = NULL)
    obj_Parametros_JS[4] = g_UsuarioId;       // @IdUsuarioGlobal
    obj_Parametros_JS[5] = solucion;          // @Solucion (solo para 5 Resuelto)

    $(".js-estado").prop("disabled", true);

    LlamarWebMethod(URL_PAGINA + "CambiarEstadoTicket", obj_Parametros_JS, function (d) {
        $(".js-estado").prop("disabled", false);
        var r = LeerRespuesta(d);

        if (r.ok) {
            if (estadoNuevoId === 5) $("#txtSolucion").val("");
            Aviso('Tiquete actualizado', r.mensaje);
            Refrescar();
        } else {
            Swal.fire({ icon: 'error', title: 'No se pudo actualizar', text: r.mensaje });
        }
    }, function () {
        $(".js-estado").prop("disabled", false);
        Swal.fire({ icon: 'error', title: 'Error en la conexión', text: 'No se pudo conectar con el servidor.' });
    });
}

// Se ejecuta al enviar el formulario (action="javascript: ResponderTicket()")
// Reutiliza el WebMethod del inicio de usuario → SP_INSERTA_COMENTARIOS
function ResponderTicket() {
    if (!ValidarSesion()) return;

    var texto = $("#txtRespuesta").val().trim();
    if (!texto) return;

    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;   // @InstitucionId
    obj_Parametros_JS[1] = g_TicketActual;    // @TicketId
    obj_Parametros_JS[2] = texto;             // @Texto
    obj_Parametros_JS[3] = g_UsuarioId;       // @IdUsuarioGlobal

    $("#btnResponder").prop("disabled", true);

    LlamarWebMethod(URL_USUARIO + "ResponderTicket", obj_Parametros_JS, function (d) {
        $("#btnResponder").prop("disabled", false);
        var r = LeerRespuesta(d);

        if (r.ok) {
            $("#txtRespuesta").val("");
            CargarDetalle();   // la conversación muestra el mensaje nuevo
        } else {
            Swal.fire({ icon: 'error', title: 'No se pudo enviar', text: r.mensaje });
        }
    }, function () {
        $("#btnResponder").prop("disabled", false);
        Swal.fire({ icon: 'error', title: 'Error en la conexión', text: 'No se pudo conectar con el servidor.' });
    });
}


// =====================================================================================
// UTILIDADES
// =====================================================================================

// 95 → "1 h 35 min" · 2000 → "1 d 9 h"
function TextoTiempo(minutos) {
    var m = Math.abs(minutos);
    if (m < 60) return m + " min";
    if (m < 1440) {
        var h = Math.floor(m / 60), resto = m % 60;
        return h + " h" + (resto ? " " + resto + " min" : "");
    }
    var d = Math.floor(m / 1440), horas = Math.floor((m % 1440) / 60);
    return d + " d" + (horas ? " " + horas + " h" : "");
}

function TextoSla(minutos) {
    return minutos < 0 ? "Vencido hace " + TextoTiempo(minutos) : "Vence en " + TextoTiempo(minutos);
}

// vencido · pronto (2 horas o menos) · ok
function ClaseSla(minutos) {
    if (minutos < 0) return "vencido";
    if (minutos <= 120) return "pronto";
    return "ok";
}

// Chip de la columna "Vence"
function ChipSla(minutosTexto, estadoId) {
    if (minutosTexto === "") {
        var texto = estadoId === "5" ? "Esperando al usuario" : "—";
        return '<span class="sla sla--neutro">' + texto + '</span>';
    }
    var m = parseInt(minutosTexto);
    return '<span class="sla sla--' + ClaseSla(m) + '">' + (m < 0 ? "Vencido hace " + TextoTiempo(m) : TextoTiempo(m)) + '</span>';
}

// Los combos solo traen categorías y ubicaciones ACTIVAS. Si el tiquete tiene una que ya se
// desactivó, se agrega para que se vea cuál tiene (y soporte la pueda cambiar por una activa).
function SeleccionarOAgregar(combo, valor, texto) {
    combo.find("option.js-inactiva").remove();
    if (combo.find('option[value="' + valor + '"]').length === 0) {
        combo.append($("<option>").val(valor).text(texto + " (desactivada)").addClass("js-inactiva"));
    }
    combo.val(valor);
}

// Escapa el texto antes de meterlo en el HTML (los títulos los escriben los usuarios)
function Esc(texto) {
    return $("<div>").text(texto == null ? "" : String(texto)).html();
}
