#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Summarize weekly-commit
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 📊

# 검색할 기본 디렉터리 목록 (필요에 따라 추가 가능)
SEARCH_DIRS=(~/Desktop/project ~/Documents/toy)
# 최대 탐색 깊이 설정
MAX_DEPTH=3

# 통계 변수
TOTAL_REPOS=0
TOTAL_COMMITS=0

# 출력 리스트 배열 변수
declare -a OUTPUT_LINES

# 날짜 인자 처리 (기준일)
REFERENCE_DATE=${1:-$(date +%Y-%m-%d)}

# 요일 이름 배열 (월요일부터 시작)
WEEKDAYS=("월요일" "화요일" "수요일" "목요일" "금요일" "토요일" "일요일")

# 임시 파일 생성
REPO_DATA=$(mktemp)
GIT_DIRS=$(mktemp)
WEEK_DATES_FILE=$(mktemp)
COMMIT_LOG_FILE=$(mktemp)
OUTPUT_FILE=$(mktemp)

# 종료 시 임시 파일 정리
cleanup() {
    rm -f "$REPO_DATA" "$GIT_DIRS" "$WEEK_DATES_FILE" "$COMMIT_LOG_FILE" "$OUTPUT_FILE"
}
trap cleanup EXIT

# 주의 시작일(월요일)과 종료일(일요일) 계산
calculate_week_dates() {
    local ref_date="$1"
    
    # macOS에서 요일 구하기 (1=월요일, 7=일요일)
    local day_of_week=$(date -j -f "%Y-%m-%d" "$ref_date" "+%u")
    
    # 요일에 따라 월요일 날짜 계산
    local days_to_monday=$((day_of_week - 1))
    if [ $days_to_monday -eq 0 ]; then
        WEEK_START="$ref_date"
    else
        WEEK_START=$(date -j -v-${days_to_monday}d -f "%Y-%m-%d" "$ref_date" +%Y-%m-%d)
    fi
    
    # 요일에 따라 일요일 날짜 계산
    local days_to_sunday=$((7 - day_of_week))
    if [ $days_to_sunday -eq 0 ]; then
        WEEK_END="$ref_date"
    else
        WEEK_END=$(date -j -v+${days_to_sunday}d -f "%Y-%m-%d" "$ref_date" +%Y-%m-%d)
    fi
    
    # 주간 날짜 배열 생성 (월~일)
    for i in {0..6}; do
        date -j -v+${i}d -f "%Y-%m-%d" "$WEEK_START" +%Y-%m-%d >> "$WEEK_DATES_FILE"
    done
    
    echo "주간 커밋 조회: $WEEK_START ~ $WEEK_END" | tee -a "$OUTPUT_FILE"
}

# 저장소 순회 및 커밋 확인 함수
find_git_repos() {
    local base_dir="$1"
    
    # .git 디렉터리 찾기 (임시 파일 사용)
    find "$base_dir" -maxdepth "$MAX_DEPTH" -type d -name ".git" > "$GIT_DIRS"
    
    while IFS= read -r git_dir; do
        repo_dir=$(dirname "$git_dir")  # .git의 상위 폴더가 실제 프로젝트 폴더
        repo_name=$(basename "$repo_dir")
        local has_commits=false
        
        # Git 저장소인지 확인
        if cd "$repo_dir" && git rev-parse --is-inside-work-tree &>/dev/null; then
            if git log --oneline &>/dev/null; then
                # 주의 각 날짜에 대해 커밋 확인
                day_index=0
                while IFS= read -r current_date; do
                    # 해당 날짜의 커밋 로그 가져오기
                    git log --all --since="$current_date 00:00:00" --until="$current_date 23:59:59" --author="$(git config user.name)" --oneline | sed 's/^/[/; s/ /] /1' > "$COMMIT_LOG_FILE"
                    
                    if [ -s "$COMMIT_LOG_FILE" ]; then
                        has_commits=true
                        commit_count=$(wc -l < "$COMMIT_LOG_FILE" | tr -d ' ')
                        
                        # 저장소와 요일별로 커밋 저장 (파일에 저장)
                        echo "COMMIT_DATA:$repo_name:$day_index:START" >> "$REPO_DATA"
                        cat "$COMMIT_LOG_FILE" >> "$REPO_DATA"
                        echo "COMMIT_DATA:$repo_name:$day_index:END" >> "$REPO_DATA"
                        
                        ((TOTAL_COMMITS+=commit_count))
                    fi
                    
                    ((day_index++))
                done < "$WEEK_DATES_FILE"
                
                # 이 저장소에 커밋이 있으면 카운트 증가
                if [ "$has_commits" = true ]; then
                    ((TOTAL_REPOS++))
                    echo "REPO:$repo_name" >> "$REPO_DATA"
                fi
            fi
        fi
    done < "$GIT_DIRS"
}

# 요일별 그룹핑된 출력 생성 함수
generate_grouped_output() {
    # 저장소 목록 추출
    grep "^REPO:" "$REPO_DATA" | sort | uniq > "$GIT_DIRS"
    
    # 먼저 요일별 그룹핑
    for day_index in {0..6}; do
        # 해당 요일에 커밋이 있는지 확인
        if grep -q "COMMIT_DATA:.*:$day_index:" "$REPO_DATA"; then
            echo "" >> "$OUTPUT_FILE"
            echo "${WEEKDAYS[$day_index]}" >> "$OUTPUT_FILE"
            
            # 레포지토리별로 순회
            while IFS= read -r repo_line; do
                repo_name=${repo_line#REPO:}
                
                # 해당 요일의 이 레포지토리 커밋 데이터 시작 태그 찾기
                if grep -q "^COMMIT_DATA:$repo_name:$day_index:START" "$REPO_DATA"; then
                    echo "    Repository: $repo_name" >> "$OUTPUT_FILE"
                    
                    # 시작 태그와 종료 태그 사이의 모든 라인 추출
                    start_line=$(grep -n "^COMMIT_DATA:$repo_name:$day_index:START" "$REPO_DATA" | cut -d':' -f1)
                    end_line=$(grep -n "^COMMIT_DATA:$repo_name:$day_index:END" "$REPO_DATA" | cut -d':' -f1)
                    
                    if [ -n "$start_line" ] && [ -n "$end_line" ]; then
                        # 시작 라인 다음부터 종료 라인 전까지의 내용 추출
                        sed -n "$((start_line+1)),$((end_line-1))p" "$REPO_DATA" | while IFS= read -r line; do
                            echo "        $line" >> "$OUTPUT_FILE"
                        done
                    fi
                fi
            done < "$GIT_DIRS"
        fi
    done
}

# 메인 실행 코드
# 주 시작일/종료일 계산
calculate_week_dates "$REFERENCE_DATE"

# 모든 지정 디렉터리에서 Git 저장소 검색
for dir in "${SEARCH_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        find_git_repos "$dir"
    fi
done

# 그룹핑된 출력 생성
generate_grouped_output

# 요약 출력
echo "" >> "$OUTPUT_FILE"
echo "🔍 주간 요약 ($WEEK_START ~ $WEEK_END)" >> "$OUTPUT_FILE"
echo "📂 커밋 활동이 있는 저장소: $TOTAL_REPOS" >> "$OUTPUT_FILE"
echo "📝 총 커밋 수: $TOTAL_COMMITS" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 출력 파일 내용 표시
cat "$OUTPUT_FILE"

# 출력 내용 클립보드 저장 (macOS에서 pbcopy 사용)
cat "$OUTPUT_FILE" | pbcopy