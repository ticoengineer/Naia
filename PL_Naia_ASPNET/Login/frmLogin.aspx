<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="frmLogin.aspx.cs" Inherits="PL_Naia_ASPNET.Login.frmLogin" ClientIDMode="Static" %>

<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Iniciar sesión · Naia</title>

    <!-- Rutas relativas a /Login/ (donde vive esta página) -->
    <link rel="icon" type="image/png" href="Images/favicon.png">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="CSS/naia.css">
</head>
<body>

    <main class="auth">

        <!-- ===================== Panel izquierdo: marca ===================== -->
        <section class="auth-hero" aria-label="Presentación de Naia">

            <img class="auth-hero__deco" src="Images/naia-icon.png" alt="" aria-hidden="true">

            <a class="brand brand--light" href="#" aria-label="Naia, inicio">
                <img class="brand__logo" src="Images/naia-icon.png" alt="">
                <span class="brand__name">Naia</span>
            </a>

            <!-- Ilustración decorativa: el ciclo de una solicitud -->
            <div class="ticket-preview" aria-hidden="true">
                <div class="ticket-preview__top">
                    <span class="ticket-preview__icon">
                        <img src="Images/icon-ticket.png" alt="" aria-hidden="true" width="20" height="20">
                    </span>
                    <div class="ticket-preview__lines">
                        <span class="ticket-preview__line ticket-preview__line--long"></span>
                        <span class="ticket-preview__line"></span>
                    </div>
                </div>
                <!-- Flujo principal del tiquete (se anima una sola vez al cargar) -->
                <ol class="flow-preview">
                    <li class="flow-preview__step"><span class="flow-preview__dot"></span>Nuevo</li>
                    <li class="flow-preview__step"><span class="flow-preview__dot"></span>Asignado</li>
                    <li class="flow-preview__step"><span class="flow-preview__dot"></span>En progreso</li>
                    <li class="flow-preview__step"><span class="flow-preview__dot"></span>Resuelto</li>
                    <li class="flow-preview__step"><span class="flow-preview__dot"></span>Cerrado</li>
                </ol>

                <!-- Estados alternos -->
                <div class="flow-preview__extra">
                    <span class="state-chip state-chip--wait">En espera</span>
                    <span class="state-chip state-chip--cancel">Cancelado</span>
                </div>
            </div>

            <div class="auth-hero__content">
                <h1 class="auth-hero__title">
                    Tu soporte técnico,<br>
                    <em>en un solo lugar.</em>
                </h1>
                <p class="auth-hero__lead">
                    Reporta problemas de equipos, red, laboratorios o sistemas académicos
                    y sigue cada solicitud hasta que esté resuelta.
                </p>

                <ul class="feature-list">
                    <li class="feature-list__item">
                        <span class="feature-list__icon">
                            <img src="Images/icon-tag.png" alt="" aria-hidden="true" width="18" height="18">
                        </span>
                        Un número único para cada reporte
                    </li>
                    <li class="feature-list__item">
                        <span class="feature-list__icon">
                            <img src="Images/icon-activity.png" alt="" aria-hidden="true" width="18" height="18">
                        </span>
                        Estado y solución visibles en tiempo real
                    </li>
                    <li class="feature-list__item">
                        <span class="feature-list__icon">
                            <img src="Images/icon-shield.png" alt="" aria-hidden="true" width="18" height="18">
                        </span>
                        Acceso seguro según tu rol
                    </li>
                </ul>
            </div>

            <footer class="auth-hero__footer">
                <span>© 2026 Naia Inc.</span>
                <span><a href="#">Privacidad</a> · <a href="#">Términos</a></span>
            </footer>
        </section>

        <!-- ===================== Panel derecho: formulario ===================== -->
        <section class="auth-panel">

            <p class="auth-panel__switch">
                ¿Tu universidad aún no usa Naia? <a href="../RegistroInstitucion/frmRegistroInstitucion.aspx">Regístrala</a>
            </p>

            <div class="auth-card">

                <!-- Logo visible solo en pantallas pequeñas -->
                <a class="brand brand--mobile" href="#" aria-label="Naia, inicio">
                    <img class="brand__logo" src="Images/naia-icon.png" alt="">
                    <span class="brand__name">Naia</span>
                </a>

                <h2 class="auth-card__title">Iniciar sesión</h2>
                <p class="auth-card__subtitle">Ingresa con tu correo institucional para continuar.</p>

                <form id="frmLogin" class="form" runat="server">

                    <div class="field">
                        <label class="field__label" for="txtCorreo">Correo institucional</label>
                        <div class="input">
                            <img class="input__icon" src="Images/icon-mail.png" alt="" aria-hidden="true" width="18" height="18">
                            <asp:TextBox ID="txtCorreo" runat="server" CssClass="input__control" TextMode="Email"
                                placeholder="nombre@universidad.ac.cr" autocomplete="username" required="required" />
                        </div>
                    </div>

                    <div class="field">
                        <label class="field__label" for="txtContrasena">Contraseña</label>
                        <div class="input">
                            <img class="input__icon" src="Images/icon-lock.png" alt="" aria-hidden="true" width="18" height="18">
                            <asp:TextBox ID="txtContrasena" runat="server" CssClass="input__control" TextMode="Password"
                                placeholder="Ingresa tu contraseña" autocomplete="current-password" required="required" />
                            <button class="input__action" type="button" aria-label="Mostrar contraseña">
                                <img src="Images/icon-eye.png" alt="" aria-hidden="true" width="18" height="18">
                            </button>
                        </div>
                    </div>

                    <div class="form__row">
                        <label class="checkbox">
                            <input type="checkbox" id="chkRecordarme" runat="server">
                            <span class="checkbox__box" aria-hidden="true"></span>
                            Recordarme
                        </label>
                        <a class="link" href="#">¿Olvidaste tu contraseña?</a>
                    </div>

                    <!-- Botón de servidor: luego se le agrega OnServerClick="btnIngresar_Click" -->
                    <button id="btnIngresar" class="btn btn--primary btn--block" type="submit" runat="server">
                        Ingresar
                        <img src="Images/icon-arrow.png" alt="" aria-hidden="true" width="18" height="18">
                    </button>
                </form>

                <p class="auth-card__note">
                    <img src="Images/icon-lock.png" alt="" aria-hidden="true" width="14" height="14">
                    Tu cuenta la crea el administrador de tu universidad
                </p>
            </div>

            <p class="auth-panel__footer-mobile">¿Tu universidad aún no usa Naia? <a class="link" href="../RegistroInstitucion/frmRegistroInstitucion.aspx">Regístrala</a><br>© 2026 Naia Inc.</p>
        </section>

    </main>

</body>
</html>
