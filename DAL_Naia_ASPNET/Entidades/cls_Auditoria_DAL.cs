using System.Data;

namespace DAL_Naia_ASPNET.Entidades
{
    public class cls_Auditoria_DAL
    {
        // ==================== Campos privados ====================
        private int _iInstitucionId;
        private int _iIdUsuarioGlobal;
        private int _iUsuarioId;
        private string _sFechaInicio;
        private string _sFechaFin;
        private string _sSeccionSistema;
        private string _sAccion;
        private string _sFiltro;
        private int _iExitoso; // -1 = todos, 0 = fallidos, 1 = exitosos

        // ==================== Propiedades ====================
        public int iInstitucionId { get { return _iInstitucionId; } set { _iInstitucionId = value; } }
        public int iIdUsuarioGlobal { get { return _iIdUsuarioGlobal; } set { _iIdUsuarioGlobal = value; } }
        public int iUsuarioId { get { return _iUsuarioId; } set { _iUsuarioId = value; } }
        public string sFechaInicio { get { return _sFechaInicio; } set { _sFechaInicio = value; } }
        public string sFechaFin { get { return _sFechaFin; } set { _sFechaFin = value; } }
        public string sSeccionSistema { get { return _sSeccionSistema; } set { _sSeccionSistema = value; } }
        public string sAccion { get { return _sAccion; } set { _sAccion = value; } }
        public string sFiltro { get { return _sFiltro; } set { _sFiltro = value; } }
        public int iExitoso { get { return _iExitoso; } set { _iExitoso = value; } }

        // ==================== DataTables ====================
        public DataTable dtDatos { get; set; }
        public DataTable dtParametros { get; set; }
        public string sMSJError { get; set; }
    }
}
