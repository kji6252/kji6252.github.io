---
title: 최신 메시지 큐(Messgae Queue) MQ 기술
layout: post
date: 2015-12-18 08:13:00
categories:
  - 최신 기술
tags:
  - Message Queue

---
# 메시지 큐 란 무엇인가?

메시지 지향 미들 웨어(Message Oriented Middleware: MOM)은 비 동기 메시지를 사용하는 다른 응용 프로그램 사이에서 데이터의 송수신을 의미 한다.

MOM을 구현한 시스템을 메시지 큐(Message Queue: MQ)라 한다.  
메시지 큐는 별도의 공정 작업을 연기 할 수 있는 유연성을 제공하여 SOA (service-oriented architecture)의 개발에 도움을 줄 수 있다.

프로그래밍에서 MQ는 프로세스 또는 프로그램 인스턴스가 데이터를 서로 교환할때 사용하는 방법이다. 이때 데이터를 교환할때 시스템이 관리하는 메세지 큐를 이용하는 것이 특징이다. 이렇게 서로 다른 프로세스나 프로그램 사이에 메시지를 교환할때 AMQP(Advanced Message Queueing Protocol)을 이용한다. AMQP는 메세지 지향 미들웨어를 위한 open standard application layer protocol 이다. AMQP를 이용하면 다른 벤더 사이에 메세지를 전송하는 것이 가능한데 JMS (Java Message Service)가 API를 제공하는것과 달리 AMQP는 wire-protocol을 제공하는데 이는 octet stream을 이용해서 다른 네트워크 사이에 데이터를 전송할 수 있는 포멧인데 이를 사용한다.

