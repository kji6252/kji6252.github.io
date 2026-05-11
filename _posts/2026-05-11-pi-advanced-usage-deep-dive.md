---
title: "Pi 코딩 에이전트 심층 활용법 — 90%가 모르는 고급 기능"
layout: post
date: 2026-05-11 00:00:00
categories:
  - AI
tags:
  - AI
  - Pi
  - CodingAgent
  - CLI
  - Automation
  - Tutorial
---

> **TL;DR** — Pi를 "터미널에서 질문하는 도구"로만 쓰면 잠재력의 10%도 못 쓴다. 세션 브랜칭, TypeScript 확장, 멀티 에이전트, 자동 루프, SDK까지 — 실전에서 바로 써먹을 수 있는 심층 활용법을 정리했다.

---

## 1. 세션은 트리다

Pi의 세션은 단방향 리스트가 아니다. **Git 브랜치처럼** 모든 분기점에서 새 브랜치를 만들 수 있다.

```
├─ user: "인증 모듈 만들어줘"
│  └─ assistant: "JWT 기반으로..."
│     ├─ user: "OAuth도 추가해"        ← 브랜치 A
│     │  └─ assistant: "Google OAuth..."
│     │     └─ user: "테스트도" ← 활성
│     └─ user: "세션 기반으로 바꿔"    ← 브랜치 B
│        └─ assistant: "express-session..."
```

`/tree` 명령으로 시각적으로 탐색:
- 이전 접근 방식으로 돌아가서 다른 방향으로 뻗어나가기
- 이전 브랜치의 작업을 **자동 요약**해서 새 브랜치에 주입
- `/fork`로 아예 별도 파일로 분기
- `/compact`로 긴 대화를 자동 압축 (컨텍스트 윈도우 절약)

**실전 팁:** "접근 A"를 시도하다가 "접근 B"가 더 나을 것 같으면 `/tree` → 분기점 선택 → B 방향으로 진행. A의 결과는 자동 요약되어 B에 참고자료로 전달.

## 2. TypeScript 확장 — Pi를 내 맘대로

Pi 코어는 4개 툴(read, write, edit, bash)뿐. 나머지는 전부 **확장**으로 추가한다. 그리고 **Pi가 스스로 확장을 작성**할 수도 있다.

### 위험 명령 차단

```typescript
// ~/.pi/agent/extensions/guard.ts
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName === "bash" && event.input.command?.includes("rm -rf")) {
      const ok = await ctx.ui.confirm("⚠️ 위험!", "rm -rf를 실행할까요?");
      if (!ok) return { block: true, reason: "사용자가 차단함" };
    }
  });
}
```

이것만으로 `rm -rf` 명령이 실행되기 전에 확인 다이얼로그가 뜬다. `.env` 파일 쓰기 방지, `sudo` 차단 등도 같은 방식.

### 커스텀 툴 등록

```typescript
// ~/.pi/agent/extensions/deploy-tool.ts
import { Type } from "typebox";

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "deploy",
    description: "프로덕션 배포",
    parameters: Type.Object({
      env: Type.String({ description: "배포 환경" }),
    }),
    async execute(id, params, signal, onUpdate, ctx) {
      return {
        content: [{ type: "text", text: `✅ ${params.env} 배포 완료` }],
      };
    },
  });
}
```

LLM이 자동으로 이 툴을 인식하고 "배포해줘"라고 하면 `deploy` 툴을 호출한다.

### 확장으로 가능한 것들

- `tool_call` 가로채기 — 특정 명령 차단, 인수 수정
- `tool_result` 수정 — 결과 가공, 요약
- `before_agent_start` — 시스템 프롬프트 수정
- `input` — 사용자 입력 변환 (`/quick 질문` → "짧게 답해: 질문")
- `pi.registerCommand` — `/deploy`, `/review` 등 커스텀 명령어
- `pi.registerShortcut` — 키보드 단축키 바인딩

## 3. 멀티 에이전트 — 혼자서 팀을 구성

Pi 하나로 여러 에이전트를 동시에 돌릴 수 있다.

### 병렬 코드 리뷰

```
"이 PR 리뷰해줘" →
  ├─ reviewer #1: 보안 관점 리뷰
  ├─ reviewer #2: 성능 관점 리뷰
  └─ reviewer #3: 아키텍처 관점 리뷰
  → 종합 보고서 → 수정사항 적용
```

### 체인 파이프라인

```
"대규모 리팩토링" →
  scout (구조 파악) →
  planner (계획 수립) →
  worker (구현) →
  reviewer (리뷰)
```

### Git Worktree 격리

서로 다른 작업을 **별도 git worktree**에서 병렬로 실행:

