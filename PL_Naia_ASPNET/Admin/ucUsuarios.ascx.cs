using System;
using System.Threading;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;

<%@ Control Language = "C#" AutoEventWireup="true" CodeBehind="ucUsuarios.ascx.cs" Inherits="PL_Naia_ASPNET.Admin.Secciones.ucUsuarios" %>

<div class= "seccion-header" >

	< h2 > Gestión de Usuarios</h2>
    <button type = "button" id= "usr-btnNuevo" class= "btn-primario" onclick = "Usuarios_AbrirModalNuevo()" > +Nuevo Usuario </ button >
</ div >

< !--Buscador-- >
< div class= "filtros-bar" >

	< input type = "text" id = "usr-txtBuscar" placeholder = "Buscar por nombre, correo, identificación o carné/empleado..." onkeyup = "Usuarios_Filtrar()" />
</ div >

< !--Tabla de Usuarios -->
<div class= "tabla-contenedor" >

	< table id = "usr-tabla" class= "tabla-datos" >

		< thead >

			< tr >

				< th > Nombre Completo </ th >

				< th > Identificación </ th >

				< th > Correo </ th >

				< th > N.º Interno </ th >

				< th > Rol </ th >

				< th > Estado </ th >

				< th > Acciones </ th >

			</ tr >

		</ thead >

		< tbody id = "usr-tbody" >

			< !--Se llena dinámicamente desde Usuarios.js -->
        </tbody>
    </table>
</div>

<!-- Modal Crear / Editar Usuario -->
<div id="usr-modal" class= "modal" hidden >

	< div class= "modal-contenido" >

		< h3 id = "usr-modalTitulo" > Nuevo Usuario </ h3 >

		< input type = "hidden" id = "usr-hdnId" value = "0" />


		< div class= "form-grupo" >

			< label for= "usr-ddlRol" > Rol *</ label >

			< select id = "usr-ddlRol" onchange = "Usuarios_CambiarCamposPorRol()" >

				< option value = "" > Seleccione un rol...</ option >

			</ select >

		</ div >


		< div class= "form-fila" >

			< div class= "form-grupo" >

				< label for= "usr-ddlTipoId" > Tipo Identificación *</ label >

				< select id = "usr-ddlTipoId" ></ select >

			</ div >

			< div class= "form-grupo" >

				< label for= "usr-txtIdentificacion" > Identificación *</ label >

				< input type = "text" id = "usr-txtIdentificacion" />

			</ div >

		</ div >


		< div class= "form-fila" >

			< div class= "form-grupo" >

				< label for= "usr-txtNombre" > Nombre *</ label >

				< input type = "text" id = "usr-txtNombre" />

			</ div >

			< div class= "form-grupo" >

				< label for= "usr-txtApellidos" > Apellidos *</ label >

				< input type = "text" id = "usr-txtApellidos" />

			</ div >

		</ div >


		< div class= "form-grupo" >

			< label for= "usr-txtCorreo" > Correo Institucional *</ label >

			< input type = "email" id = "usr-txtCorreo" />

		</ div >


		< !--Campo dinámico: Carné o N.º de empleado-- >

		< div class= "form-grupo" id = "usr-grpNumeroInterno" >

			< label id = "usr-lblNumeroInterno" for= "usr-txtNumeroInterno" > Carné / N.º de empleado *</ label >

			< input type = "text" id = "usr-txtNumeroInterno" />

		</ div >


		< !--Campo dinámico: Carrera(Estudiante / Profesor)-- >

		< div class= "form-grupo" id = "usr-grpCarrera" hidden >

			< label for= "usr-ddlCarrera" > Carrera *</ label >

			< select id = "usr-ddlCarrera" ></ select >

		</ div >


		< !--Campo dinámico: Departamento(Soporte / Administrativo)-- >

		< div class= "form-grupo" id = "usr-grpDepartamento" hidden >

			< label for= "usr-ddlDepartamento" > Departamento *</ label >

			< select id = "usr-ddlDepartamento" ></ select >

		</ div >


		< !--Campo dinámico: Equipo(Solo Soporte)-- >

		< div class= "form-grupo" id = "usr-grpEquipo" hidden >

			< label for= "usr-ddlEquipo" > Equipo de Soporte *</ label >

			< select id = "usr-ddlEquipo" ></ select >

		</ div >


		< div class= "form-grupo" >

			< label for= "usr-txtContrasena" > Contraseña < small id = "usr-lblPassOpcional" hidden > (Dejar vacío para conservar la actual)</ small ></ label >

			< input type = "password" id = "usr-txtContrasena" />

		</ div >


		< div id = "usr-msgError" class= "alerta-error" hidden ></ div >


		< div class= "modal-acciones" >

			< button type = "button" id = "usr-btnCancelar" onclick = "Usuarios_CerrarModal()" > Cancelar </ button >

			< button type = "button" id = "usr-btnGuardar" class= "btn-primario" onclick = "Usuarios_Guardar()" > Guardar </ button >

		</ div >

	</ div >
</ div >
