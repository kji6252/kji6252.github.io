---
title: "Troubleshooting Template"
tags: [troubleshooting]
layout: default
---

{% raw %}
# {{title}}

## 문제 상황

### 발생 일시
{{datetime}}

### 환경
- 서버: {{server}}
- 버전: {{version}}
- 트래픽: {{traffic_level}}

### 에러 메시지
```
{{error_message}}
```

### 증상
- {{symptom_1}}
- {{symptom_2}}

## 원인 분석

### 근본 원인
{{root_cause}}

### 영향 범위
- {{affected_service}}
- {{affected_users}}

### 재현 단계
1. {{step_1}}
2. {{step_2}}
3. {{step_3}}

## 해결 방법

### 임시 조치
{{temporary_fix}}

### 근본적 해결
```{{language}}
{{solution_code}}
```

### 적용 결과
- {{result_1}}
- {{result_2}}

## 재발 방지

### 코드 개선
{{code_improvement}}

### 설정 변경
```conf
{{config_changes}}
```

### 모니터링 추가
{{monitoring_additions}}

### 테스트 케이스
```test
{{test_case}}
```

## 참고 자료
- [{{reference_title}}]({{reference_url}})
- [[{{related_note_1}}]]
- [[{{related_note_2}}]]

## 역사
| 일자 | 변경 내용 | 작성자 |
|------|----------|--------|
| {{date}} | 초기 작성 | {{author}} |
{% endraw %}
