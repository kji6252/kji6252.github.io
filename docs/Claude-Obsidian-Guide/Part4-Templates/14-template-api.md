---
title: "API 설계 템플릿"
tags: [guide, claude-obsidian, 백엔드, template-api]
part: "Part 4: 템플릿 활용"
created: 2026-01-10
parent: 백엔드 개발자를 위한 Claude Code + Obsidian 지식 관리법
nav_order: 4
---

# API 설계 템플릿

REST API 명세서를 작성하는 표준 템플릿입니다.

## 개요

API 명세서는 프론트엔드 개발자와 백엔드 개발자 간의 커뮤니케이션 도구이자, 나중에 API를 유지보수할 때를 위한 문서입니다. 표준 형식을 사용하면 일관성을 유지할 수 있습니다.

## 학습 목표

- [ ] API 명세서 표준 구조 이해하기
- [ ] OpenAPI/Swagger 형식으로 문서화하기
- [ ] Controller 코드에서 명세서 자동 생성하기
- [ ] Claude로 API 문서 작성 자동화하기

---

## 템플릿 구조

### 전체 템플릿

```markdown
---
title: "{{API명}}"
tags: [api, {{service}}, {{version}}]
version: "{{version}}"
baseUrl: "{{baseUrl}}"
---

# {{API명}} API

## 개요

### 설명
{{description}}

### 관련 문서
- [[요구사항/기획서]]
- [[DB/스키마]]

---

## Endpoints

### 1. {{endpoint_1}}

`{{METHOD}} /api/{{path}}`

#### 설명
{{description}}

#### Request Headers
```http
Content-Type: application/json
Authorization: Bearer {{token}}
```

#### Path Parameters
| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| {{param_1}} | {{type}} | Yes | {{description}} |
| {{param_2}} | {{type}} | No | {{description}} |

#### Query Parameters
| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| {{query_1}} | {{type}} | Yes | {{description}} |
| {{query_2}} | {{type}} | No | {{description}} |

#### Request Body
```json
{
  "field1": "value1",
  "field2": "value2"
}
```

#### Response
**Success 200 OK**
```json
{
  "code": 200,
  "message": "성공",
  "data": {{response_data}}
}
```

**Error 400 Bad Request**
```json
{
  "code": 400,
  "message": "잘못된 요청",
  "errors": [
    {
      "field": "email",
      "message": "이메일 형식이 올바르지 않습니다"
    }
  ]
}
```

**Error 401 Unauthorized**
```json
{
  "code": 401,
  "message": "인증이 필요합니다"
}
```

**Error 404 Not Found**
```json
{
  "code": 404,
  "message": "리소스를 찾을 수 없습니다"
}
```

**Error 500 Internal Server Error**
```json
{
  "code": 500,
  "message": "서버 오류가 발생했습니다"
}
```

#### Example
```bash
curl -X {{METHOD}} 'https://api.example.com/api/{{path}}' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer {{token}}' \
  -d '{
    "field1": "value1",
    "field2": "value2"
  }'
```

---

## 공통 응답 형식

### 성공 응답
```json
{
  "code": 200,
  "message": "성공",
  "data": {{actual_data}}
}
```

### 실패 응답
```json
{
  "code": {{error_code}},
  "message": "{{error_message}}",
  "errors": {{validation_errors}}
}
```

---

## 에러 코드

| 코드 | 메시지 | 설명 |
|------|--------|------|
| 400 | Bad Request | 잘못된 요청 |
| 401 | Unauthorized | 인증 필요 |
| 403 | Forbidden | 권한 부족 |
| 404 | Not Found | 리소스 없음 |
| 409 | Conflict | 리소스 충돌 |
| 422 | Unprocessable Entity | 검증 실패 |
| 429 | Too Many Requests | 요청 초과 |
| 500 | Internal Server Error | 서버 오류 |
| 503 | Service Unavailable | 서비스 불가 |

---

## 변경 이력

| 버전 | 날짜 | 변경 내용 | 작성자 |
|------|------|----------|--------|
| 1.0.0 | {{date}} | 초기 버전 | {{author}} |
```

---

## 각 섹션 상세 설명

### 1. Endpoint 명세

가장 중요한 섹션입니다. 각 엔드포인트마다 다음 정보를 포함합니다:

