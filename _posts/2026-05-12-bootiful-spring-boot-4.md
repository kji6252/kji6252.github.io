---
title: "Bootiful Spring Boot 4 — Spring I/O 2026 발표 정리"
layout: post
date: 2026-05-12 11:30:00
categories:
  - Spring
tags:
  - Spring Boot 4
  - Spring Framework 7
  - Spring Security 7
  - Java 25
  - Spring I/O 2026
---

> Josh Long이 Spring I/O 2026(Barcelona)에서 **Spring Boot 4 + Spring Framework 7 + Spring Security 7**의 핵심 기능을 42분간 라이브 코딩으로 시연한 발표. 개발자가 **더 적은 코드로 더 많은 것**을 할 수 있게 된 Spring의 새로운 시대.
{: .prompt-info }

---

## 🐕 도입: Prancer 이야기와 Spring Initializr

발표는 'Prancer'라는 악마 같은 치와와의 실화로 시작한다. 주인이 쓴 입양 공고가 바이럴이 되어 NYT, BuzzFeed까지 보도한 이야기.

> "신경증적이고, 남자를 싫어하고, 동물을 싫어하고, 아이를 싫어하며, 그렘린처럼 생긴 개의 시장은 그리 크지 않습니다."

Josh Long은 Prancer에서 영감을 받아 **강아지 입양 서비스**를 라이브로 만들기로 한다. Spring Initializr에서 프로젝트를 생성하며 Spring Boot 4와 Spring Framework 7을 선택.

![Prancer the Demonic Chihuahua]({{ site.baseurl }}/images/spring-io-bootiful/slide_02_prancer.jpg){: .shadow}

---

## 🧩 Auto-configuration 분해

Spring Boot 4의 핵심 변화: **거대한 단일 auto-configuration이 각 starter별로 분해**되었다.

- 각 starter가 자체 auto-configuration을 가짐 → 사용하지 않는 starter의 코드가 클래스패스에 포함되지 않음
- **시작 시간 단축** 및 메모리 절감
- **세분화된 starters**: `spring-boot-starter-web`이 web server + HTTP client로 분리
  - Spring Batch, Spring Shell, Spring Integration 같은 **headless 앱**은 web server 없이 HTTP client만 사용 가능

![Auto-configuration 분해]({{ site.baseurl }}/images/spring-io-bootiful/slide_04_autoconfig.jpg){: .shadow}

---

## ☕ Java 25: "수학적으로도 우월"

Josh Long의 Java 버전 철학:

> "Java에는 네 가지 버전이 있지만, **유효한 선택은 단 두 개**뿐입니다. 나머지 두 개는 끔창한 삶의 선택을 하는 사람을 확인용으로만 둡니다."

Java 25은 기술적으로 빠르고, 견고하고, 문법이 풍부하며, 운영 친화적. 그리고 "Java 8의 최소 3배"이므로 수학적으로도 우월하다.

![Java 25]({{ site.baseurl }}/images/spring-io-bootiful/slide_05_java25.jpg){: .shadow}

---

## 💾 Spring Data JDBC: Java Records + AOT

Java Records로 엔티티를 정의하고 `CrudRepository`를 상속만 하면 끝.

```java
public record Dog(@Id int id, String description) {}

public interface DogRepository extends CrudRepository<Dog, Integer> {
    Collection<Dog> findByName(String name);
}
```

Spring Boot 4에서는 **compile-time code generation**이 Repository의 구체적인 구현체를 생성. 생성된 코드에 breakpoint를 걸고 디버깅도 가능하며, Spring Data가 쿼리를 어떻 변환하는지 직접 확인할 수 있다.

![Spring Data JDBC]({{ site.baseurl }}/images/spring-io-bootiful/slide_06_entities.jpg){: .shadow}

---

## 🛡️ API Versioning (Spring Framework 7)

Spring Framework 7에 **내장된 API 버전 관리**. 외부 라이브러리 불필요.

