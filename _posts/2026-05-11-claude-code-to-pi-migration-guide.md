---
title: "Claude Code에서 Pi로 — 실전 전환 가이드와 장단점 분석"
layout: post
date: 2026-05-11 00:00:00
categories:
  - AI
tags:
  - AI
  - Claude
  - ClaudeCode
  - Pi
  - CodingAgent
  - Migration
  - CLI
---

> **TL;DR** — Claude Code 쓰던 사람이 Pi로 넘어오는 건 생각보다 간단하다. `CLAUDE.md`는 그대로 작동하고, Skills는 공유 디렉토리를 쓴다. 핵심은 **Provider 설정**, **메모리 마이그레이션**, **기능 매핑** 세 가지. 이 글에서 전부 다룬다.
>
> **빠른 시작:**
> ```bash
> npm install -g @earendil-works/pi-coding-agent   # Pi 설치
> npx @robzolkos/lazypi                             # 확장 60+개 한번에 설치
> # ~/.pi/agent/settings.json에 Provider/모델 설정
> cd /path/to/project && pi                         # 바로 시작
> ```
> {: .prompt-info }

---

## 왜 전환하나

Claude Code는 강력하다. 설치 즉시 쓸 수 있고, Claude 모델 특화 최적화로 응답 품질이 높다. 하지만:

- **Anthropic만** — GPT, Gemini, DeepSeek을 같이 쓰고 싶어도 불가능
- **비용 누적** — 시스템 프롬프트만 ~10k 토큰. 매 요청마다 이게 들어간다
- **불투명** — 사용자 모르게 대량의 컨텍스트가 주입된다. 뭘 넣는지 모름
- **확장 불가** — 에이전트 자체를 수정하거나 새 확장을 작성할 수 없다

Pi는 정반대 접근: 최소 코어, 필요한 것만 조립.

## 장단점 비교

### Claude Code의 장점

1. **제로 설정** — API 키 하나로 즉시 시작. 복잡한 설정 없음
2. **강력한 기본값** — 편집, 검색, MCP, Plan 모드 전부 내장
3. **자동 메모리** — 프로젝트 Memory를 자동 관리. 세션 간 교훈이 자동 유지됨
4. **IDE 통합** — VS Code 확장, 독립 데스크톱 앱 지원
5. **Claude 모델 최적화** — Anthropic이 직접 튜닝한 시스템 프롬프트로 응답 품질이 극도로 높음
6. **큰 커뮤니티** — 레퍼런스, 트러블슈팅 자료가 풍부

### Claude Code의 단점

1. **Anthropic 종속** — Claude 모델만 사용. 다른 모델 선택권 없음
2. **비용** — $20/월 구독 + API. 숨겨진 10k 토큰 시스템 프롬프트로 매 요청 비용 누적
3. **불투명한 컨텍스트** — 어떤 정보가 주입되는지 파악 불가. 디버깅 어려움
4. **벤더 락인** — 세션, 설정, Memory가 모두 Anthropic에 종속. 이관 시 전부 재설정
5. **확장 제한** — MCP와 hooks만 커스텀 가능. 에이전트 수정 불가
6. **멀티 에이전트 미지원** — 병렬/체인 실행이 내장되지 않음

### Pi의 장점

1. **Provider 자유** — 20+ 프로바이더 자유 교체. `settings.json` 한 줄로 모델 변경
2. **토큰 효율** — 시스템 프롬프트 <1,000 토큰. 동일 작업 대비 비용 1/3~1/5
3. **오픈소스** — 코드 공개. 직접 검토, 기여, 포크 가능
4. **선택적 확장** — 필요한 기능만 설치. 안 쓰는 건 안 깔아도 됨
5. **직접 확장 작성** — Pi가 스스로 확장을 작성할 수 있음. 완전 맞춤형
6. **멀티 에이전트** — chain, parallel, async 모두 내장
7. **자동 루프** — Ralph Wiggum, Autoresearch 등 장시간 자율 작업 내장
8. **예측 가능** — 숨겨진 컨텍스트 주입 없이 항상 동일 조건

### Pi의 단점

