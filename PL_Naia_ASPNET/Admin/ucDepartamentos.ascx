<%@ Control Language="C#" AutoEventWireup="true" %>

<%--
    User Control: Seccion de Departamentos del panel de administracion.
    Prefijo "dep" en todos los IDs.
--%>

<div id="seccionDepartamentos" class="admin-section" style="display: none;">

    <div class="admin-section__header">
        <div>
            <h2 class="admin-section__title">Departamentos</h2>
            <p class="admin-section__subtitle">Administra los departamentos academicos dentro de cada carrera.</p>
        </div>
        <button id="btnDepNuevo" class="btn btn--primary" type="button" onclick="dep_AbrirModalNuevo()">
            + Nuevo departamento
        </button>
    </div>

    <div class="admin-search">
        <div class="input input--search">
            <img class="input__icon" src="Images/icon-tag.png" alt="" aria-hidden="true" width="16" height="16">
            <input id="txtDepBuscar" class="input__control" type="text" placeholder="Buscar por nombre, codigo o carrera..."
                   onkeyup="dep_Filtrar()">
        </div>
    </div>

    <div class="admin-table-wrapper">
        <table class="admin-table" id="tblDepartamentos">
            <thead>
                <tr>
                    <th>Nombre</th>
                    <th>Codigo</th>
                    <th>Carrera</th>
                    <th>Estado</th>
                    <th class="admin-table__actions-col">Acciones</th>
                </tr>
            </thead>
            <tbody id="tbodyDepartamentos">
                <tr><td colspan="5" class="admin-table__loading">Cargando departamentos...</td></tr>
            </tbody>
        </table>
    </div>

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
                        <label class="field__label" for="ddlDepCarrera">Carrera <span class="required">*</span></label>
                        <div class="select">
                            <select id="ddlDepCarrera" class="select__control">
                                <option value="">-- Seleccionar carrera --</option>
                            </select>
                        </div>
                    </div>
                    <div class="field">
                        <label class="field__label" for="txtDepNombre">Nombre <span class="required">*</span></label>
                        <div class="input">
                            <input id="txtDepNombre" class="input__control" type="text" maxlength="120"
                                   placeholder="Ej. Departamento de Computacion" required>
                        </div>
                    </div>
                    <div class="field">
                        <label class="field__label" for="txtDepCodigo">Codigo</label>
                        <div class="input">
                            <input id="txtDepCodigo" class="input__control" type="text" maxlength="20"
                                   placeholder="Ej. DC-01 (opcional)">
                        </div>
                    </div>
                    <div class="field" id="campoDepEstado" style="display: none;">
                        <label class="field__label" for="ddlDepEstado">Estado</label>
                        <div class="select">
                            <select id="ddlDepEstado" class="select__control">
                                <option value="true">Activo</option>
                                <option value="false">Inactivo</option>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="modal__actions">
                    <button class="btn btn--secondary" type="button" onclick="dep_CerrarModal()">Cancelar</button>
                    <button id="btnDepGuardar" class="btn btn--primary" type="button" onclick="dep_Guardar()">Guardar</button>
                </div>
            </form>
        </div>
    </div>
</div>
