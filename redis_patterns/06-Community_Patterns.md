---
title: "Community Patterns"
layout: page
toc: true
mermaid: true
---

# Community Patterns

Redis 커뮤니티에서 개발한 일반적인 사용 사례 패턴입니다.

---

## Bitmap Patterns

> 수백만 개의 불린 플래그를 최소 메모리로 저장

### 개념

Redis Bitmap은 1비트로 각 불린 값을 저장합니다. 1개 플래그당 1비트로 O(1) 액세스와 전체 데이터셋에 대한 빠른 집계 연산을 제공합니다.

### 기본 명령어

```redis
# 비트 설정
SETBIT user:activity:2024-01-30 123 1

# 비트 조회
GETBIT user:activity:2024-01-30 123

# 설정된 비트 수
BITCOUNT user:activity:2024-01-30

# 비트 연산
BITOP AND result key1 key2
BITOP OR result key1 key2
BITOP XOR result key1 key2
```

### 일일 활성 사용자 (DAU) 추적

```redis
# 사용자 ID 12345가 2024-01-30에 로그인
SETBIT dau:2024-01-30 12345 1

# DAU 수
BITCOUNT dau:2024-01-30

# 주간 활성 사용자 (7일 OR 연산)
BITOP OR wau:2024-week1 dau:2024-01-24 dau:2024-01-25 ... dau:2024-01-30
BITCOUNT wau:2024-week1
```

### 기능 플래그

```redis
# 사용자별 기능 활성화
SETBIT feature:beta_access 12345 1

# 기능 활성화 확인
GETBIT feature:beta_access 12345
```

### 연속 활동 추적

```redis
# 30일 연속 로그인 체크
BITOP AND streak:check dau:day1 dau:day2 ... dau:day30
GETBIT streak:check 12345  # 1이면 30일 연속
```

### 장점

- **메모리 효율**: 1억 사용자 = 약 12.5MB
- **빠른 집계**: BITCOUNT, BITOP가 O(N)이지만 매우 최적화됨
- **단순성**: 직관적인 사용법

### 주의사항

- 사용자 ID가 연속적이지 않으면 메모리 낭비
- Sparse bitmap은 메모리 비효율적일 수 있음

---

## Geospatial Patterns

> 위치 기반 쿼리

### 개념

Redis는 GEOADD, GEOSEARCH, GEODIST 명령어를 사용하여 위치 저장 및 반경/거리/경계 상자 쿼리를 지원합니다. 내부적으로 geohash 인코딩된 Sorted Set을 사용합니다.

### 기본 명령어

```redis
# 위치 추가
GEOADD locations -122.4194 37.7749 "San Francisco"
GEOADD locations -118.2437 34.0522 "Los Angeles"

# 반경 검색
GEOSEARCH locations FROMMEMBER "San Francisco" BYRADIUS 100 km

# 거리 계산
GEODIST locations "San Francisco" "Los Angeles" km
```

### 주변 가맹점 찾기

```redis
# 가맹점 위치 저장
GEOADD stores -127.0 37.0 "store:1"
GEOADD stores -127.1 37.1 "store:2"

# 사용자 위치(127.05, 37.05)에서 5km 내 가맹점
GEOSEARCH stores FROMLONLAT -127.05 37.05 BYRADIUS 5 km WITHDIST
```

### 배차 시스템

```redis
# 드라이버 위치 업데이트
GEOADD drivers:active -127.0 37.0 "driver:123"

# 승객 위치에서 3km 내 드라이버 검색
GEOSEARCH drivers:active FROMLONLAT -127.05 37.05 BYRADIUS 3 km ASC COUNT 5
```

### 경로 추적

```redis
# 위치 기록은 Sorted Set과 Geo 조합
# 현재 위치 (Geo)
GEOADD drivers:active -127.0 37.0 "driver:123"

# 위치 히스토리 (Sorted Set: score = timestamp)
ZADD tracking:driver:123 1706648400 "-127.0,37.0"
ZADD tracking:driver:123 1706648460 "-127.01,37.01"

# 시간 범위로 위치 조회
ZRANGE tracking:driver:123 1706648400 1706648500 BYSCORE
```

---

## Leaderboard Patterns

> 실시간 랭킹 시스템

### 개념

Sorted Set을 사용하여 O(log N) 점수 업데이트, O(log N) 순위 조회, 효율적인 범위 쿼리를 제공합니다.

### 기본 명령어

```redis
# 점수 추가/업데이트
ZADD leaderboard 100 "player:123"

# 순위 조회 (0부터 시작, 낮은 순위가 높은 점수)
ZREVRANK leaderboard "player:123"

# 점수와 함께 순위 조회
ZREVRANK leaderboard "player:123" WITHSCORE

# Top N 조회
ZREVRANGE leaderboard 0 9 WITHSCORES

# 점수 증가
ZINCRBY leaderboard 10 "player:123"
```

### 게임 리더보드

