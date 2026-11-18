
/*
    NAIA - CONFIGURACION INSTITUCIONAL

    Consultar universidad
    Consultar planes
    Actualizar configuracion

    Los permisos y la identidad del usuario
    se validan en el servidor.
*/

var cfg_DatosInstitucion = null;
var cfg_Planes = [];
var cfg_Cargando = false;

// ==========================================
// INICIALIZAR CONFIGURACION
// ==========================================

function cfg_Inicializar() {
    cfg_CargarInformacion();
}

// ==========================================
// PETICIONES AL SERVIDOR
// ==========================================

function cfg_ConsultarServidor(metodo, datos) {
    return $.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/" + metodo,
        data: JSON.stringify(datos || {}),
        contentType: "application/json; charset=utf-8",
        dataType: "json"
    });
}

// ==========================================
// CARGAR INFORMACION Y PLANES
// ==========================================

function cfg_CargarInformacion() {

    if (cfg_Cargando) {
        return;
    }

    cfg_Cargando = true;
    cfg_BloquearBotones(true);

    $.when(
        cfg_ConsultarServidor("InfoInstitucion"),
        cfg_ConsultarServidor("ListarPlanesConfiguracion")
    )
        .done(function (respuestaInstitucion, respuestaPlanes) {

            var instituciones = respuestaInstitucion[0].d;
            var planes = respuestaPlanes[0].d;

            if (!Array.isArray(instituciones) ||
                instituciones.length === 0) {
                cfg_MostrarMensaje(
                    "No se encontró la información de la universidad.",
                    true
                );
                return;
            }

            cfg_DatosInstitucion = instituciones[0];
            cfg_Planes = Array.isArray(planes) ? planes : [];

            cfg_MostrarInformacion();
            cfg_CargarPlanes();

        })
        .fail(function (xhr) {

            console.error(
                "Error al consultar configuración:",
                xhr.responseText
            );

            cfg_MostrarMensaje(
                "No se pudo cargar la configuración. " +
                "Verificá tu sesión e intentá nuevamente.",
                true
            );

        })
        .always(function () {

            cfg_Cargando = false;
            cfg_BloquearBotones(false);

        });
}

// ==========================================
// MOSTRAR INFORMACION INSTITUCIONAL
// ==========================================

function cfg_MostrarInformacion() {

    var datos = cfg_DatosInstitucion;

    if (!datos) {
        return;
    }

    $("#cfgNombre").val(datos.NombreInstitucion || "");
    $("#cfgSiglas").val(datos.Siglas || "");
    $("#cfgDominio").val(datos.DominioCorreo || "");

    $("#cfgPlanActual").val(datos.NombrePlan || "");

    $("#cfgUsuariosActivos").val(
        datos.UsuariosActivos || "0"
    );

    $("#cfgMaxUsuarios").val(
        cfg_FormatearUsuarios(datos.MaxUsuarios)
    );

    $("#cfgPrecio").val(
        cfg_FormatearPrecio(datos.PrecioMensual)
    );

    var activa =
        String(datos.Activa).toLowerCase();

    $("#cfgEstado").val(
        activa === "true" || activa === "1"
            ? "Activa"
            : "Inactiva"
    );

    $("#cfgFechaCreacion").val(
        cfg_FormatearFecha(datos.FechaCreacion)
    );
}

// ==========================================
// CARGAR PLANES EN SELECT
// ==========================================

function cfg_CargarPlanes() {

    var selector = $("#cfgPlan");

    selector.empty();

    if (!cfg_DatosInstitucion) {
        return;
    }

    var planActualId =
        String(cfg_DatosInstitucion.PlanId);

    var planActualEncontrado = false;

    cfg_Planes.forEach(function (plan) {

        var planId = String(plan.PlanId);
        var activo = String(plan.Activo).toLowerCase();

        var estaActivo =
            activo === "true" || activo === "1";

        var esPlanActual =
            planId === planActualId;

        // Mostrar planes activos y conservar
        // el plan actual aunque esté inactivo.
        if (!estaActivo && !esPlanActual) {
            return;
        }

        if (esPlanActual) {
            planActualEncontrado = true;
        }

        var texto = plan.NombrePlan +
            " - " +
            cfg_FormatearUsuarios(plan.MaxUsuarios) +
            " usuarios - " +
            cfg_FormatearPrecio(plan.PrecioMensual);

        if (!estaActivo) {
            texto += " (plan actual no disponible)";
        }

        selector.append(
            $("<option>")
                .val(planId)
                .text(texto)
        );
    });

    if (!planActualEncontrado) {

        selector.append(
            $("<option>")
                .val(planActualId)
                .text(
                    cfg_DatosInstitucion.NombrePlan +
                    " (plan actual)"
                )
        );
    }

    selector.val(planActualId);
}

