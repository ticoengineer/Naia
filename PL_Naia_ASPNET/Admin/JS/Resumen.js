
// ========================================================================
// NAIA - RESUMEN ADMINISTRATIVO
// Consulta SP_DASHBOARD_TICKETS mediante DashboardTickets().
// ========================================================================

var res_Cargando = false;

// Inicializar la seccion Resumen
function res_Inicializar() {
    res_CargarDashboard();
}

// Consultar indicadores del dashboard
function res_CargarDashboard() {

    // Evitar solicitudes duplicadas
    if (res_Cargando) {
        return;
    }

    res_Cargando = true;

    $("#resBtnActualizar").prop("disabled", true);
    $("#resMensaje")
        .text("Cargando indicadores...")
        .show();

    $.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/DashboardTickets",
        data: JSON.stringify({}),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        timeout: 30000
    })
        .done(function (respuesta) {

            var registros = respuesta.d;

            if (!Array.isArray(registros) || registros.length === 0) {
                res_LimpiarTarjetas();
                $("#resMensaje")
                    .text("No se recibieron indicadores del servidor.")
                    .show();
                return;
            }

            var datos = registros[0];

            // Mostrar los nueve valores devueltos por SQL Server
            res_AsignarValor("resAbiertos", datos.Abiertos);
            res_AsignarValor("resNuevos", datos.Nuevos);
            res_AsignarValor("resAsignados", datos.Asignados);
            res_AsignarValor("resEnProgreso", datos.EnProgreso);
            res_AsignarValor("resEnEspera", datos.EnEspera);
            res_AsignarValor("resResueltos", datos.Resueltos);
            res_AsignarValor("resCerradosEsteMes", datos.CerradosEsteMes);
            res_AsignarValor("resVencidos", datos.Vencidos);
            res_AsignarValor("resAsignadosAMi", datos.AsignadosAMi);

            $("#resMensaje")
                .text("Indicadores actualizados correctamente.")
                .show();

        })
        .fail(function (xhr, estado) {

            console.error(
                "Error al consultar el resumen:",
                estado,
                xhr.responseText
            );

            res_LimpiarTarjetas();

            if (xhr.status === 401 || xhr.status === 403) {
                $("#resMensaje").text(
                    "No tenés autorización para consultar el resumen. " +
                    "Iniciá sesión nuevamente."
                );
            }
            else if (estado === "timeout") {
                $("#resMensaje").text(
                    "La consulta tardó demasiado. " +
                    "Verificá que Visual Studio no esté detenido en una excepción."
                );
            }
            else {
                $("#resMensaje").text(
                    "No fue posible cargar los indicadores. " +
                    "Revisá la conexión con el servidor."
                );
            }

            $("#resMensaje").show();

        })
        .always(function () {

            res_Cargando = false;
            $("#resBtnActualizar").prop("disabled", false);

        });
}

// Mostrar un indicador numérico
function res_AsignarValor(id, valor) {

    var numero = Number(valor);

    if (!Number.isFinite(numero) || numero < 0) {
        $("#" + id).text("—");
        return;
    }

    $("#" + id).text(
        numero.toLocaleString("es-CR", {
            maximumFractionDigits: 0
        })
    );
}

// Limpiar los indicadores si falla la consulta
function res_LimpiarTarjetas() {

    var tarjetas = [
        "resAbiertos",
        "resNuevos",
        "resAsignados",
        "resEnProgreso",
        "resEnEspera",
        "resResueltos",
        "resCerradosEsteMes",
        "resVencidos",
        "resAsignadosAMi"
    ];

    tarjetas.forEach(function (id) {
        $("#" + id).text("—");
    });
}
