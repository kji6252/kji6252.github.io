---
     2|title: "macOS 홈 서버 구축하기 — myaddr.tools + Let's Encrypt + Nginx"
     3|layout: post
     4|date: 2026-04-17 00:00:00
     5|categories:
     6|  - Infra
     7|tags:
     8|  - HomeServer
     9|  - myaddr.tools
    10|  - Nginx
    11|  - LetsEncrypt
    12|  - macOS
    13|  - SSL
    14|mermaid: true
---
    15|
    16|> 공인 IP가 바뀌는 환경에서도, 무료 도메인 + 와일드카드 SSL + 리버스 프록시로 여러 서비스를 서브도메인으로 운영하는 방법을 정리한다.
    17|
    18|## 전체 구성도
    19|
    20|```mermaid
    21|flowchart TB
    22|    subgraph DDNS[1. myaddr.tools - 동적 DNS]
    23|        DD1[launchd + curl] --> DD2[공인 IP 자동 업데이트]
    24|    end
    25|
    26|    subgraph SSL[2. Let's Encrypt - SSL 인증서]
    27|        AC1[acme.sh] -->|DNS-01 챌린지| AC2[myaddr.tools API로 TXT 레코드 추가]
    28|        AC2 --> AC3[기본 + 와일드카드<br/>인증서 각각 발급]
    29|        AC3 --> AC4[~/.ssl/ 에 저장]
    30|    end
    31|
    32|    subgraph NGINX[3. Nginx - 리버스 프록시]
    33|        NX1[HTTP:80 → HTTPS 리다이렉트]
    34|        NX2[HTTPS:443 + SSL 인증서]
    35|        NX3[서브도메인별 라우팅]
    36|    end
    37|
    38|    DDNS --> SSL --> NGINX
    39|
    40|    style DDNS fill:#e3f2fd,stroke:#1976d2
    41|    style SSL fill:#fff3e0,stroke:#f57c00
    42|    style NGINX fill:#e8f5e9,stroke:#388e3c
    43|```
    44|
    45|```mermaid
    46|graph LR
    47|    Client[사용자 브라우저] --> Internet[인터넷]
    48|    Internet --> Router[라우터<br/>포트포워딩 80/443]
    49|    Router --> Nginx[Nginx<br/>리버스 프록시]
    50|
    51|