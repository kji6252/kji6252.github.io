---
     2|title: "GStack + GSD + Superpowers — 세 프레임워크를 결합한 Claude Code 워크플로우"
     3|layout: post
     4|date: 2026-05-04 00:00:00
     5|categories:
     6|  - AI
     7|tags:
     8|  - AI
     9|  - Claude
    10|  - ClaudeCode
    11|  - SpecDriven
    12|  - GStack
    13|  - GSD
    14|  - Superpowers
    15|  - TDD
    16|  - CodingAgent
    17|mermaid: true
---
    18|
    19|> **출처**: Eric Tech — "GStack + GSD + Superpowers Workflow Is Insane!"
    20|> [영상 링크](https://www.youtube.com/watch?v=BlTpG51x94w)
    21|> - [GStack](https://github.com/garrytan/gstack)
    22|> - [Superpowers](https://github.com/obra/superpowers)
    23|> - [GSD](https://github.com/gsd-build/get-shit-done)
    24|
    25|---
    26|
    27|## 전제조건
    28|
    29|| 항목 | 요구사항 |
    30||------|---------|
    31|| Claude Code | 최신 버전 권장 (`claude --version` 확인) |
    32|| API 요금제 | `claude -p` (헤드리스 실행) 사용 가능한 플랜 필요 |
    33|| 병렬 에이전트 | Claude Code의 Agent 도구(Subagent) 기본 지원 — 별도 설정 불요 |
    34|| 디스크 | 프로젝트당 `.planning/` 폴더 생성 (수십 개 파일) |
    35|
    36|---
    37|
    38|## 상황별 추천 조합
    39|
    40|> **먼저 확인하세요** — 모든 상황에서 세 개를 다 쓸 필요는 없습니다. 프로젝트 규모에 따라 조합하세요.
    41|
    42|| 상황 | 추천 조합 | 이유 |
    43||------|----------|------|
    44|| 기존 프로젝트에 작은 기능 추가 | **Superpowers 단독** | TDD만으로 충분 |
    45|| 중간 규모 새 프로젝트 | **GStack + Superpowers** | 설계 토론 + TDD |
    46|| 처음부터 만드는 대규모 프로젝트 | **GStack + GSD + Superpowers 전체** | 모든 강점 활용 |
    47|
    48|---
    49|
    50|## 핵심 한 줄 요약
    51|