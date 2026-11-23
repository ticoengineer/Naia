<%@ Control Language="C#" AutoEventWireup="true" %>

<%--
    User Control: Seccion de Departamentos del panel de administracion.
    Se muestra/oculta desde Panel.js cuando el admin navega a esta seccion.
    Prefijo "dep" en todos los IDs para evitar choques con otras secciones.
    Editar solo cambia el nombre; activar/desactivar se hace con los botones de la tabla.
    "Administración General" no se puede renombrar ni desactivar (lo valida el SP).
--%>

<div id="seccionDepartamentos" class="admin-section">

    <!-- ====== Encabezado de la seccion ====== -->
    <div class="admin-section__header">
        <div>
            <h2 class="admin-section__title">Departamentos</h2>
            <p class="admin-section__subtitle">Áreas de la universidad donde trabajan los técnicos de soporte y los administrativos.</p>
        </div>
        <button id="btnDepNuevo" class="btn btn--primary" type="button" onclick="dep_AbrirModalNuevo()">
            + Nuevo departamento
        </button>
    </div>

    <!-- ====== Buscador ====== -->
    <div class="admin-search">
        <div class="input input--search">
            <img class="input__icon" src="Images/icon-tag.png" alt="" aria-hidden="true" width="16" height="16">
            <input id="txtDepBuscar" class="input__control" type="text" placeholder="Buscar por nombre..."
                   onkeyup="dep_Filtrar()">
        </div>
    </div>

    <!-- ====== Tabla de departamentos ====== -->
    <div class="admin-table-wrapper">
        <table class="admin-table" id="tblDepartamentos">
            <thead>
                <tr>
                    <th>Departamento</th>
                    <th>Usuarios activos</th>
                    <th>Estado</th>
                    <th class="admin-table__actions-col">Acciones</th>
                </tr>
            </thead>
            <tbody id="tbodyDepartamentos">
                <tr>
                    <td colspan="4" class="admin-table__loading">Cargando departamentos...</td>
                </tr>
            </tbody>
        </table>
    </div>

    <!-- ====== Modal para crear / editar departamento ====== -->
    <div id="modalDepartamento" class="modal" style="display: none;">
        <div class="modal__overlay" onclick="dep_CerrarModal()"></div>
        <div class="modal__content">
            <div class="modal__header">
                <h3 id="modalDepTitulo" class="modal__title">Nuevo departamento</h3>
                <button class="modal__close" type="button" onclick="dep_CerrarModal()">&times;</button>
            </div>

            <form id="frmDepartamento" class="form" onsubmit="return false;">
                <input type="hidden" id="hdnDepId" value="0">

                <div class="form__stack">
                    <div class="field">
                        <label class="field__label" for="txtDepNombre">Nombre <span class="required">*</span></label>
                        <div class="input">
                            <input id="txtDepNombre" class="input__control" type="text" maxlength="120"
                                   placeholder="Ej. Tecnologías de Información" required>
                        </div>
                    </div>
                </div>

                <div class="modal__actions">
                    <button class="btn btn--secondary" type="button" onclick="dep_CerrarModal()">Cancelar</button>
                    <button id="btnDepGuardar" class="btn btn--primary" type="button" onclick="dep_Guardar()">
                        Guardar
                    </button>
                </div>
            </form>
        </div>
    </div>

</div>