```markdown
### 사용자 조회

`GET /api/users/{id}`

#### 설명
ID로 사용자 정보를 조회합니다.

#### Request Headers
```http
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### Path Parameters
| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| id | Long | Yes | 사용자 ID |

#### Query Parameters
| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| fields | String | No | 반환할 필드 (쉼표로 구분) |

#### Response
**Success 200 OK**
```json
{
  "code": 200,
  "message": "성공",
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "홍길동",
    "createdAt": "2026-01-10T10:00:00"
  }
}
```

**Error 404 Not Found**
```json
{
  "code": 404,
  "message": "사용자를 찾을 수 없습니다"
}
```
```

### 2. 검증 규칙

Request Body의 각 필드에 대한 검증 규칙을 명시합니다:

```markdown
#### Request Body 검증
| 필드 | 타입 | 필수 | 제약조건 | 설명 |
|------|------|------|----------|------|
| email | String | Yes | 이메일 형식, 최대 255자 | 이메일 주소 |
| password | String | Yes | 최소 8자, 영문+숫자+특수문자 | 비밀번호 |
| name | String | Yes | 최소 2자, 최대 50자 | 이름 |
| age | Integer | No | 0 이상, 150 이하 | 나이 |

#### 검증 오류 응답
```json
{
  "code": 422,
  "message": "검증에 실패했습니다",
  "errors": [
    {
      "field": "email",
      "message": "이메일 형식이 올바르지 않습니다"
    },
    {
      "field": "password",
      "message": "비밀번호는 최소 8자 이상이어야 합니다"
    }
  ]
}
```
```

---

## Claude로 API 문서 작성

### 1. Controller 코드에서 명세서 생성

```markdown
사용자:
"이 Spring Boot Controller 코드를
API 명세서로 변환해줘.
Templates/api-spec 템플릿을 사용해서"

[Controller 코드 붙여넣기]

Claude:
## 분석 완료

Controller: UserController.kt
엔드포인트: 5개

생성된 API 명세서:
- 경로: API/user-api.md
- 내용: 각 엔드포인트별 Request/Response 명세

미리보기:
### 사용자 생성
`POST /api/users`

Request Body:
{
  "email": "user@example.com",
  "password": "Password123!",
  "name": "홍길동"
}

Response 201:
{
  "code": 201,
  "message": "사용자가 생성되었습니다",
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "홍길동"
  }
}
```

### 2. 기존 명세서 업데이트

```markdown
사용자:
"기존 API 명세서에 새로운 엔드포인트를 추가해줘.

엔드포인트: DELETE /api/users/{id}
설명: 사용자 삭제
Response: 204 No Content"

Claude:
업데이트 완료:
- API/user-api.md에 새 엔드포인트 추가
- 에러 코드 섹션에 204 응답 추가
- 예제 cURL 명령어 추가
```

### 3. Swagger/OpenAPI 변환

```markdown
사용자:
"이 API 명세서를 OpenAPI 3.0 YAML로 변환해줘"

Claude:
openapi: 3.0.0
info:
  title: User API
  version: 1.0.0
paths:
  /api/users:
    post:
      summary: 사용자 생성
      requestBody:
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserRequest'
      responses:
        '201':
          description: 생성 성공
```
```

---

## 실전 예시

### Before: 템플릿 없음

```markdown
# 사용자 API

POST /users
이름, 이메일 받아서 생성

GET /users/{id}
ID로 조회

PUT /users/{id}
수정

DELETE /users/{id}
삭제
```

**문제점**
- Request/Response 형식 없음
- 에러 처리 방법 없음
- 검증 규칙 없음
- 실제 사용 불가능

### After: 템플릿 적용

