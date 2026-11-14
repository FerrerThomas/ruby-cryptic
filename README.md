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

## Cómo trabajamos

- Una rama por issue, con el número adelante: `git checkout -b 12-flujo-partida`.
- Nadie commitea directo a `main`. Cada cambio entra por un pull request con `Closes #N`, revisado por otrx integrante.
- Antes de abrir el PR: `git pull origin main` en tu rama y verificar que la app levanta.
- Si hay conflicto en `db/schema.rb`: quedarse con la versión de `main` y correr `bin/rails db:migrate`.

## Integrantes

Tomi · Valen · Mati · Fran
