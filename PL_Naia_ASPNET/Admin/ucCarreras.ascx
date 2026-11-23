<%@ Control Language="C#" AutoEventWireup="true" %>

<%--
    User Control: Seccion de Carreras del panel de administracion.
    Se muestra/oculta desde Panel.js cuando el admin navega a esta seccion.
    Prefijo "car" en todos los IDs para evitar choques con otras secciones.
    Editar solo cambia el nombre; activar/desactivar se hace con los botones de la tabla.
--%>

<div id="seccionCarreras" class="admin-section">

    <!-- ====== Encabezado de la seccion ====== -->
    <div class="admin-section__header">
        <div>
            <h2 class="admin-section__title">Carreras</h2>
            <p class="admin-section__subtitle">Carreras o programas académicos. Cada estudiante y profesor pertenece a una.</p>
        </div>
        <button id="btnCarNueva" class="btn btn--primary" type="button" onclick="car_AbrirModalNuevo()">
            + Nueva carrera
        </button>
    </div>

    <!-- ====== Buscador ====== -->
    <div class="admin-search">
        <div class="input input--search">
            <img class="input__icon" src="Images/icon-tag.png" alt="" aria-hidden="true" width="16" height="16">
            <input id="txtCarBuscar" class="input__control" type="text" placeholder="Buscar por nombre..."
                   onkeyup="car_Filtrar()">
        </div>
    </div>

    <!-- ====== Tabla de carreras ====== -->
    <div class="admin-table-wrapper">
        <table class="admin-table" id="tblCarreras">
            <thead>
                <tr>
                    <th>Carrera</th>
                    <th>Usuarios activos</th>
                    <th>Estado</th>
                    <th class="admin-table__actions-col">Acciones</th>
                </tr>
            </thead>
            <tbody id="tbodyCarreras">
                <tr>
                    <td colspan="4" class="admin-table__loading">Cargando carreras...</td>
                </tr>
            </tbody>
        </table>
    </div>

    <!-- ====== Modal para crear / editar carrera ====== -->
    <div id="modalCarrera" class="modal" style="display: none;">
        <div class="modal__overlay" onclick="car_CerrarModal()"></div>
        <div class="modal__content">
            <div class="modal__header">
                <h3 id="modalCarTitulo" class="modal__title">Nueva carrera</h3>
                <button class="modal__close" type="button" onclick="car_CerrarModal()">&times;</button>
            </div>

            <form id="frmCarrera" class="form" onsubmit="return false;">
                <input type="hidden" id="hdnCarId" value="0">

                <div class="form__stack">
                    <div class="field">
                        <label class="field__label" for="txtCarNombre">Nombre <span class="required">*</span></label>
                        <div class="input">
                            <input id="txtCarNombre" class="input__control" type="text" maxlength="120"
                                   placeholder="Ej. Ingeniería en Sistemas" required>
                        </div>
                    </div>
                </div>

                <div class="modal__actions">
                    <button class="btn btn--secondary" type="button" onclick="car_CerrarModal()">Cancelar</button>
                    <button id="btnCarGuardar" class="btn btn--primary" type="button" onclick="car_Guardar()">
                        Guardar
                    </button>
                </div>
            </form>
        </div>
    </div>

</div>
