---
title: "Data Structure Patterns"
layout: page
toc: true
---

# Data Structure Patterns

Redis의 데이터 구조를 효율적으로 활용하는 패턴들입니다.

---

## Memory Optimization Patterns

> 메모리 사용량 최적화 패턴

### 컴팩트 인코딩 활용

Redis는 데이터 크기에 따라 자동으로 내부 인코딩을 선택합니다.

#### ListPack (Small Lists, Hashes, Sorted Sets)

작은 컬렉션은 연속된 메모리 블록에 저장됩니다.

```redis
# 작은 Hash는 listpack 사용 (메모리 효율적)
HSET small_hash field1 "value1" field2 "value2"
```

#### IntSet (Small Sets of Integers)

정수만 포함한 작은 Set은 정렬된 배열로 저장됩니다.

```redis
# 정수 Set은 자동으로 intset 사용
SADD int_set 1 2 3 4 5
```

### Hash를 이용한 작은 객체 저장

여러 키 대신 단일 Hash 사용:

```redis
# 비효율적: 여러 String 키
SET user:123:name "Alice"
SET user:123:email "alice@example.com"
SET user:123:age "30"

# 효율적: 단일 Hash
HSET user:123 name "Alice" email "alice@example.com" age "30"
```

**메모리 절약 이유**:
- 키당 오버헤드 제거
- 작은 Hash는 listpack 인코딩 사용

### 인코딩 임계값 조정

```redis
# 설정 파일 (redis.conf)
hash-max-listpack-entries 512
hash-max-listpack-value 64
zset-max-listpack-entries 128
zset-max-listpack-value 64
set-max-intset-entries 512
```

### 키 네이밍 최적화

```redis
# 긴 키 이름 피하기
SET very_long_descriptive_key_name "value"  # 비효율적

# 짧고 의미 있는 키
SET u:123:n "value"  # 효율적
```

### 데이터 구조 선택 가이드

| 용도 | 추천 구조 | 이유 |
|------|----------|------|
| 단일 값 | String | 가장 단순 |
| 여러 필드 | Hash | 메모리 효율적 |
| 정수 집합 | Set (intset) | 자동 최적화 |
| 순서 있는 데이터 | Sorted Set | 인덱싱 가능 |
| 메시지 큐 | List / Stream | 사용 사례에 따라 |

### 버켓팅 패턴 (Bucketing Pattern)

수백만 개의 작은 값을 저장할 때 개별 키의 오버헤드가 지배적입니다. 대신 Hash 버킷에 그룹화합니다.

```redis
# 비효율적: 100만 개의 개별 키
SET user:1:name "John"
SET user:2:name "Jane"
... (100만 키)

# 효율적: 1000개의 Hash 버킷
HSET users:0 "1:name" "John" "2:name" "Jane"
HSET users:1 "1001:name" "Alice"
```

**버킷 계산** (ID 12345, 버킷 크기 1000):
```
bucket_number = item_id / 1000 = 12
key = "users:12"
field = "12345:name"
```

**효과**: 100만 개 키 대신 1000개 키로 5-10배 메모리 절감

### 만료 오버헤드

TTL이 있는 각 키는 만료 시간 저장을 위한 추가 메모리가 필요합니다. 비슷한 시간에 만료되어야 하는 많은 키가 있다면, 개별 TTL 대신 Hash로 그룹화하고 단일 TTL을 Hash 키에 설정하세요.

### 메모리 사용량 분석

```redis
# 전체 메모리 확인
INFO memory

# 특정 키 메모리 확인
MEMORY USAGE user:12345

# 메모리 통계 샘플
MEMORY STATS

# 큰 키 찾기 (프로덕션에서 주의)
MEMORY DOCTOR
```

### 퇴출 정책 (Eviction Policies)

메모리가 가득 찼을 때 Redis가 자동으로 키를 퇴출할 수 있습니다.

```redis
# 설정
maxmemory 1gb
maxmemory-policy allkeys-lru
```

**정책 종류:**

