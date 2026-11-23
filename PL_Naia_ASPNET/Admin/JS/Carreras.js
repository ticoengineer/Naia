// =====================================================================================
// CARRERAS - Carreras.js
// Prefijo: car_
// Flujo: HTML (ucCarreras.ascx) → JS → WebMethod (frmPanelAdmin.Carreras.cs) → BLL → SP
// Editar solo cambia el nombre. Desactivar (🗑️) y Activar (♻️) van por los botones de la tabla.
// =====================================================================================

var car_activaActual = "true";   // al editar se conserva el estado que ya tenía

// Hook que Panel.js llama al abrir la seccion
function Carreras_AlAbrir() {
    car_Listar();
}

// ==================== LISTAR ====================
function car_Listar() {
    if (!ValidarSesion()) return;

    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;   // @InstitucionId

    jQuery.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/ListarCarreras",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) { car_PintarTabla(msg.d); },
        error: function () {
            $("#tbodyCarreras").html('<tr><td colspan="4" class="admin-table__loading">Error al cargar carreras.</td></tr>');
        }
    });
}

// ==================== FILTRAR ====================
function car_Filtrar() {
    if (!ValidarSesion()) return;

    var texto = $("#txtCarBuscar").val().trim();
    if (texto === "") { car_Listar(); return; }

    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;   // @InstitucionId
    obj_Parametros_JS[1] = g_UsuarioId;
    obj_Parametros_JS[2] = texto;             // @Filtro

    jQuery.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/FiltrarCarreras",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) { car_PintarTabla(msg.d); },
        error: function () {
            $("#tbodyCarreras").html('<tr><td colspan="4" class="admin-table__loading">Error al filtrar.</td></tr>');
        }
    });
}

// ==================== PINTAR TABLA ====================
function car_PintarTabla(datos) {
    if (!datos || datos.length === 0) {
        $("#tbodyCarreras").html('<tr><td colspan="4" class="admin-table__loading">No se encontraron carreras.</td></tr>');
        return;
    }

    var html = "";
    $.each(datos, function (i, car) {
        var activa = car.Activa === "True";
        var claseEstado = activa ? "badge badge--activo" : "badge badge--inactivo";

        // Activa → 🗑️ Desactivar · Inactiva → ♻️ Activar
        var botonEstado = activa
            ? '<button class="btn-icon btn-icon--delete" type="button" title="Desactivar" data-nombre="' + car_Esc(car.Nombre) + '"' +
            ' onclick="car_Eliminar(' + car.CarreraId + ', this.getAttribute(\'data-nombre\'))">🗑️</button>'
            : '<button class="btn-icon btn-icon--activar" type="button" title="Activar" data-nombre="' + car_Esc(car.Nombre) + '"' +
            ' onclick="car_Activar(' + car.CarreraId + ', this.getAttribute(\'data-nombre\'))">♻️</button>';

        html += "<tr>";
        html += "  <td>" + car_Esc(car.Nombre) + "</td>";
        html += "  <td>" + car_Esc(car.UsuariosActivos) + "</td>";
        html += '  <td><span class="' + claseEstado + '">' + car_Esc(car.EstadoTexto) + "</span></td>";
        html += '  <td class="admin-table__actions-col">';
        html += '    <button class="btn-icon btn-icon--edit" type="button" title="Editar" onclick="car_Editar(' + car.CarreraId + ')">✏️</button>';
        html += "    " + botonEstado;
        html += "  </td>";
        html += "</tr>";
    });

    $("#tbodyCarreras").html(html);
}

// ==================== MODAL NUEVO ====================
function car_AbrirModalNuevo() {
    car_activaActual = "true";
    $("#hdnCarId").val("0");
    $("#txtCarNombre").val("");
    $("#modalCarTitulo").text("Nueva carrera");
    $("#btnCarGuardar").text("Guardar");
    $("#modalCarrera").fadeIn(200);
}

// ==================== EDITAR ====================
function car_Editar(carreraId) {
    if (!ValidarSesion()) return;

    car_ObtenerInfo(carreraId, function (car) {
        // El estado no se edita aquí: se guarda tal cual estaba
        car_activaActual = car.Activa === "True" ? "true" : "false";
        $("#hdnCarId").val(car.CarreraId);
        $("#txtCarNombre").val(car.Nombre);
        $("#modalCarTitulo").text("Editar carrera");
        $("#btnCarGuardar").text("Actualizar");
        $("#modalCarrera").fadeIn(200);
    });
}

