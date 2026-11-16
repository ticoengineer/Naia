<%@ Control Language="C#" AutoEventWireup="true" %>

<!-- ==================== EQUIPOS DE SOPORTE ==================== -->
<div class="seccion-contenido">
    <div class="seccion-header">
        <h2>Equipos de Soporte</h2>
        <button type="button" class="btn btn-primary btn-agregar" onclick="Equipos_AbrirModalNuevo()">
            <i class="fa fa-plus"></i> Nuevo Equipo
        </button>
    </div>

    <!-- Barra de búsqueda -->
    <div class="seccion-filtro">
        <input type="text" id="eqp_txtFiltro" class="form-control" placeholder="Buscar equipo..." onkeyup="Equipos_Filtrar()" />
    </div>

    <!-- Tabla de equipos -->
    <div class="tabla-responsive">
        <table class="tabla-datos" id="eqp_tblEquipos">
            <thead>
                <tr>
                    <th>Equipo</th>
                    <th>Descripci&#243;n</th>
                    <th>T&#233;cnicos activos</th>
                    <th>Estado</th>
                    <th>Acciones</th>
                </tr>
            </thead>
            <tbody id="eqp_tbodyEquipos">
                <tr>
                    <td colspan="5" class="text-center">Cargando...</td>
                </tr>
            </tbody>
        </table>
    </div>
</div>

<!-- Modal Equipo -->
<div class="modal-overlay" id="eqp_modal" style="display:none;">
    <div class="modal-contenido">
        <div class="modal-header">
            <h3 id="eqp_modalTitulo">Nuevo Equipo</h3>
            <button type="button" class="modal-cerrar" onclick="Equipos_CerrarModal()">&times;</button>
        </div>
        <div class="modal-body">
            <input type="hidden" id="eqp_hdnEquipoId" value="0" />

            <div class="form-grupo">
                <label for="eqp_txtNombre">Nombre <span class="requerido">*</span></label>
                <input type="text" id="eqp_txtNombre" class="form-control" maxlength="80" placeholder="Nombre del equipo" />
            </div>

            <div class="form-grupo">
                <label for="eqp_txtDescripcion">Descripci&#243;n</label>
                <textarea id="eqp_txtDescripcion" class="form-control" maxlength="250" rows="3" placeholder="Descripci&#243;n del equipo (opcional)"></textarea>
            </div>

            <div class="form-grupo" id="eqp_grupoEstado" style="display:none;">
                <label for="eqp_ddlEstado">Estado</label>
                <select id="eqp_ddlEstado" class="form-control">
                    <option value="true">Activo</option>
                    <option value="false">Inactivo</option>
                </select>
            </div>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-secondary" onclick="Equipos_CerrarModal()">Cancelar</button>
            <button type="button" class="btn btn-primary" id="eqp_btnGuardar" onclick="Equipos_Guardar()">Guardar</button>
        </div>
    </div>
</div>

<script src="JS/Equipos.js"></script>
