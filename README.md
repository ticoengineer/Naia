# Naia

> Mesa de ayuda (help desk) para universidades, bajo el modelo *SaaS*.
> Proyecto del curso **Programación IV**.

---

## 📌 Descripción

**Naia** es una aplicación web, ofrecida bajo el modelo *SaaS*, que permite a las universidades centralizar el registro, la asignación, el seguimiento y el cierre de las solicitudes de soporte técnico de sus estudiantes y profesores.

Hoy en día muchos reportes (computadoras, Internet, proyectores, laboratorios o sistemas académicos) llegan por WhatsApp, correo o en persona, sin un registro central, por lo que se pierden y no se les puede dar seguimiento. Naia resuelve esto con un único canal oficial donde cada solicitud tiene un número único (`INC0010001`), un responsable, un tiempo de atención (SLA) y un historial auditable.

Cada universidad trabaja en su propio espacio: sus usuarios, catálogos, tiquetes y auditoría están separados de las demás.

## 🎯 Objetivo principal

Desarrollar una plataforma web de gestión de tiquetes de soporte técnico, bajo el modelo SaaS, que permita a cada universidad gestionar sus solicitudes en un espacio independiente, con roles diferenciados, catálogos configurables y trazabilidad completa, sin necesidad de instalar ni mantener infraestructura propia.

## 💳 Planes de suscripción

| Plan | Usuarios máximos | Precio mensual |
| --- | --- | --- |
| Básico | 500 | $149 |
| Profesional | 3 000 | $399 |
| Institucional | Ilimitado | $899 |

Si una universidad llega al límite de su plan, los procedimientos devuelven el código `-5`.

## 👥 Roles del sistema

| Id | Rol | Quién es | Qué puede hacer | Página de inicio |
| --- | --- | --- | --- | --- |
| 1 | **Estudiante** | Usuario final | Reportar problemas, ver sus tiquetes, conversar con soporte, confirmar o reabrir tiquetes resueltos. | `Inicio/frmInicioUsuario.aspx` |
| 2 | **Profesor** | Usuario final | Lo mismo que Estudiante. | `Inicio/frmInicioUsuario.aspx` |
| 3 | **Soporte técnico** | Técnico de TI | Bandeja de tiquetes, tomar y asignar, cambiar prioridad, categoría, ubicación y estado, conversar y registrar la solución. | `Inicio/frmInicioSoporte.aspx` |
| 4 | **Administrativo** | Jefatura de TI | Todo lo de Soporte técnico, además del panel de administración (usuarios, catálogos, configuración y auditoría). | `Admin/frmPanelAdmin.aspx` |

## ✨ Módulos

| Módulo | Qué incluye | Estado |
| --- | --- | :---: |
| **Registro de institución** | Alta de una universidad con su plan, dominio de correo y primer administrador. | ✅ |
| **Inicio de sesión** | Correo institucional y contraseña; sesión por cookies y validación de rol por página. | ✅ |
| **Inicio de usuario** | Reportar un problema, lista de mis solicitudes, conversación, sección *Necesitan tu confirmación* (confirmar o reabrir con motivo) e historial. | ✅ |
| **Vista de soporte** | Indicadores (sin asignar, mis tiquetes, vencen hoy, SLA vencido), pestañas, filtros y búsqueda, panel de detalle con conversación, historial de estados, solución, y edición de prioridad, responsable, categoría y ubicación. Se actualiza cada 60 s. | ✅ |
| **Panel de administración** | Resumen, Usuarios, Equipos de soporte, Carreras, Departamentos, Ubicaciones, Categorías, Configuración y Auditoría. | ✅ |
| **Adjuntos** | Evidencia en los tiquetes (la tabla `Adjunto` ya existe). | 🚧 |

### Flujo de estados de un tiquete

```
                ┌──────────── reasignar ────────────┐
                ▼                                   │
 Nuevo ──► Asignado ──► En progreso ◄──► En espera ─┘
   │          │              │
   │          │              ▼
   │          │          Resuelto ──► Cerrado        (el usuario confirma)
   │          │              │
   │          │              └──► Asignado           (el usuario reabre, con motivo)
   ▼          ▼
 Cancelado (también desde En progreso y En espera)
```

| Id | Estado | Notas |
| --- | --- | --- |
| 1 | Nuevo | Sin responsable. |
| 2 | Asignado | Requiere responsable. |
| 3 | En progreso | |
| 4 | En espera | Si el usuario responde, el tiquete vuelve solo a **En progreso**. |
| 5 | Resuelto | Exige solución. El usuario debe confirmar o reabrir. |
| 6 | Cerrado | Final. |
| 7 | Cancelado | Final. |

Las transiciones permitidas, quién puede hacerlas y si piden motivo están en la tabla `TransicionEstado`; los botones de la interfaz se generan a partir de ella.

