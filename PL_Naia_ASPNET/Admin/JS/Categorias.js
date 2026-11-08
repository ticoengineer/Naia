// =====================================================================================
// CATEGORIAS · Categorias.js
// Funciones para listar, filtrar, crear, editar y eliminar categorias de tiquetes.
// Tambien carga los dropdowns de prioridades y equipos.
// =====================================================================================

// Se ejecuta cuando el admin abre la seccion de Categorias desde el menu
function cat_Inicializar() {
    cat_Listar();
    cat_CargarPrioridades();
    cat_CargarEquipos();

    // Actualizar el texto del color cuando el usuario lo cambia
    $("#txtCatColor").on("input", function () {
        $("#lblCatColorHex").text($(this).val().toUpperCase());
    });
}

// ==================== LISTAR ====================
// Trae todas las categorias y las pinta en la tabla
function cat_Listar() {
    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;

    jQuery.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/ListarCategorias",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            var datos = msg.d;
            cat_PintarTabla(datos);
        },
        error: function () {
            $("#tbodyCategorias").html('<tr><td colspan="7" class="admin-table__loading">Error al cargar categorías.</td></tr>');
        }
    });
}

// ==================== FILTRAR ====================
function cat_Filtrar() {
    var texto = $("#txtCatBuscar").val().trim();

    if (texto === "") {
        cat_Listar();
        return;
    }

    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;
    obj_Parametros_JS[1] = g_UsuarioId;
    obj_Parametros_JS[2] = texto;

    jQuery.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/FiltrarCategorias",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            var datos = msg.d;
            cat_PintarTabla(datos);
        },
        error: function () {
            $("#tbodyCategorias").html('<tr><td colspan="7" class="admin-table__loading">Error al filtrar.</td></tr>');
        }
    });
}

// ==================== PINTAR TABLA ====================
function cat_PintarTabla(datos) {
    var html = "";

    if (!datos || datos.length === 0) {
        html = '<tr><td colspan="7" class="admin-table__loading">No se encontraron categorías.</td></tr>';
        $("#tbodyCategorias").html(html);
        return;
    }

    $.each(datos, function (i, cat) {
        var claseEstado = cat.Activa === "True" ? "badge badge--activo" : "badge badge--inactivo";
        var requiereUbi = cat.RequiereUbicacionFisica === "True" ? "Sí" : "No";

        html += '<tr>';
        // Circulo de color de la categoria
        html += '  <td><span class="color-dot" style="background-color: ' + cat.ColorHex + ';" title="' + cat.ColorHex + '"></span></td>';
        html += '  <td>' + cat.Categoria + '</td>';
        // Prioridad con su color
        html += '  <td><span class="badge" style="background-color: ' + cat.PrioridadColor + '; color: #fff;">' + cat.PrioridadInicial + '</span></td>';
        html += '  <td>' + cat.EquipoPredeterminado + '</td>';
        html += '  <td>' + requiereUbi + '</td>';
        html += '  <td><span class="' + claseEstado + '">' + cat.EstadoTexto + '</span></td>';
        html += '  <td class="admin-table__actions-col">';
        html += '    <button class="btn-icon btn-icon--edit" type="button" title="Editar" onclick="cat_Editar(' + cat.CategoriaId + ')">✏️</button>';
        html += '    <button class="btn-icon btn-icon--delete" type="button" title="Desactivar" onclick="cat_Eliminar(' + cat.CategoriaId + ', \'' + cat.Categoria.replace(/'/g, "\\'") + '\')">🗑️</button>';
        html += '  </td>';
        html += '</tr>';
    });

    $("#tbodyCategorias").html(html);
}

// ==================== CARGAR PRIORIDADES (dropdown) ====================
// Trae las prioridades desde la base de datos para el select del modal
function cat_CargarPrioridades() {
    jQuery.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/ListarPrioridades",
        data: "{}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            var prioridades = msg.d;
            var select = $("#ddlCatPrioridad");

            // Limpiar y dejar solo la opcion por defecto
            select.find("option:not(:first)").remove();

            $.each(prioridades, function (i, prio) {
                select.append('<option value="' + prio.PrioridadId + '">' + prio.Prioridad + ' (SLA: ' + prio.SlaHoras + 'h)</option>');
            });
        },
        error: function () {
            // Si falla, el dropdown queda vacio pero no bloqueamos el panel
        }
    });
}

