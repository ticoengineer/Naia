using DAL_Naia_ASPNET.BD;
using DAL_Naia_ASPNET.Entidades;
using BLL_Naia_ASPNET.BD;
using System.Configuration;
using System.Data;

namespace BLL_Naia_ASPNET.Entidades
{
    public class cls_Usuarios_BLL
    {
        // ==================== LISTAR ====================
        public void Listar_Usuarios(ref cls_Usuarios_DAL obj_DAL)
        {
            cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
            cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

            obj_BD_DAL.sNombreBD = "Usuarios";
            obj_BD_DAL.sNombreSP = ConfigurationManager.AppSettings["SP_LISTAR_USUARIOS"];
            obj_BD_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros();

            DataRow fila;
            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@InstitucionId";
            fila["sTipoDato"] = "1";
            fila["sValor"] = obj_DAL.iInstitucionId;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);
            obj_DAL.dtDatos = obj_BD_DAL.dtDatos;
            obj_DAL.sMSJError = obj_BD_DAL.sMSJError;
        }

        // ==================== FILTRAR ====================
        public void Filtrar_Usuarios(ref cls_Usuarios_DAL obj_DAL)
        {
            cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
            cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

            obj_BD_DAL.sNombreBD = "Usuarios";
            obj_BD_DAL.sNombreSP = ConfigurationManager.AppSettings["SP_FILTRAR_USUARIOS"];
            obj_BD_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros();

            DataRow fila;
            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@InstitucionId";
            fila["sTipoDato"] = "1";
            fila["sValor"] = obj_DAL.iInstitucionId;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@Filtro";
            fila["sTipoDato"] = "7";
            fila["sValor"] = obj_DAL.sFiltro;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);
            obj_DAL.dtDatos = obj_BD_DAL.dtDatos;
            obj_DAL.sMSJError = obj_BD_DAL.sMSJError;
        }

        // ==================== INFO ====================
        public void Info_Usuario(ref cls_Usuarios_DAL obj_DAL)
        {
            cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
            cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

            obj_BD_DAL.sNombreBD = "Usuarios";
            obj_BD_DAL.sNombreSP = ConfigurationManager.AppSettings["SP_INFO_USUARIO"];
            obj_BD_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros();

            DataRow fila;
            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@InstitucionId";
            fila["sTipoDato"] = "1";
            fila["sValor"] = obj_DAL.iInstitucionId;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@UsuarioId";
            fila["sTipoDato"] = "1";
            fila["sValor"] = obj_DAL.iUsuarioId;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);
            obj_DAL.dtDatos = obj_BD_DAL.dtDatos;
            obj_DAL.sMSJError = obj_BD_DAL.sMSJError;
        }

        // ==================== INSERTAR ====================
        public void Insertar_Usuario(ref cls_Usuarios_DAL obj_DAL)
        {
            cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
            cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

            obj_BD_DAL.sNombreBD = "Usuarios";
            obj_BD_DAL.sNombreSP = ConfigurationManager.AppSettings["SP_INSERTA_USUARIOS"];
            obj_BD_DAL.sIndAxn = "SCALAR";
            obj_BD_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros();

            DataRow fila;
            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@InstitucionId";
            fila["sTipoDato"] = "1";
            fila["sValor"] = obj_DAL.iInstitucionId;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@RolId";
            fila["sTipoDato"] = "1";
            fila["sValor"] = obj_DAL.iRolId;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@CarreraId";
            fila["sTipoDato"] = obj_DAL.iCarreraId == 0 ? "0" : "1";
            fila["sValor"] = obj_DAL.iCarreraId == 0 ? (object)System.DBNull.Value : obj_DAL.iCarreraId;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@DepartamentoId";
            fila["sTipoDato"] = obj_DAL.iDepartamentoId == 0 ? "0" : "1";
            fila["sValor"] = obj_DAL.iDepartamentoId == 0 ? (object)System.DBNull.Value : obj_DAL.iDepartamentoId;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@EquipoId";
            fila["sTipoDato"] = obj_DAL.iEquipoId == 0 ? "0" : "1";
            fila["sValor"] = obj_DAL.iEquipoId == 0 ? (object)System.DBNull.Value : obj_DAL.iEquipoId;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@TipoIdentificacionId";
            fila["sTipoDato"] = "1";
            fila["sValor"] = obj_DAL.iTipoIdentificacionId;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@Identificacion";
            fila["sTipoDato"] = "6";
            fila["sValor"] = obj_DAL.sIdentificacion;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@NumeroInterno";
            fila["sTipoDato"] = "6";
            fila["sValor"] = obj_DAL.sNumeroInterno;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@Nombre";
            fila["sTipoDato"] = "7";
            fila["sValor"] = obj_DAL.sNombre;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@Apellidos";
            fila["sTipoDato"] = "7";
            fila["sValor"] = obj_DAL.sApellidos;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@Correo";
            fila["sTipoDato"] = "6";
            fila["sValor"] = obj_DAL.sCorreo;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@Contrasena";
            fila["sTipoDato"] = "6";
            fila["sValor"] = obj_DAL.sContrasena;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@IdUsuarioGlobal";
            fila["sTipoDato"] = "1";
            fila["sValor"] = obj_DAL.iIdUsuarioGlobal;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@DireccionIp";
            fila["sTipoDato"] = "6";
            fila["sValor"] = obj_DAL.sDireccionIp;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            obj_BD_BLL.EjecutaProcesosComando(ref obj_BD_DAL);
            obj_DAL.sValorScalar = obj_BD_DAL.sValorScalar;
            obj_DAL.sMSJError = obj_BD_DAL.sMSJError;
        }

        // ==================== ACTUALIZAR ====================
        public void Actualizar_Usuario(ref cls_Usuarios_DAL obj_DAL)
        {
            cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
            cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

            obj_BD_DAL.sNombreBD = "Usuarios";
            obj_BD_DAL.sNombreSP = ConfigurationManager.AppSettings["SP_ACTUALIZA_USUARIOS"];
            obj_BD_DAL.sIndAxn = "SCALAR";
            obj_BD_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros();

            DataRow fila;
            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@InstitucionId";
            fila["sTipoDato"] = "1";
            fila["sValor"] = obj_DAL.iInstitucionId;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@UsuarioId";
            fila["sTipoDato"] = "1";
            fila["sValor"] = obj_DAL.iUsuarioId;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@RolId";
            fila["sTipoDato"] = "1";
            fila["sValor"] = obj_DAL.iRolId;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@CarreraId";
            fila["sTipoDato"] = obj_DAL.iCarreraId == 0 ? "0" : "1";
            fila["sValor"] = obj_DAL.iCarreraId == 0 ? (object)System.DBNull.Value : obj_DAL.iCarreraId;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@DepartamentoId";
            fila["sTipoDato"] = obj_DAL.iDepartamentoId == 0 ? "0" : "1";
            fila["sValor"] = obj_DAL.iDepartamentoId == 0 ? (object)System.DBNull.Value : obj_DAL.iDepartamentoId;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@EquipoId";
            fila["sTipoDato"] = obj_DAL.iEquipoId == 0 ? "0" : "1";
            fila["sValor"] = obj_DAL.iEquipoId == 0 ? (object)System.DBNull.Value : obj_DAL.iEquipoId;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@TipoIdentificacionId";
            fila["sTipoDato"] = "1";
            fila["sValor"] = obj_DAL.iTipoIdentificacionId;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@Identificacion";
            fila["sTipoDato"] = "6";
            fila["sValor"] = obj_DAL.sIdentificacion;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@NumeroInterno";
            fila["sTipoDato"] = "6";
            fila["sValor"] = obj_DAL.sNumeroInterno;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@Nombre";
            fila["sTipoDato"] = "7";
            fila["sValor"] = obj_DAL.sNombre;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@Apellidos";
            fila["sTipoDato"] = "7";
            fila["sValor"] = obj_DAL.sApellidos;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@Correo";
            fila["sTipoDato"] = "6";
            fila["sValor"] = obj_DAL.sCorreo;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@Contrasena";
            fila["sTipoDato"] = string.IsNullOrEmpty(obj_DAL.sContrasena) ? "0" : "6";
            fila["sValor"] = string.IsNullOrEmpty(obj_DAL.sContrasena) ? (object)System.DBNull.Value : obj_DAL.sContrasena;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@Activo";
            fila["sTipoDato"] = "9";
            fila["sValor"] = obj_DAL.bActivo;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@IdUsuarioGlobal";
            fila["sTipoDato"] = "1";
            fila["sValor"] = obj_DAL.iIdUsuarioGlobal;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@DireccionIp";
            fila["sTipoDato"] = "6";
            fila["sValor"] = obj_DAL.sDireccionIp;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            obj_BD_BLL.EjecutaProcesosComando(ref obj_BD_DAL);
            obj_DAL.sValorScalar = obj_BD_DAL.sValorScalar;
            obj_DAL.sMSJError = obj_BD_DAL.sMSJError;
        }

        // ==================== ELIMINAR (DESACTIVAR) ====================
        public void Eliminar_Usuario(ref cls_Usuarios_DAL obj_DAL)
        {
            cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
            cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

            obj_BD_DAL.sNombreBD = "Usuarios";
            obj_BD_DAL.sNombreSP = ConfigurationManager.AppSettings["SP_ELIMINA_USUARIOS"];
            obj_BD_DAL.sIndAxn = "SCALAR";
            obj_BD_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros();

            DataRow fila;
            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@InstitucionId";
            fila["sTipoDato"] = "1";
            fila["sValor"] = obj_DAL.iInstitucionId;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@UsuarioId";
            fila["sTipoDato"] = "1";
            fila["sValor"] = obj_DAL.iUsuarioId;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@IdUsuarioGlobal";
            fila["sTipoDato"] = "1";
            fila["sValor"] = obj_DAL.iIdUsuarioGlobal;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            fila = obj_BD_DAL.dtParametros.NewRow();
            fila["sParametro"] = "@DireccionIp";
            fila["sTipoDato"] = "6";
            fila["sValor"] = obj_DAL.sDireccionIp;
            obj_BD_DAL.dtParametros.Rows.Add(fila);

            obj_BD_BLL.EjecutaProcesosComando(ref obj_BD_DAL);
            obj_DAL.sValorScalar = obj_BD_DAL.sValorScalar;
            obj_DAL.sMSJError = obj_BD_DAL.sMSJError;
        }
    }
}
