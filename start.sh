#!/bin/bash
# 범용 개발 서버 실행 스크립트
# 사용법: ./start.sh

set -e

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKEND_DIR="$ROOT_DIR/backend"
FRONTEND_DIR="$ROOT_DIR/frontend"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}[start.sh]${NC} $1"; }
warn() { echo -e "${YELLOW}[start.sh]${NC} $1"; }
err()  { echo -e "${RED}[start.sh]${NC} $1"; exit 1; }

# ── 1. 기본 의존성 체크 ─────────────────────────────────────
log "의존성 확인 중..."
command -v uv     >/dev/null 2>&1 || err "uv가 없습니다. https://docs.astral.sh/uv/ 에서 설치하세요."
command -v python3 >/dev/null 2>&1 || err "python3가 없습니다."
command -v npm    >/dev/null 2>&1 || err "npm이 없습니다."

# ── 2. Docker + PostgreSQL 자동 시작 ────────────────────────
# docs/requirements.md에서 DB 종류 감지
DB_TYPE="postgresql"  # 기본값
if [ -f "$ROOT_DIR/docs/requirements.md" ]; then
  grep -qi "sqlite" "$ROOT_DIR/docs/requirements.md" && DB_TYPE="sqlite"
  grep -qi "mysql"  "$ROOT_DIR/docs/requirements.md" && DB_TYPE="mysql"
fi

if [ "$DB_TYPE" = "postgresql" ] && command -v docker >/dev/null 2>&1; then
  # Colima 체크 (macOS)
  if ! docker info >/dev/null 2>&1; then
    if command -v colima >/dev/null 2>&1; then
      log "Colima 시작 중..."
      colima start
    else
      err "Docker 데몬이 실행되지 않았습니다. Docker Desktop 또는 Colima를 시작하세요."
    fi
  fi

  # 프로젝트명 추출 (폴더명 사용)
  PROJECT_NAME="$(basename "$ROOT_DIR")"
  CONTAINER_NAME="${PROJECT_NAME}-postgres"

  if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
      log "PostgreSQL 컨테이너 재시작 중..."
      docker start "$CONTAINER_NAME"
    else
      log "PostgreSQL 이미 실행 중."
    fi
  else
    log "PostgreSQL 컨테이너 생성 중..."
    # .env에서 DB 정보 읽기 (없으면 기본값)
    DB_NAME="${POSTGRES_DB:-${PROJECT_NAME}_db}"
    DB_USER="${POSTGRES_USER:-user}"
    DB_PASS="${POSTGRES_PASSWORD:-password}"

    docker run -d \
      --name "$CONTAINER_NAME" \
      -e POSTGRES_DB="$DB_NAME" \
      -e POSTGRES_USER="$DB_USER" \
      -e POSTGRES_PASSWORD="$DB_PASS" \
      -p 5432:5432 \
      postgres:15
  fi

  log "PostgreSQL 준비 대기 중..."
  for i in $(seq 1 20); do
    docker exec "$CONTAINER_NAME" pg_isready -U "${POSTGRES_USER:-user}" >/dev/null 2>&1 && break
    sleep 1
  done
  log "PostgreSQL 준비 완료."
fi

# ── 3. 백엔드 설정 ──────────────────────────────────────────
if [ -d "$BACKEND_DIR" ]; then
  log "백엔드 설정 중..."
  cd "$BACKEND_DIR"

  # uv로 가상환경 및 패키지 설치
  log "백엔드 패키지 설치 중 (uv)..."
  uv sync

  # .env 파일 없으면 복사
  if [ ! -f ".env" ] && [ -f ".env.example" ]; then
    warn ".env가 없습니다. .env.example을 복사합니다."
    cp .env.example .env
    warn "backend/.env에서 SECRET_KEY, DATABASE_URL 등 민감 키를 직접 입력하세요."
  fi

  # 마이그레이션
  if [ -f "manage.py" ]; then
    log "DB 마이그레이션 실행 중..."
    uv run python manage.py migrate 2>/dev/null || warn "마이그레이션 실패 (DB 연결 확인 필요)"
  fi
fi

# ── 4. 프론트엔드 설정 ──────────────────────────────────────
if [ -d "$FRONTEND_DIR" ]; then
  log "프론트엔드 패키지 설치 중..."
  cd "$FRONTEND_DIR"
  npm install -q
fi

# ── 5. 서버 동시 실행 ───────────────────────────────────────
log "서버를 시작합니다..."
echo ""
echo "  ┌─────────────────────────────────────┐"
[ -d "$BACKEND_DIR" ]  && echo "  │  백엔드:     http://localhost:8000   │"
[ -d "$FRONTEND_DIR" ] && echo "  │  프론트엔드: http://localhost:3000   │"
echo "  │  종료:       Ctrl+C                  │"
echo "  └─────────────────────────────────────┘"
echo ""

PIDS=()

if [ -d "$BACKEND_DIR" ] && [ -f "$BACKEND_DIR/manage.py" ]; then
  cd "$BACKEND_DIR"
  uv run python manage.py runserver 0.0.0.0:8000 &
  PIDS+=($!)
fi

if [ -d "$FRONTEND_DIR" ] && [ -f "$FRONTEND_DIR/package.json" ]; then
  cd "$FRONTEND_DIR"
  npm run dev &
  PIDS+=($!)
fi

# Ctrl+C 시 모든 프로세스 종료
trap "log '서버를 종료합니다...'; kill ${PIDS[*]} 2>/dev/null; exit 0" INT TERM

wait "${PIDS[@]}"
