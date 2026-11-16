// =====================================================================================
// DEPARTAMENTOS - Departamentos.js
// Prefijo: dep_
// =====================================================================================

// Hook que Panel.js llama al abrir la seccion
function Departamentos_AlAbrir() {
    dep_Listar();
}

// ==================== LISTAR ====================
function dep_Listar() {
    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;

    jQuery.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/ListarDepartamentos",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) { dep_PintarTabla(msg.d); },
        error: function () {
            $("#tbodyDepartamentos").html('<tr><td colspan="5" class="admin-table__loading">Error al cargar departamentos.</td></tr>');
        }
    });
}

// ==================== FILTRAR ====================
function dep_Filtrar() {
    var texto = $("#txtDepBuscar").val().trim();
    if (texto === "") { dep_Listar(); return; }

    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;
    obj_Parametros_JS[1] = g_UsuarioId;
    obj_Parametros_JS[2] = texto;

    jQuery.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/FiltrarDepartamentos",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) { dep_PintarTabla(msg.d); },
        error: function () {
            $("#tbodyDepartamentos").html('<tr><td colspan="5" class="admin-table__loading">Error al filtrar.</td></tr>');
        }
    });
}

// ==================== PINTAR TABLA ====================
function dep_PintarTabla(datos) {
    var html = "";
    if (!datos || datos.length === 0) {
        html = '<tr><td colspan="5" class="admin-table__loading">No se encontraron departamentos.</td></tr>';
        $("#tbodyDepartamentos").html(html);
        return;
    }

    $.each(datos, function (i, dep) {
        var claseEstado = dep.Activo === "True" ? "badge badge--activo" : "badge badge--inactivo";
        html += "<tr>";
        html += "  <td>" + dep.Nombre + "</td>";
        html += "  <td>" + (dep.Codigo || "—") + "</td>";
        html += "  <td>" + dep.CarreraNombre + "</td>";
        html += '  <td><span class="' + claseEstado + '">' + dep.EstadoTexto + "</span></td>";
        html += '  <td class="admin-table__actions-col">';
        html += '    <button class="btn-icon btn-icon--edit" type="button" title="Editar" onclick="dep_Editar(' + dep.DepartamentoId + ')">✏️</button>';
        html += '    <button class="btn-icon btn-icon--delete" type="button" title="Desactivar" onclick="dep_Eliminar(' + dep.DepartamentoId + ", '" + dep.Nombre.replace(/'/g, "\\'") + "')\">🗑️</button>";
        html += "  </td>";
        html += "</tr>";
    });

    $("#tbodyDepartamentos").html(html);
}

// ==================== CARGAR DROPDOWN DE CARRERAS ====================
function dep_CargarCarreras(callback) {
    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;

    jQuery.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/ListarCarreras",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            var datos = msg.d;
            var html = '<option value="">-- Seleccionar carrera --</option>';
            $.each(datos, function (i, car) {
                if (car.Activa === "True") {
                    html += '<option value="' + car.CarreraId + '">' + car.Nombre + '</option>';
                }
            });
            $("#ddlDepCarrera").html(html);
            if (callback) callback();
        },
        error: function () {
            Swal.fire({ icon: "error", title: "Error", text: "No se pudieron cargar las carreras." });
        }
    });
}

// ==================== MODAL NUEVO ====================
function dep_AbrirModalNuevo() {
    $("#hdnDepId").val("0");
    $("#txtDepNombre").val("");
    $("#txtDepCodigo").val("");
    $("#campoDepEstado").hide();
    $("#modalDepTitulo").text("Nuevo departamento");
    $("#btnDepGuardar").text("Guardar");

    dep_CargarCarreras(function () {
        $("#ddlDepCarrera").val("");
        $("#modalDepartamento").fadeIn(200);
    });
}

// ==================== EDITAR ====================
function dep_Editar(departamentoId) {
    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;
    obj_Parametros_JS[1] = g_UsuarioId;
    obj_Parametros_JS[2] = departamentoId.toString();

    jQuery.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/InfoDepartamento",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            var datos = msg.d;
            if (!datos || datos.length === 0) {
                Swal.fire({ icon: "error", title: "Departamentos", text: "No se encontro el departamento." });
                return;
            }
            var dep = datos[0];
            dep_CargarCarreras(function () {
                $("#hdnDepId").val(dep.DepartamentoId);
                $("#txtDepNombre").val(dep.Nombre);
                $("#txtDepCodigo").val(dep.Codigo);
                $("#ddlDepCarrera").val(dep.CarreraId);
                $("#campoDepEstado").show();
                $("#ddlDepEstado").val(dep.Activo);
                $("#modalDepTitulo").text("Editar departamento");
                $("#btnDepGuardar").text("Actualizar");
                $("#modalDepartamento").fadeIn(200);
            });
        },
        error: function () {
            Swal.fire({ icon: "error", title: "Error de conexion", text: "No se pudo cargar la informacion." });
        }
    });
}

