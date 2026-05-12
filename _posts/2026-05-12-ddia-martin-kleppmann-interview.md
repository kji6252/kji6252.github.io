---
title: "DDIA 저자 Martin Kleppmann 인터뷰 — 1판 집필 비하인드, 2판 변경점, Local-First와 형식 검증"
layout: post
date: 2026-05-12 15:30:00
categories:
  - Book
tags:
  - DDIA
  - Database
  - DistributedSystems
  - Interview
  - DataEngineering
---

> **TL;DR** — *Designing Data-Intensive Applications*의 저자 Martin Kleppmann이 스타트업 실패·성공, LinkedIn 데이터 인프라 경험, 4년의 집필 과정을 돌아본다. 2판에서는 MapReduce를 과감히 삭제하고 클라우드 네이티브·벡터 인덱스·데이터프레임을 추가했다. 이후 그의 연구는 **Local-First Software**(CRDT, Automerge), **형식 검증**(TLA+, Isabelle), 그리고 **암호학적 공급망 증명**으로 확장된다. 산업 경험이 있어야 학계 연구가 빛나고, 학계의 제일원칙 사고가 산업을 한 단계 끌어올린다는 그의 메시지를 정리했다.

---

## Martin Kleppmann의 커리어

Martin의 커리어는 **실패·인수·대규모 인프라·학계**라는 네 개의 단어로 요약할 수 있다.

### Go Test It (2008) — 첫 스타트업, 첫 실패

2008년, 케임브리지 대학에서 박사 과정을 시작하던 시절. 웹사이트 크로스 브라우저 테스트 도구 **Go Test It**을 창업했다. 기술적으로는 성공적이었지만, 비즈니스 모델을 찾지 못해 2010년 문을 닫았다.

> "좋은 제품이 비즈니스가 되는 건 아니다. 사용자가 있어도 돈을 받는 건 전혀 다른 문제다."

### Rapportive (2011) — Y Combinator, 그리고 LinkedIn 인수

Gmail 안에서 이메일 발신자의 소셜 프로필을 보여주는 **Rapportive**를 창업했다. Y Combinator W11 배치.

여기서 Martin은 백엔드 인프라를 담당했다. **MySQL 성능 문제**와 씨름하면서 데이터베이스 내부 원리에 깊이 파고들었고, 이 경험이 훗날 DDIA 집필의 원동력이 된다.

하지만 순탄치만은 않았다:

- **비자 문제** — 영국에서 미국으로 갈 수 없어 팀이 분산
- **자금 고갈** — 런웨이가 몇 주 남지 않은 상황
- **인수 압박** — 자금이 바닥나기 전에 매물로 나와야 했다

결국 2012년 LinkedIn이 Rapportive를 인수했고, Martin은 LinkedIn 데이터 인프라 팀에 합류한다.

### LinkedIn 데이터 인프라 — Kafka와 Samza의 현장

LinkedIn에서 Martin은 대규모 데이터 파이프라인을 설계했다. 당시 LinkedIn이 직면한 문제는 단순했다:

> "모든 팀이 각자의 데이터 파이프라인을 만들고 있었다. Hadoop 클러스터가 20개, ETL 스크립트가 수백 개. 누가 어떤 데이터를 어디서 가져오는지 아무도 몰랐다."

이 혼란 속에서 **Apache Kafka**와 **Apache Samza**가 탄생했다. Kafka는 LinkedIn 내부의 데이터 통합 허브가 되었고, 이후 오픈소스로 공개되어 오늘날 스트리밍 인프라의 사실상 표준이 되었다.

---

## DDIA 1판: 어떻게 탄생했나

### 집필 동기

Rapportive 시절 MySQL로 씨름하며 느낀 좌절이 출발점이었다.

> "we were all like searching around in the dark where we're having performance problems with our database and we had no idea what to do basically because we were totally lacking the foundations"

데이터베이스 성능 문제가 발생했을 때, 아무것도 할 수 없었다. 기초가 전혀 없었기 때문이다. 기존 데이터베이스 책은 너무 학술적이거나 너무 실무에 치우쳐 있었다. **원리를 설명하면서도 실무에서 바로 쓸 수 있는 책**이 필요했다.

### 4년의 집필, 2.5년의 초과

O'Reilly와 계약 후 **4년**이 걸렸다. 출판사 마감일은 황당할 정도로 초과했다.

> "The publisher deadline I missed by a ludicrous margin. I think I missed it by about 2 and a half years"

