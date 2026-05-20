# Agent 코딩 가이드

> 이 파일을 프로젝트에 추가하여 코딩 에이전트가 따라야 할 규칙을 정의합니다.

## 1. 계획 먼저, 승인 후 코딩

- 코드를 작성하기 **전에** 접근 방식을 설명하고 승인을 기다리세요.
- 요구 사항이 모호한 경우, 모든 코드를 작성하기 전에 **반드시** 명확한 질문을 던지세요.
- GDD·체크리스트·`START_HERE.md` 등에 **미정**이거나 **실무적으로 갈래가 나는 스펙**은, 코드·문서에 반영하기 전에 **반드시 사용자에게 확인**받는다. (추측으로 잠정 구현만 하고 넘어가지 않는다. 잠정안이면 그 사실을 명시한다.)

### Goal 기반 자동 진행 예외

- 사용자가 `/goal` 또는 명시적인 장기 목표를 설정하고 **자동 진행**을 승인하면, 에이전트는 목표 달성에 필요한 코드 구현, 테스트, 관련 문서 동기화, 분석·빌드·QA를 매 단계 사전 승인 없이 진행할 수 있다.
- 자동 진행 중에도 큰 작업은 작은 단위로 나누고, 각 단위의 변경 요약·검증 결과·남은 리스크를 응답으로 보고한다.
- 단, 아래 항목은 자동 진행 중에도 사용자 확인을 받는다.
  - 저장 포맷·마이그레이션을 깨뜨릴 수 있는 변경
  - UI/UX 구조를 크게 바꾸는 변경
  - 레벨링·밸런스 핵심 정책 원칙 변경
  - 삭제·복원·force push 등 파괴적 작업
  - 비용이 큰 장기 실행 작업
  - 스펙이 실무적으로 두 갈래 이상으로 갈리는 경우

## 2. 큰 작업은 작게 분해

- 작업이 **3개 이상의 파일**을 변경해야 한다면, 먼저 멈추고 **작은 작업으로 분해**하세요.
- 각 단계를 순차적으로 진행하고, 필요 시 사용자 확인을 받으세요.

## 3. 코드 작성 후 영향 분석

- 코드를 작성한 후, **무엇이 깨질 수 있는지** 나열하세요.
- 이를 커버할 **테스트를 제안**하세요.

## 4. 버그 수정 시 테스트 우선

- 버그가 생기면 **재현하는 테스트를 먼저 작성**하세요.
- 테스트가 통과할 때까지 고치세요.

## 5. 교정 시 규칙 추가

- 사용자가 수정을 요청할 때마다, 이 **AGENTS.md** 파일에 새로운 규칙을 추가하세요.
- 동일한 실수가 다시 발생하지 않도록 하세요.
- 컨버팅 작업의 완료 판단은 화면 모양 복제만으로 하지 않는다. 원본 프로젝트의 서버 연동, 데이터 흐름, 머신러닝/딥러닝 처리, 외부 API 사용, 환경 변수, 테스트 가능한 기능 계약까지 현재 앱에서 어떻게 충족되는지 항목별로 검증한 뒤 완료로 본다.
- goal 완료 처리 전에는 사용자가 말한 원래 범위를 다시 읽고, 축소된 기준으로 성공을 선언하지 않는다.
- FastAPI 서버는 개발·테스트 중에는 로컬 서버를 사용하지만, 배포 시에는 외부 서버로 이관되는 전제로 구현한다. 앱 코드와 문구는 로컬 서버 내장을 전제로 쓰지 말고, `API_BASE` 같은 환경별 서버 주소 주입을 기본 경로로 둔다.
- Flutter 컨버팅에서 `main.dart`는 앱 부트스트랩만 맡긴다. 화면은 `view` 또는 `screens`, 반복 UI는 `widgets`, 상태·비즈니스 로직은 `vm`으로 분리하고, 완료 전 `main.dart` 과밀 여부를 반드시 점검한다.
- 웹 UI를 Flutter로 이전할 때는 화면 배치를 그대로 복제하지 않는다. 우선 기기인 iOS 모바일에서 입력창·조건 패널·결과 카드가 서로 가리거나 내부 중첩 스크롤을 만들지 않는지 확인하고, 앱 사용성에 맞게 bottom sheet, compact bar, 자연 높이 리스트 등 모바일 패턴으로 재구성한다.
- Flutter 앱 UI 점검과 검증의 주 타겟은 웹 빌드가 아니라 iPhone, Android phone, iPad, Android tablet이다. 반응형 기준은 모바일/태블릿 사용성을 우선하고, 웹 빌드는 사용자가 명시적으로 요청한 경우에만 검증한다.
- UI가 좁은 화면에서 깨질 때는 문구나 기능을 숨겨 해결하지 않는다. 먼저 여백, 글자 크기, 아이콘 크기, 줄 수, 반응형 배치 같은 레이아웃 조정으로 콘텐츠를 유지한다.
- 카드 썸네일 이미지가 영역에 맞춰 잘려 보일 때는 잘린 상태만 제공하지 않는다. 사용자가 탭해서 원본 비율 이미지를 화면 크기에 맞춰 보고, X 버튼이나 여백 탭으로 닫을 수 있는 뷰어를 제공한다.

