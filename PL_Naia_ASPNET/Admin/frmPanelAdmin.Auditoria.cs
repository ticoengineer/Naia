
using BLL_Naia_ASPNET.Entidades;
using DAL_Naia_ASPNET.Entidades;
using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Web;
using System.Web.Services;

namespace PL_Naia_ASPNET.Admin
{
    public partial class frmPanelAdmin : System.Web.UI.Page
    {
        // =============================================
        // VALIDAR IDENTIDAD DEL ADMINISTRADOR
        // =============================================

        private static void aud_ValidarAdministrador(
            out int institucionId,
            out int usuarioId)
        {
            HttpContext contexto = HttpContext.Current;

            if (contexto == null || contexto.Session == null)
            {
                throw new HttpException(
                    401, "No existe una sesión autenticada.");
            }

            object sesionUsuario = contexto.Session["UsuarioId"];
            object sesionInstitucion = contexto.Session["InstitucionId"];
            object sesionRol = contexto.Session["RolId"];

            int rolId;

            if (sesionUsuario == null ||
                sesionInstitucion == null ||
                sesionRol == null ||
                !int.TryParse(sesionUsuario.ToString(), out usuarioId) ||
                !int.TryParse(sesionInstitucion.ToString(), out institucionId) ||
                !int.TryParse(sesionRol.ToString(), out rolId) ||
                usuarioId <= 0 ||
                institucionId <= 0 ||
                rolId != 4)
            {
                throw new HttpException(
                    403, "No tienes autorización para consultar Auditoría.");
            }
        }

        // =============================================
        // CONVERTIR RESULTADOS PARA JAVASCRIPT
        // =============================================

        private static List<Dictionary<string, string>>
            aud_ConvertirResultados(DataTable tabla)
        {
            List<Dictionary<string, string>> lista =
                new List<Dictionary<string, string>>();

            if (tabla == null)
                return lista;

            foreach (DataRow fila in tabla.Rows)
            {
                Dictionary<string, string> movimiento =
                    new Dictionary<string, string>();

                foreach (DataColumn columna in tabla.Columns)
                {
                    movimiento[columna.ColumnName] =
                        fila[columna] == DBNull.Value
                        ? ""
                        : fila[columna].ToString();
                }

                lista.Add(movimiento);
            }

            return lista;
        }

        // =============================================
        // LISTAR AUDITORÍA
        // =============================================

        [WebMethod(EnableSession = true)]
        public static List<Dictionary<string, string>>
            ListarAuditoria()
        {
            int institucionId;
            int usuarioId;

            aud_ValidarAdministrador(
                out institucionId, out usuarioId);

            cls_Auditoria_DAL obj_Auditoria_DAL =
                new cls_Auditoria_DAL();

            cls_Auditoria_BLL obj_Auditoria_BLL =
                new cls_Auditoria_BLL();

            obj_Auditoria_DAL.iInstitucionId = institucionId;
            obj_Auditoria_DAL.iIdUsuarioGlobal = usuarioId;

            obj_Auditoria_BLL.Listar_Auditoria(
                ref obj_Auditoria_DAL);

            if (!string.IsNullOrEmpty(
                obj_Auditoria_DAL.sMSJError))
            {
                throw new Exception(
                    "No se pudo consultar Auditoría.");
            }

            return aud_ConvertirResultados(
                obj_Auditoria_DAL.dtDatos);
        }

        // =============================================
        // FILTRAR AUDITORÍA
        // =============================================

