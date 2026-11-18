
// =====================================================================================
// SESION DEL USUARIO · Sesion.js
// Control de acceso visual y cierre de sesion.
//
// IMPORTANTE:
// La autorizacion real de cada operacion
// debe comprobarse en ASP.NET mediante
// la sesion del servidor.
// =====================================================================================

var g_Dominio = "localhost";
var g_PaginaLogin = "../Login/frmLogin.aspx";

// Datos utilizados por las interfaces existentes
var g_UsuarioId = $.cookie("USRUNI");
var g_InstitucionId = $.cookie("USRINS");
var g_RolId = $.cookie("USRROL");

var g_CerrandoSesion = false;

$(document).ready(function () {

    // ==========================================
    // 1. Comprobar cookies de la interfaz
    // ==========================================

    if (!g_UsuarioId ||
        !g_InstitucionId ||
        !g_RolId) {

        location.replace(g_PaginaLogin);
        return;
    }

    // ==========================================
    // 2. Comprobar rol para la navegacion
    // ==========================================

    var rolesPermitidos = String(
        $("body").data("roles") || ""
    ).split(",");

    if (rolesPermitidos[0] !== "" &&
        rolesPermitidos.indexOf(
            String(g_RolId)
        ) === -1) {

        location.replace(g_PaginaLogin);
        return;
    }

    // ==========================================
    // 3. Mostrar informacion del usuario
    // ==========================================

    $(".js-usuario-nombre").text(
        $.cookie("USRNOM") || ""
    );

    $(".js-usuario-correo").text(
        $.cookie("USREML") || ""
    );

    $(".js-usuario-universidad").text(
        $.cookie("USRUNV") || ""
    );

    // ==========================================
    // 4. Cerrar sesion
    // ==========================================

    $(".js-cerrar-sesion").on(
        "click",
        function (e) {

            e.preventDefault();
            CerrarSesion();

        }
    );

});

// ==========================================
// ELIMINAR COOKIES DE LA INTERFAZ
// ==========================================

function ses_EliminarCookies() {

    var cookies = [
        "USRUNI",
        "USRINS",
        "USRROL",
        "USRNOM",
        "USREML",
        "USRUNV"
    ];

    $.each(cookies, function (i, nombre) {

        // Cookies guardadas sin dominio explicito
        $.removeCookie(nombre, {
            path: "/"
        });

        // Compatibilidad con cookies anteriores
        // guardadas con dominio localhost
        $.removeCookie(nombre, {
            path: "/",
            domain: g_Dominio
        });

    });

    g_UsuarioId = null;
    g_InstitucionId = null;
    g_RolId = null;
}

// ==========================================
// CERRAR SESION EN SERVIDOR Y NAVEGADOR
// ==========================================

function CerrarSesion() {

    if (g_CerrandoSesion) {
        return;
    }

    g_CerrandoSesion = true;

    $(".js-cerrar-sesion")
        .css("pointer-events", "none");

    $.ajax({

        type: "POST",

        url: g_PaginaLogin + "/CerrarSesionServidor",

        data: "{}",

        contentType: "application/json; charset=utf-8",

        dataType: "json",

        timeout: 15000

    })
        .done(function (respuesta) {

            if (respuesta && respuesta.d === true) {

                // El servidor confirmo el cierre
                ses_EliminarCookies();

                // Volver al login
                location.replace(g_PaginaLogin);

            } else {

                ses_ErrorCerrarSesion();

            }

        })
        .fail(function (xhr, estado) {

            console.error(
                "Error al cerrar sesion:",
                estado,
                xhr.status
            );

            ses_ErrorCerrarSesion();

        });

}

// ==========================================
// ERROR AL CERRAR SESION
// ==========================================

function ses_ErrorCerrarSesion() {

    g_CerrandoSesion = false;

    $(".js-cerrar-sesion")
        .css("pointer-events", "");

    alert(
        "No se pudo confirmar el cierre de sesion " +
        "en el servidor. Intentá nuevamente."
    );
}
