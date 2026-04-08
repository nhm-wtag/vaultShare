# VaultShare

A centralized internal platform for teams to manage, preview, and collaborate on digital assets — images, PDFs, and audio files.

## Stack

| Technology | Purpose |
|---|---|
| Ruby on Rails 8.1 | Core MVC web application |
| PostgreSQL 16 | Primary database |
| Redis 7 | Background job queue broker |
| Sidekiq | Background job processing |
| Active Storage | File attachment management |
| Devise | User authentication |
| Pundit | Role-based authorization |
| Hotwire (Turbo + Stimulus) | Real-time UI updates |
| Tailwind CSS v4 | Styling |
| Docker + Docker Compose | Development environment |

---

## Prerequisites

You only need one thing installed locally:

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)

Ruby, PostgreSQL, and Redis all run inside Docker containers. No local installs required.

---

## Setup

### 1. Clone the repository

```bash
git clone <repository-url>
cd vaultShare
```

### 2. Create your environment file

```bash
cp .env.example .env
```

The defaults in `.env` work out of the box. No changes needed to get started.

### 3. Build the Docker images

```bash
docker compose build
```

Downloads Ruby 3.3.6, installs all gems. Takes a few minutes on first run.

### 4. Start all services

```bash
docker compose up
```

On first boot, the `web` container automatically:
- Compiles Tailwind CSS
- Creates the PostgreSQL database
- Runs all migrations

### 5. Open the app

```
http://localhost:3000
```

You'll be redirected to the login page. Register a new account to get started.

---

## Services

| Container | Exposed At | Description |
|---|---|---|
| `web` | http://localhost:3000 | Rails application |
| `db` | localhost:5432 | PostgreSQL 16 |
| `redis` | localhost:6379 | Redis 7 |
| `sidekiq` | — | Background job worker |
| `css` | — | Tailwind CSS watcher |

---

## Common Commands

All Rails commands run inside the container via `docker compose run --rm web`.

**Database**
```bash
# Run pending migrations
docker compose run --rm web bundle exec rails db:migrate

# Reset (drop + recreate + migrate + seed)
docker compose run --rm web bundle exec rails db:reset

# Open a database console
docker compose run --rm web bundle exec rails dbconsole
```

**Rails Console**
```bash
docker compose run --rm web bundle exec rails console
```

**Generate a migration**
```bash
docker compose run --rm web bundle exec rails generate migration AddFieldToTable field:type
```

**Run tests**
```bash
docker compose run --rm web bundle exec rails test
```

**Recompile CSS manually**
```bash
docker compose run --rm web bundle exec rails tailwindcss:build
```

**Rebuild after Gemfile changes**
```bash
docker compose build
docker compose up
```

---

## User Roles

New accounts default to `viewer`. Roles are assigned via the Rails console.

| Role | Permissions |
|---|---|
| `viewer` | View assets, add comments |
| `contributor` | Upload assets, create libraries, edit/delete own content |
| `admin` | Full access — user management, all content |

**Promote a user to admin:**
```bash
docker compose run --rm web bundle exec rails console
```
```ruby
User.find_by(email: "you@example.com").update!(role: "admin")
```

---

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `DB_HOST` | `db` | PostgreSQL host (Docker service name) |
| `DB_PORT` | `5432` | PostgreSQL port |
| `DB_USERNAME` | `vaultshare` | PostgreSQL user |
| `DB_PASSWORD` | `password` | PostgreSQL password |
| `DB_NAME` | `vaultshare_development` | Database name |
| `REDIS_URL` | `redis://redis:6379/0` | Redis connection URL |
| `SECRET_KEY_BASE` | — | Rails secret key (required in production) |

---

## Project Structure

```
app/
├── controllers/
│   ├── application_controller.rb   # Auth + post-sign-in redirect
│   ├── dashboard_controller.rb     # Main dashboard
│   └── api/v1/                     # JSON API endpoints
├── models/
│   └── user.rb                     # Devise auth + role enum
├── views/
│   ├── layouts/
│   │   ├── application.html.erb    # Authenticated shell (navbar + flash)
│   │   └── devise.html.erb         # Auth pages (centered card)
│   ├── devise/                     # Custom login + register views
│   └── dashboard/                  # Dashboard views
└── assets/
    └── tailwind/
        └── application.css         # Tailwind v4 entry point (@import "tailwindcss")

config/
├── database.yml                    # Reads DB_* env vars for Docker
├── routes.rb
└── initializers/
    └── sidekiq.rb                  # Redis connection config

docker-compose.yml                  # All five services
Dockerfile.dev                      # Dev image — Ruby 3.3.6 slim
.env                                # Local secrets (gitignored)
.env.example                        # Committed template
```

---

## Stopping the App

```bash
# Stop all containers, keep data volumes
docker compose down

# Stop and wipe all data (full reset)
docker compose down -v
```

---

## Troubleshooting

**Styles not loading**
The compiled stylesheet is served as `tailwind.css`, not `application.css`. If the page is unstyled, force a recompile:
```bash
docker compose run --rm web bundle exec rails tailwindcss:build
```
Then hard-refresh the browser (`Cmd+Shift+R`).

**Port 3000 already in use**
```bash
lsof -i :3000
kill -9 <PID>
```

**Database connection refused on startup**
The `web` container waits for a health check on `db`, but if startup is still failing, bring up the database first:
```bash
docker compose up db redis -d
# wait ~5 seconds, then:
docker compose up web sidekiq css
```

**"A server is already running" error**
The pid file from a previous run is stale. The startup command removes it automatically, but if needed:
```bash
rm tmp/pids/server.pid
```