        [WebMethod(EnableSession = true)]
        public static List<Dictionary<string, string>>
            FiltrarAuditoria(List<string> obj_Parametros_JS)
        {
            int institucionId;
            int usuarioId;

            aud_ValidarAdministrador(
                out institucionId, out usuarioId);

            // Se esperan siete filtros:
            // [0] Fecha inicial
            // [1] Fecha final
            // [2] Sección
            // [3] Acción
            // [4] UsuarioId
            // [5] Solo fallidos
            // [6] Texto de búsqueda

            if (obj_Parametros_JS == null ||
                obj_Parametros_JS.Count != 7)
            {
                throw new ArgumentException(
                    "Los filtros recibidos no son válidos.");
            }

            cls_Auditoria_DAL obj_Auditoria_DAL =
                new cls_Auditoria_DAL();

            cls_Auditoria_BLL obj_Auditoria_BLL =
                new cls_Auditoria_BLL();

            obj_Auditoria_DAL.iInstitucionId = institucionId;
            obj_Auditoria_DAL.iIdUsuarioGlobal = usuarioId;

            DateTime fecha;
            int idUsuario;

            // Fecha inicial
            if (!string.IsNullOrWhiteSpace(obj_Parametros_JS[0]))
            {
                if (!DateTime.TryParseExact(
                    obj_Parametros_JS[0],
                    "yyyy-MM-dd",
                    CultureInfo.InvariantCulture,
                    DateTimeStyles.None,
                    out fecha))
                {
                    throw new ArgumentException(
                        "Fecha inicial inválida.");
                }

                obj_Auditoria_DAL.dFechaInicio = fecha;
            }

            // Fecha final
            if (!string.IsNullOrWhiteSpace(obj_Parametros_JS[1]))
            {
                if (!DateTime.TryParseExact(
                    obj_Parametros_JS[1],
                    "yyyy-MM-dd",
                    CultureInfo.InvariantCulture,
                    DateTimeStyles.None,
                    out fecha))
                {
                    throw new ArgumentException(
                        "Fecha final inválida.");
                }

                obj_Auditoria_DAL.dFechaFin = fecha;
            }

            if (obj_Auditoria_DAL.dFechaInicio.HasValue &&
                obj_Auditoria_DAL.dFechaFin.HasValue &&
                obj_Auditoria_DAL.dFechaInicio >
                obj_Auditoria_DAL.dFechaFin)
            {
                throw new ArgumentException(
                    "La fecha inicial supera la fecha final.");
            }

            // Sección y acción
            obj_Auditoria_DAL.sSeccionSistema =
                obj_Parametros_JS[2];

            obj_Auditoria_DAL.sAccion =
                obj_Parametros_JS[3];

            if ((obj_Auditoria_DAL.sSeccionSistema ?? "").Length > 30 ||
                (obj_Auditoria_DAL.sAccion ?? "").Length > 30)
            {
                throw new ArgumentException(
                    "La sección o acción no es válida.");
            }

            // Usuario
            if (!string.IsNullOrWhiteSpace(obj_Parametros_JS[4]))
            {
                if (!int.TryParse(
                    obj_Parametros_JS[4], out idUsuario) ||
                    idUsuario <= 0)
                {
                    throw new ArgumentException(
                        "El ID del usuario no es válido.");
                }

                obj_Auditoria_DAL.iUsuarioId = idUsuario;
            }

            // Solo fallidos:
            // true = Exitoso false
            // false = sin filtro por resultado
            string soloFallidos = obj_Parametros_JS[5];

            if (soloFallidos == "true")
            {
                obj_Auditoria_DAL.bExitoso = false;
            }
            else if (soloFallidos == "false")
            {
                obj_Auditoria_DAL.bExitoso = null;
            }
            else
            {
                throw new ArgumentException(
                    "El filtro de resultado no es válido.");
            }

            // Texto de búsqueda
            obj_Auditoria_DAL.sFiltro =
                obj_Parametros_JS[6];

            if ((obj_Auditoria_DAL.sFiltro ?? "").Length > 100)
            {
                throw new ArgumentException(
                    "El texto de búsqueda es demasiado largo.");
            }

            obj_Auditoria_BLL.Filtrar_Auditoria(
                ref obj_Auditoria_DAL);

            if (!string.IsNullOrEmpty(
                obj_Auditoria_DAL.sMSJError))
            {
                throw new Exception(
                    "No se pudo filtrar Auditoría.");
            }

            return aud_ConvertirResultados(
                obj_Auditoria_DAL.dtDatos);
        }
    }
}
