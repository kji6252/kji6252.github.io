---
title: "Ollama + cmux로 Claude Code 탭 이름 자동 지정하기"
layout: post
date: 2026-04-30 00:00:00
categories:
  - AI
tags:
  - AI
  - Claude
  - ClaudeCode
  - cmux
  - Ollama
  - Terminal
  - LocalLLM
---

> 로컬 Ollama로 Claude Code 세션 내용을 요약해서 cmux 탭 이름을 자동으로 설정하는 방법
{: .prompt-info }

## 배경

cmux에서 여러 Claude Code 세션을 띄워놓으면, 어느 탭에서 뭘 하고 있는지 구분하기 어렵습니다. 챗봇 서비스(ChatGPT, Claude 등)처럼 첫 질문에 대한 답변이 오면 자동으로 대화 제목을 설정하고 싶었습니다.

## 아키텍처

```
Claude Code 첫 응답 완료 (Stop)
        ↓
Stop Hook (async, once)
        ↓
cmux read-screen --scrollback
        ↓
질문 + 답변 내용 추출 (UI 노이즈 필터링)
        ↓
Ollama API (gemma4:e2b)
        ↓
25자 이내 한국어 요약
        ↓
cmux rename-tab
```

## 핵심 설계 결정

### Stop 훅 + 마커 파일로 한 번만 실행

처음에는 `Notification` 훅을 사용했으나, OS 알림 전송 시점에만 발생하여 타이밍이 불안정했습니다. `Stop` 훅은 Claude Code가 응답을 완전히 마친 시점에 발생합니다.

`once: true` 옵션에도 불구하고 매 턴마다 실행되는 현상이 있어서, surface별 마커 파일(`/tmp/cmux-renamed-사용자-surface:ID`)로 확실히 한 번만 실행되도록 보장합니다. 새 Claude Code 세션은 새 surface ID를 가지므로 마커가 없어 다시 실행됩니다.

### 질문+답변 모두 반영

사용자 프롬프트(`❯`)만 사용하면 "응", "아니" 같은 짧은 질문일 때 의미 있는 요약이 어렵습니다. 따라서 **질문과 답변을 모두 포함**하여 요약 정확도를 높였습니다.

### `ollama run` 대신 API 직접 호출

`ollama run`은 spinner 애니메이션과 "Thinking..." 텍스트를 stdout에 출력하므로, `head -1`로 "Thinking..."이 잡히는 문제가 있습니다. HTTP API(`POST http://localhost:11434/api/generate`)를 직접 호출해야 깔끔한 결과를 얻을 수 있습니다.

### `--scrollback` 필수

`--lines N` 옵션만 사용하면 현재 화면에 보이는 N줄만 읽습니다. 이미 스크롤된 이전 대화를 읽으려면 `--scrollback` 플래그가 필요합니다.

## 필수 구성

| 구성 요소 | 버전/모델 | 용도 |
|-----------|----------|------|
| cmux | 최신 | macOS 터미널 멀티플렉서 |
| Claude Code | 최신 | AI 코딩 어시스턴트 |
| Ollama | 최신 | 로컬 LLM 서버 |
| gemma4:e2b | 7.2GB | 요약용 경량 모델 |

## 구현

### 1. 스크립트 작성

`~/.local/bin/cmux-smart-rename.sh`를 생성합니다.

```bash
#!/bin/bash
MAX_CHARS=25

[ -z "$CMUX_SURFACE_ID" ] && exit 0

# 이미 실행된 surface면 스킵
MARKER_FILE="/tmp/cmux-renamed-$(whoami)-${CMUX_SURFACE_ID}"
[ -f "$MARKER_FILE" ] && exit 0

content=$(cmux read-screen --surface "$CMUX_SURFACE_ID" --scrollback 2>/dev/null \
    | grep -v '^─\+$' \
    | grep -v '^\s*$' \
    | grep -v '^\s*│\|^\s*├\|^\s*└' \
    | grep -v '✻\|✶\|⏎\|▸' \
    | grep -vi 'Brewed for\|Worked for\|Actualizing\|Calling\|tokens\|ctrl+o\|shift+tab\|accept edits\|glm-\|of 200k' \
    | tail -30)

[ -z "$content" ] && exit 0

summary=$(python3 -c "
import json, urllib.request, sys

content = sys.stdin.read().strip()
if not content:
    sys.exit(1)

data = json.dumps({
    'model': 'gemma4:e2b',
    'prompt': f'아래 터미널 대화에서 핵심 작업을 한국어로 ${MAX_CHARS}자 이내 명사구로 요약. 제목만 출력.\n\n{content}',
    'stream': False
}).encode()

req = urllib.request.Request(
    'http://localhost:11434/api/generate',
    data=data,
    headers={'Content-Type': 'application/json'}
)
try:
    with urllib.request.urlopen(req, timeout=15) as resp:
        result = json.loads(resp.read())
        print(result.get('response', '').strip().split('\n')[0])
except:
    sys.exit(1)
" <<< "$content" 2>/dev/null)

[ -z "$summary" ] && exit 0

summary=$(echo "$summary" | cut -c1-${MAX_CHARS})
cmux rename-tab --surface "$CMUX_SURFACE_ID" "$summary" 2>/dev/null

# 성공 시 마커 생성
touch "$MARKER_FILE"
```

```bash
chmod +x ~/.local/bin/cmux-smart-rename.sh
```

### 2. Claude Code Hook 등록

`~/.claude/settings.json`에 Stop 훅을 추가합니다.

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.local/bin/cmux-smart-rename.sh",
            "async": true,
            "once": true
          }
        ]
      }
    ]
  }
}
```

> `bash`로 감싸면 `~` 경로 확장이 확실히 동작합니다. 절대경로 대신 `~`를 사용하면 다른 사용자와 설정 공유가 용이합니다.
{: .prompt-info }

### 3. 동작 확인

새 Claude Code 세션을 시작하고 질문을 하면, 첫 응답 완료 후 탭 이름이 자동으로 설정됩니다.

```bash
# 수동 테스트
export CMUX_SURFACE_ID=surface:36  # cmux tree로 확인
bash ~/.local/bin/cmux-smart-rename.sh
cmux tree  # 이름 변경 확인
```

## Hook 옵션 설명

| 옵션 | 값 | 설명 |
|------|-----|------|
| `async` | `true` | Claude Code 응답을 블로킹하지 않고 백그라운드 실행 |
| `once` | `true` | 첫 번째 Stop에만 실행 (챗봇 서비스처럼 첫 Q&A에서만 제목 설정) |

`once`를 제거하면 매 응답마다 탭 이름이 갱신됩니다.

## 동작 흐름 요약

```
사용자 질문 → Claude Code 응답 → 응답 완료(Stop) → Stop 훅 발생 (once)
    → 스크립트 백그라운드 실행 (async)
    → scrollback에서 질문+답변 추출
    → Ollama로 요약
    → cmux rename-tab 실행
    → 훅 자동 제거 (once)
```
