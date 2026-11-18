
using BLL_Naia_ASPNET.Entidades;
using DAL_Naia_ASPNET.Entidades;
using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.Services;

namespace PL_Naia_ASPNET.Admin
{
    public partial class frmPanelAdmin : System.Web.UI.Page
    {
        // =============================================
        // CONVERTIR DATATABLE A LISTA PARA JAVASCRIPT
        // =============================================

        private static List<Dictionary<string, string>>
            cfg_ConvertirResultados(DataTable tabla)
        {
            List<Dictionary<string, string>> lista =
                new List<Dictionary<string, string>>();

            if (tabla == null)
                return lista;

            foreach (DataRow fila in tabla.Rows)
            {
                Dictionary<string, string> registro =
                    new Dictionary<string, string>();

                foreach (DataColumn columna in tabla.Columns)
                {
                    registro[columna.ColumnName] =
                        fila[columna] == DBNull.Value
                            ? ""
                            : fila[columna].ToString();
                }

                lista.Add(registro);
            }

            return lista;
        }

        // =============================================
        // CONSULTAR INFORMACION INSTITUCIONAL
        // =============================================

        [WebMethod(EnableSession = true)]
        public static List<Dictionary<string, string>>
            InfoInstitucion()
        {
            int institucionId;
            int usuarioId;

            // Utilizamos la validacion de sesion
            // ya creada en frmPanelAdmin.Auditoria.cs
            aud_ValidarAdministrador(
                out institucionId,
                out usuarioId);

            cls_Configuracion_DAL obj_DAL =
                new cls_Configuracion_DAL();

            cls_Configuracion_BLL obj_BLL =
                new cls_Configuracion_BLL();

            obj_DAL.iInstitucionId = institucionId;

            obj_BLL.Info_Institucion(ref obj_DAL);

            if (!string.IsNullOrEmpty(obj_DAL.sMSJError) ||
                obj_DAL.dtDatos == null)
            {
                throw new Exception(
                    "No se pudo consultar la información institucional.");
            }

            return cfg_ConvertirResultados(
                obj_DAL.dtDatos);
        }

        // =============================================
        // CONSULTAR PLANES DE SUSCRIPCION
        // =============================================

        [WebMethod(EnableSession = true)]
        public static List<Dictionary<string, string>>
            ListarPlanesConfiguracion()
        {
            int institucionId;
            int usuarioId;

            aud_ValidarAdministrador(
                out institucionId,
                out usuarioId);

            cls_Configuracion_DAL obj_DAL =
                new cls_Configuracion_DAL();

            cls_Configuracion_BLL obj_BLL =
                new cls_Configuracion_BLL();

            // Se consultan todos los planes para
            // identificar tambien el plan actual,
            // incluso si ya no esta disponible.
            obj_DAL.bSoloActivos = false;

            obj_BLL.Listar_Planes(ref obj_DAL);

            if (!string.IsNullOrEmpty(obj_DAL.sMSJError) ||
                obj_DAL.dtDatos == null)
            {
                throw new Exception(
                    "No se pudieron consultar los planes.");
            }

            return cfg_ConvertirResultados(
                obj_DAL.dtDatos);
        }

        // =============================================
        // ACTUALIZAR CONFIGURACION INSTITUCIONAL
        // =============================================

        [WebMethod(EnableSession = true)]
        public static string ActualizarInstitucion(
            List<string> obj_Parametros_JS)
        {
            int institucionId;
            int usuarioId;

            aud_ValidarAdministrador(
                out institucionId,
                out usuarioId);

            // Orden:
            // [0] PlanId
            // [1] NombreInstitucion
            // [2] Siglas

            if (obj_Parametros_JS == null ||
                obj_Parametros_JS.Count != 3)
            {
                return "-4<SPLITER>Los datos recibidos no son válidos.";
            }

            int planId;

            if (!int.TryParse(obj_Parametros_JS[0],
                    out planId) ||
                planId <= 0)
            {
                return "-4<SPLITER>Seleccioná un plan válido.";
            }

            string nombre =
                (obj_Parametros_JS[1] ?? "").Trim();

            string siglas =
                (obj_Parametros_JS[2] ?? "").Trim();

            if (nombre.Length == 0 ||
                siglas.Length == 0 ||
                nombre.Length > 150 ||
                siglas.Length > 10)
            {
                return "-4<SPLITER>Revisá el nombre y las siglas de la universidad.";
            }

            cls_Configuracion_DAL obj_DAL =
                new cls_Configuracion_DAL();

            cls_Configuracion_BLL obj_BLL =
                new cls_Configuracion_BLL();

            // Identidad autenticada del servidor
            obj_DAL.iInstitucionId = institucionId;
            obj_DAL.iIdUsuarioGlobal = usuarioId;

            // Datos editables
            obj_DAL.iPlanId = planId;
            obj_DAL.sNombreInstitucion = nombre;
            obj_DAL.sSiglas = siglas;

            obj_DAL.sDireccionIp =
                HttpContext.Current.Request.UserHostAddress;

            obj_BLL.Actualizar_Institucion(ref obj_DAL);

            if (!string.IsNullOrEmpty(obj_DAL.sMSJError) ||
                string.IsNullOrEmpty(obj_DAL.sValorScalar))
            {
                return "0<SPLITER>No se pudo guardar la configuración.";
            }

            int codigo;

            if (!int.TryParse(obj_DAL.sValorScalar,
                    out codigo))
            {
                return "0<SPLITER>La base de datos devolvió una respuesta inesperada.";
            }

            switch (codigo)
            {
                case -2:
                    return "-2<SPLITER>La universidad no existe.";

                case -3:
                    return "-3<SPLITER>No tenés permisos para modificar la configuración.";

                case -4:
                    return "-4<SPLITER>El nombre, las siglas o el plan seleccionado no son válidos.";

                case -5:
                    return "-5<SPLITER>El plan seleccionado no permite la cantidad actual de usuarios activos.";

                case 0:
                    return "0<SPLITER>Ocurrió un error al guardar la configuración.";

                default:
                    if (codigo > 0)
                    {
                        return codigo.ToString() +
                            "<SPLITER>La configuración se guardó correctamente.";
                    }

                    return "0<SPLITER>La operación devolvió un código desconocido.";
            }
        }
    }
}
