---
title: Harness Engineering (하네스 엔지니어링) 완전 정복 가이드
layout: post
date: 2026-04-04 00:00:00
categories:
  - AI
tags:
  - AI
  - HarnessEngineering
  - Claude
  - ClaudeCode
  - AIAgent
  - Cursor
  - Copilot
---

> "모델보다 하네스가 성과를 결정한다" — AI 에이전트 시대의 새로운 엔지니어링 패러다임을 완전 정복합니다.
{: .prompt-tip }

## 이 가이드에 대하여

2026년, AI 개발의 키워드가 바뀌었다. **하네스 엔지니어링(Harness Engineering)**. AI 에이전트가 일하는 환경 전체를 설계하는 기술이다. 이 글은 바이브코딩 태일러(@shuntailor)의 "하네스 엔지니어링 완전 정복" PDF를 기반으로, 핵심 개념과 실전 방법론을 정리한 가이드입니다.

| 주제 | 내용 |
|------|------|
| **하네스 엔지니어링이란?** | AI 모델의 지능을 안정적인 결과로 변환하는 환경 설계 기술 |
| **왜 주목하나?** | 같은 모델로 33위에서 5위까지, 하네스가 성과를 결정 |
| **핵심 기둥** | Constrain, Inform, Verify, Correct 4대 원칙 |
| **실전 가이드** | AGENTS.md 작성법, Eval 파이프라인, 비용 최적화까지 |

---

## Part 1: 왜 하네스 엔지니어링인가

### 바이브코딩의 한계

2025년 Andrej Karpathy가 "vibe coding"이라는 개념을 소개하며 코드를 직접 타이핑하지 않고 자연어로 AI에게 지시하는 개발 방식이 폭발적으로 성장했습니다. 하지만 바이브코딩에는 치명적인 한계가 있었습니다.

- **보안 구멍**: AI 생성 코드의 약 45%에서 보안 취약점 발견
- **재현 불가능**: 같은 프롬프트에 3번 다른 코드가 나옴
- **컨텍스트 유실**: 세션이 길어지면 이전 설계 결정을 잊음
- **검증의 한계**: "눈으로 확인"은 400줄 이후 결함 발견율 절반 이하로 하락

### Agent = Model + Harness

2026년 2월, Terraform 창시자 **Mitchell Hashimoto**가 "하네스 엔지니어링"이라는 용어를 처음 사용했습니다.

> "에이전트가 실수할 때마다, 그 실수를 두 번 다시 일으키지 않게 하는 장치를 설계한다."

에이전트는 모델(Model)과 하네스(Harness)의 합입니다. 모델은 두뇌이고, 하네스는 그 두뇌가 제대로 일하게 만드는 모든 것입니다. Hugging Face의 Philipp Schmid는 이 관계를 컴퓨터에 빗대어 설명했습니다.

| 컴퓨터 | AI 에이전트 | 역할 |
|--------|------------|------|
| CPU | 기반 모델 (LLM) | 추론 능력, 사고력 |
| RAM | 컨텍스트 윈도우 | 휘발성 작업 메모리 |
| OS | 에이전트 하네스 | 컨텍스트 관리, 라이프사이클 관리 |
| Application | 에이전트 | 사용자 고유의 로직과 워크플로우 |

### 숫자가 증명하는 것

**LangChain 실험**: 모델(GPT-5.2-Codex)을 고정하고 하네스만 변경 → TerminalBench 2.0 점수 52.8% → 66.5% (+13.7%p), 리더보드 약 30위 → Top 5.

**TerminalBench 리더보드**: 같은 Claude Opus 4.6 모델이 하네스에 따라 33위도, 5위도 기록.

**OpenAI Codex**: 100만 줄 이상의 프로덕션 코드를 인간 코드 0줄로 생성. 5개월, 3~7명 엔지니어가 한 일은 코딩이 아니라 하네스 설계.

**Stripe**: 매주 1,000건 이상 PR을 에이전트가 완전 자동 머지.

**Anthropic 비용 실험**: 싱글 에이전트 $9(비기능적 결과물) vs. 풀 하네스 $200(완전 기능 결과물). $9짜리는 돌아가지 않았고, $200짜리는 완전히 동작함.

