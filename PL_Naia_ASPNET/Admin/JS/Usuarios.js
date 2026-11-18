// ==================== USUARIOS ====================

var usr_esEdicion = false;
var usr_roles = [];       // cache de roles para cambio dinamico
var usr_tiposId = [];     // cache de tipos de identificacion

// Función que Panel.js llama al abrir la sección
window.Usuarios_AlAbrir = function () {
    Usuarios_CargarDropdowns(function () {
        Usuarios_Listar();
    });
};

// -------------------- CARGAR DROPDOWNS --------------------
function Usuarios_CargarDropdowns(callback) {
    if (!ValidarSesion()) return;

    var pendientes = 2;
    var listo = function () { pendientes--; if (pendientes === 0 && callback) callback(); };

    // Roles
    $.ajax({
        type: "POST", url: "frmPanelAdmin.aspx/ListarRoles",
        data: JSON.stringify({ obj_Parametros_JS: [g_InstitucionId] }),
        contentType: "application/json; charset=utf-8", dataType: "json",
        success: function (r) {
            usr_roles = r.d || [];
            var ddl = $("#usr_ddlRol");
            ddl.find("option:gt(0)").remove();
            for (var i = 0; i < usr_roles.length; i++) {
                ddl.append('<option value="' + usr_roles[i].RolId + '">' + usr_roles[i].Rol + '</option>');
            }
            listo();
        },
        error: listo
    });

    // Tipos de identificacion
    $.ajax({
        type: "POST", url: "frmPanelAdmin.aspx/ListarTiposIdentificacion",
        data: JSON.stringify({ obj_Parametros_JS: [g_InstitucionId] }),
        contentType: "application/json; charset=utf-8", dataType: "json",
        success: function (r) {
            usr_tiposId = r.d || [];
            var ddl = $("#usr_ddlTipoId");
            ddl.find("option:gt(0)").remove();
            for (var i = 0; i < usr_tiposId.length; i++) {
                ddl.append('<option value="' + usr_tiposId[i].TipoIdentificacionId + '">' + usr_tiposId[i].TipoIdentificacion + '</option>');
            }
            listo();
        },
        error: listo
    });
}

    // -------------------- CARGAR CATÁLOGOS (Parte B) --------------------
    // Carreras, departamentos y equipos cambian cuando el administrador trabaja en las
    // secciones de catálogos, así que se recargan cada vez que se abre el modal.
    function Usuarios_CargarCatalogos(callback) {
        if (!ValidarSesion()) return;

        var pendientes = 3;
        var listo = function () { pendientes--; if (pendientes === 0 && callback) callback(); };

        // Carreras
        $.ajax({
            type: "POST", url: "frmPanelAdmin.aspx/ListarCarreras",
            data: JSON.stringify({ obj_Parametros_JS: [g_InstitucionId] }),
            contentType: "application/json; charset=utf-8", dataType: "json",
            success: function (r) {
                var ddl = $("#usr_ddlCarrera");
                ddl.find("option:gt(0)").remove();
                var datos = r.d || [];
                for (var i = 0; i < datos.length; i++) {
                    if (datos[i].Activa === "True")
                        ddl.append($("<option>").val(datos[i].CarreraId).text(datos[i].Nombre));
                }
                listo();
            },
            error: listo
        });

        // Departamentos
        $.ajax({
            type: "POST", url: "frmPanelAdmin.aspx/ListarDepartamentos",
            data: JSON.stringify({ obj_Parametros_JS: [g_InstitucionId] }),
            contentType: "application/json; charset=utf-8", dataType: "json",
            success: function (r) {
                var ddl = $("#usr_ddlDepartamento");
                ddl.find("option:gt(0)").remove();
                var datos = r.d || [];
                for (var i = 0; i < datos.length; i++) {
                    if (datos[i].Activo === "True")
                        ddl.append($("<option>").val(datos[i].DepartamentoId).text(datos[i].Nombre));
                }
                listo();
            },
            error: listo
        });

        // Equipos de soporte (WebMethod de la Parte B: Equipos.cs, devuelve la columna Activo)
        $.ajax({
            type: "POST", url: "frmPanelAdmin.aspx/ListarEquiposTodos",
            data: JSON.stringify({ obj_Parametros_JS: [g_InstitucionId] }),
            contentType: "application/json; charset=utf-8", dataType: "json",
            success: function (r) {
                var ddl = $("#usr_ddlEquipo");
                ddl.find("option:gt(0)").remove();
                var datos = r.d || [];
                for (var i = 0; i < datos.length; i++) {
                    if (datos[i].Activo === "True")
                        ddl.append($("<option>").val(datos[i].EquipoId).text(datos[i].Equipo));
                }
                listo();
            },
            error: listo
        });
    }

