// ==================== EQUIPOS DE SOPORTE ====================

var eqp_esEdicion = false;

// Función que Panel.js llama al abrir la sección
window.Equipos_AlAbrir = function () {
    Equipos_Listar();
};

// -------------------- LISTAR --------------------
function Equipos_Listar() {
    var params = [g_InstitucionId];

    $.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/ListarEquiposTodos",
        data: JSON.stringify({ obj_Parametros_JS: params }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (r) {
            Equipos_RenderTabla(r.d);
        },
        error: function () {
            $("#eqp_tbodyEquipos").html('<tr><td colspan="5" class="text-center">Error al cargar los equipos.</td></tr>');
        }
    });
}

// -------------------- FILTRAR --------------------
function Equipos_Filtrar() {
    var filtro = $.trim($("#eqp_txtFiltro").val());
    if (filtro.length === 0) {
        Equipos_Listar();
        return;
    }

    var params = [g_InstitucionId, g_UsuarioId, filtro];

    $.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/FiltrarEquipos",
        data: JSON.stringify({ obj_Parametros_JS: params }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (r) {
            Equipos_RenderTabla(r.d);
        },
        error: function () {
            $("#eqp_tbodyEquipos").html('<tr><td colspan="5" class="text-center">Error al filtrar los equipos.</td></tr>');
        }
    });
}

// -------------------- RENDER TABLA --------------------
function Equipos_RenderTabla(datos) {
    var tbody = $("#eqp_tbodyEquipos");
    tbody.empty();

    if (!datos || datos.length === 0) {
        tbody.html('<tr><td colspan="5" class="text-center">No se encontraron equipos.</td></tr>');
        return;
    }

    for (var i = 0; i < datos.length; i++) {
        var eq = datos[i];
        var claseEstado = eq.Activo === "True" ? "estado-activo" : "estado-inactivo";

        var fila = '<tr>' +
            '<td>' + eq.Equipo + '</td>' +
            '<td>' + (eq.Descripcion || '-') + '</td>' +
            '<td class="text-center">' + eq.TecnicosActivos + '</td>' +
            '<td><span class="' + claseEstado + '">' + eq.EstadoTexto + '</span></td>' +
            '<td class="acciones">' +
                '<button type="button" class="btn btn-sm btn-editar" onclick="Equipos_Editar(' + eq.EquipoId + ')" title="Editar"><i class="fa fa-pencil"></i></button> ' +
                '<button type="button" class="btn btn-sm btn-eliminar" onclick="Equipos_Eliminar(' + eq.EquipoId + ', \'' + eq.Equipo.replace(/'/g, "\\'") + '\')" title="Desactivar"><i class="fa fa-trash"></i></button>' +
            '</td>' +
            '</tr>';

        tbody.append(fila);
    }
}

// -------------------- ABRIR MODAL NUEVO --------------------
function Equipos_AbrirModalNuevo() {
    eqp_esEdicion = false;
    $("#eqp_modalTitulo").text("Nuevo Equipo");
    $("#eqp_hdnEquipoId").val("0");
    $("#eqp_txtNombre").val("");
    $("#eqp_txtDescripcion").val("");
    $("#eqp_ddlEstado").val("true");
    $("#eqp_grupoEstado").hide();
    $("#eqp_modal").fadeIn(200);
}

// -------------------- EDITAR --------------------
function Equipos_Editar(equipoId) {
    var params = [g_InstitucionId, g_UsuarioId, equipoId.toString()];

    $.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/InfoEquipo",
        data: JSON.stringify({ obj_Parametros_JS: params }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (r) {
            if (r.d && r.d.length > 0) {
                var eq = r.d[0];
                eqp_esEdicion = true;
                $("#eqp_modalTitulo").text("Editar Equipo");
                $("#eqp_hdnEquipoId").val(eq.EquipoId);
                $("#eqp_txtNombre").val(eq.Equipo);
                $("#eqp_txtDescripcion").val(eq.Descripcion || "");
                $("#eqp_ddlEstado").val(eq.Activo);
                $("#eqp_grupoEstado").show();
                $("#eqp_modal").fadeIn(200);
            } else {
                Swal.fire("Error", "No se pudo obtener la informacion del equipo.", "error");
            }
        },
        error: function () {
            Swal.fire("Error", "Error al obtener la informacion del equipo.", "error");
        }
    });
}

// -------------------- GUARDAR (INSERTAR / ACTUALIZAR) --------------------
function Equipos_Guardar() {
    var nombre = $.trim($("#eqp_txtNombre").val());
    if (nombre.length === 0) {
        Swal.fire("Atencion", "El nombre del equipo es obligatorio.", "warning");
        return;
    }

    var descripcion = $.trim($("#eqp_txtDescripcion").val());
    var params;
    var metodo;

    if (eqp_esEdicion) {
        var equipoId = $("#eqp_hdnEquipoId").val();
        var activo = $("#eqp_ddlEstado").val();
        params = [g_InstitucionId, g_UsuarioId, equipoId, nombre, descripcion, activo];
        metodo = "ActualizarEquipo";
    } else {
        params = [g_InstitucionId, g_UsuarioId, nombre, descripcion];
        metodo = "InsertarEquipo";
    }

    $.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/" + metodo,
        data: JSON.stringify({ obj_Parametros_JS: params }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (r) {
            var partes = r.d.split("<SPLITER>");
            var codigo = partes[0];
            var mensaje = partes[1];

            if (parseInt(codigo) > 0) {
                Swal.fire("Exito", mensaje, "success");
                Equipos_CerrarModal();
                Equipos_Listar();
            } else {
                Swal.fire("Error", mensaje, "error");
            }
        },
        error: function () {
            Swal.fire("Error", "Ocurrio un error inesperado. Intenta de nuevo.", "error");
        }
    });
}

// -------------------- ELIMINAR (DESACTIVAR) --------------------
function Equipos_Eliminar(equipoId, nombre) {
    Swal.fire({
        title: "Desactivar equipo",
        text: "¿Estas seguro de desactivar el equipo \"" + nombre + "\"?",
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#d33",
        confirmButtonText: "Si, desactivar",
        cancelButtonText: "Cancelar"
    }).then(function (result) {
        if (result.isConfirmed) {
            var params = [g_InstitucionId, g_UsuarioId, equipoId.toString()];

            $.ajax({
                type: "POST",
                url: "frmPanelAdmin.aspx/EliminarEquipo",
                data: JSON.stringify({ obj_Parametros_JS: params }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (r) {
                    var partes = r.d.split("<SPLITER>");
                    var codigo = partes[0];
                    var mensaje = partes[1];

                    if (parseInt(codigo) > 0) {
                        Swal.fire("Desactivado", mensaje, "success");
                        Equipos_Listar();
                    } else {
                        Swal.fire("Error", mensaje, "error");
                    }
                },
                error: function () {
                    Swal.fire("Error", "Ocurrio un error inesperado. Intenta de nuevo.", "error");
                }
            });
        }
    });
}

// -------------------- CERRAR MODAL --------------------
function Equipos_CerrarModal() {
    $("#eqp_modal").fadeOut(200);
}
