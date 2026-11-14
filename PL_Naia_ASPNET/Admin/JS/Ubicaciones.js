// =====================================================================================
// UBICACIONES · Ubicaciones.js
// Funciones para listar, filtrar, crear, editar y eliminar ubicaciones.
// Todas las llamadas van a frmPanelAdmin.aspx/<NombreMetodo> via AJAX.
// =====================================================================================

// Se ejecuta cuando el admin abre la seccion de Ubicaciones desde el menu
function ubi_Inicializar() {
    ubi_Listar();
}

// ==================== LISTAR ====================
// Trae todas las ubicaciones y las pinta en la tabla
function ubi_Listar() {
    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;   // viene de Sesion.js (cookie)

    jQuery.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/ListarUbicaciones",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            var datos = msg.d;
            ubi_PintarTabla(datos);
        },
        error: function () {
            $("#tbodyUbicaciones").html('<tr><td colspan="5" class="admin-table__loading">Error al cargar ubicaciones.</td></tr>');
        }
    });
}

// ==================== FILTRAR ====================
// Se llama cada vez que el usuario escribe en el buscador (onkeyup)
function ubi_Filtrar() {
    var texto = $("#txtUbiBuscar").val().trim();

    // Si el buscador esta vacio, recargamos toda la lista
    if (texto === "") {
        ubi_Listar();
        return;
    }

    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;
    obj_Parametros_JS[1] = g_UsuarioId;
    obj_Parametros_JS[2] = texto;

    jQuery.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/FiltrarUbicaciones",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            var datos = msg.d;
            ubi_PintarTabla(datos);
        },
        error: function () {
            $("#tbodyUbicaciones").html('<tr><td colspan="5" class="admin-table__loading">Error al filtrar.</td></tr>');
        }
    });
}

// ==================== PINTAR TABLA ====================
// Recibe la lista de ubicaciones y arma las filas de la tabla
function ubi_PintarTabla(datos) {
    var html = "";

    if (!datos || datos.length === 0) {
        html = '<tr><td colspan="5" class="admin-table__loading">No se encontraron ubicaciones.</td></tr>';
        $("#tbodyUbicaciones").html(html);
        return;
    }

    $.each(datos, function (i, ubi) {
        // Clase CSS segun si esta activa o inactiva
        var claseEstado = ubi.Activa === "True" ? "badge badge--activo" : "badge badge--inactivo";

        html += '<tr>';
        html += '  <td>' + ubi.Nombre + '</td>';
        html += '  <td>' + (ubi.Edificio || '—') + '</td>';
        html += '  <td>' + ubi.TipoTexto + '</td>';
        html += '  <td><span class="' + claseEstado + '">' + ubi.EstadoTexto + '</span></td>';
        html += '  <td class="admin-table__actions-col">';
        html += '    <button class="btn-icon btn-icon--edit" type="button" title="Editar" onclick="ubi_Editar(' + ubi.UbicacionId + ')">✏️</button>';
        html += '    <button class="btn-icon btn-icon--delete" type="button" title="Desactivar" onclick="ubi_Eliminar(' + ubi.UbicacionId + ', \'' + ubi.Nombre.replace(/'/g, "\\'") + '\')">🗑️</button>';
        html += '  </td>';
        html += '</tr>';
    });

    $("#tbodyUbicaciones").html(html);
}

// ==================== MODAL NUEVO ====================
// Abre el modal en modo "crear nueva ubicacion"
function ubi_AbrirModalNuevo() {
    // Limpiar el formulario
    $("#hdnUbiId").val("0");
    $("#txtUbiNombre").val("");
    $("#txtUbiEdificio").val("");
    $("#rdbUbiFisica").prop("checked", true);
    $("#campoUbiEdificio").show();
    $("#campoUbiEstado").hide();
    $("#modalUbiTitulo").text("Nueva ubicación");
    $("#btnUbiGuardar").text("Guardar");

    // Mostrar modal
    $("#modalUbicacion").fadeIn(200);
}

// ==================== EDITAR (cargar datos) ====================
// Pide la info de una ubicacion y la carga en el modal para editar
function ubi_Editar(ubicacionId) {
    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;
    obj_Parametros_JS[1] = g_UsuarioId;
    obj_Parametros_JS[2] = ubicacionId.toString();

    jQuery.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/InfoUbicacion",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            var datos = msg.d;

            if (!datos || datos.length === 0) {
                Swal.fire({ icon: 'error', title: 'Ubicaciones', text: 'No se encontró la ubicación.' });
                return;
            }

            var ubi = datos[0];

            // Cargar datos en el modal
            $("#hdnUbiId").val(ubi.UbicacionId);
            $("#txtUbiNombre").val(ubi.Nombre);
            $("#txtUbiEdificio").val(ubi.Edificio);

            // Tipo: fisica o virtual
            if (ubi.EsFisica === "True") {
                $("#rdbUbiFisica").prop("checked", true);
                $("#campoUbiEdificio").show();
            } else {
                $("#rdbUbiVirtual").prop("checked", true);
                $("#campoUbiEdificio").hide();
            }

            // Mostrar campo de estado (solo en edicion)
            $("#campoUbiEstado").show();
            $("#ddlUbiEstado").val(ubi.Activa);

            $("#modalUbiTitulo").text("Editar ubicación");
            $("#btnUbiGuardar").text("Actualizar");
            $("#modalUbicacion").fadeIn(200);
        },
        error: function () {
            Swal.fire({ icon: 'error', title: 'Error de conexión', text: 'No se pudo cargar la información.' });
        }
    });
}

