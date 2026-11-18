
using BLL_Naia_ASPNET.Entidades;
using DAL_Naia_ASPNET.Entidades;
using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.Services;
using System.Web.UI;

namespace PL_Naia_ASPNET.Login
{
    public partial class frmLogin : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        // ===================================================
        // INICIO DE SESION - NAIA
        //
        // Valida las credenciales mediante SQL Server.
        // Si son correctas, crea una sesion ASP.NET.
        //
        // Mantiene la respuesta compatible con
        // InicioSesion.js y las paginas existentes.
        // ===================================================

        [WebMethod(EnableSession = true)]
        public static string IniciarSesion(
            List<string> obj_Parametros_JS)
        {
            try
            {
                // ===========================================
                // 1. VALIDAR PARAMETROS
                // ===========================================

                if (obj_Parametros_JS == null ||
                    obj_Parametros_JS.Count < 2)
                {
                    return "-1<SPLITER>Ingresá tu correo y contraseña.";
                }

                string correo = obj_Parametros_JS[0];
                string contrasena = obj_Parametros_JS[1];

                if (string.IsNullOrWhiteSpace(correo) ||
                    string.IsNullOrEmpty(contrasena))
                {
                    return "-1<SPLITER>Ingresá tu correo y contraseña.";
                }

                // ===========================================
                // 2. OBTENER CONTEXTO DEL SERVIDOR
                // ===========================================

                HttpContext contexto = HttpContext.Current;

                if (contexto == null ||
                    contexto.Session == null)
                {
                    return "0<SPLITER>No fue posible iniciar la sesión del servidor.";
                }

                // ===========================================
                // 3. VALIDAR CREDENCIALES EN SQL SERVER
                // ===========================================

                cls_Usuarios_DAL obj_Usuarios_DAL =
                    new cls_Usuarios_DAL();

                cls_Usuarios_BLL obj_Usuarios_BLL =
                    new cls_Usuarios_BLL();

                obj_Usuarios_DAL.sCorreo =
                    correo.Trim();

                obj_Usuarios_DAL.sContrasena =
                    contrasena;

                obj_Usuarios_DAL.sDireccionIp =
                    contexto.Request.UserHostAddress;

                obj_Usuarios_BLL.Iniciar_Sesion(
                    ref obj_Usuarios_DAL);

                if (obj_Usuarios_DAL.dtDatos == null ||
                    obj_Usuarios_DAL.dtDatos.Rows.Count == 0)
                {
                    return "0<SPLITER>No se pudo consultar la base de datos.";
                }

                // ===========================================
                // 4. EVALUAR RESULTADO
                // ===========================================

                DataRow fila =
                    obj_Usuarios_DAL.dtDatos.Rows[0];

                int codigo;

                if (!int.TryParse(
                    fila["Codigo"].ToString(),
                    out codigo))
                {
                    return "0<SPLITER>Respuesta de autenticación no válida.";
                }

                if (codigo == -1)
                {
                    return "-1<SPLITER>Correo o contraseña incorrectos. Verifique.";
                }

                if (codigo == -3)
                {
                    return "-3<SPLITER>Tu cuenta está desactivada. Contacta al administrador de tu universidad.";
                }

                if (codigo == -6)
                {
                    return "-6<SPLITER>Tu universidad no tiene una suscripción activa en Naia.";
                }

                if (codigo <= 0)
                {
                    return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
                }

                // ===========================================
                // 5. VALIDAR IDENTIFICADORES DEL USUARIO
                // ===========================================

                int usuarioId;
                int institucionId;
                int rolId;

                bool usuarioValido = int.TryParse(
                    fila["UsuarioId"].ToString(),
                    out usuarioId);

                bool institucionValida = int.TryParse(
                    fila["InstitucionId"].ToString(),
                    out institucionId);

                bool rolValido = int.TryParse(
                    fila["RolId"].ToString(),
                    out rolId);

                if (!usuarioValido ||
                    !institucionValida ||
                    !rolValido ||
                    usuarioId <= 0 ||
                    institucionId <= 0 ||
                    rolId <= 0)
                {
                    return "0<SPLITER>Los datos de autenticación no son válidos.";
                }

                // ===========================================
                // 6. CREAR SESION ASP.NET
                // ===========================================

                // Borrar datos de una identidad anterior.
                contexto.Session.Clear();

                // Guardar los valores autenticados
                // obtenidos desde SQL Server.
                contexto.Session["UsuarioId"] = usuarioId;
                contexto.Session["InstitucionId"] = institucionId;
                contexto.Session["RolId"] = rolId;

                // Verificar que los datos quedaron guardados
                // en la sesion de esta solicitud.
                if (contexto.Session["UsuarioId"] == null ||
                    contexto.Session["InstitucionId"] == null ||
                    contexto.Session["RolId"] == null)
                {
                    return "0<SPLITER>No se pudo establecer la sesión del usuario.";
                }

                // ===========================================
                // 7. PAGINA DESTINO SEGUN EL ROL
                // ===========================================

                string sDestino;

                switch (rolId)
                {
                    case 4:
                        sDestino = "../Inicio/frmInicioAdmin.aspx";
                        break;

                    case 3:
                        sDestino = "../Inicio/frmInicioSoporte.aspx";
                        break;

                    default:
                        sDestino = "../Inicio/frmInicioUsuario.aspx";
                        break;
                }

                // ===========================================
                // 8. RESPUESTA PARA INICIOSESION.JS
                // ===========================================

                string mensaje =
                    usuarioId.ToString() + "<SPLITER>" +
                    "Bienvenid@ de nuevo " +
                    fila["Nombre"].ToString() + "<SPLITER>" +
                    institucionId.ToString() + "<SPLITER>" +
                    rolId.ToString() + "<SPLITER>" +
                    fila["NombreCompleto"].ToString() + "<SPLITER>" +
                    fila["Correo"].ToString() + "<SPLITER>" +
                    fila["NombreInstitucion"].ToString() + "<SPLITER>" +
                    sDestino;

                return mensaje;
            }
            catch (Exception)
            {
                return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
            }
        }

        // ===================================================
        // CERRAR SESION - NAIA
        //
        // Finaliza la sesion ASP.NET del usuario actual.
        // Se invoca desde Sesion.js.
        //
        // No modifica datos en SQL Server.
        // ===================================================

        [WebMethod(EnableSession = true)]
        public static bool CerrarSesionServidor()
        {
            HttpContext contexto = HttpContext.Current;

            // Validar que exista una sesion
            if (contexto == null ||
                contexto.Session == null)
            {
                return false;
            }

            // ===========================================
            // 1. ELIMINAR DATOS DE AUTENTICACION
            // ===========================================

            contexto.Session.Clear();

            // ===========================================
            // 2. FINALIZAR SESION ASP.NET
            // ===========================================

            contexto.Session.Abandon();

            // ===========================================
            // 3. CONFIRMAR OPERACION
            // ===========================================

            return true;
        }
    }
}
