
<%@ Control Language="C#" AutoEventWireup="true" %>

<%--
    NAIA - SECCION DE AUDITORIA

    Permite consultar y filtrar los movimientos
    registrados en la base de datos.

    Prefijo aud para evitar conflictos con
    otras secciones del panel administrativo.
--%>

<div id="seccionAuditoria"
     class="admin-section"
     style="display: none;">

    <!-- ===== ENCABEZADO ===== -->
    <div class="admin-section__header">
        <div>
            <h2 class="admin-section__title">
                Auditoría
            </h2>

            <p class="admin-section__subtitle">
                Consulta los movimientos y actividades
                registrados en el sistema Naia.
            </p>
        </div>
    </div>

    <!-- ===== FILTROS ===== -->
    <div class="admin-search">
        <div class="form__stack">

            <!-- Fecha inicial -->
            <div class="field">
                <label class="field__label"
                       for="audFechaInicio">
                    Fecha inicial
                </label>

                <div class="input">
                    <input type="date"
                           id="audFechaInicio"
                           class="input__control" />
                </div>
            </div>

            <!-- Fecha final -->
            <div class="field">
                <label class="field__label"
                       for="audFechaFin">
                    Fecha final
                </label>

                <div class="input">
                    <input type="date"
                           id="audFechaFin"
                           class="input__control" />
                </div>
            </div>

            <!-- Seccion del sistema -->
            <div class="field">
                <label class="field__label"
                       for="audSeccion">
                    Sección
                </label>

                <div class="select">
                    <select id="audSeccion"
                            class="select__control">
                        <option value="">
                            Todas las secciones
                        </option>
                    </select>
                </div>
            </div>

            <!-- Accion -->
            <div class="field">
                <label class="field__label"
                       for="audAccion">
                    Acción
                </label>

                <div class="select">
                    <select id="audAccion"
                            class="select__control">
                        <option value="">
                            Todas las acciones
                        </option>
                    </select>
                </div>
            </div>

            <!-- Usuario -->
            <div class="field">
                <label class="field__label"
                       for="audUsuario">
                    ID del usuario
                </label>

                <div class="input">
                    <input type="number"
                           id="audUsuario"
                           class="input__control"
                           min="1"
                           step="1"
                           placeholder="Ej. 15" />
                </div>
            </div>

            <!-- Busqueda por elemento o detalle -->
            <div class="field">
                <label class="field__label"
                       for="audFiltro">
                    Buscar movimiento
                </label>

                <div class="input">
                    <input type="text"
                           id="audFiltro"
                           class="input__control"
                           maxlength="100"
                           placeholder="Buscar por elemento o detalle..." />
                </div>
            </div>

            <!-- Solo movimientos fallidos -->
            <div class="field">
                <label class="radio">
                    <input type="checkbox"
                           id="audSoloFallidos" />

                    <span>
                        Mostrar solamente movimientos fallidos
                    </span>
                </label>
            </div>

            <!-- Botones -->
            <div>
                <button type="button"
                        class="btn btn--primary"
                        onclick="aud_Filtrar()">
                    Buscar
                </button>

                <button type="button"
                        class="btn btn--secondary"
                        onclick="aud_LimpiarFiltros()">
                    Limpiar filtros
                </button>
            </div>

        </div>
    </div>

    <!-- ===== TABLA DE AUDITORIA ===== -->
    <div class="admin-table-wrapper">

        <table class="admin-table"
               id="audTabla">

            <thead>
                <tr>
                    <th>Fecha y hora</th>
                    <th>Usuario</th>
                    <th>Sección</th>
                    <th>Acción</th>
                    <th>Resultado</th>
                    <th>Detalle</th>
                </tr>
            </thead>

            <tbody id="audTablaCuerpo">
                <tr>
                    <td colspan="6"
                        class="admin-table__loading">
                        Los movimientos se cargarán
                        al abrir Auditoría.
                    </td>
                </tr>
            </tbody>

        </table>

    </div>

</div>