> "모델을 교체해서 5%를 개선하는 것보다, 하네스를 설계해서 15%를 개선하는 것이 현실적이다."
{: .prompt-tip }

---

## Part 2: 4개의 기둥

하네스의 기능은 **Constrain, Inform, Verify, Correct** 4가지 기둥으로 집약됩니다.

### 1. Constrain — 제한하는 기술

에이전트의 행동 범위를 제한합니다. 해공간을 좁힐수록 에이전트의 정확도는 올라갑니다.

**5계층 방어 아키텍처** (OpenDev 논문, arXiv:2603.05344):

| 계층 | 내용 |
|------|------|
| Layer 1: 프롬프트 가드레일 | 시스템 프롬프트에 금지 행동 명시 |
| Layer 2: 스키마 레벨 도구 제한 | 도구 자체를 제한 (Plan: 읽기만, Execute: 쓰기 허용) |
| Layer 3: 런타임 승인 시스템 | Manual / Semi-Auto / Auto 3단계 승인 |
| Layer 4: 도구 레벨 검증 | 위험 패턴 블록리스트, stale-read 감지 |
| Layer 5: 라이프사이클 훅 | 실행 전·중·후 커스텀 스크립트 삽입 |

**핵심 구현 방법**:

- **샌드박스 격리**: OpenAI Codex는 Firecracker 기반 마이크로VM 사용. 태스크마다 VM 생성 후 파괴
- **도구 허용 목록**: Anthropic 연구에 따르면 "도구가 적을수록 에이전트 정확도가 올라간다"
- **파일 경로 제한**: 읽기/쓰기 권한 분리, `.env` 파일 접근 차단
- **비용 상한**: 토큰 상한 + 금액 상한 + 모델 티어링 전략
- **시간/반복 제한**: LangChain의 LoopDetectionMiddleware로 둠 루프 탐지

### 2. Inform — 알려주는 기술

에이전트에게 필요한 정보를 적시에 제공합니다.

> "컨텍스트 엔지니어링은 바람직한 결과의 가능성을 최대화하는, 가장 작은 고품질 토큰 집합을 찾는 것" — Anthropic

**3가지 정보 전달 채널**:

| 채널 | 역할 | 비유 |
|------|------|------|
| 정적 문서 (AGENTS.md) | 항상 로드되는 기본 지침 | 부서 매뉴얼 |
| 동적 컨텍스트 (MCP, RAG) | 필요한 시점에 가져오는 정보 | 도서관 |
| 이벤트 기반 리마인더 | 상황에 맞춰 자동 주입 | 시니어 개발자의 속삭임 |

**주의할 점 — Goldilocks Zone**:

ETH Zurich 연구에 따르면, LLM이 자동 생성한 AGENTS.md는 오히려 성능을 **3% 하락**시키고 비용을 **20% 증가**시켰습니다. HumanLayer의 데이터도 지침이 많을수록 개별 준수율이 떨어진다고 밝혔습니다. 사람이 핵심만 골라서 60줄 이내로 작성해야 합니다.

### 3. Verify — 검증하는 기술

에이전트의 출력을 자동으로 검증합니다. "눈으로 확인"의 시대는 끝났습니다.

**AI 출력은 확률적**이므로, 검증도 확률적으로 설계해야 합니다. `assert output == expected`가 아니라 `assert output in acceptable_range`입니다.

**Eval의 기본 구조**: 입력(Task) → 에이전트 실행 → 출력(Result) → 평가 기준(Grader). 10번 실행해서 8번 이상 성공하면 합격(80% 임계값).

**3가지 검증 유형**:

| 유형 | 검증 대상 | 장점 | 한계 |
|------|----------|------|------|
| 코드 실행 검증 | 동작 여부 | 객관적, 자동화 | 테스트가 없으면 무력 |
| 셀프 검증 루프 | 요구사항 충족 | 추가 도구 불필요 | 에이전트 자신의 한계 |
| 외부 도구 검증 | 품질·보안 | 일관된 기준 | 설정·유지 비용 |

