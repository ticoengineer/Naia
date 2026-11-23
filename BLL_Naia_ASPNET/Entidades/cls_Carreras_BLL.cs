using BLL_Naia_ASPNET.BD;
using DAL_Naia_ASPNET.BD;
using DAL_Naia_ASPNET.Entidades;
using System;
using System.Configuration;

namespace BLL_Naia_ASPNET.Entidades
{
    /// <summary>
    /// Carreras de la universidad (estudiantes y profesores pertenecen a una).
    /// Los parámetros coinciden EXACTAMENTE con los SP de storedProcedures_Script.sql.
    /// </summary>
    public class cls_Carreras_BLL
    {
        /// <summary>SP_LISTAR_CARRERAS: bSoloActivas = false para el mantenimiento (ve todas), true para combos.</summary>
        public void Listar_Carreras(ref cls_Carreras_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);
                obj.dtParametros.Rows.Add("@InstitucionId", "1", obj.iInstitucionId);
                obj.dtParametros.Rows.Add("@SoloActivos", "9", obj.bSoloActivas);
                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_LISTAR_CARRERAS"];
                obj_BD_DAL.sNomTabla = "Carreras";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables["Carreras"] : null;
            }
            catch (Exception ex) { throw ex; }
        }

        /// <summary>SP_FILTRAR_CARRERAS: busca por nombre.</summary>
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

        /// <summary>SP_INFO_CARRERA: una sola carrera (para editar).</summary>
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
                obj_BD_DAL.sNomTabla = "Carreras";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables["Carreras"] : null;
            }
            catch (Exception ex) { throw ex; }
        }

        /// <summary>SP_INSERTA_CARRERAS · sValorScalar: > 0 CarreraId · -1 nombre repetido · -3 sin permiso · -4 nombre vacío · 0 error</summary>
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

        /// <summary>SP_ACTUALIZA_CARRERAS · -1 nombre repetido · -2 no existe · -3 sin permiso · -4 nombre vacío · -6 tiene usuarios activos · 0 error</summary>
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
                obj.dtParametros.Rows.Add("@Activo", "9", obj.bActiva);
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

        /// <summary>SP_ELIMINA_CARRERAS (desactiva) · -2 no existe · -3 sin permiso · -6 ya desactivada o con usuarios activos · 0 error</summary>
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