// ==================== CARGAR EQUIPOS (dropdown) ====================
// Trae los equipos de soporte para el select del modal
function cat_CargarEquipos() {
    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;

    jQuery.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/ListarEquipos",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            var equipos = msg.d;
            var select = $("#ddlCatEquipo");

            // Limpiar y dejar solo "Sin asignar"
            select.find("option:not(:first)").remove();

            $.each(equipos, function (i, equipo) {
                select.append('<option value="' + equipo.EquipoId + '">' + equipo.Equipo + '</option>');
            });
        },
        error: function () {
            // Si falla, el dropdown queda solo con "Sin asignar"
        }
    });
}

// ==================== MODAL NUEVO ====================
function cat_AbrirModalNuevo() {
    // Limpiar el formulario
    $("#hdnCatId").val("0");
    $("#txtCatNombre").val("");
    $("#txtCatDescripcion").val("");
    $("#txtCatColor").val("#3C4F76");
    $("#lblCatColorHex").text("#3C4F76");
    $("#ddlCatPrioridad").val("");
    $("#ddlCatEquipo").val("");
    $("#rdbCatUbiFisicaNo").prop("checked", true);
    $("#campoCatEstado").hide();
    $("#modalCatTitulo").text("Nueva categoría");
    $("#btnCatGuardar").text("Guardar");

    $("#modalCategoria").fadeIn(200);
}

// ==================== EDITAR (cargar datos) ====================
function cat_Editar(categoriaId) {
    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;
    obj_Parametros_JS[1] = g_UsuarioId;
    obj_Parametros_JS[2] = categoriaId.toString();

    jQuery.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/InfoCategoria",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            var datos = msg.d;

            if (!datos || datos.length === 0) {
                Swal.fire({ icon: 'error', title: 'Categorías', text: 'No se encontró la categoría.' });
                return;
            }

            var cat = datos[0];

            // Cargar datos en el modal
            $("#hdnCatId").val(cat.CategoriaId);
            $("#txtCatNombre").val(cat.Categoria);
            $("#txtCatDescripcion").val(cat.Descripcion);
            $("#txtCatColor").val(cat.ColorHex);
            $("#lblCatColorHex").text(cat.ColorHex.toUpperCase());
            $("#ddlCatPrioridad").val(cat.PrioridadInicialId);
            $("#ddlCatEquipo").val(cat.EquipoPredeterminadoId);

            // Requiere ubicacion fisica
            if (cat.RequiereUbicacionFisica === "True") {
                $("#rdbCatUbiFisicaSi").prop("checked", true);
            } else {
                $("#rdbCatUbiFisicaNo").prop("checked", true);
            }

            // Mostrar campo de estado (solo en edicion)
            $("#campoCatEstado").show();
            $("#ddlCatEstado").val(cat.Activa);

            $("#modalCatTitulo").text("Editar categoría");
            $("#btnCatGuardar").text("Actualizar");
            $("#modalCategoria").fadeIn(200);
        },
        error: function () {
            Swal.fire({ icon: 'error', title: 'Error de conexión', text: 'No se pudo cargar la información.' });
        }
    });
}

// ==================== GUARDAR (crear o actualizar) ====================
function cat_Guardar() {
    var nombre = $("#txtCatNombre").val().trim();
    var descripcion = $("#txtCatDescripcion").val().trim();
    var colorHex = $("#txtCatColor").val();
    var prioridadId = $("#ddlCatPrioridad").val();
    var equipoId = $("#ddlCatEquipo").val();
    var requiereUbiFisica = $("input[name='rdbCatUbiFisica']:checked").val();

    // Validaciones basicas
    if (nombre === "") {
        Swal.fire({ icon: 'warning', title: 'Categorías', text: 'El nombre es obligatorio.' });
        return;
    }

    if (prioridadId === "" || prioridadId === null) {
        Swal.fire({ icon: 'warning', title: 'Categorías', text: 'Debes seleccionar una prioridad inicial.' });
        return;
    }

    var categoriaId = $("#hdnCatId").val();
    var esNuevo = (categoriaId === "0");

    if (esNuevo) {
        cat_Insertar(nombre, descripcion, colorHex, prioridadId, equipoId, requiereUbiFisica);
    } else {
        var activa = $("#ddlCatEstado").val();
        cat_Actualizar(categoriaId, nombre, descripcion, colorHex, prioridadId, equipoId, requiereUbiFisica, activa);
    }
}

