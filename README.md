# 종인의 기술 블로그

Jekyll + Just the Docs 테마로 구성된 GitHub Pages 블로그입니다.

## 주제

- Java
- Spring Boot
- JPA/Hibernate
- JavaScript
- 개발 도구 및 팁

## 로컬에서 실행하기

### 1. Ruby 설치

이 프로젝트를 실행하려면 Ruby가 필요합니다.

```bash
# macOS (Homebrew)
brew install ruby

# Ubuntu/Debian
sudo apt-get install ruby-full

# Windows
# RubyInstaller 다운로드: https://rubyinstaller.org/
```

### 2. Bundler 설치

```bash
gem install bundler
```

### 3. 의존성 설치

```bash
bundle install
```

### 4. Jekyll 서버 실행

```bash
bundle exec jekyll serve
```

브라우저에서 `http://localhost:4000`으로 접속하세요.

## 새 포스트 작성

`_posts` 디렉토리에 `YYYY-MM-DD-title.md` 형식으로 파일을 생성하세요.

```yaml
---
title: 포스트 제목
layout: post
date: YYYY-MM-DD HH:MM:SS
tags:
  - 태그1
  - 태그2
categories:
  - 카테고리
---

포스트 내용...
```

## 테마

이 블로그는 [Just the Docs](https://just-the-docs.github.io/just-the-docs/) 테마를 사용합니다.

## 라이선스

MIT License