---

## Flutter 앱 개발 원칙

- **간결함**: 요구 사항에 맞춰 작성하고, 오버스펙을 피한다.
- **초급자 관점**: 이 앱을 이어 받을 팀원이 초급이라고 가정한다. 복잡한 로직보다 **이해도와 가독성**을 우선한다.
- **한글 주석**: 핵심 기능에는 항상 간결한 한글 주석을 작성한다.
- **UI 모듈화**: 반복되거나 화면이 복잡해지는 부분은 모듈/클래스/함수로 분리한다.
- **MVVM 패턴**: `view`에는 UI 제어 로직만 둔다. 그 외 로직은 `vm` 폴더의 ViewModel로 분리한다.

---

## Flutter 실행 환경

- **우선 기기**: iOS 시뮬레이터 (모바일 앱 우선 개발)
- **우선 모드**: Debug (run보다 debug 우선)
- macOS/웹은 보조용

---

## 네이밍 (vm 폴더)

- **Handler**: DB/저장소 접근 전담 (예: DatabaseHandler, TagHandler)
- **Notifier**: Riverpod 상태 관리 (예: TodoListNotifier, TagListNotifier)
- Repository 용어는 Git과 혼동되므로 사용하지 않는다.

## Riverpod

- **`riverpod_annotation` / `build_runner` 코드젠은 도입하지 않는다.** `Notifier`·`NotifierProvider` 등은 수동 선언한다.

---

## UI 코딩 규칙

- **Row/Column 동일 간격**: `SizedBox` 대신 `spacing` 파라미터를 사용한다. (위젯 태그 과다 방지)


---

## 주석 규칙

- 주석은 **한글**로 작성한다.
- 코드가 하는 일을 그대로 옮기는 주석은 달지 않는다. ("이게 뭔가", "왜 이렇게 하나", "어떻게 동작하나"에 해당할 때만 작성)
- 클래스/mixin의 **역할과 존재 이유**를 간결하게 설명한다.
- 의도가 드러나지 않는 로직에는 **의도(why)**를 적는다.
- 그림 문자(이모지)는 사용하지 않는다. (디버깅 시 구분 용도로만 허용)
- "초보자용", "쉽게 설명하면" 같은 문구는 넣지 않는다.

---

## 문서화

- 사용자가 **문서화해 달라고 요청하기 전까지** `.md` 파일을 작성하지 않는다.
- 설계, 플랜, 요약 등은 응답으로만 보여주고, 파일로 저장하지 않는다.
- 여러 PC에서 같은 repo를 관리하므로, 문서와 응답의 repo 내부 파일 경로는 **repo root 기준 상대경로**로 적는다. 절대경로는 사용자가 명시했거나 로컬 실행 명령에 꼭 필요할 때만 쓴다.
- repo 외부 참고 프로젝트는 PC마다 위치가 다를 수 있으므로 문서에 사용자 홈·바탕화면·드라이브 문자로 시작하는 로컬 절대경로를 고정하지 않는다.

