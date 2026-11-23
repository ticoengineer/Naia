using BLL_Naia_ASPNET.BD;
using DAL_Naia_ASPNET.BD;
using DAL_Naia_ASPNET.Entidades;
using System;
using System.Configuration;

namespace BLL_Naia_ASPNET.Entidades
{
    /// <summary>
    /// Departamentos de la universidad (soporte técnico y administrativos pertenecen a uno).
    /// Los parámetros coinciden EXACTAMENTE con los SP de storedProcedures_Script.sql.
    /// </summary>
    public class cls_Departamentos_BLL
    {
        /// <summary>SP_LISTAR_DEPARTAMENTOS: bSoloActivos = false para el mantenimiento (ve todas), true para combos.</summary>
        public void Listar_Departamentos(ref cls_Departamentos_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);
                obj.dtParametros.Rows.Add("@InstitucionId", "1", obj.iInstitucionId);
                obj.dtParametros.Rows.Add("@SoloActivos", "9", obj.bSoloActivos);
                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_LISTAR_DEPARTAMENTOS"];
                obj_BD_DAL.sNomTabla = "Departamentos";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables["Departamentos"] : null;
            }
            catch (Exception ex) { throw ex; }
        }

        /// <summary>SP_FILTRAR_DEPARTAMENTOS: busca por nombre.</summary>
        public void Filtrar_Departamentos(ref cls_Departamentos_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);
                obj.dtParametros.Rows.Add("@InstitucionId", "1", obj.iInstitucionId);
                obj.dtParametros.Rows.Add("@Filtro", "7", obj.sFiltro);
                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_FILTRAR_DEPARTAMENTOS"];
                obj_BD_DAL.sNomTabla = "Departamentos";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables["Departamentos"] : null;
            }
            catch (Exception ex) { throw ex; }
        }

        /// <summary>SP_INFO_DEPARTAMENTO: un solo departamento (para editar).</summary>
        public void Info_Departamento(ref cls_Departamentos_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);
                obj.dtParametros.Rows.Add("@InstitucionId", "1", obj.iInstitucionId);
                obj.dtParametros.Rows.Add("@DepartamentoId", "1", obj.iDepartamentoId);
                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_INFO_DEPARTAMENTO"];
                obj_BD_DAL.sNomTabla = "Departamentos";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables["Departamentos"] : null;
            }
            catch (Exception ex) { throw ex; }
        }

        /// <summary>SP_INSERTA_DEPARTAMENTOS · sValorScalar: > 0 DepartamentoId · -1 nombre repetido · -3 sin permiso · -4 nombre vacío · 0 error</summary>
        public void Insertar_Departamento(ref cls_Departamentos_DAL obj)
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
                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_INSERTA_DEPARTAMENTOS"];
                obj_BD_DAL.sIndAxn = "SCALAR";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosComando(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj.sValorScalar = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.sValorScalar : null;
            }
            catch (Exception ex) { throw ex; }
        }

        /// <summary>SP_ACTUALIZA_DEPARTAMENTOS · -1 nombre repetido · -2 no existe · -3 sin permiso · -4 nombre vacío · -6 tiene usuarios activos o es Administración General · 0 error</summary>
        public void Actualizar_Departamento(ref cls_Departamentos_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);
                obj.dtParametros.Rows.Add("@InstitucionId", "1", obj.iInstitucionId);
                obj.dtParametros.Rows.Add("@DepartamentoId", "1", obj.iDepartamentoId);
                obj.dtParametros.Rows.Add("@Nombre", "7", obj.sNombre);
                obj.dtParametros.Rows.Add("@Activo", "9", obj.bActivo);
                obj.dtParametros.Rows.Add("@IdUsuarioGlobal", "1", obj.iIdUsuarioGlobal);
                obj.dtParametros.Rows.Add("@DireccionIp", "6", obj.sDireccionIp);
                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_ACTUALIZA_DEPARTAMENTOS"];
                obj_BD_DAL.sIndAxn = "SCALAR";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosComando(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj.sValorScalar = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.sValorScalar : null;
            }
            catch (Exception ex) { throw ex; }
        }

        /// <summary>SP_ELIMINA_DEPARTAMENTOS (desactiva) · -2 no existe · -3 sin permiso · -6 ya desactivado, con usuarios activos o es Administración General · 0 error</summary>
        public void Eliminar_Departamento(ref cls_Departamentos_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);
                obj.dtParametros.Rows.Add("@InstitucionId", "1", obj.iInstitucionId);
                obj.dtParametros.Rows.Add("@DepartamentoId", "1", obj.iDepartamentoId);
                obj.dtParametros.Rows.Add("@IdUsuarioGlobal", "1", obj.iIdUsuarioGlobal);
                obj.dtParametros.Rows.Add("@DireccionIp", "6", obj.sDireccionIp);
                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_ELIMINA_DEPARTAMENTOS"];
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
