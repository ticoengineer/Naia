using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAL_Naia_ASPNET.Entidades
{
	public class cls_Usuarios_DAL
	{
		#region Variables Privadas
		/*Campos principales de Usuario*/
		private int _iUsuarioId, _iInstitucionId, _iRolId, _iTipoIdentificacionId;
		private int? _iCarreraId, _iDepartamentoId, _iEquipoId;
		private string _sIdentificacion, _sNumeroInterno, _sNombre, _sApellidos, _sCorreo, _sContrasena;
		private bool _bActivo;

		/*Filtros y Auditoría*/
		private string _sFiltro, _sDireccionIp;
		private int _iIdUsuarioGlobal;

		/*Sección presente en todas las clases*/
		private string _sValorScalar, _sAXN, _sMSJError;
		private DataTable _dtDatos, _dtParametros;
		#endregion

		#region Variables Públicas o Constructores
		public int iUsuarioId { get => _iUsuarioId; set => _iUsuarioId = value; }
		public int iInstitucionId { get => _iInstitucionId; set => _iInstitucionId = value; }
		public int iRolId { get => _iRolId; set => _iRolId = value; }
		public int iTipoIdentificacionId { get => _iTipoIdentificacionId; set => _iTipoIdentificacionId = value; }
		public int? iCarreraId { get => _iCarreraId; set => _iCarreraId = value; }
		public int? iDepartamentoId { get => _iDepartamentoId; set => _iDepartamentoId = value; }
		public int? iEquipoId { get => _iEquipoId; set => _iEquipoId = value; }

		public string sIdentificacion { get => _sIdentificacion; set => _sIdentificacion = value; }
		public string sNumeroInterno { get => _sNumeroInterno; set => _sNumeroInterno = value; }
		public string sNombre { get => _sNombre; set => _sNombre = value; }
		public string sApellidos { get => _sApellidos; set => _sApellidos = value; }
		public string sCorreo { get => _sCorreo; set => _sCorreo = value; }
		public string sContrasena { get => _sContrasena; set => _sContrasena = value; }
		public bool bActivo { get => _bActivo; set => _bActivo = value; }

		public string sFiltro { get => _sFiltro; set => _sFiltro = value; }
		public string sDireccionIp { get => _sDireccionIp; set => _sDireccionIp = value; }
		public int iIdUsuarioGlobal { get => _iIdUsuarioGlobal; set => _iIdUsuarioGlobal = value; }

		public string sValorScalar { get => _sValorScalar; set => _sValorScalar = value; }
		public string sAXN { get => _sAXN; set => _sAXN = value; }
		public string sMSJError { get => _sMSJError; set => _sMSJError = value; }
		public DataTable dtDatos { get => _dtDatos; set => _dtDatos = value; }
		public DataTable dtParametros { get => _dtParametros; set => _dtParametros = value; }
		#endregion
	}
}