// Pide una carrera (SP_INFO_CARRERA) y llama a alTerminar(carrera)
function car_ObtenerInfo(carreraId, alTerminar) {
    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;          // @InstitucionId
    obj_Parametros_JS[1] = g_UsuarioId;
    obj_Parametros_JS[2] = carreraId.toString();     // @CarreraId

    jQuery.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/InfoCarrera",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            if (!msg.d || msg.d.length === 0) {
                Swal.fire({ icon: "error", title: "Carreras", text: "No se encontró la carrera." });
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
function car_Guardar() {
    var nombre = $("#txtCarNombre").val().trim();

    if (nombre === "") {
        Swal.fire({ icon: "warning", title: "Carreras", text: "El nombre es obligatorio." });
        return;
    }

    var carreraId = $("#hdnCarId").val();
    if (carreraId === "0") {
        car_Insertar(nombre);
    } else {
        car_Actualizar(carreraId, nombre, car_activaActual, false);
    }
}

// ==================== INSERTAR ====================
function car_Insertar(nombre) {
    if (!ValidarSesion()) return;

    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;   // @InstitucionId
    obj_Parametros_JS[1] = g_UsuarioId;       // @IdUsuarioGlobal
    obj_Parametros_JS[2] = nombre;            // @Nombre

    $("#btnCarGuardar").prop("disabled", true);

    jQuery.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/InsertarCarrera",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            $("#btnCarGuardar").prop("disabled", false);
            var arreglo = msg.d.split("<SPLITER>");
            if (parseInt(arreglo[0]) > 0) {
                Swal.fire({ icon: "success", title: "Carreras", text: arreglo[1], timer: 2500, showConfirmButton: false });
                car_CerrarModal();
                car_Listar();
            } else {
                Swal.fire({ icon: "error", title: "Carreras", text: arreglo[1] });
            }
        },
        error: function () {
            $("#btnCarGuardar").prop("disabled", false);
            Swal.fire({ icon: "error", title: "Error de conexión", text: "No se pudo guardar la carrera." });
        }
    });
}

// ==================== ACTUALIZAR ====================
// Lo usan "Editar" (manda el estado que ya tenía) y "Activar" (manda "true").
function car_Actualizar(carreraId, nombre, activa, esActivacion) {
    if (!ValidarSesion()) return;

    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;   // @InstitucionId
    obj_Parametros_JS[1] = g_UsuarioId;       // @IdUsuarioGlobal
    obj_Parametros_JS[2] = carreraId;         // @CarreraId
    obj_Parametros_JS[3] = nombre;            // @Nombre
    obj_Parametros_JS[4] = activa;            // @Activo ("true"/"false")

    $("#btnCarGuardar").prop("disabled", true);

    jQuery.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/ActualizarCarrera",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            $("#btnCarGuardar").prop("disabled", false);
            var arreglo = msg.d.split("<SPLITER>");
            if (parseInt(arreglo[0]) > 0) {
                var texto = esActivacion ? 'La carrera "' + nombre + '" está activa de nuevo.' : arreglo[1];
                Swal.fire({ icon: "success", title: "Carreras", text: texto, timer: 2500, showConfirmButton: false });
                car_CerrarModal();
                car_Listar();
            } else {
                Swal.fire({ icon: "error", title: "Carreras", text: arreglo[1] });
            }
        },
        error: function () {
            $("#btnCarGuardar").prop("disabled", false);
            Swal.fire({ icon: "error", title: "Error de conexión", text: "No se pudo actualizar la carrera." });
        }
    });
}

// ==================== ACTIVAR ====================
// No hay SP de "activar": SP_ACTUALIZA_CARRERAS con el mismo nombre y Activo = 1.
// En auditoría queda "Estado: Inactivo → Activo".
function car_Activar(carreraId, nombre) {
    if (!ValidarSesion()) return;

    Swal.fire({
        icon: "question",
        title: "¿Activar carrera?",
        text: 'La carrera "' + nombre + '" volverá a aparecer al crear y editar usuarios.',
        showCancelButton: true,
        confirmButtonText: "Sí, activar",
        cancelButtonText: "Cancelar"
    }).then(function (result) {
        if (!result.isConfirmed) return;

        car_ObtenerInfo(carreraId, function (car) {
            car_Actualizar(car.CarreraId, car.Nombre, "true", true);
        });
    });
}

// ==================== ELIMINAR (DESACTIVAR) ====================
function car_Eliminar(carreraId, nombre) {
    if (!ValidarSesion()) return;

    Swal.fire({
        icon: "warning",
        title: "¿Desactivar carrera?",
        text: 'Se desactivará "' + nombre + '". Podrás activarla de nuevo con el botón ♻️.',
        showCancelButton: true,
        confirmButtonText: "Sí, desactivar",
        cancelButtonText: "Cancelar",
        confirmButtonColor: "#d33"
    }).then(function (result) {
        if (!result.isConfirmed) return;

        var obj_Parametros_JS = new Array();
        obj_Parametros_JS[0] = g_InstitucionId;          // @InstitucionId
        obj_Parametros_JS[1] = g_UsuarioId;              // @IdUsuarioGlobal
        obj_Parametros_JS[2] = carreraId.toString();     // @CarreraId

        jQuery.ajax({
            type: "POST",
            url: "frmPanelAdmin.aspx/EliminarCarrera",
            data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            cache: false,
            success: function (msg) {
                var arreglo = msg.d.split("<SPLITER>");
                if (parseInt(arreglo[0]) > 0) {
                    Swal.fire({ icon: "success", title: "Carreras", text: arreglo[1], timer: 2500, showConfirmButton: false });
                    car_Listar();
                } else {
                    Swal.fire({ icon: "error", title: "Carreras", text: arreglo[1] });
                }
            },
            error: function () {
                Swal.fire({ icon: "error", title: "Error de conexión", text: "No se pudo desactivar la carrera." });
            }
        });
    });
}

// ==================== CERRAR MODAL ====================
function car_CerrarModal() {
    $("#modalCarrera").fadeOut(200);
}

// Escapa el texto antes de meterlo en el HTML (los nombres los escribe el admin)
function car_Esc(texto) {
    return $("<div>").text(texto == null ? "" : String(texto)).html();
}
