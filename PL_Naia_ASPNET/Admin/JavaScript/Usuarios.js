let usr_datosCache = [];

// Llamado automáticamente por Panel.js la primera vez que se abre la sección
function Usuarios_AlAbrir() {
    Usuarios_CargarCatalogos();
    Usuarios_Listar();
}

function Usuarios_CargarCatalogos() {
    Usuarios_Ajax("Usuarios_ListarCatalogos", [g_InstitucionId, g_UsuarioId], function (res) {
        if (!res) return;
        Usuarios_LlenarSelect("usr-ddlRol", res.Roles, "RolId", "Nombre");
        Usuarios_LlenarSelect("usr-ddlTipoId", res.TiposId, "TipoIdentificacionId", "Nombre");
        Usuarios_LlenarSelect("usr-ddlCarrera", res.Carreras, "CarreraId", "Nombre");
        Usuarios_LlenarSelect("usr-ddlDepartamento", res.Departamentos, "DepartamentoId", "Nombre");
        Usuarios_LlenarSelect("usr-ddlEquipo", res.Equipos, "EquipoId", "Nombre");
    });
}

function Usuarios_LlenarSelect(idSelect, lista, campoId, campoTexto) {
    const select = document.getElementById(idSelect);
    if (!select) return;

    select.innerHTML = '<option value="">Seleccione...</option>';
    if (!lista) return;

    lista.forEach(item => {
        const opt = document.createElement("option");
        opt.value = item[campoId];
        opt.textContent = item[campoTexto];
        select.appendChild(opt);
    });
}

function Usuarios_Listar() {
    Usuarios_Ajax("Usuarios_Listar", [g_InstitucionId, g_UsuarioId], function (lista) {
        usr_datosCache = lista || [];
        Usuarios_RenderizarTabla(usr_datosCache);
    });
}

function Usuarios_Filtrar() {
    const filtro = document.getElementById("usr-txtBuscar").value.trim();
    if (filtro === "") {
        Usuarios_RenderizarTabla(usr_datosCache);
        return;
    }

    Usuarios_Ajax("Usuarios_Filtrar", [g_InstitucionId, g_UsuarioId, filtro], function (lista) {
        Usuarios_RenderizarTabla(lista || []);
    });
}

function Usuarios_RenderizarTabla(lista) {
    const tbody = document.getElementById("usr-tbody");
    tbody.innerHTML = "";

    if (!lista || lista.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;">No se encontraron usuarios.</td></tr>';
        return;
    }

    lista.forEach(u => {
        const valorEstado = (u.Activo !== undefined ? u.Activo : u.Estado || "").toString().toLowerCase();
        const esActivo = valorEstado === "true" || valorEstado === "1" || valorEstado === "activo";
        const textoBotonEstado = esActivo ? "Desactivar" : "Reactivar";

        const nombreMostrar = u.NombreCompleto || `${u.Nombre || ""} ${u.Apellidos || ""}`.trim();
        const rolMostrar = u.RolNombre || u.Rol || "";

        const tr = document.createElement("tr");
        tr.innerHTML = `
            <td>${nombreMostrar}</td>
            <td>${u.Identificacion || ""}</td>
            <td>${u.Correo || ""}</td>
            <td>${u.NumeroInterno || ""}</td>
            <td>${rolMostrar}</td>
            <td><span class="badge ${esActivo ? 'activo' : 'inactivo'}">${esActivo ? 'Activo' : 'Inactivo'}</span></td>
            <td>
                <button type="button" onclick="Usuarios_AbrirModalEditar(${u.UsuarioId})">Editar</button>
                <button type="button" onclick="Usuarios_CambiarEstado(${u.UsuarioId}, ${esActivo ? 0 : 1})">${textoBotonEstado}</button>
            </td>
        `;
        tbody.appendChild(tr);
    });
}

// Regla de negocio: Cambiar campos y etiquetas según RolId fijo (1, 2, 3, 4)
function Usuarios_CambiarCamposPorRol() {
    const rolId = document.getElementById("usr-ddlRol").value;

    const lblNumero = document.getElementById("usr-lblNumeroInterno");
    const grpCarrera = document.getElementById("usr-grpCarrera");
    const grpDepto = document.getElementById("usr-grpDepartamento");
    const grpEquipo = document.getElementById("usr-grpEquipo");

    grpCarrera.hidden = true;
    grpDepto.hidden = true;
    grpEquipo.hidden = true;

    if (rolId === "1") { // Estudiante
        lblNumero.textContent = "Carné *";
        grpCarrera.hidden = false;
    } else if (rolId === "2") { // Profesor
        lblNumero.textContent = "N.º de empleado *";
        grpCarrera.hidden = false;
    } else if (rolId === "3") { // Soporte técnico
        lblNumero.textContent = "N.º de empleado *";
        grpDepto.hidden = false;
        grpEquipo.hidden = false;
    } else if (rolId === "4") { // Administrativo
        lblNumero.textContent = "N.º de empleado *";
        grpDepto.hidden = false;
    } else {
        lblNumero.textContent = "Carné / N.º de empleado *";
    }
}

