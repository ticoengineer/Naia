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
    public class cls_Categorias_BLL
    {
        /// <summary>
        /// Trae todas las categorias de la institucion.
        /// Si bSoloActivas = true, solo trae las activas.
        /// Si bSoloActivas = false, trae todas (para la tabla del admin).
        /// </summary>
        public void Listar_Categorias(ref cls_Categorias_DAL obj_Categorias_DAL)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                // Armar los parametros del SP
                obj_Categorias_DAL.dtParametros = null;
                obj_Categorias_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj_Categorias_DAL.dtParametros);

                obj_Categorias_DAL.dtParametros.Rows.Add("@InstitucionId", "1", obj_Categorias_DAL.iInstitucionId);
                obj_Categorias_DAL.dtParametros.Rows.Add("@SoloActivas", "9", obj_Categorias_DAL.bSoloActivas);

                // Configurar y ejecutar
                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_LISTAR_CATEGORIAS"];
                obj_BD_DAL.sNomTabla = "Categorias";
                obj_BD_DAL.DT_Parametros = obj_Categorias_DAL.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                obj_Categorias_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj_Categorias_DAL.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables["Categorias"] : null;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// Filtra categorias por el texto que escriba el usuario en el buscador.
        /// </summary>
        public void Filtrar_Categorias(ref cls_Categorias_DAL obj_Categorias_DAL)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj_Categorias_DAL.dtParametros = null;
                obj_Categorias_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj_Categorias_DAL.dtParametros);

                obj_Categorias_DAL.dtParametros.Rows.Add("@InstitucionId", "1", obj_Categorias_DAL.iInstitucionId);
                obj_Categorias_DAL.dtParametros.Rows.Add("@Filtro", "7", obj_Categorias_DAL.sFiltro);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_FILTRAR_CATEGORIAS"];
                obj_BD_DAL.sNomTabla = "Categorias";
                obj_BD_DAL.DT_Parametros = obj_Categorias_DAL.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                obj_Categorias_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj_Categorias_DAL.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables["Categorias"] : null;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// Trae los datos de una categoria especifica para llenar el modal de edicion.
        /// </summary>
        public void Info_Categoria(ref cls_Categorias_DAL obj_Categorias_DAL)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj_Categorias_DAL.dtParametros = null;
                obj_Categorias_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj_Categorias_DAL.dtParametros);

                obj_Categorias_DAL.dtParametros.Rows.Add("@InstitucionId", "1", obj_Categorias_DAL.iInstitucionId);
                obj_Categorias_DAL.dtParametros.Rows.Add("@CategoriaId", "1", obj_Categorias_DAL.iCategoriaId);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_INFO_CATEGORIA"];
                obj_BD_DAL.sNomTabla = "Categoria";
                obj_BD_DAL.DT_Parametros = obj_Categorias_DAL.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                obj_Categorias_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj_Categorias_DAL.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables["Categoria"] : null;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// Crea una nueva categoria de tiquete.
        /// Incluye color, prioridad inicial, equipo predeterminado (opcional) y si requiere ubicacion fisica.
        /// </summary>
        public void Insertar_Categoria(ref cls_Categorias_DAL obj_Categorias_DAL)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj_Categorias_DAL.dtParametros = null;
                obj_Categorias_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj_Categorias_DAL.dtParametros);

                obj_Categorias_DAL.dtParametros.Rows.Add("@InstitucionId", "1", obj_Categorias_DAL.iInstitucionId);
                obj_Categorias_DAL.dtParametros.Rows.Add("@Nombre", "7", obj_Categorias_DAL.sNombre);
                obj_Categorias_DAL.dtParametros.Rows.Add("@Descripcion", "7", obj_Categorias_DAL.sDescripcion ?? (object)DBNull.Value);
                obj_Categorias_DAL.dtParametros.Rows.Add("@ColorHex", "4", obj_Categorias_DAL.sColorHex);
                obj_Categorias_DAL.dtParametros.Rows.Add("@PrioridadInicialId", "11", obj_Categorias_DAL.iPrioridadInicialId);

                // EquipoPredeterminadoId puede ser null si no se asigna equipo
                obj_Categorias_DAL.dtParametros.Rows.Add("@EquipoPredeterminadoId", "1",
                    obj_Categorias_DAL.iEquipoPredeterminadoId.HasValue
                        ? (object)obj_Categorias_DAL.iEquipoPredeterminadoId.Value
                        : (object)DBNull.Value);

                obj_Categorias_DAL.dtParametros.Rows.Add("@RequiereUbicacionFisica", "9", obj_Categorias_DAL.bRequiereUbicacionFisica);
                obj_Categorias_DAL.dtParametros.Rows.Add("@IdUsuarioGlobal", "1", obj_Categorias_DAL.iIdUsuarioGlobal);
                obj_Categorias_DAL.dtParametros.Rows.Add("@DireccionIp", "6", obj_Categorias_DAL.sDireccionIp);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_INSERTA_CATEGORIAS"];
                obj_BD_DAL.sIndAxn = "SCALAR";
                obj_BD_DAL.DT_Parametros = obj_Categorias_DAL.dtParametros;

                obj_BD_BLL.EjecutaProcesosComando(ref obj_BD_DAL);

                obj_Categorias_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj_Categorias_DAL.sValorScalar = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.sValorScalar : null;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// Actualiza los datos de una categoria existente.
        /// </summary>
        public void Actualizar_Categoria(ref cls_Categorias_DAL obj_Categorias_DAL)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj_Categorias_DAL.dtParametros = null;
                obj_Categorias_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj_Categorias_DAL.dtParametros);

                obj_Categorias_DAL.dtParametros.Rows.Add("@InstitucionId", "1", obj_Categorias_DAL.iInstitucionId);
                obj_Categorias_DAL.dtParametros.Rows.Add("@CategoriaId", "1", obj_Categorias_DAL.iCategoriaId);
                obj_Categorias_DAL.dtParametros.Rows.Add("@Nombre", "7", obj_Categorias_DAL.sNombre);
                obj_Categorias_DAL.dtParametros.Rows.Add("@Descripcion", "7", obj_Categorias_DAL.sDescripcion ?? (object)DBNull.Value);
                obj_Categorias_DAL.dtParametros.Rows.Add("@ColorHex", "4", obj_Categorias_DAL.sColorHex);
                obj_Categorias_DAL.dtParametros.Rows.Add("@PrioridadInicialId", "11", obj_Categorias_DAL.iPrioridadInicialId);

                // El equipo puede quedar sin asignar
                obj_Categorias_DAL.dtParametros.Rows.Add("@EquipoPredeterminadoId", "1",
                    obj_Categorias_DAL.iEquipoPredeterminadoId.HasValue
                        ? (object)obj_Categorias_DAL.iEquipoPredeterminadoId.Value
                        : (object)DBNull.Value);

                obj_Categorias_DAL.dtParametros.Rows.Add("@RequiereUbicacionFisica", "9", obj_Categorias_DAL.bRequiereUbicacionFisica);
                obj_Categorias_DAL.dtParametros.Rows.Add("@Activa", "9", obj_Categorias_DAL.bActiva);
                obj_Categorias_DAL.dtParametros.Rows.Add("@IdUsuarioGlobal", "1", obj_Categorias_DAL.iIdUsuarioGlobal);
                obj_Categorias_DAL.dtParametros.Rows.Add("@DireccionIp", "6", obj_Categorias_DAL.sDireccionIp);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_ACTUALIZA_CATEGORIAS"];
                obj_BD_DAL.sIndAxn = "SCALAR";
                obj_BD_DAL.DT_Parametros = obj_Categorias_DAL.dtParametros;

                obj_BD_BLL.EjecutaProcesosComando(ref obj_BD_DAL);

                obj_Categorias_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj_Categorias_DAL.sValorScalar = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.sValorScalar : null;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// Desactiva una categoria. No se elimina, solo se oculta para nuevos tiquetes.
        /// </summary>
        public void Eliminar_Categoria(ref cls_Categorias_DAL obj_Categorias_DAL)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj_Categorias_DAL.dtParametros = null;
                obj_Categorias_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj_Categorias_DAL.dtParametros);

                obj_Categorias_DAL.dtParametros.Rows.Add("@InstitucionId", "1", obj_Categorias_DAL.iInstitucionId);
                obj_Categorias_DAL.dtParametros.Rows.Add("@CategoriaId", "1", obj_Categorias_DAL.iCategoriaId);
                obj_Categorias_DAL.dtParametros.Rows.Add("@IdUsuarioGlobal", "1", obj_Categorias_DAL.iIdUsuarioGlobal);
                obj_Categorias_DAL.dtParametros.Rows.Add("@DireccionIp", "6", obj_Categorias_DAL.sDireccionIp);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_ELIMINA_CATEGORIAS"];
                obj_BD_DAL.sIndAxn = "SCALAR";
                obj_BD_DAL.DT_Parametros = obj_Categorias_DAL.dtParametros;

                obj_BD_BLL.EjecutaProcesosComando(ref obj_BD_DAL);

                obj_Categorias_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj_Categorias_DAL.sValorScalar = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.sValorScalar : null;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        // ========== METODOS AUXILIARES ==========
        // Estos se usan para llenar los dropdowns del formulario de categorias

        /// <summary>
        /// Trae la lista de prioridades (Baja, Media, Alta, Critica).
        /// No necesita InstitucionId porque las prioridades son globales.
        /// Se usa para el dropdown de "Prioridad Inicial" al crear/editar categoria.
        /// </summary>
        public void Listar_Prioridades(ref cls_Categorias_DAL obj_Categorias_DAL)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                // Este SP no lleva parametros
                obj_Categorias_DAL.dtParametros = null;
                obj_Categorias_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj_Categorias_DAL.dtParametros);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_LISTAR_PRIORIDADES"];
                obj_BD_DAL.sNomTabla = "Prioridades";
                obj_BD_DAL.DT_Parametros = obj_Categorias_DAL.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                obj_Categorias_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj_Categorias_DAL.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables["Prioridades"] : null;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// Trae la lista de equipos de soporte de la institucion.
        /// Se usa para el dropdown de "Equipo Predeterminado" al crear/editar categoria.
        /// </summary>
        public void Listar_Equipos(ref cls_Categorias_DAL obj_Categorias_DAL)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj_Categorias_DAL.dtParametros = null;
                obj_Categorias_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj_Categorias_DAL.dtParametros);

                obj_Categorias_DAL.dtParametros.Rows.Add("@InstitucionId", "1", obj_Categorias_DAL.iInstitucionId);
                obj_Categorias_DAL.dtParametros.Rows.Add("@SoloActivos", "9", obj_Categorias_DAL.bSoloActivas);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_LISTAR_EQUIPOS"];
                obj_BD_DAL.sNomTabla = "Equipos";
                obj_BD_DAL.DT_Parametros = obj_Categorias_DAL.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                obj_Categorias_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj_Categorias_DAL.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables["Equipos"] : null;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
    }
}
