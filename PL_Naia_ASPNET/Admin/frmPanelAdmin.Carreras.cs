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
    /// WebMethods de la sección Carreras. Los usan Carreras.js y también los combos de
    /// Usuarios.js y Departamentos.js, por eso las llaves que devuelven NO cambian:
    ///   CarreraId · Nombre (columna "Carrera" del SP) · Activa ("True"/"False", columna "Activo") · EstadoTexto · UsuariosActivos
    /// </summary>
    public partial class frmPanelAdmin : System.Web.UI.Page
    {
        // ==================== CARRERAS ====================

        /// <summary>Convierte una fila del SP en lo que espera el JS.</summary>
        private static Dictionary<string, string> FilaCarrera(DataRow fila)
        {
            return new Dictionary<string, string>
            {
                { "CarreraId",       fila["CarreraId"].ToString() },
                { "Nombre",          fila["Carrera"].ToString() },
                { "Activa",          fila["Activo"].ToString() },
                { "EstadoTexto",     fila.Table.Columns.Contains("EstadoTexto") ? fila["EstadoTexto"].ToString() : "" },
                { "UsuariosActivos", fila.Table.Columns.Contains("UsuariosActivos") ? fila["UsuariosActivos"].ToString() : "0" }
            };
        }

        /// <summary>Todas las carreras (activas e inactivas). Parámetros: [0] InstitucionId</summary>
        [WebMethod]
        public static List<Dictionary<string, string>> ListarCarreras(List<string> obj_Parametros_JS)
        {
            List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();
            try
            {
                cls_Carreras_DAL obj_DAL = new cls_Carreras_DAL();
                cls_Carreras_BLL obj_BLL = new cls_Carreras_BLL();

                obj_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_DAL.bSoloActivas = false;   // el admin ve todas; los combos filtran Activa === "True"
                obj_BLL.Listar_Carreras(ref obj_DAL);

                if (obj_DAL.dtDatos != null)
                    foreach (DataRow fila in obj_DAL.dtDatos.Rows)
                        lista.Add(FilaCarrera(fila));
            }
            catch (Exception) { }
            return lista;
        }

        /// <summary>Buscador. Parámetros: [0] InstitucionId · [1] IdUsuarioGlobal · [2] Texto</summary>
        [WebMethod]
        public static List<Dictionary<string, string>> FiltrarCarreras(List<string> obj_Parametros_JS)
        {
            List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();
            try
            {
                cls_Carreras_DAL obj_DAL = new cls_Carreras_DAL();
                cls_Carreras_BLL obj_BLL = new cls_Carreras_BLL();

                obj_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_DAL.sFiltro = obj_Parametros_JS[2];
                obj_BLL.Filtrar_Carreras(ref obj_DAL);

                if (obj_DAL.dtDatos != null)
                    foreach (DataRow fila in obj_DAL.dtDatos.Rows)
                        lista.Add(FilaCarrera(fila));
            }
            catch (Exception) { }
            return lista;
        }

        /// <summary>Una carrera para el modal de editar. Parámetros: [0] InstitucionId · [1] IdUsuarioGlobal · [2] CarreraId</summary>
        [WebMethod]
        public static List<Dictionary<string, string>> InfoCarrera(List<string> obj_Parametros_JS)
        {
            List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();
            try
            {
                cls_Carreras_DAL obj_DAL = new cls_Carreras_DAL();
                cls_Carreras_BLL obj_BLL = new cls_Carreras_BLL();

                obj_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_DAL.iCarreraId = Convert.ToInt32(obj_Parametros_JS[2]);
                obj_BLL.Info_Carrera(ref obj_DAL);

                if (obj_DAL.dtDatos != null)
                    foreach (DataRow fila in obj_DAL.dtDatos.Rows)
                        lista.Add(FilaCarrera(fila));
            }
            catch (Exception) { }
            return lista;
        }

        /// <summary>Crear. Parámetros: [0] InstitucionId · [1] IdUsuarioGlobal · [2] Nombre</summary>
        [WebMethod]
        public static string InsertarCarrera(List<string> obj_Parametros_JS)
        {
            try
            {
                cls_Carreras_DAL obj_DAL = new cls_Carreras_DAL();
                cls_Carreras_BLL obj_BLL = new cls_Carreras_BLL();

                obj_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[1]);
                obj_DAL.sNombre = obj_Parametros_JS[2];
                obj_DAL.sDireccionIp = HttpContext.Current.Request.UserHostAddress;

                obj_BLL.Insertar_Carrera(ref obj_DAL);

                if (obj_DAL.sValorScalar == null)
                    return "0<SPLITER>No se pudo conectar con la base de datos.";

                switch (obj_DAL.sValorScalar)
                {
                    case "-1": return "-1<SPLITER>Ya existe una carrera con ese nombre.";
                    case "-3": return "-3<SPLITER>No tienes permisos para realizar esta acción.";
                    case "-4": return "-4<SPLITER>El nombre de la carrera es obligatorio.";
                    case "0": return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
                    default: return obj_DAL.sValorScalar + "<SPLITER>La carrera se registró correctamente.";
                }
            }
            catch (Exception)
            {
                return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
            }
        }

        /// <summary>
        /// Editar o activar. Parámetros: [0] InstitucionId · [1] IdUsuarioGlobal · [2] CarreraId · [3] Nombre · [4] Activa ("true"/"false")
        /// Editar manda el estado que ya tenía; el botón Activar manda "true".
        /// </summary>
        [WebMethod]
        public static string ActualizarCarrera(List<string> obj_Parametros_JS)
        {
            try
            {
                cls_Carreras_DAL obj_DAL = new cls_Carreras_DAL();
                cls_Carreras_BLL obj_BLL = new cls_Carreras_BLL();

                obj_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[1]);
                obj_DAL.iCarreraId = Convert.ToInt32(obj_Parametros_JS[2]);
                obj_DAL.sNombre = obj_Parametros_JS[3];
                obj_DAL.bActiva = Convert.ToBoolean(obj_Parametros_JS[4]);
                obj_DAL.sDireccionIp = HttpContext.Current.Request.UserHostAddress;

                obj_BLL.Actualizar_Carrera(ref obj_DAL);

                if (obj_DAL.sValorScalar == null)
                    return "0<SPLITER>No se pudo conectar con la base de datos.";

                switch (obj_DAL.sValorScalar)
                {
                    case "-1": return "-1<SPLITER>Ya existe otra carrera con ese nombre.";
                    case "-2": return "-2<SPLITER>La carrera no fue encontrada.";
                    case "-3": return "-3<SPLITER>No tienes permisos para realizar esta acción.";
                    case "-4": return "-4<SPLITER>El nombre de la carrera es obligatorio.";
                    case "-6": return "-6<SPLITER>No se puede desactivar: tiene usuarios activos. Muévalos primero a otra carrera.";
                    case "0": return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
                    default: return obj_DAL.sValorScalar + "<SPLITER>La carrera se actualizó correctamente.";
                }
            }
            catch (Exception)
            {
                return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
            }
        }

        /// <summary>Desactivar. Parámetros: [0] InstitucionId · [1] IdUsuarioGlobal · [2] CarreraId</summary>
        [WebMethod]
        public static string EliminarCarrera(List<string> obj_Parametros_JS)
        {
            try
            {
                cls_Carreras_DAL obj_DAL = new cls_Carreras_DAL();
                cls_Carreras_BLL obj_BLL = new cls_Carreras_BLL();

                obj_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[1]);
                obj_DAL.iCarreraId = Convert.ToInt32(obj_Parametros_JS[2]);
                obj_DAL.sDireccionIp = HttpContext.Current.Request.UserHostAddress;

                obj_BLL.Eliminar_Carrera(ref obj_DAL);

                if (obj_DAL.sValorScalar == null)
                    return "0<SPLITER>No se pudo conectar con la base de datos.";

                switch (obj_DAL.sValorScalar)
                {
                    case "-2": return "-2<SPLITER>La carrera no fue encontrada.";
                    case "-3": return "-3<SPLITER>No tienes permisos para realizar esta acción.";
                    case "-6": return "-6<SPLITER>No se puede desactivar: tiene usuarios activos o ya está desactivada.";
                    case "0": return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
                    default: return obj_DAL.sValorScalar + "<SPLITER>La carrera se desactivó correctamente.";
                }
            }
            catch (Exception)
            {
                return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
            }
        }
    }
}
