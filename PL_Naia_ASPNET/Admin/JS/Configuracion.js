// ============================================================
//  CONFIGURACION - Editar datos de la institucion
// ============================================================

var cfg_datosInstitucion = null;

window.Configuracion_AlAbrir = function () {
    Configuracion_CargarPlanes(function () {
        Configuracion_CargarInfo();
    });
};

// ==================== CARGAR PLANES ====================
function Configuracion_CargarPlanes(callback) {
    var params = ["1"]; // SoloActivos = true

    $.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/ListarPlanes",
        data: JSON.stringify({ obj_Parametros_JS: params }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (r) {
            var sel = $("#cfg_plan");
            sel.empty();
            var datos = r.d;
            for (var i = 0; i < datos.length; i++) {
                sel.append('<option value="' + datos[i].PlanId + '">' + datos[i].NombrePlan + '</option>');
            }
            if (callback) callback();
        },
        error: function () {
            $("#cfg_plan").html('<option value="">Error al cargar planes</option>');
            if (callback) callback();
        }
    });
}

// ==================== CARGAR INFO INSTITUCION ====================
function Configuracion_CargarInfo() {
    var params = [g_InstitucionId, g_UsuarioId];

    $.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/InfoInstitucion",
        data: JSON.stringify({ obj_Parametros_JS: params }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (r) {
            var datos = r.d;
            if (datos && datos.length > 0) {
                var d = datos[0];
                cfg_datosInstitucion = d;

                $("#cfg_nombre").val(d.NombreInstitucion || '');
                $("#cfg_siglas").val(d.Siglas || '');
                $("#cfg_plan").val(d.PlanId || '');
                $("#cfg_dominio").val(d.DominioCorreo || '');
                $("#cfg_usuarios").val((d.UsuariosActivos || '0') + ' / ' + (d.MaxUsuarios || '0'));
                $("#cfg_fechaCreacion").val(d.FechaCreacion || '');

                // Detalle del plan
                $("#cfg_planNombre").val(d.NombrePlan || '');
                $("#cfg_planMaxUsuarios").val(d.MaxUsuarios || '');
                $("#cfg_planPrecio").val(d.PrecioMensual ? ('$' + d.PrecioMensual) : '');
            }
        },
        error: function () {
            Swal.fire('Error', 'No se pudo cargar la informacion de la institucion', 'error');
        }
    });
}

// ==================== GUARDAR ====================
function Configuracion_Guardar() {
    var nombre = $.trim($("#cfg_nombre").val());
    var siglas = $.trim($("#cfg_siglas").val());
    var planId = $("#cfg_plan").val();

    if (!nombre) {
        Swal.fire('Atencion', 'El nombre de la institucion es obligatorio', 'warning');
        return;
    }
    if (!siglas) {
        Swal.fire('Atencion', 'Las siglas son obligatorias', 'warning');
        return;
    }
    if (!planId) {
        Swal.fire('Atencion', 'Debe seleccionar un plan', 'warning');
        return;
    }

    var params = [
        g_InstitucionId,  // [0] InstitucionId
        g_UsuarioId,      // [1] IdUsuarioGlobal
        planId,               // [2] PlanId
        nombre,               // [3] NombreInstitucion
        siglas,               // [4] Siglas
        ""                    // [5] DireccionIp (se envia vacio, el SP puede obtenerla)
    ];

    $.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/ActualizarInstitucion",
        data: JSON.stringify({ obj_Parametros_JS: params }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (r) {
            var partes = r.d.split("<SPLITER>");
            var codigo = parseInt(partes[0]);
            var mensaje = partes[1];

            if (codigo > 0) {
                Swal.fire('Exito', mensaje, 'success');
                Configuracion_CargarInfo();
            } else {
                Swal.fire('Error', mensaje, 'error');
            }
        },
        error: function () {
            Swal.fire('Error', 'Error al guardar configuracion', 'error');
        }
    });
}
