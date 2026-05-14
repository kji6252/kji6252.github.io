---
title: tmux 초보자 완전 가이드
layout: post
date: 2026-03-29 00:00:00
categories:
  - DevOps
tags:
  - tmux
  - Terminal
  - DevOps
  - BeginnerGuide
---

> 터미널 멀티플렉서 tmux의 핵심 개념부터 실전 활용까지 한 번에 정복
{: .prompt-info }

## tmux란?

**tmux**(Terminal Multiplexer)는 하나의 터미널 화면에서 **여러 세션, 윈도우, 패널을 관리**할 수 있게 해주는 도구입니다. SSH 연결이 끊겨도 작업이 유지되고, 하나의 화면을 여러 구역으로 나눌 수 있어 개발 생산성을 크게 높여줍니다.

### 왜 tmux를 써야 할까?

| 상황 | tmux 없이 | tmux 사용 |
|------|-----------|-----------|
| SSH 연결 끊김 | 작업이 사라짐 | 세션이 유지되어 재접속 가능 |
| 여러 작업 동시 실행 | 터미널 여러 개 열기 | 하나의 화면에서 분할 |
| 서버 모니터링 | 매번 다시 접속 | `attach`로 즉시 복귀 |
| 페어 프로그래밍 | 화면 공유 도구 필요 | 세션 공유로 실시간 협업 |

## 설치

### macOS

```bash
brew install tmux
```

### Ubuntu / Debian

```bash
sudo apt update && sudo apt install tmux
```

### CentOS / RHEL

```bash
sudo yum install tmux
```

### 버전 확인

```bash
tmux -V
# tmux 3.4
```

> **참고**: tmux 3.1 이상을 권장합니다. 구버전에서는 일부 기능이 동작하지 않을 수 있습니다.
{: .prompt-info }

## 핵심 개념

tmux를 이해하려면 세 가지 계층 구조를 아는 것이 중요합니다.

```
tmux 서버 (Server)
└── 세션 (Session)
    └── 윈도우 (Window)
        └── 패널 (Pane)
```

| 계층 | 설명 | 비유 |
|------|------|------|
| **서버** | tmux의 백그라운드 프로세스 | 컴퓨터 |
| **세션** | 독립된 작업 환경 단위 | 데스크탑 |
| **윈도우** | 세션 내의 탭 | 브라우저 탭 |
| **패널** | 윈도우 내의 화면 분할 | 분할된 브라우저 화면 |

## 기본 사용법

### 세션 관리

```bash
# 새 세션 시작 (이름 자동 생성)
tmux

# 이름을 지정하여 새 세션 시작
tmux new -s myproject

# 세션 목록 보기
tmux ls

# 기존 세션에 다시 접속
tmux attach -t myproject
# 또는 줄여서
tmux a -t myproject

# 마지막 세션에 접속
tmux a

# 세션 종료 (세션 안에서)
exit
# 또는
tmux kill-session -t myproject
```

### 프리픽스 키 (Prefix Key)

tmux의 모든 단축키는 **프리픽스 키**로 시작합니다.

- 기본 프리픽스: `Ctrl+b`
- 이 가이드에서는 `Ctrl+b`를 **`<prefix>`** 로 표기합니다.

> **Tip**: 프리픽스 키를 `Ctrl+a`로 변경하면 손가락 이동이 줄어 편합니다. (설정 방법은 뒤에서 다룹니다.)
{: .prompt-tip }

### 윈도우 관리

| 단축키 | 동작 |
|--------|------|
| `<prefix> c` | 새 윈도우 생성 |
| `<prefix> n` | 다음 윈도우로 이동 |
| `<prefix> p` | 이전 윈도우로 이동 |
| `<prefix> 0-9` | 번호 윈도우로 이동 |
| `<prefix> ,` | 윈도우 이름 변경 |
| `<prefix> &` | 윈도우 종료 |
| `<prefix> w` | 윈도우 목록 보기 |

### 패널 관리

| 단축키 | 동작 |
|--------|------|
| `<prefix> %` | 좌우로 분할 |
| `<prefix> "` | 상하로 분할 |
| `<prefix> 방향키` | 패널 간 이동 |
| `<prefix> z` | 현재 패널 전체화면 토글 |
| `<prefix> x` | 현재 패널 종료 |
| `<prefix> {` | 패널 위치 교환 (왼쪽/위로) |
| `<prefix> }` | 패널 위치 교환 (오른쪽/아래로) |

## 복사 모드 (Copy Mode)

tmux에서는 마우스 없이 스크롤하고 텍스트를 복사할 수 있습니다.

### 기본 복사 모드

