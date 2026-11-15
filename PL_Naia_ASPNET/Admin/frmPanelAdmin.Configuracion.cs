using System;
using System.Collections.Generic;
using System.Web.Services;
using DAL_Naia_ASPNET.Entidades;
using BLL_Naia_ASPNET.Entidades;

namespace PL_Naia_ASPNET.Admin
{
    public partial class frmPanelAdmin : System.Web.UI.Page
    {
        // ==================== INFO INSTITUCION ====================
        [WebMethod]
        public static object InfoInstitucion(List<string> obj_Parametros_JS)
        {
            try
            {
                cls_Configuracion_DAL obj_DAL = new cls_Configuracion_DAL();
                cls_Configuracion_BLL obj_BLL = new cls_Configuracion_BLL();

                obj_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[1]);

                obj_BLL.Info_Institucion(ref obj_DAL);

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

        // ==================== ACTUALIZAR INSTITUCION ====================
        [WebMethod]
        public static string ActualizarInstitucion(List<string> obj_Parametros_JS)
        {
            try
            {
                cls_Configuracion_DAL obj_DAL = new cls_Configuracion_DAL();
                cls_Configuracion_BLL obj_BLL = new cls_Configuracion_BLL();

                obj_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[1]);
                obj_DAL.iPlanId = Convert.ToInt32(obj_Parametros_JS[2]);
                obj_DAL.sNombreInstitucion = obj_Parametros_JS[3];
                obj_DAL.sSiglas = obj_Parametros_JS[4];
                obj_DAL.sDireccionIp = obj_Parametros_JS[5];

                obj_BLL.Actualizar_Institucion(ref obj_DAL);

                if (!string.IsNullOrEmpty(obj_DAL.sMSJError))
                    return "-99<SPLITER>" + obj_DAL.sMSJError;

                string codigo = obj_DAL.sValorScalar;
                int cod = Convert.ToInt32(codigo);

                if (cod > 0)
                    return codigo + "<SPLITER>Institucion actualizada correctamente";
                else if (cod == -1)
                    return codigo + "<SPLITER>Ya existe una institucion con ese nombre";
                else if (cod == -2)
                    return codigo + "<SPLITER>Institucion no encontrada";
                else if (cod == -3)
                    return codigo + "<SPLITER>No tiene permisos para esta accion";
                else
                    return codigo + "<SPLITER>Error al actualizar institucion";
            }
            catch (Exception ex)
            {
                return "-99<SPLITER>" + ex.Message;
            }
        }

        // ==================== LISTAR PLANES ====================
        [WebMethod]
        public static object ListarPlanes(List<string> obj_Parametros_JS)
        {
            try
            {
                cls_Configuracion_DAL obj_DAL = new cls_Configuracion_DAL();
                cls_Configuracion_BLL obj_BLL = new cls_Configuracion_BLL();

                obj_DAL.bSoloActivos = obj_Parametros_JS[0] == "1";

                obj_BLL.Listar_Planes(ref obj_DAL);

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
