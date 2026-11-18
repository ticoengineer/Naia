
<%@ Control Language="C#" AutoEventWireup="true" %>

<%--
    NAIA - RESUMEN ADMINISTRATIVO

    Muestra indicadores de tiquetes obtenidos
    mediante SP_DASHBOARD_TICKETS.

    Los valores se cargan desde Resumen.js.
--%>

<div id="seccionResumen"
     class="admin-section"
     style="display: none;">

    <!-- Encabezado -->
    <div class="admin-section__header">
        <div>
            <h2 class="admin-section__title">
                Resumen de tiquetes
            </h2>

            <p class="admin-section__subtitle">
                Consultá el estado general de los tiquetes
                de tu universidad.
            </p>
        </div>

        <button type="button"
                class="btn btn--secondary"
                id="resBtnActualizar"
                onclick="res_CargarDashboard()">
            Actualizar
        </button>
    </div>

    <!-- Estado de carga y mensajes -->
    <p id="resMensaje" role="status" aria-live="polite">
        Seleccioná Resumen para cargar los indicadores.
    </p>

    <!-- Tarjetas de indicadores -->
    <div class="resumen-grid">

        <div class="resumen-card">
            <span class="resumen-card__nombre">Abiertos</span>
            <strong id="resAbiertos" class="resumen-card__valor">—</strong>
            <small>Tiquetes sin finalizar</small>
        </div>

        <div class="resumen-card">
            <span class="resumen-card__nombre">Nuevos</span>
            <strong id="resNuevos" class="resumen-card__valor">—</strong>
            <small>Recién registrados</small>
        </div>

        <div class="resumen-card">
            <span class="resumen-card__nombre">Asignados</span>
            <strong id="resAsignados" class="resumen-card__valor">—</strong>
            <small>Estado asignado</small>
        </div>

        <div class="resumen-card">
            <span class="resumen-card__nombre">En progreso</span>
            <strong id="resEnProgreso" class="resumen-card__valor">—</strong>
            <small>En atención</small>
        </div>

        <div class="resumen-card">
            <span class="resumen-card__nombre">En espera</span>
            <strong id="resEnEspera" class="resumen-card__valor">—</strong>
            <small>Pendientes de respuesta</small>
        </div>

        <div class="resumen-card">
            <span class="resumen-card__nombre">Resueltos</span>
            <strong id="resResueltos" class="resumen-card__valor">—</strong>
            <small>Estado resuelto</small>
        </div>

        <div class="resumen-card">
            <span class="resumen-card__nombre">Cerrados este mes</span>
            <strong id="resCerradosEsteMes"
                    class="resumen-card__valor">—</strong>
            <small>Cierres del mes actual</small>
        </div>

        <div class="resumen-card">
            <span class="resumen-card__nombre">Vencidos</span>
            <strong id="resVencidos" class="resumen-card__valor">—</strong>
            <small>Superaron el plazo SLA</small>
        </div>

        <div class="resumen-card">
            <span class="resumen-card__nombre">Asignados a mí</span>
            <strong id="resAsignadosAMi"
                    class="resumen-card__valor">—</strong>
            <small>Tiquetes bajo mi responsabilidad</small>
        </div>

    </div>

</div>
