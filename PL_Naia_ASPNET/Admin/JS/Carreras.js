// =====================================================================================
// CARRERAS - Carreras.js
// Prefijo: car_
// =====================================================================================

// Hook que Panel.js llama al abrir la seccion
function Carreras_AlAbrir() {
    car_Listar();
}

// ==================== LISTAR ====================
function car_Listar() {
    if (!ValidarSesion()) return;

    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;

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
    obj_Parametros_JS[0] = g_InstitucionId;
    obj_Parametros_JS[1] = g_UsuarioId;
    obj_Parametros_JS[2] = texto;

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
    var html = "";
    if (!datos || datos.length === 0) {
        html = '<tr><td colspan="4" class="admin-table__loading">No se encontraron carreras.</td></tr>';
        $("#tbodyCarreras").html(html);
        return;
    }

    $.each(datos, function (i, car) {
        var claseEstado = car.Activa === "True" ? "badge badge--activo" : "badge badge--inactivo";
        html += "<tr>";
        html += "  <td>" + car.Nombre + "</td>";
        html += "  <td>" + (car.Codigo || "\u2014") + "</td>";
        html += '  <td><span class="' + claseEstado + '">' + car.EstadoTexto + "</span></td>";
        html += '  <td class="admin-table__actions-col">';
        html += '    <button class="btn-icon btn-icon--edit" type="button" title="Editar" onclick="car_Editar(' + car.CarreraId + ')">\u270F\uFE0F</button>';
        html += '    <button class="btn-icon btn-icon--delete" type="button" title="Desactivar" onclick="car_Eliminar(' + car.CarreraId + ", \'" + car.Nombre.replace(/'/g, "\\\'") + "\')" + '">\uD83D\uDDD1\uFE0F</button>';
        html += "  </td>";
        html += "</tr>";
    });

    $("#tbodyCarreras").html(html);
}

// ==================== MODAL NUEVO ====================
function car_AbrirModalNuevo() {
    $("#hdnCarId").val("0");
    $("#txtCarNombre").val("");
    $("#txtCarCodigo").val("");
    $("#campoCarEstado").hide();
    $("#modalCarTitulo").text("Nueva carrera");
    $("#btnCarGuardar").text("Guardar");
    $("#modalCarrera").fadeIn(200);
}

// ==================== EDITAR ====================
function car_Editar(carreraId) {
    if (!ValidarSesion()) return;

    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;
    obj_Parametros_JS[1] = g_UsuarioId;
    obj_Parametros_JS[2] = carreraId.toString();

    jQuery.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/InfoCarrera",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            var datos = msg.d;
            if (!datos || datos.length === 0) {
                Swal.fire({ icon: "error", title: "Carreras", text: "No se encontro la carrera." });
                return;
            }
            var car = datos[0];
            $("#hdnCarId").val(car.CarreraId);
            $("#txtCarNombre").val(car.Nombre);
            $("#txtCarCodigo").val(car.Codigo);
            $("#campoCarEstado").show();
            $("#ddlCarEstado").val(car.Activa);
            $("#modalCarTitulo").text("Editar carrera");
            $("#btnCarGuardar").text("Actualizar");
            $("#modalCarrera").fadeIn(200);
        },
        error: function () {
            Swal.fire({ icon: "error", title: "Error de conexion", text: "No se pudo cargar la informacion." });
        }
    });
}

// ==================== GUARDAR ====================
function car_Guardar() {
    var nombre = $("#txtCarNombre").val().trim();
    var codigo = $("#txtCarCodigo").val().trim();

    if (nombre === "") {
        Swal.fire({ icon: "warning", title: "Carreras", text: "El nombre es obligatorio." });
        return;
    }

    var carreraId = $("#hdnCarId").val();
    if (carreraId === "0") {
        car_Insertar(nombre, codigo);
    } else {
        var activa = $("#ddlCarEstado").val();
        car_Actualizar(carreraId, nombre, codigo, activa);
    }
}

