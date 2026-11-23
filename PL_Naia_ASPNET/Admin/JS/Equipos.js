// ==================== EQUIPOS DE SOPORTE ====================

var eqp_esEdicion = false;
var eqp_activoActual = "true";   // al editar se conserva el estado: activar/desactivar va por los botones de la tabla

// Función que Panel.js llama al abrir la sección
window.Equipos_AlAbrir = function () {
    Equipos_Listar();
};

// -------------------- LISTAR --------------------
function Equipos_Listar() {
    if (!ValidarSesion()) return;

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
            $("#eqp_tbodyEquipos").html('<tr><td colspan="5" class="admin-table__loading">Error al cargar los equipos.</td></tr>');
        }
    });
}

// -------------------- FILTRAR --------------------
function Equipos_Filtrar() {
    if (!ValidarSesion()) return;

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
            $("#eqp_tbodyEquipos").html('<tr><td colspan="5" class="admin-table__loading">Error al filtrar los equipos.</td></tr>');
        }
    });
}

// -------------------- RENDER TABLA --------------------
// Mismas clases que Carreras/Departamentos (panel-admin.css). Los textos van escapados con eqp_Esc.
function Equipos_RenderTabla(datos) {
    var tbody = $("#eqp_tbodyEquipos");

    if (!datos || datos.length === 0) {
        tbody.html('<tr><td colspan="5" class="admin-table__loading">No se encontraron equipos.</td></tr>');
        return;
    }

    var html = "";
    for (var i = 0; i < datos.length; i++) {
        var eq = datos[i];
        var claseEstado = eq.Activo === "True" ? "badge badge--active" : "badge badge--inactive";

        html += '<tr class="fila-clic" data-id="' + eq.EquipoId + '" title="Clic para ver los técnicos de este equipo">' +
            '<td>' + eqp_Esc(eq.Equipo) + '</td>' +
            '<td>' + (eq.Descripcion ? eqp_Esc(eq.Descripcion) : '\u2014') + '</td>' +
            '<td>' + eqp_Esc(eq.TecnicosActivos) + '</td>' +
            '<td><span class="' + claseEstado + '">' + eqp_Esc(eq.EstadoTexto) + '</span></td>' +
            '<td class="admin-table__actions-col">' +
            '<button class="btn-icon btn-icon--edit" type="button" title="Editar" onclick="Equipos_Editar(' + eq.EquipoId + ')">\u270F\uFE0F</button>' +
            (eq.Activo === "True"
                ? '<button class="btn-icon btn-icon--delete" type="button" title="Desactivar" data-nombre="' + eqp_Esc(eq.Equipo) + '"' +
                ' onclick="Equipos_Eliminar(' + eq.EquipoId + ', this.getAttribute(\'data-nombre\'))">\uD83D\uDDD1\uFE0F</button>'
                : '<button class="btn-icon btn-icon--activar" type="button" title="Activar" data-nombre="' + eqp_Esc(eq.Equipo) + '"' +
                ' onclick="Equipos_Activar(' + eq.EquipoId + ', this.getAttribute(\'data-nombre\'))">\u267B\uFE0F</button>') +
            '</td>' +
            '</tr>';
    }
    tbody.html(html);
}

// Escapa el texto antes de meterlo en el HTML (los nombres los escribe el admin)
function eqp_Esc(texto) {
    return $("<div>").text(texto == null ? "" : String(texto)).html();
}

// -------------------- ABRIR MODAL NUEVO --------------------
function Equipos_AbrirModalNuevo() {
    eqp_esEdicion = false;
    $("#eqp_modalTitulo").text("Nuevo equipo");
    $("#eqp_hdnEquipoId").val("0");
    $("#eqp_txtNombre").val("");
    $("#eqp_txtDescripcion").val("");
    eqp_activoActual = "true";
    $("#eqp_modal").fadeIn(200);
}

// -------------------- EDITAR --------------------
function Equipos_Editar(equipoId) {
    if (!ValidarSesion()) return;

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
                $("#eqp_modalTitulo").text("Editar equipo");
                $("#eqp_hdnEquipoId").val(eq.EquipoId);
                $("#eqp_txtNombre").val(eq.Equipo);
                $("#eqp_txtDescripcion").val(eq.Descripcion || "");
                // El estado no se edita aquí: se guarda tal cual estaba
                eqp_activoActual = (eq.Activo === "True") ? "true" : "false";
                $("#eqp_modal").fadeIn(200);
            } else {
                Swal.fire("Error", "No se pudo obtener la información del equipo.", "error");
            }
        },
        error: function () {
            Swal.fire("Error", "Error al obtener la información del equipo.", "error");
        }
    });
}

