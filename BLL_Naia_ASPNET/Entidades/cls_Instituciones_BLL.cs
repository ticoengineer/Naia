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
	public class cls_Usuarios_BLL
	{
		/* =========================================================================
           1. CONSULTAS (LISTAR, FILTRAR, INFO Y CATÁLOGOS)
           ========================================================================= */
		public void Listar_Usuarios(ref cls_Usuarios_DAL obj_Usuarios_DAL)
		{
			try
			{
				cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
				cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

				obj_Usuarios_DAL.dtParametros = null;
				obj_Usuarios_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj_Usuarios_DAL.dtParametros);

				obj_Usuarios_DAL.dtParametros.Rows.Add("@InstitucionId", "1", obj_Usuarios_DAL.iInstitucionId);

				obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_LISTAR_USUARIOS"];
				obj_BD_DAL.sIndAxn = "NORMAL";
				obj_BD_DAL.DT_Parametros = obj_Usuarios_DAL.dtParametros;

				obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

				obj_Usuarios_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
				obj_Usuarios_DAL.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables[0] : null;
			}
			catch (Exception ex)
			{
				throw ex;
			}
		}

		public void Filtrar_Usuarios(ref cls_Usuarios_DAL obj_Usuarios_DAL)
		{
			try
			{
				cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
				cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

				obj_Usuarios_DAL.dtParametros = null;
				obj_Usuarios_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj_Usuarios_DAL.dtParametros);

				obj_Usuarios_DAL.dtParametros.Rows.Add("@InstitucionId", "1", obj_Usuarios_DAL.iInstitucionId);
				obj_Usuarios_DAL.dtParametros.Rows.Add("@Filtro", "7", obj_Usuarios_DAL.sFiltro);

				obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_FILTRAR_USUARIOS"];
				obj_BD_DAL.sIndAxn = "NORMAL";
				obj_BD_DAL.DT_Parametros = obj_Usuarios_DAL.dtParametros;

				obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

				obj_Usuarios_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
				obj_Usuarios_DAL.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables[0] : null;
			}
			catch (Exception ex)
			{
				throw ex;
			}
		}

		public void Info_Usuario(ref cls_Usuarios_DAL obj_Usuarios_DAL)
		{
			try
			{
				cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
				cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

				obj_Usuarios_DAL.dtParametros = null;
				obj_Usuarios_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj_Usuarios_DAL.dtParametros);

				obj_Usuarios_DAL.dtParametros.Rows.Add("@InstitucionId", "1", obj_Usuarios_DAL.iInstitucionId);
				obj_Usuarios_DAL.dtParametros.Rows.Add("@UsuarioId", "1", obj_Usuarios_DAL.iUsuarioId);

				obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_INFO_USUARIO"];
				obj_BD_DAL.sIndAxn = "NORMAL";
				obj_BD_DAL.DT_Parametros = obj_Usuarios_DAL.dtParametros;

				obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

				obj_Usuarios_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
				obj_Usuarios_DAL.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables[0] : null;
			}
			catch (Exception ex)
			{
				throw ex;
			}
		}

		public void Listar_Catalogo(string llaveAppSettings, int? institucionId, ref cls_Usuarios_DAL obj_Usuarios_DAL)
		{
			try
			{
				cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
				cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

				obj_Usuarios_DAL.dtParametros = null;
				obj_Usuarios_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj_Usuarios_DAL.dtParametros);

				if (institucionId.HasValue)
				{
					obj_Usuarios_DAL.dtParametros.Rows.Add("@InstitucionId", "1", institucionId.Value);
				}

				obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings[llaveAppSettings];
				obj_BD_DAL.sIndAxn = "NORMAL";
				obj_BD_DAL.DT_Parametros = obj_Usuarios_DAL.dtParametros;

				obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

				obj_Usuarios_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
				obj_Usuarios_DAL.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables[0] : null;
			}
			catch (Exception ex)
			{
				throw ex;
			}
		}

		/* =========================================================================
           2. ESCRITURA (INSERTAR, ACTUALIZAR/REACTIVAR, DESACTIVAR)
           ========================================================================= */
		public void Insertar_Usuario(ref cls_Usuarios_DAL obj_Usuarios_DAL)
		{
			try
			{
				cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
				cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

				obj_Usuarios_DAL.dtParametros = null;
				obj_Usuarios_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj_Usuarios_DAL.dtParametros);

				obj_Usuarios_DAL.dtParametros.Rows.Add("@InstitucionId", "1", obj_Usuarios_DAL.iInstitucionId);
				obj_Usuarios_DAL.dtParametros.Rows.Add("@RolId", "11", obj_Usuarios_DAL.iRolId);
				obj_Usuarios_DAL.dtParametros.Rows.Add("@TipoIdentificacionId", "11", obj_Usuarios_DAL.iTipoIdentificacionId);
				obj_Usuarios_DAL.dtParametros.Rows.Add("@Identificacion", "6", obj_Usuarios_DAL.sIdentificacion);
				obj_Usuarios_DAL.dtParametros.Rows.Add("@NumeroInterno", "6", obj_Usuarios_DAL.sNumeroInterno);
				obj_Usuarios_DAL.dtParametros.Rows.Add("@Nombre", "7", obj_Usuarios_DAL.sNombre);
				obj_Usuarios_DAL.dtParametros.Rows.Add("@Apellidos", "7", obj_Usuarios_DAL.sApellidos);
				obj_Usuarios_DAL.dtParametros.Rows.Add("@Correo", "6", obj_Usuarios_DAL.sCorreo);
				obj_Usuarios_DAL.dtParametros.Rows.Add("@Contrasena", "6", obj_Usuarios_DAL.sContrasena);
				obj_Usuarios_DAL.dtParametros.Rows.Add("@CarreraId", "1", (object)obj_Usuarios_DAL.iCarreraId ?? DBNull.Value);
				obj_Usuarios_DAL.dtParametros.Rows.Add("@DepartamentoId", "1", (object)obj_Usuarios_DAL.iDepartamentoId ?? DBNull.Value);
				obj_Usuarios_DAL.dtParametros.Rows.Add("@EquipoId", "1", (object)obj_Usuarios_DAL.iEquipoId ?? DBNull.Value);
				obj_Usuarios_DAL.dtParametros.Rows.Add("@IdUsuarioGlobal", "1", obj_Usuarios_DAL.iIdUsuarioGlobal);
				obj_Usuarios_DAL.dtParametros.Rows.Add("@DireccionIp", "6", obj_Usuarios_DAL.sDireccionIp);

				obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_INSERTA_USUARIOS"];
				obj_BD_DAL.sIndAxn = "SCALAR";
				obj_BD_DAL.DT_Parametros = obj_Usuarios_DAL.dtParametros;

				obj_BD_BLL.EjecutaProcesosComando(ref obj_BD_DAL);

				obj_Usuarios_DAL.sMSJError = obj_BD_DAL.sMsjErrorBD;
				obj_Usuarios_DAL.sValorScalar = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.sValorScalar : null;
			}
			catch (Exception ex)
			{
				throw ex;
			}
		}

		public void Actualizar_Usuario(ref cls_Usuarios_DAL obj_Usuarios_DAL)
		{
			try
			{
				cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
				cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

				obj_Usuarios_DAL.dtParametros = null;
				obj_Usuarios_DAL.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj_Usuarios_DAL.dtParametros);

				obj_Usuarios_DAL.dtParametros.Rows.Add("@InstitucionId", "1", obj_Usuarios_DAL.iInstitucionId);
				obj_Usuarios_DAL.dtParametros.Rows.Add("@UsuarioId", "1", obj_Usuarios_DAL.iUsuarioId);
				obj_Usuarios_DAL.dtParametros.Rows.Add("@RolId", "11", obj_Usuarios_DAL.iRolId);
				obj_Usuarios_DAL.dtParametros.Rows.Add("@TipoIdentificacionId", "11", obj_Usuarios_DAL.iTipoIdentificacionId);
				obj_Usuarios_DAL.dtParametros.Rows.Add("@Identificacion", "6", obj_Usuarios_DAL.sIdentificacion);
				obj_Usuarios_DAL.dtParametros.Rows.Add("@NumeroInterno", "6", obj_Usuarios_DAL.sNumeroInterno);
				obj_Usuarios_DAL.dtParametros.Rows.Add("@Nombre", "7", obj_Usuarios_DAL.sNombre);
				obj_Usuarios_DAL.dtParametros.Rows.Add("@Apellidos", "7", obj_Usuarios_DAL.sApellidos);
				obj_Usuarios_DAL.dtParametros.Rows.Add("@Correo", "6", obj_Usuarios_DAL.sCorreo);
				obj_Usuarios_DAL.dtParametros.Rows.Add("@Contrasena", "6", string.IsNullOrEmpty(obj_Usuarios_DAL.sContrasena) ? (object)DBNull.Value : obj_Usuarios_DAL.sContrasena);
				obj_Usuarios_DAL.dtParametros.Rows.Add("@CarreraId", "1", (object)obj_Usuarios_DAL.iCarreraId ?? DBNull.Value);
				obj_Usuarios_DAL.dtParametros.Rows.Add("@DepartamentoId", "1", (object)obj_Usuarios_DAL.iDepartamentoId ?? DBNull.Value);
				obj_Usuarios_DAL.dtParametros.Rows.Add("@EquipoId", "1", (object)obj_Usuarios_DAL.iEquipoId ?? DBNull.Value);
