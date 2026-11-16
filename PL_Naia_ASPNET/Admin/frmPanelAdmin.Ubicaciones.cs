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
    /// WebMethods de la seccion Ubicaciones del panel de administracion.
    /// Es partial class de frmPanelAdmin para que los metodos se expongan desde esa pagina.
    /// </summary>
    public partial class frmPanelAdmin : System.Web.UI.Page
    {
        // ==================== UBICACIONES ====================

        /// <summary>
        /// Trae todas las ubicaciones para mostrar en la tabla.
        /// Se pasa SoloActivas = false para que el admin vea todas (activas e inactivas).
        /// </summary>
        [WebMethod]
        public static List<Dictionary<string, string>> ListarUbicaciones(List<string> obj_Parametros_JS)
        {
            List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();

            try
            {
                cls_Ubicaciones_DAL obj_Ubicaciones_DAL = new cls_Ubicaciones_DAL();
                cls_Ubicaciones_BLL obj_Ubicaciones_BLL = new cls_Ubicaciones_BLL();

                // obj_Parametros_JS[0] = InstitucionId (viene de la cookie de sesion)
                obj_Ubicaciones_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_Ubicaciones_DAL.bSoloActivas = false; // el admin ve todas

                obj_Ubicaciones_BLL.Listar_Ubicaciones(ref obj_Ubicaciones_DAL);

                if (obj_Ubicaciones_DAL.dtDatos != null)
                {
                    foreach (DataRow fila in obj_Ubicaciones_DAL.dtDatos.Rows)
                    {
                        lista.Add(new Dictionary<string, string>
                        {
                            { "UbicacionId",    fila["UbicacionId"].ToString() },
                            { "Nombre",         fila["Nombre"].ToString() },
                            { "Edificio",       fila["Edificio"] == DBNull.Value ? "" : fila["Edificio"].ToString() },
                            { "EsFisica",       fila["EsFisica"].ToString() },
                            { "TipoTexto",      fila["TipoTexto"].ToString() },
                            { "UbicacionTexto", fila["UbicacionTexto"].ToString() },
                            { "Activa",         fila["Activa"].ToString() },
                            { "EstadoTexto",    fila["EstadoTexto"].ToString() }
                        });
                    }
                }
            }
            catch (Exception)
            {
                // Si falla, regresa la lista vacia
            }

            return lista;
        }

        /// <summary>
        /// Filtra ubicaciones segun lo que el usuario escriba en el buscador.
        /// </summary>
        [WebMethod]
        public static List<Dictionary<string, string>> FiltrarUbicaciones(List<string> obj_Parametros_JS)
        {
            List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();

            try
            {
                cls_Ubicaciones_DAL obj_Ubicaciones_DAL = new cls_Ubicaciones_DAL();
                cls_Ubicaciones_BLL obj_Ubicaciones_BLL = new cls_Ubicaciones_BLL();

                // [0] = InstitucionId, [1] = UsuarioId (no se usa aqui), [2] = texto de busqueda
                obj_Ubicaciones_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_Ubicaciones_DAL.sFiltro = obj_Parametros_JS[2];

                obj_Ubicaciones_BLL.Filtrar_Ubicaciones(ref obj_Ubicaciones_DAL);

                if (obj_Ubicaciones_DAL.dtDatos != null)
                {
                    foreach (DataRow fila in obj_Ubicaciones_DAL.dtDatos.Rows)
                    {
                        lista.Add(new Dictionary<string, string>
                        {
                            { "UbicacionId",    fila["UbicacionId"].ToString() },
                            { "Nombre",         fila["Nombre"].ToString() },
                            { "Edificio",       fila["Edificio"] == DBNull.Value ? "" : fila["Edificio"].ToString() },
                            { "EsFisica",       fila["EsFisica"].ToString() },
                            { "TipoTexto",      fila["TipoTexto"].ToString() },
                            { "UbicacionTexto", fila["UbicacionTexto"].ToString() },
                            { "Activa",         fila["Activa"].ToString() },
                            { "EstadoTexto",    fila["EstadoTexto"].ToString() }
                        });
                    }
                }
            }
            catch (Exception)
            {
                // Si falla, regresa la lista vacia
            }

            return lista;
        }

        /// <summary>
        /// Trae la info de una ubicacion especifica para llenar el formulario de edicion.
        /// </summary>
        [WebMethod]
        public static List<Dictionary<string, string>> InfoUbicacion(List<string> obj_Parametros_JS)
        {
            List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();

            try
            {
                cls_Ubicaciones_DAL obj_Ubicaciones_DAL = new cls_Ubicaciones_DAL();
                cls_Ubicaciones_BLL obj_Ubicaciones_BLL = new cls_Ubicaciones_BLL();

                // [0] = InstitucionId, [1] = UsuarioId, [2] = UbicacionId
                obj_Ubicaciones_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_Ubicaciones_DAL.iUbicacionId = Convert.ToInt32(obj_Parametros_JS[2]);

                obj_Ubicaciones_BLL.Info_Ubicacion(ref obj_Ubicaciones_DAL);

                if (obj_Ubicaciones_DAL.dtDatos != null)
                {
                    foreach (DataRow fila in obj_Ubicaciones_DAL.dtDatos.Rows)
                    {
                        lista.Add(new Dictionary<string, string>
                        {
                            { "UbicacionId", fila["UbicacionId"].ToString() },
                            { "Nombre",      fila["Nombre"].ToString() },
                            { "Edificio",    fila["Edificio"] == DBNull.Value ? "" : fila["Edificio"].ToString() },
                            { "EsFisica",    fila["EsFisica"].ToString() },
                            { "Activa",      fila["Activa"].ToString() }
                        });
                    }
                }
            }
            catch (Exception)
            {
                // Si falla, regresa la lista vacia
            }

            return lista;
        }

        /// <summary>
        /// Registra una nueva ubicacion (fisica o virtual).
        /// </summary>
        [WebMethod]
        public static string InsertarUbicacion(List<string> obj_Parametros_JS)
        {
            try
            {
                cls_Ubicaciones_DAL obj_Ubicaciones_DAL = new cls_Ubicaciones_DAL();
                cls_Ubicaciones_BLL obj_Ubicaciones_BLL = new cls_Ubicaciones_BLL();

                // Mapear parametros del JS (mismo orden que en Ubicaciones.js)
                // [0] = InstitucionId, [1] = UsuarioId, [2] = Nombre, [3] = Edificio, [4] = EsFisica
                obj_Ubicaciones_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_Ubicaciones_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[1]);
                obj_Ubicaciones_DAL.sNombre = obj_Parametros_JS[2];
                obj_Ubicaciones_DAL.sEdificio = string.IsNullOrEmpty(obj_Parametros_JS[3]) ? null : obj_Parametros_JS[3];
                obj_Ubicaciones_DAL.bEsFisica = Convert.ToBoolean(obj_Parametros_JS[4]);
                obj_Ubicaciones_DAL.sDireccionIp = HttpContext.Current.Request.UserHostAddress;

                obj_Ubicaciones_BLL.Insertar_Ubicacion(ref obj_Ubicaciones_DAL);

                // Traducir el codigo del SP a un mensaje para el usuario
                if (obj_Ubicaciones_DAL.sValorScalar == null)
                    return "0<SPLITER>No se pudo conectar con la base de datos.";

                switch (obj_Ubicaciones_DAL.sValorScalar)
                {
                    case "-1": return "-1<SPLITER>Ya existe una ubicación con ese nombre en ese edificio.";
                    case "-3": return "-3<SPLITER>No tienes permisos para realizar esta acción.";
                    case "-4": return "-4<SPLITER>Revisa los datos: las ubicaciones físicas deben tener edificio.";
                    case "0":  return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
                    default:
                        return obj_Ubicaciones_DAL.sValorScalar +
                               "<SPLITER>La ubicación se registró correctamente.";
                }
            }
            catch (Exception)
            {
                return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
            }
        }

        /// <summary>
        /// Actualiza los datos de una ubicacion existente.
        /// </summary>
        [WebMethod]
        public static string ActualizarUbicacion(List<string> obj_Parametros_JS)
        {
            try
            {
                cls_Ubicaciones_DAL obj_Ubicaciones_DAL = new cls_Ubicaciones_DAL();
                cls_Ubicaciones_BLL obj_Ubicaciones_BLL = new cls_Ubicaciones_BLL();

                // [0] = InstitucionId, [1] = UsuarioId, [2] = UbicacionId,
                // [3] = Nombre, [4] = Edificio, [5] = EsFisica, [6] = Activa
                obj_Ubicaciones_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_Ubicaciones_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[1]);
                obj_Ubicaciones_DAL.iUbicacionId = Convert.ToInt32(obj_Parametros_JS[2]);
                obj_Ubicaciones_DAL.sNombre = obj_Parametros_JS[3];
                obj_Ubicaciones_DAL.sEdificio = string.IsNullOrEmpty(obj_Parametros_JS[4]) ? null : obj_Parametros_JS[4];
                obj_Ubicaciones_DAL.bEsFisica = Convert.ToBoolean(obj_Parametros_JS[5]);
                obj_Ubicaciones_DAL.bActiva = Convert.ToBoolean(obj_Parametros_JS[6]);
                obj_Ubicaciones_DAL.sDireccionIp = HttpContext.Current.Request.UserHostAddress;

                obj_Ubicaciones_BLL.Actualizar_Ubicacion(ref obj_Ubicaciones_DAL);

                if (obj_Ubicaciones_DAL.sValorScalar == null)
                    return "0<SPLITER>No se pudo conectar con la base de datos.";

                switch (obj_Ubicaciones_DAL.sValorScalar)
                {
                    case "-1": return "-1<SPLITER>Ya existe otra ubicación con ese nombre en ese edificio.";
                    case "-2": return "-2<SPLITER>La ubicación no fue encontrada.";
                    case "-3": return "-3<SPLITER>No tienes permisos para realizar esta acción.";
                    case "-4": return "-4<SPLITER>Revisa los datos: las ubicaciones físicas deben tener edificio.";
                    case "0":  return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
                    default:
                        return obj_Ubicaciones_DAL.sValorScalar +
                               "<SPLITER>La ubicación se actualizó correctamente.";
                }
            }
            catch (Exception)
            {
                return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
            }
        }

        /// <summary>
        /// Desactiva (elimina logicamente) una ubicacion.
        /// </summary>
        [WebMethod]
        public static string EliminarUbicacion(List<string> obj_Parametros_JS)
        {
            try
            {
                cls_Ubicaciones_DAL obj_Ubicaciones_DAL = new cls_Ubicaciones_DAL();
                cls_Ubicaciones_BLL obj_Ubicaciones_BLL = new cls_Ubicaciones_BLL();

                // [0] = InstitucionId, [1] = UsuarioId, [2] = UbicacionId
                obj_Ubicaciones_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_Ubicaciones_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[1]);
                obj_Ubicaciones_DAL.iUbicacionId = Convert.ToInt32(obj_Parametros_JS[2]);
                obj_Ubicaciones_DAL.sDireccionIp = HttpContext.Current.Request.UserHostAddress;

                obj_Ubicaciones_BLL.Eliminar_Ubicacion(ref obj_Ubicaciones_DAL);

                if (obj_Ubicaciones_DAL.sValorScalar == null)
                    return "0<SPLITER>No se pudo conectar con la base de datos.";

                switch (obj_Ubicaciones_DAL.sValorScalar)
                {
                    case "-2": return "-2<SPLITER>La ubicación no fue encontrada.";
                    case "-3": return "-3<SPLITER>No tienes permisos para realizar esta acción.";
                    case "-6": return "-6<SPLITER>La ubicación ya está desactivada.";
                    case "0":  return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
                    default:
                        return obj_Ubicaciones_DAL.sValorScalar +
                               "<SPLITER>La ubicación se desactivó correctamente.";
                }
            }
            catch (Exception)
            {
                return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
            }
        }
    }
}
