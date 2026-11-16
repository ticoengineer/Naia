using BLL_Naia_ASPNET.BD;
using DAL_Naia_ASPNET.BD;
using DAL_Naia_ASPNET.Entidades;
using System;
using System.Configuration;

namespace BLL_Naia_ASPNET.Entidades
{
    public class cls_Equipos_BLL
    {
        public void Listar_Equipos(ref cls_Equipos_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);
                obj.dtParametros.Rows.Add("@InstitucionId", "1", obj.iInstitucionId);
                obj.dtParametros.Rows.Add("@SoloActivos", "9", false);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_LISTAR_EQUIPOS"];
                obj_BD_DAL.sNomTabla = "Equipos";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables["Equipos"] : null;
            }
            catch (Exception ex) { throw ex; }
        }

        public void Filtrar_Equipos(ref cls_Equipos_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);
                obj.dtParametros.Rows.Add("@InstitucionId", "1", obj.iInstitucionId);
                obj.dtParametros.Rows.Add("@Filtro", "7", obj.sFiltro);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_FILTRAR_EQUIPOS"];
                obj_BD_DAL.sNomTabla = "Equipos";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables["Equipos"] : null;
            }
            catch (Exception ex) { throw ex; }
        }

        public void Info_Equipo(ref cls_Equipos_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);
                obj.dtParametros.Rows.Add("@InstitucionId", "1", obj.iInstitucionId);
                obj.dtParametros.Rows.Add("@EquipoId", "1", obj.iEquipoId);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_INFO_EQUIPO"];
                obj_BD_DAL.sNomTabla = "Equipo";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables["Equipo"] : null;
            }
            catch (Exception ex) { throw ex; }
        }

        public void Insertar_Equipo(ref cls_Equipos_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);
                obj.dtParametros.Rows.Add("@InstitucionId", "1", obj.iInstitucionId);
                obj.dtParametros.Rows.Add("@Nombre", "7", obj.sNombre);
                obj.dtParametros.Rows.Add("@Descripcion", "7", obj.sDescripcion ?? (object)System.DBNull.Value);
                obj.dtParametros.Rows.Add("@IdUsuarioGlobal", "1", obj.iIdUsuarioGlobal);
                obj.dtParametros.Rows.Add("@DireccionIp", "6", obj.sDireccionIp);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_INSERTA_EQUIPOS"];
                obj_BD_DAL.sIndAxn = "SCALAR";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosComando(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj.sValorScalar = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.sValorScalar : null;
            }
            catch (Exception ex) { throw ex; }
        }

        public void Actualizar_Equipo(ref cls_Equipos_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);
                obj.dtParametros.Rows.Add("@InstitucionId", "1", obj.iInstitucionId);
                obj.dtParametros.Rows.Add("@EquipoId", "1", obj.iEquipoId);
                obj.dtParametros.Rows.Add("@Nombre", "7", obj.sNombre);
                obj.dtParametros.Rows.Add("@Descripcion", "7", obj.sDescripcion ?? (object)System.DBNull.Value);
                obj.dtParametros.Rows.Add("@Activo", "9", obj.bActivo);
                obj.dtParametros.Rows.Add("@IdUsuarioGlobal", "1", obj.iIdUsuarioGlobal);
                obj.dtParametros.Rows.Add("@DireccionIp", "6", obj.sDireccionIp);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_ACTUALIZA_EQUIPOS"];
                obj_BD_DAL.sIndAxn = "SCALAR";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosComando(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj.sValorScalar = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.sValorScalar : null;
            }
            catch (Exception ex) { throw ex; }
        }

        public void Eliminar_Equipo(ref cls_Equipos_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);
                obj.dtParametros.Rows.Add("@InstitucionId", "1", obj.iInstitucionId);
                obj.dtParametros.Rows.Add("@EquipoId", "1", obj.iEquipoId);
                obj.dtParametros.Rows.Add("@IdUsuarioGlobal", "1", obj.iIdUsuarioGlobal);
                obj.dtParametros.Rows.Add("@DireccionIp", "6", obj.sDireccionIp);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_ELIMINA_EQUIPOS"];
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