// -------------------- LISTAR --------------------
function Usuarios_Listar() {
    if (!ValidarSesion()) return;

    var params = [g_InstitucionId];

    $.ajax({
        type: "POST", url: "frmPanelAdmin.aspx/ListarUsuarios",
        data: JSON.stringify({ obj_Parametros_JS: params }),
        contentType: "application/json; charset=utf-8", dataType: "json",
        success: function (r) { Usuarios_RenderTabla(r.d); },
        error: function () {
            $("#usr_tbodyUsuarios").html('<tr><td colspan="7" class="admin-table__loading">Error al cargar los usuarios.</td></tr>');
        }
    });
}

// -------------------- FILTRAR --------------------
function Usuarios_Filtrar() {
    if (!ValidarSesion()) return;

    var filtro = $.trim($("#usr_txtFiltro").val());
    if (filtro.length === 0) { Usuarios_Listar(); return; }

    var params = [g_InstitucionId, g_UsuarioId, filtro];

    $.ajax({
        type: "POST", url: "frmPanelAdmin.aspx/FiltrarUsuarios",
        data: JSON.stringify({ obj_Parametros_JS: params }),
        contentType: "application/json; charset=utf-8", dataType: "json",
        success: function (r) { Usuarios_RenderTabla(r.d); },
        error: function () {
            $("#usr_tbodyUsuarios").html('<tr><td colspan="7" class="admin-table__loading">Error al filtrar los usuarios.</td></tr>');
        }
    });
}

// -------------------- ESCAPAR HTML --------------------
// Convierte los caracteres especiales en entidades para que un nombre como
// <img onerror=...> se muestre como texto y nunca se ejecute.
function Usuarios_Escapar(valor) {
    var texto = (valor === null || valor === undefined) ? "" : String(valor);
    return texto.replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#39;");
}

// -------------------- RENDER TABLA --------------------
function Usuarios_RenderTabla(datos) {
    var tbody = $("#usr_tbodyUsuarios");

    if (!datos || datos.length === 0) {
        tbody.html('<tr><td colspan="7" class="admin-table__loading">No se encontraron usuarios.</td></tr>');
        return;
    }

    var html = "";

    for (var i = 0; i < datos.length; i++) {
        var u = datos[i];
        var activo = (u.Activo === "True");
        var claseEstado = activo ? "badge badge--active" : "badge badge--inactive";
        var estadoTexto = activo ? "Activo" : "Inactivo";
        var carreraDep = u.Carrera || u.Departamento || "-";
        if (u.Equipo) carreraDep += " / " + u.Equipo;

        var id = Usuarios_Escapar(u.UsuarioId);
        var nombre = Usuarios_Escapar(u.NombreCompleto);

        // Activo -> se puede desactivar. Inactivo -> se puede reactivar.
        var botonEstado = activo
            ? '<button type="button" class="btn-action usr-btnDesactivar" title="Desactivar" aria-label="Desactivar"' +
            ' data-id="' + id + '" data-nombre="' + nombre + '">\uD83D\uDDD1\uFE0F</button>'
            : '<button type="button" class="btn-action usr-btnReactivar" title="Reactivar" aria-label="Reactivar"' +
            ' data-id="' + id + '" data-nombre="' + nombre + '">\u267B\uFE0F</button>';

        html += '<tr>' +
            '<td>' + nombre + '</td>' +
            '<td>' + Usuarios_Escapar(u.Correo) + '</td>' +
            '<td>' + Usuarios_Escapar(u.Rol) + '</td>' +
            '<td>' + Usuarios_Escapar(carreraDep) + '</td>' +
            '<td>' + Usuarios_Escapar(u.NumeroInterno) + '</td>' +
            '<td><span class="' + claseEstado + '">' + estadoTexto + '</span></td>' +
            '<td class="admin-table__actions-col">' +
            '<button type="button" class="btn-action usr-btnEditar" title="Editar" aria-label="Editar"' +
            ' data-id="' + id + '">\u270F\uFE0F</button>' +
            botonEstado +
            '</td>' +
            '</tr>';
    }

    tbody.html(html);
}

