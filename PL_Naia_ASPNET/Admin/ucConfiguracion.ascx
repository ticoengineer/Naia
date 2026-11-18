
<%@ Control Language="C#" AutoEventWireup="true" %>

<%--
    NAIA - CONFIGURACION ADMINISTRATIVA

    Permite consultar y actualizar los datos
    de la universidad autenticada.

    Utiliza los procedimientos:
    SP_INFO_INSTITUCION
    SP_ACTUALIZA_INSTITUCIONES
    SP_LISTAR_PLANES
--%>

<div id="seccionConfiguracion"
     class="admin-section"
     style="display: none;">

    <!-- ===== ENCABEZADO ===== -->

    <div class="admin-section__header">
        <div>
            <h2 class="admin-section__title">
                Configuración
            </h2>

            <p class="admin-section__subtitle">
                Administra la información institucional
                y consulta tu plan de suscripción en Naia.
            </p>
        </div>
    </div>

    <!-- ===== INFORMACION INSTITUCIONAL ===== -->

    <div class="admin-search">

        <h3>Información de la universidad</h3>

        <div class="form__stack">

            <!-- Nombre de universidad -->
            <div class="field">
                <label class="field__label"
                       for="cfgNombre">
                    Nombre de la universidad
                    <span class="required">*</span>
                </label>

                <div class="input">
                    <input type="text"
                           id="cfgNombre"
                           class="input__control"
                           maxlength="150"
                           placeholder="Nombre de la universidad"
                           required />
                </div>
            </div>

            <!-- Siglas -->
            <div class="field">
                <label class="field__label"
                       for="cfgSiglas">
                    Siglas
                    <span class="required">*</span>
                </label>

                <div class="input">
                    <input type="text"
                           id="cfgSiglas"
                           class="input__control"
                           maxlength="10"
                           placeholder="Ej. UAM"
                           required />
                </div>
            </div>

            <!-- Dominio institucional -->
            <div class="field">
                <label class="field__label"
                       for="cfgDominio">
                    Dominio del correo institucional
                </label>

                <div class="input">
                    <input type="text"
                           id="cfgDominio"
                           class="input__control"
                           readonly />
                </div>

                <p class="field__hint">
                    El dominio institucional no puede
                    modificarse porque está asociado
                    a los correos de los usuarios.
                </p>
            </div>

        </div>
    </div>

    <!-- ===== PLAN DE SUSCRIPCION ===== -->

    <div class="admin-search">

        <h3>Plan de suscripción</h3>

        <div class="form__stack">

            <!-- Plan actual -->
            <div class="field">
                <label class="field__label"
                       for="cfgPlanActual">
                    Plan actual
                </label>

                <div class="input">
                    <input type="text"
                           id="cfgPlanActual"
                           class="input__control"
                           readonly />
                </div>
            </div>

            <!-- Seleccionar plan -->
            <div class="field">
                <label class="field__label"
                       for="cfgPlan">
                    Seleccionar plan
                </label>

                <div class="select">
                    <select id="cfgPlan"
                            class="select__control">
                        <option value="">
                            Cargando planes...
                        </option>
                    </select>
                </div>
            </div>

            <!-- Usuarios activos -->
            <div class="field">
                <label class="field__label"
                       for="cfgUsuariosActivos">
                    Usuarios activos
                </label>

                <div class="input">
                    <input type="text"
                           id="cfgUsuariosActivos"
                           class="input__control"
                           readonly />
                </div>
            </div>

            <!-- Limite de usuarios -->
            <div class="field">
                <label class="field__label"
                       for="cfgMaxUsuarios">
                    Capacidad del plan actual
                </label>

                <div class="input">
                    <input type="text"
                           id="cfgMaxUsuarios"
                           class="input__control"
                           readonly />
                </div>
            </div>

            <!-- Precio mensual -->
            <div class="field">
                <label class="field__label"
                       for="cfgPrecio">
                    Precio mensual del plan actual
                </label>

                <div class="input">
                    <input type="text"
                           id="cfgPrecio"
                           class="input__control"
                           readonly />
                </div>
            </div>

            <p class="field__hint">
                El cambio de plan estará sujeto
                a las restricciones de usuarios
                establecidas por Naia.
            </p>

        </div>
    </div>

    <!-- ===== INFORMACION GENERAL ===== -->

    <div class="admin-search">

        <h3>Información general</h3>

        <div class="form__stack">

            <div class="field">
                <label class="field__label"
                       for="cfgEstado">
                    Estado de la universidad
                </label>

                <div class="input">
                    <input type="text"
                           id="cfgEstado"
                           class="input__control"
                           readonly />
                </div>
            </div>

            <div class="field">
                <label class="field__label"
                       for="cfgFechaCreacion">
                    Fecha de registro
                </label>

                <div class="input">
                    <input type="text"
                           id="cfgFechaCreacion"
                           class="input__control"
                           readonly />
                </div>
            </div>

        </div>
    </div>

    <!-- ===== ACCIONES ===== -->

    <div class="admin-section__header">

        <div>
            <button type="button"
                    class="btn btn--primary"
                    id="cfgBtnGuardar"
                    onclick="cfg_Guardar()">
                Guardar cambios
            </button>

            <button type="button"
                    class="btn btn--secondary"
                    onclick="cfg_CargarInformacion()">
                Cancelar cambios
            </button>
        </div>

    </div>

</div>