// ==================== GUARDAR (crear o actualizar) ====================
// Decide si es nuevo o edicion segun el valor de hdnUbiId
function ubi_Guardar() {
    // Validar campos obligatorios
    var nombre = $("#txtUbiNombre").val().trim();
    var esFisica = $("input[name='rdbUbiTipo']:checked").val();
    var edificio = $("#txtUbiEdificio").val().trim();

    if (nombre === "") {
        Swal.fire({ icon: 'warning', title: 'Ubicaciones', text: 'El nombre es obligatorio.' });
        return;
    }

    // Si es fisica, el edificio es obligatorio
    if (esFisica === "true" && edificio === "") {
        Swal.fire({ icon: 'warning', title: 'Ubicaciones', text: 'Las ubicaciones físicas necesitan un edificio.' });
        return;
    }

    var ubicacionId = $("#hdnUbiId").val();
    var esNuevo = (ubicacionId === "0");

    if (esNuevo) {
        ubi_Insertar(nombre, edificio, esFisica);
    } else {
        var activa = $("#ddlUbiEstado").val();
        ubi_Actualizar(ubicacionId, nombre, edificio, esFisica, activa);
    }
}

// ==================== INSERTAR ====================
function ubi_Insertar(nombre, edificio, esFisica) {
    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;
    obj_Parametros_JS[1] = g_UsuarioId;
    obj_Parametros_JS[2] = nombre;
    obj_Parametros_JS[3] = (esFisica === "true") ? edificio : "";   // si es virtual, no mandamos edificio
    obj_Parametros_JS[4] = esFisica;

    $("#btnUbiGuardar").prop("disabled", true);

    jQuery.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/InsertarUbicacion",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            var arreglo = msg.d.split("<SPLITER>");
            var resultado = parseInt(arreglo[0]);

            if (resultado > 0) {
                Swal.fire({ icon: 'success', title: 'Ubicaciones', text: arreglo[1], timer: 2500, showConfirmButton: false });
                ubi_CerrarModal();
                ubi_Listar();   // refrescar la tabla
            } else {
                Swal.fire({ icon: 'error', title: 'Ubicaciones', text: arreglo[1] });
            }

            $("#btnUbiGuardar").prop("disabled", false);
        },
        error: function () {
            Swal.fire({ icon: 'error', title: 'Error de conexión', text: 'No se pudo guardar la ubicación.' });
            $("#btnUbiGuardar").prop("disabled", false);
        }
    });
}

