---
title: "explain-diff: PR을 한 장의 설명서로 만들기 (Redis 캐시 제거 사례)"
layout: post
date: 2026-07-23 22:00:00 +0900
categories:
  - AI
tags:
  - ai-agent
  - explain-diff
  - code-review
  - spring-boot
  - redis
---

에이전트가 코드를 대신 짜주는 시대에, 리뷰어는 무엇을 하면 될까.
코드를 줄 단위로 읽고 **"검증"** 하는 일은 점점 의미가 희미해진다. 대신 변경의
**의도와 구조를 빠르게 이해**하고 거기에 **참여** 하는 쪽이 리뷰어의 새 역할이다.

> Geoffrey Litt가 말했듯, 에이전트 시대의 진짜 병목은 코드 생성 속도가 아니라
> **인간의 이해 속도**다. ([Understanding is the new bottleneck](https://www.geoffreylitt.com/2026/07/02/understanding-is-the-new-bottleneck))

이번 글에서는 그 철학을 스킬로 구현한 **explain-diff** 로 실제 PR을 한 장의 대화형
설명서로 만든 사례를 공유한다.

## explain-diff가 하는 일

diff를 줄 단위로 나열하는 대신, 최고의 선생님이 짜주는 커리큘럼처럼 **4단계 구조**로
재구성한다.

1. **Background** — 변경이 속한 기존 시스템을 설명 (아키텍처, 도메인 모델, API 계약)
2. **Intuition** — 변경의 핵심 직관. 장난감 예시와 다이어그램으로 essence를 전달
3. **Code** — 변경을 개념적 그룹으로 묶어 안내 (알파벳순이 아니라 **이해 순서**로)
4. **Quiz** — 5문항 대화형 객관식. 퀴즈를 통과하기 전까지 머지하지 않는 **속도 조절기**

결과물은 CSS·JS까지 담은 **self-contained HTML 한 장**이다.

## 사례: Redis 캐시 의존성 제거 PR

헥사고날(포트-어댑터) 아키텍처 기반 Spring Boot 멀티모듈 서비스에서, 관리형 Redis에 대한
모든 의존성을 제거한 PR을 설명서로 만들어봤다.

- 규모: 19개 파일, `+2 / -129`
- 핵심 질문: *"Redis를 빼되 로컬 캐시(Caffeine)는 어떻게 살렸나?"*

흥미로웠던 점은, 이 서비스가 원래 **CacheManager를 두 개** 가지고 있었다는 것이다.
`@Primary` 인 CaffeineCacheManager(로컬)와 redisCacheManager(분산). 그래서
`@Cacheable`이 어디로 가는지는 단지 *"cacheManager를 명시했는가?"* 하나로 갈렸다.
설명서는 이 구조를 Background에서 풀고, Intuition에서 "Redis는 빼되 로컬 캐시는 산다"는
한 줄로 압축한다.

## 설명서 (임베디드)

아래는 실제 생성된 설명서다. 4단계로 구성되어 있고, 끝의 **Quiz는 클릭하면 정답과 해설이 바로 나온다.**

<iframe src="/assets/files/explain-diff-redis-removal.html" width="100%" height="1300" style="border:1px solid #ddd;border-radius:10px;" loading="lazy"></iframe>

*(새 창으로 보기: [설명서 HTML](/assets/files/explain-diff-redis-removal.html))*

## 왜 효과적이었나

- **리뷰어의 진입 장벽 ↓** — diff 19개 파일을 뒤지지 않아도, 한 페이지에서 변경의
  맥락·핵심·그룹을 따라갈 수 있다.
- **의도가 코드 밖으로 나온다** — "왜 Redis를 제거했는가"가 Background·Intuition에
  명시적으로 적히므로, 리뷰어는 *검증*이 아니라 *참여* 에 집중할 수 있다.
- **Quiz가 게이트 역할** — "퀴즈를 못 풀면 머지하지 말자"는 규칙 하나로, 이해 없는
  머지를 구조적으로 막는다 (cognitive debt 예방).
- **재사용 가능** — 동일한 4단계 템플릿으로 어떤 PR이든 설명서를 찍어낼 수 있다.

## 한 줄 요약

에이전트가 짠 코드를 리뷰할 때, **이해를 가속하는 설명서 한 장**이 있으면 리뷰 루프가
훨씬 건강해진다. diff를 읽는 대신, diff를 *가르쳐주는* 문서를 만들어 보자.
