// =====================================================================================
// PANEL · Panel.js
// Navegacion entre secciones del panel de administracion.
// Muestra/oculta los User Controls (divs con class="admin-section").
// =====================================================================================

$(document).ready(function () {
    // Al cargar, mostrar la primera seccion (Ubicaciones)
    panel_MostrarSeccion("seccionUbicaciones");
});

// ==================== NAVEGACION ====================
// Muestra la seccion seleccionada y oculta las demas
function panel_Navegar(boton) {
    var seccionId = $(boton).data("seccion");
    panel_MostrarSeccion(seccionId);

    // Actualizar el boton activo en la navegacion
    $(".admin-nav__item").removeClass("admin-nav__item--active");
    $(boton).addClass("admin-nav__item--active");
}

// Muestra una seccion por su ID y oculta todas las demas
function panel_MostrarSeccion(seccionId) {
    // Ocultar todas las secciones
    $(".admin-section").hide();

    // Mostrar la seccion seleccionada
    $("#" + seccionId).show();

    // Inicializar la seccion si tiene funcion de inicializacion
    if (seccionId === "seccionUbicaciones") {
        ubi_Inicializar();
    } else if (seccionId === "seccionCategorias") {
        cat_Inicializar();
    }
}
