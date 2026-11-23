<%@ Control Language="C#" AutoEventWireup="true" %>

<%--
    User Control: sección Usuarios del panel del administrador (Parte A).
    Prefijo "usr" en todos los ids para no chocar con otras secciones.
    Usuarios.js lo carga el marco (frmPanelAdmin.aspx), por eso aquí no hay <script>.
--%>

<div class="admin-section">

    <!-- Encabezado -->
    <div class="admin-section__header">
        <div>
            <h2 class="admin-section__title">Usuarios</h2>
            <p class="admin-section__subtitle">Administra los usuarios de la instituci&#243;n, sus roles y su estado.</p>
        </div>
        <button type="button" class="btn btn--primary" onclick="Usuarios_AbrirModalNuevo()">
            + Nuevo usuario
        </button>
    </div>

    <!-- Buscador -->
    <div class="admin-search">
        <div class="input input--search">
            <img class="input__icon" src="Images/icon-tag.png" alt="" aria-hidden="true" width="16" height="16" />
            <input type="text" id="usr_txtFiltro" class="input__control"
                   placeholder="Buscar por nombre, correo, identificaci&#243;n o n&#250;mero interno..."
                   onkeyup="Usuarios_Filtrar()" />
        </div>
    </div>

    <!-- Tabla de usuarios -->
    <div class="admin-table-wrapper">
        <table class="admin-table" id="usr_tblUsuarios">
            <thead>
                <tr>
                    <th>Nombre</th>
                    <th>Correo</th>
                    <th>Rol</th>
                    <th>Carrera / Departamento</th>
                    <th>N&#250;mero interno</th>
                    <th>Estado</th>
                    <th class="admin-table__actions-col">Acciones</th>
                </tr>
            </thead>
            <tbody id="usr_tbodyUsuarios">
                <tr>
                    <td colspan="7" class="admin-table__loading">Cargando usuarios...</td>
                </tr>
            </tbody>
        </table>
    </div>

    <!-- Modal crear / editar usuario -->
    <div id="usr_modal" class="modal" style="display: none;">
        <div class="modal__overlay" onclick="Usuarios_CerrarModal()"></div>
        <div class="modal__content modal__content--wide">
            <div class="modal__header">
                <h3 id="usr_modalTitulo" class="modal__title">Nuevo Usuario</h3>
                <button type="button" class="modal__close" onclick="Usuarios_CerrarModal()">&times;</button>
            </div>

            <input type="hidden" id="usr_hdnUsuarioId" value="0" />

            <div class="form__stack">

                <div class="form__grid">
                    <div class="field">
                        <label class="field__label" for="usr_txtNombre">Nombre <span class="required">*</span></label>
                        <input type="text" id="usr_txtNombre" class="input__control" maxlength="60" />
                    </div>
                    <div class="field">
                        <label class="field__label" for="usr_txtApellidos">Apellidos <span class="required">*</span></label>
                        <input type="text" id="usr_txtApellidos" class="input__control" maxlength="80" />
                    </div>
                </div>

                <div class="form__grid">
                    <div class="field">
                        <label class="field__label" for="usr_ddlRol">Rol <span class="required">*</span></label>
                        <div class="select">
                            <select id="usr_ddlRol" class="select__control" onchange="Usuarios_CambioRol()">
                                <option value="">-- Seleccione --</option>
                            </select>
                        </div>
                    </div>
                    <div class="field">
                        <label class="field__label" for="usr_txtCorreo">Correo <span class="required">*</span></label>
                        <input type="email" id="usr_txtCorreo" class="input__control" maxlength="150" />
                    </div>
                </div>

                <div class="form__grid">
                    <div class="field">
                        <label class="field__label" for="usr_ddlTipoId">Tipo identificaci&#243;n <span class="required">*</span></label>
                        <div class="select">
                            <select id="usr_ddlTipoId" class="select__control">
                                <option value="">-- Seleccione --</option>
                            </select>
                        </div>
                    </div>
                    <div class="field">
                        <label class="field__label" for="usr_txtIdentificacion">Identificaci&#243;n <span class="required">*</span></label>
                        <input type="text" id="usr_txtIdentificacion" class="input__control" maxlength="30" />
                    </div>
                </div>

                <div class="form__grid">
                    <div class="field">
                        <label class="field__label" for="usr_txtNumeroInterno" id="usr_lblNumeroInterno">Carn&#233; / N&#250;mero empleado <span class="required">*</span></label>
                        <input type="text" id="usr_txtNumeroInterno" class="input__control" maxlength="30" />
                    </div>
                    <div class="field" id="usr_grupoContrasena">
                        <label class="field__label" for="usr_txtContrasena" id="usr_lblContrasena">Contrase&#241;a <span class="required">*</span></label>
                        <input type="password" id="usr_txtContrasena" class="input__control" maxlength="256" />
                    </div>
                </div>

                <%-- Campos condicionales según el rol (Usuarios_CambioRol los muestra u oculta) --%>
                <div class="form__grid" id="usr_filaCarrera" style="display: none;">
                    <div class="field">
                        <label class="field__label" for="usr_ddlCarrera">Carrera <span class="required">*</span></label>
                        <div class="select">
                            <select id="usr_ddlCarrera" class="select__control">
                                <option value="">-- Seleccione --</option>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="form__grid" id="usr_filaDepartamento" style="display: none;">
                    <div class="field">
                        <label class="field__label" for="usr_ddlDepartamento">Departamento <span class="required">*</span></label>
                        <div class="select">
                            <select id="usr_ddlDepartamento" class="select__control">
                                <option value="">-- Seleccione --</option>
                            </select>
                        </div>
                    </div>
                    <div class="field" id="usr_grupoEquipo" style="display: none;">
                        <label class="field__label" for="usr_ddlEquipo">Equipo de soporte</label>
                        <div class="select">
                            <select id="usr_ddlEquipo" class="select__control">
                                <option value="">-- Ninguno --</option>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="form__grid" id="usr_filaEstado" style="display: none;">
                    <div class="field">
                        <label class="field__label" for="usr_ddlEstado">Estado</label>
                        <div class="select">
                            <select id="usr_ddlEstado" class="select__control">
                                <option value="true">Activo</option>
                                <option value="false">Inactivo</option>
                            </select>
                        </div>
                    </div>
                </div>

            </div>

            <div class="modal__actions">
                <button type="button" class="btn btn--secondary" onclick="Usuarios_CerrarModal()">Cancelar</button>
                <button type="button" class="btn btn--primary" onclick="Usuarios_Guardar()">Guardar</button>
            </div>
        </div>
    </div>

</div>