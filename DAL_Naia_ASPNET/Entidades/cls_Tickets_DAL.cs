using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAL_Naia_ASPNET.Entidades
{
    public class cls_Tickets_DAL
    {
        #region Variables Privadas
        /*Campos del tiquete*/
        private int _iTicketId, _iInstitucionId, _iIdUsuarioGlobal, _iCategoriaId, _iUbicacionId, _iEstadoNuevoId;
        private string _sTitulo, _sDescripcion, _sTexto, _sMotivo, _sSolucion;
        /*Auditoría*/
        private string _sDireccionIp;

        /*Soporte: asignar, editar y filtros de la bandeja*/
        private int _iResponsableId, _iPrioridadId;
        private int? _iFiltroEstadoId, _iFiltroPrioridadId, _iFiltroCategoriaId, _iFiltroResponsableId, _iEquipoId;
        private string _sFiltro;
        private bool _bSoloVencidos, _bSoloAbiertos;

        /*Sección presente en todas las clases*/
        private string _sValorScalar, _sAXN, _sMSJError;
        private DataTable _dtDatos, _dtParametros;
        #endregion

        #region Variables Públicas o Constructores
        public int iTicketId { get => _iTicketId; set => _iTicketId = value; }
        public int iInstitucionId { get => _iInstitucionId; set => _iInstitucionId = value; }
        public int iIdUsuarioGlobal { get => _iIdUsuarioGlobal; set => _iIdUsuarioGlobal = value; }
        public int iCategoriaId { get => _iCategoriaId; set => _iCategoriaId = value; }
        public int iUbicacionId { get => _iUbicacionId; set => _iUbicacionId = value; }
        public string sTitulo { get => _sTitulo; set => _sTitulo = value; }
        public string sDescripcion { get => _sDescripcion; set => _sDescripcion = value; }

        public int iEstadoNuevoId { get => _iEstadoNuevoId; set => _iEstadoNuevoId = value; }
        public string sTexto { get => _sTexto; set => _sTexto = value; }        // comentario
        public string sMotivo { get => _sMotivo; set => _sMotivo = value; }     // motivo del cambio de estado
        public string sSolucion { get => _sSolucion; set => _sSolucion = value; } // solo soporte (pasar a Resuelto)
        public string sDireccionIp { get => _sDireccionIp; set => _sDireccionIp = value; }

        /*Soporte*/
        public int iResponsableId { get => _iResponsableId; set => _iResponsableId = value; }   // a quién se asigna
        public int iPrioridadId { get => _iPrioridadId; set => _iPrioridadId = value; }
        /*Filtros: null = "todos"*/
        public int? iFiltroEstadoId { get => _iFiltroEstadoId; set => _iFiltroEstadoId = value; }
        public int? iFiltroPrioridadId { get => _iFiltroPrioridadId; set => _iFiltroPrioridadId = value; }
        public int? iFiltroCategoriaId { get => _iFiltroCategoriaId; set => _iFiltroCategoriaId = value; }
        public int? iFiltroResponsableId { get => _iFiltroResponsableId; set => _iFiltroResponsableId = value; } // 0 = sin asignar
        public int? iEquipoId { get => _iEquipoId; set => _iEquipoId = value; }
        public string sFiltro { get => _sFiltro; set => _sFiltro = value; }
        public bool bSoloVencidos { get => _bSoloVencidos; set => _bSoloVencidos = value; }
        public bool bSoloAbiertos { get => _bSoloAbiertos; set => _bSoloAbiertos = value; }

        public string sValorScalar { get => _sValorScalar; set => _sValorScalar = value; }
        public string sAXN { get => _sAXN; set => _sAXN = value; }
        public string sMSJError { get => _sMSJError; set => _sMSJError = value; }
        public DataTable dtDatos { get => _dtDatos; set => _dtDatos = value; }
        public DataTable dtParametros { get => _dtParametros; set => _dtParametros = value; }
        #endregion
    }
}