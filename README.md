# Naia
---

## 📌 Descripción

**Naia** es una aplicación web, ofrecida bajo el modelo *SaaS*, que permite a las universidades centralizar el registro, la asignación, el seguimiento y el cierre de las solicitudes de soporte técnico de sus estudiantes y profesores.

Hoy en día muchos reportes (computadoras, Internet, proyectores, laboratorios o sistemas académicos) llegan por WhatsApp, correo o en persona, sin un registro central, por lo que se pierden y no se les puede dar seguimiento. Naia resuelve esto con un único canal oficial donde cada solicitud tiene un número único, un responsable y un historial auditable.

## 🎯 Objetivo principal

Desarrollar una plataforma web de gestión de tiquetes de soporte técnico, bajo el modelo SaaS, que permita a cada universidad gestionar sus solicitudes en un espacio independiente, con roles diferenciados, catálogos configurables y trazabilidad completa, sin necesidad de instalar ni mantener infraestructura propia.

## 👥 Roles del sistema

| Rol | Quién es | Qué puede hacer |
| --- | --- | --- |
| **Estudiante / Profesor** | Usuario final | Crear tiquetes, adjuntar evidencia, consultar sus tiquetes, comentar y cerrar o reabrir sus tiquetes resueltos. |
| **Soporte técnico** | Técnico de TI | Consultar y filtrar tiquetes, asignar responsables, cambiar prioridad, categoría y estado, comentar y registrar la solución. |
| **Administrativo** | Jefatura de TI | Todo lo de Soporte técnico, además de administrar usuarios, catálogos y configuración, y consultar la auditoría. |

## ✨ Módulos principales

- **Inicio de sesión y registro** de usuarios con correo institucional.
- **Panel general (dashboard)** con indicadores de tiquetes abiertos, en progreso, resueltos y tiempos de resolución.
- **Mantenimiento de tiquetes**: creación, asignación, cambio de estado, comentarios, adjuntos y registro de la solución.
- **Configuración y catálogos**: categorías, prioridades, estados, departamentos, edificios y equipos de soporte.
- **Auditoría**: bitácora inmutable de las acciones realizadas en el sistema.

### Flujo de estados de un tiquete

```
Nuevo → Asignado → En progreso → Resuelto → Cerrado
                       ↕                ↓
                   En espera      (Reabierto → En progreso)
```

## 🛠️ Tecnologías

| Capa | Tecnología |
| --- | --- |
| Frontend | HTML5, CSS3, JavaScript |
| Backend | C# · ASP.NET |
| Base de datos | Microsoft SQL Server |
| IDE | Visual Studio |
| Control de versiones | Git + GitHub |

## 🎨 Identidad visual

| Color | Hex | Uso |
| --- | --- | --- |
| Charcoal Blue | `#383F51` | Barra lateral, textos principales |
| Dusk Blue | `#3C4F76` | Botones primarios, enlaces |
| Lavender | `#DDDBF1` | Fondos suaves, estados activos |
| Pale Oak | `#D1BEB0` | Acentos, indicadores |
| Lilac Ash | `#AB9F9D` | Acentos secundarios |

Tipografía: **Inter**. Los recursos de marca (logos, íconos y `naia-brand.css`) están en `docs/assets/`.

## 📁 Estructura del repositorio

```
naia/
├── src/                # Solución de Visual Studio (ASP.NET + C#)
├── database/           # Scripts SQL: creación de tablas, procedimientos y datos de prueba
├── docs/               # Documentación, prototipos, infografía y recursos de marca
│   └── assets/
└── README.md
```

## 🚀 Cómo ejecutar el proyecto

1. Clonar el repositorio:
   ```bash
   git clone https://github.com/<usuario>/naia.git
   ```
2. Abrir SQL Server Management Studio y ejecutar los scripts de la carpeta `database/` en orden.
3. Abrir la solución de `src/` en Visual Studio.
4. Actualizar la cadena de conexión en `Web.config` con el nombre de su servidor SQL.
5. Ejecutar el proyecto (F5).

## 🌿 Forma de trabajo en equipo

- La rama `main` siempre debe estar estable; nadie hace push directo a `main`.
- Cada integrante trabaja en su propia rama a partir de `develop`:
  - `feature/nombre-funcionalidad` para funcionalidades nuevas (ej. `feature/login`).
  - `fix/descripcion` para correcciones.
- Los cambios se integran a `develop` mediante **Pull Request**, revisado por al menos un compañero.
- Mensajes de commit cortos y en español, en presente: `Agrega validación de correo en registro`.
- Antes de empezar a trabajar: `git pull origin develop`.

## 👨‍💻 Equipo

| Integrante | Rol en el proyecto |
| --- | --- |
| Ian Quesada | |
| Jostin Solano | |
| Genesis Benavides | |
| Anthony Valverde | |
| Steven Casco | |

## 📄 Estado

🚧 En desarrollo: fase de conceptualización y prototipos.