| 단축키 | 동작 |
|--------|------|
| `<prefix> [` | 복사 모드 진입 |
| `q` | 복사 모드 종료 |
| `↑` / `↓` | 한 줄씩 스크롤 |
| `PgUp` / `PgDn` | 페이지 단위 스크롤 |
| `Space` | 선택 시작 |
| `Enter` | 선택 복사 후 종료 |
| `<prefix> ]` | 붙여넣기 |

### vi 모드 활성화

설정 파일에 다음을 추가하면 vi 키바인딩을 사용할 수 있습니다.

```bash
# ~/.tmux.conf
setw -g mode-keys vi
```

이렇게 하면 `h`, `j`, `k`, `l`로 이동하고, `v`로 선택, `y`로 복사할 수 있습니다.

## 설정 파일 커스터마이징

tmux의 설정 파일은 `~/.tmux.conf`에 작성합니다.

### 추천 기본 설정

```bash
# ~/.tmux.conf

# ---- 기본 설정 ----
# 프리픽스 키를 Ctrl+a로 변경
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# 256 컬러 지원
set -g default-terminal "screen-256color"

# 마우스 지원
set -g mouse on

# ---- 키 바인딩 ----
# | 로 좌우 분할 (직관적)
bind | split-window -h -c "#{pane_current_path}"
# - 로 상하 분할 (직관적)
bind - split-window -v -c "#{pane_current_path}"

# 현재 디렉토리 유지하며 새 윈도우 생성
bind c new-window -c "#{pane_current_path}"

# Vim 스타일 패널 이동 (프리픽스 없이)
bind -n M-h select-pane -L
bind -n M-j select-pane -D
bind -n M-k select-pane -U
bind -n M-l select-pane -R

# 설정 파일 리로드 단축키
bind r source-file ~/.tmux.conf \; display-message "설정 리로드 완료!"

# ---- 외관 설정 ----
# 상태 표시줄 색상
set -g status-style bg=black,fg=white

# 활성 윈도우 색상
set-window-option -g window-status-current-style bg=green,fg=black

# 패널 테두리
set -g pane-border-style fg=colour240
set -g pane-active-border-style fg=green

# ---- 기타 ----
# 인덱스를 1부터 시작
set -g base-index 1
setw -g pane-base-index 1

# Esc 키 지연 제거
set -sg escape-time 0

# 히스토리 크기 증가
set -g history-limit 10000

# 복사 모드 vi 키바인딩
setw -g mode-keys vi
```

### 설정 적용

```bash
# 설정 파일 리로드
tmux source-file ~/.tmux.conf

# 또는 tmux 안에서 <prefix> : 입력 후
source-file ~/.tmux.conf
```

## 실전 활용 패턴

### 1. 개발 환경 구성

서버 개발 시 자주 사용하는 패턴입니다.

```bash
# 프로젝트 세션 생성
tmux new -s dev

# 윈도우 구성 예시:
# 윈도우 1: 에디터 (vim/nano)
# 윈도우 2: 서버 실행 + 로그
# 윈도우 3: git + 빌드
```

화면 분할 예시:

```
┌──────────────────────────────────┐
│          서버 로그               │
│  $ npm run dev                   │
│                                  │
├──────────────────────────────────┤
│  git 상태    │   테스트 실행     │
│  $ git st    │   $ npm test      │
│              │                   │
└──────────────────────────────────┘
```

### 2. SSH 세션 유지

```bash
# 원격 서버에서 세션 생성
ssh server.example.com
tmux new -s work

# 작업 중... (서버 로그 모니터링, 빌드 등)

# 연결 끊김! (노트북 닫기, 네트워크 문제 등)
# → 세션은 서버에서 계속 실행 중

# 다시 접속
ssh server.example.com
tmux a -t work
# → 이전 화면 그대로 복구!
```

### 3. 자동 세션 복원 (tmux-resurrect)

[tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) 플러그인을 사용하면 시스템 재시작 후에도 세션을 복원할 수 있습니다.

```bash
# 플러그인 설치 (TPM 사용 시 - 뒤에서 설명)
# 또는 수동 설치:
git clone https://github.com/tmux-plugins/tmux-resurrect ~/.tmux/tmux-resurrect

# ~/.tmux.conf에 추가
run-shell ~/.tmux/tmux-resurrect/resurrect.tmux
```

| 단축키 | 동작 |
|--------|------|
| `<prefix> Ctrl+s` | 세션 저장 |
| `<prefix> Ctrl+r` | 세션 복원 |

## 플러그인 관리 (TPM)

