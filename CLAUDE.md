# Claude Code Project Context

이 문서는 Claude Code가 이 Jekyll 블로그 프로젝트를 관리하는 데 필요한 핵심 정보를 담고 있습니다.

## 필수 명령어

### 개발 서버 실행
```bash
# Ruby 3.3.0 환경 설정
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# 의존성 설치
bundle install

# 로컬 서버 실행 (http://localhost:4000)
bundle exec jekyll serve
```

### 빌드 및 확인
```bash
# 사이트 빌드
bundle exec jekyll build

# 캐시 삭제 후 빌드 (문제 발생 시)
rm -rf _site .jekyll-cache
bundle exec jekyll build
```

## 프로젝트 아키텍처

### Jekyll + Just the Docs 테마
- **정적 사이트 생성기**: Jekyll v3.10.0
- **테마**: Just the Docs v0.9 (https://github.com/just-the-docs/just-the-docs)
- **마크다운 프로세서**: Kramdown
- **Ruby 버전**: 3.3.0 (rbenv 관리)

### 컬렉션 구조

이 프로젝트는 두 개의 컬렉션을 사용합니다:

#### 1. posts (블로그 포스트)
- **경로**: `_posts/`
- **URL 형식**: `/:categories/:title/`
- **파일명 형식**: `YYYY-MM-DD-title.md`

#### 2. docs (문서)
- **경로**: `docs/`
- **URL 형식**: `/:collection/:path/`
- **외부 심볼릭 링크**: `docs/Claude-Obsidian-Guide` → `/Users/jonginkim/Documents/mynote/Guides/Claude-Obsidian-Guide`

## Just the Docs 네비게이션 설정

사이드바 네비게이션을 위한 필수 Front Matter 속성:

### 상위 페이지 (index.md)
```yaml
---
title: "페이지 제목"
has_children: true
nav_order: 1
---
```

### 자식 페이지
```yaml
---
title: "자식 페이지 제목"
parent: 페이지 제목  # 부모의 title과 정확히 일치해야 함
nav_order: 1
---
```

**중요**: `parent` 속성값은 부모 페이지의 `title`과 정확히 일치해야 네비게이션이 작동합니다.

## 포스트 작성 가이드

### 필수 Front Matter
```yaml
---
title: 포스트 제목
layout: post
date: YYYY-MM-DD HH:MM:SS
tags:
  - 태그1
categories:
  - 카테고리
---
```

### 포스트 명명 규칙
- 형식: `YYYY-MM-DD-title.md`
- 예시: `2024-01-15-jpa-basic-01.md`

## 설정 파일

### _config.yml 주요 설정

```yaml
# 컬렉션
collections:
  posts:
    permalink: /:categories/:title/
    output: true
  docs:
    permalink: /:collection/:path/
    output: true

# 기본 레이아웃
defaults:
  - scope:
      path: "docs"
      type: "docs"
    values:
      layout: "default"

# Just the Docs 컬렉션 이름
just_the_docs:
  collections:
    posts:
      name: 블로그 포스트
    docs:
      name: Claude & Obsidian 가이드

# 빌드에서 제외
exclude:
  - docs/Claude-Obsidian-Guide/Templates/
```

## 중요 사항

### Obsidian ↔ Jekyll 통합
- `docs/Claude-Obsidian-Guide`는 외부 Obsidian Vault의 심볼릭 링크입니다
- Obsidian Front Matter(tags, created, part 등)를 보존하면서 Jekyll 속성(parent, nav_order 등)을 추가합니다
- **기존 Front Matter는 절대 삭제하지 마세요**

### Liquid 문법 주의
마크다운 파일에서 `{{ }}` 문법은 Jekyll Liquid 템플릿으로 처리되어 경고가 발생할 수 있습니다. 이를 피하려면:
- `{% raw %}{{ }}{% endraw %}`로 감싸거나
- `{{`를 `&#123;&#123;`로 이스케이프 처리

### 검색 설정
- 검색이 활성화되어 있습니다 (`search_enabled: true`)
- 헤딩 레벨 2부터 검색 가능

## 참고 자료

- [Just the Docs 공식 문서](https://just-the-docs.github.io/just-the-docs/)
- [Jekyll 공식 문서](https://jekyllrb.com/docs/)
- [Obsidian 공식 문서](https://help.obsidian.md/)