무려 **2년 반**이나 마감을 넘겼다. 초반에는 LinkedIn에서 일하면서 **주당 50%의 시간**을 집필에 할애했다. 하지만 진전이 더뎠고, 결국 LinkedIn을 퇴사하고 전념했다.

> "퇴사한 이유 중 하나는 솔직히 말하면, LinkedIn에서 내가 하던 일의 상당수를 Kafka와 Samza가 이미 해결하고 있었다. 더 이상 나에게 의존하지 않는 시스템을 남겨두고 떠나는 건 괜찮은 일이라고 생각했다."

### 3파트 구조는 사후 분류

DDIA의 3파트 구조 — **데이터 시스템의 기초**, **분산 데이터**, **파생 데이터** — 는 처음부터 계획된 게 아니다.

> "처음에는 그냥 내가 알고 있는 걸 순서대로 썼다. 원고가 어느 정도 완성된 후에 구조를 다듬으면서 3파트로 나눴다. 독자에게 자연스럽게 읽히려면 이 순서가 맞겠다고 판단했다."

---

## DDIA 2판: 무엇이 바뀌었나

### 공동저자 Chris Riccomini

2판에서는 LinkedIn 동료인 **Chris Riccomini**가 공동저자로 합류했다. Chris는 *The Missing Readme*의 공동저자이기도 하며, 실무적 관점을 보완해 준다.

### 삭제: MapReduce 상세

가장 과감한 결단.

> "MapReduce is dead. Nobody uses it anymore."

명확하고 단호한 선언이다. 2판에서 MapReduce는 역사적 배경으로만 간략히 언급된다. 1판에서 상당한 분량을 할애하던 MapReduce와 Hadoop의 상세한 설명을 과감히 삭제하고, 그 자리를 현대적인 데이터 처리 기술로 채웠다.

### 추가: 클라우드 네이티브, 벡터 인덱스, 데이터프레임, 윤리

- **클라우드 네이티브 아키텍처** — 서버리스, 매니지드 서비스, 멀티 클라우드 전략
- **벡터 인덱스** — AI/ML 워크로드와 벡터 데이터베이스의 내부 원리
- **데이터프레임** — Pandas, Polars, Spark DataFrame의 평가 모델
- **윤리 장 독립 챕터** — 1판에서는 분산되어 있던 윤리적 고려사항을 별도 챕터로 독립

---

## 핵심 개념: 신뢰성, 확장성, 유지보수성

DDIA 1장에서 제시하는 세 가지 원칙을 Martin이 다시 정의한다.

### 신뢰성 = 장애 허용

"신뢰성은 '장애가 없음'이 아니다. **장애가 발생해도 시스템이 계속 동작하는 것**이다."

하드웨어 고장, 소프트웨어 버그, 인간의 실수 — 이 세 가지는 반드시 일어난다. 문제는 "어떻게 막을까"가 아니라 "어떻게 견딜까"다.

### 해저 케이블과 소의 발

분산 시스템의 신뢰성 이야기에서 빠질 수 없는 것이 바로 **물리적 인프라의 장애**다. 그중에서도 가장 흥미로운 것이 해저 케이블이다.

> "the sharks biting undersea cables... the shielding has got better and therefore the sharks are not biting them anymore. But instead the cows on land are stepping on cables"

상어가 해저 케이블을 물어뜯는 문제는 케이블 차폐(shielding)가 개선되면서 해결됐다. 하지만 이번에는 육지에서 **소가 케이블을 밟는** 문제가 생겼다. 장애의 형태는 변하지만, 장애는 항상 찾아온다. DDIA에서 다루는 "장애 허용" 철학이 현실에서도 이렇게 역설적으로 나타난다.

### 확장성: 스케일 업만이 아니다

흥미로운 지점은 **스케일 다운**의 중요성이다.

> "not just scaling up but scaling down as well... how do you run a service that if it has a very small amount of load it's really cheap to run"

대규모 트래픽을 처리하는 것만 확장성이 아니다. **적은 부하에서도 비용 효율적으로 동작**하는 것 역시 중요한 과제다. 서버리스가 이 철학의 극단적인 사례다.

> "I have a small website that runs on serverless and my bill is like 13 cents per month"

Martin 자신이 서버리스의 실사용 사례를 들며, 트래픽이 적을 때 얼마나 저렴하게 운영할 수 있는지를 보여준다. 거대한 클러스터를 운영하는 것만이 확장성의 전부가 아니라는 것.

### Row vs Column: 아는 것이 슈퍼파워

스토리지 엔진의 내부 구조를 이해하는 것은 생각보다 훨씬 큰 차이를 만든다.