```
subagent({
  tasks: [
    { agent: "worker", task: "기능 A 구현", worktree: true },
    { agent: "worker", task: "기능 B 구현", worktree: true },
  ],
})
```

파일 충돌 없이 두 기능을 동시에 개발.

### 비동기 백그라운드

```typescript
subagent({
  agent: "worker",
  task: "대규모 마이그레이션",
  async: true,  // 즉시 반환, 완료 시 알림
})
```

긴 작업을 백그라운드에 돌려두고 다른 작업 계속.

## 4. 자동 루프 — 에이전트가 스스로 일하게

### Ralph Wiggum (반복 개발 루프)

```typescript
ralph_start({
  name: "refactor-auth",
  taskContent: "인증 모듈 리팩토링 체크리스트",
  maxIterations: 50,
  reflectEvery: 5,  // 5회마다 재계획
})
```

장시간 복잡한 리팩토링을 Pi가 자율적으로 반복 수행. 5회마다 "반성"하여 방향 조정.

### Autoresearch (자율 실험 최적화)

```
init_experiment → run_experiment → log_experiment
  ↑ keep: 개선됨 → git commit 유지
  ↑ discard: 악화됨 → 코드 자동 복원
  ↑ 반복...
```

"이 명령의 실행 시간을 최소화해줘" → Pi가 직접 아이디어를 시도하고, 개선되면 유지, 악화되면 복원. 무한 반복.

## 5. Prompt Templates — 재사용 프롬프트

### `~/.pi/agent/prompts/review.md`

```markdown
---
description: 코드 리뷰 수행
argument-hint: "[파일경로]"
---
$1 파일의 코드 리뷰. 집중: 보안, 성능, 에러 처리
```

`/review src/auth.ts` → 즉시 확장되어 실행.

팀에서 공통 프롬프트를 `.pi/prompts/`에 두면 프로젝트 설정으로 공유.

## 6. SDK — Pi를 내 앱에 내장

```typescript
import { createAgentSession, SessionManager } from "@earendil-works/pi-coding-agent";

const { session } = await createAgentSession({
  sessionManager: SessionManager.inMemory(),
});

session.subscribe((event) => {
  if (event.type === "message_update") {
    process.stdout.write(event.assistantMessageEvent.delta);
  }
});

await session.prompt("코드 리뷰해줘");
```

활용 사례:
- **커스텀 웹 UI** — Pi를 백엔드로
- **CI/CD 파이프라인** — PR 자동 리뷰
- **IDE 플러그인** — Neovim, Emacs 통합
- **RPC 모드** — `pi --mode rpc`로 다른 언어에서도 사용

## 7. Custom Provider — 로컬 모델 연동

```json
// ~/.pi/agent/models.json
[{
  "provider": "ollama",
  "baseUrl": "http://localhost:11434/v1",
  "api": "openai-completions",
  "models": [{
    "id": "llama3",
    "contextWindow": 128000
  }]
}]
```

Ollama, LM Studio, 사내 API — 어떤 엔드포인트든 연동.

## 8. Skills — 점진적 공개로 토큰 절약

Claude Code는 모든 지침을 항상 컨텍스트에 넣는다. Pi는 다르다:

1. **시작 시**: Skill 이름과 설명만 시스템 프롬프트에 포함 (몇십 토큰)
2. **매칭 시**: `read`로 전체 SKILL.md 로드
3. **실행**: 지침에 따라 작업

→ Claude Code 대비 **시스템 프롬프트 1/10**의 비밀이 여기 있다.

## 9. 실전 워크플로우 패턴

### 패턴 A: A/B 탐색

개발 중 두 가지 접근 방식을 비교하고 싶을 때:
1. 브랜치 A로 개발 진행
2. `/tree` → 분기점으로 돌아가기
3. 브랜치 B로 다른 방식 시도
4. 더 나은 결과를 메인으로 선택

### 패턴 B: 컨텍스트 빌드 → 계획 → 구현

```
context-builder (코드베이스 분석) →
planner (계획 수립) →
worker (구현) →
reviewer (리뷰)
```

### 패턴 C: Autoresearch 최적화

```
init → run → log → (개선? keep : discard → 복원) → 반복
```

## 결론

> Pi의 진정한 힘은 "미니멀 코어 + 확장 생태계"에 있다.

- **세션 트리**로 A/B 탐색
- **확장**으로 Pi를 완전히 내 맘대로
- **멀티 에이전트**로 혼자 팀
- **자동 루프**로 무한 최적화
- **SDK**로 Pi를 어디든 내장
- **Custom Provider**로 어떤 모델이든 연동

이게 다 시스템 프롬프트 <1,000 토큰으로 돌아간다. Claude Code의 1/10 비용으로 10배의 자유도.
