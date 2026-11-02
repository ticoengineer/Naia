using BLL_Naia_ASPNET.Entidades;
using DAL_Naia_ASPNET.Entidades;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace PL_Naia_ASPNET.RegistroInstitucion
{
    public partial class frmRegistroInstitucion : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        [WebMethod]
        public static string RegistrarInstitucion(List<string> obj_Parametros_JS)
        {
            try
            {
                cls_Instituciones_DAL obj_Instituciones_DAL = new cls_Instituciones_DAL();
                cls_Instituciones_BLL obj_Instituciones_BLL = new cls_Instituciones_BLL();

                /*Descomponer los parámetros de JS (mismo orden que en RegistroInstitucion.js)*/
                obj_Instituciones_DAL.iPlanId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_Instituciones_DAL.sNombreInstitucion = obj_Parametros_JS[1];
                obj_Instituciones_DAL.sSiglas = obj_Parametros_JS[2];
                obj_Instituciones_DAL.sDominioCorreo = obj_Parametros_JS[3];
                obj_Instituciones_DAL.iTipoIdentificacionId = Convert.ToInt32(obj_Parametros_JS[4]);
                obj_Instituciones_DAL.sIdentificacion = obj_Parametros_JS[5];
                obj_Instituciones_DAL.sNumeroInterno = obj_Parametros_JS[6];
                obj_Instituciones_DAL.sNombre = obj_Parametros_JS[7];
                obj_Instituciones_DAL.sApellidos = obj_Parametros_JS[8];
                /*El correo completo lo arma el servidor con el dominio (no se confía en el JS)*/
                obj_Instituciones_DAL.sCorreo = obj_Parametros_JS[9] + "@" + obj_Parametros_JS[3];
                obj_Instituciones_DAL.sContrasena = obj_Parametros_JS[10];
                obj_Instituciones_DAL.sDireccionIp = HttpContext.Current.Request.UserHostAddress;

                obj_Instituciones_BLL.Registrar_Institucion(ref obj_Instituciones_DAL);

                /*Traducir el código del SP a un mensaje para el usuario*/
                if (obj_Instituciones_DAL.sValorScalar == null)
                    return "0<SPLITER>No se pudo conectar con la base de datos.";

                switch (obj_Instituciones_DAL.sValorScalar)
                {
                    case "-1": return "-1<SPLITER>Ya existe una universidad con ese dominio o un usuario con ese correo.";
                    case "-4": return "-4<SPLITER>Revisa los datos: el dominio debe ser válido (ej. universidad.ac.cr) y todos los campos son obligatorios.";
                    case "0": return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
                    default:
                        return obj_Instituciones_DAL.sValorScalar +
                                      "<SPLITER>Tu universidad quedó registrada. Ya puedes iniciar sesión con tu correo institucional.";
                }
            }
            catch (Exception)
            {
                return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
            }
        }

        [WebMethod]
        public static List<Dictionary<string, string>> ListarPlanes()
        {
            List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();

            cls_Planes_DAL obj_Planes_DAL = new cls_Planes_DAL();
            cls_Planes_BLL obj_Planes_BLL = new cls_Planes_BLL();

            obj_Planes_DAL.bSoloActivos = true;   // en el registro solo se ofrecen los planes vigentes
            obj_Planes_BLL.Listar_Planes(ref obj_Planes_DAL);

            if (obj_Planes_DAL.dtDatos != null)
            {
                foreach (DataRow fila in obj_Planes_DAL.dtDatos.Rows)
                {
                    lista.Add(new Dictionary<string, string>
                    {
                        { "PlanId",      fila["PlanId"].ToString() },
                        { "Nombre",      fila["NombrePlan"].ToString() },
                        { "MaxUsuarios", fila["MaxUsuarios"] == DBNull.Value ? "" : fila["MaxUsuarios"].ToString() },  // "" = ilimitado
                        { "Precio",      Convert.ToDecimal(fila["PrecioMensual"]).ToString("0.##") }
                    });
                }
            }

            return lista;
        }

    }
}