1. **초기 설정** — LazyPi로 간소화되긴 했으나 Claude Code보다 설정 단계가 있음
2. **명시적 메모리** — 자동 저장 안 됨. `memory_write`로 직접 관리 필요
3. **데스크톱 앱 없음** — 터미널 전용. IDE 통합은 MCP로 대체
4. **작은 커뮤니티** — 레퍼런스나 트러블슈팅 자료가 Claude Code보다 부족
5. **확장별 품질 편차** — 커뮤니티 확장이 많아 품질이 들쭉날쭉
6. **기본 툴 4개** — read, write, edit, bash만 기본. 나머지는 확장 설치

### 한눈에 보기

| 비교 기준 | Claude Code | Pi |
|-----------|-------------|-----|
| 초기 설정 | ⭐⭐⭐⭐⭐ 제로 | ⭐⭐⭐ LazyPi 필요 |
| API 비용 | ⭐⭐ 비쌈 (10k 토큰) | ⭐⭐⭐⭐⭐ 저렴 (<1k 토큰) |
| 모델 선택 | ⭐ Claude만 | ⭐⭐⭐⭐⭐ 20+ 프로바이더 |
| 응답 품질 | ⭐⭐⭐⭐⭐ Claude 최적화 | ⭐⭐⭐⭐ 모델에 따라 다름 |
| 확장성 | ⭐⭐ MCP만 | ⭐⭐⭐⭐⭐ TypeScript 확장 |
| 멀티 에이전트 | ⭐ 수동 | ⭐⭐⭐⭐⭐ 내장 |
| 메모리 | ⭐⭐⭐⭐⭐ 자동 | ⭐⭐⭐ 명시적 |
| 투명성 | ⭐ 불투명 | ⭐⭐⭐⭐⭐ 완전 투명 |
| 커뮤니티 | ⭐⭐⭐⭐⭐ 풍부 | ⭐⭐⭐ 성장 중 |

## 전환 절차

### 1. 설치 + LazyPi로 한 번에 설정

```bash
npm install -g @earendil-works/pi-coding-agent
npx @robzolkos/lazypi    # 확장, 스킬, 테마 한번에
```

> 기존 `.agents/skills/` 디렉토리를 Pi와 공유하므로 Claude Code에서 쓰던 스킬이 그대로 작동한다.  {: .prompt-tip }

#### LazyPi가 뭔가

