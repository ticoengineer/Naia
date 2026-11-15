// ============================================================
//  AUDITORIA - Seccion de solo lectura con filtros
// ============================================================

window.Auditoria_AlAbrir = function () {
    Auditoria_Listar();
};

// ==================== LISTAR ====================
function Auditoria_Listar() {
    var params = [SesionInstitucion(), SesionUsuario()];

    $.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/ListarAuditoria",
        data: JSON.stringify({ obj_Parametros_JS: params }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (r) {
            Auditoria_RenderTabla(r.d);
        },
        error: function () {
            $("#aud_tbody").html('<tr><td colspan="8" class="text-center text-danger">Error al cargar auditoria</td></tr>');
        }
    });
}

// ==================== FILTRAR ====================
function Auditoria_Filtrar() {
    var fechaInicio = $("#aud_fechaInicio").val();
    var fechaFin = $("#aud_fechaFin").val();
    var seccion = $("#aud_seccion").val();
    var accion = $("#aud_accion").val();
    var resultado = $("#aud_resultado").val();
    var filtro = $.trim($("#aud_txtBuscar").val());

    // Si no hay filtros activos, listar todo
    if (!fechaInicio && !fechaFin && !seccion && !accion && resultado === "-1" && !filtro) {
        Auditoria_Listar();
        return;
    }

    var params = [
        SesionInstitucion(),  // [0]
        SesionUsuario(),      // [1]
        fechaInicio,          // [2] FechaInicio
        fechaFin,             // [3] FechaFin
        seccion,              // [4] SeccionSistema
        accion,               // [5] Accion
        "0",                  // [6] UsuarioId (0 = todos)
        resultado,            // [7] Exitoso (-1 = todos)
        filtro                // [8] Filtro texto
    ];

    $.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/FiltrarAuditoria",
        data: JSON.stringify({ obj_Parametros_JS: params }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (r) {
            Auditoria_RenderTabla(r.d);
        },
        error: function () {
            $("#aud_tbody").html('<tr><td colspan="8" class="text-center text-danger">Error al filtrar auditoria</td></tr>');
        }
    });
}

// ==================== RENDER TABLA ====================
function Auditoria_RenderTabla(datos) {
    var tbody = $("#aud_tbody");
    tbody.empty();

    if (!datos || datos.length === 0) {
        tbody.html('<tr><td colspan="8" class="text-center">No se encontraron registros</td></tr>');
        return;
    }

    for (var i = 0; i < datos.length; i++) {
        var d = datos[i];
        var claseResultado = d.Exitoso === "True" ? "text-success" : "text-danger";
        var textoResultado = d.Resultado || (d.Exitoso === "True" ? "Exitoso" : "Fallido");

        var fila = '<tr>' +
            '<td>' + (d.FechaHora || d.Fecha || '') + '</td>' +
            '<td>' + (d.Usuario || '') + '</td>' +
            '<td>' + (d.AccionTexto || d.Accion || '') + '</td>' +
            '<td>' + (d.SeccionSistema || '') + '</td>' +
            '<td>' + (d.ElementoAfectado || '') + '</td>' +
            '<td>' + (d.Detalle || '') + '</td>' +
            '<td class="' + claseResultado + '">' + textoResultado + '</td>' +
            '<td>' + (d.DireccionIp || '') + '</td>' +
            '</tr>';
        tbody.append(fila);
    }
}

// ==================== LIMPIAR FILTROS ====================
function Auditoria_LimpiarFiltros() {
    $("#aud_fechaInicio").val('');
    $("#aud_fechaFin").val('');
    $("#aud_seccion").val('');
    $("#aud_accion").val('');
    $("#aud_resultado").val('-1');
    $("#aud_txtBuscar").val('');
    Auditoria_Listar();
}
