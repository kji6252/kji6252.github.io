---
title: "Redis 동시성 이슈 사례"
tags: [guide, claude-obsidian, 백엔드, case-study]
part: "Part 8: 실전 사례"
created: 2026-01-10
parent: 백엔드 개발자를 위한 Claude Code + Obsidian 지식 관리법
nav_order: 1
---

# Redis 동시성 이슈 사례

실제 프로젝트에서 발생한 Spring Data Redis 동시성 문제를 해결한 과정을 보여줍니다.

## 문제 상황

### 발생

```
환경: Production
날짜: 2026-01-05
증상: 사용자 수 카운트가 비정상적으로 감소
```

### 에러 로그

```
redis.clients.jedis.RedisDataException:
ERR value is not an integer or out of range
```

## 원인 분석

### 문제 코드

```kotlin
val redis = userCountRedisRepository.findByIdOrNull(key) ?: return
val changeUserCount = redis.changeUserCount(countType, change)
userCountRedisRepository.save(redis)  // 문제!
```

### 문제점

1. **Partial Update 없음**
   - JPA와 달리 전체 필드가 업데이트됨
   - 동시 요청 시 경합 발생

2. **경합 조건**
   - Thread A: 읽기 (count: 10)
   - Thread B: 읽기 (count: 10)
   - Thread A: -1 → 쓰기 (count: 9)
   - Thread B: -1 → 쓰기 (count: 9)
   - 결과: 2 감소해야 하는데 1만 감소

## 해결 방법

### RedisTemplate 직접 사용

```kotlin
val increment = stringRedisTemplate.opsForHash<String, String>()
    .increment(key, "userCounts.[CHAT].details.[0].remain", change)

if (increment < 0) {
    throw CommonRuntimeException(FailApiCodes.COUNT_LIMIT)
}
```

### 결과

- 경합 문제 해결
- 성능: 50ms → 5ms
- 정확도: 100%

## 문서화

이 이슈는 다음에 정리되었습니다:

```markdown
---
title: "Spring Data Redis 동시성 이슈"
tags: [troubleshooting, redis, concurrency]
status: resolved
---
```

---

## 다음 사례

→ [[26-case-kafka|Kafka 도입 검토]]