[LazyPi](https://github.com/robzolkos/lazypi)는 Rob Zolkos가 만든 Pi 원샷 셋업 도구다. Pi의 "미니멀 코어에 필요한 것만 조립한다"는 철학은 좋지만, 처음부터 하나하나 고르는 건 귀찮다. LazyPi는 이 문제를 **한 방에** 해결한다.

```bash
npx @robzolkos/lazypi
```

실행하면 자동으로 설치하는 것들:

| 카테고리 | 내용 |
|----------|------|
| **60+ 스킬** | agent-browser, mermaid-visualizer, excalidraw-diagram, frontend-tailwind, nextjs, sqlite-database-expert 등 |
| **76개 테마** | Catppuccin, Gruvbox, Dracula, Nord, Solarized 등 인기 터미널 테마 |
| **MCP 어댑터** | `pi-mcp-adapter` — GitHub, Playwright 등 MCP 서버 연동 |
| **핵심 확장** | `pi-subagents`, `pi-memory-md`, `pi-web-access`, `pi-ask-user`, `pi-autoresearch`, `pi-ralph-wiggum`, `pi-interactive-shell` 등 20+개 |
| **유틸리티** | `pi-powerbar` (상태바), `pi-usage-extension` (비용 추적), `pi-raw-paste` (붙여넣기) 등 |

**LazyPi가 해결하는 문제:**

| 문제 | LazyPi 전 | LazyPi 후 |
|------|-----------|-----------|
| Pi 초기 설정 | 확장을 하나하나 찾아서 설치 | `npx` 한 줄로 끝 |
| Claude Code 수준 기능 | 기본 4개 툴만 있어 부족 | 60+ 스킬로 Claude Code 이상 |
| 테마 | 기본 2개 | 76개 커뮤니티 테마 |
| MCP 연동 | 수동 설정 | 자동 구성 |

> **핵심:** LazyPi는 Claude Code 사용자가 Pi로 넘어올 때 겪는 **"초기 설정 장벽"**을 사실상 제거한다. 설치 후 `settings.json`에 Provider와 모델만 지정하면 바로 Claude Code와 동등한 환경이 완성된다.  {: .prompt-tip }

**설치 후 확인:**
```bash
pi list                    # 설치된 패키지 확인
pi                         # 세션 시작
/model                     # 모델 선택
```

### 2. Provider 설정

```json
// ~/.pi/agent/settings.json
{
  "defaultProvider": "anthropic",
  "defaultModel": "claude-sonnet-4"
}
```

API 키는 `~/.pi/agent/auth.json`에 저장하거나 `pi` 실행 후 `/login`으로 인증.

### 3. 프로젝트 설정 — 할 것 없음

```
CLAUDE.md → 그대로 작동 ✅
.agents/skills/ → 공유됨 ✅
```

**정말로 CLAUDE.md를 수정할 필요가 없다.** Pi가 자동으로 읽는다.

### 4. 메모리 마이그레이션

이게 유일하게 "작업"이 필요한 부분이다.

**Claude Code 메모리 구조:**
```
~/.claude/projects/-Users-{path}-{project}/memory/
  ├── MEMORY.md
  ├── feedback_xxx.md
  └── project_xxx.md
```

**Pi 메모리 구조 (pi-memory-md):**
```
~/.pi/memory-md/
  ├── global/                    # 글로벌 (사용자 프로필, 공통 지식)
  └── {project}/core/project/
      └── memory.md              # 프로젝트 메모리
```

**절차:**
1. GitHub에 pi-memory 저장소 생성
2. `settings.json`에 `repoUrl` 설정
3. memory-init 스크립트 실행
4. Claude Code Memory 내용을 pi-memory-md 형식으로 복사
5. `git commit && git push`

```json
// settings.json에 추가
{
  "pi-memory-md": {
    "repoUrl": "https://github.com/{username}/pi-memory.git",
    "globalMemory": "global"
  }
}
```

### 5. Plans 백업

Claude Code의 Plans는 세션에 종속되어 Pi에서 접근 불가. 필요한 건 미리 복사:

```bash
mkdir -p {프로젝트}/.archive/claude-plans/
cp ~/.claude/plans/관련-플랜들.md {프로젝트}/.archive/claude-plans/
```

## 명령어 매핑

| 동작 | Claude Code | Pi |
|------|-------------|-----|
| 시작 | `claude` | `pi` |
| 이어하기 | `claude --continue` | `pi -c` |
| 세션 탐색 | `claude --resume` | `pi -r` |
| 비인터랙티브 | `claude -p "..."` | `pi -p "..."` |
| 파일 참조 | `@파일명` | `@파일명` |
| 모델 전환 | 환경변수 | `/model` |

## 기능 매핑

| 기능 | Claude Code | Pi |
|------|-------------|-----|
| Plan 모드 | `/plan` | `pi-plan` 확장 |
| Memory | 자동 | `pi-memory-md` 확장 (명시적) |
| MCP | 내장 | `pi-mcp-adapter` 확장 |
| 서브에이전트 | `claude -p` (수동) | `pi-subagents` (chain/parallel/async) |
| 자동 루프 | 커스텀 스킬 필요 | `pi-ralph-wiggum` 내장 |
| 실험 최적화 | 수동 | `pi-autoresearch` 내장 |
| 다른 에이전트 | `claude -p` | `interactive_shell` (claude/codex/cursor) |
| 웹 검색 | MCP 필요 | `pi-web-access` 내장 |
| 테마 | 없음 | 76개 커뮤니티 테마 |

## 결론

> Claude Code는 **"설정 없이 바로 쓰는"** 도구, Pi는 **"내 맘대로 조립하는"** 도구다.  {: .prompt-tip }

**Claude Code에 머물러야 할 경우:**
- Claude 모델만으로 충분하고, 비용이 문제 없다면
- IDE 통합이 필수적이라면
- 설정 없이 즉시 사용이 최우선이라면

**Pi로 넘어와야 할 경우:**
- 여러 모델을 상황별로 교체해서 쓰고 싶다면
- API 비용을 절감하고 싶다면
- 에이전트 동작을 투명하게 파악하고 싶다면
- 멀티 에이전트, 자동 루프 등 고급 워크플로우가 필요하다면
- 직접 확장을 작성해서 맞춤형 도구를 만들고 싶다면

전환은 한 번이고, CLAUDE.md와 Skills는 그대로 쓰니 실제 손실은 거의 없다.