// ==================== ACTUALIZAR ====================
function ubi_Actualizar(ubicacionId, nombre, edificio, esFisica, activa) {
    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;
    obj_Parametros_JS[1] = g_UsuarioId;
    obj_Parametros_JS[2] = ubicacionId;
    obj_Parametros_JS[3] = nombre;
    obj_Parametros_JS[4] = (esFisica === "true") ? edificio : "";
    obj_Parametros_JS[5] = esFisica;
    obj_Parametros_JS[6] = activa;

    $("#btnUbiGuardar").prop("disabled", true);

    jQuery.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/ActualizarUbicacion",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            var arreglo = msg.d.split("<SPLITER>");
            var resultado = parseInt(arreglo[0]);

            if (resultado > 0) {
                Swal.fire({ icon: 'success', title: 'Ubicaciones', text: arreglo[1], timer: 2500, showConfirmButton: false });
                ubi_CerrarModal();
                ubi_Listar();
            } else {
                Swal.fire({ icon: 'error', title: 'Ubicaciones', text: arreglo[1] });
            }

            $("#btnUbiGuardar").prop("disabled", false);
        },
        error: function () {
            Swal.fire({ icon: 'error', title: 'Error de conexión', text: 'No se pudo actualizar la ubicación.' });
            $("#btnUbiGuardar").prop("disabled", false);
        }
    });
}

// ==================== ELIMINAR (desactivar) ====================
// Pide confirmacion antes de desactivar la ubicacion
function ubi_Eliminar(ubicacionId, nombre) {
    Swal.fire({
        icon: 'warning',
        title: '¿Desactivar ubicación?',
        text: 'Se desactivará "' + nombre + '". Podrás reactivarla después desde editar.',
        showCancelButton: true,
        confirmButtonText: 'Sí, desactivar',
        cancelButtonText: 'Cancelar',
        confirmButtonColor: '#d33'
    }).then(function (result) {
        if (result.isConfirmed) {
            var obj_Parametros_JS = new Array();
            obj_Parametros_JS[0] = g_InstitucionId;
            obj_Parametros_JS[1] = g_UsuarioId;
            obj_Parametros_JS[2] = ubicacionId.toString();

            jQuery.ajax({
                type: "POST",
                url: "frmPanelAdmin.aspx/EliminarUbicacion",
                data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                cache: false,
                success: function (msg) {
                    var arreglo = msg.d.split("<SPLITER>");
                    var resultado = parseInt(arreglo[0]);

                    if (resultado > 0) {
                        Swal.fire({ icon: 'success', title: 'Ubicaciones', text: arreglo[1], timer: 2500, showConfirmButton: false });
                        ubi_Listar();
                    } else {
                        Swal.fire({ icon: 'error', title: 'Ubicaciones', text: arreglo[1] });
                    }
                },
                error: function () {
                    Swal.fire({ icon: 'error', title: 'Error de conexión', text: 'No se pudo desactivar la ubicación.' });
                }
            });
        }
    });
}

// ==================== CAMBIAR TIPO ====================
// Muestra u oculta el campo de edificio segun el tipo seleccionado
function ubi_CambiarTipo() {
    var esFisica = $("input[name='rdbUbiTipo']:checked").val();

    if (esFisica === "true") {
        $("#campoUbiEdificio").slideDown(200);
    } else {
        $("#campoUbiEdificio").slideUp(200);
        $("#txtUbiEdificio").val("");   // limpiar edificio si cambia a virtual
    }
}

// ==================== CERRAR MODAL ====================
function ubi_CerrarModal() {
    $("#modalUbicacion").fadeOut(200);
}