// ==========================================
// GUARDAR CONFIGURACION
// ==========================================

function cfg_Guardar() {

    if (cfg_Cargando) {
        return;
    }

    var planId = $("#cfgPlan").val();

    var nombre = $("#cfgNombre").val().trim();
    var siglas = $("#cfgSiglas").val().trim();

    // ======================================
    // VALIDACIONES
    // ======================================

    if (!nombre || !siglas) {

        cfg_MostrarMensaje(
            "El nombre y las siglas son obligatorios.",
            true
        );

        return;
    }

    if (nombre.length > 150 || siglas.length > 10) {

        cfg_MostrarMensaje(
            "El nombre o las siglas superan " +
            "la longitud permitida.",
            true
        );

        return;
    }

    if (!planId) {

        cfg_MostrarMensaje(
            "Seleccioná un plan válido.",
            true
        );

        return;
    }

    // ======================================
    // CONFIRMAR CAMBIOS
    // ======================================

    var confirmar = confirm(
        "¿Deseás guardar los cambios " +
        "de configuración de la universidad?"
    );

    if (!confirmar) {
        return;
    }

    cfg_Cargando = true;
    cfg_BloquearBotones(true);

    // Orden establecido en el WebMethod:
    // 0 = PlanId
    // 1 = NombreInstitucion
    // 2 = Siglas

    var parametros = [
        String(planId),
        nombre,
        siglas
    ];

    cfg_ConsultarServidor(
        "ActualizarInstitucion",
        {
            obj_Parametros_JS: parametros
        }
    )
        .done(function (respuesta) {

            var resultado = String(respuesta.d || "");
            var partes = resultado.split("<SPLITER>");

            var codigo = parseInt(partes[0], 10);
            var mensaje =
                partes[1] || "Respuesta no reconocida.";

            if (codigo > 0) {

                cfg_MostrarMensaje(mensaje, false);

                // Recargar los datos actualizados
                // una vez finalizada la operación.
                cfg_Cargando = false;
                cfg_CargarInformacion();

            } else {

                cfg_MostrarMensaje(mensaje, true);

            }

        })
        .fail(function (xhr) {

            console.error(
                "Error al guardar configuración:",
                xhr.responseText
            );

            cfg_MostrarMensaje(
                "No se pudieron guardar los cambios.",
                true
            );

        })
        .always(function () {

            cfg_Cargando = false;
            cfg_BloquearBotones(false);

        });
}

// ==========================================
// FORMATEAR CANTIDAD DE USUARIOS
// ==========================================

function cfg_FormatearUsuarios(valor) {

    if (valor === null ||
        valor === undefined ||
        valor === "") {

        return "Ilimitados";
    }

    return String(valor);
}

// ==========================================
// FORMATEAR PRECIO
// ==========================================

function cfg_FormatearPrecio(valor) {

    var numero = Number(valor);

    if (!Number.isFinite(numero)) {
        return "No disponible";
    }

    return numero.toLocaleString("es-CR", {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
    });
}

// ==========================================
// FORMATEAR FECHA
// ==========================================

function cfg_FormatearFecha(valor) {

    if (!valor) {
        return "No disponible";
    }

    // ASP.NET puede devolver fechas con el
    // formato /Date(1234567890000)/.
    var coincidencia =
        /\/Date\((-?\d+)\)\//.exec(valor);

    var fecha;

    if (coincidencia) {

        fecha = new Date(
            Number(coincidencia[1])
        );

    } else {

        fecha = new Date(valor);

    }

    if (isNaN(fecha.getTime())) {
        return String(valor);
    }

    return fecha.toLocaleDateString("es-CR");
}

// ==========================================
// BLOQUEAR BOTONES DURANTE PETICIONES
// ==========================================

function cfg_BloquearBotones(bloquear) {

    $("#cfgBtnGuardar").prop(
        "disabled",
        bloquear
    );
}

// ==========================================
// MOSTRAR MENSAJES
// ==========================================

function cfg_MostrarMensaje(mensaje, esError) {

    if (esError) {
        alert("Naia - Configuración\n\n" + mensaje);
    } else {
        alert("Naia\n\n" + mensaje);
    }
}
