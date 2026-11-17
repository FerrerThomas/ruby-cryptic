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

Se completan cuando esté el login de administradores (#2).

## Decisiones de diseño

- **Código en inglés, interfaz en español.** Los modelos, controladores y servicios usan nombres en inglés (`Cryptic`, `Player`, `Game`, `CrypticSynchronizer`), así Rails pluraliza sin configuración extra. Todo lo que ve el usuario está en español (`config.i18n.default_locale = :es`, con la gema `rails-i18n` para los mensajes de validación).
- **Hora de Argentina.** `config.time_zone = "America/Argentina/Buenos_Aires"`. Para fechas usamos `Date.current` y `Time.current`, nunca `Date.today`.
- **Bootstrap con cssbundling-rails.** El SCSS se compila con `sass` desde `node_modules`. El JS de Bootstrap se carga con importmap.
  - `postcss-cli` está fijado en la v11 y `chokidar` en la v4 (con `resolutions` en `package.json`), porque las versiones nuevas necesitan Node 22.12 o superior.
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
