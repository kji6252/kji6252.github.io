---
title: "프로젝트 라이프사이클"
tags: [guide, claude-obsidian, 백엔드, project-lifecycle]
part: "Part 6: 실전 워크플로우"
created: 2026-01-10
parent: "Part 6: 실전 워크플로우"
grand_parent: 백엔드 개발자를 위한 Claude Code + Obsidian 지식 관리법
nav_order: 2
---

# 프로젝트 라이프사이클

프로젝트 전체 과정에서 지식 관리를 통합하는 방법을 배웁니다.

## 프로젝트 단계

```mermaid
flowchart LR
    A[설계] --> B[개발]
    B --> C[테스트]
    C --> D[배포]
    D --> E[운영]
    E --> F[회고]
```

## 1. 설계 단계

```markdown
Claude:
"{{프로젝트}}의 시스템 설계 문서를
작성해줘.

요구사항:
- {{요구사항}}

Templates/system-design 사용"
```

### 산출물
- `overview.md`
- `architecture.md` (다이어그램 포함)
- `api-specs/`

## 2. 개발 단계

```markdown
# 일일 노트
- [[2025-01-10]]: 오늘 구현한 기능

# 트러블슈팅
- 문제 발생 시 바로 문서화
- [[Troubleshooting/{{이슈}}]]
```

## 3. 배포 단계

```markdown
# 배포 체크리스트
- [ ] 배포 계획 작성
- [ ] 롤백 절차 확인
- [ ] 모니터링 설정
```

## 4. 회고 단계

```markdown
Claude:
"프로젝트 {{이름}}을
완료했으니 회고를 작성해줘.

성과, 문제, 개선점 포함"
```

---

→ [[22-learning-cycle|학습 사이클]]
