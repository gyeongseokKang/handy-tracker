#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title daliy-commit
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖

#!/bin/bash
# 검색할 기본 디렉터리 목록 (필요에 따라 추가 가능)
SEARCH_DIRS=(~/Desktop/project ~/Documents/toy)
# 최대 탐색 깊이 설정
MAX_DEPTH=3

# 통계 변수
TOTAL_REPOS=0
TOTAL_COMMITS=0

# 출력 리스트 배열 변수
OUTPUT_LINES=()

# 날짜 인자 처리
TARGET_DATE=${1:-$(date +%Y-%m-%d)}

# 저장소 순회 및 커밋 확인 함수
find_git_repos() {
    local base_dir="$1"
    local repos=()

    # .git 디렉터리 찾기
    while IFS= read -r git_dir; do
        repos+=("$git_dir")
    done < <(find "$base_dir" -maxdepth "$MAX_DEPTH" -type d -name ".git")

    for git_dir in "${repos[@]}"; do
        repo_dir=$(dirname "$git_dir")  # .git의 상위 폴더가 실제 프로젝트 폴더
        commit_logs=""

        # Git 저장소인지 확인 후 커밋이 있는 경우만 로그 가져오기
        if cd "$repo_dir" && git rev-parse --is-inside-work-tree &>/dev/null; then
            if git log --oneline &>/dev/null; then
                commit_logs=$(git log --all --since="$TARGET_DATE 00:00:00" --until="$TARGET_DATE 23:59:59" --author="$(git config user.name)" --oneline | sed 's/^/[/; s/ /] /1')
            fi
        fi

        # 커밋 내역이 있으면 저장소 이름과 함께 출력
        if [ -n "$commit_logs" ]; then
            ((TOTAL_REPOS++))
            COMMIT_COUNT=$(echo "$commit_logs" | wc -l)
            ((TOTAL_COMMITS+=COMMIT_COUNT))
            OUTPUT_LINES+=("")
            OUTPUT_LINES+=("📁 Repository: $(basename "$repo_dir")")
            OUTPUT_LINES+=("$commit_logs")
        fi
    done
}

# 설정한 모든 폴더에서 Git 저장소 검색
for dir in "${SEARCH_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        find_git_repos "$dir"
    fi
done

# 요약 출력
OUTPUT_LINES+=("")
OUTPUT_LINES+=("🔍 Summary")
OUTPUT_LINES+=("📂 Total git repositories: $TOTAL_REPOS")
OUTPUT_LINES+=("📝 Total git commits: $TOTAL_COMMITS")
OUTPUT_LINES+=("")

# 출력 리스트 터미널에 출력
printf "%s\n" "${OUTPUT_LINES[@]}"

# 출력 리스트 클립보드 저장 (macOS에서 pbcopy 사용)
printf "%s\n" "${OUTPUT_LINES[@]}" | pbcopy