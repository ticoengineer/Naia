<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="frmRegistroInstitucion.aspx.cs" Inherits="PL_Naia_ASPNET.RegistroInstitucion.frmRegistroInstitucion" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Registrar universidad · Naia</title>

    <!-- Rutas relativas a /RegistroInstitucion/ (donde vive esta página) -->
    <link rel="icon" type="image/png" href="Images/favicon.png">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="CSS/naia.css">
</head>
<body>

    <main class="auth auth--register">

        <!-- ===================== Panel izquierdo: marca ===================== -->
        <section class="auth-hero" aria-label="Presentación de Naia">

            <img class="auth-hero__deco" src="Images/naia-icon.png" alt="" aria-hidden="true">

            <a class="brand brand--light" href="../Login/frmLogin.aspx" aria-label="Naia, inicio">
                <img class="brand__logo" src="Images/naia-icon.png" alt="">
                <span class="brand__name">Naia</span>
            </a>

            <div class="auth-hero__content">
                <h1 class="auth-hero__title">
                    Lleva el soporte técnico<br>
                    de tu universidad<br>
                    <em>a un solo lugar.</em>
                </h1>
                <p class="auth-hero__lead">
                    Registra tu institución en minutos. Sin servidores ni instalaciones:
                    eliges tu plan y empiezas a recibir solicitudes hoy mismo.
                </p>

                <ol class="steps steps--animated">
                    <li class="steps__item">
                        <span class="steps__number">1</span>
                        <div>
                            <strong>Elige tu plan</strong>
                            <span>Según la cantidad de usuarios</span>
                        </div>
                    </li>
                    <li class="steps__item">
                        <span class="steps__number">2</span>
                        <div>
                            <strong>Datos de la universidad</strong>
                            <span>Nombre, siglas y dominio de correo</span>
                        </div>
                    </li>
                    <li class="steps__item">
                        <span class="steps__number">3</span>
                        <div>
                            <strong>Administrador principal</strong>
                            <span>La persona que configurará Naia</span>
                        </div>
                    </li>
                    <li class="steps__item">
                        <span class="steps__number">
                            <img src="Images/icon-check.png" alt="" aria-hidden="true" width="14" height="14">
                        </span>
                        <div>
                            <strong>¡Listo!</strong>
                            <span>Inicia sesión, configura y crea a tus usuarios</span>
                        </div>
                    </li>
                </ol>
            </div>

            <footer class="auth-hero__footer">
                <span>© 2026 Naia Inc.</span>
                <span><a href="#">Privacidad</a> · <a href="#">Términos</a></span>
            </footer>
        </section>

        <!-- ===================== Panel derecho: formulario ===================== -->
        <section class="auth-panel auth-panel--scroll">

            <p class="auth-panel__switch">
                ¿Tu universidad ya usa Naia? <a href="../Login/frmLogin.aspx">Iniciar sesión</a>
            </p>

            <div class="auth-card auth-card--wide">

                <a class="brand brand--mobile" href="../Login/frmLogin.aspx" aria-label="Naia, inicio">
                    <img class="brand__logo" src="Images/naia-icon.png" alt="">
                    <span class="brand__name">Naia</span>
                </a>

                <h2 class="auth-card__title">Registrar universidad</h2>
                <p class="auth-card__subtitle">Los campos marcados con <span class="required">*</span> son obligatorios.</p>

                <!--
                    Este formulario ejecuta dbo.sp_Institucion_Registrar, que en una sola transacción:
                      1. Crea la Institucion
                      2. Crea el Departamento "Administración General"
                      3. Crea las 3 Ubicaciones virtuales
                      4. Crea el Usuario administrador (RolId = 4)
                -->
                <form id="frmRegistroInstitucion" class="form" runat="server" enctype="multipart/form-data">

                    <!-- ===================== 1. PLAN ===================== -->
                    <fieldset class="form__section">
                        <legend class="form__heading">
                            <span class="form__heading-number">1</span>
                            Elige tu plan
                        </legend>

                        <!-- @PlanId → tabla PlanSuscripcion -->
                        <div class="plan-options">
                            <input type="radio" name="PlanId" id="rbPlan1" value="1" runat="server">
                            <label class="plan-card" for="rbPlan1">
                                <span class="plan-card__name">Básico</span>
                                <span class="plan-card__price">$149<small>/mes</small></span>
                                <span class="plan-card__detail">Hasta 500 usuarios</span>
                            </label>

                            <input type="radio" name="PlanId" id="rbPlan2" value="2" runat="server" checked>
                            <label class="plan-card" for="rbPlan2">
                                <span class="plan-card__tag">Recomendado</span>
                                <span class="plan-card__name">Profesional</span>
                                <span class="plan-card__price">$399<small>/mes</small></span>
                                <span class="plan-card__detail">Hasta 3 000 usuarios</span>
                            </label>

                            <input type="radio" name="PlanId" id="rbPlan3" value="3" runat="server">
                            <label class="plan-card" for="rbPlan3">
                                <span class="plan-card__name">Institucional</span>
                                <span class="plan-card__price">$899<small>/mes</small></span>
                                <span class="plan-card__detail">Usuarios ilimitados</span>
                            </label>
                        </div>
                    </fieldset>

                    <!-- ===================== 2. UNIVERSIDAD ===================== -->
                    <fieldset class="form__section">
                        <legend class="form__heading">
                            <span class="form__heading-number">2</span>
                            Datos de la universidad
                        </legend>

                        <div class="form__stack">
                            <div class="form__grid form__grid--name">
                                <!-- @NombreInstitucion → Institucion.Nombre -->
                                <div class="field">
                                    <label class="field__label" for="txtNombreInstitucion">Nombre de la universidad <span class="required">*</span></label>
                                    <div class="input">
                                        <img class="input__icon" src="Images/icon-school.png" alt="" aria-hidden="true" width="17" height="17">
                                        <asp:TextBox ID="txtNombreInstitucion" runat="server" CssClass="input__control" MaxLength="150"
                                            placeholder="Ej. Universidad Americana" required="required" />
                                    </div>
                                </div>

                                <!-- @Siglas → Institucion.Siglas -->
                                <div class="field">
                                    <label class="field__label" for="txtSiglas">Siglas <span class="required">*</span></label>
                                    <div class="input">
                                        <asp:TextBox ID="txtSiglas" runat="server" CssClass="input__control" MaxLength="10"
                                            placeholder="Ej. UAM" required="required" />
                                    </div>
                                </div>
                            </div>

                            <!-- @DominioCorreo → Institucion.DominioCorreo (único) -->
                            <div class="field">
                                <label class="field__label" for="txtDominio">Dominio de correo institucional <span class="required">*</span></label>
                                <div class="input">
                                    <span class="input__prefix">nombre@</span>
                                    <asp:TextBox ID="txtDominio" runat="server" CssClass="input__control" MaxLength="100"
                                        placeholder="universidad.ac.cr" pattern="[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}" required="required" />
                                </div>
                                <p class="field__hint">Todos los usuarios de tu universidad iniciarán sesión con un correo de este dominio.</p>
                            </div>

                            <!-- @LogoUrl → Institucion.LogoUrl (opcional) -->
                            <div class="field">
                                <span class="field__label">Logo de la universidad <span class="field__optional">(opcional)</span></span>
                                <label class="upload" for="fuLogo">
                                    <span class="upload__icon">
                                        <img src="Images/icon-image.png" alt="" aria-hidden="true" width="18" height="18">
                                    </span>
                                    <span class="upload__text">
                                        <strong>Subir logo</strong>
                                        <span>PNG · se mostrará en el menú de Naia</span>
                                    </span>
                                    <input class="upload__control" type="file" id="fuLogo" runat="server" accept="image/png">
                                </label>
                            </div>
                        </div>
                    </fieldset>

                    <!-- ===================== 3. ADMINISTRADOR ===================== -->
                    <fieldset class="form__section">
                        <legend class="form__heading">
                            <span class="form__heading-number">3</span>
                            Administrador principal
                        </legend>
                        <p class="form__intro">
                            Esta persona tendrá el rol <strong>Administrativo</strong>: configurará los catálogos y creará
                            las cuentas de estudiantes, profesores y técnicos.
                        </p>

                        <div class="form__stack">
                            <div class="form__grid">
                                <!-- @Nombre → Usuario.Nombre -->
                                <div class="field">
                                    <label class="field__label" for="txtNombre">Nombre <span class="required">*</span></label>
                                    <div class="input">
                                        <asp:TextBox ID="txtNombre" runat="server" CssClass="input__control" MaxLength="60"
                                            placeholder="Ej. María" autocomplete="given-name" required="required" />
                                    </div>
                                </div>

                                <!-- @Apellidos → Usuario.Apellidos -->
                                <div class="field">
                                    <label class="field__label" for="txtApellidos">Apellidos <span class="required">*</span></label>
                                    <div class="input">
                                        <asp:TextBox ID="txtApellidos" runat="server" CssClass="input__control" MaxLength="80"
                                            placeholder="Ej. Solano Vargas" autocomplete="family-name" required="required" />
                                    </div>
                                </div>
                            </div>

                            <div class="form__grid form__grid--id">
                                <!-- @TipoIdentificacionId → tabla TipoIdentificacion -->
                                <div class="field">
                                    <label class="field__label" for="ddlTipoIdentificacion">Tipo de identificación <span class="required">*</span></label>
                                    <div class="select">
                                        <select class="select__control" id="ddlTipoIdentificacion" runat="server" required>
                                            <option value="" selected>Selecciona</option>
                                            <option value="1">Cédula de identidad</option>
                                            <option value="2">DIMEX</option>
                                            <option value="3">Pasaporte</option>
                                        </select>
                                        <img class="select__chevron" src="Images/icon-chevron-down.png" alt="" aria-hidden="true" width="16" height="16">
                                    </div>
                                </div>

                                <!-- @Identificacion → Usuario.Identificacion -->
                                <div class="field">
                                    <label class="field__label" for="txtIdentificacion">Número de identificación <span class="required">*</span></label>
                                    <div class="input">
                                        <img class="input__icon" src="Images/icon-id-card.png" alt="" aria-hidden="true" width="17" height="17">
                                        <asp:TextBox ID="txtIdentificacion" runat="server" CssClass="input__control" MaxLength="30"
                                            placeholder="Ej. 1-0987-0654" required="required" />
                                    </div>
                                </div>
                            </div>

                            <div class="form__grid form__grid--email">
                                <!-- @NumeroInterno → Usuario.NumeroInterno (Administrativo = N.º de empleado) -->
                                <div class="field">
                                    <label class="field__label" for="txtNumeroInterno">N.º de empleado <span class="required">*</span></label>
                                    <div class="input">
                                        <img class="input__icon" src="Images/icon-tag.png" alt="" aria-hidden="true" width="17" height="17">
                                        <asp:TextBox ID="txtNumeroInterno" runat="server" CssClass="input__control" MaxLength="30"
                                            placeholder="Ej. EMP-0001" required="required" />
                                    </div>
                                </div>

                                <!-- @Correo → Usuario.Correo
                                     Solo se escribe la parte antes de la @. El servidor arma el correo completo:
                                     Correo = txtCorreoUsuario.Text + "@" + txtDominio.Text -->
                                <div class="field">
                                    <label class="field__label" for="txtCorreoUsuario">Correo institucional <span class="required">*</span></label>
                                    <div class="input input--email-split">
                                        <img class="input__icon" src="Images/icon-mail.png" alt="" aria-hidden="true" width="17" height="17">
                                        <asp:TextBox ID="txtCorreoUsuario" runat="server" CssClass="input__control" MaxLength="60"
                                            placeholder="msolano" autocomplete="off" pattern="[A-Za-z0-9._%+\-]+"
                                            ToolTip="Solo la parte antes de la @" required="required" />
                                        <span class="input__suffix" id="sufijo-dominio" data-vacio="@dominio">@dominio</span>
                                    </div>
                                    <p class="field__hint">El dominio se completa con el que registraste arriba.</p>
                                </div>
                            </div>

                            <div class="form__grid">
                                <!-- @Contrasena → Usuario.Contrasena -->
                                <div class="field">
                                    <label class="field__label" for="txtContrasena">Contraseña <span class="required">*</span></label>
                                    <div class="input input--validate">
                                        <img class="input__icon" src="Images/icon-lock.png" alt="" aria-hidden="true" width="17" height="17">
                                        <asp:TextBox ID="txtContrasena" runat="server" CssClass="input__control" TextMode="Password"
                                            minlength="8" MaxLength="256" pattern="(?=.*[A-Z])(?=.*\d).{8,}"
                                            placeholder="Mínimo 8 caracteres" autocomplete="new-password" required="required" />
                                        <img class="input__ok" src="Images/icon-check-ok.png" alt="" aria-hidden="true" width="17" height="17">
                                    </div>
                                    <p class="field__hint">Al menos 8 caracteres, una mayúscula y un número.</p>
                                </div>

                                <!-- No se guarda: solo se compara -->
                                <div class="field">
                                    <label class="field__label" for="txtConfirmar">Confirmar contraseña <span class="required">*</span></label>
                                    <div class="input">
                                        <img class="input__icon" src="Images/icon-lock.png" alt="" aria-hidden="true" width="17" height="17">
                                        <asp:TextBox ID="txtConfirmar" runat="server" CssClass="input__control" TextMode="Password"
                                            placeholder="Repite la contraseña" autocomplete="new-password" required="required" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </fieldset>

                    <div class="note-box">
                        <img src="Images/icon-info.png" alt="" aria-hidden="true" width="16" height="16">
                        <span>
                            Al registrarte, Naia crea automáticamente el departamento <strong>Administración General</strong>
                            y las ubicaciones virtuales básicas, para que puedas empezar a trabajar de inmediato.
                        </span>
                    </div>

                    <label class="checkbox checkbox--terms">
                        <input type="checkbox" id="chkAceptaTerminos" runat="server" required>
                        <span class="checkbox__box" aria-hidden="true"></span>
                        <span>Acepto los <a class="link" href="#">términos del servicio</a> y la <a class="link" href="#">política de privacidad</a> en nombre de mi institución</span>
                    </label>

                    <div class="form__actions">
                        <a class="btn btn--secondary" href="../Login/frmLogin.aspx">Cancelar</a>
                        <!-- Botón de servidor: luego se le agrega OnServerClick="btnRegistrar_Click" -->
                        <button id="btnRegistrar" class="btn btn--primary" type="submit" runat="server">
                            Registrar universidad
                            <img src="Images/icon-arrow.png" alt="" aria-hidden="true" width="16" height="16">
                        </button>
                    </div>
                </form>
            </div>

            <p class="auth-panel__footer-mobile">© 2026 Naia Inc.</p>
        </section>

    </main>

    <!--
        Script mínimo (mejora visual): copia el dominio escrito en la sección 2 al final del
        correo del administrador. La seguridad NO depende de esto: el servidor arma el correo
        con txtDominio.
    -->
    <script>
        (function () {
            var dominio = document.getElementById('txtDominio');
            var sufijo = document.getElementById('sufijo-dominio');
            function actualizar() {
                var valor = dominio.value.trim().replace(/^@+/, '').toLowerCase();
                sufijo.textContent = valor ? '@' + valor : sufijo.dataset.vacio;
                sufijo.title = sufijo.textContent;
                sufijo.classList.toggle('is-filled', valor.length > 0);
            }
            dominio.addEventListener('input', actualizar);
            actualizar();
        })();
    </script>
</body>
</html>

