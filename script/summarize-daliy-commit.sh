#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Summarize daliy-commit
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖

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

# 임시 파일 생성
GIT_DIRS=$(mktemp)
COMMIT_LOG_FILE=$(mktemp)
OUTPUT_FILE=$(mktemp)

# 종료 시 임시 파일 정리
cleanup() {
    rm -f "$GIT_DIRS" "$COMMIT_LOG_FILE" "$OUTPUT_FILE"
}
trap cleanup EXIT

# 저장소 순회 및 커밋 확인 함수
find_git_repos() {
    local base_dir="$1"
    
    # .git 디렉터리 찾기 (임시 파일 사용)
    find "$base_dir" -maxdepth "$MAX_DEPTH" -type d -name ".git" > "$GIT_DIRS"
    
    while IFS= read -r git_dir; do
        repo_dir=$(dirname "$git_dir")  # .git의 상위 폴더가 실제 프로젝트 폴더
        repo_name=$(basename "$repo_dir")
        
        # Git 저장소인지 확인 후 커밋이 있는 경우만 로그 가져오기
        if cd "$repo_dir" && git rev-parse --is-inside-work-tree &>/dev/null; then
            if git log --oneline &>/dev/null; then
                # 해당 날짜의 커밋 로그 가져오기
                git log --all --since="$TARGET_DATE 00:00:00" --until="$TARGET_DATE 23:59:59" --author="$(git config user.name)" --oneline | sed 's/^/[/; s/ /] /1' > "$COMMIT_LOG_FILE"
                
                # 커밋 내역이 있으면 저장소 이름과 함께 출력
                if [ -s "$COMMIT_LOG_FILE" ]; then
                    ((TOTAL_REPOS++))
                    COMMIT_COUNT=$(wc -l < "$COMMIT_LOG_FILE" | tr -d ' ')
                    ((TOTAL_COMMITS+=COMMIT_COUNT))
                    
                    echo "" >> "$OUTPUT_FILE"
                    echo "📁 Repository: $repo_name" >> "$OUTPUT_FILE"
                    cat "$COMMIT_LOG_FILE" >> "$OUTPUT_FILE"
                fi
            fi
        fi
    done < "$GIT_DIRS"
}

echo "일일 커밋 조회: $TARGET_DATE" > "$OUTPUT_FILE"

# 설정한 모든 폴더에서 Git 저장소 검색
for dir in "${SEARCH_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        find_git_repos "$dir"
    fi
done

# 요약 출력
echo "" >> "$OUTPUT_FILE"
echo "🔍 Summary" >> "$OUTPUT_FILE"
echo "📂 Total git repositories: $TOTAL_REPOS" >> "$OUTPUT_FILE"
echo "📝 Total git commits: $TOTAL_COMMITS" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 출력 파일 내용 표시
cat "$OUTPUT_FILE"

# 출력 내용 클립보드 저장 (macOS에서 pbcopy 사용)
cat "$OUTPUT_FILE" | pbcopy