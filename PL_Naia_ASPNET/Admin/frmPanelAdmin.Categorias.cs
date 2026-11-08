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
    /// WebMethods de la seccion Categorias del panel de administracion.
    /// Es partial class de frmPanelAdmin (misma clase que Ubicaciones, pero en otro archivo).
    /// </summary>
    public partial class frmPanelAdmin : System.Web.UI.Page
    {
        // ==================== CATEGORIAS ====================

        /// <summary>
        /// Trae todas las categorias para la tabla del admin.
        /// </summary>
        [WebMethod]
        public static List<Dictionary<string, string>> ListarCategorias(List<string> obj_Parametros_JS)
        {
            List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();

            try
            {
                cls_Categorias_DAL obj_Categorias_DAL = new cls_Categorias_DAL();
                cls_Categorias_BLL obj_Categorias_BLL = new cls_Categorias_BLL();

                // [0] = InstitucionId
                obj_Categorias_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_Categorias_DAL.bSoloActivas = false; // el admin ve activas e inactivas

                obj_Categorias_BLL.Listar_Categorias(ref obj_Categorias_DAL);

                if (obj_Categorias_DAL.dtDatos != null)
                {
                    foreach (DataRow fila in obj_Categorias_DAL.dtDatos.Rows)
                    {
                        lista.Add(new Dictionary<string, string>
                        {
                            { "CategoriaId",             fila["CategoriaId"].ToString() },
                            { "Categoria",               fila["Categoria"].ToString() },
                            { "Descripcion",             fila["Descripcion"] == DBNull.Value ? "" : fila["Descripcion"].ToString() },
                            { "ColorHex",                fila["ColorHex"].ToString() },
                            { "PrioridadInicialId",      fila["PrioridadInicialId"].ToString() },
                            { "PrioridadInicial",        fila["PrioridadInicial"].ToString() },
                            { "PrioridadColor",          fila["PrioridadColor"].ToString() },
                            { "EquipoPredeterminadoId",  fila["EquipoPredeterminadoId"] == DBNull.Value ? "" : fila["EquipoPredeterminadoId"].ToString() },
                            { "EquipoPredeterminado",    fila["EquipoPredeterminado"] == DBNull.Value ? "Sin asignar" : fila["EquipoPredeterminado"].ToString() },
                            { "RequiereUbicacionFisica", fila["RequiereUbicacionFisica"].ToString() },
                            { "Activa",                  fila["Activa"].ToString() },
                            { "EstadoTexto",             fila["EstadoTexto"].ToString() }
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
        /// Filtra categorias segun el texto del buscador.
        /// </summary>
        [WebMethod]
        public static List<Dictionary<string, string>> FiltrarCategorias(List<string> obj_Parametros_JS)
        {
            List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();

            try
            {
                cls_Categorias_DAL obj_Categorias_DAL = new cls_Categorias_DAL();
                cls_Categorias_BLL obj_Categorias_BLL = new cls_Categorias_BLL();

                // [0] = InstitucionId, [1] = UsuarioId (no se usa), [2] = texto de busqueda
                obj_Categorias_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_Categorias_DAL.sFiltro = obj_Parametros_JS[2];

                obj_Categorias_BLL.Filtrar_Categorias(ref obj_Categorias_DAL);

                if (obj_Categorias_DAL.dtDatos != null)
                {
                    foreach (DataRow fila in obj_Categorias_DAL.dtDatos.Rows)
                    {
                        lista.Add(new Dictionary<string, string>
                        {
                            { "CategoriaId",             fila["CategoriaId"].ToString() },
                            { "Categoria",               fila["Categoria"].ToString() },
                            { "Descripcion",             fila["Descripcion"] == DBNull.Value ? "" : fila["Descripcion"].ToString() },
                            { "ColorHex",                fila["ColorHex"].ToString() },
                            { "PrioridadInicialId",      fila["PrioridadInicialId"].ToString() },
                            { "PrioridadInicial",        fila["PrioridadInicial"].ToString() },
                            { "PrioridadColor",          fila["PrioridadColor"].ToString() },
                            { "EquipoPredeterminadoId",  fila["EquipoPredeterminadoId"] == DBNull.Value ? "" : fila["EquipoPredeterminadoId"].ToString() },
                            { "EquipoPredeterminado",    fila["EquipoPredeterminado"] == DBNull.Value ? "Sin asignar" : fila["EquipoPredeterminado"].ToString() },
                            { "RequiereUbicacionFisica", fila["RequiereUbicacionFisica"].ToString() },
                            { "Activa",                  fila["Activa"].ToString() },
                            { "EstadoTexto",             fila["EstadoTexto"].ToString() }
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
        /// Trae la info de una categoria para cargar en el modal de edicion.
        /// </summary>
        [WebMethod]
        public static List<Dictionary<string, string>> InfoCategoria(List<string> obj_Parametros_JS)
        {
            List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();

            try
            {
                cls_Categorias_DAL obj_Categorias_DAL = new cls_Categorias_DAL();
                cls_Categorias_BLL obj_Categorias_BLL = new cls_Categorias_BLL();

                // [0] = InstitucionId, [1] = UsuarioId, [2] = CategoriaId
                obj_Categorias_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_Categorias_DAL.iCategoriaId = Convert.ToInt32(obj_Parametros_JS[2]);

                obj_Categorias_BLL.Info_Categoria(ref obj_Categorias_DAL);

                if (obj_Categorias_DAL.dtDatos != null)
                {
                    foreach (DataRow fila in obj_Categorias_DAL.dtDatos.Rows)
                    {
                        lista.Add(new Dictionary<string, string>
                        {
                            { "CategoriaId",             fila["CategoriaId"].ToString() },
                            { "Categoria",               fila["Categoria"].ToString() },
                            { "Descripcion",             fila["Descripcion"] == DBNull.Value ? "" : fila["Descripcion"].ToString() },
                            { "ColorHex",                fila["ColorHex"].ToString() },
                            { "PrioridadInicialId",      fila["PrioridadInicialId"].ToString() },
                            { "EquipoPredeterminadoId",  fila["EquipoPredeterminadoId"] == DBNull.Value ? "" : fila["EquipoPredeterminadoId"].ToString() },
                            { "RequiereUbicacionFisica", fila["RequiereUbicacionFisica"].ToString() },
                            { "Activa",                  fila["Activa"].ToString() }
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
        /// Registra una nueva categoria de tiquete.
        /// </summary>
        [WebMethod]
        public static string InsertarCategoria(List<string> obj_Parametros_JS)
        {
            try
            {
                cls_Categorias_DAL obj_Categorias_DAL = new cls_Categorias_DAL();
                cls_Categorias_BLL obj_Categorias_BLL = new cls_Categorias_BLL();

                // [0] = InstitucionId, [1] = UsuarioId, [2] = Nombre, [3] = Descripcion,
                // [4] = ColorHex, [5] = PrioridadInicialId, [6] = EquipoPredeterminadoId, [7] = RequiereUbicacionFisica
                obj_Categorias_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_Categorias_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[1]);
                obj_Categorias_DAL.sNombre = obj_Parametros_JS[2];
                obj_Categorias_DAL.sDescripcion = string.IsNullOrEmpty(obj_Parametros_JS[3]) ? null : obj_Parametros_JS[3];
                obj_Categorias_DAL.sColorHex = obj_Parametros_JS[4];
                obj_Categorias_DAL.iPrioridadInicialId = Convert.ToInt32(obj_Parametros_JS[5]);

                // EquipoPredeterminadoId puede venir vacio si no se selecciono ningun equipo
                obj_Categorias_DAL.iEquipoPredeterminadoId = string.IsNullOrEmpty(obj_Parametros_JS[6])
                    ? (int?)null
                    : Convert.ToInt32(obj_Parametros_JS[6]);

                obj_Categorias_DAL.bRequiereUbicacionFisica = Convert.ToBoolean(obj_Parametros_JS[7]);
                obj_Categorias_DAL.sDireccionIp = HttpContext.Current.Request.UserHostAddress;

                obj_Categorias_BLL.Insertar_Categoria(ref obj_Categorias_DAL);

                if (obj_Categorias_DAL.sValorScalar == null)
                    return "0<SPLITER>No se pudo conectar con la base de datos.";

                switch (obj_Categorias_DAL.sValorScalar)
                {
                    case "-1": return "-1<SPLITER>Ya existe una categoría con ese nombre.";
                    case "-3": return "-3<SPLITER>No tienes permisos para realizar esta acción.";
                    case "-4": return "-4<SPLITER>Revisa los datos: el nombre y la prioridad son obligatorios.";
                    case "0":  return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
                    default:
                        return obj_Categorias_DAL.sValorScalar +
                               "<SPLITER>La categoría se registró correctamente.";
                }
            }
            catch (Exception)
            {
                return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
            }
        }

        /// <summary>
        /// Actualiza los datos de una categoria existente.
        /// </summary>
        [WebMethod]
        public static string ActualizarCategoria(List<string> obj_Parametros_JS)
        {
            try
            {
                cls_Categorias_DAL obj_Categorias_DAL = new cls_Categorias_DAL();
                cls_Categorias_BLL obj_Categorias_BLL = new cls_Categorias_BLL();

                // [0] = InstitucionId, [1] = UsuarioId, [2] = CategoriaId, [3] = Nombre,
                // [4] = Descripcion, [5] = ColorHex, [6] = PrioridadInicialId,
                // [7] = EquipoPredeterminadoId, [8] = RequiereUbicacionFisica, [9] = Activa
                obj_Categorias_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_Categorias_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[1]);
                obj_Categorias_DAL.iCategoriaId = Convert.ToInt32(obj_Parametros_JS[2]);
                obj_Categorias_DAL.sNombre = obj_Parametros_JS[3];
                obj_Categorias_DAL.sDescripcion = string.IsNullOrEmpty(obj_Parametros_JS[4]) ? null : obj_Parametros_JS[4];
                obj_Categorias_DAL.sColorHex = obj_Parametros_JS[5];
                obj_Categorias_DAL.iPrioridadInicialId = Convert.ToInt32(obj_Parametros_JS[6]);

                obj_Categorias_DAL.iEquipoPredeterminadoId = string.IsNullOrEmpty(obj_Parametros_JS[7])
                    ? (int?)null
                    : Convert.ToInt32(obj_Parametros_JS[7]);

                obj_Categorias_DAL.bRequiereUbicacionFisica = Convert.ToBoolean(obj_Parametros_JS[8]);
                obj_Categorias_DAL.bActiva = Convert.ToBoolean(obj_Parametros_JS[9]);
                obj_Categorias_DAL.sDireccionIp = HttpContext.Current.Request.UserHostAddress;

                obj_Categorias_BLL.Actualizar_Categoria(ref obj_Categorias_DAL);

                if (obj_Categorias_DAL.sValorScalar == null)
                    return "0<SPLITER>No se pudo conectar con la base de datos.";

                switch (obj_Categorias_DAL.sValorScalar)
                {
                    case "-1": return "-1<SPLITER>Ya existe otra categoría con ese nombre.";
                    case "-2": return "-2<SPLITER>La categoría no fue encontrada.";
                    case "-3": return "-3<SPLITER>No tienes permisos para realizar esta acción.";
                    case "-4": return "-4<SPLITER>Revisa los datos: el nombre y la prioridad son obligatorios.";
                    case "0":  return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
                    default:
                        return obj_Categorias_DAL.sValorScalar +
                               "<SPLITER>La categoría se actualizó correctamente.";
                }
            }
            catch (Exception)
            {
                return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
            }
        }

        /// <summary>
        /// Desactiva una categoria. No la borra, solo la oculta para nuevos tiquetes.
        /// </summary>
        [WebMethod]
        public static string EliminarCategoria(List<string> obj_Parametros_JS)
        {
            try
            {
                cls_Categorias_DAL obj_Categorias_DAL = new cls_Categorias_DAL();
                cls_Categorias_BLL obj_Categorias_BLL = new cls_Categorias_BLL();

                // [0] = InstitucionId, [1] = UsuarioId, [2] = CategoriaId
                obj_Categorias_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_Categorias_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[1]);
                obj_Categorias_DAL.iCategoriaId = Convert.ToInt32(obj_Parametros_JS[2]);
                obj_Categorias_DAL.sDireccionIp = HttpContext.Current.Request.UserHostAddress;

                obj_Categorias_BLL.Eliminar_Categoria(ref obj_Categorias_DAL);

                if (obj_Categorias_DAL.sValorScalar == null)
                    return "0<SPLITER>No se pudo conectar con la base de datos.";

                switch (obj_Categorias_DAL.sValorScalar)
                {
                    case "-2": return "-2<SPLITER>La categoría no fue encontrada.";
                    case "-3": return "-3<SPLITER>No tienes permisos para realizar esta acción.";
                    case "-6": return "-6<SPLITER>La categoría ya está desactivada.";
                    case "0":  return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
                    default:
                        return obj_Categorias_DAL.sValorScalar +
                               "<SPLITER>La categoría se desactivó correctamente.";
                }
            }
            catch (Exception)
            {
                return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
            }
        }

        // ==================== AUXILIARES PARA CATEGORIAS ====================

        /// <summary>
        /// Trae las prioridades para el dropdown del formulario de categorias.
        /// No necesita parametros de sesion porque las prioridades son globales.
        /// </summary>
        [WebMethod]
        public static List<Dictionary<string, string>> ListarPrioridades()
        {
            List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();

            try
            {
                cls_Categorias_DAL obj_Categorias_DAL = new cls_Categorias_DAL();
                cls_Categorias_BLL obj_Categorias_BLL = new cls_Categorias_BLL();

                obj_Categorias_BLL.Listar_Prioridades(ref obj_Categorias_DAL);

                if (obj_Categorias_DAL.dtDatos != null)
                {
                    foreach (DataRow fila in obj_Categorias_DAL.dtDatos.Rows)
                    {
                        lista.Add(new Dictionary<string, string>
                        {
                            { "PrioridadId", fila["PrioridadId"].ToString() },
                            { "Prioridad",   fila["Prioridad"].ToString() },
                            { "Nivel",       fila["Nivel"].ToString() },
                            { "SlaHoras",    fila["SlaHoras"].ToString() },
                            { "ColorHex",    fila["ColorHex"].ToString() }
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
        /// Trae los equipos de soporte para el dropdown del formulario de categorias.
        /// Solo trae los activos para que no se pueda asignar un equipo inactivo.
        /// </summary>
        [WebMethod]
        public static List<Dictionary<string, string>> ListarEquipos(List<string> obj_Parametros_JS)
        {
            List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();

            try
            {
                cls_Categorias_DAL obj_Categorias_DAL = new cls_Categorias_DAL();
                cls_Categorias_BLL obj_Categorias_BLL = new cls_Categorias_BLL();

                // [0] = InstitucionId
                obj_Categorias_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_Categorias_DAL.bSoloActivas = true; // solo equipos activos para el dropdown

                obj_Categorias_BLL.Listar_Equipos(ref obj_Categorias_DAL);

                if (obj_Categorias_DAL.dtDatos != null)
                {
                    foreach (DataRow fila in obj_Categorias_DAL.dtDatos.Rows)
                    {
                        lista.Add(new Dictionary<string, string>
                        {
                            { "EquipoId",    fila["EquipoId"].ToString() },
                            { "Equipo",      fila["Equipo"].ToString() },
                            { "Descripcion", fila["Descripcion"] == DBNull.Value ? "" : fila["Descripcion"].ToString() }
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
    }
}