// ==================== INSERTAR ====================
function cat_Insertar(nombre, descripcion, colorHex, prioridadId, equipoId, requiereUbiFisica) {
    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;
    obj_Parametros_JS[1] = g_UsuarioId;
    obj_Parametros_JS[2] = nombre;
    obj_Parametros_JS[3] = descripcion;
    obj_Parametros_JS[4] = colorHex;
    obj_Parametros_JS[5] = prioridadId;
    obj_Parametros_JS[6] = equipoId;          // puede ser "" si no se selecciono equipo
    obj_Parametros_JS[7] = requiereUbiFisica;

    $("#btnCatGuardar").prop("disabled", true);

    jQuery.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/InsertarCategoria",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            var arreglo = msg.d.split("<SPLITER>");
            var resultado = parseInt(arreglo[0]);

            if (resultado > 0) {
                Swal.fire({ icon: 'success', title: 'Categorías', text: arreglo[1], timer: 2500, showConfirmButton: false });
                cat_CerrarModal();
                cat_Listar();
            } else {
                Swal.fire({ icon: 'error', title: 'Categorías', text: arreglo[1] });
            }

            $("#btnCatGuardar").prop("disabled", false);
        },
        error: function () {
            Swal.fire({ icon: 'error', title: 'Error de conexión', text: 'No se pudo guardar la categoría.' });
            $("#btnCatGuardar").prop("disabled", false);
        }
    });
}

// ==================== ACTUALIZAR ====================
function cat_Actualizar(categoriaId, nombre, descripcion, colorHex, prioridadId, equipoId, requiereUbiFisica, activa) {
    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;
    obj_Parametros_JS[1] = g_UsuarioId;
    obj_Parametros_JS[2] = categoriaId;
    obj_Parametros_JS[3] = nombre;
    obj_Parametros_JS[4] = descripcion;
    obj_Parametros_JS[5] = colorHex;
    obj_Parametros_JS[6] = prioridadId;
    obj_Parametros_JS[7] = equipoId;
    obj_Parametros_JS[8] = requiereUbiFisica;
    obj_Parametros_JS[9] = activa;

    $("#btnCatGuardar").prop("disabled", true);

    jQuery.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/ActualizarCategoria",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            var arreglo = msg.d.split("<SPLITER>");
            var resultado = parseInt(arreglo[0]);

            if (resultado > 0) {
                Swal.fire({ icon: 'success', title: 'Categorías', text: arreglo[1], timer: 2500, showConfirmButton: false });
                cat_CerrarModal();
                cat_Listar();
            } else {
                Swal.fire({ icon: 'error', title: 'Categorías', text: arreglo[1] });
            }

            $("#btnCatGuardar").prop("disabled", false);
        },
        error: function () {
            Swal.fire({ icon: 'error', title: 'Error de conexión', text: 'No se pudo actualizar la categoría.' });
            $("#btnCatGuardar").prop("disabled", false);
        }
    });
}

// ==================== ELIMINAR (desactivar) ====================
function cat_Eliminar(categoriaId, nombre) {
    Swal.fire({
        icon: 'warning',
        title: '¿Desactivar categoría?',
        text: 'Se desactivará "' + nombre + '". Los tiquetes existentes no se afectan.',
        showCancelButton: true,
        confirmButtonText: 'Sí, desactivar',
        cancelButtonText: 'Cancelar',
        confirmButtonColor: '#d33'
    }).then(function (result) {
        if (result.isConfirmed) {
            var obj_Parametros_JS = new Array();
            obj_Parametros_JS[0] = g_InstitucionId;
            obj_Parametros_JS[1] = g_UsuarioId;
            obj_Parametros_JS[2] = categoriaId.toString();

            jQuery.ajax({
                type: "POST",
                url: "frmPanelAdmin.aspx/EliminarCategoria",
                data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                cache: false,
                success: function (msg) {
                    var arreglo = msg.d.split("<SPLITER>");
                    var resultado = parseInt(arreglo[0]);

                    if (resultado > 0) {
                        Swal.fire({ icon: 'success', title: 'Categorías', text: arreglo[1], timer: 2500, showConfirmButton: false });
                        cat_Listar();
                    } else {
                        Swal.fire({ icon: 'error', title: 'Categorías', text: arreglo[1] });
                    }
                },
                error: function () {
                    Swal.fire({ icon: 'error', title: 'Error de conexión', text: 'No se pudo desactivar la categoría.' });
                }
            });
        }
    });
}

// ==================== CERRAR MODAL ====================
function cat_CerrarModal() {
    $("#modalCategoria").fadeOut(200);
}
