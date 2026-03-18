---
title: "&#123;&#123;api_name&#125;&#125; API 명세"
tags: [api, &#123;&#123;service&#125;&#125;, &#123;&#123;version&#125;&#125;]
version: "&#123;&#123;version&#125;&#125;"
last-updated: &#123;&#123;date&#125;&#125;
---

{% raw %}
# {{api_name}} API

## 개요

### 설명
{{description}}

### 기능
{{purpose}}

## Request

### Endpoint
`{{method}} /api/{{version}}{{path}}`

### Headers
| Key | Value | 필수 | 설명 |
|-----|-------|------|------|
| Content-Type | application/json | ✅ | |
| Authorization | Bearer {token} | ✅ | JWT 토큰 |
| {{header_key}} | {{header_value}} | | {{header_desc}} |

### Path Parameters
| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| {{path_param}} | {{type}} | ✅ | {{description}} |

### Query Parameters
| 파라미터 | 타입 | 필수 | 기본값 | 설명 |
|----------|------|------|--------|------|
| {{query_param}} | {{type}} | | {{default}} | {{description}} |

### Request Body
```json
{
  "{{field_1}}": "{{value_1}}",
  "{{field_2}}": "{{value_2}}"
}
```

| 필드 | 타입 | 필수 | 제약 | 설명 |
|------|------|------|------|------|
| {{field}} | {{type}} | ✅ | {{constraint}} | {{description}} |

## Response

### Success Response
**Status**: `200 OK`

```json
{
  "{{response_field_1}}": "{{value_1}}",
  "{{response_field_2}}": "{{value_2}}"
}
```

| 필드 | 타입 | 설명 |
|------|------|------|
| {{field}} | {{type}} | {{description}} |

### Error Responses

#### 400 Bad Request
```json
{
  "code": "{{error_code}}",
  "message": "{{error_message}}",
  "timestamp": "{{timestamp}}"
}
```

| 코드 | 메시지 | 원인 |
|------|--------|------|
| {{code}} | {{message}} | {{cause}} |

## 구현 노트

### 비즈니스 로직
{{business_logic}}

### 데이터베이스 쿼리
```sql
{{query}}
```

### 외부 API 호출
{{external_calls}}

## 테스트 케이스

### 정상 케이스
| 케이스 | 입력 | 기대 출력 |
|--------|------|----------|
| {{case_1}} | {{input}} | {{output}} |

### 예외 케이스
| 케이스 | 입력 | 기대 에러 |
|--------|------|-----------|
| {{case_1}} | {{input}} | {{error}} |

## 관련 API
- [[{{related_api_1}}]]
- [[{{related_api_2}}]]

## 변경 이력
| 버전 | 일자 | 변경 내용 | 작성자 |
|------|------|----------|--------|
| {{version}} | {{date}} | {{changes}} | {{author}} |
{% endraw %}
