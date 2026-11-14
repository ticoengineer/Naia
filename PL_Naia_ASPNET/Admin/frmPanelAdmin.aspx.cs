using System;

namespace PL_Naia_ASPNET.Admin
{
    /// <summary>
    /// Pagina principal del panel de administracion.
    /// Hospeda los User Controls de Ubicaciones y Categorias.
    /// Los WebMethods estan en las partial classes:
    ///   - frmPanelAdmin.Ubicaciones.cs
    ///   - frmPanelAdmin.Categorias.cs
    /// </summary>
    public partial class frmPanelAdmin : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // La autenticacion y autorizacion se manejan en Sesion.js (lado cliente)
        }
    }
}
