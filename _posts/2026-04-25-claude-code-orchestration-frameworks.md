---
     2|title: "Claude Code 오케스트레이션 프레임워크 비교 — Superpowers vs GSD vs GSTACK"
     3|layout: post
     4|date: 2026-04-25 00:00:00
     5|categories:
     6|  - AI
     7|tags:
     8|  - AI
     9|  - Claude
    10|  - CodingAgent
    11|  - Orchestration
    12|  - Superpowers
    13|  - GSD
    14|  - GSTACK
    15|  - ClaudeCode
    16|mermaid: true
---
    17|
    18|> 원문: [Superpowers, GSD, and GSTACK: Picking the Right Framework for Your Coding Agent](https://www.pulumi.com/blog/claude-code-orchestration-frameworks/) (Pulumi Blog, 2026.04.13)
    19|
    20|## 들어가며
    21|
    22|AI 코딩 에이전트(Claude Code, Cursor, Codex, Windsurf 등)는 처음 30분은 놀라울 정도로 잘 동작한다. 하지만 시간이 지날수록 예측 가능하게 무너진다. 세 개의 독립적인 팀이 **같은 문제를 해결하기 위해** 각각 프레임워크를 만들었다. 이 문서에서는 이 세 프레임워크의 핵심을 정리하고, **개발자와 기획자**가 실제로 어떻게 활용할 수 있는지 살펴본다.
    23|
    24|---
    25|
    26|## AI 코딩 에이전트의 3가지 공통 문제
    27|
    28|### 1. 컨텍스트 부패 (Context Rot)
    29|
    30|모든 LLM에는 컨텍스트 윈도우가 있다. 윈도우가 채워질수록 **초기 지시사항의 영향력이 약해진다**.
    31|
    32|> 처음에 "AES-256 암호화, 적절한 ACL, 접근 로깅이 포함된 S3 버킷"을 요청했다. 2시간, 200K 토큰 뒤에 에이전트가 만든 새 버킷에는 그 요구사항 중 아무것도 없었다.
    33|
    34|### 2. 테스트 부재 (No Test Discipline)
    35|
    36|에이전트가 작성한 코드는 "그럴듯해 보인다". 컴파일도 되고, 잠시는 동작한다. 하지만 **테스트 없는 코드는 부채**다. 에이전트가 기능을 하나 추가하면서 조용히 다른 두 개를 망가뜨려도 아무도 모른다.
    37|
    38|### 3. 범위 확장 (Scope Drift)
    39|
    40|VPC 3개 서브넷을 요청했는데, 에이전트가 NAT Gateway, Transit Gateway, VPN Endpoint, Custom DNS Resolver까지 추가한다. 이론적으로는 도움이 되지만, **요청하지 않은 인프라를 이해하지 못한 채 매월 비용을 지불**하게 된다.
    41|
    42|---
    43|
    44|## Superpowers: TDD 규율 강제기
    45|
    46|| 항목 | 내용 |
    47||------|------|
    48|| **작성자** | Jesse Vincent |
    49|| **GitHub Stars** | 149K+ |
    50|| **핵심 철학** | 실패하는 테스트 없이 프로덕션 코드를 작성할 수 없다 |
    51|