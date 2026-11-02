// =====================================================================================
// INICIO DE SESIÓN · InicioSesion.js
// Flujo: formulario → IniciarSesion() → WebMethod → BLL → SP_INICIAR_SESION
//        Si es correcto: se guardan los datos del usuario en cookies (como el profe)
//        y se redirige a la página de su rol.
// =====================================================================================

var g_Dominio = "localhost";   // dominio de las cookies (en producción, el dominio del sitio)
var TLC = 60;                   // días que dura la sesión (cookie)

$(document).ready(function () {

    // Mostrar u ocultar la contraseña con el botón del ojo
    $("#btnVerContrasena").on("click", function () {
        var campo = $("#txtContrasena");
        var mostrar = campo.attr("type") === "password";

        campo.attr("type", mostrar ? "text" : "password");
        $(this).attr("aria-label", mostrar ? "Ocultar contraseña" : "Mostrar contraseña");
    });

    // Las cuentas las administra cada universidad
    $("#lnkOlvidoContrasena").on("click", function (e) {
        e.preventDefault();
        Swal.fire({
            icon: 'info',
            title: '¿Olvidaste tu contraseña?',
            text: 'Comunícate con el administrador de tu universidad para que la restablezca.'
        });
    });
});


// Se ejecuta al enviar el formulario (action="javascript: IniciarSesion()")
function IniciarSesion() {
    // Arreglo de parámetros. EL ORDEN IMPORTA: el WebMethod lo lee por posición
    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = $("#txtCorreo").val().trim().toLowerCase();   // Correo
    obj_Parametros_JS[1] = $("#txtContrasena").val();                    // Contrasena

    var parametros = JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS });

    $("#btnIngresar").prop("disabled", true);   // evita doble clic

    jQuery.ajax({
        type: "POST",
        url: "frmLogin.aspx/IniciarSesion",
        data: parametros,
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            var res = msg.d;

            if (res === undefined) {
                Swal.fire({ icon: 'error', title: 'Error en la conexión', text: 'Error en la conexión a la base de datos' });
                $("#btnIngresar").prop("disabled", false);
                return;
            }

            // [0] Codigo (UsuarioId) · [1] Mensaje · [2] InstitucionId · [3] RolId
            // [4] Nombre completo · [5] Correo · [6] Universidad · [7] Página destino
            var arreglo = res.split("<SPLITER>");
            var resultado = parseInt(arreglo[0]);

            if (resultado > 0) {
                $.cookie('USRUNI', arreglo[0], { expires: TLC, path: '/', domain: g_Dominio });   // UsuarioId
                $.cookie('USRINS', arreglo[2], { expires: TLC, path: '/', domain: g_Dominio });   // InstitucionId
                $.cookie('USRROL', arreglo[3], { expires: TLC, path: '/', domain: g_Dominio });   // RolId
                $.cookie('USRNOM', arreglo[4], { expires: TLC, path: '/', domain: g_Dominio });   // Nombre completo
                $.cookie('USREML', arreglo[5], { expires: TLC, path: '/', domain: g_Dominio });   // Correo
                $.cookie('USRUNV', arreglo[6], { expires: TLC, path: '/', domain: g_Dominio });   // Universidad

                Swal.fire({
                    icon: 'success', title: 'Inicio de sesión', text: arreglo[1],
                    showConfirmButton: false, timer: 2000, timerProgressBar: true
                });
                setTimeout(function () { location.href = arreglo[7]; }, 2000);
            }
            else {
                Swal.fire({ icon: 'error', title: 'Inicio de sesión', text: arreglo[1] });
                $("#txtContrasena").val("").focus();
                $("#btnIngresar").prop("disabled", false);
            }
        },
        error: function () {
            Swal.fire({ icon: 'error', title: 'Error en la conexión', text: 'Error en la conexión a la base de datos' });
            $("#btnIngresar").prop("disabled", false);
        }
    });
}