```redis
# 점수 업데이트
ZINCRBY game:scores 50 "player:456"

# 전체 순위
ZREVRANK game:scores "player:456" WITHSCORE

# 주간 리더보드
ZADD leaderboard:week:2024-05 1000 "player:123"
```

### 사용자 주변 순위

```redis
# 123등 사용자 주변 ±5명
ZREVRANGE leaderboard 118 128 WITHSCORES
```

### 페이지네이션

```redis
# 1페이지 (Top 10)
ZREVRANGE leaderboard 0 9 WITHSCORES

# 2페이지 (11-20등)
ZREVRANGE leaderboard 10 19 WITHSCORES
```

### 다중 리더보드 병합

```redis
# 일일 리더보드를 주간으로 병합
ZUNIONSTORE leaderboard:week:2024-05 7 \
    leaderboard:day:2024-01-29 leaderboard:day:2024-01-30 ...
```

---

## Pub/Sub Patterns

> 실시간 이벤트 브로드캐스트

### 개념

Fire-and-forget 메시징으로 여러 구독자에게 실시간 이벤트를 브로드캐스트합니다. 메시지 유실이 허용되는 경우에 적합합니다.

### 기본 명령어

```redis
# 채널 구독
SUBSCRIBE channel1 channel2

# 패턴 구독
PSUBSCRIBE news:*

# 메시지 발행
PUBLISH channel1 "Hello World"

# 구독 취소
UNSUBSCRIBE channel1
```

### 채팅 시스템

```redis
# 채팅방 구독
SUBSCRIBE chat:room:123

# 메시지 발행
PUBLISH chat:room:123 '{"user":"alice","message":"Hello!"}'
```

### 알림 시스템

```redis
# 사용자별 알림 채널
SUBSCRIBE notifications:user:123

# 알림 발행
PUBLISH notifications:user:123 '{"type":"new_message","data":...}'
```

### 이벤트 브로드캐스트

```redis
# 시스템 이벤트
PUBLISH system:events '{"type":"config_changed","key":"rate_limit"}'

# 캐시 무효화
PUBLISH cache:invalidate "user:123"
```

### 주의사항

- **메시지 유실**: 구독자가 연결되지 않으면 메시지 손실
- **지속성 없음**: 메시지가 저장되지 않음
- **신뢰성 필요 시**: Streams 사용

---

## Session Management Patterns

> 세션 저장소

### 개념

Redis에 TTL과 함께 사용자 세션을 저장합니다. 접근 패턴에 따라 Hashes, Strings, JSON 중 선택합니다.

### Hash를 이용한 세션

```redis
# 세션 생성
HSET session:abc123 user_id 123 created_at 1706648400 last_access 1706648400
EXPIRE session:abc123 1800  # 30분

# 세션 필드 액세스
HGET session:abc123 user_id

# 마지막 접근 업데이트
HSET session:abc123 last_access 1706648460
```

### String (직렬화) 세션

```redis
# JSON 세션 저장
SET session:abc123 '{"user_id":123,"created_at":1706648400}'
EXPIRE session:abc123 1800

# 세션 조회
GET session:abc123
```

### 세션 스토어 선택 가이드

| 방식 | 장점 | 단점 |
|------|------|------|
| Hash | 필드별 액세스, 부분 업데이트 | 중첩 데이터 불가 |
| String | 간단, 중첩 데이터 가능 | 전체 읽기/쓰기 |
| JSON | 중첩 데이터, 쿼리 가능 | Redis Stack 필요 |

### 세션 인덱스

```redis
# 사용자 ID → 세션 ID 매핑
SET user:123:session session:abc123

# 세션 무효화 시 함께 삭제
DEL session:abc123
DEL user:123:session
```

---

## Vector Search and AI Patterns

> AI/ML 인프라를 위한 벡터 검색

### 개념

Redis Vector Sets를 사용하여 시맨틱 검색, RAG 파이프라인, 추천 시스템, AI 에이전트 인프라를 구축합니다.

### RAG (Retrieval-Augmented Generation)

```redis
# 문서 벡터 저장
VADD documents <embedding_vector> VALUES ... METADATA {"title":"Redis Guide"}

# 쿼리 벡터로 유사 문서 검색
VSEARCH documents <query_embedding> K 5
```

### 추천 시스템

```redis
# 상품 벡터 저장
VADD products <product_embedding> VALUES ... METADATA {"category":"electronics"}

# 사용자 선호 벡터로 추천
VSEARCH products <user_preference_vector> K 10 FILTER "category == 'electronics'"
```

### AI 에이전트 메모리

```redis
# 대화 컨텍스트 벡터 저장
VADD conversations <context_embedding> VALUES ... METADATA {"session_id":"abc123"}

# 관련 컨텍스트 검색
VSEARCH conversations <query_embedding> K 3
```

### 성능 특성

- **HNSW 기반**: 서브 밀리초 지연 시간
- **필터링 지원**: 메타데이터 기반 필터링
- **확장성**: 수백만 벡터 처리
