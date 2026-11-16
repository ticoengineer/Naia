<%@ Control Language="C#" AutoEventWireup="true" %>

<!-- ==================== USUARIOS ==================== -->
<div class="seccion-contenido">
    <div class="seccion-header">
        <h2>Usuarios</h2>
        <button type="button" class="btn btn-primary btn-agregar" onclick="Usuarios_AbrirModalNuevo()">
            <i class="fa fa-plus"></i> Nuevo Usuario
        </button>
    </div>

    <!-- Barra de b&#250;squeda -->
    <div class="seccion-filtro">
        <input type="text" id="usr_txtFiltro" class="form-control" placeholder="Buscar por nombre, correo, identificaci&#243;n..." onkeyup="Usuarios_Filtrar()" />
    </div>

    <!-- Tabla de usuarios -->
    <div class="tabla-responsive">
        <table class="tabla-datos" id="usr_tblUsuarios">
            <thead>
                <tr>
                    <th>Nombre</th>
                    <th>Correo</th>
                    <th>Rol</th>
                    <th>Carrera / Departamento</th>
                    <th>N&#250;mero interno</th>
                    <th>Estado</th>
                    <th>Acciones</th>
                </tr>
            </thead>
            <tbody id="usr_tbodyUsuarios">
                <tr>
                    <td colspan="7" class="text-center">Cargando...</td>
                </tr>
            </tbody>
        </table>
    </div>
</div>

<!-- Modal Usuario -->
<div class="modal-overlay" id="usr_modal" style="display:none;">
    <div class="modal-contenido modal-grande">
        <div class="modal-header">
            <h3 id="usr_modalTitulo">Nuevo Usuario</h3>
            <button type="button" class="modal-cerrar" onclick="Usuarios_CerrarModal()">&times;</button>
        </div>
        <div class="modal-body">
            <input type="hidden" id="usr_hdnUsuarioId" value="0" />

            <div class="form-fila">
                <div class="form-grupo">
                    <label for="usr_txtNombre">Nombre <span class="requerido">*</span></label>
                    <input type="text" id="usr_txtNombre" class="form-control" maxlength="60" />
                </div>
                <div class="form-grupo">
                    <label for="usr_txtApellidos">Apellidos <span class="requerido">*</span></label>
                    <input type="text" id="usr_txtApellidos" class="form-control" maxlength="80" />
                </div>
            </div>

            <div class="form-fila">
                <div class="form-grupo">
                    <label for="usr_ddlRol">Rol <span class="requerido">*</span></label>
                    <select id="usr_ddlRol" class="form-control" onchange="Usuarios_CambioRol()">
                        <option value="">-- Seleccione --</option>
                    </select>
                </div>
                <div class="form-grupo">
                    <label for="usr_txtCorreo">Correo <span class="requerido">*</span></label>
                    <input type="email" id="usr_txtCorreo" class="form-control" maxlength="150" />
                </div>
            </div>

            <div class="form-fila">
                <div class="form-grupo">
                    <label for="usr_ddlTipoId">Tipo identificaci&#243;n <span class="requerido">*</span></label>
                    <select id="usr_ddlTipoId" class="form-control">
                        <option value="">-- Seleccione --</option>
                    </select>
                </div>
                <div class="form-grupo">
                    <label for="usr_txtIdentificacion">Identificaci&#243;n <span class="requerido">*</span></label>
                    <input type="text" id="usr_txtIdentificacion" class="form-control" maxlength="30" />
                </div>
            </div>

            <div class="form-fila">
                <div class="form-grupo">
                    <label for="usr_txtNumeroInterno" id="usr_lblNumeroInterno">Carn&#233; / N&#250;mero empleado <span class="requerido">*</span></label>
                    <input type="text" id="usr_txtNumeroInterno" class="form-control" maxlength="30" />
                </div>
                <div class="form-grupo" id="usr_grupoContrasena">
                    <label for="usr_txtContrasena" id="usr_lblContrasena">Contrase&#241;a <span class="requerido">*</span></label>
                    <input type="password" id="usr_txtContrasena" class="form-control" maxlength="256" />
                </div>
            </div>

            <!-- Campos condicionales segun rol -->
            <div class="form-fila" id="usr_filaCarrera" style="display:none;">
                <div class="form-grupo">
                    <label for="usr_ddlCarrera">Carrera <span class="requerido">*</span></label>
                    <select id="usr_ddlCarrera" class="form-control">
                        <option value="">-- Seleccione --</option>
                    </select>
                </div>
            </div>

            <div class="form-fila" id="usr_filaDepartamento" style="display:none;">
                <div class="form-grupo">
                    <label for="usr_ddlDepartamento">Departamento <span class="requerido">*</span></label>
                    <select id="usr_ddlDepartamento" class="form-control">
                        <option value="">-- Seleccione --</option>
                    </select>
                </div>
                <div class="form-grupo" id="usr_grupoEquipo" style="display:none;">
                    <label for="usr_ddlEquipo">Equipo de soporte</label>
                    <select id="usr_ddlEquipo" class="form-control">
                        <option value="">-- Ninguno --</option>
                    </select>
                </div>
            </div>

            <div class="form-fila" id="usr_filaEstado" style="display:none;">
                <div class="form-grupo">
                    <label for="usr_ddlEstado">Estado</label>
                    <select id="usr_ddlEstado" class="form-control">
                        <option value="true">Activo</option>
                        <option value="false">Inactivo</option>
                    </select>
                </div>
            </div>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-secondary" onclick="Usuarios_CerrarModal()">Cancelar</button>
            <button type="button" class="btn btn-primary" onclick="Usuarios_Guardar()">Guardar</button>
        </div>
    </div>
</div>

<script src="JS/Usuarios.js"></script>