// -------------------- EVENTOS DE LOS BOTONES DE LA TABLA --------------------
// Delegación: un solo manejador en el documento atiende a todos los botones,
// incluso a los que se vuelven a dibujar cada vez que se lista o filtra.
$(document).on("click", "#usr_tbodyUsuarios .usr-btnEditar", function () {
    Usuarios_Editar($(this).attr("data-id"));
});

$(document).on("click", "#usr_tbodyUsuarios .usr-btnDesactivar", function () {
    Usuarios_Eliminar($(this).attr("data-id"), $(this).attr("data-nombre"));
});

$(document).on("click", "#usr_tbodyUsuarios .usr-btnReactivar", function () {
    Usuarios_Reactivar($(this).attr("data-id"), $(this).attr("data-nombre"));
});
// -------------------- CAMBIO DE ROL (condicional) --------------------
function Usuarios_CambioRol() {
    var rolId = parseInt($("#usr_ddlRol").val()) || 0;

    // Roles 1,2 = Estudiante, Profesor -> muestran Carrera
    // Roles 3,4 = Soporte tecnico, Administrativo -> muestran Departamento
    // Solo Rol 3 = Soporte tecnico -> muestra Equipo

    if (rolId === 1 || rolId === 2) {
        $("#usr_filaCarrera").show();
        $("#usr_filaDepartamento").hide();
        $("#usr_grupoEquipo").hide();
        $("#usr_ddlDepartamento").val("");
        $("#usr_ddlEquipo").val("");
    } else if (rolId === 3 || rolId === 4) {
        $("#usr_filaCarrera").hide();
        $("#usr_filaDepartamento").show();
        $("#usr_ddlCarrera").val("");
        if (rolId === 3) {
            $("#usr_grupoEquipo").show();
        } else {
            $("#usr_grupoEquipo").hide();
            $("#usr_ddlEquipo").val("");
        }
    } else {
        $("#usr_filaCarrera").hide();
        $("#usr_filaDepartamento").hide();
        $("#usr_grupoEquipo").hide();
    }

    // Cambiar label del numero interno segun TipoNumeroInterno del rol
    var rolSeleccionado = null;
    for (var i = 0; i < usr_roles.length; i++) {
        if (parseInt(usr_roles[i].RolId) === rolId) { rolSeleccionado = usr_roles[i]; break; }
    }
    if (rolSeleccionado) {
        var tipo = rolSeleccionado.TipoNumeroInterno || "Numero interno";
        $("#usr_lblNumeroInterno").html(tipo + ' <span class="required">*</span>');
    }
}

// -------------------- ABRIR MODAL NUEVO --------------------
function Usuarios_AbrirModalNuevo() {
    usr_esEdicion = false;
    $("#usr_modalTitulo").text("Nuevo Usuario");
    $("#usr_hdnUsuarioId").val("0");
    $("#usr_txtNombre").val("");
    $("#usr_txtApellidos").val("");
    $("#usr_ddlRol").val("");
    $("#usr_txtCorreo").val("");
    $("#usr_ddlTipoId").val("");
    $("#usr_txtIdentificacion").val("");
    $("#usr_txtNumeroInterno").val("");
    $("#usr_txtContrasena").val("");
    $("#usr_ddlCarrera").val("");
    $("#usr_ddlDepartamento").val("");
    $("#usr_ddlEquipo").val("");
    $("#usr_ddlEstado").val("true");
    $("#usr_filaCarrera").hide();
    $("#usr_filaDepartamento").hide();
    $("#usr_grupoEquipo").hide();
    $("#usr_filaEstado").hide();
    $("#usr_grupoContrasena").show();
    $("#usr_lblContrasena").html('Contrase&#241;a <span class="required">*</span>');
    Usuarios_CargarCatalogos();
    $("#usr_modal").fadeIn(200);
}

