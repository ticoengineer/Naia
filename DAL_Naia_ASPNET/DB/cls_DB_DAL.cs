using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAL_Naia_ASPNET.DB
{
    public class cls_DB_DAL
    {
        #region VARIABLES PRIVADAS
        private SqlConnection _Obj_CNX;
        private SqlDataAdapter _Obj_DAP;
        private SqlCommand _Obj_CMD;
        private DataSet _DS;
        private DataTable _DT_Parametros;
        private string _sNomTabla, _sNomSP, _sMsjErrorBD, _sIndAxn, _sValorScalar;
        #endregion

        #region VARIABLES PÚBLICAS O CONSTRUCTORES
        public SqlConnection Obj_CNX { get => _Obj_CNX; set => _Obj_CNX = value; }
        public SqlDataAdapter Obj_DAP { get => _Obj_DAP; set => _Obj_DAP = value; }
        public SqlCommand Obj_CMD { get => _Obj_CMD; set => _Obj_CMD = value; }
        public string sMsjErrorBD { get => _sMsjErrorBD; set => _sMsjErrorBD = value; }
        public string sNomTabla { get => _sNomTabla; set => _sNomTabla = value; }
        public string sNomSP { get => _sNomSP; set => _sNomSP = value; }
        public DataSet DS { get => _DS; set => _DS = value; }
        public DataTable DT_Parametros { get => _DT_Parametros; set => _DT_Parametros = value; }
        public string sIndAxn { get => _sIndAxn; set => _sIndAxn = value; }
        public string sValorScalar { get => _sValorScalar; set => _sValorScalar = value; }
        #endregion

    }
}