### Prioridades y SLA

| Id | Prioridad | Tiempo para resolver |
| --- | --- | --- |
| 1 | Crítica | 2 h |
| 2 | Alta | 4 h |
| 3 | Media | 8 h |
| 4 | Baja | 24 h |

## 🛠️ Tecnologías

| Capa | Tecnología |
| --- | --- |
| Frontend | HTML5, CSS3, JavaScript, jQuery, SweetAlert2 |
| Backend | C# · ASP.NET Web Forms (.NET Framework 4.8) · WebMethods |
| Base de datos | Microsoft SQL Server (base `NaiaInc`) con procedimientos almacenados |
| IDE | Visual Studio |
| Control de versiones | Git + GitHub |

## 🏗️ Arquitectura

La solución sigue el modelo de tres capas que usamos en el curso:

```
Navegador (JS + jQuery)
   │  $.ajax → [WebMethod] public static ... (List<string> obj_Parametros_JS)
   ▼
PL_Naia_ASPNET    Páginas .aspx, controles .ascx, WebMethods, CSS y JS
   ▼
BLL_Naia_ASPNET   cls_X_BLL: arma los parámetros y llama al procedimiento
   ▼
DAL_Naia_ASPNET   cls_X_DAL (propiedades) · cls_BD_DAL (conexión) · scripts SQL
   ▼
SQL Server        Procedimientos almacenados · auditoría
```

## 📁 Estructura del repositorio

```
Naia/
├── Naia.slnx
├── PL_Naia_ASPNET/                 # Capa de presentación
│   ├── Login/                      # frmLogin.aspx · naia-brand.css · InicioSesion.js
│   ├── RegistroInstitucion/        # frmRegistroInstitucion.aspx
│   ├── Inicio/                     # frmInicioUsuario.aspx · frmInicioSoporte.aspx
│   ├── Admin/                      # frmPanelAdmin.aspx + controles uc*.ascx
│   │   ├── frmPanelAdmin.<Sección>.cs   # WebMethods de cada sección (partial class)
│   │   ├── JS/                     # Panel.js + un JS por sección
│   │   └── CSS/                    # panel.css · panel-admin.css
│   ├── JavaScript/                 # Sesion.js · jquery.cookie.js
│   └── Web.config                  # Conexión y nombres de los procedimientos
├── BLL_Naia_ASPNET/
│   ├── BD/cls_BD_BLL.cs
│   └── Entidades/cls_*_BLL.cs
├── DAL_Naia_ASPNET/
│   ├── BD/cls_BD_DAL.cs
│   ├── Entidades/cls_*_DAL.cs
│   └── BD/Scripts/
│       ├── dataBase_Creation.sql           # Tablas y catálogos fijos
│       ├── Stored_Procedures/
│       │   └── storedProcedures_Script.sql # Todos los procedimientos
│       └── Datos_Prueba/                   # reset_naia.sql · seed_naia.sql
└── README.md
```

## 🚀 Cómo ejecutar el proyecto

1. Clonar el repositorio y cambiarse a `develop`:
   ```bash
   git clone https://github.com/ticoengineer/Naia.git
   cd Naia
   git checkout develop
   ```
2. En SQL Server Management Studio, ejecutar en este orden:
   1. `DAL_Naia_ASPNET/BD/Scripts/dataBase_Creation.sql`
   2. `DAL_Naia_ASPNET/BD/Scripts/Stored_Procedures/storedProcedures_Script.sql`
   3. *(Opcional)* `DAL_Naia_ASPNET/BD/Scripts/Datos_Prueba/seed_naia.sql` para cargar datos de prueba.
3. Abrir `Naia.slnx` en Visual Studio.
4. En `PL_Naia_ASPNET/Web.config`, ajustar la cadena de conexión (`WIN_AUT` o `SQL_AUT`) con el nombre de su servidor.
5. Establecer `PL_Naia_ASPNET` como proyecto de inicio, compilar y ejecutar (F5).

> ⚠️ **Nunca suban su contraseña de SQL en `Web.config`.** El repositorio es público. Antes de cada commit revisen el diff de `Web.config`.

> Si después de un `pull` el navegador muestra la versión vieja de una página, hagan **Ctrl+F5**.

### 🧪 Datos de prueba

`seed_naia.sql` simula unos 6 meses de uso con tres universidades ficticias:

| Universidad | Dominio | Plan |
| --- | --- | --- |
| Universidad del Valle Central (UVC) | `uvc.ac.cr` | Profesional |
| Instituto Tecnológico del Pacífico (ITP) | `itpacifico.ac.cr` | Institucional |
| Universidad Santa Lucía (USL) | `usantalucia.ac.cr` | Básico |

Incluye ~290 usuarios, ~450 tiquetes con conversación e historial de estados, y la auditoría correspondiente. Las fechas se calculan a partir del día en que se corre el script.

