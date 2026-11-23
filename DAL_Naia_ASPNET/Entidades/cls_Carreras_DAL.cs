using System;
using System.Data;

namespace DAL_Naia_ASPNET.Entidades
{
    public class cls_Carreras_DAL
    {
        #region Variables Privadas

        private int _iInstitucionId, _iCarreraId, _iIdUsuarioGlobal;
        private string _sNombre, _sDireccionIp, _sFiltro;
        private bool _bActiva, _bSoloActivas;

        private string _sValorScalar, _sAXN, _sMSJError;
        private DataTable _dtDatos, _dtParametros;

        #endregion

        #region Variables Publicas

        public int iInstitucionId { get => _iInstitucionId; set => _iInstitucionId = value; }
        public int iCarreraId { get => _iCarreraId; set => _iCarreraId = value; }
        public string sNombre { get => _sNombre; set => _sNombre = value; }
        public bool bActiva { get => _bActiva; set => _bActiva = value; }            // @Activo del SP
        public bool bSoloActivas { get => _bSoloActivas; set => _bSoloActivas = value; } // @SoloActivos de SP_LISTAR_CARRERAS
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
