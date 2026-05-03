---
title: "macOS 홈 서버 구축하기 — myaddr.tools + Let's Encrypt + Nginx"
layout: post
date: 2026-04-17 00:00:00
categories:
  - Infra
tags:
  - HomeServer
  - myaddr.tools
  - Nginx
  - LetsEncrypt
  - macOS
  - SSL
---

> 공인 IP가 바뀌는 환경에서도, 무료 도메인 + 와일드카드 SSL + 리버스 프록시로 여러 서비스를 서브도메인으로 운영하는 방법을 정리한다.

## 전체 구성도

```mermaid
flowchart TB
    subgraph DDNS[1. myaddr.tools - 동적 DNS]
        DD1[launchd + curl] --> DD2[공인 IP 자동 업데이트]
    end

    subgraph SSL[2. Let's Encrypt - SSL 인증서]
        AC1[acme.sh] -->|DNS-01 챌린지| AC2[myaddr.tools API로 TXT 레코드 추가]
        AC2 --> AC3[기본 + 와일드카드<br/>인증서 각각 발급]
        AC3 --> AC4[~/.ssl/ 에 저장]
    end

    subgraph NGINX[3. Nginx - 리버스 프록시]
        NX1[HTTP:80 → HTTPS 리다이렉트]
        NX2[HTTPS:443 + SSL 인증서]
        NX3[서브도메인별 라우팅]
    end

    DDNS --> SSL --> NGINX

    style DDNS fill:#e3f2fd,stroke:#1976d2
    style SSL fill:#fff3e0,stroke:#f57c00
    style NGINX fill:#e8f5e9,stroke:#388e3c
```

```mermaid
graph LR
    Client[사용자 브라우저] --> Internet[인터넷]
    Internet --> Router[라우터<br/>포트포워딩 80/443]
    Router --> Nginx[Nginx<br/>리버스 프록시]

    Nginx -->|your-name.myaddr.io| Static[정적 페이지<br/>/opt/homebrew/var/www]
    Nginx -->|app.your-name.myaddr.io| App[App 서버<br/>localhost:8080]
    Nginx -->|api.your-name.myaddr.io| API[API 서버<br/>localhost:4000]

    style Client fill:#e1f5fe
    style Nginx fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    style Static fill:#e8f5e9
    style App fill:#e8f5e9
    style API fill:#e8f5e9
```

---

## 1. myaddr.tools — 무료 동적 DNS 구성

