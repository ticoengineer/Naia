// =====================================================================================
// DEPARTAMENTOS - Departamentos.js
// Prefijo: dep_
// Flujo: HTML (ucDepartamentos.ascx) → JS → WebMethod (frmPanelAdmin.Departamentos.cs) → BLL → SP
// Editar solo cambia el nombre. Desactivar (🗑️) y Activar (♻️) van por los botones de la tabla.
// "Administración General" no muestra botones: es el departamento de los administrativos (el SP también lo protege).
// =====================================================================================

var dep_activoActual = "true";   // al editar se conserva el estado que ya tenía

// Hook que Panel.js llama al abrir la seccion
function Departamentos_AlAbrir() {
    dep_Listar();
}

// ==================== LISTAR ====================
function dep_Listar() {
    if (!ValidarSesion()) return;

    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;   // @InstitucionId

    jQuery.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/ListarDepartamentos",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) { dep_PintarTabla(msg.d); },
        error: function () {
            $("#tbodyDepartamentos").html('<tr><td colspan="4" class="admin-table__loading">Error al cargar departamentos.</td></tr>');
        }
    });
}

// ==================== FILTRAR ====================
function dep_Filtrar() {
    if (!ValidarSesion()) return;

    var texto = $("#txtDepBuscar").val().trim();
    if (texto === "") { dep_Listar(); return; }

    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;   // @InstitucionId
    obj_Parametros_JS[1] = g_UsuarioId;
    obj_Parametros_JS[2] = texto;             // @Filtro

    jQuery.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/FiltrarDepartamentos",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) { dep_PintarTabla(msg.d); },
        error: function () {
            $("#tbodyDepartamentos").html('<tr><td colspan="4" class="admin-table__loading">Error al filtrar.</td></tr>');
        }
    });
}

// ==================== PINTAR TABLA ====================
function dep_PintarTabla(datos) {
    if (!datos || datos.length === 0) {
        $("#tbodyDepartamentos").html('<tr><td colspan="4" class="admin-table__loading">No se encontraron departamentos.</td></tr>');
        return;
    }

    var html = "";
    $.each(datos, function (i, dep) {
        var activo = dep.Activo === "True";
        var claseEstado = activo ? "badge badge--activo" : "badge badge--inactivo";

        // Activo → 🗑️ Desactivar · Inactivo → ♻️ Activar
        var botonEstado = activo
            ? '<button class="btn-icon btn-icon--delete" type="button" title="Desactivar" data-nombre="' + dep_Esc(dep.Nombre) + '"' +
            ' onclick="dep_Eliminar(' + dep.DepartamentoId + ', this.getAttribute(\'data-nombre\'))">🗑️</button>'
            : '<button class="btn-icon btn-icon--activar" type="button" title="Activar" data-nombre="' + dep_Esc(dep.Nombre) + '"' +
            ' onclick="dep_Activar(' + dep.DepartamentoId + ', this.getAttribute(\'data-nombre\'))">♻️</button>';

        html += "<tr>";
        html += "  <td>" + dep_Esc(dep.Nombre) + "</td>";
        html += "  <td>" + dep_Esc(dep.UsuariosActivos) + "</td>";
        html += '  <td><span class="' + claseEstado + '">' + dep_Esc(dep.EstadoTexto) + "</span></td>";
        html += '  <td class="admin-table__actions-col">';
        if (dep.Nombre === "Administración General") {
            // Lo crea el registro de la universidad y es el departamento de los administrativos
            html += '    <span class="badge" title="Lo crea el registro de la universidad">Predeterminado</span>';
        } else {
            html += '    <button class="btn-icon btn-icon--edit" type="button" title="Editar" onclick="dep_Editar(' + dep.DepartamentoId + ')">✏️</button>';
            html += "    " + botonEstado;
        }
        html += "  </td>";
        html += "</tr>";
    });

    $("#tbodyDepartamentos").html(html);
}

// ==================== MODAL NUEVO ====================
function dep_AbrirModalNuevo() {
    dep_activoActual = "true";
    $("#hdnDepId").val("0");
    $("#txtDepNombre").val("");
    $("#modalDepTitulo").text("Nuevo departamento");
    $("#btnDepGuardar").text("Guardar");
    $("#modalDepartamento").fadeIn(200);
}

// ==================== EDITAR ====================
function dep_Editar(departamentoId) {
    if (!ValidarSesion()) return;

    dep_ObtenerInfo(departamentoId, function (dep) {
        // El estado no se edita aquí: se guarda tal cual estaba
        dep_activoActual = dep.Activo === "True" ? "true" : "false";
        $("#hdnDepId").val(dep.DepartamentoId);
        $("#txtDepNombre").val(dep.Nombre);
        $("#modalDepTitulo").text("Editar departamento");
        $("#btnDepGuardar").text("Actualizar");
        $("#modalDepartamento").fadeIn(200);
    });
}

// Pide un departamento (SP_INFO_DEPARTAMENTO) y llama a alTerminar(departamento)
function dep_ObtenerInfo(departamentoId, alTerminar) {
    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;          // @InstitucionId
    obj_Parametros_JS[1] = g_UsuarioId;
    obj_Parametros_JS[2] = departamentoId.toString();     // @DepartamentoId

    jQuery.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/InfoDepartamento",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            if (!msg.d || msg.d.length === 0) {
                Swal.fire({ icon: "error", title: "Departamentos", text: "No se encontró el departamento." });
                return;
            }
            alTerminar(msg.d[0]);
        },
        error: function () {
            Swal.fire({ icon: "error", title: "Error de conexión", text: "No se pudo cargar la información." });
        }
    });
}