---

## 추가 참고

- **언어**: 모든 응답은 한국어로 작성합니다.
- **출처**: [@svpino - X/Twitter](https://x.com/svpino/status/2018682144361734368)

<!-- BEGIN GSTACK-CODEX MANAGED BLOCK -->
## gstack — AI Engineering Workflow

This block is managed by `gstack-codex`. Do not edit inside this block.

Skills live in `.agents/skills`. Invoke them by name, e.g. `/office-hours`.
Refresh with `npx gstack-codex init --project`.
This repo currently has the `full` pack installed.

## Available skills

| Skill | What it does |
|-------|-------------|
| `/office-hours` | YC Office Hours — two modes. Startup mode: six forcing questions that expose demand reality, status quo, desperate specificity, narrowest wedge, observation, and future-fit. |
| `/plan-ceo-review` | CEO/founder-mode plan review. Rethink the problem, find the 10-star product, challenge premises, expand scope when it creates a better product. |
| `/plan-eng-review` | Eng manager-mode plan review. Lock in the execution plan — architecture, data flow, diagrams, edge cases, test coverage, performance. |
| `/plan-design-review` | Designer's eye plan review — interactive, like CEO and Eng review. |
| `/design-consultation` | Design consultation: understands your product, researches the landscape, proposes a complete design system (aesthetic, typography, color, layout, spacing, motion), and generates font+color preview pages. |
| `/review` | Pre-landing PR review. Analyzes diff against the base branch for SQL safety, LLM trust boundary violations, conditional side effects, and other structural issues. |
| `/investigate` | Systematic debugging with root cause investigation. Four phases: investigate, analyze, hypothesize, implement. |
| `/design-review` | Designer's eye QA: finds visual inconsistency, spacing issues, hierarchy problems, AI slop patterns, and slow interactions — then fixes them. |
| `/qa` | Systematically QA test a web application and fix bugs found. |
| `/qa-only` | Report-only QA testing. Systematically tests a web application and produces a structured report with health score, screenshots, and repro steps — but never fixes anything. |
| `/ship` | Ship workflow: detect + merge base branch, run tests, review diff, bump VERSION, update CHANGELOG, commit, push, create PR. |
| `/document-release` | Post-ship documentation update. Reads all project docs, cross-references the diff, updates README/ARCHITECTURE/CONTRIBUTING/CLAUDE.md to match what shipped, polishes CHANGELOG voice, cleans up TODOS, and optionally bumps VERSION. |
| `/retro` | Weekly engineering retrospective. Analyzes commit history, work patterns, and code quality metrics with persistent history and trend tracking. |
| `/browse` | Fast headless browser for QA testing and site dogfooding. Navigate any URL, interact with elements, verify page state, diff before/after actions, take annotated screenshots, check responsive layouts, test forms and uploads, handle dialogs, and assert element states. |
| `/setup-browser-cookies` | Import cookies from your real Chromium browser into the headless browse session. |
| `/careful` | Safety guardrails for destructive commands. Warns before rm -rf, DROP TABLE, force-push, git reset --hard, kubectl delete, and similar destructive operations. |
| `/freeze` | Restrict file edits to a specific directory for the session. |
| `/guard` | Full safety mode: destructive command warnings + directory-scoped edits. |
| `/unfreeze` | Clear the freeze boundary set by /freeze, allowing edits to all directories again. |
| `/gstack-upgrade` | Upgrade gstack to the latest version. Detects global vs vendored install, runs the upgrade, and shows what's new. |
| `/autoplan` | Auto-review pipeline — reads the full CEO, design, eng, and DX review skills from disk and runs them sequentially with auto-decisions using 6 decision principles. |
| `/benchmark` | Performance regression detection using the browse daemon. Establishes baselines for page load times, Core Web Vitals, and resource sizes. |
| `/benchmark-models` | Cross-model benchmark for gstack skills. Runs the same prompt through Claude, GPT (via Codex CLI), and Gemini side-by-side — compares latency, tokens, cost, and optionally quality via LLM judge. |
| `/canary` | Post-deploy canary monitoring. Watches the live app for console errors, performance regressions, and page failures using the browse daemon. |
| `/claude` | Claude Code CLI wrapper for non-Claude hosts - three modes. Review: independent diff review via claude -p. |
| `/context-restore` | Restore working context saved earlier by /context-save. Loads the most recent saved state (across all branches by default) so you can pick up where you left off — even across Conductor workspace handoffs. |
| `/context-save` | Save working context. Captures git state, decisions made, and remaining work so any future session can pick up without losing a beat. |
| `/cso` | Chief Security Officer mode. Infrastructure-first security audit: secrets archaeology, dependency supply chain, CI/CD pipeline security, LLM/AI security, skill supply chain scanning, plus OWASP Top 10, STRIDE threat modeling, and active verification. |
| `/design-html` | Design finalization: generates production-quality Pretext-native HTML/CSS. |
| `/design-shotgun` | Design shotgun: generate multiple AI design variants, open a comparison board, collect structured feedback, and iterate. |
| `/devex-review` | Live developer experience audit. Uses the browse tool to actually TEST the developer experience: navigates docs, tries the getting started flow, times TTHW, screenshots error messages, evaluates CLI help text. |
| `/health` | Code quality dashboard. Wraps existing project tools (type checker, linter, test runner, dead code detector, shell linter), computes a weighted composite 0-10 score, and tracks trends over time. |
| `/land-and-deploy` | Land and deploy workflow. Merges the PR, waits for CI and deploy, verifies production health via canary checks. |
| `/landing-report` | Read-only queue dashboard for workspace-aware ship. Shows which VERSION slots are currently claimed by open PRs, which sibling Conductor workspaces have WIP work likely to ship soon, and what slot /ship would pick next. |
| `/learn` | Manage project learnings. Review, search, prune, and export what gstack has learned across sessions. |
| `/make-pdf` | Turn any markdown file into a publication-quality PDF. Proper 1in margins, intelligent page breaks, page numbers, cover pages, running headers, curly quotes and em dashes, clickable TOC, diagonal DRAFT watermark. |
| `/open-gstack-browser` | Launch GStack Browser — AI-controlled Chromium with the sidebar extension baked in. |
| `/pair-agent` | Pair a remote AI agent with your browser. One command generates a setup key and prints instructions the other agent can follow to connect. |
| `/plan-devex-review` | Interactive developer experience plan review. Explores developer personas, benchmarks against competitors, designs magical moments, and traces friction points before scoring. |
| `/plan-tune` | Self-tuning question sensitivity + developer psychographic for gstack (v1: observational). |
| `/scrape` | Pull data from a web page. First call on a new intent prototypes the flow via $B primitives and returns JSON. |
| `/setup-deploy` | Configure deployment settings for /land-and-deploy. Detects your deploy platform (Fly.io, Render, Vercel, Netlify, Heroku, GitHub Actions, custom), production URL, health check endpoints, and deploy status commands. |
| `/setup-gbrain` | Set up gbrain for this coding agent: install the CLI, initialize a local PGLite or Supabase brain, register MCP, capture per-remote trust policy. |
| `/skillify` | Codify the most recent successful /scrape flow into a permanent browser-skill on disk. |
| `/sync-gbrain` | Keep gbrain current with this repo's code and refresh agent search guidance in CLAUDE.md. |

Repo installs include the full generated skill pack. Heavy browser/runtime binaries stay machine-local in v1.
Installed release: `0.2.3`
<!-- END GSTACK-CODEX MANAGED BLOCK -->
