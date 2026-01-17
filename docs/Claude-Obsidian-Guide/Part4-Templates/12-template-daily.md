---
title: "일일 기록 템플릿"
tags: [guide, claude-obsidian, 백엔드, template-daily]
part: "Part 4: 템플릿 활용"
created: 2026-01-10
parent: "Part 4: 템플릿 활용"
grand_parent: 백엔드 개발자를 위한 Claude Code + Obsidian 지식 관리법
nav_order: 2
---

# 일일 기록 템플릿

매일의 작업, 학습, 회의 내용을 기록하는 템플릿을 만들고 활용하는 방법을 배웁니다.

## 개요

일일 노트(Daily Notes)는 지식 관리의 기초가 되는 핵심 요소입니다. 매일의 활동을 기록함으로써 시간의 흐름에 따른 학습, 문제 해결, 성장을 추적할 수 있습니다.

## 학습 목표

- [ ] 일일 노트 템플릿 구조 이해하기
- [ ] Daily Notes 플러그인 설정하기
- [ ] Templater로 자동화 구축하기
- [ ] Claude와 함께 일일 회고 작성하기

---

## 템플릿 구조

### 기본 구조

```markdown
---
title: "{{date:YYYY-MM-DD}}"
tags: [daily]
---

# {{date:YYYY-MM-DD}} {{day_of_week}}

## 오늘의 계획
- [ ] {{task_1}}
- [ ] {{task_2}}
- [ ] {{task_3}}

## 회의 일정
- {{time_1}} - {{meeting_1}}
- {{time_2}} - {{meeting_2}}

## 완료한 작업
- [x] {{completed_1}}
- [x] {{completed_2}}

## 해결한 문제
{{if_troubleshooting}}

## 배운 것
{{if_learning}}

## 코드 리뷰
{{if_code_review}}

## 내일 할 일
- [ ] {{tomorrow_1}}
- [ ] {{tomorrow_2}}

## 메모
{{notes}}

---

## 관련 링크
- [[{{yesterday_note}}]]: 어제
- [[{{tomorrow_note}}]]: 내일
- [[{{current_week}}]]: 이번 주
```

---

## Obsidian Daily Notes 설정

### 1. Daily Notes 플러그인 설치

1. **설정 → 서드파티 플러그인**
2. **"Daily Notes" 검색 후 설치**
3. **플러그인 활성화**

### 2. 기본 설정

```yaml
새 파일 위치: daily/
파일명 형식: YYYY-MM-DD.md
템플릿 위치: Templates/daily-note.md
```

### 3. 단축키 설정

```yaml
단축키: Ctrl/Cmd + D
```

---

## Templater로 자동화

### 날짜 자동 입력

```javascript
<%*
// 현재 날짜와 요일 자동 생성
let today = tp.date.now("YYYY-MM-DD");
let dayNames = ["일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일"];
let dayIndex = tp.date.now("d");
let dayName = dayNames[dayIndex];

tR += `# ${today} ${dayName}\n`;
*%>
```

### 어제/내일 노트 링크

```javascript
<%*
// 어제/내일 노트 자동 링크
let yesterday = tp.date.now("YYYY-MM-DD", -1, tp.file.title, "YYYY-MM-DD");
let tomorrow = tp.date.now("YYYY-MM-DD", 1, tp.file.title, "YYYY-MM-DD");

tR += `## 관련 링크\n`;
tR += `- [[${yesterday}]]: 어제\n`;
tR += `- [[${tomorrow}]]: 내일\n`;
*%>
```

### 주간 노트 링크

```javascript
<%*
// 이번 주 시작일 (월요일) 계산
let weekStart = tp.date.now("YYYY-MM-DD", -tp.date.now("d") + 1, tp.file.title, "YYYY-MM-DD");
tR += `- [[${weekStart}]]: 이번 주\n`;
*%>
```

---

## Claude와 일일 노트 작성

### 1. 아침 루틴: 계획 수립

```markdown
사용자:
"오늘 일일 노트를 만들어줘.
어제 완료한 것을 확인하고,
오늘 해야 할 일을 정리해줘."

Claude:
## 2026-01-10 금요일

### 어제 한 일 (2026-01-09)
- [x] Redis 캐싱 전략 수립
- [x] Spring Data Redis 동시성 이슈 해결
- [x] 코드 리뷰 2건 완료

### 오늘의 계획
- [ ] Kafka 컨슈머 랙 문제 분석
- [ ] API 성능 튜닝
- [ ] 팀 미팅 (14:00)
```

### 2. 저녁 루틴: 회고 작성

```markdown
사용자:
"오늘 한 일을 정리해서
일일 노트에 추가해줘."

Claude:
## 완료한 작업

### Kafka 컨슈머 랙 분석
- 문제: 컨슈먈가 메시지를 제때 소비하지 못함
- 원인: max.poll.interval.ms가 너무 짧음
- 해결: 5분 → 10분으로 증가
- 관련: [[Troubleshooting/kafka/consumer-lag]]

### API 성능 튜닝
- 개선 대상: 사용자 조회 API
- 적용: Redis 캐싱 추가
- 결과: 50ms → 5ms (90% 개선)

## 배운 것

### Kafka 컨슈머 설정
max.poll.interval.ms는 폴링 간격보다 충분히 커야 함:
```
최소값 = max.poll.records * 단건 처리 시간 + 버퍼
```

