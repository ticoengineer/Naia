using System.Data;

namespace DAL_Naia_ASPNET.Entidades
{
    public class cls_Configuracion_DAL
    {
        // ===== Campos de control =====
        private DataTable _dtDatos = new DataTable();
        private DataTable _dtParametros = new DataTable();
        private string _sValorScalar = "";
        private string _sMSJError = "";

        // ===== Campos de entidad =====
        private int _iInstitucionId = 0;
        private int _iIdUsuarioGlobal = 0;
        private int _iPlanId = 0;
        private string _sNombreInstitucion = "";
        private string _sSiglas = "";
        private string _sDireccionIp = "";
        private bool _bSoloActivos = true;

        // ===== Propiedades de control =====
        public DataTable dtDatos { get { return _dtDatos; } set { _dtDatos = value; } }
        public DataTable dtParametros { get { return _dtParametros; } set { _dtParametros = value; } }
        public string sValorScalar { get { return _sValorScalar; } set { _sValorScalar = value; } }
        public string sMSJError { get { return _sMSJError; } set { _sMSJError = value; } }

        // ===== Propiedades de entidad =====
        public int iInstitucionId { get { return _iInstitucionId; } set { _iInstitucionId = value; } }
        public int iIdUsuarioGlobal { get { return _iIdUsuarioGlobal; } set { _iIdUsuarioGlobal = value; } }
        public int iPlanId { get { return _iPlanId; } set { _iPlanId = value; } }
        public string sNombreInstitucion { get { return _sNombreInstitucion; } set { _sNombreInstitucion = value; } }
        public string sSiglas { get { return _sSiglas; } set { _sSiglas = value; } }
        public string sDireccionIp { get { return _sDireccionIp; } set { _sDireccionIp = value; } }
        public bool bSoloActivos { get { return _bSoloActivos; } set { _bSoloActivos = value; } }
    }
}
