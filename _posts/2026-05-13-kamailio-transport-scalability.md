---
title: "Kamailio Transport Layer Scalability — Multi-Processing에서 Multi-Threading으로"
layout: post
date: 2026-05-13 23:30:00
categories:
  - VoIP
  - Infrastructure
tags:
  - kamailio
  - sip
  - voip
  - networking
  - scalability
  - multi-threading
---

> **원본 영상:** [Transport Layer Scalability – Multi Processing And Multi Threading — Daniel-Constantin Mierla @ Kamailio World 2026](https://www.youtube.com/watch?v=f0_xkXucO_U)

> **TL;DR** — Kamailio는 2001년부터 multi-process 아키텍처로 SIP traffic을 처리해왔다. 최근 릴리스에서 UDP와 TLS transport layer에 대해 **multi-threading** 기반 처리가 추가되었다. UDP는 `udp_receive_mode`로 스레드 기반 수신이 가능하고, TLS는 libSSL의 thread-safety 문제(Heartbleed 이후)를 `tcp_main_threads`라는 전용 스레드 모델로 해결했다. 아직 default는 multi-process지만, 향후 multi-threading이 표준이 될 방향이다.
{: .prompt-info }

---

## Transport Layer 개요

Kamailio는 다양한 network protocol 조합을 지원한다. 기본적으로 **IPv4/IPv6** address family와 **UDP/TCP/TLS**를 주요 SIP transport로 사용하며, WebRTC 통신을 위한 **WebSocket Secure (WSS)**, 최근에는 **plain WebSocket (WS)** 까지 지원한다.

Daniel-Constantin Mierla는 이 발표에서 Kamailio가 지원하는 transport layer의 조합과 그 scaling 전략을 상세히 설명했다. 주요 use case는 다음과 같다:

- **Security bridging** — 외부 네트워크(TLS)와 내부 네트워크(UDP/TCP) 간 보안 경계 역할. Kamailio를 SBC(Session Border Controller)로 사용하여 media server, PSTN gateway 등을 private network에 보관
- **IPv4 ↔ IPv6 전환** — 레거시 IPv4 환경과 IPv6 환경 간 SIP proxy
- **WebRTC ↔ SIP** — WebSocket을 통한 WebRTC client와 classic SIP 전화기 간 연결
- **WebSocket Proxy** — Kamailio가 WebSocket proxy로 동작하는 신규 패턴

![Kamailio Transport Layer Options](/images/kamailio-transport/frame_0.jpg)
![Transport Use Cases](/images/kamailio-transport/frame_20.jpg)

---

## 소켓 설정: listen vs socket

Kamailio에서 listening socket을 지정하는 방법은 두 가지다.

### 전통적인 listen 지시자

```kamailio
# protocol + IP/interface + port
listen=udp:10.0.0.1:5060
listen=tls:eth0:5061
listen=wss:192.168.1.100:443
```

여러 번 선언할 수 있고, protocol과 port는 생략 가능하다. 생략 시 default port(5060)와 default transport(UDP)가 사용된다. interface 이름(예: `eth0`)도 IP 대신 지정할 수 있다.

![Listen Directive](/images/kamailio-transport/frame_40.jpg)

### 구조화된 socket global parameter

최근 major release에서 추가된 `socket` parameter는 더 구조화된 방식이다:

```kamailio
socket {
    bind: 10.0.0.1:5060
    advertise: 203.0.113.5:5060
    async_group: groupA
}
```

- **bind** — 실제 binding할 주소
- **advertise** — SIP header에 기록할 public 주소 (NAT 환경에서 유용)
- **async_group** — UDP multi-threading에서 worker group 지정

![Socket Global Parameter](/images/kamailio-transport/frame_80.jpg)

명시적으로 `listen`이나 `socket`을 지정하지 않으면, Kamailio는 해당 시점에 사용 가능한 IP를 auto-discovery한다. IPv6까지 자동 발견하려면 `auto_bind_ipv6` global parameter를 설정해야 한다.

### Socket 확인

`listen` 없이 실행하거나 `0.0.0.0`으로 listen하면, 실제로 어떤 socket이 열렸는지 RPC command로 확인할 수 있다:

```bash
kamcmd core.listen
# JSON output으로 listening socket 목록 반환
```

dynamic IP 환경에서는 auto-discovery 결과가 예상과 다를 수 있으므로, 반드시 확인하는 것이 좋다.

---

## TCP 보안 옵션

발표에서 Mierla는 TCP transport layer에 추가된 다양한 보안 옵션을 강조했다. Kamailio World에서 논의된 "slow connection" attack에 대응하기 위해 최근 1~2년 사이에 여러 option이 추가되었다:

```kamailio
# 첫 패킷 대기 시간
tcp_accept_timeout = 5

# 전체 SIP 메시지 수신 대기 시간
tcp_recv_timeout = 10

# TCP connection 관련 주요 옵션들
tcp_connect_timeout = 5
tcp_send_timeout = 5
tcp_connection_lifetime = 3605
```

공격자가 connection을 맺고 데이터를 보내지 않거나, 한 글자씩 10초마다 보내는 식으로 file descriptor를 소모하는 공격을 방어한다. 물론 이런 공격은 **firewall 단**에서 차단하는 것이 더 바람직하다.

![TCP Security Options](/images/kamailio-transport/frame_120.jpg)

---

## Multi-Process Architecture (2001~)

Kamailio(SIP Express Router)의 초기 설계자인 Andre가 **2001년**에 multi-process 아키텍처를 선택했다. Mierla는 "20시간 전에 release를 해야 했기 때문에 빠른 결정이 필요했다"고 농담처럼 회고했다.

### 장점

- **경량 설계** — worker 간에 synchronization이 필요 없다. 각 process가 독립적인 memory space를 가지므로 shared resource에 대한 lock이 불필요
- **안정성** — 한 worker가 crash해도 다른 process는 정상 동작
- **UDP dispatching** — transport layer가 datagram을 읽어서 각 process에 하나씩 분배. Kamailio 자체가 아닌 OS가 receiving/distribution을 처리

![Multi-Process Benefits](/images/kamailio-transport/frame_140.jpg)

### 단점

- **최소 1 process per socket** — 보안상 여러 VPN/carrier와 연결해야 하는 환경에서는 socket 수가 많아지고, 병렬 처리를 위해 2개 이상의 process가 필요하면 process 수가 기하급수적으로 증가
- **Database connection 한계** — 각 process가 database에 connection을 생성하므로, process 수 증가에 따라 DB active connection limit에 도달. Cloud provider의 managed DB를 사용하는 경우 tuning이 제한적
- **메모리 중복** — 각 process가 독립적인 memory space를 가지므로 config parsing, module loading 등의 메모리가 중복

```
Multi-Process 모델의 문제:

Socket 1 ──→ Worker 1 ──→ DB Connection 1
Socket 2 ──→ Worker 2 ──→ DB Connection 2
Socket 3 ──→ Worker 3 ──→ DB Connection 3
... (socket/process 수에 비례하여 DB connection 증가)
```

![Multi-Process Drawbacks](/images/kamailio-transport/frame_200.jpg)

---

## Multi-Threading: UDP

UDP에 대한 multi-threading 지원이 추가되면서, 한 process가 여러 socket을 담당할 수 있게 되었다. 이는 위에서 언급한 process 수 / DB connection 한계 문제를 해결한다.

### udp_receive_mode

```kamailio
# Mode 0 (default): 기존 multi-process 모델 (변경 없음)
# Mode 1: 한 process가 여러 socket을 담당
#          각 socket마다 전용 receive thread를 생성
# Mode 2: dedicated async worker group 할당
udp_receive_mode = 1

# Mode 2 예시
udp_receive_mode = 2
```

**Mode 1**은 각 listening socket마다 전용 receive thread를 생성하여, multi-process 모델에서 "소켓당 최소 1 process"가 필요했던 제약을 해소한다.

![Multi-Threading UDP Architecture](/images/kamailio-transport/frame_240.jpg)

### async_workers와 Worker Group

**Mode 2**에서는 worker group을 정의하고, 각 socket에 group을 할당한다:

```kamailio
# async worker group 정의
async_workers = groupA 4
async_workers = groupB 2

# socket에 group 할당
socket {
    bind: 10.0.0.1:5060
    async_group: groupA
}

socket {
    bind: 10.0.0.2:5060
    async_group: groupB
}
```

이 설정으로 특정 socket에 대해 **전용 worker thread pool**을 가질 수 있다. 예를 들어 carrier A 트래픽은 4개 thread로, carrier B 트래픽은 2개 thread로 처리하는 식의 세분화된 resource 분배가 가능하다.

![udp_receive_mode Config](/images/kamailio-transport/frame_300.jpg)

### UDP Multi-Threading 장단점

- **장점** — process 수 감소 → DB connection 감소, memory 공유로 효율 증가
- **단점** — shared memory space를 사용하므로 synchronization 필요. config 내에서 shared data에 대한 concurrent access에 주의해야 함

![Mixed Mode async_workers](/images/kamailio-transport/frame_360.jpg)

---

## Multi-Threading: TCP/TLS

TCP/TLS에서의 multi-threading 도입은 더 복잡한 배경이 있다.

### 문제: OpenSSL 3.0의 Thread-Safety

**OpenSSL 3.0**에서 대규모 내부 아키텍처 변경이 이루어졌다. Heartbleed 취약점(CVE-2014-0160) 이후 지속된 보안 강화 과정에서 OpenSSL 내부 구조가 크게 재설계되었고, 그 결과 **`fork()` 기반 multi-process 환경에서 SSL_CTX와 thread-local data의 일관성** 문제가 발생했다.

기존 Kamailio의 multi-process 모델에서는:
1. 여러 TCP worker process가 존재
2. 각 process가 독립적으로 SSL context를 사용
3. 하지만 OpenSSL 3.0의 내부 refactoring으로 인해 process 간 SSL state 일관성이 깨져 **random crash** 발생

![libSSL 3.0 Problem](/images/kamailio-transport/frame_480.jpg)

Mierla는 "Willix 팀이 매우 유용한 debugging 정보를 제공해주었다. 그 덕분에 실제 원인을 식별할 수 있었다"며, 실제 운영 환경에서 겪는 문제를 community의 협력으로 해결한 과정을 설명했다.

![Original TCP Architecture](/images/kamailio-transport/frame_400.jpg)

### 해결책: tcp_main_threads

```kamailio
# TLS multi-threading 활성화
tcp_main_threads = 1
# 또는
tcp_main_threads = on
# 또는
tcp_main_threads = true
```

이 설정을 활성화하면 동작 방식이 다음과 같이 변경된다:

```
기존 (Multi-Process):
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│  TCP Worker 1 │  │  TCP Worker 2 │  │  TCP Worker N │
│  SSL Context  │  │  SSL Context  │  │  SSL Context  │  ← 독립 process, SSL context 불일치 문제
└──────────────┘  └──────────────┘  └──────────────┘

tcp_main_threads = 1 (Multi-Thread):
┌──────────────────────────────────────────────────┐
│                 tcp_main Process                  │
│  ┌────────┐  ┌────────┐  ┌────────┐              │
│  │Thread 1│  │Thread 2│  │Thread N│              │
│  │SSL_CTX │  │SSL_CTX │  │SSL_CTX │  ← 동일 process 내 thread-local
│  └────────┘  └────────┘  ┌────────┐              │
│       ↕          ↕        │pipe   │              │
│  ┌────────┐  ┌────────┐  └────────┘              │
│  │Worker 1│  │Worker 2│  │Worker N│              │
│  └────────┘  └────────┘  └────────┘              │
└──────────────────────────────────────────────────┘
```

구체적인 동작 원리:
1. 기존 `tcp_main` process를 유지
2. 이 process 내에서 TCP worker 수를 자동 감지
3. 각 worker에 대해 **전용 thread**를 생성
4. Worker process와 해당 thread 사이에 **bidirectional communication pipe** 구축
5. Worker는 encryption/decryption과 TLS 전송을 자신의 thread에 위임

이렇게 하면 모든 libSSL context와 thread-local data가 **동일한 process 내**에 존재하므로 안전하게 사용할 수 있다.

![tcp_main_threads Solution](/images/kamailio-transport/frame_560.jpg)

### 주의사항

- **v6.1 stable**부터 사용 가능
- **default는 여전히 multi-process** (backward compatibility)
- 설정은 `listen`/`socket`이 아닌 **global parameter**로만 지정
- 모든 TCP/TLS/WSS socket에 일괄 적용됨

```kamailio
# socket 레벨이 아닌 global 레벨 설정
tcp_main_threads = 1

# 이후 기존처럼 socket 지정
listen = tls:10.0.0.1:5061
listen = wss:10.0.0.1:443
```

![TCP TLS Multi-Threading Summary](/images/kamailio-transport/frame_620.jpg)

---

## 개발 버전의 진행 상황 (Devel)

Mierla는 개발 버전에서 더 진보된 multi-threading 작업이 진행 중이라고 밝혔다. 핵심 contributor인 **Victor Seva (sipwise)** 가 4년 이상 이 영역에 집중해왔다.

### 주요 변경 사항

- **Attribute access의 multi-threading migration** — config reload 등의 작업이 multi-threading 아키텍처에 맞게 재작성
- **Config file reloading** — shared context space 절약
- **WolfSSL 전면 전환** — 개발 버전에서 WolfSSL TLS module은 **multi-threading 전용**으로 동작. Victor가 "이 라이브러리를 사용하는 것이 적절한 접근"이라고 판단
- **libSSL 4.0 대응** — 아직 major Linux distribution에 포함되지 않았지만, 이미 대응 작업 진행 중

![Development Version Progress](/images/kamailio-transport/frame_680.jpg)

### Auto-Mode 계획

현재는 `tcp_main_threads = 1`을 명시적으로 설정해야 하지만, auto-detection mode가 구상 중이다:

> TLS나 WolfSSL module이 load된 경우 자동으로 thread를 생성. 명시적 설정 불필요.
{: .prompt-info }

현재 WSS module의 경우, `tcp_main_threads`를 설정하지 않으면 **startup error**를 발생시키고 log에 설정 필요 메시지를 출력한다.

---

## WebSocket Client (신기능)

Kamailio World 2026에서 발표된 가장 새로운 기능 중 하나는 **Kamailio가 WebSocket client로 동작**하는 기능이다. 이전까지 Kamailio는 WebSocket **server** 역할만 지원했다 (connection accept, handshake 처리).

### 배경

이 기능은 **SIPFront**의 sponsorship으로 개발되었다. SIPFront는 자체 testing framework에 WebSocket client 기능을 통합하려 했다.

### 구현

WebSocket server로서의 대부분 코드는 이미 존재했지만, client로 동작할 때의 핵심 차이는 **HTTP handshake queueing**이다. WebSocket connection을 맺기 위해 SIP 메시지를 잠시 queue에 저장해야 하며, 대량 메시지가 동시에 도달하면 queue가 누적될 수 있다.

### 사용법

```kamailio
# ws_connect() — 빠른 연결 시도, 연결 상태 반환
# URL 형식 또는 분할된 속성 사용 가능
if (ws_connect("sip:user@wss.example.com:443/ws")) {
    # 연결 성공 시 stateless forwarding
    sl_send_reply("100", "Trying");
}

# 또는 속성 분할 형식
ws_connect("wss://example.com", "443", "/ws");

# ws_send() — connect + stateless forwarding (ws_connect + forward와 동일)
ws_send("wss://example.com:443/ws");
```

### 향후 계획

현재 `ws_connect` + `sl_send_reply` 또는 `ws_send` (stateless forwarding)를 지원한다. 향후 `t_relay`와 `forward`에 대해 **transparent 동작**을 지원할 계획이다.

`t_relay`가 SIP address를 기대하는 반면, WebSocket client는 host/port/path가 필요하므로 이를 어떻게 통합할지가 과제다.

![WebSocket Client Feature](/images/kamailio-transport/frame_760.jpg)

---

## SIP Expresser (테스트 도구) 업데이트

WebSocket client 개발을 위해 Mierla가 SIP Expresser 테스트 도구도 확장했다:

- **Plain WebSocket 지원** — 기존에는 WSS만 지원
- **강력한 인증 해시 알고리즘** — 최신/현대 해시 알고리즘 추가
- **자동화 시나리오** — register 후 self-call, 두 user 간 call 등
- **Presence testing** 추가 (테스트가 미완료 상태)

![SIP Expresser Updates](/images/kamailio-transport/frame_840.jpg)

---

## 정리

Daniel-Constantin Mierla의 발표는 Kamailio가 25년 된 multi-process 아키텍처에서 어떻게 점진적으로 multi-threading으로 진화하고 있는지를 보여주었다.

```
Kamailio Transport Layer 진화:

2001          2023          2025          2026+
──────────────────────────────────────────────────
Multi-Process  │  UDP        │  TCP/TLS     │  Auto-Mode
(Architect:    │  Threading  │  Threading   │  WolfSSL
 Andre)        │  (Mode 1/2) │  (tcp_main)  │  libSSL 4.0
               │  async_     │  libSSL      │  WS Client
               │  workers    │  thread-safe │  transparent
               │             │              │  t_relay
```

핵심 takeaways:
- **UDP** — `udp_receive_mode`와 `async_workers`로 socket당 process 감소, DB connection 절약
- **TLS** — `tcp_main_threads = 1`로 libSSL thread-safety 문제 해결. v6.1 stable 부터 사용 가능
- **향후** — auto-detection mode, WolfSSL 전면 전환, libSSL 4.0 대응, WebSocket client 투명화
- **여전히 default는 multi-process** — 안정성을 위해 점진적 마이그레이션 권장

Victor Seva가 4년 이상 이 영역에 집중해온 점, 그리고 Willix 등 실제 운영자들이 debugging에 기여한 점을 강조하며, Mierla는 Kamailio community의 협력 모델을 자랑스러워했다.

---

> **원본 영상:** [Transport Layer Scalability – Multi Processing And Multi Threading — Daniel-Constantin Mierla @ Kamailio World 2026](https://www.youtube.com/watch?v=f0_xkXucO_U)
