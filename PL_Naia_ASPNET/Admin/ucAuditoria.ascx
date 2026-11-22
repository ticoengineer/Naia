<%@ Control Language="C#" AutoEventWireup="true" %>

<!-- ========== SECCIÓN AUDITORÍA ========== -->
<div id="seccion_auditoria">
    <h2>Auditoría</h2>

    <!-- FILTROS -->
    <div class="filtros-auditoria" style="display:flex; flex-wrap:wrap; gap:10px; margin-bottom:15px; align-items:flex-end;">
        <div style="display:flex; flex-direction:column;">
            <label for="aud_fechaInicio">Desde</label>
            <input type="date" id="aud_fechaInicio" class="form-control" style="width:160px;" />
        </div>
        <div style="display:flex; flex-direction:column;">
            <label for="aud_fechaFin">Hasta</label>
            <input type="date" id="aud_fechaFin" class="form-control" style="width:160px;" />
        </div>

        <!-- value = Auditoria.SeccionSistema (exactamente como lo guarda la BD, con tildes) -->
        <div style="display:flex; flex-direction:column;">
            <label for="aud_seccion">Sección</label>
            <select id="aud_seccion" class="form-control" style="width:160px;">
                <option value="">-- Todas --</option>
                <option value="Tiquetes">Tiquetes</option>
                <option value="Usuarios">Usuarios</option>
                <option value="Catálogos">Catálogos</option>
                <option value="Configuración">Configuración</option>
                <option value="Seguridad">Seguridad</option>
            </select>
        </div>

        <!-- value = Auditoria.Accion (exactamente como lo guarda la BD) -->
        <div style="display:flex; flex-direction:column;">
            <label for="aud_accion">Acción</label>
            <select id="aud_accion" class="form-control" style="width:160px;">
                <option value="">-- Todas --</option>
                <option value="Crear">Crear</option>
                <option value="Actualizar">Actualizar</option>
                <option value="Desactivar">Desactivar</option>
                <option value="Asignar">Asignar</option>
                <option value="CambiarEstado">Cambio de estado</option>
                <option value="InicioSesion">Inicio de sesión</option>
                <option value="CierreSesion">Cierre de sesión</option>
            </select>
        </div>

        <div style="display:flex; flex-direction:column;">
            <label for="aud_resultado">Resultado</label>
            <select id="aud_resultado" class="form-control" style="width:130px;">
                <option value="-1">-- Todos --</option>
                <option value="1">Exitoso</option>
                <option value="0">Fallido</option>
            </select>
        </div>
        <div style="display:flex; flex-direction:column;">
            <label for="aud_txtBuscar">Buscar</label>
            <input type="text" id="aud_txtBuscar" class="form-control" placeholder="Buscar..." style="width:180px;" />
        </div>
        <div>
            <button type="button" class="btn btn-primary" onclick="Auditoria_Filtrar()">
                <i class="fas fa-search"></i> Filtrar
            </button>
            <button type="button" class="btn btn-secondary" onclick="Auditoria_LimpiarFiltros()">
                <i class="fas fa-eraser"></i> Limpiar
            </button>
        </div>
    </div>

    <!-- TABLA -->
    <div class="table-responsive">
        <table class="table table-striped table-hover" id="tbl_auditoria">
            <thead>
                <tr>
                    <th>Fecha/Hora</th>
                    <th>Usuario</th>
                    <th>Acción</th>
                    <th>Sección</th>
                    <th>Elemento</th>
                    <th>Detalle</th>
                    <th>Resultado</th>
                    <th>IP</th>
                </tr>
            </thead>
            <tbody id="aud_tbody">
                <tr>
                    <td colspan="8" class="text-center">Cargando...</td>
                </tr>
            </tbody>
        </table>
    </div>
</div>