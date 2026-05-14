---
     2|title: "Claude Code Build Loop 스킬 — GSD Phase를 자동으로 연속 실행하기"
     3|layout: post
     4|date: 2026-05-04 00:00:00
     5|categories:
     6|  - AI
     7|tags:
     8|  - AI
     9|  - Claude
    10|  - ClaudeCode
    11|  - BuildLoop
    12|  - RalphLoop
    13|  - GSD
    14|  - Automation
    15|mermaid: true
---
    16|
    17|> **관련 글**: [GStack + GSD + Superpowers 워크플로우 정리]({% post_url 2026-05-04-gstack-gsd-superpowers-workflow %})
    18|
    19|---
    20|
    21|## Build Loop란?
    22|
    23|GSD(Get Shit Done)로 분해한 Phase를 `claude -p` 헤드리스 세션으로 **자동 연속 실행**하는 Claude Code 커스텀 스킬이다. Ralph Wiggum Loop 패턴을 GSD 워크플로우에 맞게 적용한 것이다.
    24|
    25|### 왜 필요한가?
    26|
    27|GSD는 프로젝트를 여러 Phase로 나누지만, 각 Phase를 수동으로 하나씩 실행해야 한다:
    28|
    29|```bash
    30|# 수동 실행 — Phase가 10개면 10번 반복
    31|$ claude -p "$(cat .planning/phases/01/01-01-PLAN.md)"
    32|$ claude -p "$(cat .planning/phases/02/02-01-PLAN.md)"
    33|$ claude -p "$(cat .planning/phases/03/03-01-PLAN.md)"
    34|# ...
    35|```
    36|
    37|Build Loop는 이 과정을 **자동화**한다.
    38|
    39|---
    40|
    41|## 설치
    42|
    43|### 방법 1: skills CLI (권장)
    44|
    45|```bash
    46|# build-loop 스킬 설치
    47|npx skills add pallidev/agent-skills --skill build-loop
    48|
    49|# 글로벌 설치 (모든 프로젝트에서 사용)
    50|npx skills add pallidev/agent-skills --skill build-loop -g
    51|