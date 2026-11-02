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
    public class cls_Planes_BLL
    {
        public void Listar_Planes(ref cls_Planes_DAL obj_Planes_DAL)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj_Planes_DAL.dtParametros = null;
                obj_Planes_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj_Planes_DAL.dtParametros);

                /*Bit: se manda el bool (true/false), no "1"/"0", para que se convierta bien*/
                obj_Planes_DAL.dtParametros.Rows.Add("@SoloActivos", "9", obj_Planes_DAL.bSoloActivos);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_LISTAR_PLANES"];
                obj_BD_DAL.sNomTabla = "Planes";
                obj_BD_DAL.DT_Parametros = obj_Planes_DAL.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                if (obj_BD_DAL.sMsjErrorBD == string.Empty)
                {
                    obj_Planes_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
                    obj_Planes_DAL.dtDatos = obj_BD_DAL.DS.Tables[0];
                }
                else
                {
                    obj_Planes_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
                    obj_Planes_DAL.dtDatos = null;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
    }
}
