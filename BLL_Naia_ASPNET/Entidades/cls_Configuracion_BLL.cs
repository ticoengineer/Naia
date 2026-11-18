
using BLL_Naia_ASPNET.BD;
using DAL_Naia_ASPNET.BD;
using DAL_Naia_ASPNET.Entidades;
using System;
using System.Configuration;

namespace BLL_Naia_ASPNET.Entidades
{
    public class cls_Configuracion_BLL
    {
        // ============================================
        // CONSULTAR INFORMACION DE LA UNIVERSIDAD
        // SP_INFO_INSTITUCION
        // ============================================

        public void Info_Institucion(
            ref cls_Configuracion_DAL obj_Configuracion_DAL)
        {
            cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
            cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

            // Preparar tabla de parametros
            obj_Configuracion_DAL.dtParametros =
                obj_BD_BLL.ObtieneDTParametros(null);

            // Institucion autenticada
            obj_Configuracion_DAL.dtParametros.Rows.Add(
                "@InstitucionId",
                "1",
                obj_Configuracion_DAL.iInstitucionId);

            // Configurar procedimiento
            obj_BD_DAL.sNomSP =
                ConfigurationManager.AppSettings[
                    "SP_INFO_INSTITUCION"];

            obj_BD_DAL.sNomTabla = "Institucion";

            obj_BD_DAL.DT_Parametros =
                obj_Configuracion_DAL.dtParametros;

            // Ejecutar consulta
            obj_BD_BLL.EjecutaProcesosTabla(
                ref obj_BD_DAL);

            // Guardar respuesta
            obj_Configuracion_DAL.sMSJError =
                obj_BD_DAL.sMsjErrorBD;

            obj_Configuracion_DAL.dtDatos =
                obj_BD_DAL.sMsjErrorBD == string.Empty
                && obj_BD_DAL.DS != null
                    ? obj_BD_DAL.DS.Tables["Institucion"]
                    : null;
        }

        // ============================================
        // LISTAR PLANES DISPONIBLES
        // SP_LISTAR_PLANES
        // ============================================

        public void Listar_Planes(
            ref cls_Configuracion_DAL obj_Configuracion_DAL)
        {
            cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
            cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

            // Preparar tabla de parametros
            obj_Configuracion_DAL.dtParametros =
                obj_BD_BLL.ObtieneDTParametros(null);

            // Mostrar solamente planes activos
            // o todos, segun el valor recibido
            obj_Configuracion_DAL.dtParametros.Rows.Add(
                "@SoloActivos",
                "9",
                obj_Configuracion_DAL.bSoloActivos);

            // Configurar procedimiento
            obj_BD_DAL.sNomSP =
                ConfigurationManager.AppSettings[
                    "SP_LISTAR_PLANES"];

            obj_BD_DAL.sNomTabla = "Planes";

            obj_BD_DAL.DT_Parametros =
                obj_Configuracion_DAL.dtParametros;

            // Ejecutar consulta
            obj_BD_BLL.EjecutaProcesosTabla(
                ref obj_BD_DAL);

            // Guardar respuesta
            obj_Configuracion_DAL.sMSJError =
                obj_BD_DAL.sMsjErrorBD;

            obj_Configuracion_DAL.dtDatos =
                obj_BD_DAL.sMsjErrorBD == string.Empty
                && obj_BD_DAL.DS != null
                    ? obj_BD_DAL.DS.Tables["Planes"]
                    : null;
        }

        // ============================================
        // ACTUALIZAR CONFIGURACION INSTITUCIONAL
        // SP_ACTUALIZA_INSTITUCIONES
        // ============================================

        public void Actualizar_Institucion(
            ref cls_Configuracion_DAL obj_Configuracion_DAL)
        {
            cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
            cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

            // Preparar tabla de parametros
            obj_Configuracion_DAL.dtParametros =
                obj_BD_BLL.ObtieneDTParametros(null);

            // 1. Institucion
            obj_Configuracion_DAL.dtParametros.Rows.Add(
                "@InstitucionId",
                "1",
                obj_Configuracion_DAL.iInstitucionId);

            // 2. Plan seleccionado
            obj_Configuracion_DAL.dtParametros.Rows.Add(
                "@PlanId",
                "1",
                obj_Configuracion_DAL.iPlanId);

            // 3. Nombre institucional
            obj_Configuracion_DAL.dtParametros.Rows.Add(
                "@NombreInstitucion",
                "7",
                obj_Configuracion_DAL.sNombreInstitucion);

            // 4. Siglas
            obj_Configuracion_DAL.dtParametros.Rows.Add(
                "@Siglas",
                "7",
                obj_Configuracion_DAL.sSiglas);

            // 5. Administrador autenticado
            obj_Configuracion_DAL.dtParametros.Rows.Add(
                "@IdUsuarioGlobal",
                "1",
                obj_Configuracion_DAL.iIdUsuarioGlobal);

            // 6. Direccion IP
            obj_Configuracion_DAL.dtParametros.Rows.Add(
                "@DireccionIp",
                "6",
                obj_Configuracion_DAL.sDireccionIp);

            // Configurar procedimiento
            obj_BD_DAL.sNomSP =
                ConfigurationManager.AppSettings[
                    "SP_ACTUALIZA_INSTITUCIONES"];

            obj_BD_DAL.sIndAxn = "SCALAR";

            obj_BD_DAL.DT_Parametros =
                obj_Configuracion_DAL.dtParametros;

            // Ejecutar actualizacion
            obj_BD_BLL.EjecutaProcesosComando(
                ref obj_BD_DAL);

            // Guardar resultado
            obj_Configuracion_DAL.sMSJError =
                obj_BD_DAL.sMsjErrorBD;

            obj_Configuracion_DAL.sValorScalar =
                obj_BD_DAL.sMsjErrorBD == string.Empty
                    ? obj_BD_DAL.sValorScalar
                    : null;
        }
    }
}
