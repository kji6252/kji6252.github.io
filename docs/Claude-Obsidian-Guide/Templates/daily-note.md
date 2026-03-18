---
title: "Daily Note Template"
tags: [daily]
layout: default
---

{% raw %}
# {{date:YYYY-MM-DD}} {{day_of_week}}

## 오늘의 계획
- [ ] {{priority_1}}
- [ ] {{priority_2}}
- [ ] {{priority_3}}

## 회의 일정
- {{time_1}} - {{meeting_1}}
- {{time_2}} - {{meeting_2}}

## 완료한 작업
- [x] {{task_1}}
- [x] {{task_2}}

## 해결한 문제
{{if_troubleshooting}}

## 배운 것
{{if_learning}}

## 코드 리뷰
{{if_code_review}}

## 내일 할 일
- [ ] {{tomorrow_1}}
- [ ] {{tomorrow_2}}

## 메모
{{notes}}

---

## 관련 링크
- [[{{yesterday_note}}]]: 어제
- [[{{tomorrow_note}}]]: 내일
- [[{{current_week}}]]: 이번 주
{% endraw %}
