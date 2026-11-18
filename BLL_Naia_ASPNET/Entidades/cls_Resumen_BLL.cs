
using BLL_Naia_ASPNET.BD;
using DAL_Naia_ASPNET.BD;
using DAL_Naia_ASPNET.Entidades;
using System;
using System.Configuration;

namespace BLL_Naia_ASPNET.Entidades
{
    public class cls_Resumen_BLL
    {
        // ==========================================
        // CONSULTAR INDICADORES DEL DASHBOARD
        // SP_DASHBOARD_TICKETS
        // ==========================================

        public void Dashboard_Tickets(
            ref cls_Resumen_DAL obj_Resumen_DAL)
        {
            cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
            cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

            // Crear tabla de parámetros
            obj_Resumen_DAL.dtParametros =
                obj_BD_BLL.ObtieneDTParametros(null);

            // Universidad autenticada
            obj_Resumen_DAL.dtParametros.Rows.Add(
                "@InstitucionId",
                "1",
                obj_Resumen_DAL.iInstitucionId);

            // Usuario autenticado
            obj_Resumen_DAL.dtParametros.Rows.Add(
                "@IdUsuarioGlobal",
                "1",
                obj_Resumen_DAL.iIdUsuarioGlobal);

            // Procedimiento almacenado
            obj_BD_DAL.sNomSP =
                ConfigurationManager.AppSettings[
                    "SP_DASHBOARD_TICKETS"];

            obj_BD_DAL.sNomTabla = "Dashboard";

            obj_BD_DAL.DT_Parametros =
                obj_Resumen_DAL.dtParametros;

            // Ejecutar consulta
            obj_BD_BLL.EjecutaProcesosTabla(
                ref obj_BD_DAL);

            // Recuperar resultado
            obj_Resumen_DAL.sMSJError =
                obj_BD_DAL.sMsjErrorBD;

            obj_Resumen_DAL.dtDatos =
                string.IsNullOrEmpty(obj_BD_DAL.sMsjErrorBD)
                && obj_BD_DAL.DS != null
                    ? obj_BD_DAL.DS.Tables["Dashboard"]
                    : null;
        }
    }
}
