# Alszik a Város

Narratorless multiplayer social deduction game app in Flutter.

This repository is scaffolded with a feature-based architecture and Riverpod.

## Run backend with Docker Compose

### 1. Prepare env file

```bash
cp .env.docker.example .env.docker
```

You can edit `.env.docker` if needed (ports, DB credentials, CORS, secrets).
For host port conflicts, change `HOST_API_PORT` (container `APP_PORT` can stay `8080`).

### 2. Start services

```bash
docker compose --env-file .env.docker up --build -d
```

This starts:
- `postgres` on `${POSTGRES_PORT}` (default `5432`)
- `backend` API on `${HOST_API_PORT}` (default `8080`)

### 3. Check health

```bash
curl http://localhost:${HOST_API_PORT:-8080}/health
```

### 4. View logs

```bash
docker compose logs -f backend
```

### 5. Stop services

```bash
docker compose down
```

To also remove database volume:

```bash
docker compose down -v
```
