---
title: "Mermaid 다이어그램 기초"
tags: [guide, claude-obsidian, 백엔드, mermaid]
part: "Part 5: 문서화 기법"
created: 2026-01-10
parent: 백엔드 개발자를 위한 Claude Code + Obsidian 지식 관리법
nav_order: 1
---

# Mermaid 다이어그램 기초

Mermaid 문법을 사용하여 시스템 아키텍처, API 흐름, 데이터 모델을 시각화하는 방법을 배웁니다.

## Mermaid란?

Markdown으로 다이어그램을 작성할 수 있는 도구입니다.

```mermaid
```mermaid
graph TD
    A[Mermaid] --> B[텍스트로 작성]
    B --> C[자동 렌더링]
    C --> D[이미지 변환]
```

## 지원되는 다이어그램

| 유형 | 백엔드 활용 | 예시 |
|------|-------------|------|
| **flowchart** | 프로세스 흐름 | 주문 처리 흐름 |
| **sequenceDiagram** | API 호출 순서 | 결제 API 흐름 |
| **erDiagram** | 데이터 모델 | ERD |
| **graph** | 아키텍처 | 마이크로서비스 |
| **gantt** | 프로젝트 일정 | 개발 계획 |
| **stateDiagram** | 상태 머신 | 주문 상태 |

## 기초 문법

### Flowchart

```mermaid
flowchart LR
    A[클라이언트] --> B[API Gateway]
    B --> C[서비스 A]
    B --> D[서비스 B]
    C --> E[(데이터베이스)]
    D --> E
```

### Sequence Diagram

```mermaid
sequenceDiagram
    actor U as 사용자
    participant A as API
    participant S as 서비스
    participant D as DB

    U->>A: 요청
    A->>S: 처리 요청
    S->>D: 조회
    D-->>S: 데이터
    S-->>A: 응답
    A-->>U: 결과
```

### ERD

```mermaid
erDiagram
    USER ||--o{ ORDER : places
    ORDER ||--|{ ORDER_ITEM : contains
    PRODUCT ||--o{ ORDER_ITEM : ordered
```

---

## 다음 단계

백엔드 다이어그램 활용:

→ [[17-mermaid-backend|백엔드 다이어그램]]
