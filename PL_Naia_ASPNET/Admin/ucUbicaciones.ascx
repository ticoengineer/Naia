<%@ Control Language="C#" AutoEventWireup="true" %>

<%--
    User Control: Sección de Ubicaciones del panel de administración.
    Se muestra/oculta desde Panel.js cuando el admin navega a esta sección.
    Prefijo "ubi" en todos los IDs para evitar choques con otras secciones.
--%>

<div id="seccionUbicaciones" class="admin-section" style="display: none;">

    <!-- ====== Encabezado de la seccion ====== -->
    <div class="admin-section__header">
        <div>
            <h2 class="admin-section__title">Ubicaciones</h2>
            <p class="admin-section__subtitle">Administra los lugares donde se generan tiquetes de soporte.</p>
        </div>
        <button id="btnUbiNueva" class="btn btn--primary" type="button" onclick="ubi_AbrirModalNuevo()">
            + Nueva ubicación
        </button>
    </div>

    <!-- ====== Buscador ====== -->
    <div class="admin-search">
        <div class="input input--search">
            <img class="input__icon" src="Admin/Images/icon-search.png" alt="" aria-hidden="true" width="16" height="16">
            <input id="txtUbiBuscar" class="input__control" type="text" placeholder="Buscar por nombre, edificio o tipo..."
                   onkeyup="ubi_Filtrar()">
        </div>
    </div>

    <!-- ====== Tabla de ubicaciones ====== -->
    <div class="admin-table-wrapper">
        <table class="admin-table" id="tblUbicaciones">
            <thead>
                <tr>
                    <th>Nombre</th>
                    <th>Edificio</th>
                    <th>Tipo</th>
                    <th>Estado</th>
                    <th class="admin-table__actions-col">Acciones</th>
                </tr>
            </thead>
            <tbody id="tbodyUbicaciones">
                <!-- Se llena desde Ubicaciones.js con ListarUbicaciones() -->
                <tr>
                    <td colspan="5" class="admin-table__loading">Cargando ubicaciones...</td>
                </tr>
            </tbody>
        </table>
    </div>

    <!-- ====== Modal para crear / editar ubicacion ====== -->
    <div id="modalUbicacion" class="modal" style="display: none;">
        <div class="modal__overlay" onclick="ubi_CerrarModal()"></div>
        <div class="modal__content">
            <div class="modal__header">
                <h3 id="modalUbiTitulo" class="modal__title">Nueva ubicación</h3>
                <button class="modal__close" type="button" onclick="ubi_CerrarModal()">&times;</button>
            </div>

            <form id="frmUbicacion" class="form" onsubmit="return false;">
                <!-- Campo oculto: guarda el ID cuando es edicion (0 si es nuevo) -->
                <input type="hidden" id="hdnUbiId" value="0">

                <div class="form__stack">
                    <!-- Nombre de la ubicacion -->
                    <div class="field">
                        <label class="field__label" for="txtUbiNombre">Nombre <span class="required">*</span></label>
                        <div class="input">
                            <input id="txtUbiNombre" class="input__control" type="text" maxlength="80"
                                   placeholder="Ej. Laboratorio de Cómputo 1" required>
                        </div>
                    </div>

                    <!-- Tipo: Física o Virtual -->
                    <div class="field">
                        <label class="field__label">Tipo de ubicación <span class="required">*</span></label>
                        <div class="radio-group">
                            <label class="radio">
                                <input type="radio" name="rdbUbiTipo" id="rdbUbiFisica" value="true" checked
                                       onchange="ubi_CambiarTipo()">
                                <span class="radio__mark"></span>
                                Física
                            </label>
                            <label class="radio">
                                <input type="radio" name="rdbUbiTipo" id="rdbUbiVirtual" value="false"
                                       onchange="ubi_CambiarTipo()">
                                <span class="radio__mark"></span>
                                Virtual
                            </label>
                        </div>
                        <p class="field__hint">Las ubicaciones físicas necesitan un edificio asignado.</p>
                    </div>

                    <!-- Edificio (solo visible cuando es fisica) -->
                    <div class="field" id="campoUbiEdificio">
                        <label class="field__label" for="txtUbiEdificio">Edificio <span class="required">*</span></label>
                        <div class="input">
                            <input id="txtUbiEdificio" class="input__control" type="text" maxlength="80"
                                   placeholder="Ej. Edificio de Ingeniería">
                        </div>
                    </div>

                    <!-- Estado (solo visible cuando es edicion) -->
                    <div class="field" id="campoUbiEstado" style="display: none;">
                        <label class="field__label" for="ddlUbiEstado">Estado</label>
                        <div class="select">
                            <select id="ddlUbiEstado" class="select__control">
                                <option value="true">Activa</option>
                                <option value="false">Inactiva</option>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="modal__actions">
                    <button class="btn btn--secondary" type="button" onclick="ubi_CerrarModal()">Cancelar</button>
                    <button id="btnUbiGuardar" class="btn btn--primary" type="button" onclick="ubi_Guardar()">
                        Guardar
                    </button>
                </div>
            </form>
        </div>
    </div>

</div>
