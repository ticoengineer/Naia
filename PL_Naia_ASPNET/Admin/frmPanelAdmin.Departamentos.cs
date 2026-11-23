using BLL_Naia_ASPNET.Entidades;
using DAL_Naia_ASPNET.Entidades;
using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.Services;

namespace PL_Naia_ASPNET.Admin
{
    /// <summary>
    /// WebMethods de la sección Departamentos. Los usan Departamentos.js y el combo de Usuarios.js,
    /// por eso las llaves que devuelven son las mismas que ya usaba Usuarios.js:
    ///   DepartamentoId · Nombre (columna "Departamento" del SP) · Activo ("True"/"False") · EstadoTexto · UsuariosActivos
    /// </summary>
    public partial class frmPanelAdmin : System.Web.UI.Page
    {
        // ==================== DEPARTAMENTOS ====================

        /// <summary>Convierte una fila del SP en lo que espera el JS.</summary>
        private static Dictionary<string, string> FilaDepartamento(DataRow fila)
        {
            return new Dictionary<string, string>
            {
                { "DepartamentoId",  fila["DepartamentoId"].ToString() },
                { "Nombre",          fila["Departamento"].ToString() },
                { "Activo",          fila["Activo"].ToString() },
                { "EstadoTexto",     fila.Table.Columns.Contains("EstadoTexto") ? fila["EstadoTexto"].ToString() : "" },
                { "UsuariosActivos", fila.Table.Columns.Contains("UsuariosActivos") ? fila["UsuariosActivos"].ToString() : "0" }
            };
        }

        /// <summary>Todos los departamentos (activos e inactivos). Parámetros: [0] InstitucionId</summary>
        [WebMethod]
        public static List<Dictionary<string, string>> ListarDepartamentos(List<string> obj_Parametros_JS)
        {
            List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();
            try
            {
                cls_Departamentos_DAL obj_DAL = new cls_Departamentos_DAL();
                cls_Departamentos_BLL obj_BLL = new cls_Departamentos_BLL();

                obj_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_DAL.bSoloActivos = false;   // el admin ve todos; el combo de Usuarios filtra Activo === "True"
                obj_BLL.Listar_Departamentos(ref obj_DAL);

                if (obj_DAL.dtDatos != null)
                    foreach (DataRow fila in obj_DAL.dtDatos.Rows)
                        lista.Add(FilaDepartamento(fila));
            }
            catch (Exception) { }
            return lista;
        }

        /// <summary>Buscador. Parámetros: [0] InstitucionId · [1] IdUsuarioGlobal · [2] Texto</summary>
        [WebMethod]
        public static List<Dictionary<string, string>> FiltrarDepartamentos(List<string> obj_Parametros_JS)
        {
            List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();
            try
            {
                cls_Departamentos_DAL obj_DAL = new cls_Departamentos_DAL();
                cls_Departamentos_BLL obj_BLL = new cls_Departamentos_BLL();

                obj_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_DAL.sFiltro = obj_Parametros_JS[2];
                obj_BLL.Filtrar_Departamentos(ref obj_DAL);

                if (obj_DAL.dtDatos != null)
                    foreach (DataRow fila in obj_DAL.dtDatos.Rows)
                        lista.Add(FilaDepartamento(fila));
            }
            catch (Exception) { }
            return lista;
        }

        /// <summary>Un departamento para el modal de editar. Parámetros: [0] InstitucionId · [1] IdUsuarioGlobal · [2] DepartamentoId</summary>
        [WebMethod]
        public static List<Dictionary<string, string>> InfoDepartamento(List<string> obj_Parametros_JS)
        {
            List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();
            try
            {
                cls_Departamentos_DAL obj_DAL = new cls_Departamentos_DAL();
                cls_Departamentos_BLL obj_BLL = new cls_Departamentos_BLL();

                obj_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_DAL.iDepartamentoId = Convert.ToInt32(obj_Parametros_JS[2]);
                obj_BLL.Info_Departamento(ref obj_DAL);

                if (obj_DAL.dtDatos != null)
                    foreach (DataRow fila in obj_DAL.dtDatos.Rows)
                        lista.Add(FilaDepartamento(fila));
            }
            catch (Exception) { }
            return lista;
        }

