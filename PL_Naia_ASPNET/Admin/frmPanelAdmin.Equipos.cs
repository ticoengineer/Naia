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
        // ==================== EQUIPOS DE SOPORTE ====================

        [WebMethod]
        public static List<Dictionary<string, string>> ListarEquiposTodos(List<string> obj_Parametros_JS)
        {
            List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();
            try
            {
                cls_Equipos_DAL obj_DAL = new cls_Equipos_DAL();
                cls_Equipos_BLL obj_BLL = new cls_Equipos_BLL();

                obj_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_BLL.Listar_Equipos(ref obj_DAL);

                if (obj_DAL.dtDatos != null)
                {
                    foreach (DataRow fila in obj_DAL.dtDatos.Rows)
                    {
                        lista.Add(new Dictionary<string, string>
                        {
                            { "EquipoId",       fila["EquipoId"].ToString() },
                            { "Equipo",         fila["Equipo"].ToString() },
                            { "Descripcion",    fila["Descripcion"] == DBNull.Value ? "" : fila["Descripcion"].ToString() },
                            { "Activo",         fila["Activo"].ToString() },
                            { "EstadoTexto",    fila["EstadoTexto"].ToString() },
                            { "TecnicosActivos",fila["TecnicosActivos"].ToString() }
                        });
                    }
                }
            }
            catch (Exception) { }
            return lista;
        }

        [WebMethod]
        public static List<Dictionary<string, string>> FiltrarEquipos(List<string> obj_Parametros_JS)
        {
            List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();
            try
            {
                cls_Equipos_DAL obj_DAL = new cls_Equipos_DAL();
                cls_Equipos_BLL obj_BLL = new cls_Equipos_BLL();

                obj_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_DAL.sFiltro = obj_Parametros_JS[2];
                obj_BLL.Filtrar_Equipos(ref obj_DAL);

                if (obj_DAL.dtDatos != null)
                {
                    foreach (DataRow fila in obj_DAL.dtDatos.Rows)
                    {
                        lista.Add(new Dictionary<string, string>
                        {
                            { "EquipoId",       fila["EquipoId"].ToString() },
                            { "Equipo",         fila["Equipo"].ToString() },
                            { "Descripcion",    fila["Descripcion"] == DBNull.Value ? "" : fila["Descripcion"].ToString() },
                            { "Activo",         fila["Activo"].ToString() },
                            { "EstadoTexto",    fila["EstadoTexto"].ToString() },
                            { "TecnicosActivos",fila["TecnicosActivos"].ToString() }
                        });
                    }
                }
            }
            catch (Exception) { }
            return lista;
        }

        [WebMethod]
        public static List<Dictionary<string, string>> InfoEquipo(List<string> obj_Parametros_JS)
        {
            List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();
            try
            {
                cls_Equipos_DAL obj_DAL = new cls_Equipos_DAL();
                cls_Equipos_BLL obj_BLL = new cls_Equipos_BLL();

                obj_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_DAL.iEquipoId = Convert.ToInt32(obj_Parametros_JS[2]);
                obj_BLL.Info_Equipo(ref obj_DAL);

                if (obj_DAL.dtDatos != null)
                {
                    foreach (DataRow fila in obj_DAL.dtDatos.Rows)
                    {
                        lista.Add(new Dictionary<string, string>
                        {
                            { "EquipoId",    fila["EquipoId"].ToString() },
                            { "Equipo",      fila["Equipo"].ToString() },
                            { "Descripcion", fila["Descripcion"] == DBNull.Value ? "" : fila["Descripcion"].ToString() },
                            { "Activo",      fila["Activo"].ToString() }
                        });
                    }
                }
            }
            catch (Exception) { }
            return lista;
        }

        [WebMethod]
        public static string InsertarEquipo(List<string> obj_Parametros_JS)
        {
            try
            {
                cls_Equipos_DAL obj_DAL = new cls_Equipos_DAL();
                cls_Equipos_BLL obj_BLL = new cls_Equipos_BLL();

                obj_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[1]);
                obj_DAL.sNombre = obj_Parametros_JS[2];
                obj_DAL.sDescripcion = string.IsNullOrEmpty(obj_Parametros_JS[3]) ? null : obj_Parametros_JS[3];
                obj_DAL.sDireccionIp = HttpContext.Current.Request.UserHostAddress;

                obj_BLL.Insertar_Equipo(ref obj_DAL);

                if (obj_DAL.sValorScalar == null)
                    return "0<SPLITER>No se pudo conectar con la base de datos.";

                switch (obj_DAL.sValorScalar)
                {
                    case "-1": return "-1<SPLITER>Ya existe un equipo con ese nombre.";
                    case "-3": return "-3<SPLITER>No tienes permisos para realizar esta accion.";
                    case "-4": return "-4<SPLITER>El nombre es obligatorio.";
                    case "0": return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
                    default:
                        return obj_DAL.sValorScalar + "<SPLITER>El equipo se registro correctamente.";
                }
            }
            catch (Exception)
            {
                return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
            }
        }

        [WebMethod]
        public static string ActualizarEquipo(List<string> obj_Parametros_JS)
        {
            try
            {
                cls_Equipos_DAL obj_DAL = new cls_Equipos_DAL();
                cls_Equipos_BLL obj_BLL = new cls_Equipos_BLL();

                obj_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[1]);
                obj_DAL.iEquipoId = Convert.ToInt32(obj_Parametros_JS[2]);
                obj_DAL.sNombre = obj_Parametros_JS[3];
                obj_DAL.sDescripcion = string.IsNullOrEmpty(obj_Parametros_JS[4]) ? null : obj_Parametros_JS[4];
                obj_DAL.bActivo = Convert.ToBoolean(obj_Parametros_JS[5]);
                obj_DAL.sDireccionIp = HttpContext.Current.Request.UserHostAddress;

                obj_BLL.Actualizar_Equipo(ref obj_DAL);

                if (obj_DAL.sValorScalar == null)
                    return "0<SPLITER>No se pudo conectar con la base de datos.";

                switch (obj_DAL.sValorScalar)
                {
                    case "-1": return "-1<SPLITER>Ya existe otro equipo con ese nombre.";
                    case "-2": return "-2<SPLITER>El equipo no fue encontrado.";
                    case "-3": return "-3<SPLITER>No tienes permisos para realizar esta acción.";
                    case "-4": return "-4<SPLITER>El nombre del equipo es obligatorio.";
                    case "-6": return "-6<SPLITER>No se puede desactivar: tiene técnicos activos o categorías que lo usan.";
                    case "0": return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
                    default:
                        return obj_DAL.sValorScalar + "<SPLITER>El equipo se actualizo correctamente.";
                }
            }
            catch (Exception)
            {
                return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
            }
        }

        [WebMethod]
        public static string EliminarEquipo(List<string> obj_Parametros_JS)
        {
            try
            {
                cls_Equipos_DAL obj_DAL = new cls_Equipos_DAL();
                cls_Equipos_BLL obj_BLL = new cls_Equipos_BLL();

                obj_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[1]);
                obj_DAL.iEquipoId = Convert.ToInt32(obj_Parametros_JS[2]);
                obj_DAL.sDireccionIp = HttpContext.Current.Request.UserHostAddress;

                obj_BLL.Eliminar_Equipo(ref obj_DAL);

                if (obj_DAL.sValorScalar == null)
                    return "0<SPLITER>No se pudo conectar con la base de datos.";

                switch (obj_DAL.sValorScalar)
                {
                    case "-2": return "-2<SPLITER>El equipo no fue encontrado.";
                    case "-3": return "-3<SPLITER>No tienes permisos para realizar esta acción.";
                    case "-6": return "-6<SPLITER>No se puede desactivar: tiene técnicos activos o categorías que lo usan.";
                    case "0": return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
                    default:
                        return obj_DAL.sValorScalar + "<SPLITER>El equipo se desactivó correctamente.";
                }
            }
            catch (Exception)
            {
                return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
            }
        }
    }
}