| 정책             | 설명                 | 사용 사례     |
| -------------- | ------------------ | --------- |
| `noeviction`   | 쓰기 시 오류 반환         | 데이터 손실 방지 |
| `allkeys-lru`  | 가장 오래 사용되지 않은 키 퇴출 | 캐시        |
| `allkeys-lfu`  | 가장 적게 사용된 키 퇴출     | 캐시        |
| `volatile-lru` | TTL이 있는 키 중 LRU    | 혼합 워크로드   |
| `volatile-ttl` | 가장 짧은 TTL 키 퇴출     | 시간 기반 데이터 |

### 압축 (Compression)

큰 문자열 값의 경우 저장 전 압축을 고려하세요:
1. 애플리케이션에서 압축 (gzip, lz4, snappy)
2. 압축된 바이트 저장
3. 읽을 때 압축 해제

**트레이드오프**: CPU ↔ 메모리. 수백 바이트 이상 값에서 효과적.

### 최적화 기법 요약

| 기법 | 효과 | 노력 |
|------|------|------|
| 버켓팅 | 5-10배 절감 | 중간 |
| 짧은 키 이름 | 10-30% 절감 | 낮음 |
| 정수 인코딩 | 가변적 | 낮음 |
| 만료 그룹화 | 10-20% 절감 | 중간 |
| 압축 | 50-90% 절감 | 높음 |

---

## Probabilistic Data Structures

> 확률적 데이터 구조

대규모 데이터셋에서 메모리를 극적으로 절약하면서 근사치를 제공하는 구조들입니다.

### HyperLogLog: 유니크 아이템 카운팅

10억 개의 유니크 사용자 ID를 저장하려면 약 12GB가 필요하지만, HyperLogLog는 단 12KB로 약 0.81% 표준 오차로 추정합니다.

#### 명령어

```redis
# 요소 추가
PFADD visitors:2024-01-30 "user:123" "user:456" "user:789"

# 추정 카운트 조회
PFCOUNT visitors:2024-01-30

# 여러 HLL 병합
PFMERGE visitors:week visitors:2024-01-28 visitors:2024-01-29 visitors:2024-01-30
```

#### 사용 사례

- 웹사이트 고유 방문자 수
- 고유 검색 쿼리 추적
- 고유 IP 주소 카운팅

#### 정확도

100만 개 실제 유니크 아이템에 대해 991,900 ~ 1,008,100 범위의 추정치 제공.

### Bloom Filter: 멤버십 테스트

"이 아이템이 집합에 있는가?"를 거짓 양성 가능성과 함께 답합니다. "아니오"라고 하면 확실히 없고, "예"라고 하면 아마 있을 것입니다.

#### 명령어 (Redis Stack)

```redis
# 필터 생성 (1% 오류율, 100만 아이템)
BF.RESERVE usernames 0.01 1000000

# 아이템 추가
BF.ADD usernames "john_doe"

# 멤버십 확인
BF.EXISTS usernames "john_doe"
```

#### 사용 사례

- 사용자명/이메일 가용성 사전 체크
- 스팸 필터링
- 캐시 미스 최적화
- 중복 처리 방지

#### 캐시 관통 문제 해결

공격자가 존재하지 않는 키로 요청을 폭주시키면, 각 요청이 캐시를 미스하고 데이터베이스를 타격합니다. Bloom Filter로 즉시 거부할 수 있습니다.

### Cuckoo Filter

Bloom Filter와 유사하지만 삭제를 지원합니다.

```redis
# Redis Stack
CF.RESERVE sessions 1000000
CF.ADD sessions "session:abc123"
CF.EXISTS sessions "session:abc123"
CF.DEL sessions "session:abc123"
```

#### Bloom vs Cuckoo 비교

| 기능 | Bloom Filter | Cuckoo Filter |
|------|--------------|---------------|
| 삭제 | 미지원 | 지원 |
| 공간 효율 | 좋음 | 낮은 FP율에서 더 좋음 |
| 삽입 성능 | 빠름 | 약간 느림 |
| 조회 성능 | 약간 느림 | 빠름 |

