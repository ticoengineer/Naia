<%@ Control Language="C#" AutoEventWireup="true" %>

<!-- ========== SECCION AUDITORIA ========== -->
<div id="seccion_auditoria">
    <h2>Auditoria</h2>

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
        <div style="display:flex; flex-direction:column;">
            <label for="aud_seccion">Seccion</label>
            <select id="aud_seccion" class="form-control" style="width:160px;">
                <option value="">-- Todas --</option>
                <option value="Usuarios">Usuarios</option>
                <option value="Carreras">Carreras</option>
                <option value="Departamentos">Departamentos</option>
                <option value="Equipos">Equipos</option>
                <option value="Ubicaciones">Ubicaciones</option>
                <option value="Categorias">Categorias</option>
                <option value="Configuracion">Configuracion</option>
            </select>
        </div>
        <div style="display:flex; flex-direction:column;">
            <label for="aud_accion">Accion</label>
            <select id="aud_accion" class="form-control" style="width:140px;">
                <option value="">-- Todas --</option>
                <option value="INSERT">Insertar</option>
                <option value="UPDATE">Actualizar</option>
                <option value="DELETE">Eliminar</option>
                <option value="LOGIN">Login</option>
                <option value="LOGOUT">Logout</option>
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
                    <th>Accion</th>
                    <th>Seccion</th>
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
