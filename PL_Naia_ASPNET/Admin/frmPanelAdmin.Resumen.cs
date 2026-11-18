
using BLL_Naia_ASPNET.Entidades;
using DAL_Naia_ASPNET.Entidades;
using System;
using System.Collections.Generic;
using System.Data;
using System.Web.Services;

namespace PL_Naia_ASPNET.Admin
{
    public partial class frmPanelAdmin : System.Web.UI.Page
    {
        // ==========================================
        // CONVERTIR RESULTADOS PARA JAVASCRIPT
        // ==========================================

        private static List<Dictionary<string, int>>
            res_ConvertirResultados(DataTable tabla)
        {
            var registros =
                new List<Dictionary<string, int>>();

            if (tabla == null)
                return registros;

            foreach (DataRow fila in tabla.Rows)
            {
                var registro =
                    new Dictionary<string, int>();

                foreach (DataColumn columna in tabla.Columns)
                {
                    int valor = 0;

                    if (fila[columna] != DBNull.Value)
                    {
                        valor = Convert.ToInt32(
                            fila[columna]);
                    }

                    registro[columna.ColumnName] = valor;
                }

                registros.Add(registro);
            }

            return registros;
        }

        // ==========================================
        // CONSULTAR RESUMEN DE TIQUETES
        // ==========================================

        [WebMethod(EnableSession = true)]
        public static List<Dictionary<string, int>>
            DashboardTickets()
        {
            int institucionId;
            int usuarioId;

            // Reutilizamos la validacion de sesion
            // creada para Auditoria y Configuracion.
            aud_ValidarAdministrador(
                out institucionId,
                out usuarioId);

            cls_Resumen_DAL obj_DAL =
                new cls_Resumen_DAL();

            cls_Resumen_BLL obj_BLL =
                new cls_Resumen_BLL();

            // Identificadores obtenidos exclusivamente
            // de la sesion ASP.NET autenticada.
            obj_DAL.iInstitucionId = institucionId;
            obj_DAL.iIdUsuarioGlobal = usuarioId;

            // Ejecutar procedimiento SQL
            obj_BLL.Dashboard_Tickets(
                ref obj_DAL);

            if (!string.IsNullOrEmpty(obj_DAL.sMSJError)
                || obj_DAL.dtDatos == null)
            {
                throw new Exception(
                    "No se pudo consultar el resumen de tiquetes.");
            }

            return res_ConvertirResultados(
                obj_DAL.dtDatos);
        }
    }
}