### T-Digest: 백분위수 추정

정확한 백분위수 계산은 모든 데이터를 정렬해야 하므로 스트리밍 데이터에 부적합합니다. T-Digest는 압축된 표현으로 정확한 추정치를 제공합니다.

```redis
# Redis Stack
TDIGEST.CREATE latencies
TDIGEST.ADD latencies 45.2 89.1 12.5 156.7 23.4
TDIGEST.QUANTILE latencies 0.5 0.95 0.99
```

#### 사용 사례

- SLA 모니터링 (p99 지연 시간)
- 성능 분석
- 스트리밍 데이터 백분위수

### Count-Min Sketch: 빈도 추정

각 아이템이 몇 번 관찰되었는지 추정합니다. 초과 카운팅 가능하지만 미만 카운팅은 없습니다.

```redis
CMS.INITBYDIM page_views 2000 5
CMS.INCRBY page_views "/home" 1 "/about" 1
CMS.QUERY page_views "/home"
```

### Top-K: 헤비 히터

스트림에서 가장 빈번한 K개 아이템을 추적합니다.

```redis
# Redis Stack
TOPK.RESERVE trending 10 50 3 0.9
TOPK.ADD trending "topic:redis" "topic:python" "topic:redis" "topic:go"
TOPK.LIST trending
```

### 구조 선택 가이드

| 필요 | 구조 | 오류 유형 |
|------|------|----------|
| 유니크 아이템 수 | HyperLogLog | 카디널리티 ±0.81% |
| 집합 멤버십 확인 | Bloom/Cuckoo Filter | 거짓 양성 가능 |
| 백분위수 계산 | T-Digest | 백분위수 추정 |
| 아이템 빈도 | Count-Min Sketch | 초과 카운팅 가능 |

---

## Rate Limiting Patterns

> 분산 속도 제한 패턴

### 고정 윈도우 (Fixed Window)

가장 단순한 방식: 시간 윈도우당 카운터 유지

```redis
# 1분 윈도우
INCR rate:user:123:1706648400
EXPIRE rate:user:123:1706648400 60

# 확인
GET rate:user:123:1706648400
```

**문제**: 윈도우 경계에서 트래픽 스파이크 가능 (두 윈도우에 걸쳐 2배 허용)

### 슬라이딩 윈도우 로그 (Sliding Window Log)

각 요청의 타임스탬프를 저장:

```redis
# 요청 추가
ZADD rate:user:123 1706648460 "1706648460:abc"

# 오래된 요청 제거 (1분 윈도우)
ZREMRANGEBYSCORE rate:user:123 -inf (1706648460-60)

# 현재 카운트
ZCARD rate:user:123
```

**장점**: 정확한 속도 제한
**단점**: 메모리 사용량이 요청 수에 비례

### 슬라이딩 윈도우 카운터

고정 윈도우와 슬라이딩 윈도우의 하이브리드:

```lua
local current = redis.call('INCR', KEYS[1])
if current == 1 then
    redis.call('EXPIRE', KEYS[1], ARGV[1])
end

local prev = redis.call('GET', KEYS[2])
if prev then
    local weight = (ARGV[1] - (now % ARGV[1])) / ARGV[1]
    current = current + prev * weight
end

return current
```

### 토큰 버킷 (Token Bucket)

버킷에 토큰을 채우고 요청 시 토큰 소모:

```lua
local tokens = redis.call('GET', KEYS[1])
if not tokens then
    tokens = ARGV[1]  -- 초기 토큰
end

local last_refill = redis.call('GET', KEYS[2]) or 0
local now = ARGV[3]
local refill_rate = ARGV[4]

-- 토큰 리필
local elapsed = now - last_refill
tokens = math.min(tokens + elapsed * refill_rate, ARGV[1])

if tokens >= 1 then
    redis.call('SET', KEYS[1], tokens - 1)
    redis.call('SET', KEYS[2], now)
    return 1  -- 허용
else
    return 0  -- 거부
end
```

### 누출 버킷 (Leaky Bucket)

