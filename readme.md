# SocialVid — monorepo (starter)

This repo contains a starter scaffold for SocialVid: backend (Node/Express), mobile (React Native/Expo), and infra (docker-compose + k8s job).

## Quickstart

1. Create GitHub repo and push this scaffold.
2. Copy `.env.example` to `backend/.env` and fill values.
3. Start Postgres and backend via Docker Compose:
   ```bash
   cd infra
   docker-compose up -d
   # Make sure Postgres is ready, then run migrations
   docker exec -it infra_postgres_1 bash -c "psql -U postgres -f /migrations/001_create_core_tables.sql"