function Usuarios_AbrirModalNuevo() {
    document.getElementById("usr-hdnId").value = "0";
    document.getElementById("usr-modalTitulo").textContent = "Nuevo Usuario";
    document.getElementById("usr-lblPassOpcional").hidden = true;

    document.getElementById("usr-ddlRol").value = "";
    Usuarios_CambiarCamposPorRol();

    document.getElementById("usr-ddlTipoId").value = "";
    document.getElementById("usr-txtIdentificacion").value = "";
    document.getElementById("usr-txtNombre").value = "";
    document.getElementById("usr-txtApellidos").value = "";
    document.getElementById("usr-txtCorreo").value = "";
    document.getElementById("usr-txtNumeroInterno").value = "";
    document.getElementById("usr-ddlCarrera").value = "";
    document.getElementById("usr-ddlDepartamento").value = "";
    document.getElementById("usr-ddlEquipo").value = "";
    document.getElementById("usr-txtContrasena").value = "";

    document.getElementById("usr-msgError").hidden = true;
    document.getElementById("usr-modal").hidden = false;
}

function Usuarios_AbrirModalEditar(usuarioId) {
    Usuarios_Ajax("Usuarios_ObtenerInfo", [g_InstitucionId, g_UsuarioId, usuarioId.toString()], function (info) {
        if (!info || info.length === 0) return;
        const u = info[0];

        document.getElementById("usr-hdnId").value = u.UsuarioId;
        document.getElementById("usr-modalTitulo").textContent = "Editar Usuario";
        document.getElementById("usr-lblPassOpcional").hidden = false;
        document.getElementById("usr-txtContrasena").value = "";

        document.getElementById("usr-ddlRol").value = u.RolId;
        Usuarios_CambiarCamposPorRol();

        document.getElementById("usr-ddlTipoId").value = u.TipoIdentificacionId;
        document.getElementById("usr-txtIdentificacion").value = u.Identificacion || "";
        document.getElementById("usr-txtNombre").value = u.Nombre || "";
        document.getElementById("usr-txtApellidos").value = u.Apellidos || "";
        document.getElementById("usr-txtCorreo").value = u.Correo || "";
        document.getElementById("usr-txtNumeroInterno").value = u.NumeroInterno || "";
        document.getElementById("usr-ddlCarrera").value = u.CarreraId || "";
        document.getElementById("usr-ddlDepartamento").value = u.DepartamentoId || "";
        document.getElementById("usr-ddlEquipo").value = u.EquipoId || "";

        document.getElementById("usr-msgError").hidden = true;
        document.getElementById("usr-modal").hidden = false;
    });
}

function Usuarios_Guardar() {
    const id = document.getElementById("usr-hdnId").value;
    const esNuevo = id === "0";
    const metodo = esNuevo ? "Usuarios_Insertar" : "Usuarios_Actualizar";

    const parametros = [
        g_InstitucionId,
        g_UsuarioId,
        id,
        document.getElementById("usr-ddlRol").value,
        document.getElementById("usr-ddlTipoId").value,
        document.getElementById("usr-txtIdentificacion").value.trim(),
        document.getElementById("usr-txtNombre").value.trim(),
        document.getElementById("usr-txtApellidos").value.trim(),
        document.getElementById("usr-txtCorreo").value.trim(),
        document.getElementById("usr-txtNumeroInterno").value.trim(),
        document.getElementById("usr-ddlCarrera").value,
        document.getElementById("usr-ddlDepartamento").value,
        document.getElementById("usr-ddlEquipo").value,
        document.getElementById("usr-txtContrasena").value
    ];

    Usuarios_Ajax(metodo, parametros, function (respuesta) {
        const partes = (respuesta || "").split("<SPLITER>");
        const codigo = parseInt(partes[0], 10);
        const mensaje = partes[1] || "Error al guardar el usuario.";

        if (!isNaN(codigo) && codigo > 0) {
            Usuarios_CerrarModal();
            Usuarios_Listar();
        } else {
            const divError = document.getElementById("usr-msgError");
            divError.textContent = mensaje;
            divError.hidden = false;
        }
    });
}

function Usuarios_CambiarEstado(usuarioId, nuevoEstado) {
    Usuarios_Ajax("Usuarios_CambiarEstado", [g_InstitucionId, g_UsuarioId, usuarioId.toString(), nuevoEstado.toString()], function (respuesta) {
        const partes = (respuesta || "").split("<SPLITER>");
        const codigo = parseInt(partes[0], 10);
        const mensaje = partes[1] || "No se pudo cambiar el estado del usuario.";

        if (!isNaN(codigo) && codigo > 0) {
            Usuarios_Listar();
        } else {
            alert(mensaje);
        }
    });
}

function Usuarios_CerrarModal() {
    document.getElementById("usr-modal").hidden = true;
}

// Helper estándar para llamadas AJAX a frmPanelAdmin.aspx
function Usuarios_Ajax(metodo, parametros, callback) {
    fetch(`frmPanelAdmin.aspx/${metodo}`, {
        method: "POST",
        headers: { "Content-Type": "application/json; charset=utf-8" },
        body: JSON.stringify({ obj_Parametros_JS: parametros })
    })
        .then(r => r.json())
        .then(data => callback(data.d))
        .catch(err => console.error(`Error en ${metodo}:`, err));
}
