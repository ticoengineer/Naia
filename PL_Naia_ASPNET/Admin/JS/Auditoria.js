
// =======================================================
// NAIA - AUDITORÍA
// Consulta, filtros y visualización de movimientos.
// =======================================================

// Comprobación de navegación.
// La autorización real corresponde al servidor.
function aud_SesionDisponible() {
    return !!(g_UsuarioId &&
        g_InstitucionId &&
        String(g_RolId) === "4");
}

// Se ejecuta cuando se abre Auditoría.
function aud_Inicializar() {
    if (!aud_SesionDisponible()) return;

    aud_Listar();
}

// ==========================================
// LISTAR AUDITORÍA
// ==========================================

function aud_Listar() {
    if (!aud_SesionDisponible()) return;

    $("#audTablaCuerpo").html(
        '<tr><td colspan="6" class="admin-table__loading">' +
        'Cargando movimientos...</td></tr>'
    );

    $.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/ListarAuditoria",
        data: JSON.stringify({}),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,

        success: function (msg) {
            var datos = msg.d || [];

            aud_PintarTabla(datos);
            aud_CargarOpciones(datos);
        },

        error: function (xhr) {
            aud_MostrarError(xhr);
        }
    });
}

// ==========================================
// FILTRAR AUDITORÍA
// ==========================================

function aud_Filtrar() {
    if (!aud_SesionDisponible()) return;

    var fechaInicio = $("#audFechaInicio").val();
    var fechaFin = $("#audFechaFin").val();
    var usuarioId = $("#audUsuario").val().trim();

    if (fechaInicio && fechaFin && fechaInicio > fechaFin) {
        Swal.fire({
            icon: "warning",
            title: "Auditoría",
            text: "La fecha inicial no puede ser posterior a la fecha final."
        });
        return;
    }

    if (usuarioId &&
        (!/^[1-9]\d*$/.test(usuarioId) ||
            Number(usuarioId) > 2147483647)) {
        Swal.fire({
            icon: "warning",
            title: "Auditoría",
            text: "Ingresá un ID de usuario válido."
        });
        return;
    }

    var parametros = [
        fechaInicio,
        fechaFin,
        $("#audSeccion").val(),
        $("#audAccion").val(),
        usuarioId,
        $("#audSoloFallidos").is(":checked")
            ? "true" : "false",
        $("#audFiltro").val().trim()
    ];

    $("#audTablaCuerpo").html(
        '<tr><td colspan="6" class="admin-table__loading">' +
        'Buscando movimientos...</td></tr>'
    );

    $.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/FiltrarAuditoria",
        data: JSON.stringify({
            obj_Parametros_JS: parametros
        }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,

        success: function (msg) {
            aud_PintarTabla(msg.d || []);
        },

        error: function (xhr) {
            aud_MostrarError(xhr);
        }
    });
}

// ==========================================
// MOSTRAR RESULTADOS
// ==========================================

function aud_PintarTabla(datos) {
    var cuerpo = $("#audTablaCuerpo");
    cuerpo.empty();

    if (!datos || datos.length === 0) {
        cuerpo.append(
            $("<tr>").append(
                $("<td>")
                    .attr("colspan", 6)
                    .addClass("admin-table__loading")
                    .text("No se encontraron movimientos.")
            )
        );
        return;
    }

    $.each(datos, function (i, movimiento) {
        var fila = $("<tr>");

        $("<td>").text(movimiento.FechaHora || "")
            .appendTo(fila);

        $("<td>").text(movimiento.Usuario || "Desconocido")
            .appendTo(fila);

        $("<td>").text(movimiento.SeccionSistema || "—")
            .appendTo(fila);

        $("<td>").text(movimiento.AccionTexto ||
            movimiento.Accion || "—")
            .appendTo(fila);

        var exitoso = String(movimiento.Exitoso).toLowerCase();
        var esExitoso = exitoso === "true" || exitoso === "1";

        var estado = $("<span>")
            .addClass(esExitoso
                ? "badge badge--activo"
                : "badge badge--inactivo")
            .text(movimiento.Resultado ||
                (esExitoso ? "Exitoso" : "Fallido"));

        $("<td>").append(estado).appendTo(fila);

        var detalle = movimiento.Detalle ||
            movimiento.ElementoAfectado || "—";

        $("<td>").text(detalle).appendTo(fila);

        cuerpo.append(fila);
    });
}

// ==========================================
// OPCIONES DE SECCIÓN Y ACCIÓN
// ==========================================

function aud_CargarOpciones(datos) {
    var secciones = {};
    var acciones = {};

    $.each(datos, function (i, movimiento) {
        if (movimiento.SeccionSistema) {
            secciones[movimiento.SeccionSistema] = true;
        }

        if (movimiento.Accion) {
            acciones[movimiento.Accion] =
                movimiento.AccionTexto || movimiento.Accion;
        }
    });

    var ddlSeccion = $("#audSeccion");
    var ddlAccion = $("#audAccion");

    ddlSeccion.empty().append(
        $("<option>").val("").text("Todas las secciones")
    );

    ddlAccion.empty().append(
        $("<option>").val("").text("Todas las acciones")
    );

    Object.keys(secciones).sort().forEach(function (seccion) {
        ddlSeccion.append(
            $("<option>").val(seccion).text(seccion)
        );
    });

    Object.keys(acciones).sort().forEach(function (accion) {
        ddlAccion.append(
            $("<option>").val(accion).text(acciones[accion])
        );
    });
}

// ==========================================
// LIMPIAR FILTROS
// ==========================================

function aud_LimpiarFiltros() {
    if (!aud_SesionDisponible()) return;

    $("#audFechaInicio").val("");
    $("#audFechaFin").val("");
    $("#audSeccion").val("");
    $("#audAccion").val("");
    $("#audUsuario").val("");
    $("#audFiltro").val("");
    $("#audSoloFallidos").prop("checked", false);

    aud_Listar();
}

// ==========================================
// MENSAJES DE ERROR
// ==========================================

function aud_MostrarError(xhr) {
    $("#audTablaCuerpo").html(
        '<tr><td colspan="6" class="admin-table__loading">' +
        'No fue posible cargar los movimientos.</td></tr>'
    );

    var mensaje = "No se pudo completar la consulta.";

    if (xhr.status === 401 || xhr.status === 403 ||
        (xhr.responseJSON &&
            xhr.responseJSON.Message &&
            /sesión|autorización/i.test(xhr.responseJSON.Message))) {
        mensaje = "La consulta requiere una sesión " +
            "administrativa validada por el servidor.";
    }

    Swal.fire({
        icon: "error",
        title: "Auditoría",
        text: mensaje
    });
}
