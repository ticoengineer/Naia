<%@ Control Language="C#" AutoEventWireup="true" %>

<%--
    User Control: Sección de Categorías del panel de administración.
    Se muestra/oculta desde Panel.js cuando el admin navega a esta sección.
    Prefijo "cat" en todos los IDs para evitar choques con otras secciones.
--%>

<div id="seccionCategorias" class="admin-section" style="display: none;">

    <!-- ====== Encabezado de la seccion ====== -->
    <div class="admin-section__header">
        <div>
            <h2 class="admin-section__title">Categorías</h2>
            <p class="admin-section__subtitle">Organiza los tipos de tiquetes que pueden crear los usuarios.</p>
        </div>
        <button id="btnCatNueva" class="btn btn--primary" type="button" onclick="cat_AbrirModalNuevo()">
            + Nueva categoría
        </button>
    </div>

    <!-- ====== Buscador ====== -->
    <div class="admin-search">
        <div class="input input--search">
            <img class="input__icon" src="Admin/Images/icon-search.png" alt="" aria-hidden="true" width="16" height="16">
            <input id="txtCatBuscar" class="input__control" type="text" placeholder="Buscar por nombre, descripción o equipo..."
                   onkeyup="cat_Filtrar()">
        </div>
    </div>

    <!-- ====== Tabla de categorias ====== -->
    <div class="admin-table-wrapper">
        <table class="admin-table" id="tblCategorias">
            <thead>
                <tr>
                    <th>Color</th>
                    <th>Categoría</th>
                    <th>Prioridad inicial</th>
                    <th>Equipo predeterminado</th>
                    <th>Ubic. física</th>
                    <th>Estado</th>
                    <th class="admin-table__actions-col">Acciones</th>
                </tr>
            </thead>
            <tbody id="tbodyCategorias">
                <!-- Se llena desde Categorias.js con ListarCategorias() -->
                <tr>
                    <td colspan="7" class="admin-table__loading">Cargando categorías...</td>
                </tr>
            </tbody>
        </table>
    </div>

    <!-- ====== Modal para crear / editar categoria ====== -->
    <div id="modalCategoria" class="modal" style="display: none;">
        <div class="modal__overlay" onclick="cat_CerrarModal()"></div>
        <div class="modal__content modal__content--wide">
            <div class="modal__header">
                <h3 id="modalCatTitulo" class="modal__title">Nueva categoría</h3>
                <button class="modal__close" type="button" onclick="cat_CerrarModal()">&times;</button>
            </div>

            <form id="frmCategoria" class="form" onsubmit="return false;">
                <!-- Campo oculto: guarda el CategoriaId cuando es edicion -->
                <input type="hidden" id="hdnCatId" value="0">

                <div class="form__stack">
                    <!-- Nombre de la categoria -->
                    <div class="field">
                        <label class="field__label" for="txtCatNombre">Nombre <span class="required">*</span></label>
                        <div class="input">
                            <input id="txtCatNombre" class="input__control" type="text" maxlength="80"
                                   placeholder="Ej. Problema de red" required>
                        </div>
                    </div>

                    <!-- Descripcion (opcional) -->
                    <div class="field">
                        <label class="field__label" for="txtCatDescripcion">Descripción</label>
                        <div class="input">
                            <textarea id="txtCatDescripcion" class="input__control input__control--textarea" maxlength="250"
                                      placeholder="Breve descripción de qué tiquetes van en esta categoría..." rows="3"></textarea>
                        </div>
                    </div>

                    <div class="form__grid">
                        <!-- Color de la categoria -->
                        <div class="field">
                            <label class="field__label" for="txtCatColor">Color <span class="required">*</span></label>
                            <div class="input input--color">
                                <input id="txtCatColor" class="input__control input__control--color" type="color" value="#3C4F76">
                                <span id="lblCatColorHex" class="input__suffix">#3C4F76</span>
                            </div>
                            <p class="field__hint">Este color identifica la categoría en la vista de tiquetes.</p>
                        </div>

                        <!-- Prioridad inicial -->
                        <div class="field">
                            <label class="field__label" for="ddlCatPrioridad">Prioridad inicial <span class="required">*</span></label>
                            <div class="select">
                                <select id="ddlCatPrioridad" class="select__control" required>
                                    <option value="">Selecciona...</option>
                                    <!-- Se llena desde Categorias.js con CargarPrioridades() -->
                                </select>
                            </div>
                            <p class="field__hint">Prioridad que se asigna automáticamente al crear un tiquete de esta categoría.</p>
                        </div>
                    </div>

                    <div class="form__grid">
                        <!-- Equipo predeterminado (opcional) -->
                        <div class="field">
                            <label class="field__label" for="ddlCatEquipo">Equipo predeterminado</label>
                            <div class="select">
                                <select id="ddlCatEquipo" class="select__control">
                                    <option value="">Sin asignar</option>
                                    <!-- Se llena desde Categorias.js con CargarEquipos() -->
                                </select>
                            </div>
                            <p class="field__hint">Equipo que se asigna por defecto. Puede dejarse vacío.</p>
                        </div>

                        <!-- Requiere ubicacion fisica -->
                        <div class="field">
                            <label class="field__label">¿Requiere ubicación física?</label>
                            <div class="radio-group">
                                <label class="radio">
                                    <input type="radio" name="rdbCatUbiFisica" id="rdbCatUbiFisicaSi" value="true">
                                    <span class="radio__mark"></span>
                                    Sí
                                </label>
                                <label class="radio">
                                    <input type="radio" name="rdbCatUbiFisica" id="rdbCatUbiFisicaNo" value="false" checked>
                                    <span class="radio__mark"></span>
                                    No
                                </label>
                            </div>
                            <p class="field__hint">Si es Sí, al crear tiquetes de esta categoría solo se podrán elegir ubicaciones físicas.</p>
                        </div>
                    </div>

                    <!-- Estado (solo visible cuando es edicion) -->
                    <div class="field" id="campoCatEstado" style="display: none;">
                        <label class="field__label" for="ddlCatEstado">Estado</label>
                        <div class="select">
                            <select id="ddlCatEstado" class="select__control">
                                <option value="true">Activa</option>
                                <option value="false">Inactiva</option>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="modal__actions">
                    <button class="btn btn--secondary" type="button" onclick="cat_CerrarModal()">Cancelar</button>
                    <button id="btnCatGuardar" class="btn btn--primary" type="button" onclick="cat_Guardar()">
                        Guardar
                    </button>
                </div>
            </form>
        </div>
    </div>

</div>