## 해결한 문제

### Redis 동시성 이슈
- 상세: [[Troubleshooting/redis/concurrency-issue]]
- 해결: RedisTemplate으로 HINCRBY 원자적 연산
```

### 3. 주간 회고 준비

```markdown
사용자:
"이번 주(1월 2주차) 일일 노트들을 분석해서
주요 성과와 이슈를 정리해줘."

Claude:
## 2026년 1월 2주차 주간 요약

### 완료한 작업
1. Redis 캐싱 전략 수립
2. Spring Data Redis 동시성 이슈 해결
3. Kafka 컨슈머 랙 문제 해결
4. API 성능 튜닝 (50ms → 5ms)

### 해결한 문제
1. Redis 동시성 경합 (01-08)
2. Kafka 컨슈머 랙 (01-09)
3. PostgreSQL deadlock (01-10)

### 학습 현황
- 완료: Virtual Threads, Redis 데이터 구조
- 진행 중: Kafka Exactly-Once (60%)

### 다음 주 계획
- Kafka 마이그레이션 PoC 시작
- CI/CD 파이프라인 개선
- 주간 기술 발표 준비
```

---

## 실전 예시

### Before: 템플릿 없음

```markdown
# 1월 10일

일했다.
Redis 이슈 해결했고 회의도 했음.
내일은 Kafka 작업 예정.
```

**문제점**
- 구조 없음
- 검색 불가
- 후에 파악 어려움

### After: 템플릿 적용

```markdown
---
title: "2026-01-10"
tags: [daily]
---

# 2026-01-10 금요일

## 오늘의 계획
- [x] Kafka 컨슈머 랙 문제 분석
- [x] API 성능 튜닝
- [x] 팀 미팅 (14:00)
- [ ] 일일 회의록 작성

## 완료한 작업

### Kafka 컨슈머 랙 해결
- 문제: 컨슈머가 메시지 소비 지연
- 원인: max.poll.interval.ms = 5분 (부족)
- 해결: 10분으로 증가
- 결과: 랙 5000 → 0

### API 성능 튜닝
- 대상: 사용자 조회 API
- 적용: Redis 캐싱
- 결과: 50ms → 5ms (90% 개선)

## 해결한 문제

### Kafka 컨슈머 랙
상세: [[Troubleshooting/kafka/consumer-lag-2026-01-10]]

## 배운 것

### Kafka 타임아웃 설정
```yaml
spring:
  kafka:
    consumer:
      max-poll-interval-ms: 600000  # 10분
```

## 회의 기록

### 정기 회의 (14:00-15:00)
- 참석: 백엔드 팀
- 안건: 다음 주 스프린트 계획
- 결정: Kafka 마이그레이션 PoC 진행

## 내일 할 일
- [ ] Kafka PoC 환경 구축
- [ ] Redis 캐싱 가이드 작성
- [ ] 코드 리뷰 3건

## 관련 링크
- [[2026-01-09]]: 어제
- [[2026-01-11]]: 내일
- [[2026-01-05]]: 이번 주 시작
```

---

## 모범 사례

### 1. 매일 일정 시간에 작성

```mermaid
graph LR
    A[아침 9:00] --> B[계획 수립]
    B --> C[업무 진행]
    C --> D[저녁 6:00]
    D --> E[회고 작성]

    style A fill:#FFE4B5
    style E fill:#90EE90
```

### 2. 체크리스트 활용

```markdown
## 오늘의 계획
- [ ] 긴급: {{urgent_task}}
- [ ] 중요: {{important_task}}
- [ ] 일반: {{normal_task}}
```

### 3. 링크 적극 활용

```markdown
## 완료한 작업
- [x] Redis 캐싱 구현
  - 상세: [[Projects/redis-caching]]
  - 관련 PR: [[GitHub/PR-123]]

## 해결한 문제
- 상세: [[Troubleshooting/redis/timeout]]
```

### 4. 태그 활용

```markdown
---
tags: [daily, frontend, meeting]
---

# 개발 작업은 #dev
# 회의는 #meeting
# 학습은 #learning
```

---

## 일일 노트 검색 팁

### Dataview 쿼리

```dataview
# 이번 주 완료한 작업
TABLE tasks
FROM #daily
WHERE file.ctime >= date(2026-01-06)
AND file.ctime <= date(2026-01-10)
```

```dataview
# 해결한 문제
LIST
FROM #daily
WHERE contains(file.content, "## 해결한 문제")
SORT file.ctime DESC
```

---

## 실습 과제

- [ ] Daily Notes 플러그인 설치 및 설정
- [ ] 자신만의 일일 노트 템플릿 작성
- [ ] Templater로 날짜 자동 입력 설정
- [ ] Claude에게 아침 계획 수립 요청
- [ ] Claude에게 저녁 회고 작성 요청
- [ ] 7일 연속 일일 노트 작성 도전

---

## 참고 자료

- [Obsidian Daily Notes 문서](https://help.obsidian.md/Extending+Obsidian/Daily+notes)
- [Templater 문서](https://github.com/SilentVoid13/Templater)

---

## 다음 단계

일일 노트를 작성했으면, 이제 트러블슈팅을 기록해봅시다.

→ [[13-template-troubleshooting|트러블슈팅 템플릿]]
