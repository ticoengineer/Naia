// =====================================================================================
// SESIÓN DEL USUARIO · Sesion.js  (se incluye en TODAS las páginas después del login)
// 1. ValidarSesion(): se llama al cargar la página y ANTES de cada llamada AJAX.
// 2. CerrarSesion(): avisa al servidor (SP_CERRAR_SESION), borra las cookies y sale.
// Cada página indica qué roles la pueden ver con data-roles en el <body>.
// =====================================================================================

var g_Dominio = "localhost";
var g_PaginaLogin = "../Login/frmLogin.aspx";
var g_Cookies = ['USRUNI', 'USRINS', 'USRROL', 'USRNOM', 'USREML', 'USRUNV'];

// Valores de la sesión para los demás JS (se refrescan en cada ValidarSesion)
var g_UsuarioId = $.cookie('USRUNI');
var g_InstitucionId = $.cookie('USRINS');
var g_RolId = $.cookie('USRROL');

$(document).ready(function () {

    // 1. Sin sesión → mensaje y al login
    if (!ValidarSesion()) return;

    // 2. Rol sin permiso para esta página → al login
    var rolesPermitidos = String($("body").data("roles") || "").split(",");
    if (rolesPermitidos[0] !== "" && rolesPermitidos.indexOf(String(g_RolId)) === -1) {
        SesionInvalida("No tienes permiso para ver esta página.");
        return;
    }

    // 3. Datos del usuario en pantalla
    $(".js-usuario-nombre").text($.cookie('USRNOM'));
    $(".js-usuario-correo").text($.cookie('USREML'));
    $(".js-usuario-universidad").text($.cookie('USRUNV'));

    // 4. Cerrar sesión
    $(".js-cerrar-sesion").on("click", function (e) {
        e.preventDefault();
        CerrarSesion();
    });
});


// Vuelve a leer las cookies. Si falta alguna, avisa y manda al login.
// Uso en cada función AJAX:   if (!ValidarSesion()) return;
function ValidarSesion() {
    g_UsuarioId = $.cookie('USRUNI');
    g_InstitucionId = $.cookie('USRINS');
    g_RolId = $.cookie('USRROL');

    if (!g_UsuarioId || g_UsuarioId == "0" || !g_InstitucionId || !g_RolId) {
        SesionInvalida("No se ha podido validar la información del usuario. Por favor, inicie sesión en el sistema.");
        return false;
    }
    return true;
}

function SesionInvalida(mensaje) {
    BorrarCookiesSesion();
    Swal.fire({
        icon: 'error', title: 'Información de credenciales', text: mensaje,
        showConfirmButton: false, timer: 3000, timerProgressBar: true
    });
    setTimeout(function () { location.href = g_PaginaLogin; }, 3000);
}

function BorrarCookiesSesion() {
    $.each(g_Cookies, function (i, nombre) {
        $.removeCookie(nombre, { path: '/', domain: g_Dominio });
    });
}


// Cierre de sesión: WebMethod → BLL → SP_CERRAR_SESION (queda en Auditoría)
function CerrarSesion() {
    if (!ValidarSesion()) return;

    var nombre = ($.cookie('USRNOM') || "").split(" ")[0];

    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;   // @InstitucionId
    obj_Parametros_JS[1] = g_UsuarioId;       // @IdUsuarioGlobal

    jQuery.ajax({
        type: "POST",
        url: "../Login/frmLogin.aspx/CerrarSesion",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            var res = msg.d;

            if (res === undefined) {
                Swal.fire({ icon: 'error', title: 'Error en la conexión', text: 'Error en la conexión a la base de datos' });
                return;
            }

            var arreglo = res.split("<SPLITER>");

            if (parseInt(arreglo[0]) > 0) {
                BorrarCookiesSesion();
                Swal.fire({
                    icon: 'success', title: 'Cierre de sesión', text: 'Gracias ' + nombre + '. ¡Hasta pronto!',
                    showConfirmButton: false, timer: 2000, timerProgressBar: true
                });
                setTimeout(function () { location.href = g_PaginaLogin; }, 2000);
            }
            else {
                Swal.fire({ icon: 'error', title: 'Cierre de sesión', text: arreglo[1] });
            }
        },
        error: function () {
            Swal.fire({ icon: 'error', title: 'Error en la conexión', text: 'Error en la conexión a la base de datos' });
        }
    });
}