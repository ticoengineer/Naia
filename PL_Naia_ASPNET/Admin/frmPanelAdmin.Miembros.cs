using BLL_Naia_ASPNET.Entidades;
using DAL_Naia_ASPNET.Entidades;
using System;
using System.Collections.Generic;
using System.Data;
using System.Web.Services;

namespace PL_Naia_ASPNET.Admin
{
    /// <summary>
    /// Lista desplegable (solo lectura) de los usuarios activos de una carrera, departamento o equipo.
    /// La usan Carreras, Departamentos y Equipos por medio de JS/Miembros.js.
    /// </summary>
    public partial class frmPanelAdmin : System.Web.UI.Page
    {
        /// <summary>
        /// Parámetros: [0] InstitucionId · [1] IdUsuarioGlobal · [2] Tipo (Carrera | Departamento | Equipo) · [3] Id
        /// Si falla responde error 500 y el JS muestra "No se pudo cargar la lista".
        /// </summary>
        [WebMethod]
        public static List<Dictionary<string, string>> ListarMiembros(List<string> obj_Parametros_JS)
        {
            List<Dictionary<string, string>> lista = new List<Dictionary<string, string>>();

            string sTipo = obj_Parametros_JS[2];
            if (sTipo != "Carrera" && sTipo != "Departamento" && sTipo != "Equipo")
                throw new ArgumentException("Tipo no válido.");

            cls_Miembros_DAL obj_DAL = new cls_Miembros_DAL();
            cls_Miembros_BLL obj_BLL = new cls_Miembros_BLL();

            obj_DAL.iInstitucionId = Convert.ToInt32(obj_Parametros_JS[0]);
            obj_DAL.iIdUsuarioGlobal = Convert.ToInt32(obj_Parametros_JS[1]);
            obj_DAL.sTipo = sTipo;
            obj_DAL.iId = Convert.ToInt32(obj_Parametros_JS[3]);

            obj_BLL.Listar_Miembros(ref obj_DAL);

            if (!string.IsNullOrEmpty(obj_DAL.sMSJError))
                throw new Exception(obj_DAL.sMSJError);

            if (obj_DAL.dtDatos != null)
            {
                foreach (DataRow fila in obj_DAL.dtDatos.Rows)
                {
                    lista.Add(new Dictionary<string, string>
                    {
                        { "UsuarioId", fila["UsuarioId"].ToString() },
                        { "Nombre",    fila["NombreCompleto"].ToString() },
                        { "Rol",       fila["Rol"].ToString() }
                    });
                }
            }

            return lista;
        }
    }
}
