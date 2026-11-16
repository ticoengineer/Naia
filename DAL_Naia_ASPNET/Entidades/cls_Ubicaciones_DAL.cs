using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAL_Naia_ASPNET.Entidades
{
    public class cls_Ubicaciones_DAL
    {
        #region Variables Privadas

        // Campos de la tabla Ubicacion
        private int _iInstitucionId, _iUbicacionId, _iIdUsuarioGlobal;
        private string _sNombre, _sEdificio, _sDireccionIp;
        private bool _bEsFisica, _bActiva, _bSoloActivas;
        private string _sFiltro;

        // Variables que siempre van en todas las clases DAL
        private string _sValorScalar, _sAXN, _sMSJError;
        private DataTable _dtDatos, _dtParametros;

        #endregion

        #region Variables Públicas

        // Datos de la ubicacion
        public int iInstitucionId { get => _iInstitucionId; set => _iInstitucionId = value; }
        public int iUbicacionId { get => _iUbicacionId; set => _iUbicacionId = value; }
        public string sNombre { get => _sNombre; set => _sNombre = value; }
        public string sEdificio { get => _sEdificio; set => _sEdificio = value; }
        public bool bEsFisica { get => _bEsFisica; set => _bEsFisica = value; }
        public bool bActiva { get => _bActiva; set => _bActiva = value; }
        public bool bSoloActivas { get => _bSoloActivas; set => _bSoloActivas = value; }
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
