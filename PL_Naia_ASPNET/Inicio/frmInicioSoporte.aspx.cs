using BLL_Naia_ASPNET.Entidades;
using DAL_Naia_ASPNET.Entidades;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PL_Naia_ASPNET.Inicio
{
    /// <summary>
    /// Vista de soporte técnico (rol 3) y administrativo (rol 4).
    /// Los combos de categoría/ubicación y "Responder" reutilizan los WebMethods de frmInicioUsuario.aspx
    /// (son los mismos datos y el mismo SP), por eso no se repiten aquí.
    /// </summary>
    public partial class frmInicioSoporte : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        // =====================================================================================
        // TARJETAS DE ARRIBA
        // =====================================================================================

        /// <summary>
        /// Números de las tarjetas. Parámetros: [0] InstitucionId · [1] IdUsuarioGlobal
        /// </summary>
        [WebMethod]
        public static Dictionary<string, string> ResumenSoporte(List<string> obj_Parametros_JS)
        {
            Dictionary<string, string> resumen = new Dictionary<string, string>();

            try
            {
                cls_Tickets_DAL obj_Tickets_DAL = new cls_Tickets_DAL();
                cls_Tickets_BLL obj_Tickets_BLL = new cls_Tickets_BLL();

                obj_Tickets_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_Tickets_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[1]);

                obj_Tickets_BLL.Dashboard_Tickets(ref obj_Tickets_DAL);

                if (obj_Tickets_DAL.dtDatos != null && obj_Tickets_DAL.dtDatos.Rows.Count > 0)
                {
                    DataRow fila = obj_Tickets_DAL.dtDatos.Rows[0];
                    resumen.Add("SinAsignar", fila["SinAsignar"].ToString());
                    resumen.Add("AsignadosAMi", fila["AsignadosAMi"].ToString());
                    resumen.Add("VencenHoy", fila["VencenHoy"].ToString());
                    resumen.Add("Vencidos", fila["Vencidos"].ToString());
                }
            }
            catch (Exception)
            {
                /*Si falla se devuelve vacío; el JS deja las tarjetas en "–"*/
            }

            return resumen;
        }

        // =====================================================================================
        // BANDEJA (tabla)
        // =====================================================================================

        /// <summary>
        /// Lista de la tabla con filtros. Parámetros (mismo orden que InicioSoporte.js):
        /// [0] InstitucionId · [1] IdUsuarioGlobal · [2] Texto a buscar · [3] PrioridadId ("" = todas)
        /// [4] ResponsableId ("" = todos · "0" = sin asignar · Id = de esa persona)
        /// [5] SoloVencidos ("1"/"0") · [6] SoloAbiertos ("1"/"0")
        /// </summary>
        [WebMethod]
        public static List<Dictionary<string, string>> FiltrarTickets(List<string> obj_Parametros_JS)
        {
            List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();

            try
            {
                cls_Tickets_DAL obj_Tickets_DAL = new cls_Tickets_DAL();
                cls_Tickets_BLL obj_Tickets_BLL = new cls_Tickets_BLL();

                obj_Tickets_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_Tickets_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[1]);
                obj_Tickets_DAL.sFiltro = obj_Parametros_JS[2];
                obj_Tickets_DAL.iFiltroPrioridadId = EnteroONulo(obj_Parametros_JS[3]);
                obj_Tickets_DAL.iFiltroResponsableId = EnteroONulo(obj_Parametros_JS[4]);
                obj_Tickets_DAL.iFiltroEstadoId = null;
                obj_Tickets_DAL.iFiltroCategoriaId = null;
                obj_Tickets_DAL.bSoloVencidos = obj_Parametros_JS[5] == "1";
                obj_Tickets_DAL.bSoloAbiertos = obj_Parametros_JS[6] == "1";

                obj_Tickets_BLL.Filtrar_Tickets(ref obj_Tickets_DAL);

                if (obj_Tickets_DAL.dtDatos != null)
                {
                    foreach (DataRow fila in obj_Tickets_DAL.dtDatos.Rows)
                    {
                        lista.Add(new Dictionary<string, string>
                        {
                            { "TicketId",         fila["TicketId"].ToString() },
                            { "Numero",           fila["Numero"].ToString() },
                            { "Titulo",           fila["Titulo"].ToString() },
                            { "Categoria",        fila["Categoria"].ToString() },
                            { "PrioridadId",      fila["PrioridadId"].ToString() },
                            { "Prioridad",        fila["Prioridad"].ToString() },
                            { "EstadoId",         fila["EstadoId"].ToString() },
                            { "Estado",           fila["Estado"].ToString() },
                            { "Solicitante",      fila["Solicitante"].ToString() },
                            { "RolSolicitante",   fila["RolSolicitante"].ToString() },
                            { "ResponsableId",    fila["ResponsableId"] == DBNull.Value ? "" : fila["ResponsableId"].ToString() },
                            { "Responsable",      fila["Responsable"].ToString() },
                            { "FechaCreacion",    fila["FechaCreacionTexto"].ToString() },
                            { "MinutosRestantes", fila["MinutosRestantes"] == DBNull.Value ? "" : fila["MinutosRestantes"].ToString() }
                        });
                    }
                }
            }
            catch (Exception)
            {
                /*Si falla se devuelve la lista vacía; el JS muestra el mensaje*/
            }

            return lista;
        }

        // =====================================================================================
        // COMBOS DEL PANEL
        // =====================================================================================

        /// <summary>
        /// Combo "Prioridad" (filtro y panel). Las prioridades son globales: no lleva parámetros.
        /// Reutiliza cls_Categorias_BLL.Listar_Prioridades (la hizo Steven para Categorías).
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
                            { "SlaHoras",    fila["SlaHoras"].ToString() }
                        });
                    }
                }
            }
            catch (Exception)
            {
                /*Si falla se devuelve la lista vacía*/
            }

            return lista;
        }

        /// <summary>
        /// Combo "Responsable": técnicos y administrativos activos con su carga de trabajo.
        /// Parámetros: [0] InstitucionId
        /// </summary>
        [WebMethod]
        public static List<Dictionary<string, string>> ListarResponsables(List<string> obj_Parametros_JS)
        {
            List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();

            try
            {
                cls_Tickets_DAL obj_Tickets_DAL = new cls_Tickets_DAL();
                cls_Tickets_BLL obj_Tickets_BLL = new cls_Tickets_BLL();

                obj_Tickets_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_Tickets_DAL.iEquipoId = null;   // todos los equipos

                obj_Tickets_BLL.Listar_Responsables(ref obj_Tickets_DAL);

                if (obj_Tickets_DAL.dtDatos != null)
                {
                    foreach (DataRow fila in obj_Tickets_DAL.dtDatos.Rows)
                    {
                        lista.Add(new Dictionary<string, string>
                        {
                            { "UsuarioId",        fila["UsuarioId"].ToString() },
                            { "Nombre",           fila["NombreCompleto"].ToString() },
                            { "Equipo",           fila["Equipo"] == DBNull.Value ? "" : fila["Equipo"].ToString() },
                            { "TiquetesAbiertos", fila["TiquetesAbiertos"].ToString() }
                        });
                    }
                }
            }
            catch (Exception)
            {
                /*Si falla se devuelve la lista vacía*/
            }

            return lista;
        }

        // =====================================================================================
        // PANEL LATERAL
        // =====================================================================================

        /// <summary>
        /// Abre el panel. En UNA llamada devuelve Ticket, Comentarios y Acciones (botones de estado).
        /// Parámetros: [0] InstitucionId · [1] TicketId · [2] IdUsuarioGlobal
        /// </summary>
        [WebMethod]
        public static Dictionary<string, object> VerTicket(List<string> obj_Parametros_JS)
        {
            Dictionary<string, object> respuesta = new Dictionary<string, object>();

            try
            {
                cls_Tickets_DAL obj_Tickets_DAL = new cls_Tickets_DAL();
                cls_Tickets_BLL obj_Tickets_BLL = new cls_Tickets_BLL();

                obj_Tickets_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_Tickets_DAL.iTicketId = Convert.ToInt32(obj_Parametros_JS[1]);
                obj_Tickets_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[2]);

                /*1. Datos del tiquete*/
                obj_Tickets_BLL.Info_Ticket(ref obj_Tickets_DAL);

                if (obj_Tickets_DAL.dtDatos == null || obj_Tickets_DAL.dtDatos.Rows.Count == 0)
                    return respuesta;   // no existe o no tiene permiso

                DataRow t = obj_Tickets_DAL.dtDatos.Rows[0];
                respuesta.Add("Ticket", new Dictionary<string, string>
                {
                    { "TicketId",          t["TicketId"].ToString() },
                    { "Numero",            t["Numero"].ToString() },
                    { "Titulo",            t["Titulo"].ToString() },
                    { "Descripcion",       t["Descripcion"].ToString() },
                    { "CategoriaId",       t["CategoriaId"].ToString() },
                    { "Categoria",         t["Categoria"].ToString() },
                    { "UbicacionId",       t["UbicacionId"].ToString() },
                    { "Ubicacion",         t["Ubicacion"].ToString() },
                    { "PrioridadId",       t["PrioridadId"].ToString() },
                    { "Prioridad",         t["Prioridad"].ToString() },
                    { "SlaHoras",          t["SlaHoras"].ToString() },
                    { "MinutosRestantes",  t["MinutosRestantes"] == DBNull.Value ? "" : t["MinutosRestantes"].ToString() },
                    { "EstadoId",          t["EstadoId"].ToString() },
                    { "Estado",            t["Estado"].ToString() },
                    { "Solicitante",       t["Solicitante"].ToString() },
                    { "RolSolicitante",    t["RolSolicitante"].ToString() },
                    { "CorreoSolicitante", t["CorreoSolicitante"].ToString() },
                    { "ResponsableId",     t["ResponsableId"] == DBNull.Value ? "" : t["ResponsableId"].ToString() },
                    { "Solucion",          t["Solucion"] == DBNull.Value ? "" : t["Solucion"].ToString() },
                    { "FechaCreacion",     Convert.ToDateTime(t["FechaCreacion"]).ToString("dd/MM/yyyy HH:mm") },
                    { "PuedeEditar",       t["PuedeEditar"].ToString() },
                    { "PuedeAsignar",      t["PuedeAsignar"].ToString() },
                    { "PuedeComentar",     t["PuedeComentar"].ToString() }
                });

                /*2. Conversación*/
                List<Dictionary<string, string>> comentarios = new List<Dictionary<string, string>>();
                obj_Tickets_BLL.Listar_Comentarios(ref obj_Tickets_DAL);

                if (obj_Tickets_DAL.dtDatos != null)
                {
                    foreach (DataRow c in obj_Tickets_DAL.dtDatos.Rows)
                    {
                        comentarios.Add(new Dictionary<string, string>
                        {
                            { "Autor", c["Autor"].ToString() },
                            { "Rol",   c["RolAutor"].ToString() },
                            { "Texto", c["Texto"].ToString() },
                            { "Fecha", c["FechaTexto"].ToString() },
                            { "EsMio", Convert.ToInt32(c["UsuarioId"]) == obj_Tickets_DAL.iIdUsuarioGlobal ? "1" : "0" }
                        });
                    }
                }
                respuesta.Add("Comentarios", comentarios);

                /*3. Botones de estado que la BD permite a este usuario*/
                List<Dictionary<string, string>> acciones = new List<Dictionary<string, string>>();
                obj_Tickets_BLL.Listar_Transiciones(ref obj_Tickets_DAL);

                if (obj_Tickets_DAL.dtDatos != null)
                {
                    foreach (DataRow a in obj_Tickets_DAL.dtDatos.Rows)
                    {
                        acciones.Add(new Dictionary<string, string>
                        {
                            { "EstadoDestinoId",  a["EstadoDestinoId"].ToString() },
                            { "EstadoDestino",    a["EstadoDestino"].ToString() },
                            { "RequiereMotivo",   Convert.ToBoolean(a["RequiereMotivo"]) ? "1" : "0" },
                            { "RequiereSolucion", a["RequiereSolucion"].ToString() }
                        });
                    }
                }
                respuesta.Add("Acciones", acciones);
            }
            catch (Exception)
            {
                respuesta.Clear();   // el JS muestra el mensaje de error
            }

            return respuesta;
        }

        /// <summary>
        /// Botón "Tomar": se asigna el tiquete a quien hace clic. Queda en estado 2 Asignado.
        /// Parámetros: [0] InstitucionId · [1] TicketId · [2] IdUsuarioGlobal
        /// </summary>
        [WebMethod]
        public static string TomarTicket(List<string> obj_Parametros_JS)
        {
            try
            {
                cls_Tickets_DAL obj_Tickets_DAL = new cls_Tickets_DAL();
                cls_Tickets_BLL obj_Tickets_BLL = new cls_Tickets_BLL();

                obj_Tickets_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_Tickets_DAL.iTicketId = Convert.ToInt32(obj_Parametros_JS[1]);
                obj_Tickets_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[2]);
                obj_Tickets_DAL.iResponsableId = obj_Tickets_DAL.iIdUsuarioGlobal;   // me lo asigno a mí
                obj_Tickets_DAL.sMotivo = null;
                obj_Tickets_DAL.sDireccionIp = HttpContext.Current.Request.UserHostAddress;

                obj_Tickets_BLL.Asignar_Ticket(ref obj_Tickets_DAL);

                return MensajeAsignar(obj_Tickets_DAL.sValorScalar, "Listo, el tiquete ahora es tuyo.");
            }
            catch (Exception)
            {
                return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
            }
        }

        /// <summary>
        /// Botón "Guardar cambios" del panel derecho.
        /// Parámetros: [0] InstitucionId · [1] TicketId · [2] IdUsuarioGlobal · [3] CategoriaId · [4] PrioridadId
        ///             [5] UbicacionId · [6] ResponsableId ("" = no se toca) · [7] Motivo de la reasignación
        /// 1. Lee el tiquete actual (para mandar el título y la descripción tal cual y ver qué cambió).
        /// 2. Si cambió prioridad, categoría o ubicación → SP_ACTUALIZA_TICKETS.
        /// 3. Si cambió el responsable → SP_ASIGNA_TICKETS.
        /// </summary>
        [WebMethod]
        public static string GuardarCambiosTicket(List<string> obj_Parametros_JS)
        {
            try
            {
                cls_Tickets_DAL obj_Tickets_DAL = new cls_Tickets_DAL();
                cls_Tickets_BLL obj_Tickets_BLL = new cls_Tickets_BLL();

                obj_Tickets_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_Tickets_DAL.iTicketId = Convert.ToInt32(obj_Parametros_JS[1]);
                obj_Tickets_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[2]);
                obj_Tickets_DAL.sDireccionIp = HttpContext.Current.Request.UserHostAddress;

                int iCategoriaNueva = Convert.ToInt32(obj_Parametros_JS[3]);
                int iPrioridadNueva = Convert.ToInt32(obj_Parametros_JS[4]);
                int iUbicacionNueva = Convert.ToInt32(obj_Parametros_JS[5]);
                string sResponsableNuevo = obj_Parametros_JS[6];
                string sMotivo = obj_Parametros_JS[7];

                /*1. Cómo está el tiquete ahora*/
                obj_Tickets_BLL.Info_Ticket(ref obj_Tickets_DAL);

                if (obj_Tickets_DAL.dtDatos == null || obj_Tickets_DAL.dtDatos.Rows.Count == 0)
                    return "-2<SPLITER>El tiquete no existe o no tienes permiso para verlo.";

                DataRow t = obj_Tickets_DAL.dtDatos.Rows[0];
                bool bCambiaDatos = Convert.ToInt32(t["CategoriaId"]) != iCategoriaNueva
                                 || Convert.ToInt32(t["PrioridadId"]) != iPrioridadNueva
                                 || Convert.ToInt32(t["UbicacionId"]) != iUbicacionNueva;
                string sResponsableActual = t["ResponsableId"] == DBNull.Value ? "" : t["ResponsableId"].ToString();
                bool bCambiaResponsable = sResponsableNuevo != "" && sResponsableNuevo != sResponsableActual;

                if (!bCambiaDatos && !bCambiaResponsable)
                    return "0<SPLITER>No hiciste ningún cambio.";

                /*2. Prioridad, categoría y ubicación*/
                if (bCambiaDatos)
                {
                    obj_Tickets_DAL.sTitulo = t["Titulo"].ToString();
                    obj_Tickets_DAL.sDescripcion = t["Descripcion"].ToString();
                    obj_Tickets_DAL.iCategoriaId = iCategoriaNueva;
                    obj_Tickets_DAL.iPrioridadId = iPrioridadNueva;
                    obj_Tickets_DAL.iUbicacionId = iUbicacionNueva;

                    obj_Tickets_BLL.Actualizar_Ticket(ref obj_Tickets_DAL);

                    string sRespuesta = MensajeActualizar(obj_Tickets_DAL.sValorScalar);
                    if (!sRespuesta.StartsWith("OK"))
                        return sRespuesta;   // si esto falla, no se intenta reasignar
                }

                /*3. Responsable*/
                if (bCambiaResponsable)
                {
                    obj_Tickets_DAL.iResponsableId = Convert.ToInt32(sResponsableNuevo);
                    obj_Tickets_DAL.sMotivo = sMotivo;

                    obj_Tickets_BLL.Asignar_Ticket(ref obj_Tickets_DAL);

                    string sRespuesta = MensajeAsignar(obj_Tickets_DAL.sValorScalar, "Los cambios se guardaron.");
                    string[] partes = sRespuesta.Split(new[] { "<SPLITER>" }, StringSplitOptions.None);

                    if (bCambiaDatos && Convert.ToInt32(partes[0]) <= 0)
                    {
                        /*Los datos sí se guardaron, pero la reasignación no*/
                        return partes[0] + "<SPLITER>Se guardaron la prioridad, la categoría y la ubicación, pero no se pudo reasignar: " + partes[1];
                    }
                    return sRespuesta;
                }

                return obj_Tickets_DAL.iTicketId + "<SPLITER>Los cambios se guardaron.";
            }
            catch (Exception)
            {
                return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
            }
        }

        /// <summary>
        /// Cambia el estado (En progreso, En espera, Resuelto, Cancelado).
        /// Parámetros: [0] InstitucionId · [1] TicketId · [2] EstadoNuevoId · [3] Motivo · [4] IdUsuarioGlobal · [5] Solución
        /// </summary>
        [WebMethod]
        public static string CambiarEstadoTicket(List<string> obj_Parametros_JS)
        {
            try
            {
                cls_Tickets_DAL obj_Tickets_DAL = new cls_Tickets_DAL();
                cls_Tickets_BLL obj_Tickets_BLL = new cls_Tickets_BLL();

                obj_Tickets_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_Tickets_DAL.iTicketId = Convert.ToInt32(obj_Parametros_JS[1]);
                obj_Tickets_DAL.iEstadoNuevoId = Convert.ToInt32(obj_Parametros_JS[2]);
                obj_Tickets_DAL.sMotivo = obj_Parametros_JS[3];
                obj_Tickets_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[4]);
                obj_Tickets_DAL.sSolucion = obj_Parametros_JS[5];   // solo se usa al pasar a 5 Resuelto
                obj_Tickets_DAL.sDireccionIp = HttpContext.Current.Request.UserHostAddress;

                obj_Tickets_BLL.Cambiar_Estado(ref obj_Tickets_DAL);

                if (obj_Tickets_DAL.sValorScalar == null)
                    return "0<SPLITER>No se pudo conectar con la base de datos.";

                switch (obj_Tickets_DAL.sValorScalar)
                {
                    case "-2": return "-2<SPLITER>El tiquete no existe.";
                    case "-3": return "-3<SPLITER>No tienes permiso para hacer este cambio. Solo el responsable del tiquete puede cambiarle el estado.";
                    case "-4": return "-4<SPLITER>Falta el motivo o la solución.";
                    case "-6": return "-6<SPLITER>Este cambio ya no se puede hacer. Recarga el tiquete.";
                    case "0": return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
                    default: return obj_Tickets_DAL.sValorScalar + "<SPLITER>Listo, el estado se actualizó.";
                }
            }
            catch (Exception)
            {
                return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
            }
        }

        // =====================================================================================
        // UTILIDADES
        // =====================================================================================

        /// <summary>"" o texto no numérico → null (el SP lo toma como "todos").</summary>
        private static int? EnteroONulo(string valor)
        {
            int numero;
            return int.TryParse(valor, out numero) ? (int?)numero : null;
        }

        /// <summary>Respuesta de SP_ASIGNA_TICKETS → "código<SPLITER>mensaje".</summary>
        private static string MensajeAsignar(string sValorScalar, string sMensajeExito)
        {
            if (sValorScalar == null)
                return "0<SPLITER>No se pudo conectar con la base de datos.";

            switch (sValorScalar)
            {
                case "-2": return "-2<SPLITER>El tiquete no existe.";
                case "-3": return "-3<SPLITER>No tienes permiso para asignar tiquetes.";
                case "-4": return "-4<SPLITER>La persona elegida no puede atender tiquetes, o falta el motivo de la reasignación.";
                case "-6": return "-6<SPLITER>No se puede asignar: el tiquete ya es de esa persona o ya no está abierto.";
                case "0": return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
                default: return sValorScalar + "<SPLITER>" + sMensajeExito;
            }
        }

        /// <summary>Respuesta de SP_ACTUALIZA_TICKETS. Devuelve "OK" si salió bien.</summary>
        private static string MensajeActualizar(string sValorScalar)
        {
            if (sValorScalar == null)
                return "0<SPLITER>No se pudo conectar con la base de datos.";

            switch (sValorScalar)
            {
                case "-2": return "-2<SPLITER>El tiquete no existe.";
                case "-3": return "-3<SPLITER>No tienes permiso para editar este tiquete.";
                case "-4": return "-4<SPLITER>Revisa los datos: la categoría, la prioridad o la ubicación no son válidas. Si el tipo de problema necesita un lugar del campus, la ubicación no puede ser en línea.";
                case "-6": return "-6<SPLITER>No se puede editar un tiquete cerrado o cancelado.";
                case "0": return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
                default: return "OK";
            }
        }
    }
}