**임계값 가이드**: 보안 관련 95%+, 포매팅/컨벤션 90%+, 기능 구현 70~80%, 복잡한 리팩토링 50~60%.

### 4. Correct — 수정하는 기술

실패를 전제하고, 감지하고, 복구하고, 같은 실패가 반복되지 않게 기록합니다.

**4가지 수정 패턴**:

1. **에러 리커버리**: 감지 → 분석 → 복구 3단계. 에러 메시지는 "무엇이 잘못됐고 어떻게 고치는지"를 포함해야 함
2. **재시도 로직**: 지수 백오프 + 대체 경로 시도. LangChain의 Ralph Loop는 깨끗한 컨텍스트에서 재시도
3. **Human-in-the-Loop**: 3회 이상 같은 에러, 스코프 크리프, 보안 결정, 비가역 작업 시 사람에게 에스컬레이션
4. **가비지 컬렉션**: 정기적으로 문서 불일치와 규칙 위반을 탐지. OpenAI의 5번째 핵심 교훈

**Hashimoto 원칙**: 에이전트 실수 1건 = AGENTS.md에 방지책 1줄 추가. 삭제하지 않고 누적. 시간이 지나면 프로젝트의 "학습된 지혜"가 됨.

### 4개 기둥의 순환

```
Constrain → Inform → Verify → Correct → (다시 Constrain 강화)
```

Correct에서 발견된 패턴이 Constrain의 새 규칙이 되고, Inform에 반영되며, Verify의 Eval에 추가됩니다. 한 바퀴 돌 때마다 구멍이 하나씩 막힙니다.

---

## Part 3: 실전 하네스 설계

### AGENTS.md 작성법

**6대 핵심 영역** (GitHub 2,500+ 리포지토리 분석):

1. 프로젝트 개요 (기술 스택, 아키텍처)
2. 코딩 규약 (네이밍, 포매팅, 린터)
3. 빌드·테스트 (명령어, CI 파이프라인)
4. 금지 사항 (보안·성능·호환성 제약)
5. 도구 사용법 (프로젝트 전용 스크립트, 환경 변수)
6. 알려진 함정 (과거 실패 사례와 우회 방법)

**분량은 60줄 이내**: 토큰 효율, 주의력 집중, 유지보수 용이. 60줄을 넘으면 디렉토리별로 분할합니다.

**좋은 지시 vs. 나쁜 지시**:

| # | 나쁜 지시 | 좋은 지시 |
|---|----------|----------|
| 1 | 코드를 깔끔하게 작성하세요 | 함수 20줄 이내. 변수명 camelCase. 매직넘버 금지 |
| 2 | 테스트를 충분히 작성하세요 | 모든 public 메서드에 단위 테스트. 커버리지 80% 이상 |
| 3 | 에러를 적절히 처리하세요 | HTTP API: try-catch 후 `{code, message}` 반환. 500은 로깅 필수 |
| 4 | 보안에 신경 쓰세요 | SQL은 반드시 파라미터 바인딩. 문자열 연결 SQL 금지 |

### 도구 설계 패턴 5가지

Anthropic의 도구 설계 7원칙 중 가장 중요한 것: **도구 설명문이 에이전트의 행동을 직접 바꾼다**. 설명문 한 줄 수정으로 올바른 도구 선택률이 40% → 78%로 향상된 사례가 있습니다.

**에이전트 오케스트레이션 패턴**:

| 패턴 | 설명 | 적합한 상황 |
|------|------|------------|
| Router | 입력 유형별로 전문 처리 경로 분배 | 고객 지원, 요청 분류 |
| Chain | 순차적 파이프라인 | 코드 생성 → 린팅 → 테스트 → 리뷰 |
| Parallel | 독립 태스크 동시 실행 | 시장 조사 + 경쟁사 분석 + 고객 인터뷰 |
| Orchestrator-Worker | PM이 하위 에이전트에 배분 | 복잡한 다단계 프로젝트 |
| Evaluator-Optimizer | 구현 + 검증 분리 | 품질이 중요한 프로덕션 코드 |

---

## Part 4: 플랫폼별 하네스 비교

