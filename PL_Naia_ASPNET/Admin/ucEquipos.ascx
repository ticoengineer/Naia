<%@ Control Language="C#" AutoEventWireup="true" %>

<%--
    User Control: Seccion de Equipos de soporte del panel de administracion.
    Se muestra/oculta desde Panel.js cuando el admin navega a esta seccion.
    Prefijo "eqp_" en todos los IDs para evitar choques con otras secciones.
    Mismas clases de panel-admin.css que Carreras, Departamentos, Ubicaciones y Categorias.
    El JS (JS/Equipos.js) lo carga frmPanelAdmin.aspx: aqui NO se vuelve a incluir.
--%>

<div id="eqp_seccion" class="admin-section">

    <!-- ====== Encabezado de la seccion ====== -->
    <div class="admin-section__header">
        <div>
            <h2 class="admin-section__title">Equipos de soporte</h2>
            <p class="admin-section__subtitle">Grupos de técnicos que atienden los tiquetes (Redes, Laboratorios, Mesa de Ayuda...).</p>
        </div>
        <button id="eqp_btnNuevo" class="btn btn--primary" type="button" onclick="Equipos_AbrirModalNuevo()">
            + Nuevo equipo
        </button>
    </div>

    <!-- ====== Buscador ====== -->
    <div class="admin-search">
        <div class="input input--search">
            <img class="input__icon" src="Images/icon-tag.png" alt="" aria-hidden="true" width="16" height="16">
            <input id="eqp_txtFiltro" class="input__control" type="text" placeholder="Buscar por nombre o descripción..."
                   onkeyup="Equipos_Filtrar()">
        </div>
    </div>

    <!-- ====== Tabla de equipos ====== -->
    <div class="admin-table-wrapper">
        <table class="admin-table" id="eqp_tblEquipos">
            <thead>
                <tr>
                    <th>Equipo</th>
                    <th>Descripción</th>
                    <th>Técnicos activos</th>
                    <th>Estado</th>
                    <th class="admin-table__actions-col">Acciones</th>
                </tr>
            </thead>
            <tbody id="eqp_tbodyEquipos">
                <tr>
                    <td colspan="5" class="admin-table__loading">Cargando equipos...</td>
                </tr>
            </tbody>
        </table>
    </div>

    <!-- ====== Modal para crear / editar equipo ====== -->
    <div id="eqp_modal" class="modal" style="display: none;">
        <div class="modal__overlay" onclick="Equipos_CerrarModal()"></div>
        <div class="modal__content">
            <div class="modal__header">
                <h3 id="eqp_modalTitulo" class="modal__title">Nuevo equipo</h3>
                <button class="modal__close" type="button" onclick="Equipos_CerrarModal()">&times;</button>
            </div>

            <form id="eqp_frmEquipo" class="form" onsubmit="return false;">
                <input type="hidden" id="eqp_hdnEquipoId" value="0">

                <div class="form__stack">
                    <div class="field">
                        <label class="field__label" for="eqp_txtNombre">Nombre <span class="required">*</span></label>
                        <div class="input">
                            <input id="eqp_txtNombre" class="input__control" type="text" maxlength="80"
                                   placeholder="Ej. Redes y Conectividad" required>
                        </div>
                    </div>

                    <div class="field">
                        <label class="field__label" for="eqp_txtDescripcion">Descripción</label>
                        <div class="input">
                            <textarea id="eqp_txtDescripcion" class="input__control input__control--textarea" maxlength="250" rows="3"
                                      placeholder="Qué tipo de problemas atiende este equipo (opcional)"></textarea>
                        </div>
                    </div>
                </div>

                <div class="modal__actions">
                    <button class="btn btn--secondary" type="button" onclick="Equipos_CerrarModal()">Cancelar</button>
                    <button id="eqp_btnGuardar" class="btn btn--primary" type="button" onclick="Equipos_Guardar()">
                        Guardar
                    </button>
                </div>
            </form>
        </div>
    </div>

</div>
