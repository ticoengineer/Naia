
using BLL_Naia_ASPNET.BD;
using DAL_Naia_ASPNET.BD;
using DAL_Naia_ASPNET.Entidades;
using System;
using System.Configuration;

namespace BLL_Naia_ASPNET.Entidades
{
    public class cls_Auditoria_BLL
    {
        // ==========================================
        // LISTAR AUDITORIA
        // SP_LISTAR_AUDITORIA
        // ==========================================
        public void Listar_Auditoria(
            ref cls_Auditoria_DAL obj_Auditoria_DAL)
        {
            cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
            cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

            // Preparar tabla de parametros
            obj_Auditoria_DAL.dtParametros =
                obj_BD_BLL.ObtieneDTParametros(null);

            // Institucion
            obj_Auditoria_DAL.dtParametros.Rows.Add(
                "@InstitucionId",
                "1",
                obj_Auditoria_DAL.iInstitucionId);

            // Administrador
            obj_Auditoria_DAL.dtParametros.Rows.Add(
                "@IdUsuarioGlobal",
                "1",
                obj_Auditoria_DAL.iIdUsuarioGlobal);

            // Configurar procedimiento
            obj_BD_DAL.sNomSP =
                ConfigurationManager.AppSettings[
                    "SP_LISTAR_AUDITORIA"];

            obj_BD_DAL.sNomTabla = "Auditoria";

            obj_BD_DAL.DT_Parametros =
                obj_Auditoria_DAL.dtParametros;

            // Ejecutar
            obj_BD_BLL.EjecutaProcesosTabla(
                ref obj_BD_DAL);

            // Guardar resultado
            obj_Auditoria_DAL.sMSJError =
                obj_BD_DAL.sMsjErrorBD;

            obj_Auditoria_DAL.dtDatos =
                obj_BD_DAL.sMsjErrorBD == string.Empty
                && obj_BD_DAL.DS != null
                    ? obj_BD_DAL.DS.Tables["Auditoria"]
                    : null;
        }

        // ==========================================
        // FILTRAR AUDITORIA
        // SP_FILTRAR_AUDITORIA
        // ==========================================
        public void Filtrar_Auditoria(
            ref cls_Auditoria_DAL obj_Auditoria_DAL)
        {
            cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
            cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

            // Preparar tabla de parametros
            obj_Auditoria_DAL.dtParametros =
                obj_BD_BLL.ObtieneDTParametros(null);

            // 1. Institucion
            obj_Auditoria_DAL.dtParametros.Rows.Add(
                "@InstitucionId",
                "1",
                obj_Auditoria_DAL.iInstitucionId);

            // 2. Administrador
            obj_Auditoria_DAL.dtParametros.Rows.Add(
                "@IdUsuarioGlobal",
                "1",
                obj_Auditoria_DAL.iIdUsuarioGlobal);

            // 3. Fecha inicial
            obj_Auditoria_DAL.dtParametros.Rows.Add(
                "@FechaInicio",
                "8",
                obj_Auditoria_DAL.dFechaInicio.HasValue
                    ? (object)obj_Auditoria_DAL.dFechaInicio.Value.Date
                    : DBNull.Value);

            // 4. Fecha final
            obj_Auditoria_DAL.dtParametros.Rows.Add(
                "@FechaFin",
                "8",
                obj_Auditoria_DAL.dFechaFin.HasValue
                    ? (object)obj_Auditoria_DAL.dFechaFin.Value.Date
                    : DBNull.Value);

            // 5. Seccion
            obj_Auditoria_DAL.dtParametros.Rows.Add(
                "@SeccionSistema",
                "7",
                string.IsNullOrWhiteSpace(
                    obj_Auditoria_DAL.sSeccionSistema)
                    ? (object)DBNull.Value
                    : obj_Auditoria_DAL.sSeccionSistema);

            // 6. Accion
            obj_Auditoria_DAL.dtParametros.Rows.Add(
                "@Accion",
                "7",
                string.IsNullOrWhiteSpace(
                    obj_Auditoria_DAL.sAccion)
                    ? (object)DBNull.Value
                    : obj_Auditoria_DAL.sAccion);

            // 7. Usuario
            obj_Auditoria_DAL.dtParametros.Rows.Add(
                "@UsuarioId",
                "1",
                obj_Auditoria_DAL.iUsuarioId.HasValue
                    ? (object)obj_Auditoria_DAL.iUsuarioId.Value
                    : DBNull.Value);

            // 8. Resultado
            obj_Auditoria_DAL.dtParametros.Rows.Add(
                "@Exitoso",
                "9",
                obj_Auditoria_DAL.bExitoso.HasValue
                    ? (object)obj_Auditoria_DAL.bExitoso.Value
                    : DBNull.Value);

            // 9. Texto de busqueda
            obj_Auditoria_DAL.dtParametros.Rows.Add(
                "@Filtro",
                "7",
                string.IsNullOrWhiteSpace(
                    obj_Auditoria_DAL.sFiltro)
                    ? (object)DBNull.Value
                    : obj_Auditoria_DAL.sFiltro);

            // Configurar procedimiento
            obj_BD_DAL.sNomSP =
                ConfigurationManager.AppSettings[
                    "SP_FILTRAR_AUDITORIA"];

            obj_BD_DAL.sNomTabla = "Auditoria";

            obj_BD_DAL.DT_Parametros =
                obj_Auditoria_DAL.dtParametros;

            // Ejecutar
            obj_BD_BLL.EjecutaProcesosTabla(
                ref obj_BD_DAL);

            // Guardar resultado
            obj_Auditoria_DAL.sMSJError =
                obj_BD_DAL.sMsjErrorBD;

            obj_Auditoria_DAL.dtDatos =
                obj_BD_DAL.sMsjErrorBD == string.Empty
                && obj_BD_DAL.DS != null
                    ? obj_BD_DAL.DS.Tables["Auditoria"]
                    : null;
        }
    }
}