```java
@GetMapping(value = "/dogs", headers = "X-Dogs-Version=1.0")
@VersionRange(from = "1.0")
Collection<Map<String, Object>> dogsV1() { ... }

@GetMapping(value = "/dogs")
@VersionRange(from = "1.1", defaultVersion = true)
Collection<Dog> dogsV2() { ... }
```

Header, media type, path segment, query parameter로 버전 지정 가능.

![API Versioning]({{ site.baseurl }}/images/spring-io-bootiful/slide_07_versioning.jpg){: .shadow}

---

## 📞 Declarative HTTP Services: `@ImportHttpServices`

3rd party API 호출을 위한 보일러플레이트가 완전히 사라졌다.

```java
@GetExchange("/api")
CatFacts facts();

// 설정 한 줄로 끝
@ImportHttpServices(CatFactsClient.class)
```

Spring Framework 6에서는 설정이 필요했지만, **Spring Framework 7에서는 `@ImportHttpServices` 한 줄**로 끝.

![Declarative HTTP Services]({{ site.baseurl }}/images/spring-io-bootiful/slide_08_declarative_client.jpg){: .shadow}

---

## 💪 Resilience: `@Retryable` + Concurrency Limits

> "작년에 AWS US-East-1이 다운되면서 인터넷 절반이 죽었습니다. **지구에서 가장 잘 운영되는 데이터센터**인데도 말이죠."

`@EnableResilientMethods`를 활성화하면:

- **`@Retryable`**: maxRetries, exponential backoff, 예외 타입 필터링
- **Concurrency Limits**: semaphore 기반으로 downstream 서비스 보호

```java
@Retryable(maxRetries = 5, include = IllegalStateException.class)
@ConcurrencyLimit(10)
public CatFacts facts() { ... }
```

![Resilience]({{ site.baseurl }}/images/spring-io-bootiful/slide_09_resilience.jpg){: .shadow}

---

## ⚙️ Meta-annotations & BeanRegistrar

**모든 것은 `@Component`**: `@Controller`, `@Service`, `@Repository`, `@Configuration` 모두 `@Component`의 meta-annotation. 커스텀 annotation도 쉽게 만들 수 있다.

새로운 **`BeanRegistrar`** 인터페이스로 프로그래밍 방식 빈 등록:

```java
class MyRegistrar implements BeanRegistrar {
    void register(BeanRegistry registry) {
        for (int i = 0; i < 5; i++) {
            registry.registerBean(MyRunner.class,
                spec -> spec.supplier(() -> new MyRunner("hello " + i)));
        }
    }
}
```

`for` 루프로 동적으로 여러 빈을 등록할 수도 있고, 생성자도 제어 가능.

![BeanRegistrar]({{ site.baseurl }}/images/spring-io-bootiful/slide_12_bean_registrar.jpg){: .shadow}

---

## 🔒 Spring Security 7: 보안의 패러다임 전환

### Customizer: Additive 보안 설정

Spring Security 6까지는 `SecurityFilterChain` Bean을 하나만 만들어도 Spring Boot의 기본 보안 설정이 **전부 사라졌다**. HTTP Basic, Form Login, endpoint 보호 — defaults가 싹 날아감.

Spring Security 7에서는 **`Customizer` API**로 기본값을 유지하면서 필요한 기능만 추가(additive)한다:

```java
@Bean
SecurityFilterChain chain(HttpSecurity http) throws Exception {
    http.customizer(c -> c
        .oneTimeTokenLogin(ott -> ott.tokenEndpoint("/login/ott"))
    );
    return http.build();
}
```

> "보안에 정통하다면 괜찮지만, 전혀 보호되지 않는 상태로 시작하는 것은 좋은 security posture가 아닙니다." — Josh Long

### Password Migration