[TPM](https://github.com/tmux-plugins/tpm)(Tmux Plugin Manager)은 tmux 플러그인을 쉽게 관리해줍니다.

### TPM 설치

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

### ~/.tmux.conf에 플러그인 추가

```bash
# 플러그인 목록
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'        # 기본 설정 모음
set -g @plugin 'tmux-plugins/tmux-resurrect'        # 세션 저장/복원
set -g @plugin 'tmux-plugins/tmux-continuum'        # 자동 세션 저장
set -g @plugin 'tmux-plugins/tmux-yank'             # 클립보드 복사 개선
set -g @plugin 'tmux-plugins/tmux-prefix-highlight' # 프리픽스 키 표시

# TPM 초기화 (반드시 마지막 줄에)
run '~/.tmux/plugins/tpm/tpm'
```

### 플러그인 설치/업데이트

| 단축키 | 동작 |
|--------|------|
| `<prefix> I` | 플러그인 설치 |
| `<prefix> U` | 플러그인 업데이트 |
| `<prefix> alt+u` | 플러그인 제거 (목록에서 삭제 후) |

## 명령어 치트시트

### 세션

```
tmux new -s NAME        # 새 세션 생성
tmux ls                 # 세션 목록
tmux a -t NAME          # 세션 접속
tmux kill-session -t N  # 세션 종료
tmux kill-server        # 전체 종료
<prefix> d              # 세션에서 분리 (detach)
<prefix> $              # 세션 이름 변경
<prefix> s              # 세션 목록 (전환 가능)
```

### 윈도우

```
<prefix> c     # 새 윈도우
<prefix> n     # 다음 윈도우
<prefix> p     # 이전 윈도우
<prefix> 0-9   # 번호로 이동
<prefix> ,     # 이름 변경
<prefix> &     # 종료
<prefix> w     # 목록 보기
```

### 패널

```
<prefix> %       # 좌우 분할
<prefix> "       # 상하 분할
<prefix> 방향키  # 이동
<prefix> z       # 전체화면 토글
<prefix> x       # 종료
<prefix> { / }   # 위치 교환
<prefix> Space   # 레이아웃 순환 변경
```

### 기타

```
<prefix> ?       # 모든 단축키 보기
<prefix> :       # 명령 모드 진입
<prefix> t       # 시계 표시
<prefix> [       # 복사 모드 진입
```

## 자주 묻는 질문

### Q: tmux 안에서 마우스 스크롤이 안 돼요

```bash
# ~/.tmux.conf에 추가
set -g mouse on
```

설정 리로드 후 마우스로 스크롤, 클릭, 패널 크기 조절이 가능합니다.

### Q: 색상이 이상하게 나와요

```bash
# ~/.tmux.conf에 추가
set -g default-terminal "screen-256color"

# 또는 터미널 에뮬레이터에서 true color 지원 시
set -ag terminal-overrides ",xterm-256color:RGB"
```

### Q: 기존 터미널 작업을 tmux로 옮길 수 있나요?

불가능합니다. tmux는 새 셸을 시작합니다. 대신:
1. tmux 세션을 새로 시작
2. 기존 작업은 백그라운드로 전환 (`Ctrl+z` 후 `bg`)
3. tmux 안에서 다시 `fg`로 가져오기

### Q: 프리픽스 키가 불편해요

`Ctrl+b`는 왼손으로 입력하기 멀리 있습니다. 많은 사용자가 `Ctrl+a`로 변경합니다.

```bash
# ~/.tmux.conf
unbind C-b
set -g prefix C-a
bind C-a send-prefix
```

> **참고**: `Ctrl+a`는 bash에서 줄의 시작으로 이동하는 단축키입니다. tmux 안에서는 `Ctrl+a`를 두 번 눌러야 원래 기능을 사용할 수 있습니다.
{: .prompt-info }

## 요약

tmux는 처음에는 진입장벽이 있지만, 몇 가지 핵심 단축키만 기억하면 즉시 생산성 향상을 체감할 수 있습니다.

**시작하기 위한 최소한의 단축키:**

1. `tmux new -s 이름` - 세션 생성
2. `<prefix> d` - 세션에서 분리
3. `tmux a` - 세션에 재접속
4. `<prefix> %` / `<prefix> "` - 화면 분할
5. `<prefix> 방향키` - 패널 이동

이 다섯 가지만으로도 충분히 tmux의 장점을 누릴 수 있습니다. 익숙해진 후에 설정 파일을 커스터마이징하고 플러그인을 추가해 보세요.

## 더 알아보기

- [tmux 공식 GitHub](https://github.com/tmux/tmux)
- [tmux 매뉴얼 페이지](https://man7.org/linux/man-pages/man1/tmux.1.html)
- [tmux-plugins](https://github.com/tmux-plugins)
- [Oh My Tmux](https://github.com/gpakosz/.tmux) - 인기 있는 tmux 설정 프레임워크
