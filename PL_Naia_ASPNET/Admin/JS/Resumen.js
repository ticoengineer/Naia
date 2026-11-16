// ============================================================
//  RESUMEN - Dashboard con totales y actividad reciente
// ============================================================

window.Resumen_AlAbrir = function () {
    Resumen_CargarTotales();
    Resumen_CargarActividad();
};

// ==================== CARGAR TOTALES ====================
function Resumen_CargarTotales() {
    if (!ValidarSesion()) return;

    var params = [g_InstitucionId, g_UsuarioId];

    // Usuarios
    $.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/ListarUsuarios",
        data: JSON.stringify({ obj_Parametros_JS: params }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (r) {
            var activos = 0;
            if (r.d) {
                for (var i = 0; i < r.d.length; i++) {
                    if (r.d[i].Activo === "True") activos++;
                }
            }
            $("#res_totalUsuarios").text(activos);
        }
    });

    // Equipos
    $.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/ListarEquipos",
        data: JSON.stringify({ obj_Parametros_JS: params }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (r) {
            var activos = 0;
            if (r.d) {
                for (var i = 0; i < r.d.length; i++) {
                    if (r.d[i].Activo === "True") activos++;
                }
            }
            $("#res_totalEquipos").text(activos);
        }
    });

    // Carreras
    $.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/ListarCarreras",
        data: JSON.stringify({ obj_Parametros_JS: params }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (r) {
            var activos = 0;
            if (r.d) {
                for (var i = 0; i < r.d.length; i++) {
                    if (r.d[i].Activo === "True") activos++;
                }
            }
            $("#res_totalCarreras").text(activos);
        }
    });

    // Departamentos
    $.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/ListarDepartamentos",
        data: JSON.stringify({ obj_Parametros_JS: params }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (r) {
            var activos = 0;
            if (r.d) {
                for (var i = 0; i < r.d.length; i++) {
                    if (r.d[i].Activo === "True") activos++;
                }
            }
            $("#res_totalDepartamentos").text(activos);
        }
    });

    // Ubicaciones
    $.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/ListarUbicaciones",
        data: JSON.stringify({ obj_Parametros_JS: params }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (r) {
            var activos = 0;
            if (r.d) {
                for (var i = 0; i < r.d.length; i++) {
                    if (r.d[i].Activo === "True") activos++;
                }
            }
            $("#res_totalUbicaciones").text(activos);
        }
    });

    // Categorias
    $.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/ListarCategorias",
        data: JSON.stringify({ obj_Parametros_JS: params }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (r) {
            var activos = 0;
            if (r.d) {
                for (var i = 0; i < r.d.length; i++) {
                    if (r.d[i].Activo === "True") activos++;
                }
            }
            $("#res_totalCategorias").text(activos);
        }
    });

    // Info Institucion
    $.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/InfoInstitucion",
        data: JSON.stringify({ obj_Parametros_JS: params }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (r) {
            if (r.d && r.d.length > 0) {
                var d = r.d[0];
                $("#res_institucion").text(d.Siglas || d.NombreInstitucion || '-');
                $("#res_planActual").text(d.NombrePlan || '-');
            }
        }
    });
}

// ==================== CARGAR ACTIVIDAD RECIENTE ====================
function Resumen_CargarActividad() {
    if (!ValidarSesion()) return;

    var params = [g_InstitucionId, g_UsuarioId];

    $.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/ListarAuditoria",
        data: JSON.stringify({ obj_Parametros_JS: params }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (r) {
            var tbody = $("#res_tbody_actividad");
            tbody.empty();

            var datos = r.d;
            if (!datos || datos.length === 0) {
                tbody.html('<tr><td colspan="5" class="text-center">Sin actividad reciente</td></tr>');
                return;
            }

            // Mostrar solo los ultimos 10 registros
            var limite = Math.min(datos.length, 10);
            for (var i = 0; i < limite; i++) {
                var d = datos[i];
                var claseRes = d.Exitoso === "True" ? "text-success" : "text-danger";
                var textoRes = d.Resultado || (d.Exitoso === "True" ? "Exitoso" : "Fallido");

                var fila = '<tr>' +
                    '<td>' + (d.FechaHora || d.Fecha || '') + '</td>' +
                    '<td>' + (d.Usuario || '') + '</td>' +
                    '<td>' + (d.AccionTexto || d.Accion || '') + '</td>' +
                    '<td>' + (d.SeccionSistema || '') + '</td>' +
                    '<td class="' + claseRes + '">' + textoRes + '</td>' +
                    '</tr>';
                tbody.append(fila);
            }
        },
        error: function () {
            $("#res_tbody_actividad").html('<tr><td colspan="5" class="text-center text-danger">Error al cargar actividad</td></tr>');
        }
    });
}
