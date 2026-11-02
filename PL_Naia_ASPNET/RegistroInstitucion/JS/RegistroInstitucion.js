// =====================================================================================
// REGISTRO DE UNIVERSIDAD · RegistroInstitucion.js
// Flujo: formulario → RegistrarInstitucion() → WebMethod → BLL → SP_INSERTA_INSTITUCIONES
// =====================================================================================

// Al cargar la página
$(document).ready(function () {

    // Copia el dominio escrito en la sección 2 al final del correo del administrador.
    // Es solo visual; el correo completo lo arma el servidor.
    function ActualizarSufijoCorreo() {
        var valor = $("#txtDominio").val().trim().replace(/^@+/, '').toLowerCase();
        var texto = valor ? '@' + valor : $("#sufijo-dominio").data("vacio");

        $("#sufijo-dominio")
            .text(texto)
            .attr("title", texto)
            .toggleClass("is-filled", valor.length > 0);
    }

    $("#txtDominio").on("input", ActualizarSufijoCorreo);
    ActualizarSufijoCorreo();

    // Tarjetas de planes desde la base de datos
    CargarPlanes();
});


// Carga las tarjetas de planes desde la base de datos (SP_LISTAR_PLANES).
// Si un precio o límite cambia en la BD, la página lo muestra automáticamente.
function CargarPlanes() {
    jQuery.ajax({
        type: "POST",
        url: "frmRegistroInstitucion.aspx/ListarPlanes",
        data: "{}",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            var planes = msg.d;

            if (!planes || planes.length === 0) {
                $("#contenedorPlanes").html('<p class="field__hint">No hay planes disponibles en este momento.</p>');
                $("#btnRegistrar").prop("disabled", true);
                return;
            }

            var recomendado = Math.floor(planes.length / 2);   // se marca el plan del medio
            var html = "";

            $.each(planes, function (i, plan) {
                var id = "rbPlan" + plan.PlanId;
                var detalle = (plan.MaxUsuarios === "")
                    ? "Usuarios ilimitados"
                    : "Hasta " + Number(plan.MaxUsuarios).toLocaleString("es-CR") + " usuarios";

                html += '<input type="radio" name="PlanId" id="' + id + '" value="' + plan.PlanId + '"' + (i === recomendado ? ' checked' : '') + ' required>' +
                    '<label class="plan-card" for="' + id + '">' +
                    (i === recomendado ? '<span class="plan-card__tag">Recomendado</span>' : '') +
                    '<span class="plan-card__name">' + plan.Nombre + '</span>' +
                    '<span class="plan-card__price">$' + plan.Precio + '<small>/mes</small></span>' +
                    '<span class="plan-card__detail">' + detalle + '</span>' +
                    '</label>';
            });

            $("#contenedorPlanes").html(html);
        },
        error: function () {
            $("#contenedorPlanes").html('<p class="field__hint">No se pudieron cargar los planes.</p>');
            $("#btnRegistrar").prop("disabled", true);
        }
    });
}


// Se ejecuta al enviar el formulario (action="javascript: RegistrarInstitucion()")
function RegistrarInstitucion() {
    // Validación que el SP no puede hacer: las contraseñas deben coincidir
    if ($("#txtContrasena").val() !== $("#txtConfirmar").val()) {
        Swal.fire({ icon: 'warning', title: 'Registro de universidad', text: 'Las contraseñas no coinciden.' });
        return;
    }

    // Arreglo de parámetros. EL ORDEN IMPORTA: el WebMethod lo lee por posición
    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = $("input[name='PlanId']:checked").val();                         // PlanId
    obj_Parametros_JS[1] = $("#txtNombreInstitucion").val().trim();                          // NombreInstitucion
    obj_Parametros_JS[2] = $("#txtSiglas").val().trim();                                     // Siglas
    obj_Parametros_JS[3] = $("#txtDominio").val().trim().replace(/^@+/, '').toLowerCase();   // DominioCorreo
    obj_Parametros_JS[4] = $("#ddlTipoIdentificacion").val();                                // TipoIdentificacionId
    obj_Parametros_JS[5] = $("#txtIdentificacion").val().trim();                             // Identificacion
    obj_Parametros_JS[6] = $("#txtNumeroInterno").val().trim();                              // NumeroInterno
    obj_Parametros_JS[7] = $("#txtNombre").val().trim();                                     // Nombre
    obj_Parametros_JS[8] = $("#txtApellidos").val().trim();                                  // Apellidos
    obj_Parametros_JS[9] = $("#txtCorreoUsuario").val().trim().toLowerCase();                // parte del correo antes de la @
    obj_Parametros_JS[10] = $("#txtContrasena").val();                                       // Contrasena

    var parametros = JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS });

    $("#btnRegistrar").prop("disabled", true);   // evita que registren dos veces por doble clic

    jQuery.ajax({
        type: "POST",
        url: "frmRegistroInstitucion.aspx/RegistrarInstitucion",
        data: parametros,
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            var arreglo = msg.d.split("<SPLITER>");
            var resultado = parseInt(arreglo[0]);

            if (resultado > 0) {
                Swal.fire({
                    icon: 'success', title: '¡Universidad registrada!', text: arreglo[1],
                    showConfirmButton: false, timer: 3500, timerProgressBar: true
                });
                setTimeout(function () { location.href = "../Login/frmLogin.aspx"; }, 3500);
            }
            else {
                Swal.fire({ icon: 'error', title: 'No se pudo registrar', text: arreglo[1] });
                $("#btnRegistrar").prop("disabled", false);
            }
        },
        error: function () {
            Swal.fire({ icon: 'error', title: 'Error de conexión', text: 'No se pudo conectar con el servidor.' });
            $("#btnRegistrar").prop("disabled", false);
        }
    });
}