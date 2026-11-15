<%@ Control Language="C#" AutoEventWireup="true" %>

<!-- ========== SECCION RESUMEN ========== -->
<div id="seccion_resumen">
    <h2>Resumen</h2>

    <!-- TARJETAS DE RESUMEN -->
    <div class="row" id="res_tarjetas" style="margin-bottom:20px;">
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="card text-center" style="border-left:4px solid #007bff;">
                <div class="card-body">
                    <h6 class="text-muted">Usuarios Activos</h6>
                    <h3 id="res_totalUsuarios" class="text-primary">-</h3>
                </div>
            </div>
        </div>
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="card text-center" style="border-left:4px solid #28a745;">
                <div class="card-body">
                    <h6 class="text-muted">Equipos</h6>
                    <h3 id="res_totalEquipos" class="text-success">-</h3>
                </div>
            </div>
        </div>
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="card text-center" style="border-left:4px solid #ffc107;">
                <div class="card-body">
                    <h6 class="text-muted">Carreras</h6>
                    <h3 id="res_totalCarreras" class="text-warning">-</h3>
                </div>
            </div>
        </div>
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="card text-center" style="border-left:4px solid #17a2b8;">
                <div class="card-body">
                    <h6 class="text-muted">Departamentos</h6>
                    <h3 id="res_totalDepartamentos" class="text-info">-</h3>
                </div>
            </div>
        </div>
    </div>

    <div class="row" style="margin-bottom:20px;">
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="card text-center" style="border-left:4px solid #6f42c1;">
                <div class="card-body">
                    <h6 class="text-muted">Ubicaciones</h6>
                    <h3 id="res_totalUbicaciones" style="color:#6f42c1;">-</h3>
                </div>
            </div>
        </div>
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="card text-center" style="border-left:4px solid #fd7e14;">
                <div class="card-body">
                    <h6 class="text-muted">Categorias</h6>
                    <h3 id="res_totalCategorias" style="color:#fd7e14;">-</h3>
                </div>
            </div>
        </div>
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="card text-center" style="border-left:4px solid #6c757d;">
                <div class="card-body">
                    <h6 class="text-muted">Plan Actual</h6>
                    <h4 id="res_planActual" class="text-secondary">-</h4>
                </div>
            </div>
        </div>
        <div class="col-md-3 col-sm-6 mb-3">
            <div class="card text-center" style="border-left:4px solid #20c997;">
                <div class="card-body">
                    <h6 class="text-muted">Institucion</h6>
                    <h4 id="res_institucion" style="color:#20c997;">-</h4>
                </div>
            </div>
        </div>
    </div>

    <!-- ACTIVIDAD RECIENTE -->
    <div class="card">
        <div class="card-header">
            <h5>Actividad Reciente</h5>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-sm table-striped" id="tbl_resumen_actividad">
                    <thead>
                        <tr>
                            <th>Fecha/Hora</th>
                            <th>Usuario</th>
                            <th>Accion</th>
                            <th>Seccion</th>
                            <th>Resultado</th>
                        </tr>
                    </thead>
                    <tbody id="res_tbody_actividad">
                        <tr>
                            <td colspan="5" class="text-center">Cargando...</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
