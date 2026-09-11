.PHONY: test migrate upgrade-v14 dev config-check backup-staging local-smoke staging-preflight staging-gate

test:
	cd backend && pytest -q

migrate:
	cd backend && alembic upgrade head

upgrade-v14:
	cd backend && python scripts/upgrade_existing_v14.py

dev:
	docker compose up --build

config-check:
	cd backend && python scripts/check_production_config.py

local-smoke:
	python ops/local_operational_smoke.py

staging-preflight:
	python3 ops/staging_preflight.py --env-file .env.staging --compose-file docker-compose.staging.yml

staging-gate:
	./ops/staging_gate.sh

backup-staging:
	MAILFLOW_ENVIRONMENT=staging ENV_FILE=.env.staging COMPOSE_FILE=docker-compose.staging.yml ./ops/backup_postgres.sh
