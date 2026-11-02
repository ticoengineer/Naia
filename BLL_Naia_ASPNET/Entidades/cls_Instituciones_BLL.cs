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
    public class cls_Instituciones_BLL
    {
        public void Registrar_Institucion(ref cls_Instituciones_DAL obj_Instituciones_DAL)
        {
            try
            {
                /*Objetos de comunicación con la base de datos*/
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                /*Estructura de la tabla de parámetros*/
                obj_Instituciones_DAL.dtParametros = null;
                obj_Instituciones_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj_Instituciones_DAL.dtParametros);

                /*Parámetros del SP: nombre, código de tipo de dato, valor*/
                obj_Instituciones_DAL.dtParametros.Rows.Add("@PlanId", "1", obj_Instituciones_DAL.iPlanId);
                obj_Instituciones_DAL.dtParametros.Rows.Add("@NombreInstitucion", "7", obj_Instituciones_DAL.sNombreInstitucion);
                obj_Instituciones_DAL.dtParametros.Rows.Add("@Siglas", "7", obj_Instituciones_DAL.sSiglas);
                obj_Instituciones_DAL.dtParametros.Rows.Add("@DominioCorreo", "6", obj_Instituciones_DAL.sDominioCorreo);
                obj_Instituciones_DAL.dtParametros.Rows.Add("@TipoIdentificacionId", "11", obj_Instituciones_DAL.iTipoIdentificacionId);
                obj_Instituciones_DAL.dtParametros.Rows.Add("@Identificacion", "6", obj_Instituciones_DAL.sIdentificacion);
                obj_Instituciones_DAL.dtParametros.Rows.Add("@NumeroInterno", "6", obj_Instituciones_DAL.sNumeroInterno);
                obj_Instituciones_DAL.dtParametros.Rows.Add("@Nombre", "7", obj_Instituciones_DAL.sNombre);
                obj_Instituciones_DAL.dtParametros.Rows.Add("@Apellidos", "7", obj_Instituciones_DAL.sApellidos);
                obj_Instituciones_DAL.dtParametros.Rows.Add("@Correo", "6", obj_Instituciones_DAL.sCorreo);
                obj_Instituciones_DAL.dtParametros.Rows.Add("@Contrasena", "6", obj_Instituciones_DAL.sContrasena);
                obj_Instituciones_DAL.dtParametros.Rows.Add("@DireccionIp", "6", obj_Instituciones_DAL.sDireccionIp);

                /*Nombre del SP (Web.config) y tipo de acción*/
                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_INSERTA_INSTITUCIONES"];
                obj_BD_DAL.sIndAxn = "SCALAR";
                obj_BD_DAL.DT_Parametros = obj_Instituciones_DAL.dtParametros;

                /*Ejecutar*/
                obj_BD_BLL.EjecutaProcesosComando(ref obj_BD_DAL);

                /*Respuesta de la base de datos*/
                obj_Instituciones_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj_Instituciones_DAL.sValorScalar = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.sValorScalar : null;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
    }

}
