using System.Data;

namespace DAL_Naia_ASPNET.Entidades
{
    public class cls_Catalogos_DAL
    {
        // ==================== DataTables ====================
        public DataTable dtDatos { get; set; }
        public DataTable dtParametros { get; set; }
        public string sValorScalar { get; set; }
        public string sMSJError { get; set; }
    }
}
