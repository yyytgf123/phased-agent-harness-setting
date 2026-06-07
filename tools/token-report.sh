#!/usr/bin/env bash
# token-report.sh — 하네스 키트의 토큰/중복 비용을 측정한다.
#
# 토크나이저(tiktoken 등)가 없는 환경을 가정하므로 "문자 수(chars)"를 1차 지표로 쓴다.
# 문자 수는 같은 성격의 텍스트끼리 전후를 비교할 때 가장 안정적인 프록시다(나누는 상수가 소거됨).
# 토큰 추정치는 chars/TOK_DIV 의 거친 근사다. KR/EN 혼합이라 절대값은 부정확하니
# "상대 비교"에만 쓴다. 자세한 한계는 _shared/metrics.md 참조.
#
# 사용법:
#   tools/token-report.sh --build            # 키트 docs(빌드타임) 토큰을 영역별로 집계
#   tools/token-report.sh --runtime <path>   # 생성된 프로젝트의 런타임 비용(CLAUDE.md/agents/skills)
#   tools/token-report.sh --dup              # 반복 규칙의 등장 횟수(중복률) 측정
#   tools/token-report.sh --gate <path>      # 임계 위반 시 non-zero exit (Phase 6 게이트 / Stop hook)
#
# 환경변수: TOK_DIV (기본 4) — 토큰 추정 나눗수.

set -euo pipefail

# 키트 루트 = 이 스크립트의 상위 디렉터리
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TOK_DIV="${TOK_DIV:-4}"

# --- 공통: 파일 글롭의 (파일수, 문자합)을 출력 ------------------------------
# 인자: 디렉터리 또는 파일 경로들. .md/.tmpl/.sh 만 집계.
count_chars() {
  local total=0 files=0 c
  for p in "$@"; do
    [ -e "$p" ] || continue
    while IFS= read -r f; do
      c=$(wc -m < "$f" | tr -d ' ')
      total=$((total + c))
      files=$((files + 1))
    done < <(find "$p" -type f \( -name '*.md' -o -name '*.tmpl' -o -name '*.sh' \) 2>/dev/null)
  done
  echo "$files $total"
}

row() { # name files chars
  local name="$1" files="$2" chars="$3"
  printf '%-26s %5s files %9s chars  ~%8s tok\n' \
    "$name" "$files" "$chars" "$((chars / TOK_DIV))"
}

# --- --build: 키트 문서 비용 -------------------------------------------------
build_report() {
  echo "# Build-time cost (키트 docs — 하네스 구축 시 로드)"
  echo "# proxy=chars, ~tok=chars/$TOK_DIV (상대 비교용)"
  echo "----------------------------------------------------------------------"
  local gtotal=0
  # 루트(README, ORCHESTRATOR)
  read -r f c < <(count_chars "$ROOT/README.md" "$ROOT/ORCHESTRATOR.md")
  row "root (README+ORCH)" "$f" "$c"; gtotal=$((gtotal + c))
  # steps, kb, catalog, templates (빌드 시 단계별로 로드됨)
  for area in steps kb catalog templates; do
    [ -d "$ROOT/$area" ] || continue
    read -r f c < <(count_chars "$ROOT/$area")
    row "$area/" "$f" "$c"; gtotal=$((gtotal + c))
  done
  echo "----------------------------------------------------------------------"
  printf '%-26s %5s        %9s chars  ~%8s tok\n' "TOTAL (build-loaded)" "" "$gtotal" "$((gtotal / TOK_DIV))"
  # tools/ 는 빌드 시 로드되지 않음 — 참고로만 표기
  if [ -d "$ROOT/tools" ]; then
    read -r f c < <(count_chars "$ROOT/tools")
    row "(ref) tools/ not-loaded" "$f" "$c"
  fi
}

# --- --runtime <path>: 생성 산출물 비용 -------------------------------------
runtime_report() {
  local proj="$1"
  [ -d "$proj" ] || { echo "ERROR: 경로 없음: $proj" >&2; exit 1; }
  echo "# Runtime cost (생성 산출물 — 매 작업 로드)  target=$proj"
  echo "# proxy=chars, ~tok=chars/$TOK_DIV"
  echo "----------------------------------------------------------------------"
  # (a) 항상 로드: 루트 claude.md(헌법) — 가장 중요한 지표
  local consti=""
  [ -f "$proj/claude.md" ] && consti="$proj/claude.md"
  [ -z "$consti" ] && [ -f "$proj/CLAUDE.md" ] && consti="$proj/CLAUDE.md"
  if [ -n "$consti" ]; then
    local lines chars
    lines=$(wc -l < "$consti" | tr -d ' ')
    chars=$(wc -m < "$consti" | tr -d ' ')
    printf 'ALWAYS-LOADED claude.md   %5s lines %9s chars  ~%8s tok  %s\n' \
      "$lines" "$chars" "$((chars / TOK_DIV))" \
      "$([ "$lines" -le 120 ] && echo '[OK <=120]' || echo '[OVER 120!]')"
  else
    echo "ALWAYS-LOADED claude.md   (없음)"
  fi
  # (b) on-trigger: agents (호출 시 1개씩 로드 → 평균/최대가 의미있음)
  if [ -d "$proj/.claude/agents" ]; then
    read -r f c < <(count_chars "$proj/.claude/agents")
    [ "$f" -gt 0 ] && row "ON-CALL agents (sum)" "$f" "$c" && \
      printf '%-26s %5s        %9s chars/agent avg\n' "  per-agent avg" "" "$((c / f))"
  fi
  # (c) on-trigger: skills (SKILL.md body — 트리거 시 로드)
  if [ -d "$proj/.claude/skills" ]; then
    local sf=0 sc=0 cc over=0
    while IFS= read -r sk; do
      cc=$(wc -m < "$sk" | tr -d ' ')
      local sl; sl=$(wc -l < "$sk" | tr -d ' ')
      sc=$((sc + cc)); sf=$((sf + 1))
      [ "$sl" -gt 500 ] && over=$((over + 1))
    done < <(find "$proj/.claude/skills" -name 'SKILL.md' 2>/dev/null)
    [ "$sf" -gt 0 ] && row "ON-TRIGGER skills (sum)" "$sf" "$sc" && \
      printf '%-26s %5s        %9s chars/skill avg  (%s body>500줄)\n' \
        "  per-skill avg" "" "$((sc / sf))" "$over"
  fi
  echo "----------------------------------------------------------------------"
  echo "핵심: ALWAYS-LOADED 가 매 작업 비용. agents/skills 는 호출/트리거 시에만."
}