// -------------------- EDITAR --------------------
function Usuarios_Editar(usuarioId) {
    if (!ValidarSesion()) return;

    var params = [g_InstitucionId, g_UsuarioId, usuarioId.toString()];

    $.ajax({
        type: "POST", url: "frmPanelAdmin.aspx/InfoUsuario",
        data: JSON.stringify({ obj_Parametros_JS: params }),
        contentType: "application/json; charset=utf-8", dataType: "json",
        success: function (r) {
            if (!r.d || r.d.length === 0) {
                Swal.fire("Error", "No se pudo obtener la informacion del usuario.", "error");
                return;
            }
            var u = r.d[0];

            // Primero se refrescan los combos de la Parte B; después se selecciona el valor del usuario.
            Usuarios_CargarCatalogos(function () {
                usr_esEdicion = true;
                $("#usr_modalTitulo").text("Editar Usuario");
                $("#usr_hdnUsuarioId").val(u.UsuarioId);
                $("#usr_txtNombre").val(u.Nombre);
                $("#usr_txtApellidos").val(u.Apellidos);
                $("#usr_ddlRol").val(u.RolId);
                $("#usr_txtCorreo").val(u.Correo);
                $("#usr_ddlTipoId").val(u.TipoIdentificacionId);
                $("#usr_txtIdentificacion").val(u.Identificacion);
                $("#usr_txtNumeroInterno").val(u.NumeroInterno);
                $("#usr_txtContrasena").val("");
                $("#usr_ddlCarrera").val(u.CarreraId || "");
                $("#usr_ddlDepartamento").val(u.DepartamentoId || "");
                $("#usr_ddlEquipo").val(u.EquipoId || "");
                $("#usr_ddlEstado").val(u.Activo);
                $("#usr_filaEstado").show();
                $("#usr_grupoContrasena").show();
                $("#usr_lblContrasena").html('Contrase&#241;a <small>(dejar vac&#237;o para no cambiar)</small>');
                Usuarios_CambioRol();
                $("#usr_modal").fadeIn(200);
            });
        },
        error: function () {
            Swal.fire("Error", "Error al obtener la informacion del usuario.", "error");
        }
    });
}

