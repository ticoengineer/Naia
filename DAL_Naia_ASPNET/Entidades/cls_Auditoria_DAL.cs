
using System;
using System.Data;

namespace DAL_Naia_ASPNET.Entidades
{
    public class cls_Auditoria_DAL
    {
        #region Variables Privadas

        // Identificación de institución y administrador
        private int _iInstitucionId, _iIdUsuarioGlobal;

        // Filtros opcionales de auditoría
        private DateTime? _dFechaInicio, _dFechaFin;
        private string _sSeccionSistema, _sAccion, _sFiltro;
        private int? _iUsuarioId;
        private bool? _bExitoso;

        // Variables utilizadas por las clases DAL
        private string _sValorScalar, _sAXN, _sMSJError;
        private DataTable _dtDatos, _dtParametros;

        #endregion

        #region Variables Públicas

        // Identificación
        public int iInstitucionId
        {
            get => _iInstitucionId;
            set => _iInstitucionId = value;
        }

        public int iIdUsuarioGlobal
        {
            get => _iIdUsuarioGlobal;
            set => _iIdUsuarioGlobal = value;
        }

        // Fechas
        public DateTime? dFechaInicio
        {
            get => _dFechaInicio;
            set => _dFechaInicio = value;
        }

        public DateTime? dFechaFin
        {
            get => _dFechaFin;
            set => _dFechaFin = value;
        }

        // Filtros
        public string sSeccionSistema
        {
            get => _sSeccionSistema;
            set => _sSeccionSistema = value;
        }

        public string sAccion
        {
            get => _sAccion;
            set => _sAccion = value;
        }

        public int? iUsuarioId
        {
            get => _iUsuarioId;
            set => _iUsuarioId = value;
        }

        public bool? bExitoso
        {
            get => _bExitoso;
            set => _bExitoso = value;
        }

        public string sFiltro
        {
            get => _sFiltro;
            set => _sFiltro = value;
        }

        // Respuesta de la base de datos
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