// ==================== GUARDAR ====================
function dep_Guardar() {
    var carreraId = $("#ddlDepCarrera").val();
    var nombre = $("#txtDepNombre").val().trim();
    var codigo = $("#txtDepCodigo").val().trim();

    if (carreraId === "") {
        Swal.fire({ icon: "warning", title: "Departamentos", text: "Selecciona una carrera." });
        return;
    }
    if (nombre === "") {
        Swal.fire({ icon: "warning", title: "Departamentos", text: "El nombre es obligatorio." });
        return;
    }

    var departamentoId = $("#hdnDepId").val();
    if (departamentoId === "0") {
        dep_Insertar(carreraId, nombre, codigo);
    } else {
        var activo = $("#ddlDepEstado").val();
        dep_Actualizar(departamentoId, carreraId, nombre, codigo, activo);
    }
}

// ==================== INSERTAR ====================
function dep_Insertar(carreraId, nombre, codigo) {
    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;
    obj_Parametros_JS[1] = g_UsuarioId;
    obj_Parametros_JS[2] = carreraId;
    obj_Parametros_JS[3] = nombre;
    obj_Parametros_JS[4] = codigo;

    $("#btnDepGuardar").prop("disabled", true);
    jQuery.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/InsertarDepartamento",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            var arreglo = msg.d.split("<SPLITER>");
            if (parseInt(arreglo[0]) > 0) {
                Swal.fire({ icon: "success", title: "Departamentos", text: arreglo[1], timer: 2500, showConfirmButton: false });
                dep_CerrarModal();
                dep_Listar();
            } else {
                Swal.fire({ icon: "error", title: "Departamentos", text: arreglo[1] });
            }
            $("#btnDepGuardar").prop("disabled", false);
        },
        error: function () {
            Swal.fire({ icon: "error", title: "Error de conexion", text: "No se pudo guardar." });
            $("#btnDepGuardar").prop("disabled", false);
        }
    });
}

// ==================== ACTUALIZAR ====================
function dep_Actualizar(departamentoId, carreraId, nombre, codigo, activo) {
    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;
    obj_Parametros_JS[1] = g_UsuarioId;
    obj_Parametros_JS[2] = departamentoId;
    obj_Parametros_JS[3] = carreraId;
    obj_Parametros_JS[4] = nombre;
    obj_Parametros_JS[5] = codigo;
    obj_Parametros_JS[6] = activo;

    $("#btnDepGuardar").prop("disabled", true);
    jQuery.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/ActualizarDepartamento",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            var arreglo = msg.d.split("<SPLITER>");
            if (parseInt(arreglo[0]) > 0) {
                Swal.fire({ icon: "success", title: "Departamentos", text: arreglo[1], timer: 2500, showConfirmButton: false });
                dep_CerrarModal();
                dep_Listar();
            } else {
                Swal.fire({ icon: "error", title: "Departamentos", text: arreglo[1] });
            }
            $("#btnDepGuardar").prop("disabled", false);
        },
        error: function () {
            Swal.fire({ icon: "error", title: "Error de conexion", text: "No se pudo actualizar." });
            $("#btnDepGuardar").prop("disabled", false);
        }
    });
}

// ==================== ELIMINAR ====================
function dep_Eliminar(departamentoId, nombre) {
    Swal.fire({
        icon: "warning",
        title: "¿Desactivar departamento?",
        text: 'Se desactivara "' + nombre + '".',
        showCancelButton: true,
        confirmButtonText: "Si, desactivar",
        cancelButtonText: "Cancelar",
        confirmButtonColor: "#d33"
    }).then(function (result) {
        if (result.isConfirmed) {
            var obj_Parametros_JS = new Array();
            obj_Parametros_JS[0] = g_InstitucionId;
            obj_Parametros_JS[1] = g_UsuarioId;
            obj_Parametros_JS[2] = departamentoId.toString();

            jQuery.ajax({
                type: "POST",
                url: "frmPanelAdmin.aspx/EliminarDepartamento",
                data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                cache: false,
                success: function (msg) {
                    var arreglo = msg.d.split("<SPLITER>");
                    if (parseInt(arreglo[0]) > 0) {
                        Swal.fire({ icon: "success", title: "Departamentos", text: arreglo[1], timer: 2500, showConfirmButton: false });
                        dep_Listar();
                    } else {
                        Swal.fire({ icon: "error", title: "Departamentos", text: arreglo[1] });
                    }
                },
                error: function () {
                    Swal.fire({ icon: "error", title: "Error de conexion", text: "No se pudo desactivar." });
                }
            });
        }
    });
}

// ==================== CERRAR MODAL ====================
function dep_CerrarModal() {
    $("#modalDepartamento").fadeOut(200);
}
