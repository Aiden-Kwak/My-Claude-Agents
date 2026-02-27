# /start-dev — 범용 자동 개발 파이프라인

`docs/requirements.md`를 읽고 설계 → 구현 → QA를 자동으로 진행합니다.

---

## 시작 전 체크

**먼저 `docs/requirements.md`가 있는지 확인하세요.**

```bash
ls docs/requirements.md 2>/dev/null || echo "없음"
```

없다면 사용자에게 안내:
```
docs/requirements.md 파일이 없습니다.
docs/requirements.example.md를 복사하여 요구사항을 작성해주세요:

  cp docs/requirements.example.md docs/requirements.md
  # requirements.md 편집 후 다시 /start-dev 실행
```

있다면 아래 단계를 순서대로 진행합니다.

---

## Step 1: 코드베이스 탐색 + 설계

```
# 1-A: 기존 코드가 있으면 탐색
Task(
  subagent_type: "feature-dev:code-explorer",
  prompt: "프로젝트 전체 구조를 분석해줘. 기존 코드 패턴, 설정 파일, 디렉토리 구조를 파악해줘."
)

# 1-B: 설계 문서 생성
Task(
  subagent_type: "design-agent",
  prompt: "CLAUDE.md와 docs/requirements.md를 읽고 서비스 전체를 설계해줘.
          docs/api-spec.md (모든 엔드포인트 요청/응답 예시 포함)와
          docs/data-model.md (ERD, 필드 설명, 인덱스 전략)를 생성해줘.
          작업 완료 후 발견된 교훈을 CLAUDE.md ## 누적 교훈에 기록해줘."
)
```

완료 확인: `docs/api-spec.md`, `docs/data-model.md` 존재 여부

---

## Step 2: 개발 계획 수립

```
Task(
  subagent_type: "planning-agent",
  prompt: "docs/ 폴더의 모든 문서를 읽고 개발 계획을 수립해줘.
          TaskCreate로 모든 개발 태스크를 등록하고 의존성을 설정해줘.
          docs/dev-plan.md를 생성해줘.
          백엔드와 프론트엔드 초기화는 병렬로 실행 가능하다고 명시해줘."
)
```

완료 확인: `docs/dev-plan.md` 존재, TaskList로 태스크 등록 확인

---

## Step 3 + 4: 백엔드 & 프론트엔드 병렬 구현

> **중요**: 두 Task를 한 메시지에 동시에 호출하여 병렬 실행

```
# 동시에 실행 (run_in_background: true)
Task(
  subagent_type: "db-agent",
  run_in_background: true,
  prompt: "CLAUDE.md와 docs/ 설계 문서를 읽고 백엔드를 완전히 구현해줘.
          작업 완료 후 발견된 교훈을 CLAUDE.md ## 누적 교훈에 기록해줘."
)

Task(
  subagent_type: "frontend-agent",
  run_in_background: true,
  prompt: "CLAUDE.md와 docs/ 설계 문서를 읽고 프론트엔드를 완전히 구현해줘.
          npm run build가 성공해야 완료.
          작업 완료 후 발견된 교훈을 CLAUDE.md ## 누적 교훈에 기록해줘."
)
```

완료 확인: 두 에이전트의 완료 알림 대기

---

## Step 5: QA 검증

```
Task(
  subagent_type: "qa-agent",
  prompt: "구현된 서비스 전체를 검증해줘.
          1. 백엔드/프론트엔드 코드 리뷰
          2. 백엔드 테스트 작성 및 실행 (SQLite 테스트 설정 사용)
          3. 프론트엔드 tsc, lint, build 확인
          4. docs/bug-report.md, docs/qa-report.md 작성
          5. 발견된 교훈을 CLAUDE.md ## 누적 교훈에 반드시 기록"
)
```

완료 확인: `docs/qa-report.md` 존재, CLAUDE.md `## 누적 교훈` 업데이트 여부

---

## Step 6: 서버 실행

```bash
./start.sh
```

---

## Step 7: 커밋 (선택)

```
/commit        # 커밋만
/commit-push-pr  # 커밋 + push + PR
```

---

## 최종 산출물 체크리스트

```
✅ docs/requirements.md     — 요구사항 (사용자 작성)
✅ docs/api-spec.md         — REST API 스펙
✅ docs/data-model.md       — 데이터 모델 & ERD
✅ docs/dev-plan.md         — 개발 계획
✅ backend/                 — 백엔드 구현
✅ frontend/                — 프론트엔드 구현
✅ docs/qa-report.md        — QA 최종 리포트
✅ CLAUDE.md (누적 교훈)    — 이번 프로젝트 교훈 기록
✅ start.sh                 — 원클릭 실행 스크립트
```
