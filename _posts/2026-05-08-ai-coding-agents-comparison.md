---
     2|title: "Claude Code 대신 뭘 쓸까 — OpenCode vs Pi 비교와 추천"
     3|layout: post
     4|date: 2026-05-08 00:00:00
     5|categories:
     6|  - AI
     7|tags:
     8|  - AI
     9|  - Claude
    10|  - ClaudeCode
    11|  - OpenCode
    12|  - Pi
    13|  - CodingAgent
    14|  - CLI
    15|mermaid: true
---
    16|
    17|> **TL;DR** — Pi를 추천한다. 이유: (1) 숨겨진 컨텍스트 주입 없이 예측 가능 (2) 시스템 프롬프트 1/10로 API 비용 절감 (3) 필요한 기능만 확장으로 추가 (4) Pi 스스로 확장을 작성하는 자가 수정 가능. 즉시 풍부한 기능이 필요하면 OpenCode가 대안.
    18|>
    19|> **빠른 시작:**
    20|> ```bash
    21|> npm install -g @earendil-works/pi-coding-agent   # 설치
    22|> cd /path/to/project && pi && /login               # 실행 + 인증
    23|> npx @robzolkos/lazypi                             # 확장 한번에 설치 (선택)
    24|> ```
    25|
    26|---
    27|
    28|## 한눈에 보기 — 철학 스펙트럼
    29|
    30|<video autoplay loop muted playsinline width="100%" style="max-width: 1280px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.15);">
    31|  <source src="/assets/videos/philosophy-spectrum.webm" type="video/webm">
    32|</video>
    33|
    34|| | Claude Code | OpenCode | Pi |
    35||---|---|---|---|
    36|| **개발** | Anthropic | anomalyco (커뮤니티) | Mario Zechner |
    37|| **오픈소스** | 아니오 | 네 (100%) | 네 |
    38|| **비용** | $20/월 + API | API 비용만 | API 비용만 |
    39|
    40|- **Claude Code** — Anthropic 생태계에 깊이 통합. 강력한 기본값, 낮은 설정 부담, 벤더 종속.
    41|- **OpenCode** — Claude Code의 오픈소스 미러. provider 무관, TUI/데스크톱/모바일 클라이언트, Client/Server 아키텍처. neovim 유저와 terminal.shop 제작자가 개발.
    42|- **Pi** — "반대 방향". 최소한의 코어, 모든 추가 기능은 사용자가 선택해 확장. 예측 가능하고 토큰 효율적.
    43|
    44|---
    45|
    46|## 기능 비교 — 레이더 차트
    47|
    48|<video autoplay loop muted playsinline width="100%" style="max-width: 1280px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.15);">
    49|  <source src="/assets/videos/feature-radar.webm" type="video/webm">
    50|</video>
    51|