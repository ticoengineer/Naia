// =====================================================================================
// SESIÓN DEL USUARIO · Sesion.js  (se incluye en TODAS las páginas después del login)
// Lee las cookies que guardó InicioSesion.js.
// Cada página indica qué roles la pueden ver con data-roles en el <body>:
//   <body data-roles="4">    → solo Administrativo
//   <body data-roles="1,2">  → Estudiante y Profesor
// =====================================================================================

var g_Dominio = "localhost";
var g_PaginaLogin = "../Login/frmLogin.aspx";

// Valores de la sesión para los demás JS (ej. @IdUsuarioGlobal e @InstitucionId de los SP)
var g_UsuarioId = $.cookie('USRUNI');
var g_InstitucionId = $.cookie('USRINS');
var g_RolId = $.cookie('USRROL');

$(document).ready(function () {

    // 1. Sin sesión → al login
    if (!g_UsuarioId || !g_InstitucionId || !g_RolId) {
        location.href = g_PaginaLogin;
        return;
    }

    // 2. Rol sin permiso para esta página → al login
    var rolesPermitidos = String($("body").data("roles") || "").split(",");
    if (rolesPermitidos[0] !== "" && rolesPermitidos.indexOf(String(g_RolId)) === -1) {
        location.href = g_PaginaLogin;
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

function CerrarSesion() {
    var cookies = ['USRUNI', 'USRINS', 'USRROL', 'USRNOM', 'USREML', 'USRUNV'];

    $.each(cookies, function (i, nombre) {
        $.removeCookie(nombre, { path: '/', domain: g_Dominio });
    });

    location.href = g_PaginaLogin;
}