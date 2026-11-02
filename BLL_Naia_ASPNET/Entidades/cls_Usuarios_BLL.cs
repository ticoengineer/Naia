using BLL_Naia_ASPNET.BD;
using DAL_Naia_ASPNET.BD;
using DAL_Naia_ASPNET.Entidades;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL_Naia_ASPNET.Entidades
{
    public class cls_Usuarios_BLL
    {
        /// <summary>
        /// Ejecuta SP_INICIAR_SESION. El SP siempre devuelve UNA fila cuya primera columna es "Codigo":
        /// > 0 = UsuarioId (éxito) · -1 credenciales · -3 cuenta inactiva · -6 universidad inactiva · 0 error
        /// </summary>
        public void Iniciar_Sesion(ref cls_Usuarios_DAL obj_Usuarios_DAL)
        {
            try
            {
                /*Objetos de comunicación con la base de datos*/
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                /*Estructura de la tabla de parámetros*/
                obj_Usuarios_DAL.dtParametros = null;
                obj_Usuarios_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj_Usuarios_DAL.dtParametros);

                /*Parámetros del SP: nombre, código de tipo de dato, valor*/
                obj_Usuarios_DAL.dtParametros.Rows.Add("@Correo", "6", obj_Usuarios_DAL.sCorreo);
                obj_Usuarios_DAL.dtParametros.Rows.Add("@Contrasena", "6", obj_Usuarios_DAL.sContrasena);
                obj_Usuarios_DAL.dtParametros.Rows.Add("@DireccionIp", "6", obj_Usuarios_DAL.sDireccionIp);

                /*SP (Web.config) y nombre lógico de la tabla de respuesta*/
                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_INICIAR_SESION"];
                obj_BD_DAL.sNomTabla = "InicioSesion";
                obj_BD_DAL.DT_Parametros = obj_Usuarios_DAL.dtParametros;

                /*Ejecutar*/
                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                /*Respuesta de la base de datos*/
                if (obj_BD_DAL.sMsjErrorBD == string.Empty)
                {
                    obj_Usuarios_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
                    obj_Usuarios_DAL.dtDatos = obj_BD_DAL.DS.Tables[0];
                }
                else
                {
                    obj_Usuarios_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
                    obj_Usuarios_DAL.dtDatos = null;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
    }
}
