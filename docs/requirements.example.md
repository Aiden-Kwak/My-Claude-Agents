# 프로젝트 요구사항

> 이 파일을 복사해서 `docs/requirements.md`로 저장한 뒤 내용을 채우세요.
> 에이전트들이 이 파일을 읽고 설계 → 구현 → QA를 자동으로 진행합니다.

---

## 1. 서비스 개요

**서비스명**: [서비스 이름]
**한 줄 설명**: [이 서비스가 무엇인지 한 문장으로]
**목적**: [왜 이 서비스를 만드는지]

---

## 2. 기술 스택

| 레이어 | 기술 | 비고 |
|--------|------|------|
| Frontend | Next.js 14 (App Router) + TailwindCSS + TypeScript | 또는 다른 프레임워크로 변경 가능 |
| Backend | Python 3.11+ + Django 5.x + Django REST Framework | 또는 FastAPI, Express 등 |
| Database | PostgreSQL 15+ | 또는 MySQL, SQLite |
| 패키지 관리 | pip + venv (backend), npm (frontend) | |

---

## 3. 환경 설정

```
Backend:  http://localhost:8000
Frontend: http://localhost:3000
DB:       [DB명] (localhost:5432)
```

---

## 4. 데이터 모델

### [모델명 예: User, Product, Post ...]

| 필드명 | 타입 | 제약 | 설명 |
|--------|------|------|------|
| id | UUID | PK, auto | 고유 식별자 |
| [필드명] | [타입] | [제약조건] | [설명] |
| created_at | DateTime | auto | 생성일시 |
| updated_at | DateTime | auto | 수정일시 |

---

## 5. API 엔드포인트

```
GET    /api/[리소스]/           # 목록 조회
POST   /api/[리소스]/           # 생성
GET    /api/[리소스]/{id}/      # 단일 조회
PUT    /api/[리소스]/{id}/      # 전체 수정
PATCH  /api/[리소스]/{id}/      # 부분 수정
DELETE /api/[리소스]/{id}/      # 삭제
```

---

## 6. 프론트엔드 기능

- [ ] [기능 1 - 예: 목록 조회 페이지]
- [ ] [기능 2 - 예: 생성 폼]
- [ ] [기능 3 - 예: 수정/삭제]
- [ ] [기능 4 - 예: 필터/검색]

---

## 7. 비기능 요구사항

- [ ] CORS 설정 (백엔드 ↔ 프론트엔드)
- [ ] 환경변수 분리 (.env 파일)
- [ ] 입력값 유효성 검사 (백엔드 + 프론트엔드)
- [ ] 에러 처리 및 사용자 피드백

---

## 8. 제외 범위 (Out of Scope)

> 이번 버전에서는 구현하지 않는 기능을 명시합니다.

- [ ] 사용자 인증/권한 (JWT, OAuth)
- [ ] 파일 업로드
- [ ] 실시간 기능 (WebSocket)
- [ ] [기타 제외 항목]