기존 사용자의 SHA-256 비밀번호를 **로그인 시 자동으로 BCrypt로 마이그레이션**. 평문 비밀번호가 메모리에 있는 순간을 활용.

![Password Migration]({{ site.baseurl }}/images/spring-io-bootiful/slide_14_password_migration.jpg){: .shadow}

### One-Time Token (OTT)

Slack처럼 이메일 링크 하나로 로그인. **내가 관리할 비밀번호가 없다** — Google이나 Outlook이 대신 관리.

### WebAuthn / Passkeys

> "Amazon, Apple, Google, Microsoft, Meta, PayPal... 이 모든 곳에서 **이미 작동**합니다."

공개키 암호화 기반. Touch ID, Face ID, Apple Watch 모두 같은 키. OS가 관리하므로 비밀번호 자체가 사라진다.

![WebAuthn / Passkeys]({{ site.baseurl }}/images/spring-io-bootiful/slide_16_webauthn.jpg){: .shadow}

### Multi-Factor Authentication

`@EnableMultiFactor`로 password + OTT 조합 인증을 간단히 설정.

![Multi-Factor Auth]({{ site.baseurl }}/images/spring-io-bootiful/slide_17_mfa.jpg){: .shadow}

### JdbcUserDetailsManager

DB 기반 사용자 관리는 `JdbcUserDetailsManager` 빈 하나로 끝:

```java
@Bean
UserDetailsManager users(DataSource ds) {
    return new JdbcUserDetailsManager(ds);
}
```

기존 `users`, `authorities` 테이블 스키마와 연동되며, Password Migration과 함께 쓰면 레거시 사용자의 비밀번호가 로그인 시 자동으로 안전한 해시로 마이그레이션된다.

![One-Time Token]({{ site.baseurl }}/images/spring-io-bootiful/slide_15_ott.jpg){: .shadow}

---

## 🧬 Spring Framework 7: API 설계 철학

### `@NonNullApi` 기본

`org.springframework.beans.factory` 패키지 전체가 `@NonNullApi`로 선언되어 있다. 모든 파라미터와 반환값이 기본적으로 non-null.

```java
// 패키지-info.java
@NonNullApi
package org.springframework.beans.factory;
```

- null 허용이 필요한 경우 명시적 opt-in (`@Nullable`)
- IDE에서 null safety 경고 자동 제공
- `BeanRegistrar`의 `register()` 메서드 등이 이 패키지에 위치

Spring Framework 7의 API 설계 철학: **null을 기본으로 금지**하여 NPE를 컴파일 타임에 방어.

---

## ⚡ AOT & Project Leyden

Spring의 AOT 서브시스템이 **Project Leyden**과 연동:

1. 애플리케이션을 컴파일 + AOT 처리
2. 시작 직전의 상태를 "사진"으로 캡처
3. 캡처된 상태로 빠른 시작

Spring Data Repository의 `findByName()` 메서드가 **compile-time에 실제 Java 코드로 생성**되는 것을 직접 확인할 수 있다.

![AOT Code Generation]({{ site.baseurl }}/images/spring-io-bootiful/slide_19_codegen.jpg){: .shadow}

---

## 👋 마무리

42분 동안 Spring Boot 4 하나로 구축한 것:
- **Auto-configuration 분해** → 가벼운 시작
- **API Versioning** → 내장 지원
- **Declarative HTTP** → 보일러플레이트 제로
- **Resilience** → `@Retryable` 한 줄
- **Spring Security 7** → OTT, Passkeys, MFA
- **AOT + Leyden** → compile-time code generation

더 적은 코드로 더 많은 것을. 이것이 Bootiful Spring Boot 4.

![Closing]({{ site.baseurl }}/images/spring-io-bootiful/slide_20_closing.jpg){: .shadow}

---

*원본 영상: [Bootiful Spring Boot 4 by Josh Long @ Spring I/O 2026](https://www.youtube.com/watch?v=6zfuCPQzrwE)*