> "whether you're using row oriented storage or column oriented storage... it has a massive performance implication... knowing a bit about the internals is actually like a superpower"

행 기반 저장과 열 기반 저장의 선택은 쿼리 성능에 **거대한 영향**을 미친다. 내부 원리를 조금만 알아도 문제 해결 속도가 완전히 달라진다. DDIA를 읽는 가장 큰 이유 중 하나가 바로 이런 "슈퍼파워"를 얻는 것이다.

### 추상화의 역설

클라우드 매니지드 서비스를 쓰면 내부 원리를 몰라도 된다. 하지만...

> "if you're building the higher level systems... that's fine. But somebody still has to build those lower level abstractions"

추상화 위에서 비즈니스 로직을 만드는 것은 좋다. 하지만 **누군가는 그 아래 층의 추상화를 만들어야 한다**. 그리고 추상화가 무너질 때 — 장애가 났을 때 — 내부 원리를 아는 사람만이 원인을 파악할 수 있다.

---

## 형식 검증이 AI 시대에 중요한 이유

Martin의 학계 연구 중 가장 돋보이는 분야 중 하나가 **형식 검증(formal verification)**이다.

### 모델 체킹 vs 증명 보조기

- **모델 체킹(TLA+)** — 시스템의 모델을 작성하고, 모든 가능한 상태를 탐색하여 버그를 찾는다. 유한 상태 공간에서 강력.
- **증명 보조기(Isabelle, Lean)** — 수학적 증명으로 시스템의 **모든** 가능한 상태에서 성질을 보인다. 무한 상태 공간도 커버.

> "테스트는 버그의 부재를 증명할 수 없다. 테스트가 통과했다는 건 '내가 생각한 시나리오에서는 괜찮다'는 뜻이다. 형식 검증은 **무한 상태 공간**에서 성질을 보장한다."

### LLM이 증명을 쓰기 시작했다

이제 LLM이 Coq, Lean, Isabelle에서 증명 스크립트를 작성하는 능력이 급속도로 향상되고 있다.

> "형식 검증의 가장 큰 장벽은 '증명을 쓰는 게 너무 비싸다'는 것이었다. LLM이 그 비용을 낮추고 있다. 이건 패러다임 전환이다."

### 바이브 코딩 시대, 자동 검증은 필수

"바이브 코딩" — AI가 코드를 마구 생성하는 시대에, 그 코드가 정말로 올바른지 확인하는 수단이 더욱 중요해진다.

> "we're vibe coding a bunch of stuff. If we have to manually review all of that code, then that will become the bottleneck... the thing that proof can do that tests can't is to consider absolutely every possible thing"

AI가 대량의 코드를 생성하면 **수동 리뷰가 병목**이 된다. 테스트는 한계가 있다 — 생각하는 시나리오만 검증할 수 있을 뿐이다. 반면 **형식 증명(formal proof)**은 **절대적으로 모든 가능한 경우**를 고려할 수 있다. 테스트와 증명은 상호 보완적이며, 바이브 코딩 시대에는 증명의 가치가 그 어느 때보다 크다.

---

## Local-First Software: 10년의 연구

Martin이 케임브리지 대학에서 약 10년간 몰두한 연구 주제.

### 핵심 철학

> "클라우드 서비스에 의존하지 말자. 사용자가 **자기 데이터를 통제**할 수 있게 하자."

Local-First는 오프라인 동작을 기본으로 하고, 클라우드는 동기화 매개체로만 사용한다. 인터넷이 끊겨도 앱이 동작하고, 서버가 사라져도 데이터는 로컬에 남는다.

### 핵심 챌린지

1. **탈중앙화 접근 제어** — 중앙 서버 없이 누가 어떤 데이터에 접근할 수 있는지 관리
2. **consensus 없이 일관성 유지** — 분산 합의(Paxos, Raft) 없이 여러 기기 간 데이터 일관성 보장
3. **충돌 해결** — 오프라인 변경이 여러 기기에서 동시에 일어났을 때 자동 병합

### Automerge (CRDT)

이 연구의 결정체가 **Automerge**다. CRDT(Conflict-Free Replicated Data Type) 기반의 JSON-like 데이터 구조로, 여러 사용자가 동시에 편집해도 자동으로 병합된다.

> "Google Docs 같은 실시간 협업을, 중앙 서버 없이 할 수 있게 만드는 게 목표다."

### SaaS 비즈니스 모델 비판

Martin은 현재 SaaS 모델에 대해 강하게 비판한다.

> "software as a service businesses... the whole reason why they can charge a subscription is because they are able to essentially hold a gun to the customer's head"

