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

## Run Flutter app against Docker backend

The mobile app reads API and WebSocket endpoints via `--dart-define`.

### Android emulator (uses host loopback alias)

```bash
flutter run \
  --dart-define=API_HOST=10.0.2.2 \
  --dart-define=API_PORT=8080
```

If your compose API is on a different host port:

```bash
flutter run \
  --dart-define=API_HOST=10.0.2.2 \
  --dart-define=API_PORT=18080
```

### iOS simulator

```bash
flutter run \
  --dart-define=API_HOST=localhost \
  --dart-define=API_PORT=8080
```

### Physical phone on same Wi-Fi

Use your computer LAN IP:

```bash
flutter run \
  --dart-define=API_HOST=192.168.1.50 \
  --dart-define=API_PORT=8080
```

Optional full overrides:
- `API_BASE_URL` (e.g. `http://192.168.1.50:8080`)
- `WS_BASE_URL` (e.g. `ws://192.168.1.50:8080/ws`)
