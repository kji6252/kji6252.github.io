---
title: java data access
layout: post
date: 2017-07-06 10:39:00
categories:
  - 자바
tags:
  - Java
  - Spring
  - DB
---
# JDBC

자바에서 데이터베이스에 접속 할수 있는 API를 제공하는데 그게 [ JDBC(Java Database Connectivity)](https://ko.wikipedia.org/wiki/JDBC) 입니다.
![JDBC흐름도](https://lh6.googleusercontent.com/0YTTqDJ6t6cUvCIh2DsCCptnyvx-0N7NuaM560euJStFCwRbaHvQhQ2KgNiohS0rID21jJ6Kppfjp0_bM_MqqMsp7ItnkiwEcGAy3W6480MJlbD20GkOEbLWgyI4GyuPZmYiCPrR)
<!-- more -->

# 자바 JDBC와 DB벤더들
아래 표는 JDBC를 사용시의 불편함점 개선과 기능추가가된 라이브러리 및 프레임워크들 이다.

| 자바 | 스프링
---|---|---
JDBC | [Plane JDBC](https://docs.oracle.com/javase/8/docs/technotes/guides/jdbc/) | [Spring JDBC](https://docs.spring.io/spring/docs/current/spring-framework-reference/html/jdbc.html)
| [Mybatis](http://www.mybatis.org/mybatis-3/ko/) | [Mybatis-Spring](http://www.mybatis.org/spring/)
| [Apache commons DbUtils](http://commons.apache.org/proper/commons-dbutils/) | 　
| [sql2o](https://github.com/aaberg/sql2o) | 　
| [JDBI](http://jdbi.org/) | 　
| [ORMLite](http://ormlite.com/) | 　
JPA(ORM) | [Plane JPA](http://www.oracle.com/technetwork/java/javaee/tech/persistence-jsp-140049.html) | [Spring Data JPA](http://projects.spring.io/spring-data-jpa/)
JPA provider | [Hibernate](http://hibernate.org/), [EclipseLink](http://eclipse.org/eclipselink/), [TopLink](http://www.oracle.com/technetwork/middleware/toplink/overview/index-089172.html) | 　
| [JDO](https://db.apache.org/jdo/index.html) | 　
TpyeSafe Builder | [jOOQ](https://www.jooq.org/) , [QueryDSL](http://www.querydsl.com/) | 　

# JDBC API

JDBC API는 Java에서 가장 로우레벨의 데이터베이스 API 입니다. 그래서 SQL을 실행하는 데도 매우 번잡한 코드가 필요하고 DB에 따라 일관성없는 예외체크를 해야 하며 SQL은 코드 내에서 문자로 제공해야 하는 불편을 감수해야 한다. 커넥션과 같은 공유 리소스를 제대로 처리하지 않으면 시스템의 자원이 바닥나는 심각한 버그를 심어놓을 수도 있다.

# MyBatis

MyBatis는  first class persistence framework with support라고 소개 되어 있는데 말그대로 클래스 중심으로 프로그램을 개발 할 수 있게 도움을 준다는 프레임워크 지원 하는 기능은 커스텀SQL, 스토어프로시저, 고급매핑을 지원한다.

어떤곳에서는 ORM매퍼 라고 하는데 공식홈페이지를 가보면 ORM이라는 단어는 없고 first class persistence framework 가 맞는거 같다.

[http://blog.mybatis.org/p/products.html](http://blog.mybatis.org/p/products.html)

들어가면 마이바티스부터 시작해서 코드자동생성 제너레이터, 이클립스개발시 도움을 주는 플러그인, 스칼라버전 마이바티스, 닷넷버전 마이바티스 등등 JDBC를 직접 사용하는것 보다 편의 기능이나 각종 툴이 제공되어서 생산성을 높일수 있다.

# JPA(ORM)

JPA(Java Persistence API)는 관계형 [데이터베이스](https://ko.wikipedia.org/wiki/%EB%8D%B0%EC%9D%B4%ED%84%B0%EB%B2%A0%EC%9D%B4%EC%8A%A4)에 접근하기 위한 표준 [ORM](https://ko.wikipedia.org/wiki/ORM) 기술을 제공 한다.

2006년 java 1.5버전 이상부터  JPA1.0이 정의 되었으며 현재버전은 2013년에 정의된 JPA2.1버전이 최신이다.

JPA는 구현체를 함께 사용해야 하는데 주로 사용되는 구현체의 점유율은 이러하다.

![JPA구현체트랜드차트](https://lh4.googleusercontent.com/eSdG9B0TsjMhv0Ab3_3JmMhiv2DUUseC7dR2ey7k8JSPfP189DDSOklZGqWlRmSmAZSQUPzsOzVb-U0OEOmy3br_lmLz99D_iEX-ku0mq-aBdPvCJRmrFY5gaNPMJajoHR93j8xI)

# Spring

## Spring JDBCTemplate

spring 에서는 jdbc를 확장해서 만든 jdbcTemplate을 이용하여 데이터베이스에 접근을 합니다.

jdbcTemplate은 JDBC API를 가지고 템플릿콜백패턴을 통해 간결함과 리소스 처리를 함으로써 비즈니스로직에 집중할수 있게 하였고 데이터베이스마다 다른 exception핸들링을 통하여 데이터베이스 예외처리를 획일화 하였습니다.

![익셉션구성도](https://lh6.googleusercontent.com/X1A8cV7QO_Jl7L7VyIKUpQ0Q_LaJz5mjUg4utCSNwKf0vmnraNppOXlKpVjzPfRKjACu4EfK-zaUOqfxg2tzu6ZLAE6ExYt9J3VeR7kxPUHqob9a6WBo06HFU5m8Uh-7JxbE8R4_)

스프링 SQLException 핸들링

## Spring Data와 서브 프로젝트들

![스프링데이타프로젝트들](https://lh5.googleusercontent.com/yI5316iTK5dqoF-ofsDIjtDd1-ea6hbOrjmYYFMnRdjAwm9ul8XYfDiAX7AwyuJnCeVGT20TucmuEm1DJwPqPFvBWMcRzucsz3Dp101CdE39ZDLtEyv0Z8Ba_sy3WmYwm9t8oePx)

spring data 는 JDBC뿐만 아니라 JPA와 각각의 클라이언트를 제공하던 NoSQL들도 제공 함으로써 Spring에서 가장 대표적으로 사용하는 Dao Access 프레임워크가 되었습니다.

Repositories, Templates, Object Mapping과 트랜잭션동시지원, 간편한 설정등의 기능을 더하고 확장 하였습니다.

spring data 서브프로젝트 중에서는 Repository만 구현해도 자동으로 CRUD및 Paging, sort 기능을 자동으로 생성되는 프로젝트들도 있습니다.

spring data의 기능은 Repository에 crud, paging, sort 기능을 함유 커스텀 Repository 하고 있고 각종 유틸과 QueryDSL에 관련된 서포트툴이 있어

QueryDSL의 TypeSafe한 쿼리문을 작성하기에 용이 합니다.

  
 

# TpyeSafe Builder

## QueryDSL

[QueryDSL](http://www.querydsl.com/static/querydsl/4.0.1/reference/ko-KR/html_single/)은 정적 타입을 이용해서 SQL과 같은 쿼리를 생성할 수 있는 프레임워크다. 문자열이나 XML에 쿼리를 작성하는 대신 QueryDSL이 제공하는 플루언트(Fluent) API를 이용해서 쿼리를 생성할 수 있다.

* IDE의 코드 자동 완성 기능 사용
* 컴파일 시점에서 잘못된 쿼리를 허용하지 않음
* 도메인 타입과 프로퍼티를 안전하게 참조할 수 있음
* 도메인 타입의 리팩토링을 더 잘 할 수 있음

## jOOQ

처음엔 JPA를 공부할때는 QueryDSL을 먼저 알았지만 타입세이프빌더쪽에서는 jOOQ가 더 오래된걸 알게 되었습니다. 아무래도 유료이다 보니 QueryDSL보다 덜 활성화 된게 아닐까 싶습니다. jOOQ의 장점은 돈을 내고 지원을 받을수 있다는 점인거 같습니다.

흥미로운건 jOO로 시작하는 프로젝트들인

* [jOOX](https://github.com/jOOQ/jOOX) : jquery 문법을 자바에서 사용가능하게 해줌
* [jOOR](https://github.com/jOOQ/jOOR) : 자바 리플렉션 랩퍼 라이브러리
* [jOOL](https://github.com/jOOQ/jOOL) : 자바에 람다 기능 보강(?)
* [jOOU](https://github.com/jOOQ/jOOU) : unsigned 타입을 지원

등 재미 있는 프로젝트들이 있어서 뭔가 새로운걸 도전하는 팀같아서 좋게 보였습니다.

작성 하다보니 쓸모 있는 내용이 없어서 죄송합니다. 안바쁠때 예제와 함께 올릴예정이였지만 이직과 이리저리 많은일이 있어서 간단하게 나마 남겨 봅니다.
