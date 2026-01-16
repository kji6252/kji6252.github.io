---
title: Spring Boot + Spring Cloud 를 경험 하자
layout: post
date: 2020-06-06 14:00:00
categories: Spring
tags: Java, Spring, Spring Boot, Spring Cloud
---

# Spring Boot + Spring Cloud 를 경험 하자

Spring 에서 제공 해주는 MSA 환경 구축 가이드를 경험하여 실력을 향상해 보자!

[https://spring.io/guides](https://spring.io/guides)

![Untitled](https://user-images.githubusercontent.com/6037055/113374794-efafd980-93a8-11eb-903d-1ff96a90627c.png)
<!-- more -->
**[Service Registration and Discovery](https://spring.io/guides/gs/service-registration-and-discovery/)**

Learn how to register and find services with Eureka

**[Centralized Configuration](https://spring.io/guides/gs/centralized-configuration/)**

Learn how to manage application settings from an external, centralized source

**[Routing and Filtering](https://spring.io/guides/gs/routing-and-filtering/)**

Learn how to route and filter requests to a microservice using Netflix Zuul

**[Circuit Breaker](https://spring.io/guides/gs/circuit-breaker/)**

Learn how to degrade gracefully services using Hystrix

**[Client Side Load Balancing with Ribbon and Spring Cloud](https://spring.io/guides/gs/client-side-load-balancing/)**

Dynamically support services coming up and going down without interrupting the client

5가지 가이드를 학습하여 차례대로 Spring Cloud를 경험해 보자

![Untitled 1](https://user-images.githubusercontent.com/6037055/113374792-ede61600-93a8-11eb-9c09-c3bd008b774d.png)

스프링에서 제공하는 가이드를 학습하면서 github에 commit별로 정리 하였습니다.

학습하다가 막힐 경우 commit내역을 참고 하면서 학습 하시길 바랍니다.

각 단계를 실시한 후 확인하기 위해 http/check-config.http로 확인 하였습니다.

[https://github.com/kji6252/study-spring-cloud](https://github.com/kji6252/study-spring-cloud)

# 1.**[Service Registration and Discovery](https://spring.io/guides/gs/service-registration-and-discovery/)**

가이드대로 진행 한 후 eureka baseurl을 넣어 대비하는게 좋을거 같다

```yaml
#discovery client의 application.yml에 추가
eureka:
  client:
    serviceUrl:
      defaultZone: http://localhost:8761/eureka/
```

# 2.**[Centralized Configuration](https://spring.io/guides/gs/centralized-configuration/)**

Eureka Server와 충돌을 피하기 위해 `spring.cloud.config.server.prefix=/config`를 추가

```
spring.cloud.config.server.prefix=/config
```

```
# study-springboot-eureka/config/example-app.properties 에 추가 한 뒤
# cd study-springboot-eureka/config/
# git init && git add. && git commit 하기

message=Remote Config!
```

# 3.**[Routing and Filtering](https://spring.io/guides/gs/routing-and-filtering/)**

# 4.**[Circuit Breaker](https://spring.io/guides/gs/circuit-breaker/)**

study-springboot-discoveryclient를 stop 한 후에 실행하면 hystrixcommand에 명시된 fallback을 실행

# 5.**[Client Side Load Balancing with Ribbon and Spring Cloud](https://spring.io/guides/gs/client-side-load-balancing/)**

ribbon은 더이상 관리하지 않으므로 Spring Cloud Load Balancer로 예제가 바뀜

[https://spring.io/guides/gs/spring-cloud-loadbalancer/](https://spring.io/guides/gs/spring-cloud-loadbalancer/)

eureka와 통합하여 service discovery부분을 생략함
