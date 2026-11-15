using BLL_Naia_ASPNET.BD;
using DAL_Naia_ASPNET.BD;
using DAL_Naia_ASPNET.Entidades;
using System;
using System.Configuration;

namespace BLL_Naia_ASPNET.Entidades
{
    public class cls_Catalogos_BLL
    {
        // ==================== LISTAR ROLES ====================
        public void Listar_Roles(ref cls_Catalogos_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_LISTAR_ROLES"];
                obj_BD_DAL.sNomTabla = "Roles";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables["Roles"] : null;
            }
            catch (Exception ex) { throw ex; }
        }

        // ==================== LISTAR TIPOS IDENTIFICACION ====================
        public void Listar_TiposIdentificacion(ref cls_Catalogos_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_LISTAR_TIPOS_IDENTIFICACION"];
                obj_BD_DAL.sNomTabla = "TiposIdentificacion";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables["TiposIdentificacion"] : null;
            }
            catch (Exception ex) { throw ex; }
        }
    }
}