Cuentas para probar (contraseña **`Clave123`**), con el dominio de cada universidad:

| Correo | Rol |
| --- | --- |
| `admin@<dominio>` | Administrativo |
| `soporte@<dominio>` | Soporte técnico |
| `profesor@<dominio>` | Profesor |
| `estudiante@<dominio>` | Estudiante |

Para empezar de cero se puede correr `reset_naia.sql` (**borra la base `NaiaInc` completa**) y luego repetir el paso 2.

## 📐 Convenciones de código

### Procedimientos almacenados

- Los nombres de los procedimientos **no se escriben en el código**: se leen de `Web.config` (`<add key="SP_LISTAR_MIEMBROS" value="SP_LISTAR_MIEMBROS" />`). Si agregan un procedimiento, agreguen también su llave.
- Todos reciben `@InstitucionId` y `@IdUsuarioGlobal` (quién hace la acción) y validan permisos dentro del procedimiento.
- Las escrituras (crear, actualizar, desactivar, cambiar estado) quedan registradas con `SP_INSERTA_AUDITORIA`. La tabla `Auditoria` tiene un trigger que impide modificar o borrar registros.
- Las escrituras devuelven un código:

| Código | Significado |
| --- | --- |
| `> 0` | Correcto (normalmente el Id afectado) |
| `0` | Error general |
| `-1` | Duplicado |
| `-2` | No existe |
| `-3` | Sin permiso |
| `-4` | Datos inválidos |
| `-5` | Límite del plan alcanzado |
| `-6` | Regla de negocio (ej. no se puede desactivar *Administración General*) |

### Capas

- **DAL:** `cls_X_DAL` solo tiene propiedades (`iId`, `sNombre`, `bActivo`, …).
- **BLL:** `cls_X_BLL` arma los parámetros con `cls_BD_BLL.ObtieneDTParametros` y llama a `EjecutaProcesosTabla` (consultas) o `EjecutaProcesosComando` con `"SCALAR"` (escrituras).
- **PL:** los WebMethods son `[WebMethod] public static` y reciben `List<string> obj_Parametros_JS` (el orden importa). Las escrituras devuelven `"código<SPLITER>mensaje"`, que el JS separa para mostrar el mensaje.
- En el panel de administración, cada sección tiene su `ucX.ascx`, su `frmPanelAdmin.X.cs` y su `JS/X.js`.
- Las clases compartidas (por ejemplo `cls_Usuarios_*` o `cls_Tickets_*`) no se modifican sin avisar al equipo, para evitar conflictos con PRs abiertos.

### Front-end

- Mensajes al usuario con **SweetAlert2** (no `alert()`).
- Íconos en **PNG** (no SVG).
- Al cambiar un CSS o JS, suban la versión en la página (`archivo.js?v=5`) para que el navegador no use la copia vieja.
- Archivos en **UTF-8**. `Web.config` ya fuerza `utf-8` en `<globalization>`.
- Escapar siempre el texto que viene de la base antes de meterlo en el HTML.
- Los catálogos no se borran: se **desactivan** y se pueden volver a **activar**. Editar no cambia el estado.

### Sesión

Al iniciar sesión se guardan las cookies `USRUNI` (usuario), `USRINS` (institución), `USRROL` (rol), `USRNOM`, `USREML` y `USRUNV`. `Sesion.js` las valida en cada página y el atributo `data-roles` del `<body>` define qué roles pueden entrar.

## 🌿 Forma de trabajo en equipo

- `main` y `develop` están protegidas: **nadie hace push directo**.
- Cada integrante trabaja en su propia rama creada desde `develop`:
  - `feature/nombre-funcionalidad` para funcionalidades nuevas (ej. `feature/vista-soporte`).
  - `fix/descripcion` para correcciones.
- Los cambios entran a `develop` por **Pull Request** con base en `develop`. El coordinador revisa y hace el merge.
- En la descripción del PR expliquen qué cambió, qué hay que correr después del `pull` (scripts, llaves de `Web.config`) y cómo probarlo.
- Mensajes de commit en español y en presente: `Agrega validación de correo en registro`.
- Antes de empezar a trabajar:
  ```bash
  git checkout develop
  git pull origin develop
  git checkout -b feature/mi-cambio
  ```

## 👨‍💻 Equipo

| Integrante | Rol en el proyecto |
| --- | --- |
| Ian Quesada | Coordinación, revisión y merge de PRs, desarrollo |
| Jostin Solano | Desarrollo |
| Steven Casco | Desarrollo |

## 📄 Estado

🚧 **En desarrollo.** Ya funcionan el registro de instituciones, el inicio de sesión, el ciclo completo del tiquete (usuario y soporte) y el panel de administración. Pendiente: adjuntos.