        /// <summary>Crear. Parámetros: [0] InstitucionId · [1] IdUsuarioGlobal · [2] Nombre</summary>
        [WebMethod]
        public static string InsertarDepartamento(List<string> obj_Parametros_JS)
        {
            try
            {
                cls_Departamentos_DAL obj_DAL = new cls_Departamentos_DAL();
                cls_Departamentos_BLL obj_BLL = new cls_Departamentos_BLL();

                obj_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[1]);
                obj_DAL.sNombre = obj_Parametros_JS[2];
                obj_DAL.sDireccionIp = HttpContext.Current.Request.UserHostAddress;

                obj_BLL.Insertar_Departamento(ref obj_DAL);

                if (obj_DAL.sValorScalar == null)
                    return "0<SPLITER>No se pudo conectar con la base de datos.";

                switch (obj_DAL.sValorScalar)
                {
                    case "-1": return "-1<SPLITER>Ya existe un departamento con ese nombre.";
                    case "-3": return "-3<SPLITER>No tienes permisos para realizar esta acción.";
                    case "-4": return "-4<SPLITER>El nombre del departamento es obligatorio.";
                    case "0": return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
                    default: return obj_DAL.sValorScalar + "<SPLITER>El departamento se registró correctamente.";
                }
            }
            catch (Exception)
            {
                return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
            }
        }

        /// <summary>
        /// Editar o activar. Parámetros: [0] InstitucionId · [1] IdUsuarioGlobal · [2] DepartamentoId · [3] Nombre · [4] Activo ("true"/"false")
        /// Editar manda el estado que ya tenía; el botón Activar manda "true".
        /// </summary>
        [WebMethod]
        public static string ActualizarDepartamento(List<string> obj_Parametros_JS)
        {
            try
            {
                cls_Departamentos_DAL obj_DAL = new cls_Departamentos_DAL();
                cls_Departamentos_BLL obj_BLL = new cls_Departamentos_BLL();

                obj_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[1]);
                obj_DAL.iDepartamentoId = Convert.ToInt32(obj_Parametros_JS[2]);
                obj_DAL.sNombre = obj_Parametros_JS[3];
                obj_DAL.bActivo = Convert.ToBoolean(obj_Parametros_JS[4]);
                obj_DAL.sDireccionIp = HttpContext.Current.Request.UserHostAddress;

                obj_BLL.Actualizar_Departamento(ref obj_DAL);

                if (obj_DAL.sValorScalar == null)
                    return "0<SPLITER>No se pudo conectar con la base de datos.";

                switch (obj_DAL.sValorScalar)
                {
                    case "-1": return "-1<SPLITER>Ya existe otro departamento con ese nombre.";
                    case "-2": return "-2<SPLITER>El departamento no fue encontrado.";
                    case "-3": return "-3<SPLITER>No tienes permisos para realizar esta acción.";
                    case "-4": return "-4<SPLITER>El nombre del departamento es obligatorio.";
                    case "-6": return "-6<SPLITER>No se puede: tiene usuarios activos (muévalos primero a otro departamento), o es Administración General, que no se puede renombrar ni desactivar.";
                    case "0": return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
                    default: return obj_DAL.sValorScalar + "<SPLITER>El departamento se actualizó correctamente.";
                }
            }
            catch (Exception)
            {
                return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
            }
        }

        /// <summary>Desactivar. Parámetros: [0] InstitucionId · [1] IdUsuarioGlobal · [2] DepartamentoId</summary>
        [WebMethod]
        public static string EliminarDepartamento(List<string> obj_Parametros_JS)
        {
            try
            {
                cls_Departamentos_DAL obj_DAL = new cls_Departamentos_DAL();
                cls_Departamentos_BLL obj_BLL = new cls_Departamentos_BLL();

                obj_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[1]);
                obj_DAL.iDepartamentoId = Convert.ToInt32(obj_Parametros_JS[2]);
                obj_DAL.sDireccionIp = HttpContext.Current.Request.UserHostAddress;

                obj_BLL.Eliminar_Departamento(ref obj_DAL);

                if (obj_DAL.sValorScalar == null)
                    return "0<SPLITER>No se pudo conectar con la base de datos.";

                switch (obj_DAL.sValorScalar)
                {
                    case "-2": return "-2<SPLITER>El departamento no fue encontrado.";
                    case "-3": return "-3<SPLITER>No tienes permisos para realizar esta acción.";
                    case "-6": return "-6<SPLITER>No se puede desactivar: tiene usuarios activos, ya está desactivado o es Administración General.";
                    case "0": return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
                    default: return obj_DAL.sValorScalar + "<SPLITER>El departamento se desactivó correctamente.";
                }
            }
            catch (Exception)
            {
                return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
            }
        }
    }
}
