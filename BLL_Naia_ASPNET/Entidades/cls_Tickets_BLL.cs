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

        /// <summary>
        /// SP_INSERTA_TICKETS: crea el tiquete. La prioridad, el estado (Nuevo), el SLA,
        /// el historial y la auditoría los pone el SP.
        /// sValorScalar: > 0 TicketId creado · -3 usuario sin permiso · -4 dato inválido · 0 error
        /// </summary>
        public void Insertar_Ticket(ref cls_Tickets_DAL obj_Tickets_DAL)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj_Tickets_DAL.dtParametros = null;
                obj_Tickets_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj_Tickets_DAL.dtParametros);

                obj_Tickets_DAL.dtParametros.Rows.Add("@InstitucionId", "1", obj_Tickets_DAL.iInstitucionId);
                obj_Tickets_DAL.dtParametros.Rows.Add("@Titulo", "7", obj_Tickets_DAL.sTitulo);
                obj_Tickets_DAL.dtParametros.Rows.Add("@Descripcion", "7", obj_Tickets_DAL.sDescripcion);
                obj_Tickets_DAL.dtParametros.Rows.Add("@CategoriaId", "1", obj_Tickets_DAL.iCategoriaId);
                obj_Tickets_DAL.dtParametros.Rows.Add("@UbicacionId", "1", obj_Tickets_DAL.iUbicacionId);
                obj_Tickets_DAL.dtParametros.Rows.Add("@IdUsuarioGlobal", "1", obj_Tickets_DAL.iIdUsuarioGlobal);
                obj_Tickets_DAL.dtParametros.Rows.Add("@DireccionIp", "6", obj_Tickets_DAL.sDireccionIp);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_INSERTA_TICKETS"];
                obj_BD_DAL.sIndAxn = "SCALAR";
                obj_BD_DAL.DT_Parametros = obj_Tickets_DAL.dtParametros;

                obj_BD_BLL.EjecutaProcesosComando(ref obj_BD_DAL);

                obj_Tickets_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj_Tickets_DAL.sValorScalar = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.sValorScalar : null;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// SP_INSERTA_COMENTARIOS: agrega un mensaje a la conversación (máx. 500 caracteres).
        /// sValorScalar: > 0 ComentarioId · -2 no existe · -3 sin permiso · -4 vacío o muy largo · -6 tiquete cerrado · 0 error
        /// </summary>
        public void Insertar_Comentario(ref cls_Tickets_DAL obj_Tickets_DAL)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj_Tickets_DAL.dtParametros = null;
                obj_Tickets_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj_Tickets_DAL.dtParametros);

                obj_Tickets_DAL.dtParametros.Rows.Add("@InstitucionId", "1", obj_Tickets_DAL.iInstitucionId);
                obj_Tickets_DAL.dtParametros.Rows.Add("@TicketId", "1", obj_Tickets_DAL.iTicketId);
                obj_Tickets_DAL.dtParametros.Rows.Add("@Texto", "7", obj_Tickets_DAL.sTexto);
                obj_Tickets_DAL.dtParametros.Rows.Add("@IdUsuarioGlobal", "1", obj_Tickets_DAL.iIdUsuarioGlobal);
                obj_Tickets_DAL.dtParametros.Rows.Add("@DireccionIp", "6", obj_Tickets_DAL.sDireccionIp);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_INSERTA_COMENTARIOS"];
                obj_BD_DAL.sIndAxn = "SCALAR";
                obj_BD_DAL.DT_Parametros = obj_Tickets_DAL.dtParametros;

                obj_BD_BLL.EjecutaProcesosComando(ref obj_BD_DAL);

                obj_Tickets_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj_Tickets_DAL.sValorScalar = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.sValorScalar : null;
            }
            catch (Exception ex) { throw ex; }
        }

        /// <summary>
        /// SP_LISTAR_TRANSICIONES_DISPONIBLES: cambios de estado que ESTE usuario puede hacer en ESTE tiquete.
        /// Un renglón = un botón. Columnas: EstadoDestinoId, EstadoDestino, RequiereMotivo, RequiereSolucion
        /// </summary>
        public void Listar_Transiciones(ref cls_Tickets_DAL obj_Tickets_DAL)
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

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_LISTAR_TRANSICIONES_DISPONIBLES"];
                obj_BD_DAL.sNomTabla = "Transiciones";
                obj_BD_DAL.DT_Parametros = obj_Tickets_DAL.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                obj_Tickets_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj_Tickets_DAL.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables[0] : null;
            }
            catch (Exception ex) { throw ex; }
        }

        /// <summary>
        /// SP_CAMBIA_ESTADO_TICKETS: confirmar solución, reabrir, cancelar, etc. Valida contra TransicionEstado.
        /// sValorScalar: > 0 TicketId · -2 no existe · -3 sin permiso · -4 falta motivo/solución · -6 cambio no permitido · 0 error
        /// </summary>
        public void Cambiar_Estado(ref cls_Tickets_DAL obj_Tickets_DAL)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj_Tickets_DAL.dtParametros = null;
                obj_Tickets_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj_Tickets_DAL.dtParametros);

                obj_Tickets_DAL.dtParametros.Rows.Add("@InstitucionId", "1", obj_Tickets_DAL.iInstitucionId);
                obj_Tickets_DAL.dtParametros.Rows.Add("@TicketId", "1", obj_Tickets_DAL.iTicketId);
                obj_Tickets_DAL.dtParametros.Rows.Add("@EstadoNuevoId", "11", obj_Tickets_DAL.iEstadoNuevoId);
                /*Motivo y solución son opcionales: si vienen vacíos se manda NULL real*/
                obj_Tickets_DAL.dtParametros.Rows.Add("@Motivo", "7",
                    string.IsNullOrWhiteSpace(obj_Tickets_DAL.sMotivo) ? (object)DBNull.Value : obj_Tickets_DAL.sMotivo);
                obj_Tickets_DAL.dtParametros.Rows.Add("@Solucion", "7",
                    string.IsNullOrWhiteSpace(obj_Tickets_DAL.sSolucion) ? (object)DBNull.Value : obj_Tickets_DAL.sSolucion);
                obj_Tickets_DAL.dtParametros.Rows.Add("@IdUsuarioGlobal", "1", obj_Tickets_DAL.iIdUsuarioGlobal);
                obj_Tickets_DAL.dtParametros.Rows.Add("@DireccionIp", "6", obj_Tickets_DAL.sDireccionIp);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_CAMBIA_ESTADO_TICKETS"];
                obj_BD_DAL.sIndAxn = "SCALAR";
                obj_BD_DAL.DT_Parametros = obj_Tickets_DAL.dtParametros;

                obj_BD_BLL.EjecutaProcesosComando(ref obj_BD_DAL);

                obj_Tickets_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj_Tickets_DAL.sValorScalar = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.sValorScalar : null;
            }
            catch (Exception ex) { throw ex; }
        }
    }

}
