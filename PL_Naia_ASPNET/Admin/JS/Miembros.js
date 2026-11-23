// =====================================================================================
// MIEMBROS · Miembros.js
// Al hacer clic en una fila de Carreras, Departamentos o Equipos se despliega debajo la lista
// (SOLO LECTURA) de los usuarios activos: nombre y rol. Otro clic la cierra.
// Para editar a una persona se usa la sección Usuarios.
// Flujo: clic en <tr class="fila-clic" data-id="..."> → WebMethod ListarMiembros → SP_LISTAR_MIEMBROS
// =====================================================================================

// Qué tabla es de qué tipo y cuántas columnas tiene (para el colspan de la fila desplegada)
var MIEMBROS_TABLAS = [
    { tbody: "#tbodyCarreras",       tipo: "Carrera",      columnas: 4, vacio: "No hay usuarios activos en esta carrera." },
    { tbody: "#tbodyDepartamentos",  tipo: "Departamento", columnas: 4, vacio: "No hay usuarios activos en este departamento." },
    { tbody: "#eqp_tbodyEquipos",    tipo: "Equipo",       columnas: 5, vacio: "No hay técnicos activos en este equipo." }
];

$(function () {
    $.each(MIEMBROS_TABLAS, function (i, cfg) {
        // Las filas se crean con JS, por eso se escuchan desde el document
        $(document).on("click", cfg.tbody + " tr.fila-clic", function (e) {
            // Los botones ✏️ 🗑️ ♻️ siguen haciendo lo suyo: no abren la lista
            if ($(e.target).closest("button, a").length) return;
            Miembros_Toggle($(this), cfg);
        });
    });
});

function Miembros_Toggle(fila, cfg) {
    var siguiente = fila.next("tr.fila-miembros");

    // Ya estaba abierta → se cierra
    if (siguiente.length) {
        siguiente.remove();
        fila.removeClass("is-open");
        return;
    }

    if (!ValidarSesion()) return;

    fila.addClass("is-open");
    var detalle = $('<tr class="fila-miembros"><td colspan="' + cfg.columnas + '">' +
                    '<div class="miembros"><p class="miembros__vacio">Cargando…</p></div></td></tr>');
    fila.after(detalle);

    var obj_Parametros_JS = new Array();
    obj_Parametros_JS[0] = g_InstitucionId;          // @InstitucionId
    obj_Parametros_JS[1] = g_UsuarioId;              // @IdUsuarioGlobal
    obj_Parametros_JS[2] = cfg.tipo;                 // @Tipo
    obj_Parametros_JS[3] = String(fila.data("id"));  // @Id

    jQuery.ajax({
        type: "POST",
        url: "frmPanelAdmin.aspx/ListarMiembros",
        data: JSON.stringify({ "obj_Parametros_JS": obj_Parametros_JS }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        cache: false,
        success: function (msg) {
            var lista = msg.d || [];
            var caja = detalle.find(".miembros");

            if (lista.length === 0) {
                caja.html('<p class="miembros__vacio">' + cfg.vacio + '</p>');
                return;
            }

            var html = '<ul class="miembros__lista">';
            $.each(lista, function (i, m) {
                html += '<li class="miembros__item">' +
                        '<span class="miembros__nombre">' + Miembros_Esc(m.Nombre) + '</span>' +
                        '<span class="miembros__rol">' + Miembros_Esc(m.Rol) + '</span>' +
                        '</li>';
            });
            html += '</ul>';
            caja.html(html);
        },
        error: function () {
            detalle.find(".miembros").html('<p class="miembros__vacio">No se pudo cargar la lista.</p>');
        }
    });
}

function Miembros_Esc(texto) {
    return $("<div>").text(texto == null ? "" : String(texto)).html();
}