// -------------------- GUARDAR --------------------
function Usuarios_Guardar() {
    if (!ValidarSesion()) return;

    var nombre = $.trim($("#usr_txtNombre").val());
    var apellidos = $.trim($("#usr_txtApellidos").val());
    var rolId = $("#usr_ddlRol").val();
    var correo = $.trim($("#usr_txtCorreo").val());
    var tipoIdId = $("#usr_ddlTipoId").val();
    var identificacion = $.trim($("#usr_txtIdentificacion").val());
    var numeroInterno = $.trim($("#usr_txtNumeroInterno").val());
    var contrasena = $("#usr_txtContrasena").val();

    if (!nombre || !apellidos || !rolId || !correo || !tipoIdId || !identificacion || !numeroInterno) {
        Swal.fire("Atencion", "Completa todos los campos obligatorios.", "warning");
        return;
    }
    if (!usr_esEdicion && !contrasena) {
        Swal.fire("Atencion", "La contrasena es obligatoria para usuarios nuevos.", "warning");
        return;
    }

    var rolNum = parseInt(rolId);
    var carreraId = "";
    var departamentoId = "";
    var equipoId = "";

    if (rolNum === 1 || rolNum === 2) {
        carreraId = $("#usr_ddlCarrera").val();
        if (!carreraId) { Swal.fire("Atencion", "Selecciona una carrera.", "warning"); return; }
    } else if (rolNum === 3 || rolNum === 4) {
        departamentoId = $("#usr_ddlDepartamento").val();
        if (!departamentoId) { Swal.fire("Atencion", "Selecciona un departamento.", "warning"); return; }
        if (rolNum === 3) equipoId = $("#usr_ddlEquipo").val() || "";
    }

    var params;
    var metodo;

    if (usr_esEdicion) {
        var usuarioId = $("#usr_hdnUsuarioId").val();
        var activo = $("#usr_ddlEstado").val();
        // [0]=Inst, [1]=UsrGlobal, [2]=UsrId, [3]=Rol, [4]=Carrera, [5]=Depto, [6]=Equipo,
        // [7]=TipoId, [8]=Identificacion, [9]=NumInterno, [10]=Nombre, [11]=Apellidos, [12]=Correo, [13]=Contra, [14]=Activo
        params = [g_InstitucionId, g_UsuarioId, usuarioId, rolId, carreraId, departamentoId, equipoId,
                  tipoIdId, identificacion, numeroInterno, nombre, apellidos, correo, contrasena, activo];
        metodo = "ActualizarUsuario";
    } else {
        // [0]=Inst, [1]=UsrGlobal, [2]=Rol, [3]=Carrera, [4]=Depto, [5]=Equipo,
        // [6]=TipoId, [7]=Identificacion, [8]=NumInterno, [9]=Nombre, [10]=Apellidos, [11]=Correo, [12]=Contra
        params = [g_InstitucionId, g_UsuarioId, rolId, carreraId, departamentoId, equipoId,
                  tipoIdId, identificacion, numeroInterno, nombre, apellidos, correo, contrasena];
        metodo = "InsertarUsuario";
    }

    $.ajax({
        type: "POST", url: "frmPanelAdmin.aspx/" + metodo,
        data: JSON.stringify({ obj_Parametros_JS: params }),
        contentType: "application/json; charset=utf-8", dataType: "json",
        success: function (r) {
            var partes = r.d.split("<SPLITER>");
            var codigo = partes[0];
            var mensaje = partes[1];

            if (parseInt(codigo) > 0) {
                Swal.fire("Exito", mensaje, "success");
                Usuarios_CerrarModal();
                Usuarios_Listar();
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
function Usuarios_Eliminar(usuarioId, nombre) {
    if (!ValidarSesion()) return;

    Swal.fire({
        title: "Desactivar usuario",
        text: "¿Estas seguro de desactivar al usuario \"" + nombre + "\"?",
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#d33",
        confirmButtonText: "Si, desactivar",
        cancelButtonText: "Cancelar"
    }).then(function (result) {
        if (result.isConfirmed) {
            var params = [g_InstitucionId, g_UsuarioId, usuarioId.toString()];

            $.ajax({
                type: "POST", url: "frmPanelAdmin.aspx/EliminarUsuario",
                data: JSON.stringify({ obj_Parametros_JS: params }),
                contentType: "application/json; charset=utf-8", dataType: "json",
                success: function (r) {
                    var partes = r.d.split("<SPLITER>");
                    var codigo = partes[0];
                    var mensaje = partes[1];

                    if (parseInt(codigo) > 0) {
                        Swal.fire("Desactivado", mensaje, "success");
                        Usuarios_Listar();
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

// -------------------- REACTIVAR --------------------
// SP_ELIMINA_USUARIOS solo desactiva. Reactivar = SP_ACTUALIZA_USUARIOS con Activo = true.
// Como ese SP actualiza todos los campos, primero leemos los datos actuales (InfoUsuario)
// y los reenviamos sin cambios. Contraseña vacía = se conserva la actual.
function Usuarios_Reactivar(usuarioId, nombre) {
    if (!ValidarSesion()) return;

    Swal.fire({
        title: "Reactivar usuario",
        text: "¿Deseas reactivar al usuario \"" + nombre + "\"?",
        icon: "question",
        showCancelButton: true,
        confirmButtonText: "Sí, reactivar",
        cancelButtonText: "Cancelar"
    }).then(function (result) {
        if (!result.isConfirmed) return;

        // 1) Leer los datos actuales del usuario
        $.ajax({
            type: "POST", url: "frmPanelAdmin.aspx/InfoUsuario",
            data: JSON.stringify({ obj_Parametros_JS: [g_InstitucionId, g_UsuarioId, usuarioId] }),
            contentType: "application/json; charset=utf-8", dataType: "json",
            success: function (r) {
                if (!r.d || r.d.length === 0) {
                    Swal.fire("Error", "No se pudo obtener la información del usuario.", "error");
                    return;
                }
                var u = r.d[0];

                // 2) Reenviar los mismos datos con Activo = true (mismo orden que Usuarios_Guardar al editar)
                var params = [g_InstitucionId, g_UsuarioId, u.UsuarioId, u.RolId, u.CarreraId, u.DepartamentoId,
                    u.EquipoId, u.TipoIdentificacionId, u.Identificacion, u.NumeroInterno,
                    u.Nombre, u.Apellidos, u.Correo, "", "true"];

                $.ajax({
                    type: "POST", url: "frmPanelAdmin.aspx/ActualizarUsuario",
                    data: JSON.stringify({ obj_Parametros_JS: params }),
                    contentType: "application/json; charset=utf-8", dataType: "json",
                    success: function (r2) {
                        var partes = r2.d.split("<SPLITER>");
                        if (parseInt(partes[0]) > 0) {
                            Swal.fire("Reactivado", "El usuario se reactivó correctamente.", "success");
                            Usuarios_Filtrar();
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
                Swal.fire("Error", "Error al obtener la información del usuario.", "error");
            }
        });
    });
}
// -------------------- CERRAR MODAL --------------------
function Usuarios_CerrarModal() {
    $("#usr_modal").fadeOut(200);
}
