
using System;
using System.Data;

namespace DAL_Naia_ASPNET.Entidades
{
    public class cls_Configuracion_DAL
    {
        #region Variables Privadas

        // Datos de la universidad
        private int _iInstitucionId;
        private int _iPlanId;
        private string _sNombreInstitucion;
        private string _sSiglas;

        // Datos del administrador
        private int _iIdUsuarioGlobal;
        private string _sDireccionIp;

        // Consulta de planes
        private bool _bSoloActivos;

        // Resultados de la base de datos
        private string _sValorScalar;
        private string _sAXN;
        private string _sMSJError;

        private DataTable _dtDatos;
        private DataTable _dtParametros;

        #endregion

        #region Variables Publicas

        // =====================================
        // INFORMACION INSTITUCIONAL
        // =====================================

        public int iInstitucionId
        {
            get => _iInstitucionId;
            set => _iInstitucionId = value;
        }

        public int iPlanId
        {
            get => _iPlanId;
            set => _iPlanId = value;
        }

        public string sNombreInstitucion
        {
            get => _sNombreInstitucion;
            set => _sNombreInstitucion = value;
        }

        public string sSiglas
        {
            get => _sSiglas;
            set => _sSiglas = value;
        }

        // =====================================
        // ADMINISTRADOR
        // =====================================

        public int iIdUsuarioGlobal
        {
            get => _iIdUsuarioGlobal;
            set => _iIdUsuarioGlobal = value;
        }

        public string sDireccionIp
        {
            get => _sDireccionIp;
            set => _sDireccionIp = value;
        }

        // =====================================
        // PLANES DE SUSCRIPCION
        // =====================================

        public bool bSoloActivos
        {
            get => _bSoloActivos;
            set => _bSoloActivos = value;
        }

        // =====================================
        // RESPUESTAS DE SQL SERVER
        // =====================================

        public string sValorScalar
        {
            get => _sValorScalar;
            set => _sValorScalar = value;
        }

        public string sAXN
        {
            get => _sAXN;
            set => _sAXN = value;
        }

        public string sMSJError
        {
            get => _sMSJError;
            set => _sMSJError = value;
        }

        public DataTable dtDatos
        {
            get => _dtDatos;
            set => _dtDatos = value;
        }

        public DataTable dtParametros
        {
            get => _dtParametros;
            set => _dtParametros = value;
        }

        #endregion
    }
}