![C:\Users\김종인\Downloads\MOM diagram.png](https://lh5.googleusercontent.com/TpxIuVIxvO-XDxHn81kWL0vMPkQbvwyg17VYa9b0iy2tOxDpRfIrFr6rk1NtW_vWi2hkblDDCAymp_6czuEuqL_Pw7YGartv-i0s69cDUt7zS3Pg1VpygFzcooIIvtDi4Xuv2Onvp07PJgAh1A)

그림 1 MOM 개념
<!-- more -->
# 메시지 큐의 장점

* 비 동기(Asynchronous) : Queue에 넣기 때문에 나중에 처리 할 수 있다.
* 비 동조(Decoupling) : 애플리케이션과 분리 할 수 있다.
* 탄력성(Resilience) : 일부가 실패 시 전체에 영향을 받지 않는다.
* 과잉(Redundancy): 실패 할 경우 재실행 가능
* 보증(Guarantees): 작업이 처리된 걸 확인 할 수 있다.
* 확장성(Scalable): 다수의 프로세스들이 큐에 메시지를 보낼 수 있다.

Message Queueing은 대용량 데이터를 처리하기 위한 배치 작업이나, 체팅 서비스, 비동기 데이터를 처리할때 사용한다. 프로세스단위로 처리하는 웹 요청이나 일반적인 프로그램을 만들어서 사용하는데 사용자가 많아지거나 데이터가 많아지면 요청에 대한 응답을 기다리는 수가 증가하다가 나중에는 대기 시간이 지연되어서 서비스가 정상적으로 되지 못하는 상황이 오기 때문에 기존에 분산되어 있던 데이터 처리를 한곳으로 집중하면서 메세지 브로커를 두어서 필요한 프로그램에 작업을 분산 시키는 방법을 하고 싶었기 때문이다.

# 메시지 큐 사용처

* 다른 곳의 API로 부터 데이터 송수신 가능.
* 다양한 애플리케이션에서 비 동기 통신을 할 수 있음.
* 이 메일 발송 및 문서 업로드 가능
* 많은 양의 프로세스들을 처리 할 수 있다

# JMS vs AMQP

* AMQP는 [ISO 응용 계층](https://ko.wikipedia.org/wiki/%EC%9D%91%EC%9A%A9_%EA%B3%84%EC%B8%B5)의 MOM 표준이다.
* JMS는 MOM를 자바 에서 지원하는 표준 API 이다. (JMS ≠ AMQP)
* JMS는 다른 자바 애플리케이션들끼리 통신이 가능하지만 다른 MOM의 통신은 불가능하다. (AMQP, SMTP등)
* ActiveMQ의 JMS라이브러리를 사용한 자바 애플리케이션들 끼리 통신이 가능하다 그러나 다른 자바 애플리케이션(ActiveMQ를 사용 안함)의 JMS와는 통신 할 수 없다.
* AMQP는 프로토콜만  맞다만 다른 AMQP를 사용한 애플리케이션 끼리 통신이 가능하다 같은 라인인SMTP 하고도 가능.
* JMS 라이브러리엔 AMQP를 지원하지 않는다.

# 오픈 소스 메시지 큐

RabbitMQ, ActiveMQ, ZeroMQ, Kafka 에 대해 소개 합니다.

## RabbitMQ

* AMQT 프로토콜을 구현 해놓은 프로그램
* 신뢰성 – 안정성과 성능을 충족할 수 있도록 다양한 기능 제공
* 유연한 라우팅 – Message Queue가 도착하기 전에 라우팅 되며 플러그인을 통해 더 복잡한 라우팅 가능
* 클러스터링 – 로컬네트워크에 있는 여러 RabbitMQ 서버를 논리적으로 클러스터링 할 수 있고 논리적인 브로커도 가능 하다. 
* 관리 UI가 있어 편하게 관리 가능하다
* 거의 모든 언어와 운영체제 지원
* 오픈소스이며 상업적  지원

## ActiveMQ

아파치 ActiveMQ 는 풀 자바 메시지 서비스(JMS) 클라이언트와 함께 자바로 만든 오픈소스 메시지 브로커이다.  이 시스템은 “엔터프라이즈 기능” – 이 경우는 하나 이상의  클라이언트와 서버간의 커뮤니케이션을 증진시키는 – 을 제공한다. JMS 1.1 을 통해 자바 뿐만 아니라 다른 “교차언어”를 사용하는  클라이언트를 지원한다.  커뮤니케이션은 컴퓨터 클러스터링및 가상메모리, 캐쉬 그리고 저널 지속성을 제외한 어떤 데이터베이스를 JMS 지속성 제공자로 이용할 수 있는 등의 특징들을 통해 운영된다.

### 주요 특성들

* 다양한 언어 환경의 클라이언트들과 프로토콜을 지원하여, Java, C, C++, C#, Ruby, Perl, Python, 그리고 PHP 클라이언트들을 지원합니다.
* OpenWire를 통해 고성능의 Java, C, C++, C# 클라이언트 지원
* Stomp를 통해 C, Ruby, Perl, Python, PHP 클라이언트가 다른 인기있는 메시지 브로커들과 마찬가지로 ActiveMQ에 접근할 수 있음.
* Message Groups, Virtual Destinations, Wildcards와 Composite Destinations 지원
* JMS 1.1과 J2EE 1.4를 완벽하게 지원하며, transient, persistent, transactional, 그리고 XA 메시징을 지원
* Spring 지원으로 ActiveMQ는 Spring 애플리케이션에 매우 쉽게 임베딩될 수 있으며, Spring의 XML 설정 메커니즘에 의해 쉽게 설정됨.
* Geronimo, JBoss 4, GlassFish, 그리고 WebLogic과 같은 인기있는 J2EE 서버들과 함께 테스트 됨.
    * Inbound와 Outbound 메시징을 위한 JCA 1.5 Resource Adapter를 포함하여 ActiveMQ가 J2EE 1.4 호환 서버에 자동 배치됨.
* In-VM, TCP, SSL, NIO, UDP, Multicast, JGroups, 그리고 JXTA Transport들과 같은 플러그인 가능한 전송 프로토콜들을 지원
* 고성능의 저널을 사용할 때에 JDBC를 사용하여 매우 빠른 Persistence 지원
* 고성능의 클러스터링, 클라이언트-서버, 피어 기반 통신을 지원하기 위한 설계
* REST API를 통해 웹 기반 메시징 API 지원
* 웹 브라우저가 메시징 도구가 될 수 있도록, Ajax를 통해 순수한 DHTML을 사용한 웹 스트리밍 지원
* Axis를 지원하여, ActiveMQ가 Apache Axis 런타임에 쉽게 통합됨.
* In-memory JMS Provider로 사용될 수 있음. 이는 JMS를 사용한 단위 테스트에 적합한 솔루션 제공
* STOMP, AMQP, MQTT, Openwire, SSL, and WebSockets

## ZeroMQ

ZeroMQ는 메시징 라이브러리이다. 그것은 많은 수고를 들이지 않고도 복잡한 커뮤니케이션 시스템을 설계할 수 있도록 해준다. ZeroMQ는 스스로를 효율적으로 설명하기 위해 지금까지 많은 노력을 해왔다. 처음에는 '메시징 미들웨어'로 소개되었지만, 나중에는 '스테로이드를 맞은 TCP' 그리고 이제는 '네트워크 스택의 새로운 레이어'라고 말한다.

ØMQ (ZeroMQ, 0MQ, zmq)는 임베디드 네트워킹 라이브러리 이지만, 동시성 프레임 워크와 같은 역할을 합니다.

이것은 in-process, inter-process, TCP, and multicast 처럼 다양한 방식으로 메시지를 전송하는 소켓을 제공합니다. 당신은 fanout, pub-sub, task distribution, and request-reply와 같은 패턴으로 N-to-N 소켓을 연결할 수 있습니다. 이것은 클러스터 구조에서 충분한 속도를 제공합니다. 비동기 I/O 모델은 비동기 메시지 처리를 제공하는 확장 멀티 코어 애플리케이션을 제공합니다. 이것은 language API를 제공하며 대부분의 운영 체제에서 실행됩니다. ØMQ는 iMatix에서 만들어 졌으며, LGPL 오픈소스 소프트웨어입니다.

### 퍼포먼스

ZeroMQ는 정말 빠르다. 그것은 대부분의 AMQP들 보다 단위가 다를 정도로 빠르다. 이러한 퍼포먼스는 다음과 같은 테크닉들 때문에 가능하다:

* AMQP처럼 과도하게 복잡한 프로토콜이 없다.
* 신뢰성 있는 멀티캐스트나 Y-suite IPC 전송 같은 효율적인 전송을 활용한다.
* 지능적인 메시지 묶음을 활용한다. 이것은 0MQ로 하여금 프로토콜 오버헤드뿐만 아니라 시스템 호출을 줄여서 TCP/IP를 효율적으로 활용하게 한다.

### 단순성

API는 믿을 수 없을 정도로 간단하다. 그렇기에 소켓 버퍼에 계속 '값을 채워' 주어야 하는 생 소켓 방식에 비교하면 메시지를 보내는 것이 정말로 단순하다. ZeroMQ에서는 그냥 비동기 send 호출을 부르기만 하면, 메시지를 별도의 스레드의 큐에 넣고 필요한 모든 일을 해준다. 이러한 비동기 특성이 있기에 당신의 애플리케이션은 메시지가 처리되기를 기다리며 시간 낭비하지 않아도 된다. 0MQ의 비동기 특성은 이벤트 중심의 프레임웍에도 최적이다.

ZeroMQ의 단순한 와이어 프로토콜은 다양한 전송 프로토콜이 사용되는 요즘에 적합하다. AMQP를 쓴다면 그 위에 또 다른 프로토콜 레이어를 쓴다는 것은 좀 이상하게 느껴진다. 0MQ는 메시지를 그냥 Blob으로 보기에 당신이 메시지를 어떻게 인코드하든 상관없다. 단순히 JSON 메시지들을 보내던지, 아니면 BSON, Protocol Buffers나 Thrift 같은 바이너리 방식 메시지들도 괜찮다.

### 확장성

ZeroMQ 소켓들은 저수준처럼 보이지만 사실은 다양한 기능들을 제공한다. 예를 들어 하나의 ZeroMQ 소켓은 복수의 접점을 가질 수 있으며 그들 간에 자동으로 메시지 부하 분산을 수행한다. 또는 하나의 소켓으로 복수의 소스에서 메시지들을 받아들이는 게이트 역할을 할 수도 있다.

## Kafka

* 대용량의 실시간 로그 처리에 특화되어 설계된 메시징 시스템으로써 기존 범용 메시징 시스템대비 TPS가 매우 우수하다. 단, 특화된 시스템이기 때문에 범용 메시징 시스템에서 제공하는 다양한 기능들은 제공되지 않는다.  
     
* 분산 시스템을 기본으로 설계되었기 때문에, 기존 메시징 시스템에 비해 분산 및 복제 구성을 손쉽게 할 수 있다.
* AMQP 프로토콜이나 JMS API를 사용하지 않고 단순한 메시지 헤더를 지닌 TCP기반의 프로토콜을 사용하여 프로토콜에 의한 오버헤드를 감소시켰다.
* Producer가 broker에게 다수의 메시지를 전송할 때 각 메시지를 개별적으로 전송해야하는 기존 메시징 시스템과는 달리, 다수의 메시지를 batch형태로 broker에게 한 번에 전달할 수 있어 TCP/IP 라운드트립 횟수를 줄일 수 있다.
* 메시지를 기본적으로 메모리에 저장하는 기존 메시징 시스템과는 달리 메시지를 파일 시스템에 저장한다.
* 파일 시스템에 메시지를 저장하기 때문에 별도의 설정을 하지 않아도 데이터의 영속성(durability)이 보장된다.
* 기존 메시징 시스템에서는 처리되지 않고 남아있는 메시지의 수가 많을 수록 시스템의 성능이 크게 감소하였으나, Kafka에서는 메시지를 파일 시스템에 저장하기 때문에 메시지를 많이 쌓아두어도 성능이 크게 감소하지 않는다. 또한 많은 메시지를 쌓아둘 수 있기 때문에, 실시간 처리뿐만 아니라 주기적인 batch작업에 사용할 데이터를 쌓아두는 용도로도 사용할 수 있다.
* Consumer에 의해 처리된 메시지(acknowledged message)를 곧바로 삭제하는 기존 메시징 시스템과는 달리 처리된 메시지를 삭제하지 않고 파일 시스템에 그대로 두었다가 설정된 수명이 지나면 삭제한다. 처리된 메시지를 일정 기간동안 삭제하지 않기 때문에 메시지 처리 도중 문제가 발생하였거나 처리 로직이 변경되었을 경우 consumer가 메시지를 처음부터 다시 처리(rewind)하도록 할 수 있다.
* 기존의 메시징 시스템에서는 broker가 consumer에게 메시지를 push해 주는 방식인데 반해, Kafka는 consumer가 broker로부터 직접 메시지를 가지고 가는 pull 방식으로 동작한다. 따라서 consumer는 자신의 처리능력만큼의 메시지만 broker로부터 가져오기 때문에 최적의 성능을 낼 수 있다.
* 기존의 push 방식의 메시징 시스템에서는 broker가 직접 각 consumer가 어떤 메시지를 처리해야 하는지 계산하고 어떤 메시지를 처리 중인지 트랙킹하였는데, Kafka에서는 consumer가 직접 필요한 메시지를 broker로부터 pull하므로 broker의 consumer와 메시지 관리에 대한 부담이 경감되었다.
* 메시지를 pull 방식으로 가져오므로, 메시지를 쌓아두었다가 주기적으로 처리하는 batch consumer의 구현이 가능하다.

큐의 기능은 기존의 JMS나 AMQP 기반의 RabbitMQ(데이타 기반 라우팅,페데레이션 기능등)등에 비해서는 많이 부족하지만 대용량 메세지를 지원할 수 있는 것이 가장 큰 특징이다. 특히 분산 환경에서 용량 뿐 아니라, 복사본을 다른 노드에 저장함으로써 노드 장애에 대한 장애 대응 성을 가지고 있기 때문에 용량에는 확실하게 강점

마이크로소프트 社의 엔지니어가 쓴 논문을 보면

[http://research.microsoft.com/en-us/um/people/srikanth/netdb11/netdb11papers/netdb11-final12.pdf](http://research.microsoft.com/en-us/um/people/srikanth/netdb11/netdb11papers/netdb11-final12.pdf)

Producer 성능

![http://cfile27.uf.tistory.com/image/23441B445509177A1F0983](https://lh4.googleusercontent.com/_u9w3kXY58i7MK6rU1ZfaWecYs6iG6SmHehMPu3hwJEwgh--x0FF3PFHCaE8S3ByTHSDpcv-x57wW-aWvAap44o1RLDwiZBApL3VLBxkWNAB-vm10zCdckeLflxKpDVtobPHzoeNO7i6XEHLrw)

(이미지 출처: [Kafka: A distributed messaging system for log processing](http://research.microsoft.com/en-us/UM/people/srikanth/netdb11/netdb11papers/netdb11-final12.pdf))

붉은 색 그래프는 메시지를 한 번에 50개씩 batch로 전송한 결과이고 연두색 그래프는 한 번에 하나씩 전송한 결과이다.

Consumer 성능

![http://cfile21.uf.tistory.com/image/217D7945550917BD0BA936](https://lh6.googleusercontent.com/d-U177PdyTqOjZgItbKdGjKpZ2FfFXI8ivNPf8qPCH0OFR7nLEBoFaeNjGn_47z3RznqTIywB4lEUAzD8z2PculfJ7UUcErDWSYqaKe7BxCMVCMIuMyqmRayWZmdlbY2o2kE6DzJsvtonlrizg)

(이미지 출처: [Kafka: A distributed messaging system for log processing](http://research.microsoft.com/en-us/UM/people/srikanth/netdb11/netdb11papers/netdb11-final12.pdf))

카프카의 경우 10만 TPS 이상의 성능을 RabbitMQ는 2만 TPS 정도의 성능을 내는 것으로 나와 있는데, 여기서 생각해볼 문제가 큐는 비동기 처리 솔루션이다. 즉 응답 시간에 그렇게 민감 하지 않다는 것이다.

그리고 일반적인 웹 시스템의 성능이 1500~2000 TPS (엔터프라이즈 시스템의 경우) 내외인 것이 일반적이기 때문에, Rabbit MQ의 2만 TPS의 성능은 충분하다고 볼 수 있지 않을까 한다.

# 결론

대용량 CEP 엔진에서는 kafka를 사용해서 처리하고 그이외에 자잘한 메시지큐 같은경우는 다양한 기능이 있는 ActiveMQ를 사용 하는것이 좋을거 같다.

# ※ 추가 내용

Spring에서는 [Spring AMQP](http://projects.spring.io/spring-amqp/) 가 서브프로젝트로 존재 하며 기본 예제는 RabbitMQ로 되어 있습니다.

최근에 AMQP는 아니지만 빠른 속도를 내세우며 엄청난 인기몰이를 하는 Kafka가 있는데 Spring 서브프로젝트 [Spring Kafka](http://projects.spring.io/spring-kafka/)도 있어서 빠른 메시징 큐를 사용시에 활용 할수 있을거 같습니다.

![](https://lh4.googleusercontent.com/PyDBoFLpk5EyVtermWrJ7OCsYCggb7yKqVKJuHo__VUTLqb7uQI0GFYxM1wKWwsJLMqsfNNXoAFEbIgw-Y9wpO9miQnhA5-I34AGH9Da6iSARuz9nhJ10fhXQHy9pJ3kepv3d6eY)

[https://trends.google.com/trends/explore?q=%2Fm%2F0zmynvd,%2Fm%2F0264f96,%2Fm%2F0bhc0tk](https://trends.google.com/trends/explore?q=%2Fm%2F0zmynvd,%2Fm%2F0264f96,%2Fm%2F0bhc0tk)

2017년 4월 27일 검색 기준으로 구글 트렌드 검색결과 1위 Kafka이며 2위 RabbitMQ, 3위 ActiveMQ는 입니다.

Kafka의 인기몰이 중 하나는 메시징 전송시에 헤더의 크기가 작아 오버헤드를 감소시키며

기존의 메시징 시스템에서는 broker가 consumer에게 메시지를 push해 주는 방식인데 반해, Kafka는 consumer가 broker로부터 직접 메시지를 가지고 가는 pull 방식으로 동작한다. 따라서 consumer는 자신의 처리능력만큼의 메시지만 broker로부터 가져오기 때문에 최적의 성능을 낼 수 있다.

각각의 오픈 소스 메시징 큐 의 지원 프로토콜과 지원하는 클라이언트 이다.

![](https://lh6.googleusercontent.com/jCrIYNCt8flWhMEchZCAq56fIUt4MYbcwPvuxule9pRuWq0FY2PedH2Qj1j3GoSHG-F9shMXJfLML2dT22iC3JiayITcYuSUaso5BqHE07o1SPcvvXfR9ZlhoWsvAi9Mb5zxYYQq)

![](https://lh3.googleusercontent.com/5GLU1dXLizd58-92X3ADx6tKUps--87h7mF7dpvbIJ8DDZtMqVrWPyygRiX6tkaejb0-uLJYvtGHyl96yXt-qI4lxOPZ4s848_cdo-2yuB27mzcnIKrWs02zW2IL84Msvc9zJLmc)

  
 

출처

* [https://docs.oracle.com/cd/E19148-01/820-0532/6nc919fag/index.html](https://docs.oracle.com/cd/E19148-01/820-0532/6nc919fag/index.html)
* [https://docs.microsoft.com/ko-kr/azure/service-bus-messaging/service-bus-amqp-overview](https://docs.microsoft.com/ko-kr/azure/service-bus-messaging/service-bus-amqp-overview)
* [https://www.predic8.com/activemq-hornetq-rabbitmq-apollo-qpid-comparison.htm](https://www.predic8.com/activemq-hornetq-rabbitmq-apollo-qpid-comparison.htm)
* [http://projects.spring.io/spring-amqp/](http://projects.spring.io/spring-amqp/)
* [https://dzone.com/articles/jms-vs-rabbitmq](https://dzone.com/articles/jms-vs-rabbitmq)