# --- --dup: 반복 규칙 등장 횟수(중복률) -------------------------------------
dup_report() {
  echo "# Duplication (반복 규칙 — 키트 전체에서 등장한 파일 수)"
  echo "# 목표: 권위 소스 1 + 1줄 참조 N. 전문(full restatement) 중복을 줄인다."
  echo "----------------------------------------------------------------------"
  dup_one() { # label  pattern
    local n
    n=$(grep -rlE "$2" "$ROOT/steps" "$ROOT/kb" "$ROOT/catalog" "$ROOT/templates" 2>/dev/null | wc -l | tr -d ' ')
    printf '%-34s %3s files\n' "$1" "$n"
  }
  dup_one "안전규칙 (terraform apply)"   'terraform apply'
  dup_one "안전규칙 (apply/migrate/secret)" 'apply/migrate/secret|apply.*migrate.*secret'
  dup_one "에러핸들링 (1회 재시도)"        '1회 재시도|재시도 후'
  dup_one "Phase7 점수 (0.7)"             '0\.7'
  dup_one "scope 분리 (drift)"            'drift|범위 침범'
  dup_one "관찰은 차단하지 않는다"          '관찰.*차단|차단.*관찰'
  echo "----------------------------------------------------------------------"
}

# --- --gate <path>: 임계 위반 시 non-zero exit (Phase 6 게이트 / Stop hook용) ------
# 결정적 강제 — "말로 말고 시스템으로"(design-principles §1). 통과=0, 위반=1.
gate_report() {
  local proj="$1" fail=0
  [ -d "$proj" ] || { echo "GATE ERROR: 경로 없음: $proj" >&2; exit 2; }
  echo "# Token gate  target=$proj"
  # 1) 헌법 claude.md ≤ 120줄 (상시 로드 상한 — 60줄 강박은 폐지, 깊은 내용은 docs/로)
  local consti=""
  [ -f "$proj/claude.md" ] && consti="$proj/claude.md"
  [ -z "$consti" ] && [ -f "$proj/CLAUDE.md" ] && consti="$proj/CLAUDE.md"
  if [ -n "$consti" ]; then
    local l; l=$(wc -l < "$consti" | tr -d ' ')
    if [ "$l" -le 120 ]; then echo "  [OK]   claude.md ${l}줄 (≤120)"
    else echo "  [FAIL] claude.md ${l}줄 > 120 — 깊은 내용은 docs/(SDD)로 분리"; fail=1; fi
  else
    echo "  [FAIL] 루트 claude.md(헌법) 없음"; fail=1
  fi
  # 2) skill 본문 ≤ 500줄
  while IFS= read -r sk; do
    local sl; sl=$(wc -l < "$sk" | tr -d ' ')
    [ "$sl" -gt 500 ] && { echo "  [FAIL] ${sk#$proj/} ${sl}줄 > 500 — references/로 분리"; fail=1; }
  done < <(find "$proj/.claude/skills" -name 'SKILL.md' 2>/dev/null)
  # 3) 안전 표준응답 단일 소스 — 스킬에 전문 복붙 금지(루트 claude.md '# CRITICAL — Safety' 참조해야)
  # grep은 매치 없음(=정상)일 때 exit 1 → set -e/pipefail에 걸리므로 || true 로 감싼다.
  local dupes
  dupes=$( { grep -rl '직접 실행하지 않습니다' "$proj/.claude/skills" 2>/dev/null || true; } | wc -l | tr -d ' ')
  if [ "${dupes:-0}" -gt 0 ]; then
    echo "  [FAIL] 표준 응답이 스킬 ${dupes}곳에 복붙됨 — 루트 claude.md '# CRITICAL — Safety' 참조로 교체"; fail=1
  else echo "  [OK]   안전 표준응답 단일 소스"; fi
  # 4) 옛 .claude/rules/safety.md 잔재 금지(폐지됨 — 헌법+훅으로 병합)
  if [ -e "$proj/.claude/rules/safety.md" ]; then
    echo "  [FAIL] .claude/rules/safety.md 잔재 — 폐지됨(헌법 claude.md + 훅으로 병합)"; fail=1
  fi
  echo "----------------------------------------------------------------------"
  if [ "$fail" -eq 0 ]; then echo "GATE PASS"; else echo "GATE FAIL (위 항목 수정 후 재실행)"; fi
  return "$fail"
}

case "${1:-}" in
  --build)   ORCHESTRATOR_PATH="$ROOT/ORCHESTRATOR.md"; build_report ;;
  --runtime) shift; runtime_report "${1:?사용법: --runtime <프로젝트경로>}" ;;
  --dup)     dup_report ;;
  --gate)    shift; if gate_report "${1:?사용법: --gate <프로젝트경로>}"; then exit 0; else exit 1; fi ;;
  *) echo "사용법: $0 --build | --runtime <path> | --dup | --gate <path>" >&2; exit 2 ;;
esac