일정한 속도로 요청 처리:

```lua
local now = ARGV[1]
local capacity = ARGV[2]
local rate = ARGV[3]

local last = redis.call('GET', KEYS[1]) or now
local water = redis.call('GET', KEYS[2]) or 0

water = math.max(0, water - (now - last) * rate)
if water < capacity then
    redis.call('SET', KEYS[1], now)
    redis.call('SET', KEYS[2], water + 1)
    return 1  -- 허용
else
    return 0  -- 거부
end
```

### 알고리즘 비교

| 알고리즘 | 복잡성 | 정확성 | 메모리 | 버스트 처리 |
|----------|--------|--------|--------|-------------|
| 고정 윈도우 | 낮음 | 낮음 | O(1) | 경계에서 2배 |
| 슬라이딩 로그 | 중간 | 높음 | O(N) | 없음 |
| 슬라이딩 카운터 | 중간 | 중간 | O(1) | 없음 |
| 토큰 버킷 | 중간 | 높음 | O(1) | 설정 가능 |
| 누출 버킷 | 중간 | 높음 | O(1) | 없음 |

### 응답 헤더 (Response Headers)

클라이언트에게 속도 제한 상태를 전달합니다:

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1706648460
```

거부 시 `Retry-After` 헤더 포함:
```
HTTP/1.1 429 Too Many Requests
Retry-After: 60
```

### 다중 계층 제한 (Multi-Tier Limits)

여러 제한을 동시에 적용합니다:

| 계층 | 제한 | 목적 |
|------|------|------|
| 초당 | 10회 | 버스트 보호 |
| 분당 | 100회 | 지속 속도 |
| 시간당 | 1000회 | 전체 할당량 |

모든 요청에서 모든 제한을 확인하고, 하나라도 초과하면 거부합니다.

### 분산 환경 고려사항

여러 애플리케이션 서버가 실행 중일 때, 모든 서버가 동일한 Redis 인스턴스(또는 클러스터)를 공유해야 전역 제한을 적용할 수 있습니다.

```
⚠️ 로컬 속도 제한은 N개 서버에서 N × 제한 허용
```

### 사용 시기 가이드

| 요구사항 | 추천 알고리즘 |
|----------|--------------|
| 단순 구현 | 고정 윈도우 |
| 정확한 제한 | 슬라이딩 로그 |
| 메모리 효율 + 정확 | 슬라이딩 카운터 |
| 버스트 허용 | 토큰 버킷 |
| 일정한 처리율 | 누출 버킷 |

---

## Lexicographic Sorted Set Patterns

> 문자열 인덱싱을 위한 사전식 Sorted Set 패턴

### 개념

동일한 점수(일반적으로 0)를 가진 Sorted Set을 사용하여 B-tree 같은 인덱스를 생성합니다.

```redis
ZADD index 0 "apple"
ZADD index 0 "banana"
ZADD index 0 "cherry"
ZADD index 0 "application"
```

### 프리픽스 쿼리

"app"으로 시작하는 모든 단어 찾기:

```redis
ZRANGEBYLEX index "[app" "(app~"
```

- `[app`: "app" 포함
- `(app~`: "app~" 미만 (~는 ASCII에서 z 다음)

### 범위 쿼리

```redis
# "a"에서 "c" 사이의 모든 단어
ZRANGEBYLEX index "[a" "(d"
```

### 복합 키 인덱스

```redis
# 사용자:국가:도시 형식
ZADD locations 0 "user:1:korea:seoul"
ZADD locations 0 "user:2:korea:busan"
ZADD locations 0 "user:3:usa:newyork"

# 한국 사용자 모두 찾기
ZRANGEBYLEX locations "[user::korea:" "(user::korea~"
```

### 자동 완성 구현

```redis
# 사용자 입력: "ap"
ZRANGEBYLEX autocomplete "[ap" "(ap~" LIMIT 0 10
```

### 사용 사례

- 자동 완성
- 사전식 정렬 인덱스
- 프리픽스 기반 검색
- 범위 스캔
