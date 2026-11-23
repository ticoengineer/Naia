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
    public partial class frmInicioUsuario : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        /// <summary>
        /// Lo llama InicioUsuario.js → CargarTickets().
        /// Parámetros (mismo orden que en el JS): [0] InstitucionId · [1] IdUsuarioGlobal
        /// Devuelve TODOS los tiquetes del usuario; el JS los separa en abiertos e historial.
        /// </summary>
        [WebMethod]
        public static List<Dictionary<string, string>> ListarTickets(List<string> obj_Parametros_JS)
        {
            List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();

            try
            {
                cls_Tickets_DAL obj_Tickets_DAL = new cls_Tickets_DAL();
                cls_Tickets_BLL obj_Tickets_BLL = new cls_Tickets_BLL();

                obj_Tickets_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_Tickets_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[1]);

                obj_Tickets_BLL.Listar_Tickets(ref obj_Tickets_DAL);

                if (obj_Tickets_DAL.dtDatos != null)
                {
                    foreach (DataRow fila in obj_Tickets_DAL.dtDatos.Rows)
                    {
                        lista.Add(new Dictionary<string, string>
                        {
                            { "TicketId",      fila["TicketId"].ToString() },
                            { "Numero",        fila["Numero"].ToString() },
                            { "Titulo",        fila["Titulo"].ToString() },
                            { "Categoria",     fila["Categoria"].ToString() },
                            { "Prioridad",     fila["Prioridad"].ToString() },
                            { "EstadoId",      fila["EstadoId"].ToString() },
                            { "Estado",        fila["Estado"].ToString() },
                            { "Responsable",   fila["Responsable"].ToString() },
                            { "Ubicacion",     fila["Ubicacion"].ToString() },
                            { "FechaCreacion", fila["FechaCreacionTexto"].ToString() }
                        });
                    }
                }
            }
            catch (Exception)
            {
                /*Si algo falla se devuelve la lista vacía; el JS muestra el mensaje*/
            }

            return lista;
        }

        /// <summary>
        /// Lo llama InicioUsuario.js → CargarDetalleTicket() al abrir una fila.
        /// Parámetros: [0] InstitucionId · [1] TicketId · [2] IdUsuarioGlobal
        /// Junta SP_INFO_TICKET (descripción, equipo) y el último comentario de SP_LISTAR_COMENTARIOS.
        /// </summary>
        [WebMethod]
        public static Dictionary<string, string> DetalleTicket(List<string> obj_Parametros_JS)
        {
            Dictionary<string, string> detalle = new Dictionary<string, string>();

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
                {
                    return detalle;   // sin permiso o no existe
                }

                DataRow fila = obj_Tickets_DAL.dtDatos.Rows[0];
                detalle.Add("Descripcion", fila["Descripcion"].ToString());
                detalle.Add("Equipo", fila["EquipoResponsable"] == DBNull.Value ? "" : fila["EquipoResponsable"].ToString());

                /*2. Último comentario (el SP los ordena del más viejo al más nuevo)*/
                obj_Tickets_BLL.Listar_Comentarios(ref obj_Tickets_DAL);

                if (obj_Tickets_DAL.dtDatos != null && obj_Tickets_DAL.dtDatos.Rows.Count > 0)
                {
                    DataRow ultimo = obj_Tickets_DAL.dtDatos.Rows[obj_Tickets_DAL.dtDatos.Rows.Count - 1];
                    detalle.Add("UltimoAutor", ultimo["Autor"].ToString());
                    detalle.Add("UltimaFecha", ultimo["FechaTexto"].ToString());
                    detalle.Add("UltimoMensaje", ultimo["Texto"].ToString());
                }
            }
            catch (Exception)
            {
                /*Si algo falla se devuelve vacío; el JS muestra el mensaje*/
            }

            return detalle;
        }

        /// <summary>
        /// Combo "Tipo de problema". Parámetros: [0] InstitucionId
        /// Solo categorías ACTIVAS (el estudiante no debe ver las desactivadas).
        /// </summary>
        [WebMethod]
        public static List<Dictionary<string, string>> ListarCategorias(List<string> obj_Parametros_JS)
        {
            List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();

            try
            {
                cls_Categorias_DAL obj_Categorias_DAL = new cls_Categorias_DAL();
                cls_Categorias_BLL obj_Categorias_BLL = new cls_Categorias_BLL();

                obj_Categorias_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_Categorias_DAL.bSoloActivas = true;

                obj_Categorias_BLL.Listar_Categorias(ref obj_Categorias_DAL);

                if (obj_Categorias_DAL.dtDatos != null)
                {
                    foreach (DataRow fila in obj_Categorias_DAL.dtDatos.Rows)
                    {
                        lista.Add(new Dictionary<string, string>
                {
                    { "CategoriaId",    fila["CategoriaId"].ToString() },
                    { "Nombre",         fila["Categoria"].ToString() },
                    { "Descripcion",    fila["Descripcion"] == DBNull.Value ? "" : fila["Descripcion"].ToString() },
                    { "RequiereFisica", Convert.ToBoolean(fila["RequiereUbicacionFisica"]) ? "1" : "0" }
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

        /// <summary>
        /// Combo "¿Dónde ocurre?". Parámetros: [0] InstitucionId
        /// Solo ubicaciones ACTIVAS. EsFisica: "1" campus · "0" en línea.
        /// </summary>
        [WebMethod]
        public static List<Dictionary<string, string>> ListarUbicaciones(List<string> obj_Parametros_JS)
        {
            List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();

            try
            {
                cls_Ubicaciones_DAL obj_Ubicaciones_DAL = new cls_Ubicaciones_DAL();
                cls_Ubicaciones_BLL obj_Ubicaciones_BLL = new cls_Ubicaciones_BLL();

                obj_Ubicaciones_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_Ubicaciones_DAL.bSoloActivas = true;

                obj_Ubicaciones_BLL.Listar_Ubicaciones(ref obj_Ubicaciones_DAL);

                if (obj_Ubicaciones_DAL.dtDatos != null)
                {
                    foreach (DataRow fila in obj_Ubicaciones_DAL.dtDatos.Rows)
                    {
                        lista.Add(new Dictionary<string, string>
                {
                    { "UbicacionId", fila["UbicacionId"].ToString() },
                    { "Nombre",      fila["UbicacionTexto"].ToString() },
                    { "EsFisica",    Convert.ToBoolean(fila["EsFisica"]) ? "1" : "0" }
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

        /// <summary>
        /// Crea el tiquete. Parámetros (mismo orden que en InicioUsuario.js):
        /// [0] InstitucionId · [1] Titulo · [2] Descripcion · [3] CategoriaId · [4] UbicacionId · [5] IdUsuarioGlobal
        /// Respuesta: "código<SPLITER>mensaje" (código > 0 = TicketId creado)
        /// </summary>
        [WebMethod]
        public static string InsertarTicket(List<string> obj_Parametros_JS)
        {
            try
            {
                cls_Tickets_DAL obj_Tickets_DAL = new cls_Tickets_DAL();
                cls_Tickets_BLL obj_Tickets_BLL = new cls_Tickets_BLL();

                obj_Tickets_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_Tickets_DAL.sTitulo = obj_Parametros_JS[1];
                obj_Tickets_DAL.sDescripcion = obj_Parametros_JS[2];
                obj_Tickets_DAL.iCategoriaId = Convert.ToInt32(obj_Parametros_JS[3]);
                obj_Tickets_DAL.iUbicacionId = Convert.ToInt32(obj_Parametros_JS[4]);
                obj_Tickets_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[5]);
                obj_Tickets_DAL.sDireccionIp = HttpContext.Current.Request.UserHostAddress;

                obj_Tickets_BLL.Insertar_Ticket(ref obj_Tickets_DAL);

                if (obj_Tickets_DAL.sValorScalar == null)
                    return "0<SPLITER>No se pudo conectar con la base de datos.";

                switch (obj_Tickets_DAL.sValorScalar)
                {
                    case "-3": return "-3<SPLITER>Tu cuenta no puede crear solicitudes en esta universidad.";
                    case "-4": return "-4<SPLITER>Revisa los datos: el título y la descripción son obligatorios, y el tipo de problema y la ubicación deben ser válidos.";
                    case "0": return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
                    default:
                        /*Número visible del tiquete: INC + TicketId con 7 dígitos (igual que la columna Numero)*/
                        string sNumero = "INC" + obj_Tickets_DAL.sValorScalar.PadLeft(7, '0');
                        return obj_Tickets_DAL.sValorScalar + "<SPLITER>Recibimos tu solicitud " + sNumero + ". Te avisaremos cada avance.";
                }
            }
            catch (Exception)
            {
                return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
            }
        }

        /// <summary>
        /// Abre el panel de "Ver y responder". En UNA llamada devuelve:
        ///   Ticket      → datos del tiquete (SP_INFO_TICKET)
        ///   Comentarios → conversación completa (SP_LISTAR_COMENTARIOS)
        ///   Acciones    → botones de estado permitidos (SP_LISTAR_TRANSICIONES_DISPONIBLES)
        /// Parámetros: [0] InstitucionId · [1] TicketId · [2] IdUsuarioGlobal
        /// Si el usuario no tiene permiso de ver el tiquete, devuelve vacío.
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
            { "TicketId",      t["TicketId"].ToString() },
            { "Numero",        t["Numero"].ToString() },
            { "Titulo",        t["Titulo"].ToString() },
            { "Descripcion",   t["Descripcion"].ToString() },
            { "Categoria",     t["Categoria"].ToString() },
            { "Ubicacion",     t["Ubicacion"].ToString() },
            { "Prioridad",     t["Prioridad"].ToString() },
            { "Responsable",   t["Responsable"].ToString() },
            { "Equipo",        t["EquipoResponsable"] == DBNull.Value ? "" : t["EquipoResponsable"].ToString() },
            { "EstadoId",      t["EstadoId"].ToString() },
            { "Estado",        t["Estado"].ToString() },
            { "Solucion",      t["Solucion"] == DBNull.Value ? "" : t["Solucion"].ToString() },
            { "FechaCreacion", Convert.ToDateTime(t["FechaCreacion"]).ToString("dd/MM/yyyy HH:mm") },
            { "PuedeComentar", t["PuedeComentar"].ToString() }
        });

                /*2. Conversación + cambios de estado.
     Si la actividad falla (SP o llave faltante), se usan solo los comentarios:
     así el panel nunca deja de cargar por esto.*/
                List<Dictionary<string, string>> comentarios = new List<Dictionary<string, string>>();
                bool bConActividad = false;

                try
                {
                    obj_Tickets_BLL.Listar_Actividad(ref obj_Tickets_DAL);
                    bConActividad = obj_Tickets_DAL.dtDatos != null;
                }
                catch (Exception) { bConActividad = false; }

                if (!bConActividad)
                    obj_Tickets_BLL.Listar_Comentarios(ref obj_Tickets_DAL);

                if (obj_Tickets_DAL.dtDatos != null)
                {
                    foreach (DataRow c in obj_Tickets_DAL.dtDatos.Rows)
                    {
                        comentarios.Add(new Dictionary<string, string>
                        {
                            { "Tipo",             bConActividad ? c["Tipo"].ToString() : "Comentario" },
                            { "Autor",            c["Autor"].ToString() },
                            { "Rol",              c["RolAutor"].ToString() },
                            { "Texto",            c["Texto"] == DBNull.Value ? "" : c["Texto"].ToString() },
                            { "Fecha",            c["FechaTexto"].ToString() },
                            { "EstadoAnteriorId", bConActividad ? c["EstadoAnteriorId"].ToString() : "" },
                            { "EstadoNuevoId",    bConActividad ? c["EstadoNuevoId"].ToString() : "" },
                            { "EstadoNuevo",      bConActividad ? c["EstadoNuevo"].ToString() : "" },
                            { "EsMio",            Convert.ToInt32(c["UsuarioId"]) == obj_Tickets_DAL.iIdUsuarioGlobal ? "1" : "0" }
                        });
                    }
                }
                respuesta.Add("Comentarios", comentarios);

                /*3. Botones de estado permitidos*/
                List<Dictionary<string, string>> acciones = new List<Dictionary<string, string>>();
                obj_Tickets_BLL.Listar_Transiciones(ref obj_Tickets_DAL);

                if (obj_Tickets_DAL.dtDatos != null)
                {
                    foreach (DataRow a in obj_Tickets_DAL.dtDatos.Rows)
                    {
                        acciones.Add(new Dictionary<string, string>
                {
                    { "EstadoDestinoId", a["EstadoDestinoId"].ToString() },
                    { "EstadoDestino",   a["EstadoDestino"].ToString() },
                    { "RequiereMotivo",  Convert.ToBoolean(a["RequiereMotivo"]) ? "1" : "0" }
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
        /// Guarda un mensaje en la conversación.
        /// Parámetros: [0] InstitucionId · [1] TicketId · [2] Texto · [3] IdUsuarioGlobal
        /// </summary>
        [WebMethod]
        public static string ResponderTicket(List<string> obj_Parametros_JS)
        {
            try
            {
                cls_Tickets_DAL obj_Tickets_DAL = new cls_Tickets_DAL();
                cls_Tickets_BLL obj_Tickets_BLL = new cls_Tickets_BLL();

                obj_Tickets_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
                obj_Tickets_DAL.iTicketId = Convert.ToInt32(obj_Parametros_JS[1]);
                obj_Tickets_DAL.sTexto = obj_Parametros_JS[2];
                obj_Tickets_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[3]);
                obj_Tickets_DAL.sDireccionIp = HttpContext.Current.Request.UserHostAddress;

                obj_Tickets_BLL.Insertar_Comentario(ref obj_Tickets_DAL);

                if (obj_Tickets_DAL.sValorScalar == null)
                    return "0<SPLITER>No se pudo conectar con la base de datos.";

                switch (obj_Tickets_DAL.sValorScalar)
                {
                    case "-2": return "-2<SPLITER>La solicitud no existe.";
                    case "-3": return "-3<SPLITER>No tienes permiso para responder en esta solicitud.";
                    case "-4": return "-4<SPLITER>El mensaje no puede estar vacío ni pasar de 500 caracteres.";
                    case "-6": return "-6<SPLITER>Esta solicitud ya está cerrada; no se pueden enviar mensajes.";
                    case "0": return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
                    default: return obj_Tickets_DAL.sValorScalar + "<SPLITER>Mensaje enviado.";
                }
            }
            catch (Exception)
            {
                return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
            }
        }

        /// <summary>
        /// Cambia el estado del tiquete (confirmar solución, reabrir, cancelar).
        /// Parámetros: [0] InstitucionId · [1] TicketId · [2] EstadoNuevoId · [3] Motivo · [4] IdUsuarioGlobal
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
                obj_Tickets_DAL.sSolucion = null;   // el usuario nunca marca como Resuelto
                obj_Tickets_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[4]);
                obj_Tickets_DAL.sDireccionIp = HttpContext.Current.Request.UserHostAddress;

                obj_Tickets_BLL.Cambiar_Estado(ref obj_Tickets_DAL);

                if (obj_Tickets_DAL.sValorScalar == null)
                    return "0<SPLITER>No se pudo conectar con la base de datos.";

                switch (obj_Tickets_DAL.sValorScalar)
                {
                    case "-2": return "-2<SPLITER>La solicitud no existe.";
                    case "-3": return "-3<SPLITER>No tienes permiso para hacer este cambio.";
                    case "-4": return "-4<SPLITER>Debes escribir el motivo.";
                    case "-6": return "-6<SPLITER>Este cambio ya no se puede hacer. Recarga la solicitud.";
                    case "0": return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
                    default: return obj_Tickets_DAL.sValorScalar + "<SPLITER>Listo, la solicitud se actualizó.";
                }
            }
            catch (Exception)
            {
                return "0<SPLITER>Ocurrió un error inesperado. Intenta de nuevo.";
            }
        }
    }

}