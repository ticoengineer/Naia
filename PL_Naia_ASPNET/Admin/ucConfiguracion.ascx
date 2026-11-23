<%@ Control Language="C#" AutoEventWireup="true" %>

<!-- ========== SECCION CONFIGURACION ========== -->
<div id="seccion_configuracion">
    <h2>Configuracion</h2>

    <!-- INFO INSTITUCION (solo lectura) -->
    <div class="card mb-3">
        <div class="card-header">
            <h5>Informacion de la Institucion</h5>
        </div>
        <div class="card-body">
            <div class="row">
                <div class="col-md-6">
                    <div class="form-group">
                        <label>Nombre de la Institucion</label>
                        <input type="text" id="cfg_nombre" class="form-control" maxlength="100" />
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="form-group">
                        <label>Siglas</label>
                        <input type="text" id="cfg_siglas" class="form-control" maxlength="10" />
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="form-group">
                        <label>Plan</label>
                        <select id="cfg_plan" class="form-control">
                            <option value="">Cargando...</option>
                        </select>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-4">
                    <div class="form-group">
                        <label>Dominio de Correo</label>
                        <input type="text" id="cfg_dominio" class="form-control" disabled />
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="form-group">
                        <label>Usuarios Activos / Max</label>
                        <input type="text" id="cfg_usuarios" class="form-control" disabled />
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="form-group">
                        <label>Fecha de Creacion</label>
                        <input type="text" id="cfg_fechaCreacion" class="form-control" disabled />
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12 text-right" style="margin-top:10px;">
                    <button type="button" class="btn btn-success" onclick="Configuracion_Guardar()">
                        <i class="fas fa-save"></i> Guardar Cambios
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- INFO PLAN ACTUAL (solo lectura) -->
    <div class="card">
        <div class="card-header">
            <h5>Detalle del Plan</h5>
        </div>
        <div class="card-body">
            <div class="row">
                <div class="col-md-4">
                    <div class="form-group">
                        <label>Plan Actual</label>
                        <input type="text" id="cfg_planNombre" class="form-control" disabled />
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="form-group">
                        <label>Max Usuarios</label>
                        <input type="text" id="cfg_planMaxUsuarios" class="form-control" disabled />
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="form-group">
                        <label>Precio Mensual</label>
                        <input type="text" id="cfg_planPrecio" class="form-control" disabled />
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
