using DAL_Naia_ASPNET.BD;
using DAL_Naia_ASPNET.Entidades;
using BLL_Naia_ASPNET.BD;
using System.Configuration;
using System.Data;

namespace BLL_Naia_ASPNET.Entidades
{
    public class cls_Auditoria_BLL
    {
        // ==================== LISTAR ====================
        public void Listar_Auditoria(ref cls_Auditoria_DAL obj_DAL)
        {
            cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
            cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

            obj_BD_DAL.sNombreBD = "Auditoria";
            obj_BD_DAL.sNombreSP = ConfigurationManager.AppSettings["SP_LISTAR_AUDITORIA"];
            obj_BD_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros();

            DataRow fila;
            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@InstitucionId";
            fila["sTipoDato"] = "1";
            fila["sValor"] = obj_DAL.iInstitucionId;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@IdUsuarioGlobal";
            fila["sTipoDato"] = "1";
            fila["sValor"] = obj_DAL.iIdUsuarioGlobal;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);
            obj_DAL.dtDatos = obj_BD_DAL.dtDatos;
            obj_DAL.sMSJError = obj_BD_DAL.sMSJError;
        }

        // ==================== FILTRAR ====================
        public void Filtrar_Auditoria(ref cls_Auditoria_DAL obj_DAL)
        {
            cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
            cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

            obj_BD_DAL.sNombreBD = "Auditoria";
            obj_BD_DAL.sNombreSP = ConfigurationManager.AppSettings["SP_FILTRAR_AUDITORIA"];
            obj_BD_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros();

            DataRow fila;
            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@InstitucionId";
            fila["sTipoDato"] = "1";
            fila["sValor"] = obj_DAL.iInstitucionId;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@IdUsuarioGlobal";
            fila["sTipoDato"] = "1";
            fila["sValor"] = obj_DAL.iIdUsuarioGlobal;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            // FechaInicio - puede ser NULL
            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@FechaInicio";
            fila["sTipoDato"] = string.IsNullOrEmpty(obj_DAL.sFechaInicio) ? "0" : "6";
            fila["sValor"] = string.IsNullOrEmpty(obj_DAL.sFechaInicio) ? (object)System.DBNull.Value : obj_DAL.sFechaInicio;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            // FechaFin - puede ser NULL
            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@FechaFin";
            fila["sTipoDato"] = string.IsNullOrEmpty(obj_DAL.sFechaFin) ? "0" : "6";
            fila["sValor"] = string.IsNullOrEmpty(obj_DAL.sFechaFin) ? (object)System.DBNull.Value : obj_DAL.sFechaFin;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            // SeccionSistema - puede ser NULL
            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@SeccionSistema";
            fila["sTipoDato"] = string.IsNullOrEmpty(obj_DAL.sSeccionSistema) ? "0" : "7";
            fila["sValor"] = string.IsNullOrEmpty(obj_DAL.sSeccionSistema) ? (object)System.DBNull.Value : obj_DAL.sSeccionSistema;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            // Accion - puede ser NULL
            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@Accion";
            fila["sTipoDato"] = string.IsNullOrEmpty(obj_DAL.sAccion) ? "0" : "7";
            fila["sValor"] = string.IsNullOrEmpty(obj_DAL.sAccion) ? (object)System.DBNull.Value : obj_DAL.sAccion;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            // UsuarioId - puede ser NULL
            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@UsuarioId";
            fila["sTipoDato"] = obj_DAL.iUsuarioId == 0 ? "0" : "1";
            fila["sValor"] = obj_DAL.iUsuarioId == 0 ? (object)System.DBNull.Value : obj_DAL.iUsuarioId;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            // Exitoso - puede ser NULL (-1 = todos)
            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@Exitoso";
            fila["sTipoDato"] = obj_DAL.iExitoso < 0 ? "0" : "9";
            fila["sValor"] = obj_DAL.iExitoso < 0 ? (object)System.DBNull.Value : (obj_DAL.iExitoso == 1);
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            // Filtro texto - puede ser NULL
            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@Filtro";
            fila["sTipoDato"] = string.IsNullOrEmpty(obj_DAL.sFiltro) ? "0" : "7";
            fila["sValor"] = string.IsNullOrEmpty(obj_DAL.sFiltro) ? (object)System.DBNull.Value : obj_DAL.sFiltro;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);
            obj_DAL.dtDatos = obj_BD_DAL.dtDatos;
            obj_DAL.sMSJError = obj_BD_DAL.sMSJError;
        }
    }
}
