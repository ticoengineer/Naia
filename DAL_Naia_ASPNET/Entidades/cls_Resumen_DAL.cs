
using System;
using System.Data;

namespace DAL_Naia_ASPNET.Entidades
{
    public class cls_Resumen_DAL
    {
        #region Variables Privadas

        // Identidad institucional
        private int _iInstitucionId;
        private int _iIdUsuarioGlobal;

        // Resultados de SQL Server
        private DataTable _dtDatos;
        private DataTable _dtParametros;
        private string _sMSJError;

        #endregion

        #region Propiedades Publicas

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

        public string sMSJError
        {
            get => _sMSJError;
            set => _sMSJError = value;
        }

        #endregion
    }
}
