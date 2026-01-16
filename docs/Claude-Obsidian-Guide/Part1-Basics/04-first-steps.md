---
title: "첫 노트 작성하기"
tags: [guide, claude-obsidian, 백엔드, practical]
part: "Part 1: 기초 다지기"
created: 2026-01-10
parent: 백엔드 개발자를 위한 Claude Code + Obsidian 지식 관리법
nav_order: 4
---

# 첫 노트 작성하기

Claude Code와 Obsidian을 연동하여 첫 번째 노트를 작성하고 기본 워크플로우를 익혀봅니다.

## 개요

이 가이드에서는 Claude Code를 사용하여 Obsidian에 노트를 생성, 읽기, 검색하는 실전 연습을 진행합니다.

## 학습 목표

- [ ] Claude로 노트 생성하기
- [ ] Claude로 노트 내용 읽고 요약하기
- [ ] Claude로 노트 검색하기
- [ ] 백링크 연결하기

---

## 실습 시나리오

백엔드 개발자로서 다음 상황을 가정합니다:

> **상황**: Redis 캐시 설정을 변경했는데, 예상치 못한 성능 저하가 발생했습니다. 원인을 파악하고 해결 과정을 문서화해야 합니다.

---

## Step 1: Claude로 첫 노트 생성

### 1.1 Claude Code 실행

```bash
claude
```

### 1.2 노트 생성 요청

Claude에게 다음과 같이 요청합니다:

```markdown
"Troubleshooting 폴더에 'Redis 성능 저하 분석'이라는 제목의
트러블슈팅 노트를 만들어줘.

문제 상황:
- Redis maxmemory 설정을 4GB로 변경
- 이후 쿼리 응답 시간이 평균 50ms에서 200ms로 증가
- CPU 사용량은 정상 수준

해결책:
- eviction-policy를 allkeys-lru로 변경
- maxmemory-samples를 기본값 5에서 10으로 증가
- 응답 시간이 30ms로 개선됨

재발 방지:
- 설정 변경 시 사전에 성능 테스트 실행
- 모니터링 대시보드에 Redis 메트릭 추가"
```

### 1.3 Claude의 결과

Claude가 자동으로 다음 형식의 노트를 생성합니다:

```markdown
---
title: "Redis 성능 저하 분석"
tags: [troubleshooting, redis, performance]
created: 2026-01-10
status: resolved
---

# Redis 성능 저하 분석

## 문제 상황

### 발생 일시
2026-01-10 14:30

### 환경
- Production
- Redis 7.0
- maxmemory: 4GB (변경 직전: 2GB)

### 증상
- 쿼리 응답 시간: 50ms → 200ms (4배 증가)
- CPU 사용량: 정상 (30-40%)
- 메모리 사용량: 정상

## 원인 분석

### 근본 원인
1. **maxmemory 증가로 인한 캐스팅 비용 증가**
   - 메모리가 늘어나면서 LRU 알고리즘 계산 비용 증가
   - eviction-policy가 noeviction으로 설정되어 메모리 관리 부재

2. **샘플링 효율 저하**
   - maxmemory-samples=5는 큰 메모리에서 비효율적

## 해결 방법

### 적용한 변경사항

**redis.conf**
```conf
# 변경 전
maxmemory 4gb
maxmemory-policy noeviction
maxmemory-samples 5

# 변경 후
maxmemory 4gb
maxmemory-policy allkeys-lru
maxmemory-samples 10
```

### 결과
- 응답 시간: 200ms → 30ms
- eviction rate: 0 → 150/sec (정상 작동)

## 재발 방지

### 설정 변경 프로세스
1. 스테이징 환경에서 사전 테스트
2. Redis Benchmark로 성능 측정
3. 모니터링 알림 설정

### 모니터링 추가
```yaml
# Prometheus + Grafana 대시보드
- Redis 연결 수
- 응답 시간 (p50, p95, p99)
- Eviction rate
- Memory 사용률
```

## 참고 자료
- [Redis LRU Analysis](https://redis.io/docs/manual/eviction/)
- [[Redis 성능 튜닝 가이드]] (작성 예정)

## 관련 문서
- [[2026-01-08]]: 설정 변경 결정 회의
- [[Monitoring/Metrics-Guide]]: 모니터링 가이드
```

---

## Step 2: 노트 검색 및 읽기

### 2.1 키워드 검색

```markdown
"Redis 관련된 모든 노트를 찾아줘"
```

Claude가 다음과 같이 응답:

```
찾은 노트 (3개):

1. Projects/study/redis-basics.md
   - Redis 기본 개념 정리

2. Troubleshooting/redis-performance.md
   - Redis 성능 저하 분석 (방금 생성)

3. Resources/redis-config.md
   - Redis 설정 모음
```

### 2.2 내용 읽기

```markdown
"방금 만든 트러블슈팅 노트를 읽어서 요약해줘"
```

Claude가 요약:

