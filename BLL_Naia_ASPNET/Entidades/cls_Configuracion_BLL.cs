
using BLL_Naia_ASPNET.BD;
using DAL_Naia_ASPNET.BD;
using DAL_Naia_ASPNET.Entidades;
using System;
using System.Configuration;

namespace BLL_Naia_ASPNET.Entidades
{
    public class cls_Configuracion_BLL
    {
        // ==========================================
        // INFO INSTITUCION
        // ==========================================
        public void Info_Institucion(ref cls_Configuracion_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros =
                    obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);

                // SP_INFO_INSTITUCION recibe solamente
                // @InstitucionId.
                obj.dtParametros.Rows.Add(
                    "@InstitucionId", "1", obj.iInstitucionId);

                obj_BD_DAL.sNomSP =
                    ConfigurationManager.AppSettings["SP_INFO_INSTITUCION"];

                obj_BD_DAL.sNomTabla = "Institucion";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;

                obj.dtDatos =
                    obj_BD_DAL.sMsjErrorBD == string.Empty &&
                    obj_BD_DAL.DS != null &&
                    obj_BD_DAL.DS.Tables.Contains("Institucion")
                    ? obj_BD_DAL.DS.Tables["Institucion"]
                    : null;
            }
            catch (Exception)
            {
                throw;
            }
        }

        // ==========================================
        // ACTUALIZAR INSTITUCION
        // ==========================================
        public void Actualizar_Institucion(ref cls_Configuracion_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros =
                    obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);

                obj.dtParametros.Rows.Add(
                    "@InstitucionId", "1", obj.iInstitucionId);

                obj.dtParametros.Rows.Add(
                    "@PlanId", "1", obj.iPlanId);

                obj.dtParametros.Rows.Add(
                    "@NombreInstitucion", "7", obj.sNombreInstitucion);

                obj.dtParametros.Rows.Add(
                    "@Siglas", "7", obj.sSiglas);

                obj.dtParametros.Rows.Add(
                    "@IdUsuarioGlobal", "1", obj.iIdUsuarioGlobal);

                obj.dtParametros.Rows.Add(
                    "@DireccionIp", "6", obj.sDireccionIp);

                obj_BD_DAL.sNomSP =
                    ConfigurationManager.AppSettings["SP_ACTUALIZA_INSTITUCIONES"];

                obj_BD_DAL.sIndAxn = "SCALAR";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosComando(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;

                obj.sValorScalar =
                    obj_BD_DAL.sMsjErrorBD == string.Empty
                    ? obj_BD_DAL.sValorScalar
                    : null;
            }
            catch (Exception)
            {
                throw;
            }
        }

        // ==========================================
        // LISTAR PLANES
        // ==========================================
        public void Listar_Planes(ref cls_Configuracion_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros =
                    obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);

                obj.dtParametros.Rows.Add(
                    "@SoloActivos", "9", obj.bSoloActivos);

                obj_BD_DAL.sNomSP =
                    ConfigurationManager.AppSettings["SP_LISTAR_PLANES"];

                obj_BD_DAL.sNomTabla = "Planes";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);
                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;

                obj.dtDatos =
                    obj_BD_DAL.sMsjErrorBD == string.Empty &&
                    obj_BD_DAL.DS != null &&
                    obj_BD_DAL.DS.Tables.Contains("Planes")
                    ? obj_BD_DAL.DS.Tables["Planes"]
                    : null;
            }
            catch (Exception)
            {
                throw;
            }
        }
    }
}