// -------------------- GUARDAR (INSERTAR / ACTUALIZAR) --------------------
function Equipos_Guardar() {
    if (!ValidarSesion()) return;

    var nombre = $.trim($("#eqp_txtNombre").val());
    if (nombre.length === 0) {
        Swal.fire("Atención", "El nombre del equipo es obligatorio.", "warning");
        return;
    }

    var descripcion = $.trim($("#eqp_txtDescripcion").val());
    var params;
    var metodo;

    if (eqp_esEdicion) {
        var equipoId = $("#eqp_hdnEquipoId").val();
        var activo = eqp_activoActual;   // editar NO cambia el estado
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
                Swal.fire("Éxito", mensaje, "success");
                Equipos_CerrarModal();
                Equipos_Listar();
            } else {
                Swal.fire("Error", mensaje, "error");
            }
        },
        error: function () {
            Swal.fire("Error", "Ocurrió un error inesperado. Intenta de nuevo.", "error");
        }
    });
}

// -------------------- ELIMINAR (DESACTIVAR) --------------------
function Equipos_Eliminar(equipoId, nombre) {
    if (!ValidarSesion()) return;

    Swal.fire({
        title: "Desactivar equipo",
        text: "¿Estás seguro de desactivar el equipo \"" + nombre + "\"?",
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#d33",
        confirmButtonText: "Sí, desactivar",
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
                    Swal.fire("Error", "Ocurrió un error inesperado. Intenta de nuevo.", "error");
                }
            });
        }
    });
}

// -------------------- ACTIVAR (reactivar un equipo desactivado) --------------------
// No hay SP de "activar": se usa SP_ACTUALIZA_EQUIPOS con Activo = 1 y el mismo nombre y descripción.
// El SP deja en auditoría "Estado: Inactivo → Activo".
function Equipos_Activar(equipoId, nombre) {
    if (!ValidarSesion()) return;

    Swal.fire({
        title: "Activar equipo",
        text: "¿Quieres activar de nuevo el equipo \"" + nombre + "\"? Volverá a aparecer al asignar técnicos y categorías.",
        icon: "question",
        showCancelButton: true,
        confirmButtonText: "Sí, activar",
        cancelButtonText: "Cancelar"
    }).then(function (result) {
        if (!result.isConfirmed) return;

        // 1) Datos actuales del equipo
        $.ajax({
            type: "POST",
            url: "frmPanelAdmin.aspx/InfoEquipo",
            data: JSON.stringify({ obj_Parametros_JS: [g_InstitucionId, g_UsuarioId, equipoId.toString()] }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (r) {
                if (!r.d || r.d.length === 0) {
                    Swal.fire("Error", "No se pudo obtener la información del equipo.", "error");
                    return;
                }
                var eq = r.d[0];

                // 2) Mismo nombre y descripción, Activo = true
                var params = [g_InstitucionId, g_UsuarioId, eq.EquipoId, eq.Equipo, eq.Descripcion || "", "true"];

                $.ajax({
                    type: "POST",
                    url: "frmPanelAdmin.aspx/ActualizarEquipo",
                    data: JSON.stringify({ obj_Parametros_JS: params }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (r2) {
                        var partes = r2.d.split("<SPLITER>");
                        if (parseInt(partes[0]) > 0) {
                            Swal.fire("Activado", "El equipo \"" + nombre + "\" está activo de nuevo.", "success");
                            Equipos_Listar();
                        } else {
                            Swal.fire("Error", partes[1], "error");
                        }
                    },
                    error: function () {
                        Swal.fire("Error", "Ocurrió un error inesperado. Intenta de nuevo.", "error");
                    }
                });
            },
            error: function () {
                Swal.fire("Error", "Error al obtener la información del equipo.", "error");
            }
        });
    });
}

// -------------------- CERRAR MODAL --------------------
function Equipos_CerrarModal() {
    $("#eqp_modal").fadeOut(200);
}