```markdown
---
title: "사용자 API"
tags: [api, user-service]
version: "1.0.0"
baseUrl: "https://api.example.com"
---

# 사용자 API

## 개요

사용자 관리를 위한 REST API입니다. 사용자 생성, 조회, 수정, 삭제 기능을 제공합니다.

---

## Endpoints

### 1. 사용자 생성

`POST /api/users`

#### 설명
새로운 사용자를 생성합니다.

#### Request Body
```json
{
  "email": "user@example.com",
  "password": "Password123!",
  "name": "홍길동",
  "age": 30
}
```

#### Request Body 검증
| 필드 | 타입 | 필수 | 제약조건 |
|------|------|------|----------|
| email | String | Yes | 이메일 형식, 중복 불가 |
| password | String | Yes | 최소 8자, 영문+숫자+특수문자 |
| name | String | Yes | 2-50자 |
| age | Integer | No | 0-150 |

#### Response
**Success 201 Created**
```json
{
  "code": 201,
  "message": "사용자가 생성되었습니다",
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "홍길동",
    "age": 30,
    "createdAt": "2026-01-10T10:00:00"
  }
}
```

**Error 409 Conflict**
```json
{
  "code": 409,
  "message": "이미 존재하는 이메일입니다"
}
```

**Error 422 Unprocessable Entity**
```json
{
  "code": 422,
  "message": "검증에 실패했습니다",
  "errors": [
    {
      "field": "email",
      "message": "이메일 형식이 올바르지 않습니다"
    }
  ]
}
```

#### Example
```bash
curl -X POST 'https://api.example.com/api/users' \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "user@example.com",
    "password": "Password123!",
    "name": "홍길동",
    "age": 30
  }'
```

---

## 공통 응답 형식

### 성공 응답
```json
{
  "code": 200,
  "message": "성공",
  "data": {{actual_data}}
}
```

### 실패 응답
```json
{
  "code": {{error_code}},
  "message": "{{error_message}}",
  "errors": {{validation_errors}}
}
```

---

## 에러 코드

| 코드 | 메시지 | 설명 |
|------|--------|------|
| 400 | Bad Request | 잘못된 요청 |
| 401 | Unauthorized | 인증 필요 |
| 404 | Not Found | 리소스 없음 |
| 409 | Conflict | 리소스 충돌 (이메일 중복 등) |
| 422 | Unprocessable Entity | 검증 실패 |
| 500 | Internal Server Error | 서버 오류 |
```

---

## 모범 사례

### 1. 명확한 URL 설계

❌ **나쁜 예**
```markdown
GET /getUser
POST /createUser
PUT /updateUser
```

✅ **좋은 예**
```markdown
GET /api/users
POST /api/users
PUT /api/users/{id}
```

### 2. HTTP 메서드 올바른 사용

| 메서드 | 용도 | 멱등성 |
|--------|------|---------|
| GET | 조회 | Yes |
| POST | 생성 | No |
| PUT | 전체 수정 | Yes |
| PATCH | 부분 수정 | No |
| DELETE | 삭제 | Yes |

### 3. 상태 코드 올바른 사용

```markdown
# 성공
200 OK: 조회/수정 성공
201 Created: 생성 성공
204 No Content: 삭제 성공 (본문 없음)

# 클라이언트 오류
400 Bad Request: 잘못된 요청
401 Unauthorized: 인증 필요
403 Forbidden: 권한 부족
404 Not Found: 리소스 없음
409 Conflict: 리소스 충돌
422 Unprocessable Entity: 검증 실패

# 서버 오류
500 Internal Server Error: 서버 오류
503 Service Unavailable: 서비스 점검 중
```

### 4. 일관된 응답 형식

```json
// 모든 API에서 동일한 구조 사용
{
  "code": 200,
  "message": "성공",
  "data": { ... },
  "timestamp": "2026-01-10T10:00:00"
}
```

---

## 검색 팁

### Dataview 쿼리

```dataview
# 모든 API 문서
TABLE version, baseUrl
FROM #api
SORT file.ctime DESC
```

```dataview
# 특정 서비스의 API
LIST
FROM #api
WHERE contains(tags, "user-service")
```

---

## 실습 과제

- [ ] 본인이 만든 Controller의 API 명세서 작성
- [ ] Claude에게 코드에서 명세서 생성 요청
- [ ] Swagger/OpenAPI로 변환
- [ ] Postman이나 curl로 테스트
- [ ] 팀원에게 리뷰 요청

---

## 참고 자료

- [OpenAPI Specification](https://swagger.io/specification/)
- [REST API Best Practices](https://restfulapi.net/)
- [HTTP Status Codes](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status)

---

## 다음 단계

API 명세를 작성했으면, 이제 시스템을 설계해봅시다.

→ [[15-template-design|시스템 설계 템플릿]]
