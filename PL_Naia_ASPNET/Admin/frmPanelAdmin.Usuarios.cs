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
        // ==================== USUARIOS ====================

        [WebMethod]
        public static List<Dictionary<string, string>> ListarUsuarios(List<string> obj_Parametros_JS)
        {
            List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();
            try
            {
                cls_Usuarios_DAL obj_DAL = new cls_Usuarios_DAL();
                cls_Usuarios_BLL obj_BLL = new cls_Usuarios_BLL();

                obj_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_BLL.Listar_Usuarios(ref obj_DAL);

				if (!string.IsNullOrEmpty(obj_DAL.sMSJError))
					throw new Exception(obj_DAL.sMSJError);

				if (obj_DAL.dtDatos != null)
                {
                    foreach (DataRow fila in obj_DAL.dtDatos.Rows)
                    {
                        lista.Add(new Dictionary<string, string>
                        {
                            { "UsuarioId",         fila["UsuarioId"].ToString() },
                            { "RolId",             fila["RolId"].ToString() },
                            { "Rol",               fila["Rol"].ToString() },
                            { "NombreCompleto",    fila["NombreCompleto"].ToString() },
                            { "Correo",            fila["Correo"].ToString() },
                            { "NumeroInterno",     fila["NumeroInterno"].ToString() },
                            { "Carrera",           fila["Carrera"] == DBNull.Value ? "" : fila["Carrera"].ToString() },
                            { "Departamento",      fila["Departamento"] == DBNull.Value ? "" : fila["Departamento"].ToString() },
                            { "Equipo",            fila["Equipo"] == DBNull.Value ? "" : fila["Equipo"].ToString() },
                            { "Activo",            fila["Activo"].ToString() }
                        });
                    }
                }
            }
			catch (Exception)
			{
				// No se traga el error: ASP.NET responde HTTP 500 y el JS (callback "error")
				// muestra "Error al cargar". Una lista vacía significaría "no hay usuarios".
				throw;
			}

			return lista;
        }

        [WebMethod]
        public static List<Dictionary<string, string>> FiltrarUsuarios(List<string> obj_Parametros_JS)
        {
            List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();
            try
            {
                cls_Usuarios_DAL obj_DAL = new cls_Usuarios_DAL();
                cls_Usuarios_BLL obj_BLL = new cls_Usuarios_BLL();

                obj_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_DAL.sFiltro = obj_Parametros_JS[2];
                obj_BLL.Filtrar_Usuarios(ref obj_DAL);

				if (!string.IsNullOrEmpty(obj_DAL.sMSJError))
					throw new Exception(obj_DAL.sMSJError);

				if (obj_DAL.dtDatos != null)
                {
                    foreach (DataRow fila in obj_DAL.dtDatos.Rows)
                    {
                        lista.Add(new Dictionary<string, string>
                        {
                            { "UsuarioId",         fila["UsuarioId"].ToString() },
                            { "RolId",             fila["RolId"].ToString() },
                            { "Rol",               fila["Rol"].ToString() },
                            { "NombreCompleto",    fila["NombreCompleto"].ToString() },
                            { "Correo",            fila["Correo"].ToString() },
                            { "NumeroInterno",     fila["NumeroInterno"].ToString() },
                            { "Carrera",           fila["Carrera"] == DBNull.Value ? "" : fila["Carrera"].ToString() },
                            { "Departamento",      fila["Departamento"] == DBNull.Value ? "" : fila["Departamento"].ToString() },
                            { "Equipo",            fila["Equipo"] == DBNull.Value ? "" : fila["Equipo"].ToString() },
                            { "Activo",            fila["Activo"].ToString() }
                        });
                    }
                }
            }
			catch (Exception)
			{
				// No se traga el error: ASP.NET responde HTTP 500 y el JS (callback "error")
				// muestra "Error al cargar". Una lista vacía significaría "no hay usuarios".
				throw;
			}

			return lista;
        }

        [WebMethod]
        public static List<Dictionary<string, string>> InfoUsuario(List<string> obj_Parametros_JS)
        {
            List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();
            try
            {
                cls_Usuarios_DAL obj_DAL = new cls_Usuarios_DAL();
                cls_Usuarios_BLL obj_BLL = new cls_Usuarios_BLL();

                obj_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_DAL.iUsuarioId = Convert.ToInt32(obj_Parametros_JS[2]);
                obj_BLL.Info_Usuario(ref obj_DAL);

                if (obj_DAL.dtDatos != null)
                {
                    foreach (DataRow fila in obj_DAL.dtDatos.Rows)
                    {
                        lista.Add(new Dictionary<string, string>
                        {
                            { "UsuarioId",              fila["UsuarioId"].ToString() },
                            { "RolId",                  fila["RolId"].ToString() },
                            { "CarreraId",              fila["CarreraId"] == DBNull.Value ? "" : fila["CarreraId"].ToString() },
                            { "DepartamentoId",         fila["DepartamentoId"] == DBNull.Value ? "" : fila["DepartamentoId"].ToString() },
                            { "EquipoId",               fila["EquipoId"] == DBNull.Value ? "" : fila["EquipoId"].ToString() },
                            { "TipoIdentificacionId",   fila["TipoIdentificacionId"].ToString() },
                            { "Identificacion",         fila["Identificacion"].ToString() },
                            { "NumeroInterno",          fila["NumeroInterno"].ToString() },
                            { "Nombre",                 fila["Nombre"].ToString() },
                            { "Apellidos",              fila["Apellidos"].ToString() },
                            { "Correo",                 fila["Correo"].ToString() },
                            { "Activo",                 fila["Activo"].ToString() }
                        });
                    }
                }
            }
            catch (Exception) { }
            return lista;
        }

        [WebMethod]
        public static string InsertarUsuario(List<string> obj_Parametros_JS)
        {
            try
            {
                cls_Usuarios_DAL obj_DAL = new cls_Usuarios_DAL();
                cls_Usuarios_BLL obj_BLL = new cls_Usuarios_BLL();

                // [0]=InstitucionId, [1]=UsuarioGlobal, [2]=RolId, [3]=CarreraId, [4]=DepartamentoId,
                // [5]=EquipoId, [6]=TipoIdentificacionId, [7]=Identificacion, [8]=NumeroInterno,
                // [9]=Nombre, [10]=Apellidos, [11]=Correo, [12]=Contrasena
                obj_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[1]);
                obj_DAL.iRolId = Convert.ToInt32(obj_Parametros_JS[2]);
                obj_DAL.iCarreraId = string.IsNullOrEmpty(obj_Parametros_JS[3]) ? 0 : Convert.ToInt32(obj_Parametros_JS[3]);
                obj_DAL.iDepartamentoId = string.IsNullOrEmpty(obj_Parametros_JS[4]) ? 0 : Convert.ToInt32(obj_Parametros_JS[4]);
                obj_DAL.iEquipoId = string.IsNullOrEmpty(obj_Parametros_JS[5]) ? 0 : Convert.ToInt32(obj_Parametros_JS[5]);
                obj_DAL.iTipoIdentificacionId = Convert.ToInt32(obj_Parametros_JS[6]);
                obj_DAL.sIdentificacion = obj_Parametros_JS[7];
                obj_DAL.sNumeroInterno = obj_Parametros_JS[8];
                obj_DAL.sNombre = obj_Parametros_JS[9];
                obj_DAL.sApellidos = obj_Parametros_JS[10];
                obj_DAL.sCorreo = obj_Parametros_JS[11];
                obj_DAL.sContrasena = obj_Parametros_JS[12];
                obj_DAL.sDireccionIp = HttpContext.Current.Request.UserHostAddress;

                obj_BLL.Insertar_Usuario(ref obj_DAL);

                if (obj_DAL.sValorScalar == null)
                    return "0<SPLITER>No se pudo conectar con la base de datos.";

                switch (obj_DAL.sValorScalar)
                {
                    case "-1": return "-1<SPLITER>Ya existe un usuario con ese correo, identificacion o numero interno.";
                    case "-3": return "-3<SPLITER>No tienes permisos para crear usuarios.";
                    case "-4": return "-4<SPLITER>Hay campos obligatorios vacios o datos invalidos.";
                    case "-5": return "-5<SPLITER>Se alcanzo el limite de usuarios del plan.";
                    case "0":  return "0<SPLITER>Ocurrio un error inesperado. Intenta de nuevo.";
                    default:
                        return obj_DAL.sValorScalar + "<SPLITER>El usuario se registro correctamente.";
                }
            }
            catch (Exception)
            {
                return "0<SPLITER>Ocurrio un error inesperado. Intenta de nuevo.";
            }
        }

        [WebMethod]
        public static string ActualizarUsuario(List<string> obj_Parametros_JS)
        {
            try
            {
                cls_Usuarios_DAL obj_DAL = new cls_Usuarios_DAL();
                cls_Usuarios_BLL obj_BLL = new cls_Usuarios_BLL();

                // [0]=InstitucionId, [1]=UsuarioGlobal, [2]=UsuarioId, [3]=RolId, [4]=CarreraId,
                // [5]=DepartamentoId, [6]=EquipoId, [7]=TipoIdentificacionId, [8]=Identificacion,
                // [9]=NumeroInterno, [10]=Nombre, [11]=Apellidos, [12]=Correo, [13]=Contrasena, [14]=Activo
                obj_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[1]);
                obj_DAL.iUsuarioId = Convert.ToInt32(obj_Parametros_JS[2]);
                obj_DAL.iRolId = Convert.ToInt32(obj_Parametros_JS[3]);
                obj_DAL.iCarreraId = string.IsNullOrEmpty(obj_Parametros_JS[4]) ? 0 : Convert.ToInt32(obj_Parametros_JS[4]);
                obj_DAL.iDepartamentoId = string.IsNullOrEmpty(obj_Parametros_JS[5]) ? 0 : Convert.ToInt32(obj_Parametros_JS[5]);
                obj_DAL.iEquipoId = string.IsNullOrEmpty(obj_Parametros_JS[6]) ? 0 : Convert.ToInt32(obj_Parametros_JS[6]);
                obj_DAL.iTipoIdentificacionId = Convert.ToInt32(obj_Parametros_JS[7]);
                obj_DAL.sIdentificacion = obj_Parametros_JS[8];
                obj_DAL.sNumeroInterno = obj_Parametros_JS[9];
                obj_DAL.sNombre = obj_Parametros_JS[10];
                obj_DAL.sApellidos = obj_Parametros_JS[11];
                obj_DAL.sCorreo = obj_Parametros_JS[12];
                obj_DAL.sContrasena = string.IsNullOrEmpty(obj_Parametros_JS[13]) ? null : obj_Parametros_JS[13];
                obj_DAL.bActivo = Convert.ToBoolean(obj_Parametros_JS[14]);
                obj_DAL.sDireccionIp = HttpContext.Current.Request.UserHostAddress;

                obj_BLL.Actualizar_Usuario(ref obj_DAL);

                if (obj_DAL.sValorScalar == null)
                    return "0<SPLITER>No se pudo conectar con la base de datos.";

                switch (obj_DAL.sValorScalar)
                {
                    case "-1": return "-1<SPLITER>Ya existe un usuario con ese correo, identificacion o numero interno.";
                    case "-2": return "-2<SPLITER>El usuario no fue encontrado.";
                    case "-3": return "-3<SPLITER>No tienes permisos para modificar usuarios.";
                    case "-4": return "-4<SPLITER>Hay campos obligatorios vacios o datos invalidos.";
                    case "-5": return "-5<SPLITER>Se alcanzo el limite de usuarios del plan.";
                    case "-6": return "-6<SPLITER>No se puede realizar esa accion.";
                    case "0":  return "0<SPLITER>Ocurrio un error inesperado. Intenta de nuevo.";
                    default:
                        return obj_DAL.sValorScalar + "<SPLITER>El usuario se actualizo correctamente.";
                }
            }
            catch (Exception)
            {
                return "0<SPLITER>Ocurrio un error inesperado. Intenta de nuevo.";
            }
        }

        [WebMethod]
        public static string EliminarUsuario(List<string> obj_Parametros_JS)
        {
            try
            {
                cls_Usuarios_DAL obj_DAL = new cls_Usuarios_DAL();
                cls_Usuarios_BLL obj_BLL = new cls_Usuarios_BLL();

                obj_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[1]);
                obj_DAL.iUsuarioId = Convert.ToInt32(obj_Parametros_JS[2]);
                obj_DAL.sDireccionIp = HttpContext.Current.Request.UserHostAddress;

                obj_BLL.Eliminar_Usuario(ref obj_DAL);

                if (obj_DAL.sValorScalar == null)
                    return "0<SPLITER>No se pudo conectar con la base de datos.";

                switch (obj_DAL.sValorScalar)
                {
                    case "-2": return "-2<SPLITER>El usuario no fue encontrado.";
                    case "-3": return "-3<SPLITER>No tienes permisos para desactivar usuarios.";
                    case "-6": return "-6<SPLITER>No se puede desactivar este usuario.";
                    case "0":  return "0<SPLITER>Ocurrio un error inesperado. Intenta de nuevo.";
                    default:
                        return obj_DAL.sValorScalar + "<SPLITER>El usuario se desactivo correctamente.";
                }
            }
            catch (Exception)
            {
                return "0<SPLITER>Ocurrio un error inesperado. Intenta de nuevo.";
            }
        }

        // ==================== DROPDOWNS PARA FORMULARIO USUARIOS ====================

        [WebMethod]
        public static List<Dictionary<string, string>> ListarRoles(List<string> obj_Parametros_JS)
        {
            List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();
            try
            {
                cls_Catalogos_DAL obj_DAL = new cls_Catalogos_DAL();
                cls_Catalogos_BLL obj_BLL = new cls_Catalogos_BLL();

                obj_BLL.Listar_Roles(ref obj_DAL);

                if (obj_DAL.dtDatos != null)
                {
                    foreach (DataRow fila in obj_DAL.dtDatos.Rows)
                    {
                        lista.Add(new Dictionary<string, string>
                        {
                            { "RolId",               fila["RolId"].ToString() },
                            { "Rol",                 fila["Rol"].ToString() },
                            { "TipoNumeroInterno",   fila["TipoNumeroInterno"].ToString() }
                        });
                    }
                }
            }
            catch (Exception) { }
            return lista;
        }

        [WebMethod]
        public static List<Dictionary<string, string>> ListarTiposIdentificacion(List<string> obj_Parametros_JS)
        {
            List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();
            try
            {
                cls_Catalogos_DAL obj_DAL = new cls_Catalogos_DAL();
                cls_Catalogos_BLL obj_BLL = new cls_Catalogos_BLL();

                obj_BLL.Listar_TiposIdentificacion(ref obj_DAL);

                if (obj_DAL.dtDatos != null)
                {
                    foreach (DataRow fila in obj_DAL.dtDatos.Rows)
                    {
                        lista.Add(new Dictionary<string, string>
                        {
                            { "TipoIdentificacionId", fila["TipoIdentificacionId"].ToString() },
                            { "TipoIdentificacion",   fila["TipoIdentificacion"].ToString() }
                        });
                    }
                }
            }
            catch (Exception) { }
            return lista;
        }
    }
}