SaaS 비즈니스가 구독을 청구할 수 있는 근본적인 이유는, 고객의 데이터를 쥐고 있어서 **사실상 협박**이 가능하기 때문이다. "구독을 끊으면 데이터를 잃는다"는 구조는 건강한 관계가 아니다.

Local-First는 데이터 소유권을 사용자에게 돌려줌으로써 이 관계를 근본적으로 바꾸려 한다.

---

## 새 연구: 암호학으로 물리 세계 증명

Martin의 최신 연구 방향은 생각보다 "물리적"이다.

### 공급망 탄소 배출 검증

기업이 "우리 제품의 탄소 배출량은 X다"라고 주장할 때, 그게 사실인지 어떻게 확인할까?

- **EU 규제** — 공급망 전체의 탄소 배출 보고 의무화
- **문제** — 상업적 민감정보(단가, 거래처)를 공개하지 않으면서 증명해야 함
- **접근** — 영지식 증명(ZKP) 등 암호학 기법으로 데이터를 공개하지 않으면서 클레임을 검증

### 산림 파괴 방지 규제

EU의 **Deforestation Regulation**은 커피, 코코아, 목재 등의 원산지가 불법 벌목 지역이 아님을 증명하도록 요구한다. 위성 이미지와 공급망 데이터를 암호학적으로 연결하여 증명하는 연구를 진행 중이다.

> "분산 시스템에서 데이터 무결성을 증명하는 기술을, 물리 세계의 환경 문제에 적용하는 건 자연스러운 확장이다."

---

## 산업 vs 학계

Martin은 산업과 학계 양쪽을 경험한 드문 사례다.

### 학계의 장점

> "학계의 가장 큰 특권은 **장기적 사고**다. 5년, 10년 단위로 생각할 수 있다. 분기별 실적에 쫓기지 않아도 된다."

상업적 인센티브에 독립적이기 때문에, 시장에 즉각적인 가치가 없어도 중요한 문제에 매진할 수 있다.

### 산업이 학계에서 배울 것

> "산업 엔지니어가 학계의 **제일원칙(first principles) 사고**를 도입하면 경쟁력이 완전히 달라진다. '왜 이 아키텍처인가?'를 근본적으로 질문하는 습관."

### 추천 커리어 경로

Martin이 추천하는 경로:

1. **학부** — 기초를 탄탄히
2. **산업 경험** (2~5년) — 실제 문제가 무엇인지 몸으로 체득
3. **박사 과정** — 산업에서 발견한 문제를 깊이 파고들

> "산업 경험 없이 박사 과정에 들어오면, 진짜 문제가 뭔지 모른 채 논문을 쓰게 된다. 반대로 산업만 하면 '왜'를 묻지 않게 된다. 둘 다 필요하다."

그리고 학습 과정에서의 어려움에 대해서도 조언을 남긴다.

> "sometimes in order to learn something you just have to struggle with it a bit"

**직접 부딪히고 고생해 보는 것**을 대체할 학습법은 없다. DDIA도 읽기만 해서는 안 되고, 실제 문제에 직면했을 때 다시 펼쳐봐야 진정한 가치를 얻을 수 있다.

---

## 마무리

Martin Kleppmann은 실무자이자 연구자이자 작가인, 보기 드문 하이브리드다. 그의 커리어 궤적 — 스타트업 실패, 인수, 대규모 인프라, 학계 연구 — 은 DDIA라는 책에 고스란히 녹아 있다.

**DDIA 2판**은 2026년 현재의 데이터 인프라 환경을 반영한 의미 있는 업데이트다. MapReduce의 퇴장과 클라우드 네이티브·벡터 인덱스의 등장은 이 업계가 얼마나 빠르게 변화하는지를 보여준다.

그리고 그의 연구는 여전히 진행 중이다. Local-First Software, 형식 검증, 암호학적 공급망 증명 — 이 모든 것이 "데이터 시스템을 더 신뢰할 수 있게 만드는 방법"이라는 하나의 질문으로 연결된다.

> "데이터를 어떻게 다룰 것인가. 그게 결국 모든 것의 핵심이다."

---

- **원본 인터뷰 영상:** [Designing Data-Intensive Applications with Martin Kleppmann — The Pragmatic Engineer Podcast](https://youtu.be/SVOrURyOu_U)
- **DDIA 2판:** O'Reilly 출간 예정
- **Automerge:** [automerge.org](https://automerge.org/)
- **Local-First Software:** [localfirstweb.dev](https://localfirstweb.dev/)
