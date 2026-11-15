using BLL_Naia_ASPNET.BD;
using DAL_Naia_ASPNET.BD;
using DAL_Naia_ASPNET.Entidades;
using System;
using System.Configuration;

namespace BLL_Naia_ASPNET.Entidades
{
    public class cls_Auditoria_BLL
    {
        // ==================== LISTAR ====================
        public void Listar_Auditoria(ref cls_Auditoria_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);
                obj.dtParametros.Rows.Add("@InstitucionId", "1", obj.iInstitucionId);
                obj.dtParametros.Rows.Add("@IdUsuarioGlobal", "1", obj.iIdUsuarioGlobal);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_LISTAR_AUDITORIA"];
                obj_BD_DAL.sNomTabla = "Auditoria";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables["Auditoria"] : null;
            }
            catch (Exception ex) { throw ex; }
        }

        // ==================== FILTRAR ====================
        public void Filtrar_Auditoria(ref cls_Auditoria_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);
                obj.dtParametros.Rows.Add("@InstitucionId", "1", obj.iInstitucionId);
                obj.dtParametros.Rows.Add("@IdUsuarioGlobal", "1", obj.iIdUsuarioGlobal);

                // FechaInicio - puede ser NULL
                obj.dtParametros.Rows.Add("@FechaInicio",
                    string.IsNullOrEmpty(obj.sFechaInicio) ? "0" : "6",
                    string.IsNullOrEmpty(obj.sFechaInicio) ? (object)System.DBNull.Value : obj.sFechaInicio);

                // FechaFin - puede ser NULL
                obj.dtParametros.Rows.Add("@FechaFin",
                    string.IsNullOrEmpty(obj.sFechaFin) ? "0" : "6",
                    string.IsNullOrEmpty(obj.sFechaFin) ? (object)System.DBNull.Value : obj.sFechaFin);

                // SeccionSistema - puede ser NULL
                obj.dtParametros.Rows.Add("@SeccionSistema",
                    string.IsNullOrEmpty(obj.sSeccionSistema) ? "0" : "7",
                    string.IsNullOrEmpty(obj.sSeccionSistema) ? (object)System.DBNull.Value : obj.sSeccionSistema);

                // Accion - puede ser NULL
                obj.dtParametros.Rows.Add("@Accion",
                    string.IsNullOrEmpty(obj.sAccion) ? "0" : "7",
                    string.IsNullOrEmpty(obj.sAccion) ? (object)System.DBNull.Value : obj.sAccion);

                // UsuarioId - puede ser NULL
                obj.dtParametros.Rows.Add("@UsuarioId",
                    obj.iUsuarioId == 0 ? "0" : "1",
                    obj.iUsuarioId == 0 ? (object)System.DBNull.Value : obj.iUsuarioId);

                // Exitoso - puede ser NULL (-1 = todos)
                obj.dtParametros.Rows.Add("@Exitoso",
                    obj.iExitoso < 0 ? "0" : "9",
                    obj.iExitoso < 0 ? (object)System.DBNull.Value : (object)(obj.iExitoso == 1));

                // Filtro texto - puede ser NULL
                obj.dtParametros.Rows.Add("@Filtro",
                    string.IsNullOrEmpty(obj.sFiltro) ? "0" : "7",
                    string.IsNullOrEmpty(obj.sFiltro) ? (object)System.DBNull.Value : obj.sFiltro);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_FILTRAR_AUDITORIA"];
                obj_BD_DAL.sNomTabla = "Auditoria";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables["Auditoria"] : null;
            }
            catch (Exception ex) { throw ex; }
        }
    }
}