// ==================== GUARDAR ====================
function dep_Guardar() {
    var nombre = $("#txtDepNombre").val().trim();

    if (nombre === "") {
        Swal.fire({ icon: "warning", title: "Departamentos", text: "El nombre es obligatorio." });
        return;
    }

    var departamentoId = $("#hdnDepId").val();
    if (departamentoId === "0") {
        dep_Insertar(nombre);
    } else {
        dep_Actualizar(departamentoId, nombre, dep_activoActual, false);
    }
}

// ==================== INSERTAR ====================
function dep_Insertar(nombre) {
    if (!ValidarSesion()) return;

    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;   // @InstitucionId
    obj_Parametros_JS[1] = g_UsuarioId;       // @IdUsuarioGlobal
    obj_Parametros_JS[2] = nombre;            // @Nombre

    $("#btnDepGuardar").prop("disabled", true);

    jQuery.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/InsertarDepartamento",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            $("#btnDepGuardar").prop("disabled", false);
            var arreglo = msg.d.split("<SPLITER>");
            if (parseInt(arreglo[0]) > 0) {
                Swal.fire({ icon: "success", title: "Departamentos", text: arreglo[1], timer: 2500, showConfirmButton: false });
                dep_CerrarModal();
                dep_Listar();
            } else {
                Swal.fire({ icon: "error", title: "Departamentos", text: arreglo[1] });
            }
        },
        error: function () {
            $("#btnDepGuardar").prop("disabled", false);
            Swal.fire({ icon: "error", title: "Error de conexión", text: "No se pudo guardar el departamento." });
        }
    });
}

// ==================== ACTUALIZAR ====================
// Lo usan "Editar" (manda el estado que ya tenía) y "Activar" (manda "true").
function dep_Actualizar(departamentoId, nombre, activo, esActivacion) {
    if (!ValidarSesion()) return;

    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;   // @InstitucionId
    obj_Parametros_JS[1] = g_UsuarioId;       // @IdUsuarioGlobal
    obj_Parametros_JS[2] = departamentoId;         // @DepartamentoId
    obj_Parametros_JS[3] = nombre;            // @Nombre
    obj_Parametros_JS[4] = activo;            // @Activo ("true"/"false")

    $("#btnDepGuardar").prop("disabled", true);

    jQuery.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/ActualizarDepartamento",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            $("#btnDepGuardar").prop("disabled", false);
            var arreglo = msg.d.split("<SPLITER>");
            if (parseInt(arreglo[0]) > 0) {
                var texto = esActivacion ? 'El departamento "' + nombre + '" está activo de nuevo.' : arreglo[1];
                Swal.fire({ icon: "success", title: "Departamentos", text: texto, timer: 2500, showConfirmButton: false });
                dep_CerrarModal();
                dep_Listar();
            } else {
                Swal.fire({ icon: "error", title: "Departamentos", text: arreglo[1] });
            }
        },
        error: function () {
            $("#btnDepGuardar").prop("disabled", false);
            Swal.fire({ icon: "error", title: "Error de conexión", text: "No se pudo actualizar el departamento." });
        }
    });
}

// ==================== ACTIVAR ====================
// No hay SP de "activar": SP_ACTUALIZA_DEPARTAMENTOS con el mismo nombre y Activo = 1.
// En auditoría queda "Estado: Inactivo → Activo".
function dep_Activar(departamentoId, nombre) {
    if (!ValidarSesion()) return;

    Swal.fire({
        icon: "question",
        title: "¿Activar departamento?",
        text: 'El departamento "' + nombre + '" volverá a aparecer al crear y editar usuarios.',
        showCancelButton: true,
        confirmButtonText: "Sí, activar",
        cancelButtonText: "Cancelar"
    }).then(function (result) {
        if (!result.isConfirmed) return;

        dep_ObtenerInfo(departamentoId, function (dep) {
            dep_Actualizar(dep.DepartamentoId, dep.Nombre, "true", true);
        });
    });
}

// ==================== ELIMINAR (DESACTIVAR) ====================
function dep_Eliminar(departamentoId, nombre) {
    if (!ValidarSesion()) return;

    Swal.fire({
        icon: "warning",
        title: "¿Desactivar departamento?",
        text: 'Se desactivará "' + nombre + '". Podrás activarlo de nuevo con el botón ♻️.',
        showCancelButton: true,
        confirmButtonText: "Sí, desactivar",
        cancelButtonText: "Cancelar",
        confirmButtonColor: "#d33"
    }).then(function (result) {
        if (!result.isConfirmed) return;

        var obj_Parametros_JS = new Array();
        obj_Parametros_JS[0] = g_InstitucionId;          // @InstitucionId
        obj_Parametros_JS[1] = g_UsuarioId;              // @IdUsuarioGlobal
        obj_Parametros_JS[2] = departamentoId.toString();     // @DepartamentoId

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
                Swal.fire({ icon: "error", title: "Error de conexión", text: "No se pudo desactivar el departamento." });
            }
        });
    });
}

// ==================== CERRAR MODAL ====================
function dep_CerrarModal() {
    $("#modalDepartamento").fadeOut(200);
}

// Escapa el texto antes de meterlo en el HTML (los nombres los escribe el admin)
function dep_Esc(texto) {
    return $("<div>").text(texto == null ? "" : String(texto)).html();
}
