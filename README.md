# Cripticolandia

Trabajo Final Integrador de TTPS opción Ruby (cursada 2026): **Rubípticos**, un sitio para jugar a crípticos en español, hecho con Ruby on Rails.

- **Sitio público**: jugar, rachas, tabla de posiciones y cómo se juega.
- **Backend de administración** (`/admin`): configuración del juego, catálogo de crípticos, jugadores y usuarios.
- **Integración**: el catálogo se sincroniza desde la [API de la cátedra](https://github.com/ecorrons/cryptics-api).

El enunciado y la presentación de la cátedra están en [`Docs/`](Docs/). El seguimiento de tareas está en el [tablero del proyecto](https://github.com/users/FerrerThomas/projects/1).

## Requisitos técnicos

| Herramienta | Versión |
|---|---|
| Ruby | 3.4 (en Windows: [RubyInstaller](https://rubyinstaller.org/) **con DevKit**) |
| Rails | 8.1 |
| Node.js | 20 o 22 |
| Yarn | 1.x (`npm install -g yarn`) |
| Base de datos | SQLite (viene con Rails, no hay que instalar nada) |

## Cómo levantar el proyecto

### Windows

```powershell
git clone https://github.com/FerrerThomas/ruby-cryptic.git
cd ruby-cryptic
bundle install
yarn install
ruby bin/rails db:setup
```

Para desarrollar hacen falta dos terminales:

```powershell
# Terminal 1: recompila el CSS de Bootstrap cuando cambia
yarn watch:css

# Terminal 2: el servidor
ruby bin/rails server
```

Abrir http://localhost:3000.

> En PowerShell los scripts de `bin/` se corren anteponiendo `ruby` (por ejemplo `ruby bin/rails console`).
> `bin/dev` es un script de shell y no funciona en PowerShell; por eso se usan las dos terminales.

### Linux / macOS

```bash
git clone https://github.com/FerrerThomas/ruby-cryptic.git
cd ruby-cryptic
bundle install
yarn install
bin/rails db:setup
bin/dev
```

Abrir http://localhost:3000.

### Comandos útiles

| Comando | Para qué |
|---|---|
| `bin/rails db:migrate` | Aplica migraciones pendientes |
| `bin/rails db:setup` | Crea la base, carga el esquema y los seeds |
| `bin/rails console` | Probar modelos y consultas |
| `bin/rails routes` | Ver las rutas |
| `bin/rails test` | Correr los tests |
| `yarn build:css` | Compilar el CSS una vez |

## Credenciales de prueba

`bin/rails db:setup` (o `bin/rails db:seed` si la base ya existe) crea estos usuarios para entrar al backend en `/session/new`:

| Rol | Email | Contraseña | Puede |
|---|---|---|---|
| Administrador | `admin@rubipticos.test` | `admin1234` | Todo el backend |
| Editor de puntajes | `editor@rubipticos.test` | `editor1234` | Solo editar puntos y multiplicadores |

Un usuario desactivado no puede iniciar sesión, y si ya estaba logueado pierde la sesión en el siguiente pedido.

## Decisiones de diseño

- **Código en inglés, interfaz en español.** Los modelos, controladores y servicios usan nombres en inglés (`Cryptic`, `Player`, `Game`, `CrypticSynchronizer`), así Rails pluraliza sin configuración extra. Todo lo que ve el usuario está en español (`config.i18n.default_locale = :es`, con la gema `rails-i18n` para los mensajes de validación).
- **Hora de Argentina.** `config.time_zone = "America/Argentina/Buenos_Aires"`. Para fechas usamos `Date.current` y `Time.current`, nunca `Date.today`.
- **Bootstrap con cssbundling-rails.** El SCSS se compila con `sass` desde `node_modules`. El JS de Bootstrap se carga con importmap.
  - `postcss-cli` está fijado en la v11 y `chokidar` en la v4 (con `resolutions` en `package.json`), porque las versiones nuevas necesitan Node 22.12 o superior.
- **Autenticación con el generador de Rails 8** (`bin/rails g authentication`), sin Devise. Los usuarios del backend (`User`) tienen un rol (`admin` o `score_editor`) y pueden desactivarse. No hay recuperación de contraseña por email: la reinicia un admin.
  - **Todos los controladores piden login por defecto.** Las pantallas públicas (el juego, el ranking, etc.) tienen que declararlo explícitamente:
    ```ruby
    class GamesController < ApplicationController
      allow_unauthenticated_access
    end
    ```
  - Los controladores del backend van en el namespace `Admin` y heredan de `Admin::BaseController`, que usa el layout `admin`.
  - **Permisos por rol: por defecto, solo admins.** Todo controlador del backend rechaza al editor de puntajes, aunque escriba la URL a mano (lo redirige al panel con un aviso). Los pocos que el editor sí puede usar lo habilitan explícitamente:
    ```ruby
    class Admin::DifficultiesController < Admin::BaseController
      allow_score_editor                            # todo el controlador
      # allow_score_editor only: %i[ index update ] # o solo algunas acciones
    end
    ```
    Si se olvidan de esto, la pantalla queda solo para admins (el error "seguro"). Para ocultar links en las vistas: `Current.user.admin?`.
- **Configuración del juego en la base, no en el código.** Se edita desde el backend y la cargan los seeds:
  - `CrypticType`: los 13 tipos de la API (`key: "anagrama"`) con su nombre para mostrar y sus `points` (10 a 1000).
  - `Difficulty`: fácil, medio y avanzado (`key: "medio"`) con su `multiplier` (mayor que 0 y hasta 5) y su `reference_seconds` (60/180/300). El tiempo de referencia es fijo: no se puede cambiar.
  - `Setting.current`: una sola fila con la URL de la fuente de crípticos y el texto de bienvenida.
  - Los crípticos referencian su tipo y su dificultad por foreign key. Las partidas guardan sus puntos al resolverse, así que cambiar la configuración no recalcula las partidas anteriores.
- **Lógica de negocio en `app/services/`.** Puntaje, rachas y sincronización van en servicios, no en los controladores.
- **Tests con Minitest**, el framework que trae Rails.
- **Catálogo de crípticos**: se usa la API de la cátedra sin modificaciones (`https://ecorrons.github.io/cryptics-api/v1/cryptics.json`).

## Guía de estilos

La app tiene un estilo "rubí": fondo pergamino claro, detalles en rojo rubí y esquinas cortadas en diagonal, como una gema tallada. Los estilos están en `app/assets/stylesheets/ruby/`:

| Archivo | Qué tiene |
|---|---|
| `_variables.scss` | Paleta, tipografías y variables de Bootstrap que pisamos. Se carga **antes** de Bootstrap. |
| `_components.scss` | Clases propias reutilizables. Se carga **después** de Bootstrap. |

### Paleta y tipografías

| Variable | Color | Uso |
|---|---|---|
| `$ruby-600` | `#C81E3D` | Color principal (`$primary`) |
| `$ruby-700` | `#9E122C` | Links, errores (`$danger`) |
| `$ruby-50` … `$ruby-200` | rosados claros | Fondos suaves y bordes |
| `$parchment-100` | `#FAFAF7` | Fondo de la página |
| `$ink` / `$ink-muted` / `$ink-faint` | grises cálidos | Texto principal, secundario y apagado |

- **Cinzel** (`.brand-title`): solo para la marca "RUBÍPTICOS".
- **Newsreader** (serif): títulos `h1`…`h6`, las pistas y los textos en itálica.
- **Plus Jakarta Sans**: texto general, formularios y botones.
- **JetBrains Mono** (`.font-monospace`, `.eyebrow`): números, contadores, temporizadores y etiquetas.

Las fuentes se cargan desde Google Fonts en `app/views/layouts/_fonts.html.erb`, que ya incluyen los layouts `application` y `admin`.

### Bootstrap ya viene "pintado"

Usen las clases de Bootstrap de siempre: `btn btn-primary`, `btn-outline-primary`, `form-control`, `alert alert-danger`, `badge`, `container`, `row`/`col`, etc. Ya salen con los colores y tipografías del estilo rubí. Las clases propias son solo para lo que Bootstrap no tiene.

### Clases propias

| Clase | Para qué |
|---|---|
| `card-gem-frame` + `card-gem` | Tarjeta blanca tallada con filetes rubí arriba y abajo (ej.: la pista del críptico). |
| `card-gem__corner card-gem__corner--tl` (`tr`, `bl`, `br`) | Rombitos en las esquinas de la tarjeta. |
| `btn-gem` | Botón rubí principal con brillo (la acción más importante de la pantalla). |
| `facet-chamfer-sm` / `facet-chamfer-lg` | Esquinas cortadas en diagonal (7px / 14px) en cualquier elemento: casilleros de letras, badges, etc. |
| `eyebrow` | Etiqueta chica en mayúsculas y monoespaciada ("ACERTIJO CRÍPTICO"). |
| `brand-title` / `brand-tagline` | La marca "RUBÍPTICOS" y la bajada en itálica. |
| `gem-rule` | Línea separadora fina rubí que se desvanece en los extremos. |
| `gem-diamond` | Rombito decorativo. |
| `gem-sheen` | Reflejo de luz sobre un elemento. |
| `badge-role` | Badge chico con borde rubí. |
| `bg-ruby-crystal` | Fondo pergamino con enrejado (ya lo tiene el `<body>` de los layouts). |

Logo del rubí: `<%= render "shared/gem_logo" %>` (o `size: :lg` para el grande).

### Ejemplo

```erb
<div class="card-gem-frame">
  <section class="card-gem p-4 text-center">
    <span class="card-gem__corner card-gem__corner--tl"></span>
    <span class="card-gem__corner card-gem__corner--tr"></span>
    <span class="card-gem__corner card-gem__corner--bl"></span>
    <span class="card-gem__corner card-gem__corner--br"></span>

    <div class="eyebrow mb-2">Acertijo críptico</div>
    <h1 class="h2">«Mi metido en el hogar da una prenda» <span class="font-monospace text-primary">(6)</span></h1>

    <button class="btn btn-gem px-4 py-2 mt-3">Comprobar palabra</button>
  </section>
</div>
```

> `card-gem` usa `clip-path` para cortar las esquinas, y eso recorta la sombra. Por eso la sombra y el borde van en el `card-gem-frame` de afuera: no se olviden del envoltorio.

### Reglas para no pisarnos

- **No modifiquen `_variables.scss` ni `_components.scss` sin avisar**: los usa todo el equipo. Si falta algo general, propónganlo en el PR.
- **Estilos propios de una pantalla van en su propio archivo**, por ejemplo `ruby/_game.scss` o `ruby/_ranking.scss`, importado al final de `app/assets/stylesheets/application.bootstrap.scss`.
- **Usen las variables, no colores sueltos**: `$ruby-600` en vez de `#C81E3D`.
- **No usen `style="..."` salvo para un ajuste puntual** (un ancho máximo, por ejemplo).
- Los avisos `Deprecation Warning` al compilar el CSS son normales: vienen de que Bootstrap 5 todavía usa `@import`. Mientras termine con `clean exit`, compiló bien.

## Cómo trabajamos

- Una rama por issue, con el número adelante: `git checkout -b 12-flujo-partida`.
- Nadie commitea directo a `main`. Cada cambio entra por un pull request con `Closes #N`, revisado por otrx integrante.
- Antes de abrir el PR: `git pull origin main` en tu rama y verificar que la app levanta.
- Si hay conflicto en `db/schema.rb`: quedarse con la versión de `main` y correr `bin/rails db:migrate`.

## Integrantes

Tomi · Valen · Mati · Fran
