
/* ==========================================
   NAIA - PANEL DEL ADMINISTRADOR
   Parte D - Anthony
   Navegación entre secciones
   ========================================== */

(function () {
    "use strict";

    const seccionesValidas = [
        "resumen",
        "tiquetes",
        "usuarios",
        "carreras",
        "departamentos",
        "equipos",
        "ubicaciones",
        "categorias",
        "auditoria",
        "configuracion"
    ];

    const seccionesCargadas = new Set();

    const funcionesAlAbrir = {
        resumen: "Resumen_AlAbrir",
        usuarios: "Usuarios_AlAbrir",
        carreras: "Carreras_AlAbrir",
        departamentos: "Departamentos_AlAbrir",
        equipos: "Equipos_AlAbrir",
        ubicaciones: "Ubicaciones_AlAbrir",
        categorias: "Categorias_AlAbrir",
        auditoria: "Auditoria_AlAbrir",
        configuracion: "Configuracion_AlAbrir",
        tiquetes: "Tiquetes_AlAbrir"
    };

    function Panel_MostrarSeccion(nombre) {

        if (!seccionesValidas.includes(nombre)) {
            nombre = "resumen";
        }

        document.querySelectorAll(".panel-seccion").forEach(function (seccion) {
            seccion.hidden = seccion.id !== "seccion-" + nombre;
        });

        document.querySelectorAll(".panel-menu a[data-seccion]").forEach(function (enlace) {
            const activo = enlace.dataset.seccion === nombre;

            enlace.classList.toggle("activo", activo);

            if (activo) {
                enlace.setAttribute("aria-current", "page");
            } else {
                enlace.removeAttribute("aria-current");
            }
        });

        if (!seccionesCargadas.has(nombre)) {

            const nombreFuncion = funcionesAlAbrir[nombre];
            const funcion = window[nombreFuncion];

            if (typeof funcion === "function") {
                funcion();
                seccionesCargadas.add(nombre);
            }
        }
    }

    function Panel_LeerSeccionURL() {
        return window.location.hash.substring(1).toLowerCase();
    }

    document.addEventListener("DOMContentLoaded", function () {

        document.querySelectorAll(".panel-menu a[data-seccion]").forEach(function (enlace) {

            enlace.addEventListener("click", function (evento) {
                evento.preventDefault();

                const nombre = enlace.dataset.seccion;

                if (window.location.hash === "#" + nombre) {
                    Panel_MostrarSeccion(nombre);
                } else {
                    window.location.hash = nombre;
                }
            });
        });

        window.addEventListener("hashchange", function () {
            Panel_MostrarSeccion(Panel_LeerSeccionURL());
        });

        Panel_MostrarSeccion(Panel_LeerSeccionURL());
    });

    window.Panel_MostrarSeccion = Panel_MostrarSeccion;

})();
