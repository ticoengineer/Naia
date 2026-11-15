using DAL_Naia_ASPNET.BD;
using DAL_Naia_ASPNET.Entidades;
using BLL_Naia_ASPNET.BD;
using System.Configuration;

namespace BLL_Naia_ASPNET.Entidades
{
    public class cls_Catalogos_BLL
    {
        // ==================== LISTAR ROLES ====================
        public void Listar_Roles(ref cls_Catalogos_DAL obj_DAL)
        {
            cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
            cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

            obj_BD_DAL.sNombreBD = "Catalogos";
            obj_BD_DAL.sNombreSP = ConfigurationManager.AppSettings["SP_LISTAR_ROLES"];
            obj_BD_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros();

            obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);
            obj_DAL.dtDatos = obj_BD_DAL.dtDatos;
            obj_DAL.sMSJError = obj_BD_DAL.sMSJError;
        }

        // ==================== LISTAR TIPOS IDENTIFICACION ====================
        public void Listar_TiposIdentificacion(ref cls_Catalogos_DAL obj_DAL)
        {
            cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
            cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

            obj_BD_DAL.sNombreBD = "Catalogos";
            obj_BD_DAL.sNombreSP = ConfigurationManager.AppSettings["SP_LISTAR_TIPOS_IDENTIFICACION"];
            obj_BD_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros();

            obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);
            obj_DAL.dtDatos = obj_BD_DAL.dtDatos;
            obj_DAL.sMSJError = obj_BD_DAL.sMSJError;
        }
    }
}
