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
    public class cls_Ubicaciones_BLL
    {
        /// <summary>
        /// Trae todas las ubicaciones de la institucion.
        /// Si bSoloActivas = true, solo trae las activas (para dropdowns).
        /// Si bSoloActivas = false, trae todas (para la tabla de mantenimiento).
        /// </summary>
        public void Listar_Ubicaciones(ref cls_Ubicaciones_DAL obj_Ubicaciones_DAL)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                // Armar los parametros que necesita el SP
                obj_Ubicaciones_DAL.dtParametros = null;
                obj_Ubicaciones_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj_Ubicaciones_DAL.dtParametros);

                obj_Ubicaciones_DAL.dtParametros.Rows.Add("@InstitucionId", "1", obj_Ubicaciones_DAL.iInstitucionId);
                obj_Ubicaciones_DAL.dtParametros.Rows.Add("@SoloActivas", "9", obj_Ubicaciones_DAL.bSoloActivas);

                // Configurar el SP a ejecutar
                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_LISTAR_UBICACIONES"];
                obj_BD_DAL.sNomTabla = "Ubicaciones";
                obj_BD_DAL.DT_Parametros = obj_Ubicaciones_DAL.dtParametros;

                // Ejecutar y guardar resultado
                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                obj_Ubicaciones_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj_Ubicaciones_DAL.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables["Ubicaciones"] : null;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// Busca ubicaciones que coincidan con el texto del buscador.
        /// </summary>
        public void Filtrar_Ubicaciones(ref cls_Ubicaciones_DAL obj_Ubicaciones_DAL)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj_Ubicaciones_DAL.dtParametros = null;
                obj_Ubicaciones_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj_Ubicaciones_DAL.dtParametros);

                obj_Ubicaciones_DAL.dtParametros.Rows.Add("@InstitucionId", "1", obj_Ubicaciones_DAL.iInstitucionId);
                obj_Ubicaciones_DAL.dtParametros.Rows.Add("@Filtro", "7", obj_Ubicaciones_DAL.sFiltro);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_FILTRAR_UBICACIONES"];
                obj_BD_DAL.sNomTabla = "Ubicaciones";
                obj_BD_DAL.DT_Parametros = obj_Ubicaciones_DAL.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                obj_Ubicaciones_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj_Ubicaciones_DAL.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables["Ubicaciones"] : null;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// Trae los datos de una sola ubicacion para cargarlos en el modal de edicion.
        /// </summary>
        public void Info_Ubicacion(ref cls_Ubicaciones_DAL obj_Ubicaciones_DAL)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj_Ubicaciones_DAL.dtParametros = null;
                obj_Ubicaciones_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj_Ubicaciones_DAL.dtParametros);

                obj_Ubicaciones_DAL.dtParametros.Rows.Add("@InstitucionId", "1", obj_Ubicaciones_DAL.iInstitucionId);
                obj_Ubicaciones_DAL.dtParametros.Rows.Add("@UbicacionId", "1", obj_Ubicaciones_DAL.iUbicacionId);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_INFO_UBICACION"];
                obj_BD_DAL.sNomTabla = "Ubicacion";
                obj_BD_DAL.DT_Parametros = obj_Ubicaciones_DAL.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                obj_Ubicaciones_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj_Ubicaciones_DAL.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables["Ubicacion"] : null;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// Crea una nueva ubicacion (fisica o virtual).
        /// El SP valida permisos, duplicados y que las fisicas tengan edificio.
        /// </summary>
        public void Insertar_Ubicacion(ref cls_Ubicaciones_DAL obj_Ubicaciones_DAL)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj_Ubicaciones_DAL.dtParametros = null;
                obj_Ubicaciones_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj_Ubicaciones_DAL.dtParametros);

                obj_Ubicaciones_DAL.dtParametros.Rows.Add("@InstitucionId", "1", obj_Ubicaciones_DAL.iInstitucionId);
                obj_Ubicaciones_DAL.dtParametros.Rows.Add("@Nombre", "7", obj_Ubicaciones_DAL.sNombre);
                obj_Ubicaciones_DAL.dtParametros.Rows.Add("@Edificio", "7", obj_Ubicaciones_DAL.sEdificio ?? (object)DBNull.Value);
                obj_Ubicaciones_DAL.dtParametros.Rows.Add("@EsFisica", "9", obj_Ubicaciones_DAL.bEsFisica);
                obj_Ubicaciones_DAL.dtParametros.Rows.Add("@IdUsuarioGlobal", "1", obj_Ubicaciones_DAL.iIdUsuarioGlobal);
                obj_Ubicaciones_DAL.dtParametros.Rows.Add("@DireccionIp", "6", obj_Ubicaciones_DAL.sDireccionIp);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_INSERTA_UBICACIONES"];
                obj_BD_DAL.sIndAxn = "SCALAR";
                obj_BD_DAL.DT_Parametros = obj_Ubicaciones_DAL.dtParametros;

                obj_BD_BLL.EjecutaProcesosComando(ref obj_BD_DAL);

                obj_Ubicaciones_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj_Ubicaciones_DAL.sValorScalar = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.sValorScalar : null;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// Actualiza una ubicacion existente. Tambien sirve para reactivar (Activa = true).
        /// </summary>
        public void Actualizar_Ubicacion(ref cls_Ubicaciones_DAL obj_Ubicaciones_DAL)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj_Ubicaciones_DAL.dtParametros = null;
                obj_Ubicaciones_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj_Ubicaciones_DAL.dtParametros);

                obj_Ubicaciones_DAL.dtParametros.Rows.Add("@InstitucionId", "1", obj_Ubicaciones_DAL.iInstitucionId);
                obj_Ubicaciones_DAL.dtParametros.Rows.Add("@UbicacionId", "1", obj_Ubicaciones_DAL.iUbicacionId);
                obj_Ubicaciones_DAL.dtParametros.Rows.Add("@Nombre", "7", obj_Ubicaciones_DAL.sNombre);
                obj_Ubicaciones_DAL.dtParametros.Rows.Add("@Edificio", "7", obj_Ubicaciones_DAL.sEdificio ?? (object)DBNull.Value);
                obj_Ubicaciones_DAL.dtParametros.Rows.Add("@EsFisica", "9", obj_Ubicaciones_DAL.bEsFisica);
                obj_Ubicaciones_DAL.dtParametros.Rows.Add("@Activa", "9", obj_Ubicaciones_DAL.bActiva);
                obj_Ubicaciones_DAL.dtParametros.Rows.Add("@IdUsuarioGlobal", "1", obj_Ubicaciones_DAL.iIdUsuarioGlobal);
                obj_Ubicaciones_DAL.dtParametros.Rows.Add("@DireccionIp", "6", obj_Ubicaciones_DAL.sDireccionIp);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_ACTUALIZA_UBICACIONES"];
                obj_BD_DAL.sIndAxn = "SCALAR";
                obj_BD_DAL.DT_Parametros = obj_Ubicaciones_DAL.dtParametros;

                obj_BD_BLL.EjecutaProcesosComando(ref obj_BD_DAL);

                obj_Ubicaciones_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj_Ubicaciones_DAL.sValorScalar = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.sValorScalar : null;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// Desactiva una ubicacion. No la borra, solo deja de aparecer al crear tiquetes.
        /// </summary>
        public void Eliminar_Ubicacion(ref cls_Ubicaciones_DAL obj_Ubicaciones_DAL)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj_Ubicaciones_DAL.dtParametros = null;
                obj_Ubicaciones_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj_Ubicaciones_DAL.dtParametros);

                obj_Ubicaciones_DAL.dtParametros.Rows.Add("@InstitucionId", "1", obj_Ubicaciones_DAL.iInstitucionId);
                obj_Ubicaciones_DAL.dtParametros.Rows.Add("@UbicacionId", "1", obj_Ubicaciones_DAL.iUbicacionId);
                obj_Ubicaciones_DAL.dtParametros.Rows.Add("@IdUsuarioGlobal", "1", obj_Ubicaciones_DAL.iIdUsuarioGlobal);
                obj_Ubicaciones_DAL.dtParametros.Rows.Add("@DireccionIp", "6", obj_Ubicaciones_DAL.sDireccionIp);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_ELIMINA_UBICACIONES"];
                obj_BD_DAL.sIndAxn = "SCALAR";
                obj_BD_DAL.DT_Parametros = obj_Ubicaciones_DAL.dtParametros;

                obj_BD_BLL.EjecutaProcesosComando(ref obj_BD_DAL);

                obj_Ubicaciones_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj_Ubicaciones_DAL.sValorScalar = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.sValorScalar : null;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
    }
}
