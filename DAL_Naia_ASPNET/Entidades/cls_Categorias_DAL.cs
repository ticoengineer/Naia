using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAL_Naia_ASPNET.Entidades
{
    public class cls_Categorias_DAL
    {
        #region Variables Privadas

        // Campos de la tabla Categoria
        private int _iInstitucionId, _iCategoriaId, _iIdUsuarioGlobal;
        private int? _iEquipoPredeterminadoId;  // puede ser null (no todas las categorias tienen equipo)
        private int _iPrioridadInicialId;
        private string _sNombre, _sDescripcion, _sColorHex, _sDireccionIp;
        private bool _bRequiereUbicacionFisica, _bActiva, _bSoloActivas;
        private string _sFiltro;

        // Variables que siempre van en todas las clases DAL
        private string _sValorScalar, _sAXN, _sMSJError;
        private DataTable _dtDatos, _dtParametros;

        #endregion

        #region Variables Públicas

        // Datos de la categoria
        public int iInstitucionId { get => _iInstitucionId; set => _iInstitucionId = value; }
        public int iCategoriaId { get => _iCategoriaId; set => _iCategoriaId = value; }
        public string sNombre { get => _sNombre; set => _sNombre = value; }
        public string sDescripcion { get => _sDescripcion; set => _sDescripcion = value; }
        public string sColorHex { get => _sColorHex; set => _sColorHex = value; }
        public int iPrioridadInicialId { get => _iPrioridadInicialId; set => _iPrioridadInicialId = value; }
        public int? iEquipoPredeterminadoId { get => _iEquipoPredeterminadoId; set => _iEquipoPredeterminadoId = value; }
        public bool bRequiereUbicacionFisica { get => _bRequiereUbicacionFisica; set => _bRequiereUbicacionFisica = value; }
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
