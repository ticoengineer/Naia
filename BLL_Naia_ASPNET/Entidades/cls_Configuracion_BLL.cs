using DAL_Naia_ASPNET.BD;
using DAL_Naia_ASPNET.Entidades;
using BLL_Naia_ASPNET.BD;
using System.Configuration;
using System.Data;

namespace BLL_Naia_ASPNET.Entidades
{
    public class cls_Configuracion_BLL
    {
        // ==================== INFO INSTITUCION ====================
        public void Info_Institucion(ref cls_Configuracion_DAL obj_DAL)
        {
            cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
            cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

            obj_BD_DAL.sNombreBD = "Configuracion";
            obj_BD_DAL.sNombreSP = ConfigurationManager.AppSettings["SP_INFO_INSTITUCION"];
            obj_BD_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros();

            DataRow fila;
            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@InstitucionId";
            fila["sTipoDato"] = "1";
            fila["sValor"] = obj_DAL.iInstitucionId;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@IdUsuarioGlobal";
            fila["sTipoDato"] = "1";
            fila["sValor"] = obj_DAL.iIdUsuarioGlobal;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);
            obj_DAL.dtDatos = obj_BD_DAL.dtDatos;
            obj_DAL.sMSJError = obj_BD_DAL.sMSJError;
        }

        // ==================== ACTUALIZAR INSTITUCION ====================
        public void Actualizar_Institucion(ref cls_Configuracion_DAL obj_DAL)
        {
            cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
            cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

            obj_BD_DAL.sNombreBD = "Configuracion";
            obj_BD_DAL.sNombreSP = ConfigurationManager.AppSettings["SP_ACTUALIZA_INSTITUCIONES"];
            obj_BD_DAL.sIndAxn = "SCALAR";
            obj_BD_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros();

            DataRow fila;

            // @InstitucionId
            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@InstitucionId";
            fila["sTipoDato"] = "1";
            fila["sValor"] = obj_DAL.iInstitucionId;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            // @PlanId
            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@PlanId";
            fila["sTipoDato"] = "1";
            fila["sValor"] = obj_DAL.iPlanId;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            // @NombreInstitucion
            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@NombreInstitucion";
            fila["sTipoDato"] = "7";
            fila["sValor"] = obj_DAL.sNombreInstitucion;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            // @Siglas
            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@Siglas";
            fila["sTipoDato"] = "7";
            fila["sValor"] = obj_DAL.sSiglas;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            // @IdUsuarioGlobal
            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@IdUsuarioGlobal";
            fila["sTipoDato"] = "1";
            fila["sValor"] = obj_DAL.iIdUsuarioGlobal;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            // @DireccionIp
            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@DireccionIp";
            fila["sTipoDato"] = "6";
            fila["sValor"] = obj_DAL.sDireccionIp;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            obj_BD_BLL.EjecutaProcesosComando(ref obj_BD_DAL);
            obj_DAL.sValorScalar = obj_BD_DAL.sValorScalar;
            obj_DAL.sMSJError = obj_BD_DAL.sMSJError;
        }

        // ==================== LISTAR PLANES ====================
        public void Listar_Planes(ref cls_Configuracion_DAL obj_DAL)
        {
            cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
            cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

            obj_BD_DAL.sNombreBD = "Configuracion";
            obj_BD_DAL.sNombreSP = ConfigurationManager.AppSettings["SP_LISTAR_PLANES"];
            obj_BD_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros();

            DataRow fila;
            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@SoloActivos";
            fila["sTipoDato"] = "9";
            fila["sValor"] = obj_DAL.bSoloActivos;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);
            obj_DAL.dtDatos = obj_BD_DAL.dtDatos;
            obj_DAL.sMSJError = obj_BD_DAL.sMSJError;
        }
    }
}