// ==================== INSERTAR ====================
function car_Insertar(nombre, codigo) {
    if (!ValidarSesion()) return;

    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;
    obj_Parametros_JS[1] = g_UsuarioId;
    obj_Parametros_JS[2] = nombre;
    obj_Parametros_JS[3] = codigo;

    $("#btnCarGuardar").prop("disabled", true);

    jQuery.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/InsertarCarrera",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            var arreglo = msg.d.split("<SPLITER>");
            var resultado = parseInt(arreglo[0]);
            if (resultado > 0) {
                Swal.fire({ icon: "success", title: "Carreras", text: arreglo[1], timer: 2500, showConfirmButton: false });
                car_CerrarModal();
                car_Listar();
            } else {
                Swal.fire({ icon: "error", title: "Carreras", text: arreglo[1] });
            }
            $("#btnCarGuardar").prop("disabled", false);
        },
        error: function () {
            Swal.fire({ icon: "error", title: "Error de conexion", text: "No se pudo guardar la carrera." });
            $("#btnCarGuardar").prop("disabled", false);
        }
    });
}

// ==================== ACTUALIZAR ====================
function car_Actualizar(carreraId, nombre, codigo, activa) {
    if (!ValidarSesion()) return;

    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;
    obj_Parametros_JS[1] = g_UsuarioId;
    obj_Parametros_JS[2] = carreraId;
    obj_Parametros_JS[3] = nombre;
    obj_Parametros_JS[4] = codigo;
    obj_Parametros_JS[5] = activa;

    $("#btnCarGuardar").prop("disabled", true);

    jQuery.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/ActualizarCarrera",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            var arreglo = msg.d.split("<SPLITER>");
            var resultado = parseInt(arreglo[0]);
            if (resultado > 0) {
                Swal.fire({ icon: "success", title: "Carreras", text: arreglo[1], timer: 2500, showConfirmButton: false });
                car_CerrarModal();
                car_Listar();
            } else {
                Swal.fire({ icon: "error", title: "Carreras", text: arreglo[1] });
            }
            $("#btnCarGuardar").prop("disabled", false);
        },
        error: function () {
            Swal.fire({ icon: "error", title: "Error de conexion", text: "No se pudo actualizar la carrera." });
            $("#btnCarGuardar").prop("disabled", false);
        }
    });
}

// ==================== ELIMINAR ====================
function car_Eliminar(carreraId, nombre) {
    if (!ValidarSesion()) return;

    Swal.fire({
        icon: "warning",
        title: "\u00BFDesactivar carrera?",
        text: 'Se desactivara "' + nombre + '". Podras reactivarla despues desde editar.',
        showCancelButton: true,
        confirmButtonText: "Si, desactivar",
        cancelButtonText: "Cancelar",
        confirmButtonColor: "#d33"
    }).then(function (result) {
        if (result.isConfirmed) {
            var obj_Parametros_JS = new Array();
            obj_Parametros_JS[0] = g_InstitucionId;
            obj_Parametros_JS[1] = g_UsuarioId;
            obj_Parametros_JS[2] = carreraId.toString();

            jQuery.ajax({
                type: "POST",
                url: "frmPanelAdmin.aspx/EliminarCarrera",
                data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                cache: false,
                success: function (msg) {
                    var arreglo = msg.d.split("<SPLITER>");
                    var resultado = parseInt(arreglo[0]);
                    if (resultado > 0) {
                        Swal.fire({ icon: "success", title: "Carreras", text: arreglo[1], timer: 2500, showConfirmButton: false });
                        car_Listar();
                    } else {
                        Swal.fire({ icon: "error", title: "Carreras", text: arreglo[1] });
                    }
                },
                error: function () {
                    Swal.fire({ icon: "error", title: "Error de conexion", text: "No se pudo desactivar la carrera." });
                }
            });
        }
    });
}

// ==================== CERRAR MODAL ====================
function car_CerrarModal() {
    $("#modalCarrera").fadeOut(200);
}
