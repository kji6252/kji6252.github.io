---
title: 종인의 기술 블로그
layout: default
nav_order: 1
---

# 종인의 기술 블로그

안녕하세요! 종인의 기술 블로그에 오신 것을 환영합니다.

## 소개

Java, Spring, JavaScript 등 다양한 기술을 다루는 개발 블로그입니다.

## 최근 포스트

최근 포스트는 왼쪽 사이드바의 **블로그 포스트** 섹션에서 확인하실 수 있습니다.

### 주제

- Java
- Spring Boot
- JPA/Hibernate
- JavaScript
- 개발 도구 및 팁

---

{% for post in site.posts limit:5 %}
### [{{ post.title }}]({{ post.url }})
{{ post.date | date: "%Y-%m-%d" }}

{% endfor %}
