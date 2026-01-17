---
title: "팀 Vault 구축"
tags: [guide, claude-obsidian, 백엔드, team]
part: "Part 7: 팀 협업"
created: 2026-01-10
parent: "Part 7: 팀 협업"
grand_parent: 백엔드 개발자를 위한 Claude Code + Obsidian 지식 관리법
nav_order: 1
---

# 팀 Vault 구축

Git을 활용하여 팀으로 지식을 공유하는 방법을 배웁니다.

## 팀 Vault 구조

```
team-knowledge-base/
├── .obsidian/
├── .git/
├── CLAUDE.md
├── Team/
│   ├── Members/
│   ├── Meetings/
│   └── Onboarding/
├── Projects/
├── Resources/
└── Shared/
```

## Git 설정

### .gitignore

```
.obsidian/workspace
.obsidian/workspace-mobile
.obsidian/graph.json
.DS_Store
```

### 커밋 규칙

```bash
# 커밋 메시지
docs: Redis 트러블슈팅 추가
fix: 오타수정
refactor: 폴더 구조 재편
```

## 협업 워크플로우

```mermaid
flowchart LR
    A[작성] --> B[Git Commit]
    B --> C[Push]
    C --> D[PR 생성]
    D --> E[Review]
    E --> F[Merge]
```

---

## 다음 단계

온보딩 자동화:

→ [[24-onboarding|온보딩 문서 자동화]]