[myaddr.tools](https://myaddr.tools)는 미니멀한 무료 동적 DNS(DDNS) 서비스다. 공인 IP가 변경되더라도 도메인으로 접속할 수 있게 해준다.

- 도메인: `your-name.myaddr.io` (`.myaddr.tools`, `.myaddr.dev` 도 모두 동일 IP 리졸브)
- 와일드카드 지원: `*.your-name.myaddr.io` 모두 동일 IP로 리졸브
- Let's Encrypt ACME dns-01 챌린지 지원

### 동작 구조

```mermaid
sequenceDiagram
    participant Cron as launchd (5분마다)
    participant API as myaddr.tools API
    participant DNS as DNS 서버
    participant User as 사용자

    Cron->>API: 공인 IP 업데이트<br/>GET /update?key=...&ip=self
    API-->>Cron: OK 응답
    API->>DNS: DNS 레코드 갱신

    User->>DNS: your-name.myaddr.io 조회
    DNS-->>User: 최신 공인 IP 반환
    User->>API: 공인 IP로 접속
```

### 1-1. myaddr.tools에서 이름 등록

1. https://myaddr.tools 에 접속
2. 원하는 이름 입력 후 Claim
3. Secret Key 발급 받음 (분실 시 복구 불가)

> Secret Key를 분실하면 도메인 제어권을 잃습니다. 안전한 곳에 보관하세요.

### 1-2. 수동 IP 업데이트 테스트

```bash
curl -s "https://myaddr.tools/update?key=<your-secret-key>&ip=self"
# OK 가 출력되면 정상
```

### 1-3. launchd로 자동 업데이트 설정

`~/Library/LaunchAgents/com.myaddrtools.plist` 생성:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.myaddrtools</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/curl</string>
        <string>-s</string>
        <string>https://myaddr.tools/update?key=&lt;your-secret-key&gt;&amp;ip=self</string>
    </array>
    <key>StartInterval</key>
    <integer>300</integer>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
```

```bash
# 서비스 등록
launchctl load ~/Library/LaunchAgents/com.myaddrtools.plist

# 서비스 상태 확인
launchctl list | grep myaddrtools
```

### 1-4. 동작 확인

```bash
# DNS 리졸브 확인
nslookup your-name.myaddr.io
```

### 1-5. 와일드카드 리졸브 확인

myaddr.tools는 모든 서브도메인을 동일 IP로 리졸브한다.

```bash
nslookup www.your-name.myaddr.io
nslookup app.your-name.myaddr.io
nslookup api.your-name.myaddr.io
# 모두 동일한 IP가 반환됨
```

> 90일마다 최소 한 번은 IP 업데이트해야 활성 상태가 유지된다. 120일간 업데이트가 없으면 등록이 삭제된다.

---

## 2. Let's Encrypt SSL 인증서 발급

acme.sh와 myaddr.tools의 커스텀 DNS API를 사용하여 **포트 80 개방 없이** DNS-01 챌린지 방식으로 Let's Encrypt 인증서를 발급받는다.

> **주의**: myaddr.tools는 TXT 레코드를 하나만 저장하므로, 기본 도메인과 와일드카드를 **하나의 인증서로 동시 발급할 수 없다**. 따라서 각각 별도로 발급하여 관리한다.
>
> - 인증서 1 (기본 도메인): `your-name.myaddr.io`
> - 인증서 2 (와일드카드): `*.your-name.myaddr.io`
> - 인증서 유효기간: 90일 (60일마다 자동 갱신)

### DNS-01 챌린지 인증 흐름

```mermaid
sequenceDiagram
    participant acme as acme.sh
    participant MyAddr as myaddr.tools API
    participant LE as Let's Encrypt
    participant DNS as DNS 서버

    acme->>LE: 인증서 발급 요청
    LE-->>acme: 챌린지 토큰 발급
    acme->>MyAddr: TXT 레코드 추가<br/>_acme-challenge.your-name.myaddr.io
    MyAddr-->>acme: OK 응답
    Note over acme: DNS 전파 대기 (--dnssleep 60)
    acme->>DNS: TXT 레코드 확인
    DNS-->>acme: 확인 성공
    acme->>LE: 챌린지 완료 요청
    LE->>DNS: TXT 레코드 검증
    LE-->>acme: 인증서 발급 완료
    Note over MyAddr: TXT 레코드 자동 삭제 (몇 분 후)
```

### 2-1. acme.sh 설치

```bash
curl https://get.acme.sh | sh -s email=<your-email>
```

### 2-2. Let's Encrypt를 기본 CA로 설정

```bash
~/.acme.sh/acme.sh --set-default-ca --server letsencrypt --accountkeylength ec-256
~/.acme.sh/acme.sh --register-account -m <your-email> --server letsencrypt
```

### 2-3. myaddr.tools DNS API 스크립트 설치

acme.sh에서 myaddr.tools를 사용하기 위한 커스텀 DNS API 스크립트를 추가한다.

`~/.acme.sh/dnsapi/dns_myaddrtools.sh` 생성:

```bash
#!/bin/bash

# myaddr.tools DNS API for acme.sh

MYADDRTOOLS_API="https://myaddr.tools/update"

dns_myaddrtools_add() {
  _info "Adding ACME challenge via myaddr.tools"
  _key="${MYADDRTOOLS_KEY}"
  _challenge="${txtvalue}"

  if [ -z "$_key" ]; then
    _err "MYADDRTOOLS_KEY is not set"
    return 1
  fi

  _response=$(_get "${MYADDRTOOLS_API}?key=${_key}&acme_challenge=${_challenge}")

  if [ "$_response" = "OK" ]; then
    _info "Challenge added successfully"
    return 0
  else
    _err "Failed to add challenge: $_response"
    return 1
  fi
}

dns_myaddrtools_rm() {
  _info "Challenge will be auto-removed by myaddr.tools"
  return 0
}
```

```bash
chmod +x ~/.acme.sh/dnsapi/dns_myaddrtools.sh
```

### 2-4. 인증서 발급

Secret Key를 환경변수로 설정한 뒤 발급한다.

**기본 도메인 인증서:**

```bash
export MYADDRTOOLS_KEY="<your-secret-key>"
~/.acme.sh/acme.sh --issue --dns dns_myaddrtools -d your-name.myaddr.io --server letsencrypt --dnssleep 60
```

**와일드카드 인증서:**

```bash
export MYADDRTOOLS_KEY="<your-secret-key>"
~/.acme.sh/acme.sh --issue --dns dns_myaddrtools -d '*.your-name.myaddr.io' --server letsencrypt --dnssleep 60
```

> 포트 80 개방이 필요 없다. myaddr.tools API를 통해 TXT 레코드를 자동으로 추가하여 도메인 소유권을 증명한다.
>
> `*.your-name.myaddr.io` 와일드카드 인증서로 `api.`, `app.`, `blog.` 등 모든 서브도메인을 커버한다. 단, 기본 도메인(`your-name.myaddr.io`)은 포함되지 않으므로 별도 발급이 필요하다.

### 2-5. 인증서 설치

**기본 도메인:**

```bash
mkdir -p ~/.ssl/your-name-base.myaddr.io

~/.acme.sh/acme.sh --install-cert -d your-name.myaddr.io --ecc \
  --key-file ~/.ssl/your-name-base.myaddr.io/key.pem \
  --fullchain-file ~/.ssl/your-name-base.myaddr.io/fullchain.pem \
  --reloadcmd "nginx -s reload"
```

**와일드카드:**

```bash
mkdir -p ~/.ssl/your-name.myaddr.io

~/.acme.sh/acme.sh --install-cert -d '*.your-name.myaddr.io' --ecc \
  --key-file ~/.ssl/your-name.myaddr.io/key.pem \
  --fullchain-file ~/.ssl/your-name.myaddr.io/fullchain.pem \
  --reloadcmd "nginx -s reload"
```

### 2-6. 인증서 파일 경로

| 용도 | 파일 | 경로 |
|------|------|------|
| 기본 도메인 | 인증서 | `~/.ssl/your-name-base.myaddr.io/fullchain.pem` |
| 기본 도메인 | 개인키 | `~/.ssl/your-name-base.myaddr.io/key.pem` |
| 와일드카드 | 인증서 | `~/.ssl/your-name.myaddr.io/fullchain.pem` |
| 와일드카드 | 개인키 | `~/.ssl/your-name.myaddr.io/key.pem` |

### 2-7. 인증서 체크 방법

```bash
# 기본 도메인 인증서
openssl x509 -in ~/.ssl/your-name-base.myaddr.io/fullchain.pem -noout -subject -issuer -dates

# 와일드카드 인증서
openssl x509 -in ~/.ssl/your-name.myaddr.io/fullchain.pem -noout -subject -issuer -dates
```

원격 서버 인증서 확인 (Nginx 구동 후):

```bash
# 기본 도메인
openssl s_client -connect your-name.myaddr.io:443 -servername your-name.myaddr.io </dev/null 2>/dev/null | openssl x509 -noout -dates

# 서브도메인 (예: www)
openssl s_client -connect www.your-name.myaddr.io:443 -servername www.your-name.myaddr.io </dev/null 2>/dev/null | openssl x509 -noout -dates
```

갱신 테스트 (dry-run):

```bash
~/.acme.sh/acme.sh --renew -d your-name.myaddr.io --ecc --force --test
~/.acme.sh/acme.sh --renew -d '*.your-name.myaddr.io' --ecc --force --test
```

### 2-8. 자동 갱신

- acme.sh 설치 시 cron job이 자동 등록된다.
- 인증서는 **90일 유효**하며, **60일마다 자동 갱신**된다.
- Secret Key는 acme.sh 설정에 저장되어 갱신 시에도 자동으로 사용된다.

```bash
# 등록된 cron job 확인
crontab -l | grep acme
```

---

## 3. Nginx 리버스 프록시 설정

Nginx를 리버스 프록시로 사용하여 서브도메인별로 다른 로컬 포트로 라우팅한다.

### 요청 처리 흐름

```mermaid
flowchart TB
    Request[들어오는 요청] --> Port{포트}

    Port -->|80| Redirect[301 리다이렉트<br/>→ HTTPS]
    Port -->|443| SSL[TLS 복호화<br/>도메인별 인증서]

    SSL --> Host{Host 헤더 분기}

    Host -->|your-name.myaddr.io| Static[정적 페이지<br/>/opt/homebrew/var/www]
    Host -->|app.your-name.myaddr.io| App[proxy_pass<br/>localhost:8080]
    Host -->|api.your-name.myaddr.io| API[proxy_pass<br/>localhost:4000]
    Host -->|*.your-name.myaddr.io| Custom[새 server 블록<br/>추가 가능]

    style Request fill:#e1f5fe
    style SSL fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    style Host fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    style Static fill:#e8f5e9
    style App fill:#e8f5e9
    style API fill:#e8f5e9
    style Custom fill:#e8f5e9
```

### 3-1. Nginx 설치

```bash
brew install nginx
```

### 3-2. 설정 파일

설정 파일 위치: `/opt/homebrew/etc/nginx/nginx.conf`

```nginx
worker_processes  auto;

error_log  /opt/homebrew/var/log/nginx/error.log;
pid        /opt/homebrew/var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /opt/homebrew/var/log/nginx/access.log  main;

    sendfile        on;
    tcp_nopush      on;
    tcp_nodelay     on;

    keepalive_timeout  65;
    gzip  on;

    # --- 공통 SSL 설정 (와일드카드 인증서 - 서브도메인용) ---
    ssl_certificate      /Users/username/.ssl/your-name.myaddr.io/fullchain.pem;
    ssl_certificate_key  /Users/username/.ssl/your-name.myaddr.io/key.pem;
    ssl_protocols        TLSv1.2 TLSv1.3;
    ssl_ciphers          HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers  on;
    ssl_session_cache    shared:SSL:10m;
    ssl_session_timeout  10m;

    # --- HTTP → HTTPS 리다이렉트 ---
    server {
        listen 80;
        server_name _;
        return 301 https://$host$request_uri;
    }

    # --- 기본 도메인: 전용 인증서 사용 ---
    server {
        listen 443 ssl;
        server_name your-name.myaddr.io;
        ssl_certificate     /Users/username/.ssl/your-name-base.myaddr.io/fullchain.pem;
        ssl_certificate_key /Users/username/.ssl/your-name-base.myaddr.io/key.pem;

        location / {
            root   /opt/homebrew/var/www;
            index  index.html index.htm;
        }
    }

    # --- 서브도메인 리버스 프록시 ---
    # 아래 예시를 복사/수정하여 사용

    # app.your-name.myaddr.io → localhost:8080
    # server {
    #     listen 443 ssl;
    #     server_name app.your-name.myaddr.io;
    #
    #     location / {
    #         proxy_pass         http://127.0.0.1:8080;
    #         proxy_set_header   Host              $host;
    #         proxy_set_header   X-Real-IP         $remote_addr;
    #         proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
    #         proxy_set_header   X-Forwarded-Proto $scheme;
    #     }
    # }

    # api.your-name.myaddr.io → localhost:4000
    # server {
    #     listen 443 ssl;
    #     server_name api.your-name.myaddr.io;
    #
    #     location / {
    #         proxy_pass         http://127.0.0.1:4000;
    #         proxy_set_header   Host              $host;
    #         proxy_set_header   X-Real-IP         $remote_addr;
    #         proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
    #         proxy_set_header   X-Forwarded-Proto $scheme;
    #     }
    # }

    include servers/*;
}
```

> 공통 SSL 블록(http 레벨)에 와일드카드 인증서를 설정하면, 명시적으로 `ssl_certificate`를 지정하지 않은 server 블록은 모두 이 인증서를 상속받는다. 기본 도메인 server 블록만 별도의 전용 인증서를 지정하면 된다.

### 3-3. 서비스 시작

```bash
brew services start nginx
```

### 3-4. 설정 문법 검사 & 리로드

```bash
# 문법 검사
nginx -t

# 설정 변경 후 리로드 (재시작 불필요)
nginx -s reload
```

### 3-5. 서브도메인 추가 방법

새 서비스를 추가하려면 `nginx.conf`에 새 server 블록을 추가한다.

```nginx
# 예: blog.your-name.myaddr.io → localhost:3000
server {
    listen 443 ssl;
    server_name blog.your-name.myaddr.io;

    location / {
        proxy_pass         http://127.0.0.1:3000;
        proxy_set_header   Host              $host;
        proxy_set_header   X-Real-IP         $remote_addr;
        proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
    }
}
```

추가 후 리로드:

```bash
nginx -t && nginx -s reload
```

> 별도 DNS/SSL 설정이 필요 없다. myaddr.tools가 자동으로 리졸브하고, 와일드카드 인증서가 모든 서브도메인을 커버한다.

### 3-6. 동작 확인

```bash
# HTTP → HTTPS 리다이렉트 확인
curl -s -o /dev/null -w "%{http_code}" http://your-name.myaddr.io
# 301 반환

# HTTPS 확인
curl -sk -o /dev/null -w "%{http_code}" https://your-name.myaddr.io
# 200 반환
```

### 3-7. 로그 확인

```bash
# 접근 로그
tail -f /opt/homebrew/var/log/nginx/access.log

# 에러 로그
tail -f /opt/homebrew/var/log/nginx/error.log
```

### 3-8. 정적 페이지 경로

메인 도메인의 정적 파일은 아래 경로에 위치한다.

```
/opt/homebrew/var/www/
```

`index.html`을 생성하면 `https://your-name.myaddr.io`에서 바로 확인할 수 있다.

---

## 정리

| 구성 요소 | 역할 |
|-----------|------|
| myaddr.tools | 무료 DDNS. 공인 IP 변경 시 자동 업데이트 |
| acme.sh | Let's Encrypt 인증서 발급/갱신 자동화 (DNS-01 챌린지) |
| Nginx | 리버스 프록시. 서브도메인별 라우팅 + HTTPS 종단 |

**핵심 포인트:**

- myaddr.tools는 TXT 레코드를 하나만 지원하므로 기본 도메인과 와일드카드 인증서를 **각각 발급**해야 한다
- Nginx http 레벨에 와일드카드 인증서를 공통으로 설정하고, 기본 도메인 server 블록에만 전용 인증서를 지정하는 방식으로 관리한다
- 서브도메인 추가 시 DNS나 SSL 설정 변경 없이 nginx server 블록만 추가하면 된다
