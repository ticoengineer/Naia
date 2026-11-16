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
    }

}