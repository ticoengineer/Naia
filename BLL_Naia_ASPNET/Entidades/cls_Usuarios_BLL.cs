using BLL_Naia_ASPNET.BD;
using DAL_Naia_ASPNET.BD;
using DAL_Naia_ASPNET.Entidades;
using System;
using System.Configuration;

namespace BLL_Naia_ASPNET.Entidades
{
    public class cls_Usuarios_BLL
    {
        // ==================== LISTAR ====================
        public void Listar_Usuarios(ref cls_Usuarios_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);
                obj.dtParametros.Rows.Add("@InstitucionId", "1", obj.iInstitucionId);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_LISTAR_USUARIOS"];
                obj_BD_DAL.sNomTabla = "Usuarios";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables["Usuarios"] : null;
            }
            catch (Exception ex) { throw ex; }
        }

        // ==================== FILTRAR ====================
        public void Filtrar_Usuarios(ref cls_Usuarios_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);
                obj.dtParametros.Rows.Add("@InstitucionId", "1", obj.iInstitucionId);
                obj.dtParametros.Rows.Add("@Filtro", "7", obj.sFiltro);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_FILTRAR_USUARIOS"];
                obj_BD_DAL.sNomTabla = "Usuarios";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables["Usuarios"] : null;
            }
            catch (Exception ex) { throw ex; }
        }

        // ==================== INFO ====================
        public void Info_Usuario(ref cls_Usuarios_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);
                obj.dtParametros.Rows.Add("@InstitucionId", "1", obj.iInstitucionId);
                obj.dtParametros.Rows.Add("@UsuarioId", "1", obj.iUsuarioId);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_INFO_USUARIO"];
                obj_BD_DAL.sNomTabla = "Usuario";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables["Usuario"] : null;
            }
            catch (Exception ex) { throw ex; }
        }

        // ==================== INSERTAR ====================
        public void Insertar_Usuario(ref cls_Usuarios_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);
                obj.dtParametros.Rows.Add("@InstitucionId", "1", obj.iInstitucionId);
                obj.dtParametros.Rows.Add("@RolId", "1", obj.iRolId);

                // CarreraId - NULL si es 0
                obj.dtParametros.Rows.Add("@CarreraId",
                    obj.iCarreraId == 0 ? "0" : "1",
                    obj.iCarreraId == 0 ? (object)System.DBNull.Value : obj.iCarreraId);

                // DepartamentoId - NULL si es 0
                obj.dtParametros.Rows.Add("@DepartamentoId",
                    obj.iDepartamentoId == 0 ? "0" : "1",
                    obj.iDepartamentoId == 0 ? (object)System.DBNull.Value : obj.iDepartamentoId);

                // EquipoId - NULL si es 0
                obj.dtParametros.Rows.Add("@EquipoId",
                    obj.iEquipoId == 0 ? "0" : "1",
                    obj.iEquipoId == 0 ? (object)System.DBNull.Value : obj.iEquipoId);

                obj.dtParametros.Rows.Add("@TipoIdentificacionId", "1", obj.iTipoIdentificacionId);
                obj.dtParametros.Rows.Add("@Identificacion", "6", obj.sIdentificacion);
                obj.dtParametros.Rows.Add("@NumeroInterno", "6", obj.sNumeroInterno);
                obj.dtParametros.Rows.Add("@Nombre", "7", obj.sNombre);
                obj.dtParametros.Rows.Add("@Apellidos", "7", obj.sApellidos);
                obj.dtParametros.Rows.Add("@Correo", "6", obj.sCorreo);
                obj.dtParametros.Rows.Add("@Contrasena", "6", obj.sContrasena);
                obj.dtParametros.Rows.Add("@IdUsuarioGlobal", "1", obj.iIdUsuarioGlobal);
                obj.dtParametros.Rows.Add("@DireccionIp", "6", obj.sDireccionIp);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_INSERTA_USUARIOS"];
                obj_BD_DAL.sIndAxn = "SCALAR";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosComando(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj.sValorScalar = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.sValorScalar : null;
            }
            catch (Exception ex) { throw ex; }
        }

        // ==================== ACTUALIZAR ====================
        public void Actualizar_Usuario(ref cls_Usuarios_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);
                obj.dtParametros.Rows.Add("@InstitucionId", "1", obj.iInstitucionId);
                obj.dtParametros.Rows.Add("@UsuarioId", "1", obj.iUsuarioId);
                obj.dtParametros.Rows.Add("@RolId", "1", obj.iRolId);

                // CarreraId - NULL si es 0
                obj.dtParametros.Rows.Add("@CarreraId",
                    obj.iCarreraId == 0 ? "0" : "1",
                    obj.iCarreraId == 0 ? (object)System.DBNull.Value : obj.iCarreraId);

                // DepartamentoId - NULL si es 0
                obj.dtParametros.Rows.Add("@DepartamentoId",
                    obj.iDepartamentoId == 0 ? "0" : "1",
                    obj.iDepartamentoId == 0 ? (object)System.DBNull.Value : obj.iDepartamentoId);

                // EquipoId - NULL si es 0
                obj.dtParametros.Rows.Add("@EquipoId",
                    obj.iEquipoId == 0 ? "0" : "1",
                    obj.iEquipoId == 0 ? (object)System.DBNull.Value : obj.iEquipoId);

                obj.dtParametros.Rows.Add("@TipoIdentificacionId", "1", obj.iTipoIdentificacionId);
                obj.dtParametros.Rows.Add("@Identificacion", "6", obj.sIdentificacion);
                obj.dtParametros.Rows.Add("@NumeroInterno", "6", obj.sNumeroInterno);
                obj.dtParametros.Rows.Add("@Nombre", "7", obj.sNombre);
                obj.dtParametros.Rows.Add("@Apellidos", "7", obj.sApellidos);
                obj.dtParametros.Rows.Add("@Correo", "6", obj.sCorreo);

                // Contrasena - NULL si viene vacía (no cambiar)
                obj.dtParametros.Rows.Add("@Contrasena",
                    string.IsNullOrEmpty(obj.sContrasena) ? "0" : "6",
                    string.IsNullOrEmpty(obj.sContrasena) ? (object)System.DBNull.Value : obj.sContrasena);

                obj.dtParametros.Rows.Add("@Activo", "9", obj.bActivo);
                obj.dtParametros.Rows.Add("@IdUsuarioGlobal", "1", obj.iIdUsuarioGlobal);
                obj.dtParametros.Rows.Add("@DireccionIp", "6", obj.sDireccionIp);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_ACTUALIZA_USUARIOS"];
                obj_BD_DAL.sIndAxn = "SCALAR";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosComando(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj.sValorScalar = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.sValorScalar : null;
            }
            catch (Exception ex) { throw ex; }
        }

        // ==================== ELIMINAR (DESACTIVAR) ====================
        public void Eliminar_Usuario(ref cls_Usuarios_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);
                obj.dtParametros.Rows.Add("@InstitucionId", "1", obj.iInstitucionId);
                obj.dtParametros.Rows.Add("@UsuarioId", "1", obj.iUsuarioId);
                obj.dtParametros.Rows.Add("@IdUsuarioGlobal", "1", obj.iIdUsuarioGlobal);
                obj.dtParametros.Rows.Add("@DireccionIp", "6", obj.sDireccionIp);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_ELIMINA_USUARIOS"];
                obj_BD_DAL.sIndAxn = "SCALAR";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosComando(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj.sValorScalar = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.sValorScalar : null;
            }
            catch (Exception ex) { throw ex; }
        }
    
        // ==================== INICIAR & CERRAR SESION ====================
        public void Iniciar_Sesion(ref cls_Usuarios_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);
                obj.dtParametros.Rows.Add("@Correo", "6", obj.sCorreo);
                obj.dtParametros.Rows.Add("@Contrasena", "6", obj.sContrasena);
                obj.dtParametros.Rows.Add("@DireccionIp", "6", obj.sDireccionIp);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_INICIAR_SESION"];
                obj_BD_DAL.sNomTabla = "Sesion";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables["Sesion"] : null;
            }
            catch (Exception ex) { throw ex; }
        }

        /// <summary>
        /// SP_CERRAR_SESION: registra el cierre de sesión en la auditoría.
        /// Devuelve en sValorScalar: > 0 éxito · -2 usuario no existe · 0 error
        /// </summary>
        public void Cerrar_Sesion(ref cls_Usuarios_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);
                obj.dtParametros.Rows.Add("@InstitucionId", "1", obj.iInstitucionId);
                obj.dtParametros.Rows.Add("@IdUsuarioGlobal", "1", obj.iIdUsuarioGlobal);
                obj.dtParametros.Rows.Add("@DireccionIp", "6", obj.sDireccionIp);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_CERRAR_SESION"];
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
