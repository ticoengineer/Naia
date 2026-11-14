using BLL_Naia_ASPNET.BD;
using DAL_Naia_ASPNET.BD;
using DAL_Naia_ASPNET.Entidades;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL_Naia_ASPNET.Entidades
{
    public class cls_Tickets_BLL
    {
        /// <summary>
        /// SP_LISTAR_TICKETS: Estudiante/Profesor reciben solo los tiquetes que ellos crearon.
        /// </summary>
        public void Listar_Tickets(ref cls_Tickets_DAL obj_Tickets_DAL)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj_Tickets_DAL.dtParametros = null;
                obj_Tickets_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj_Tickets_DAL.dtParametros);

                obj_Tickets_DAL.dtParametros.Rows.Add("@InstitucionId", "1", obj_Tickets_DAL.iInstitucionId);
                obj_Tickets_DAL.dtParametros.Rows.Add("@IdUsuarioGlobal", "1", obj_Tickets_DAL.iIdUsuarioGlobal);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_LISTAR_TICKETS"];
                obj_BD_DAL.sNomTabla = "Tickets";
                obj_BD_DAL.DT_Parametros = obj_Tickets_DAL.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                if (obj_BD_DAL.sMsjErrorBD == string.Empty)
                {
                    obj_Tickets_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
                    obj_Tickets_DAL.dtDatos = obj_BD_DAL.DS.Tables[0];
                }
                else
                {
                    obj_Tickets_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
                    obj_Tickets_DAL.dtDatos = null;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// SP_INFO_TICKET: detalle de un tiquete. No devuelve filas si el usuario no tiene permiso de verlo.
        /// </summary>
        public void Info_Ticket(ref cls_Tickets_DAL obj_Tickets_DAL)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj_Tickets_DAL.dtParametros = null;
                obj_Tickets_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj_Tickets_DAL.dtParametros);

                obj_Tickets_DAL.dtParametros.Rows.Add("@InstitucionId", "1", obj_Tickets_DAL.iInstitucionId);
                obj_Tickets_DAL.dtParametros.Rows.Add("@TicketId", "1", obj_Tickets_DAL.iTicketId);
                obj_Tickets_DAL.dtParametros.Rows.Add("@IdUsuarioGlobal", "1", obj_Tickets_DAL.iIdUsuarioGlobal);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_INFO_TICKET"];
                obj_BD_DAL.sNomTabla = "Ticket";
                obj_BD_DAL.DT_Parametros = obj_Tickets_DAL.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                if (obj_BD_DAL.sMsjErrorBD == string.Empty)
                {
                    obj_Tickets_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
                    obj_Tickets_DAL.dtDatos = obj_BD_DAL.DS.Tables[0];
                }
                else
                {
                    obj_Tickets_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
                    obj_Tickets_DAL.dtDatos = null;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// SP_LISTAR_COMENTARIOS: conversación del tiquete, del más viejo al más nuevo.
        /// </summary>
        public void Listar_Comentarios(ref cls_Tickets_DAL obj_Tickets_DAL)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj_Tickets_DAL.dtParametros = null;
                obj_Tickets_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj_Tickets_DAL.dtParametros);

                obj_Tickets_DAL.dtParametros.Rows.Add("@InstitucionId", "1", obj_Tickets_DAL.iInstitucionId);
                obj_Tickets_DAL.dtParametros.Rows.Add("@TicketId", "1", obj_Tickets_DAL.iTicketId);
                obj_Tickets_DAL.dtParametros.Rows.Add("@IdUsuarioGlobal", "1", obj_Tickets_DAL.iIdUsuarioGlobal);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_LISTAR_COMENTARIOS"];
                obj_BD_DAL.sNomTabla = "Comentarios";
                obj_BD_DAL.DT_Parametros = obj_Tickets_DAL.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                if (obj_BD_DAL.sMsjErrorBD == string.Empty)
                {
                    obj_Tickets_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
                    obj_Tickets_DAL.dtDatos = obj_BD_DAL.DS.Tables[0];
                }
                else
                {
                    obj_Tickets_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
                    obj_Tickets_DAL.dtDatos = null;
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
    }

}
