using System.Data;

namespace DAL_Naia_ASPNET.Entidades
{
    public class cls_Usuarios_DAL
    {
        // ==================== Campos privados ====================
        private int _iInstitucionId;
        private int _iUsuarioId;
        private int _iIdUsuarioGlobal;
        private int _iRolId;
        private int _iCarreraId;
        private int _iDepartamentoId;
        private int _iEquipoId;
        private int _iTipoIdentificacionId;
        private string _sIdentificacion;
        private string _sNumeroInterno;
        private string _sNombre;
        private string _sApellidos;
        private string _sCorreo;
        private string _sContrasena;
        private string _sDireccionIp;
        private string _sFiltro;
        private bool _bActivo;

        // ==================== Propiedades ====================
        public int iInstitucionId { get { return _iInstitucionId; } set { _iInstitucionId = value; } }
        public int iUsuarioId { get { return _iUsuarioId; } set { _iUsuarioId = value; } }
        public int iIdUsuarioGlobal { get { return _iIdUsuarioGlobal; } set { _iIdUsuarioGlobal = value; } }
        public int iRolId { get { return _iRolId; } set { _iRolId = value; } }
        public int iCarreraId { get { return _iCarreraId; } set { _iCarreraId = value; } }
        public int iDepartamentoId { get { return _iDepartamentoId; } set { _iDepartamentoId = value; } }
        public int iEquipoId { get { return _iEquipoId; } set { _iEquipoId = value; } }
        public int iTipoIdentificacionId { get { return _iTipoIdentificacionId; } set { _iTipoIdentificacionId = value; } }
        public string sIdentificacion { get { return _sIdentificacion; } set { _sIdentificacion = value; } }
        public string sNumeroInterno { get { return _sNumeroInterno; } set { _sNumeroInterno = value; } }
        public string sNombre { get { return _sNombre; } set { _sNombre = value; } }
        public string sApellidos { get { return _sApellidos; } set { _sApellidos = value; } }
        public string sCorreo { get { return _sCorreo; } set { _sCorreo = value; } }
        public string sContrasena { get { return _sContrasena; } set { _sContrasena = value; } }
        public string sDireccionIp { get { return _sDireccionIp; } set { _sDireccionIp = value; } }
        public string sFiltro { get { return _sFiltro; } set { _sFiltro = value; } }
        public bool bActivo { get { return _bActivo; } set { _bActivo = value; } }

        // ==================== DataTables ====================
        public DataTable dtDatos { get; set; }
        public DataTable dtParametros { get; set; }
        public string sValorScalar { get; set; }
        public string sMSJError { get; set; }
    }
}
