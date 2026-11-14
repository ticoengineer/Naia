using BLL_Naia_ASPNET.Entidades;
using DAL_Naia_ASPNET.Entidades;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Services;

namespace PL_Naia_ASPNET.Admin
{
	public partial class frmPanelAdmin
	{
		[WebMethod]
		public static List<Dictionary<string, string>> Usuarios_Listar(List<string> obj_Parametros_JS)
		{
			cls_Usuarios_DAL objDAL = new cls_Usuarios_DAL
			{
				iInstitucionId = int.Parse(obj_Parametros_JS[0])
			};
			cls_Usuarios_BLL objBLL = new cls_Usuarios_BLL();
			objBLL.Listar_Usuarios(ref objDAL);

			return ConvertirDataTableALista(objDAL.dtDatos);
		}

		[WebMethod]
		public static List<Dictionary<string, string>> Usuarios_Filtrar(List<string> obj_Parametros_JS)
		{
			cls_Usuarios_DAL objDAL = new cls_Usuarios_DAL
			{
				iInstitucionId = int.Parse(obj_Parametros_JS[0]),
				sFiltro = obj_Parametros_JS[2]
			};
			cls_Usuarios_BLL objBLL = new cls_Usuarios_BLL();
			objBLL.Filtrar_Usuarios(ref objDAL);

			return ConvertirDataTableALista(objDAL.dtDatos);
		}

		[WebMethod]
		public static List<Dictionary<string, string>> Usuarios_ObtenerInfo(List<string> obj_Parametros_JS)
		{
			cls_Usuarios_DAL objDAL = new cls_Usuarios_DAL
			{
				iInstitucionId = int.Parse(obj_Parametros_JS[0]),
				iUsuarioId = int.Parse(obj_Parametros_JS[2])
			};
			cls_Usuarios_BLL objBLL = new cls_Usuarios_BLL();
			objBLL.Info_Usuario(ref objDAL);

			return ConvertirDataTableALista(objDAL.dtDatos);
		}

		[WebMethod]
		public static Dictionary<string, List<Dictionary<string, string>>> Usuarios_ListarCatalogos(List<string> obj_Parametros_JS)
		{
			int institucionId = int.Parse(obj_Parametros_JS[0]);
			var resultado = new Dictionary<string, List<Dictionary<string, string>>>();
			cls_Usuarios_BLL objBLL = new cls_Usuarios_BLL();

			// Catálogos globales (sin @InstitucionId)
			cls_Usuarios_DAL dalRoles = new cls_Usuarios_DAL();
			objBLL.Listar_Catalogo("SP_LISTAR_ROLES", null, ref dalRoles);
			resultado["Roles"] = ConvertirDataTableALista(dalRoles.dtDatos);

			cls_Usuarios_DAL dalTiposId = new cls_Usuarios_DAL();
			objBLL.Listar_Catalogo("SP_LISTAR_TIPOS_IDENTIFICACION", null, ref dalTiposId);
			resultado["TiposId"] = ConvertirDataTableALista(dalTiposId.dtDatos);

			// Catálogos de la universidad (Parte B - requieren @InstitucionId)
			cls_Usuarios_DAL dalCarreras = new cls_Usuarios_DAL();
			objBLL.Listar_Catalogo("SP_LISTAR_CARRERAS", institucionId, ref dalCarreras);
			resultado["Carreras"] = ConvertirDataTableALista(dalCarreras.dtDatos);

			cls_Usuarios_DAL dalDeptos = new cls_Usuarios_DAL();
			objBLL.Listar_Catalogo("SP_LISTAR_DEPARTAMENTOS", institucionId, ref dalDeptos);
			resultado["Departamentos"] = ConvertirDataTableALista(dalDeptos.dtDatos);

			cls_Usuarios_DAL dalEquipos = new cls_Usuarios_DAL();
			objBLL.Listar_Catalogo("SP_LISTAR_EQUIPOS", institucionId, ref dalEquipos);
			resultado["Equipos"] = ConvertirDataTableALista(dalEquipos.dtDatos);

			return resultado;
		}

		[WebMethod]
		public static string Usuarios_Insertar(List<string> obj_Parametros_JS)
		{
			cls_Usuarios_DAL objDAL = MapearDesdeJS(obj_Parametros_JS);
			cls_Usuarios_BLL objBLL = new cls_Usuarios_BLL();
			objBLL.Insertar_Usuario(ref objDAL);

			return InterpretarRespuestaSP(objDAL, "Usuario creado correctamente.");
		}

		[WebMethod]
		public static string Usuarios_Actualizar(List<string> obj_Parametros_JS)
		{
			cls_Usuarios_DAL objDAL = MapearDesdeJS(obj_Parametros_JS);
			objDAL.bActivo = true;
			cls_Usuarios_BLL objBLL = new cls_Usuarios_BLL();
			objBLL.Actualizar_Usuario(ref objDAL);

			return InterpretarRespuestaSP(objDAL, "Usuario actualizado correctamente.");
		}

