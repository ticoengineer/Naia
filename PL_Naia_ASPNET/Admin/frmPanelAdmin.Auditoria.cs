using System;
using System.Collections.Generic;
using System.Web.Services;
using DAL_Naia_ASPNET.Entidades;
using BLL_Naia_ASPNET.Entidades;

namespace PL_Naia_ASPNET.Admin
{
    public partial class frmPanelAdmin : System.Web.UI.Page
    {
        // ==================== LISTAR AUDITORIA ====================
        [WebMethod]
        public static object ListarAuditoria(List<string> obj_Parametros_JS)
        {
            try
            {
                cls_Auditoria_DAL obj_DAL = new cls_Auditoria_DAL();
                cls_Auditoria_BLL obj_BLL = new cls_Auditoria_BLL();

                obj_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[1]);

                obj_BLL.Listar_Auditoria(ref obj_DAL);

                if (!string.IsNullOrEmpty(obj_DAL.sMSJError))
                    return new List<Dictionary<string, string>>();

                List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();
                foreach (System.Data.DataRow fila in obj_DAL.dtDatos.Rows)
                {
                    Dictionary<string, string> item = new Dictionary<string, string>();
                    foreach (System.Data.DataColumn col in obj_DAL.dtDatos.Columns)
                        item[col.ColumnName] = fila[col].ToString();
                    lista.Add(item);
                }
                return lista;
            }
            catch
            {
                return new List<Dictionary<string, string>>();
            }
        }

        // ==================== FILTRAR AUDITORIA ====================
        [WebMethod]
        public static object FiltrarAuditoria(List<string> obj_Parametros_JS)
        {
            try
            {
                cls_Auditoria_DAL obj_DAL = new cls_Auditoria_DAL();
                cls_Auditoria_BLL obj_BLL = new cls_Auditoria_BLL();

                obj_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[1]);
                obj_DAL.sFechaInicio = obj_Parametros_JS[2];
                obj_DAL.sFechaFin = obj_Parametros_JS[3];
                obj_DAL.sSeccionSistema = obj_Parametros_JS[4];
                obj_DAL.sAccion = obj_Parametros_JS[5];
                obj_DAL.iUsuarioId = Convert.ToInt32(obj_Parametros_JS[6]);
                obj_DAL.iExitoso = Convert.ToInt32(obj_Parametros_JS[7]);
                obj_DAL.sFiltro = obj_Parametros_JS[8];

                obj_BLL.Filtrar_Auditoria(ref obj_DAL);

                if (!string.IsNullOrEmpty(obj_DAL.sMSJError))
                    return new List<Dictionary<string, string>>();

                List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();
                foreach (System.Data.DataRow fila in obj_DAL.dtDatos.Rows)
                {
                    Dictionary<string, string> item = new Dictionary<string, string>();
                    foreach (System.Data.DataColumn col in obj_DAL.dtDatos.Columns)
                        item[col.ColumnName] = fila[col].ToString();
                    lista.Add(item);
                }
                return lista;
            }
            catch
            {
                return new List<Dictionary<string, string>>();
            }
        }
    }
}