| 플랫폼 | 격리 방식 | 권한 모델 | 특징 |
|--------|----------|----------|------|
| **Claude Code** | 로컬 실행 + 퍼미션 | 3단계 (Manual/Semi/Auto) | 라이프사이클 훅, 점진적 신뢰 |
| **OpenAI Codex** | 마이크로VM (Firecracker) | 완전 격리 | 태스크당 VM, 물리적 분리 |
| **Cursor** | IDE 내장 규칙 | 경로별 MDC 규칙 | 모델별 튜닝 |
| **Devin** | 워크스페이스 격리 | 전용 셸 + 에디터 | Brain(클라우드) + Workspace(샌드박스) 분리 |

---

## Part 5: 비용 최적화 핵심

### 모델 티어링 전략

LangChain의 "추론 샌드위치": 계획 단계(높은 추론) → 구현(표준 추론) → 최종 검증(높은 추론). Opus 없이 Sonnet + 하네스 조합이 비용 1/5로 더 나은 결과를 낼 수 있습니다.

### 성공한 하네스의 5가지 공통 패턴

1. **검증 자동화**: 모든 성공 사례에 에이전트 출력 자동 검증 체계 존재
2. **컨텍스트 정밀 관리**: 필요한 정보를 필요한 시점에 필요한 에이전트에게만 제공
3. **실패에서 학습**: 실수할 때마다 환경 업데이트 (Hashimoto의 1실패=1규칙)
4. **점진적 신뢰 구축**: 보수적으로 시작해서 확신이 쌓이면 게이트를 여는 방식
5. **모델이 아닌 환경에 투자**: OpenAI 5개월, Manus 6개월(5회 재작성)

### 실패하는 하네스의 징후

- 에이전트가 같은 파일을 반복 수정 (둠 루프)
- AGENTS.md가 100줄을 넘어가는데도 효과 없음
- Eval 없이 에이전트 최적화 시도
- LLM이 생성한 가이드라인을 검증 없이 사용
- 모델 교체를 먼저 시도

---

## 참고 자료 및 출처

이 글은 다음 자료를 기반으로 작성되었습니다.

### 원본 자료

- 바이브코딩 태일러, **"하네스 엔지니어링 완전 정복: AI 에이전트를 제대로 다루는 기술"** (2026 EDITION, 130+ sources, 23 chapters)

### 핵심 기초 문헌

- Mitchell Hashimoto, ["My AI Adoption Journey"](https://mitchellh.com/writing/my-ai-adoption-journey) (2026.02.05) — 하네스 엔지니어링 용어 최초 사용
- OpenAI, ["Harness Engineering: Leveraging Codex in an Agent-First World"](https://openai.com/index/harness-engineering/) (2026.02)
- Birgitta Bockeler / Martin Fowler, ["Harness Engineering"](https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html) (2026.02.17)
- Anthropic, ["Building Effective Agents"](https://www.anthropic.com/research/building-effective-agents) (2024.12)
- Anthropic, ["Effective Context Engineering for AI Agents"](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- Anthropic, ["Writing Effective Tools for AI Agents"](https://www.anthropic.com/engineering/writing-tools-for-agents)
- Anthropic, ["Demystifying Evals for AI Agents"](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents)

### 플랫폼 공식 문서

- Cursor, ["Agent Best Practices"](https://cursor.com/blog/agent-best-practices)
- GitHub Blog, ["How to Write a Great AGENTS.md"](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-learned-from-2500-repositories)

### 에이전트 프레임워크

- LangChain, ["Improving Deep Agents with Harness Engineering"](https://blog.langchain.com/improving-deep-agents-with-harness-engineering/) (2026.02.17)
- HumanLayer / Kyle, ["Skill Issue: Harness Engineering for Coding Agents"](https://www.humanlayer.dev/blog/skill-issue-harness-engineering-for-coding-agents) (2026.03.12)

### 업계 분석

- Philipp Schmid, ["The Importance of Agent Harness in 2026"](https://www.philschmid.de/agent-harness-2026)
- Deloitte, ["State of AI in Enterprise 2026"](https://www.deloitte.com/us/en/about/press-room/state-of-ai-report-2026.html)
- Gartner: 에이전틱 AI 프로젝트 40%+ 2027년까지 중단 예측
