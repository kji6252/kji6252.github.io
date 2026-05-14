---
title: "Claude Code for Spring Developers — Spring I/O 2026 심층 분석"
layout: post
date: 2026-05-12 05:00:00
categories:
  - AI
tags:
  - AI
  - Claude
  - ClaudeCode
  - Spring
  - Kotlin
  - SpringIO
  - AgenticDevelopment
  - CodingAgent
---

> **원본 영상:** [Claude Code for Spring Developers — Thomas Schilling @ Spring I/O 2026](https://www.youtube.com/watch?v=PmW4-tcMQbc)
>

> **TL;DR** — Claude Code를 Spring/Kotlin 프로젝트에서 3개월간 실전 사용한 결과: 3,700 커밋, 1,700 세션, 커밋 속도 5배 증가. 핵심은 Claude 자체가 아니라 **CLAUDE.md, Skills, Hooks, Specs**로 구성된 "셋업의 복리"에 있다. 속도는 무료지만, **규율은 당신의 몫**이다.
{: .prompt-info }

---

![Thomas Schilling — Claude Code for Spring Developers]({{ site.baseurl }}/images/spring-io-2026/slide_01_intro.jpg){: .shadow}

## 발표자 소개

Thomas Schilling — Stuttgart 기반, **Photo Quest**(웨딩 포토 게임 플랫폼) 창립자. Spring Boot + Kotlin + HTMX 스택. 3개월간 Claude Code로 실전 개발하며 얻은 패턴과 워크플로우를 공유.

![3개월간 3,700 커밋, 1,700 세션, 커밋 속도 5배]({{ site.baseurl }}/images/spring-io-2026/slide_02_stats.jpg){: .shadow}

### 실적 (실화)

- 3개월간 **3,700 커밋**, **1,700 세션**, **11,000+ 프롬프트**
- 커밋 속도 **5배** 증가
- GitHub contribution graph에 뚜렷한 스파이크로 확인 가능

---

![What is Claude Code?]({{ site.baseurl }}/images/spring-io-2026/slide_03_what_is_claude_code.jpg){: .shadow}

## 1. Claude Code란?

CLI 기반 에이전트 도구. 터미널에서 프롬프트를 입력하면:

```
프롬프트 입력 → 코드 읽기 → 계획 수립 → 파일 수정 → 명령 실행 → 결과 확인 → 반복
```

**종료 조건 3가지:**
1. Claude가 완료 판단 (항상 정확하진 않음)
2. 사용자 Escape로 중단
3. 권한 프롬프트에서 대기

**핵심:** 매 실행이 비결정적. 같은 프롬프트도 매번 다른 결과가 나온다.

**접속 방법:** CLI 터미널, VS Code, IntelliJ, 브라우저, 스마트폰 앱, Slack, GitHub Actions

---

![Why Spring is the best backend for agentic development]({{ site.baseurl }}/images/spring-io-2026/slide_04_why_spring.jpg){: .shadow}

## 2. 왜 Spring이 에이전트 개발에 최적인가?

Spring이 Claude Code와 특히 잘 맞는 이유 4가지:

**강한 컨벤션** — Controller-Service-Repository 패턴을 Claude가 이미 수백만 프로젝트에서 학습. 별도 설명 없이도 구조를 이해한다.

**컴파일 타임 검증** — Claude가 빌드를 실행하고, 에러를 보고, **같은 턴에서 수정**한다. 즉각적인 피드백 루프.

**테스트 용이성** — Spring Boot Test, MockMvc, TestContainers로 에이전트가 자가 검증 가능.

**예측 가능한 구조** — 코드 위치를 설명하지 않아도 Claude가 탐색 가능.

### 모델 선택 가이드

| 모델 | 용도 |
|---|---|
| **Sonnet** | 빠른 반복, 간단 수정, 서브에이전트 |
| **Opus** | 복잡 아키텍처, 다중 파일 리팩토링, 플래닝 |

**effort 명령어:** `low`(빠른 조회) → `medium`(일반) → `high`(플래닝) → `max`(어려운 디버깅)

발표자의 기본 조합: **Opus + high effort**

---

## 3. 핵심 기능: Rewind, Branch, Sub-agent

### /rewind — 실험은 공짜다

Claude가 잘못된 방향으로 가면 `/rewind`로 즉시 복원. 모든 파일 변경이 체크포인트로 추적되므로 아무것도 잃지 않는다. 컨텍스트 윈도우를 보존한 채 프롬프트를 수정하고 재시도.

**실제 데모:** sealed interface로 리팩토링하다가 마음이 바뀜 → Escape → `/rewind` → 37줄 추가/23줄 삭제 전부 복원 → 컨텍스트 유지.

### /branch — 세션 포크

다른 접근법을 시도하면서 기존 컨텍스트를 유지. 실험이 자유롭다.

### Sub-agent — 컨텍스트 보호

무거운 연구는 서브에이전트에서 독립 실행. 메인 컨텍스트에는 **요약만** 들어온다.

**실제 사례:** Photo Quest의 SSE(Server-Sent Events) 시스템 분석
- 49 tool calls
- 84,000 토큰 코드 읽기
- 90초 소요
- 결과: 완전한 아키텍처 요약 + 다이어그램
- 메인 컨텍스트는 깨끗하게 유지

![Sub-agent: 49 tool calls, 84K tokens, 90 seconds]({{ site.baseurl }}/images/spring-io-2026/slide_06_subagent.jpg){: .shadow}

### Headless 모드

`claude -p`로 UI 없이 프롬프트 → 결과. `--model haiku`로 빠르고 저렴한 조회. CI 스크립트나 파이프라인에 활용.

```bash
# 예시: migration 파일에서 ranking game 테이블 찾기
claude -p --model haiku "Find all ranking game tables in the migration files"
```

---

![Vibe Coding의 결과: 버그 8개, 테스트 0개]({{ site.baseurl }}/images/spring-io-2026/slide_07_vibe_coding.jpg){: .shadow}

## 4. ⚠️ Vibe Coding의 참상 — 반면교사

**0설정으로 2,000줄을 한 번에 코딩한 결과:**

- ❌ 테스트 0개 작성
- ❌ 수동 테스트로 발견한 버그 8개
- ❌ 4개 게임 상태 중 1개(Reveal 단계)를 **조용히 스킵** — 컨텍스트 윈도우에서 요구사항이 drift out
- ❌ JSON 대신 HTML 렌더링 컨벤션 미인지
- ❌ 사진이 한 번에 다 뜸 (비머 표시 로직 없음)
- ❌ 게임이 자동시작 안 됨
- ❌ 결과 페이지 "No votes" — 쿼리 자체가 고장

> "I wasn't designing a feature, I was **fire fighting**."

**핵심 교훈:** 코드만으로는 부족하다. Claude는 **지식, 스킬, 계획**이 필요하다.

---

![CLAUDE.md: 첫날은 5줄만 쓴다]({{ site.baseurl }}/images/spring-io-2026/slide_09_claude_md.jpg){: .shadow}

## 5. CLAUDE.md 구축법 — 컨텍스트의 기반

### 핵심 원칙: 모든 규칙은 실제 실패로부터 얻어라

**첫날:** 5줄만 쓴다 — 빌드 명령어, 테스트 명령어. 끝.

그다음 Claude Code를 사용하면서 **무엇이 잘못되는지 관찰**한다:
- 잘못된 가정 → 규칙 추가
- 잘못된 import → 규칙 추가
- **모든 규칙은 실제 실패를 통해 자리를 잡아야 한다**

![CLAUDE.md의 3가지 핵심 규칙]({{ site.baseurl }}/images/spring-io-2026/slide_10_claude_md_rules.jpg){: .shadow}

### 발표자의 3가지 핵심 규칙

**1. Kotlin 변경 후 컴파일**
```
Gradle compileKotlin compileTestKotlin
```
빠른 피드백 루프로 Claude가 에러를 자가 수정.

**2. 완료 전 검증**
테스트를 실행하고 정확성을 증명하기 전에는 태스크 완료 금지. Claude가 "끝났다"고 해도 증명이 없으면 끝난 게 아니다.

**3. 멀티인스턴스 안전**
인메모리 상태 금지, DB 체크 사용. 분산 합의에는 advisory lock. 이 규칙은 Claude가 코드만으로는 추론할 수 없는 **아키텍처 수준 결정**이다.

> 규칙이 advisory lock을 설명하지 않는다 — `advisorylock.kt` 파일을 가리킨다. Claude가 필요할 때 파일을 읽는다. CLAUDE.md는 짧게, 지식은 정확하게.
{: .prompt-tip }

### 컨텍스트 3계층

```
CLAUDE.md          → 항상 로드 (200줄 이하 권장)
.claude/rules/     → 경로별 조건부 로드 (package-by-feature 매핑)
auto memory        → 사용자 폴더, Git 미추적 (발표자는 비활성화)
```

**`.claude/rules/`의 핵심:** 각 파일에 `path` 필드가 있어, 해당 경로를 수정할 때만 로드된다. Kotlin 규칙은 Kotlin 파일 수정 시, 결제 규칙은 결제 패키지 수정 시. Claude는 **관련 있는 컨텍스트만** 본다.

![컨텍스트 3계층: CLAUDE.md → .claude/rules → auto memory]({{ site.baseurl }}/images/spring-io-2026/slide_11_context_hierarchy.jpg){: .shadow}

### 컨텍스트 관리 실전 팁

- **`/context`** 명령어로 토큰 사용량 실시간 확인
- Opus 4.6 = 100만 토큰 기본이지만, **채울수록 주의력 분산**
- **`/compact` 대신 새 세션 선호** — 성능 저하 방지
- 프롬프트 캐시가 **5분**에 만료 → 긴 세션을 재개하면 전체 토큰이 재과금됨
- **휴식 시:** 마크다운 파일로 진행 상태(완료/다음/결정) 기록 → 다음 세션에서 즉시 복원

---

## 6. Skills — 워크플로우 자동화

### CLAUDE.md vs Skills

- **CLAUDE.md** — 세션 시작 시 로드, 대화가 길어지면 주의력 이탈
- **Skills** — 이름+설명만 로드, **호출 시점에 전체 내용이 fresh injection**

> CLAUDE.md는 "항상 X를 해라" 규칙, Skills는 "TDD 단계" 같은 상세 워크플로우.
{: .prompt-tip }

### 발표자의 4대 핵심 스킬

1. **Interview** — 기능 스펙 작성 (PM처럼 질문)
2. **TDD Task** — 테스트 주도 개발
3. **Test** — 테스트 실행 (컨텍스트 오염 방지)
4. **Commit** — 논리적 단위 커밋

> "에이전트는 서두르지 않는다. 매번 같은 규율. 이것이 나를 검증, 설계, 아키텍처에 집중하게 해준다."

![Skills: Interview, TDD, Test, Commit]({{ site.baseurl }}/images/spring-io-2026/slide_13_four_skills.jpg){: .shadow}

### 🌟 Interview 스킬 — 이 발표의 하이라이트

![Interview 스킬 실제 데모: PM처럼 질문하며 스펙 작성]({{ site.baseurl }}/images/spring-io-2026/slide_15_interview.jpg){: .shadow}

**동작 방식:**
1. 서브에이전트가 코드베이스 탐색
2. PM처럼 **다지선다 질문** 시작 ("매니저는 어디서 게임을 찾나요?")
3. 8라운드 진행 → 약 20개 아키텍처/UX 결정 도출
4. 결과물: **170줄 스펙**
5. 스펙 리뷰 → 인라인 코멘트 → Claude가 수정/질문

**실제 발견 사례:**

- "반응 조작을 방지할까?" → 쿠키로 충분? → **Claude가 반박**: "반응은 DB에 저장하면서 예산은 쿠키로?" → DB enforcement로 변경
- 터미널에서 **ASCII 와이어프레임**으로 UX 결정 시각화
- 매니저 vs 관리자 역할 혼란 발견 → guest/manager/admin 3역할 정의

**스펙 리뷰의 함정:**
Claude가 10개 변경을 제안 → "각각 왜 필요한지 설명해" → **8개가 할당된 긴급성**(실제로는 중요하지 않은 엣지 케이스)

> "당신은 여전히 엔지니어다. 각 결정을 이해해야 한다."

### 스킬 진화 과정 — Iterate by Friction

| 반복 | 문제 | 개선 |
|---|---|---|
| 2 | 진입점 누락 | mandatory topics + user stories 추가 |
| 3 | dead end 화면 | state transitions + terminal states 추가 |
| 4 | 26개 유저스토리 | 진입점 누락 **제로** |

CLAUDE.md와 동일한 루프: **관찰 → 실패 발견 → 스킬 개선 → 반복**

### Skill 구조

```markdown
---
name: commit
description: Group changes by logical feature with proper commit messages
---

Body: instructions, steps, constraints, patterns
```

간단한 커밋 스킬은 **4줄**. 마크다운 파일 하나.

### jvmskills.com

- LLM이 이미 아는 내용("생성자 주입, @Transactional")은 스킵
- 전문가 작성/리뷰된 **JVM 특화** 스킬만
- 프롬프트 인젝션 없음

---

![Hooks: Pre-tool use, Post-tool use, Session end]({{ site.baseurl }}/images/spring-io-2026/slide_18_hooks.jpg){: .shadow}

## 7. Hooks — 선택이 아닌 강제

> "Skills drift, Claude.md gets buried. **Hooks fire every time.**"

### 발표자의 4개 Hook

| 이벤트 | Hook | 동작 |
|---|---|---|
| Pre-tool use | **Git Guardrails** | 위험한 Git 명령 차단 (`exit 2` = hard block) |
| Pre-tool use | **Pre-commit Gate** | lint/compile 실패 시 커밋 차단 |
| Post-tool use | **Detekt Lint** | 파일 수정 직후 Kotlin 정적분석 피드백 |
| Session end | **Uncommitted Warning** | CLI 종료 시 미커밋 변경 경고 |

### Git Guardrails 상세

Pre-tool use 훅이 모든 tool call 전에 실행. `exit 2`를 반환하면 Claude가 **물리적으로 명령을 실행할 수 없다**. Claude는 차단 사유를 보고 적응.

### Detekt로 실수 영구 차단

**실제 사례:** Claude가 Jackson 2의 `ObjectMapper` import → Spring Boot 4에는 Jackson 2가 존재하지 않음 → 앱 시작 실패 → Claude가 JSON을 **문자열 결합**으로 직렬화 (더 나쁨)

**해결:** Detekt에 forbidden import 규칙 추가 → Jackson 3의 `JsonMapper`를 대안으로 제시 → Post-tool use 훅이 매 수정 후 즉시 감지 → Claude가 **같은 턴에서 수정**

> **그 실수는 두 번 다시 일어날 수 없다.** 제약이 자동화되었으므로.
{: .prompt-tip }

### 훅 vs 스킬 vs CLAUDE.md

```
CLAUDE.md  → 세션 간 복리, BUT 무시될 수 있음
Skills     → 호출 시 fresh, BUT 컨텍스트에서 이탈 가능
Hooks      → 매번 실행, 강제, 무시 불가
```

> **훅에 넣을 수 있다면 훅에 넣어라.**
{: .prompt-tip }

---

![MCP: 에이전트를 IDE에 연결]({{ site.baseurl }}/images/spring-io-2026/slide_20_mcp.jpg){: .shadow}

## 8. MCP — 에이전트를 IDE에 연결

MCP(Model Context Protocol)로 Claude가 코드베이스 밖의 도구에 접근.

### 발표자가 사용하는 MCP 서버

- **IntelliJ MCP** — Reformat file, 자동 import 최적화, Run Configuration 실행 (가장 많이 사용)
- **Linear** — 이슈 읽기/업데이트/다음 태스크
- **Sentry** — 프로덕션 에러 직접 조사 (스택 트레이스 복사 불필요)
- **Javadoc Central** — 최신 라이브러리 문서 제공
- **Spring AI MCP Service Starter** — 커스텀 MCP 서버 구축

![IDE가 에이전트의 API가 된다]({{ site.baseurl }}/images/spring-io-2026/slide_21_ide_as_api.jpg){: .shadow}

### IntelliJ MCP가 특히 중요한 이유

**Without MCP:** Claude가 `sed`로 포맷팅, import를 손으로 수정, `Gradle`로 앱 시작 → **에이전트가 툴체인과 싸움**

**With MCP:** Claude가 `reformat file` 호출, 자동 import 최적화, run configuration 재실행 → **에이전트가 IDE를 당신처럼 사용**

> IDE가 에이전트의 API가 된다. 이것이 **Agent Developer Experience**다.
{: .prompt-tip }

### MCP Steward 프로젝트 비전

- 에이전트에게 IntelliJ 전체 API 접근 권한 부여 (디버거, 리팩토링, 인스펙션, 스크린샷)
- **"에이전트가 사용자, 개발자가 아님"** — 에이전트 우선 도구 설계
- 장기 비전: UI 없는 헤드리스 IntelliJ 런타임

### 팁: Claude가 MCP를 먼저 사용하게 하려면

Claude는 기본적으로 bash/sed를 먼저 사용하도록 훈련됨. **CLAUDE.md에 한 줄 추가**로 해결:

```
Use "reformat file" instead of sed for formatting.
```

---

![워크플로우 5단계]({{ site.baseurl }}/images/spring-io-2026/slide_22_five_levels.jpg){: .shadow}

## 9. 워크플로우 5단계

### Level 1: Human in the Loop

**여기서 시작해야 한다.** 설명 → 관찰 → 리다이렉트. 버그 수정, 소규모 기능에 적합. 에이전트의 사고방식을 체득하는 시간.

> 자율 에이전트부터 시작하면 실패를 이해하지 못한다.
{: .prompt-warning }

### Level 2: Plan Mode

코드 작성 전 구조 설계. Shift+Tab으로 수동 트리거도 가능. 탐색/프로토타이핑에 적합.

### Level 3: Spec-Driven (Interview)

스펙으로 요구사항을 외부화. 복잡한 기능, 결정이 필요한 작업. **20분 인터뷰 = 몇 시간 회의 대체.**

**반복 1 (vibe coding) vs 반복 4 (spec-driven):**
- 반복 1: 테스트 0, 버그 8개, 스펙 없음
- 반복 4: 테스트 37개, 설계 결정 20개, CLAUDE.md 규칙 8개 추가

![Level 5: The Ralph Loop]({{ site.baseurl }}/images/spring-io-2026/slide_23_ralph.jpg){: .shadow}

### Level 4: Ralph — 자율 루프

> Claude는 게으르다. 스킬을 스킵하고, 코너를 자르고, 계획의 단계를 누락한다.
{: .prompt-warning }

**해결책:** Ralph — 단순한 **bash while 루프**.

```bash
# 각 phase에 fresh session으로 실행
while IFS= read -r phase; do
  claude -p "$phase"
done < plan.md
```

- 각 phase가 **fresh context** → 스킬 체크리스트가 드리프트하지 않음
- 계획이 전체 프롬프트 → 드리프트 제로

**진화:** 마크다운 체크리스트(39테스트, 뭉침) → **built-in TodoWrite 도구**(60테스트, 매 phase마다 test-first)

> **"낮에는 생각하고, 밤에는 Claude가 구현한다."** — Matt Pocock

![Get a Second Opinion — Claude + Codex 병렬 리뷰]({{ site.baseurl }}/images/spring-io-2026/slide_24_multi_agent.jpg){: .shadow}

### Level 5: 멀티 에이전트 리뷰

Claude Code + OpenAI Codex를 같은 브랜치/프롬프트로 병렬 코드 리뷰:

- **Claude 발견:** 타이머 hanging, 게임 종료 후 리다이렉트 누락, 예산 체크 race condition
- **Codex 발견:** `isManager` 체크 누락, live guest list 스크립트 인젝션
- **겹친 것:** 1개 (예산 race condition)
- **다른 모델 = 다른 맹점**

---

## 10. 실전 팁

### Sandbox — 자율 루프의 핵심

- 파일 시스템: 프로젝트 디렉토리로 잠금
- 네트워크: 승인된 도메인만 (Maven Central, Gradle, GitHub)
- Docker: 마이크로 VM 격리, 초 단위 재생성

### 음성 인터페이스

[handy.computer](https://handy.computer) — 오픈소스, 로컬 실행, 사용량 무제한.

> 타이핑하면 게을러지지만, 말하면 사고 과정이 드러난다. Claude가 다듬어진 프롬프트가 아닌 **사고 과정**을 본다.
{: .prompt-tip }

### Worktree — 병렬 에이전트 환경

`worktrunk`로 Git worktree를 브랜치처럼 쉽게 관리:
- 에이전트별 독립 환경 (전용 Postgres, LocalStack, 결정론적 포트 해싱)
- IntelliJ 자동 오픈 (post-start hook)
- 완료 후 한 명령어로 squash + rebase + 정리

3개 에이전트가 3개 기능을 서로 충돌 없이 병렬 개발.

![Three Agents, Zero Conflicts — Worktrunk]({{ site.baseurl }}/images/spring-io-2026/slide_25_worktrunk.jpg){: .shadow}

### Rebase Commit Skill

여러 세션의 커밋 노이즈 → 논리적 기능 단위로 정리. 리뷰어가 디버깅 노이즈가 아닌 **기능**을 볼 수 있게.

---

![The speed is free, but the discipline is yours]({{ site.baseurl }}/images/spring-io-2026/slide_26_discipline.jpg){: .shadow}

## 핵심 철학

> **"The speed is free, but the discipline is yours."**

반복 1에서 속도는 이미 있었다. Claude가 다른 셋업보다 **더 빨랐다**. 달라진 것은 Claude **주변의 모든 것** — CLAUDE.md, Skills, Hooks, Specs.

- AI가 코딩하면 엔지니어링 품질은 사라지지 않는다 — **스펙, 테스트, 제약, 리스크 관리로 이동**한다
- 구현이 저렴해지면 **판단력이 병목**이 된다
- 나쁜 소프트웨어를 만드는 게 그 어느 때보다 쉬워졌다 → **주인의식이 그 어느 때보다 중요**

### 유일한 방법: Iterate by Friction

```
관찰 → 실패 발견 → 규칙/스킬/훅 추가 → 반복
```

단축키는 없다. 하지만 **셋업이 복리**로 쌓인다:

> 모든 규칙, 모든 스킬, 모든 세션 — Claude가 프로젝트에 대해 더 잘 알게 된다. AI가 똑똑해져서가 아니라, **셋업이 프로젝트를 더 많이 알게 되어서** 빨라진다.
{: .prompt-tip }

---

## 참고 링크

- [영상 원본](https://www.youtube.com/watch?v=PmW4-tcMQbc)
- [Spring I/O 2026 Playlist](https://www.youtube.com/playlist?list=PLe6FX2SlkJdQZ3N0SW9Abo4cN7eO5dU-U)
- [jvmskills.com](https://jvmskills.com) — JVM 전문가 작성 Claude Code 스킬
- [handy.computer](https://handy.computer) — 오픈소스 로컬 음성 인터페이스