```
Redis 성능 저하 문제 해결 요약:

문제: maxmemory를 2GB→4GB로 늘린 후 응답 시간 4배 증가
원인: LRU 알고리즘 비용 증가 + 부적절한 eviction policy
해결: allkeys-lru 정책 적용 + sampling 증가
결과: 응답 시간 200ms→30ms로 개선
```

---

## Step 3: 백링크 연결

### 3.1 관련 노트 찾기

```markdown
"이 트러블슈팅과 관련된 기존 노트들을 찾아서
백링크를 연결해줘"
```

### 3.2 Claude의 자동 연결

Claude가 자동으로 관련 노트를 찾아 연결:

```markdown
...
## 관련 문서
- [[Redis 성능 튜닝 가이드]]: Redis 튜닝 방법론
- [[2025-01-08 Daily Note]]: 설정 변경 회의 기록
- [[Monitoring/Redis-Dashboard]]: 모니터링 대시보드 설정

## 역링크
이 노트를 참조하는 문서:
- (없음)
```

---

## Step 4: 노트 업데이트

### 4.1 새로운 정보 추가

```markdown
"트러블슈팅 노트에 '추가 발견사항' 섹션을 추가해줘.
내용은 다음과 같아:

- Redis 느린 쿼리 로그를 분석해보니
  KEYS 명령이 평균 100ms 소요되는 것을 확인
- 애플리케이션 코드에서 KEYS 사용을
  SCAN으로 변경 필요"
```

### 4.2 Claude가 자동 업데이트

```markdown
...
## 추가 발견사항 (2026-01-10 16:00)

### Slow Query 분석 결과
```redis
# Redis Slow Log
redis-cli SLOWLOG GET 10

1) 1) (integer) 12345
   2) (integer) 1704887600
   3) (integer) 120000
   4) "KEYS" "user:*"
```

### 원인
- KEYS 명령은 O(N) 복잡도로 대용량에서 느림
- 매분 100회 호출되고 있었음

### 추가 해결책
```java
// 변경 전
Set<String> keys = redisTemplate.keys("user:*");

// 변경 후
ScanOptions options = ScanOptions.scanOptions()
    .match("user:*")
    .count(100)
    .build();
Cursor<String> cursor = redisTemplate.scan(options);
```

### 예상 효과
- KEYS 제거로 응답 시간 추가 20ms 개선 예상
- 전체: 50ms → 10ms 목표
```

---

## Step 5: 일일 노트와 연결

### 5.1 오늘의 Daily Note 확인

```markdown
"오늘(2026-01-10) 일일 노트를 보여줘"
```

### 5.2 트러블슈팅 링크 추가

```markdown
"오늘 일일 노트의 '완료한 작업'에
이 트러블슈팅 해결 내용을 추가해줘"
```

```markdown
## 완료한 작업

- [x] Redis 성능 저하 문제 해결
  - [[Troubleshooting/redis-performance]] 상세 보고서
  - 응답 시간 50ms → 30ms 개선
  - KEYS → SCAN 변경 (예정)
```

---

## 전체 워크플로우

```mermaid
flowchart LR
    A[문제 발생] --> B[Claude에게 설명]
    B --> C[노트 자동 생성]
    C --> D[관련 노트 검색]
    D --> E[백링크 연결]
    E --> F[추가 정보 업데이트]
    F --> G[일일 노트와 연결]
    G --> H[완료]

    style C fill:#90EE90
    style H fill:#e1f5ff
```

---

## 실습 팁

### 1. 구체적인 프롬프트 사용

❌ **나쁜 예**
```markdown
"노트 만들어줘"
```

✅ **좋은 예**
```markdown
"Troubleshooting 폴더에 'Redis 성능 저하' 제목으로
트러블슈팅 노트를 만들어줘.

문제: maxmemory 변경 후 응답 시간 4배 증가
해결: eviction-policy 변경
..."
```

### 2. 단계적 작성

```mermaid
graph LR
    A[기본 노트 생성] --> B[상세 내용 추가]
    B --> C[관련 문서 연결]
    C --> D[일일 노트 연결]
```

### 3. 정기적인 업데이트

```markdown
# 시간 경과에 따른 노트 업데이트

## 최초 작성 (14:30)
문제 발생 및 증상 기록

## 1차 업데이트 (15:00)
원인 분석 및 임시 조치

## 2차 업데이트 (16:00)
추가 발견사항 (KEYS 문제)

## 최종 업데이트 (17:30)
모든 해결책 적용 완료
```

---

## 실습 과제

- [ ] 본인이 최근에 겪은 기술적 문제를 하나 선택
- [ ] Claude로 트러블슈팅 노트 생성
- [ ] 관련 노트 찾아서 백링크 연결
- [ ] 일일 노트와 연결
- [ ] 검색으로 다시 찾아보기

---

## 다음 단계

첫 노트를 작성했습니다! 이제 본격적인 Vault를 설계해봅시다.

→ [[05-vault-design|백엔드 개발자를 위한 Vault 설계]]로 계속하세요

---

## 참고 자료

- [Obsidian 공식 튜토리얼](https://help.obsidian.md/Editing+and+formatting/Markdown+basics)
- [Claude Code 사용법](https://docs.anthropic.com/claude-code)
