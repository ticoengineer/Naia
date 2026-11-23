using BLL_Naia_ASPNET.BD;
using DAL_Naia_ASPNET.BD;
using DAL_Naia_ASPNET.Entidades;
using System;
using System.Configuration;

namespace BLL_Naia_ASPNET.Entidades
{
    public class cls_Miembros_BLL
    {
        /// <summary>
        /// SP_LISTAR_MIEMBROS: nombre y rol de los usuarios activos de una carrera, departamento o equipo.
        /// </summary>
        public void Listar_Miembros(ref cls_Miembros_DAL obj)
        {
            try
            {
                cls_BD_DAL obj_BD_DAL = new cls_BD_DAL();
                cls_BD_BLL obj_BD_BLL = new cls_BD_BLL();

                obj.dtParametros = null;
                obj.dtParametros = obj_BD_BLL.ObtieneDTParametros(obj.dtParametros);
                obj.dtParametros.Rows.Add("@InstitucionId", "1", obj.iInstitucionId);
                obj.dtParametros.Rows.Add("@IdUsuarioGlobal", "1", obj.iIdUsuarioGlobal);
                obj.dtParametros.Rows.Add("@Tipo", "7", obj.sTipo);
                obj.dtParametros.Rows.Add("@Id", "1", obj.iId);

                obj_BD_DAL.sNomSP = ConfigurationManager.AppSettings["SP_LISTAR_MIEMBROS"];
                obj_BD_DAL.sNomTabla = "Miembros";
                obj_BD_DAL.DT_Parametros = obj.dtParametros;

                obj_BD_BLL.EjecutaProcesosTabla(ref obj_BD_DAL);

                obj.sMSJError = obj_BD_DAL.sMsjErrorBD;
                obj.dtDatos = (obj_BD_DAL.sMsjErrorBD == string.Empty) ? obj_BD_DAL.DS.Tables["Miembros"] : null;
            }
            catch (Exception ex) { throw ex; }
        }
    }
}

