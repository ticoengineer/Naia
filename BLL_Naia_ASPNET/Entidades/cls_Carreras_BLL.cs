using BLL_Naia_ASPNET.BD;
using DAL_Naia_ASPNET.BD;
using DAL_Naia_ASPNET.Entidades;
using System;
using System.Configuration;

namespace BLL_Naia_ASPNET.Entidades
{
    public class cls_Carreras_BLL
    {
        public void Listar_Carreras(ref cls_Carreras_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);
                obj.dtParametros.Rows.Add("@InstitucionId", "1", obj.iInstitucionId);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_LISTAR_CARRERAS"];
                obj_BD_DAL.sNomTabla = "Carreras";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables["Carreras"] : null;
            }
            catch (Exception ex) { throw ex; }
        }

        public void Filtrar_Carreras(ref cls_Carreras_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);
                obj.dtParametros.Rows.Add("@InstitucionId", "1", obj.iInstitucionId);
                obj.dtParametros.Rows.Add("@Filtro", "7", obj.sFiltro);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_FILTRAR_CARRERAS"];
                obj_BD_DAL.sNomTabla = "Carreras";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables["Carreras"] : null;
            }
            catch (Exception ex) { throw ex; }
        }

        public void Info_Carrera(ref cls_Carreras_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);
                obj.dtParametros.Rows.Add("@InstitucionId", "1", obj.iInstitucionId);
                obj.dtParametros.Rows.Add("@CarreraId", "1", obj.iCarreraId);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_INFO_CARRERA"];
                obj_BD_DAL.sNomTabla = "Carrera";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables["Carrera"] : null;
            }
            catch (Exception ex) { throw ex; }
        }

        public void Insertar_Carrera(ref cls_Carreras_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);
                obj.dtParametros.Rows.Add("@InstitucionId", "1", obj.iInstitucionId);
                obj.dtParametros.Rows.Add("@Nombre", "7", obj.sNombre);
                obj.dtParametros.Rows.Add("@Codigo", "7", obj.sCodigo ?? (object)System.DBNull.Value);
                obj.dtParametros.Rows.Add("@IdUsuarioGlobal", "1", obj.iIdUsuarioGlobal);
                obj.dtParametros.Rows.Add("@DireccionIp", "6", obj.sDireccionIp);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_INSERTA_CARRERAS"];
                obj_BD_DAL.sIndAxn = "SCALAR";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosComando(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj.sValorScalar = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.sValorScalar : null;
            }
            catch (Exception ex) { throw ex; }
        }

        public void Actualizar_Carrera(ref cls_Carreras_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);
                obj.dtParametros.Rows.Add("@InstitucionId", "1", obj.iInstitucionId);
                obj.dtParametros.Rows.Add("@CarreraId", "1", obj.iCarreraId);
                obj.dtParametros.Rows.Add("@Nombre", "7", obj.sNombre);
                obj.dtParametros.Rows.Add("@Codigo", "7", obj.sCodigo ?? (object)System.DBNull.Value);
                obj.dtParametros.Rows.Add("@Activa", "9", obj.bActiva);
                obj.dtParametros.Rows.Add("@IdUsuarioGlobal", "1", obj.iIdUsuarioGlobal);
                obj.dtParametros.Rows.Add("@DireccionIp", "6", obj.sDireccionIp);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_ACTUALIZA_CARRERAS"];
                obj_BD_DAL.sIndAxn = "SCALAR";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosComando(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj.sValorScalar = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.sValorScalar : null;
            }
            catch (Exception ex) { throw ex; }
        }

        public void Eliminar_Carrera(ref cls_Carreras_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);
                obj.dtParametros.Rows.Add("@InstitucionId", "1", obj.iInstitucionId);
                obj.dtParametros.Rows.Add("@CarreraId", "1", obj.iCarreraId);
                obj.dtParametros.Rows.Add("@IdUsuarioGlobal", "1", obj.iIdUsuarioGlobal);
                obj.dtParametros.Rows.Add("@DireccionIp", "6", obj.sDireccionIp);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_ELIMINA_CARRERAS"];
                obj_BD_DAL.sIndAxn = "SCALAR";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosComando(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj.sValorScalar = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.sValorScalar : null;
            }
            catch (Exception ex) { throw ex; }
        }
    }
}
