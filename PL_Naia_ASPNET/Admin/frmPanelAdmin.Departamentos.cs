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
        // ==================== DEPARTAMENTOS ====================

        [WebMethod]
        public static List<Dictionary<string, string>> ListarDepartamentos(List<string> obj_Parametros_JS)
        {
            List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();
            try
            {
                cls_Departamentos_DAL obj_DAL = new cls_Departamentos_DAL();
                cls_Departamentos_BLL obj_BLL = new cls_Departamentos_BLL();
                obj_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_BLL.Listar_Departamentos(ref obj_DAL);

                if (obj_DAL.dtDatos != null)
                {
                    foreach (DataRow fila in obj_DAL.dtDatos.Rows)
                    {
                        lista.Add(new Dictionary<string, string>
                        {
                            { "DepartamentoId", fila["DepartamentoId"].ToString() },
                            { "Nombre",         fila["Nombre"].ToString() },
                            { "Codigo",         fila["Codigo"] == DBNull.Value ? "" : fila["Codigo"].ToString() },
                            { "CarreraNombre",  fila["CarreraNombre"].ToString() },
                            { "Activo",         fila["Activo"].ToString() },
                            { "EstadoTexto",    fila["EstadoTexto"].ToString() }
                        });
                    }
                }
            }
            catch (Exception) { }
            return lista;
        }

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
                {
                    foreach (DataRow fila in obj_DAL.dtDatos.Rows)
                    {
                        lista.Add(new Dictionary<string, string>
                        {
                            { "DepartamentoId", fila["DepartamentoId"].ToString() },
                            { "Nombre",         fila["Nombre"].ToString() },
                            { "Codigo",         fila["Codigo"] == DBNull.Value ? "" : fila["Codigo"].ToString() },
                            { "CarreraNombre",  fila["CarreraNombre"].ToString() },
                            { "Activo",         fila["Activo"].ToString() },
                            { "EstadoTexto",    fila["EstadoTexto"].ToString() }
                        });
                    }
                }
            }
            catch (Exception) { }
            return lista;
        }

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
                {
                    foreach (DataRow fila in obj_DAL.dtDatos.Rows)
                    {
                        lista.Add(new Dictionary<string, string>
                        {
                            { "DepartamentoId", fila["DepartamentoId"].ToString() },
                            { "Nombre",         fila["Nombre"].ToString() },
                            { "Codigo",         fila["Codigo"] == DBNull.Value ? "" : fila["Codigo"].ToString() },
                            { "CarreraId",      fila["CarreraId"].ToString() },
                            { "Activo",         fila["Activo"].ToString() }
                        });
                    }
                }
            }
            catch (Exception) { }
            return lista;
        }

        [WebMethod]
        public static string InsertarDepartamento(List<string> obj_Parametros_JS)
        {
            try
            {
                cls_Departamentos_DAL obj_DAL = new cls_Departamentos_DAL();
                cls_Departamentos_BLL obj_BLL = new cls_Departamentos_BLL();
                obj_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[1]);
                obj_DAL.iCarreraId = Convert.ToInt32(obj_Parametros_JS[2]);
                obj_DAL.sNombre = obj_Parametros_JS[3];
                obj_DAL.sCodigo = string.IsNullOrEmpty(obj_Parametros_JS[4]) ? null : obj_Parametros_JS[4];
                obj_DAL.sDireccionIp = HttpContext.Current.Request.UserHostAddress;
                obj_BLL.Insertar_Departamento(ref obj_DAL);

                if (obj_DAL.sValorScalar == null) return "0<SPLITER>No se pudo conectar con la base de datos.";
                switch (obj_DAL.sValorScalar)
                {
                    case "-1": return "-1<SPLITER>Ya existe un departamento con ese nombre en esa carrera.";
                    case "-3": return "-3<SPLITER>No tienes permisos para realizar esta accion.";
                    case "0":  return "0<SPLITER>Ocurrio un error inesperado. Intenta de nuevo.";
                    default: return obj_DAL.sValorScalar + "<SPLITER>El departamento se registro correctamente.";
                }
            }
            catch (Exception) { return "0<SPLITER>Ocurrio un error inesperado. Intenta de nuevo."; }
        }

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
                obj_DAL.iCarreraId = Convert.ToInt32(obj_Parametros_JS[3]);
                obj_DAL.sNombre = obj_Parametros_JS[4];
                obj_DAL.sCodigo = string.IsNullOrEmpty(obj_Parametros_JS[5]) ? null : obj_Parametros_JS[5];
                obj_DAL.bActivo = Convert.ToBoolean(obj_Parametros_JS[6]);
                obj_DAL.sDireccionIp = HttpContext.Current.Request.UserHostAddress;
                obj_BLL.Actualizar_Departamento(ref obj_DAL);

                if (obj_DAL.sValorScalar == null) return "0<SPLITER>No se pudo conectar con la base de datos.";
                switch (obj_DAL.sValorScalar)
                {
                    case "-1": return "-1<SPLITER>Ya existe otro departamento con ese nombre en esa carrera.";
                    case "-2": return "-2<SPLITER>El departamento no fue encontrado.";
                    case "-3": return "-3<SPLITER>No tienes permisos para realizar esta accion.";
                    case "0":  return "0<SPLITER>Ocurrio un error inesperado. Intenta de nuevo.";
                    default: return obj_DAL.sValorScalar + "<SPLITER>El departamento se actualizo correctamente.";
                }
            }
            catch (Exception) { return "0<SPLITER>Ocurrio un error inesperado. Intenta de nuevo."; }
        }

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

                if (obj_DAL.sValorScalar == null) return "0<SPLITER>No se pudo conectar con la base de datos.";
                switch (obj_DAL.sValorScalar)
                {
                    case "-2": return "-2<SPLITER>El departamento no fue encontrado.";
                    case "-3": return "-3<SPLITER>No tienes permisos para realizar esta accion.";
                    case "-5": return "-5<SPLITER>No se puede desactivar: hay equipos activos en este departamento.";
                    case "-6": return "-6<SPLITER>El departamento ya esta desactivado.";
                    case "0":  return "0<SPLITER>Ocurrio un error inesperado. Intenta de nuevo.";
                    default: return obj_DAL.sValorScalar + "<SPLITER>El departamento se desactivo correctamente.";
                }
            }
            catch (Exception) { return "0<SPLITER>Ocurrio un error inesperado. Intenta de nuevo."; }
        }
    }
}
