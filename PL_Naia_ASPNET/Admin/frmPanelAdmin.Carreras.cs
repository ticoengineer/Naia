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
        // ==================== CARRERAS ====================

        [WebMethod]
        public static List<Dictionary<string, string>> ListarCarreras(List<string> obj_Parametros_JS)
        {
            List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();
            try
            {
                cls_Carreras_DAL obj_DAL = new cls_Carreras_DAL();
                cls_Carreras_BLL obj_BLL = new cls_Carreras_BLL();

                obj_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_BLL.Listar_Carreras(ref obj_DAL);

                if (obj_DAL.dtDatos != null)
                {
                    foreach (DataRow fila in obj_DAL.dtDatos.Rows)
                    {
                        lista.Add(new Dictionary<string, string>
                        {
                            { "CarreraId",   fila["CarreraId"].ToString() },
                            { "Nombre",      fila["Nombre"].ToString() },
                            { "Codigo",      fila["Codigo"] == DBNull.Value ? "" : fila["Codigo"].ToString() },
                            { "Activa",      fila["Activa"].ToString() },
                            { "EstadoTexto", fila["EstadoTexto"].ToString() }
                        });
                    }
                }
            }
            catch (Exception) { }
            return lista;
        }

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
                {
                    foreach (DataRow fila in obj_DAL.dtDatos.Rows)
                    {
                        lista.Add(new Dictionary<string, string>
                        {
                            { "CarreraId",   fila["CarreraId"].ToString() },
                            { "Nombre",      fila["Nombre"].ToString() },
                            { "Codigo",      fila["Codigo"] == DBNull.Value ? "" : fila["Codigo"].ToString() },
                            { "Activa",      fila["Activa"].ToString() },
                            { "EstadoTexto", fila["EstadoTexto"].ToString() }
                        });
                    }
                }
            }
            catch (Exception) { }
            return lista;
        }

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
                {
                    foreach (DataRow fila in obj_DAL.dtDatos.Rows)
                    {
                        lista.Add(new Dictionary<string, string>
                        {
                            { "CarreraId", fila["CarreraId"].ToString() },
                            { "Nombre",    fila["Nombre"].ToString() },
                            { "Codigo",    fila["Codigo"] == DBNull.Value ? "" : fila["Codigo"].ToString() },
                            { "Activa",    fila["Activa"].ToString() }
                        });
                    }
                }
            }
            catch (Exception) { }
            return lista;
        }

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
                obj_DAL.sCodigo = string.IsNullOrEmpty(obj_Parametros_JS[3]) ? null : obj_Parametros_JS[3];
                obj_DAL.sDireccionIp = HttpContext.Current.Request.UserHostAddress;

                obj_BLL.Insertar_Carrera(ref obj_DAL);

                if (obj_DAL.sValorScalar == null)
                    return "0<SPLITER>No se pudo conectar con la base de datos.";

                switch (obj_DAL.sValorScalar)
                {
                    case "-1": return "-1<SPLITER>Ya existe una carrera con ese nombre.";
                    case "-3": return "-3<SPLITER>No tienes permisos para realizar esta accion.";
                    case "0":  return "0<SPLITER>Ocurrio un error inesperado. Intenta de nuevo.";
                    default:
                        return obj_DAL.sValorScalar + "<SPLITER>La carrera se registro correctamente.";
                }
            }
            catch (Exception)
            {
                return "0<SPLITER>Ocurrio un error inesperado. Intenta de nuevo.";
            }
        }

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
                obj_DAL.sCodigo = string.IsNullOrEmpty(obj_Parametros_JS[4]) ? null : obj_Parametros_JS[4];
                obj_DAL.bActiva = Convert.ToBoolean(obj_Parametros_JS[5]);
                obj_DAL.sDireccionIp = HttpContext.Current.Request.UserHostAddress;

                obj_BLL.Actualizar_Carrera(ref obj_DAL);

                if (obj_DAL.sValorScalar == null)
                    return "0<SPLITER>No se pudo conectar con la base de datos.";

                switch (obj_DAL.sValorScalar)
                {
                    case "-1": return "-1<SPLITER>Ya existe otra carrera con ese nombre.";
                    case "-2": return "-2<SPLITER>La carrera no fue encontrada.";
                    case "-3": return "-3<SPLITER>No tienes permisos para realizar esta accion.";
                    case "0":  return "0<SPLITER>Ocurrio un error inesperado. Intenta de nuevo.";
                    default:
                        return obj_DAL.sValorScalar + "<SPLITER>La carrera se actualizo correctamente.";
                }
            }
            catch (Exception)
            {
                return "0<SPLITER>Ocurrio un error inesperado. Intenta de nuevo.";
            }
        }

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
                    case "-3": return "-3<SPLITER>No tienes permisos para realizar esta accion.";
                    case "-5": return "-5<SPLITER>No se puede desactivar: hay departamentos activos en esta carrera.";
                    case "-6": return "-6<SPLITER>La carrera ya esta desactivada.";
                    case "0":  return "0<SPLITER>Ocurrio un error inesperado. Intenta de nuevo.";
                    default:
                        return obj_DAL.sValorScalar + "<SPLITER>La carrera se desactivo correctamente.";
                }
            }
            catch (Exception)
            {
                return "0<SPLITER>Ocurrio un error inesperado. Intenta de nuevo.";
            }
        }
    }
}
