using System;
using System.Data;

namespace DAL_Naia_ASPNET.Entidades
{
    public class cls_Equipos_DAL
    {
        #region Variables Privadas

        private int _iInstitucionId, _iEquipoId, _iIdUsuarioGlobal;
        private string _sNombre, _sDescripcion, _sDireccionIp, _sFiltro;
        private bool _bActivo;

        private string _sValorScalar, _sAXN, _sMSJError;
        private DataTable _dtDatos, _dtParametros;

        #endregion

        #region Variables Publicas

        public int iInstitucionId { get => _iInstitucionId; set => _iInstitucionId = value; }
        public int iEquipoId { get => _iEquipoId; set => _iEquipoId = value; }
        public string sNombre { get => _sNombre; set => _sNombre = value; }
        public string sDescripcion { get => _sDescripcion; set => _sDescripcion = value; }
        public bool bActivo { get => _bActivo; set => _bActivo = value; }
        public string sFiltro { get => _sFiltro; set => _sFiltro = value; }

        // Auditoria
        public int iIdUsuarioGlobal { get => _iIdUsuarioGlobal; set => _iIdUsuarioGlobal = value; }
        public string sDireccionIp { get => _sDireccionIp; set => _sDireccionIp = value; }

        // Respuesta de la BD
        public string sValorScalar { get => _sValorScalar; set => _sValorScalar = value; }
        public string sAXN { get => _sAXN; set => _sAXN = value; }
        public string sMSJError { get => _sMSJError; set => _sMSJError = value; }
        public DataTable dtDatos { get => _dtDatos; set => _dtDatos = value; }
        public DataTable dtParametros { get => _dtParametros; set => _dtParametros = value; }

        #endregion
    }
}
