---
title: "학습 사이클"
tags: [guide, claude-obsidian, 백엔드, learning-cycle]
part: "Part 6: 실전 워크플로우"
created: 2026-01-10
parent: 백엔드 개발자를 위한 Claude Code + Obsidian 지식 관리법
nav_order: 3
---

# 학습 사이클

새로운 기술을 학습하고 지식으로 만드는 과정을 정립합니다.

## 학습 루프

```mermaid
flowchart LR
    A[자료 발견] --> B[빠른 메모]
    B --> C[요약 및 정리]
    C --> D[실전 적용]
    D --> E[영구 메모]
    E --> F[관련 개념 연결]
    F --> G[MOC 업데이트]
```

## 1단계: 자료 발견

```markdown
# Inbox/learning-queue.md
## Kafka Exactly-Once
- https://docs.confluent.io/...
- 핵심: 트랜잭션 + idempotence
```

## 2단계: 요약

```markdown
Claude:
"이 문서를 요약해서
학습 노트를 만들어줘.

Templates/tech-study 사용"
```

## 3단계: 실전 적용

```markdown
# PoC 작성
```kotlin
// Kafka Exactly-Once 테스트
@Configuration
class KafkaConfig {
    // 설정
}
```
```

## 4단계: 영구 메모

```markdown
# Kafka Exactly-Once 보장

## 핵심
1. 트랜잭션으로 producer 구성
2. idempotence 활성화
3. consumer의 offset-commit 트랜잭션

## 코드
```kotlin
{{예시}}
```

## 적용
- 주문 처리
- 결제

## 관련
- [[Kafka/기초]]
- [[분산-트랜잭션]]
```

---

→ Part 7: 팀 협업
