using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;

namespace DAL_Naia_ASPNET.Entidades
{
    /// <summary>
    /// Lista de solo lectura de los usuarios activos de una carrera, departamento o equipo
    /// (la fila desplegable de las tablas del panel del admin).
    /// </summary>
    public class cls_Miembros_DAL
    {
        #region Variables Privadas

        private int _iInstitucionId, _iIdUsuarioGlobal, _iId;
        private string _sTipo;

        private string _sValorScalar, _sAXN, _sMSJError;
        private DataTable _dtDatos, _dtParametros;

        #endregion

        #region Variables Publicas

        public int iInstitucionId { get => _iInstitucionId; set => _iInstitucionId = value; }
        public int iIdUsuarioGlobal { get => _iIdUsuarioGlobal; set => _iIdUsuarioGlobal = value; }
        public string sTipo { get => _sTipo; set => _sTipo = value; }   // Carrera · Departamento · Equipo
        public int iId { get => _iId; set => _iId = value; }            // Id de la carrera, departamento o equipo

        // Respuesta de la BD
        public string sValorScalar { get => _sValorScalar; set => _sValorScalar = value; }
        public string sAXN { get => _sAXN; set => _sAXN = value; }
        public string sMSJError { get => _sMSJError; set => _sMSJError = value; }
        public DataTable dtDatos { get => _dtDatos; set => _dtDatos = value; }
        public DataTable dtParametros { get => _dtParametros; set => _dtParametros = value; }

        #endregion
    }
}
