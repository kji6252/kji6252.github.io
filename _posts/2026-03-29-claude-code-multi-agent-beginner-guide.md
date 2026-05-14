---
     2|title: Claude Code 다중 에이전트 초보자 가이드
     3|layout: post
     4|date: 2026-03-29 00:00:00
     5|categories:
     6|  - AI
     7|tags:
     8|  - AI
     9|  - Agent
    10|  - Claude
    11|  - ClaudeCode
    12|  - MultiAgent
    13|  - tmux
    14|  - Harness
    15|  - BeginnerGuide
    16|mermaid: true
---
    17|
    18|> Agent Teams + tmux + revfactory/harness를 활용한 Claude Code 다중 에이전트 협업 완전 정복
    19|
    20|## 이 가이드에 대하여
    21|
    22|이 가이드는 Claude Code에서 **여러 AI 에이전트를 팀으로 조직하여 협업**하는 방법을 처음부터 차근차근 설명합니다. 세 가지 핵심 주제를 다룹니다:
    23|
    24|| 주제 | 역할 |
    25||------|------|
    26|| **Agent Teams** | Claude Code 내장 다중 에이전트 협업 시스템 |
    27|| **tmux** | 터미널 분할 도구, Agent Teams의 시각적 표시에 활용 |
    28|| **revfactory/harness** | 에이전트 팀 설계를 자동화하는 Claude Code 플러그인 |
    29|
    30|> **Tip**: 이 가이드 자체가 Agent Teams를 사용하여 작성되었습니다. 3명의 팀원이 각 섹션을 병렬로 작성했습니다.
    31|
    32|---
    33|
    34|## Part 1: Agent Teams 기초
    35|
    36|### 1.1 Agent Teams란?
    37|
    38|Agent Teams는 여러 Claude Code 인스턴스를 하나의 **팀(Team)** 으로 조율하여 함께 작동하게 하는 기능입니다.
    39|
    40|```
    41|┌─────────────────────────────────────────────┐
    42|│                  사용자                       │
    43|│                    │                          │
    44|│              ┌─────▼─────┐                   │
    45|│              │   리더     │ ← 메인 세션       │
    46|│              │Team Leader │                   │
    47|│              └──┬───┬───┬┘                   │
    48|│                 │   │   │                     │
    49|│          ┌──────▼┐ ┌▼───┐ ┌▼──────┐         │
    50|│          │팀원 A │ │팀원B│ │팀원 C  │         │
    51|