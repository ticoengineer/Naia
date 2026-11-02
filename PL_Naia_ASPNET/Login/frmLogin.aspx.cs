using BLL_Naia_ASPNET.Entidades;
using DAL_Naia_ASPNET.Entidades;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PL_Naia_ASPNET.Login
{
    public partial class frmLogin : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        /// <summary>
        /// Lo llama InicioSesion.js por AJAX.
        /// Respuesta (separada por <SPLITER>):
        /// [0] Codigo (UsuarioId si es correcto) · [1] Mensaje · [2] InstitucionId · [3] RolId
        /// [4] Nombre completo · [5] Correo · [6] Nombre de la universidad · [7] Página destino
        /// </summary>
        [WebMethod]
        public static string IniciarSesion(List<string> obj_Parametros_JS)
        {
            try
            {
                string _mensaje = string.Empty;

                /*Objetos de la entidad con la que estamos trabajando*/
                cls_Usuarios_DAL obj_Usuarios_DAL = new cls_Usuarios_DAL();
                cls_Usuarios_BLL obj_Usuarios_BLL = new cls_Usuarios_BLL();

                /*Descomponer el objeto de parámetros de JS y asignar los valores a los atributos de nuestra entidad*/
                obj_Usuarios_DAL.sCorreo = obj_Parametros_JS[0].ToString();
                obj_Usuarios_DAL.sContrasena = obj_Parametros_JS[1].ToString();
                obj_Usuarios_DAL.sDireccionIp = HttpContext.Current.Request.UserHostAddress;

                /*Ejecutamos la lógica de negocio correspondiente*/
                obj_Usuarios_BLL.Iniciar_Sesion(ref obj_Usuarios_DAL);

                /*Sin respuesta de la base de datos*/
                if (obj_Usuarios_DAL.dtDatos == null || obj_Usuarios_DAL.dtDatos.Rows.Count == 0)
                {
                    return "0" + "<SPLITER>" + "No se pudo conectar con la base de datos.";
                }

                /*Recuperamos los valores y los evaluamos*/
                DataRow fila = obj_Usuarios_DAL.dtDatos.Rows[0];
                string sCodigo = fila["Codigo"].ToString();

                if (sCodigo == "-1")
                {
                    _mensaje = "-1" + "<SPLITER>" + "Correo o contraseña incorrectos. Verifique.";
                }
                else if (sCodigo == "-3")
                {
                    _mensaje = "-3" + "<SPLITER>" + "Tu cuenta está desactivada. Contacta al administrador de tu universidad.";
                }
                else if (sCodigo == "-6")
                {
                    _mensaje = "-6" + "<SPLITER>" + "Tu universidad no tiene una suscripción activa en Naia.";
                }
                else if (sCodigo == "0")
                {
                    _mensaje = "0" + "<SPLITER>" + "Ocurrió un error inesperado. Intenta de nuevo.";
                }
                else
                {
                    /*Página de inicio según el rol*/
                    string sDestino;
                    switch (Convert.ToInt32(fila["RolId"]))
                    {
                        case 4: sDestino = "../Inicio/frmInicioAdmin.aspx"; break;   // Administrativo
                        case 3: sDestino = "../Inicio/frmInicioSoporte.aspx"; break;   // Soporte técnico
                        default: sDestino = "../Inicio/frmInicioUsuario.aspx"; break;   // Estudiante y Profesor
                    }

                    _mensaje = fila["UsuarioId"].ToString() + "<SPLITER>" +
                               "Bienvenid@ de nuevo " + fila["Nombre"].ToString() + "<SPLITER>" +
                               fila["InstitucionId"].ToString() + "<SPLITER>" +
                               fila["RolId"].ToString() + "<SPLITER>" +
                               fila["NombreCompleto"].ToString() + "<SPLITER>" +
                               fila["Correo"].ToString() + "<SPLITER>" +
                               fila["NombreInstitucion"].ToString() + "<SPLITER>" +
                               sDestino;
                }

                return _mensaje;
            }
            catch (Exception)
            {
                return "0" + "<SPLITER>" + "Ocurrió un error inesperado. Intenta de nuevo.";
            }
        }
    }
}