		[WebMethod]
		public static string Usuarios_CambiarEstado(List<string> obj_Parametros_JS)
		{
			int institucionId = int.Parse(obj_Parametros_JS[0]);
			int idUsuarioGlobal = int.Parse(obj_Parametros_JS[1]);
			int usuarioId = int.Parse(obj_Parametros_JS[2]);
			bool activar = obj_Parametros_JS[3] == "1";

			cls_Usuarios_BLL objBLL = new cls_Usuarios_BLL();

			if (!activar)
			{
				// Desactivar -> usa SP_ELIMINA_USUARIOS
				cls_Usuarios_DAL objDAL = new cls_Usuarios_DAL
				{
					iInstitucionId = institucionId,
					iUsuarioId = usuarioId,
					iIdUsuarioGlobal = idUsuarioGlobal,
					sDireccionIp = ObtenerIpCliente()
				};
				objBLL.Eliminar_Usuario(ref objDAL);
				return InterpretarRespuestaSP(objDAL, "Usuario desactivado correctamente.");
			}
			else
			{
				// Reactivar -> obtiene info actual y llama SP_ACTUALIZA_USUARIOS con @Activo = 1
				cls_Usuarios_DAL objInfo = new cls_Usuarios_DAL
				{
					iInstitucionId = institucionId,
					iUsuarioId = usuarioId
				};
				objBLL.Info_Usuario(ref objInfo);

				if (objInfo.dtDatos == null || objInfo.dtDatos.Rows.Count == 0)
					return "-2<SPLITER>El usuario no existe.";

				DataRow r = objInfo.dtDatos.Rows[0];
				cls_Usuarios_DAL objAct = new cls_Usuarios_DAL
				{
					iInstitucionId = institucionId,
					iUsuarioId = usuarioId,
					iRolId = Convert.ToInt32(r["RolId"]),
					iTipoIdentificacionId = Convert.ToInt32(r["TipoIdentificacionId"]),
					sIdentificacion = r["Identificacion"].ToString(),
					sNumeroInterno = r["NumeroInterno"].ToString(),
					sNombre = r["Nombre"].ToString(),
					sApellidos = r["Apellidos"].ToString(),
					sCorreo = r["Correo"].ToString(),
					sContrasena = null, // Conserva la contraseña actual
					iCarreraId = r["CarreraId"] == DBNull.Value ? (int?)null : Convert.ToInt32(r["CarreraId"]),
					iDepartamentoId = r["DepartamentoId"] == DBNull.Value ? (int?)null : Convert.ToInt32(r["DepartamentoId"]),
					iEquipoId = r["EquipoId"] == DBNull.Value ? (int?)null : Convert.ToInt32(r["EquipoId"]),
					bActivo = true,
					iIdUsuarioGlobal = idUsuarioGlobal,
					sDireccionIp = ObtenerIpCliente()
				};
				objBLL.Actualizar_Usuario(ref objAct);
				return InterpretarRespuestaSP(objAct, "Usuario reactivado correctamente.");
			}
		}

		/* =========================================================================
           MÉTODOS AUXILIARES
           ========================================================================= */
		private static cls_Usuarios_DAL MapearDesdeJS(List<string> p)
		{
			int rolId = int.Parse(p[3]);

			// Regla del negocio SQL:
			// Rol 1 (Estudiante) y 2 (Profesor) -> CarreraId (Depto y Equipo NULL)
			// Rol 3 (Soporte) -> DepartamentoId y EquipoId (Carrera NULL)
			// Rol 4 (Administrativo) -> DepartamentoId (Carrera y Equipo NULL)
			int? carreraId = (rolId == 1 || rolId == 2) && !string.IsNullOrEmpty(p[10]) ? int.Parse(p[10]) : (int?)null;
			int? deptoId = (rolId == 3 || rolId == 4) && !string.IsNullOrEmpty(p[11]) ? int.Parse(p[11]) : (int?)null;
			int? equipoId = (rolId == 3) && !string.IsNullOrEmpty(p[12]) ? int.Parse(p[12]) : (int?)null;

			return new cls_Usuarios_DAL
			{
				iInstitucionId = int.Parse(p[0]),
				iIdUsuarioGlobal = int.Parse(p[1]),
				iUsuarioId = int.Parse(p[2]),
				iRolId = rolId,
				iTipoIdentificacionId = int.Parse(p[4]),
				sIdentificacion = p[5],
				sNombre = p[6],
				sApellidos = p[7],
				sCorreo = p[8],
				sNumeroInterno = p[9],
				iCarreraId = carreraId,
				iDepartamentoId = deptoId,
				iEquipoId = equipoId,
				sContrasena = p[13],
				sDireccionIp = ObtenerIpCliente()
			};
		}

		private static string InterpretarRespuestaSP(cls_Usuarios_DAL objDAL, string mensajeExito)
		{
			if (!string.IsNullOrEmpty(objDAL.sMSJError))
			{
				return "0<SPLITER>Error de comunicación con la base de datos: " + objDAL.sMSJError;
			}

			if (!int.TryParse(objDAL.sValorScalar, out int codigo))
			{
				return "0<SPLITER>Respuesta inesperada del servidor.";
			}

			if (codigo > 0)
			{
				return codigo + "<SPLITER>" + mensajeExito;
			}

			switch (codigo)
			{
				case -1:
					return "-1<SPLITER>Ya existe un usuario registrado con ese correo, identificación o número interno.";
				case -2:
					return "-2<SPLITER>El usuario no existe o no pertenece a esta universidad.";
				case -3:
					return "-3<SPLITER>No tienes permisos para realizar esta acción.";
				case -4:
