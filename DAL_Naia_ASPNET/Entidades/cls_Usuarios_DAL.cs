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
        /*Campos del usuario*/
        private int _iUsuarioId, _iInstitucionId, _iRolId;
        private string _sNombre, _sApellidos, _sCorreo, _sContrasena;
        /*Auditoría*/
        private string _sDireccionIp;

        /*Sección presente en todas las clases*/
        private string _sValorScalar, _sAXN, _sMSJError;
        private DataTable _dtDatos, _dtParametros;
        #endregion

        #region Variables Públicas o Constructores
        public int iUsuarioId { get => _iUsuarioId; set => _iUsuarioId = value; }
        public int iInstitucionId { get => _iInstitucionId; set => _iInstitucionId = value; }
        public int iRolId { get => _iRolId; set => _iRolId = value; }
        public string sNombre { get => _sNombre; set => _sNombre = value; }
        public string sApellidos { get => _sApellidos; set => _sApellidos = value; }
        public string sCorreo { get => _sCorreo; set => _sCorreo = value; }
        public string sContrasena { get => _sContrasena; set => _sContrasena = value; }
        public string sDireccionIp { get => _sDireccionIp; set => _sDireccionIp = value; }

        public string sValorScalar { get => _sValorScalar; set => _sValorScalar = value; }
        public string sAXN { get => _sAXN; set => _sAXN = value; }
        public string sMSJError { get => _sMSJError; set => _sMSJError = value; }
        public DataTable dtDatos { get => _dtDatos; set => _dtDatos = value; }
        public DataTable dtParametros { get => _dtParametros; set => _dtParametros = value; }
        #endregion
    }
}
