
// =====================================================================================
// PANEL · Panel.js
// Navegacion entre secciones del panel administrativo de Naia.
// =====================================================================================

$(document).ready(function () {
    // Mostrar Ubicaciones al cargar el panel
    panel_MostrarSeccion("seccionUbicaciones");
});

// Navegar entre las secciones
function panel_Navegar(boton) {

    var seccionId = $(boton).data("seccion");

    panel_MostrarSeccion(seccionId);

    // Actualizar el boton activo
    $(".admin-nav__item").removeClass("admin-nav__item--active");
    $(boton).addClass("admin-nav__item--active");
}

// Mostrar la seccion seleccionada
function panel_MostrarSeccion(seccionId) {

    // Ocultar todas las secciones
    $(".admin-section").hide();

    // Mostrar la seleccionada
    $("#" + seccionId).show();

    // Inicializar la funcionalidad correspondiente
    if (seccionId === "seccionUbicaciones") {
        ubi_Inicializar();
    }
    else if (seccionId === "seccionCategorias") {
        cat_Inicializar();
    }
    else if (seccionId === "seccionAuditoria") {
        aud_Inicializar();
    }
    else if (seccionId === "seccionConfiguracion") {
        cfg_Inicializar();
    }
    else if (seccionId === "seccionResumen") {
        res_Inicializar();
    }
}
