# 해당 레포는 업무 자동화를 위한 스크립트를 모아둔 레포.


## find_daliy_git_commits.sh

이 스크립트는 지정된 디렉터리 내의 Git 저장소를 검색하고, 오늘 날짜 기준으로 사용자가 작성한 커밋 내역을 요약하여 출력합니다. 또한, 결과를 클립보드에 복사합니다.

### 왜 만들었는가?

- 하루에 한번씩 커밋로그를 보면서 하루를 반성하고 정리하기 위해 만듬.
- 회사에서는 github과 giblab를 주로 사용하고, 개인프로젝트는 github으로 커밋하기에 한컴퓨터에서 한 커밋을 모으고 싶었음.

### 요구 사항

- Bash 쉘
- Git
- `pbcopy` 명령어 (macOS에서 기본 제공)

### 사용법

1. 스크립트를 실행 가능한 상태로 만듭니다:

   ```bash
   chmod +x script/find_daliy_git_commits.sh
   ```

2. 스크립트를 실행합니다:

   ```bash
   ./script/find_daliy_git_commits.sh
   ```
   ![image](https://github.com/user-attachments/assets/8ef33c23-4b4a-4592-85e8-3da0a314c548)


3. 별도의 날짜를 입력하여 실행할 수 있습니다:

   ```bash
   ./script/find_daliy_git_commits.sh YYYY-MM-DD
   ```
   ![image](https://github.com/user-attachments/assets/25cedcb9-ee31-40f5-bd2a-08b5aefdfe08)


### 스크립트 설명

- **검색 디렉터리**: `SEARCH_DIRS` 배열에 지정된 디렉터리에서 Git 저장소를 검색합니다. 기본값은 `~/Desktop/project`와 `~/Documents/toy`입니다. 필요에 따라 디렉터리를 추가하거나 수정할 수 있습니다.
- **최대 탐색 깊이**: `MAX_DEPTH` 변수로 설정된 깊이까지 디렉터리를 탐색합니다. 기본값은 3입니다.
- **커밋 내역**: 각 저장소에서 지정된 날짜 기준으로 사용자가 작성한 커밋 내역을 검색하고, 저장소 이름과 함께 출력합니다.
- **요약**: 총 저장소 수와 총 커밋 수를 요약하여 출력합니다.
- **클립보드 저장**: 결과를 클립보드에 복사하여 다른 곳에 쉽게 붙여넣을 수 있습니다.

### 참고

- 스크립트는 macOS 환경에서 테스트되었습니다. 다른 운영체제에서는 `pbcopy` 명령어 대신 다른 방법으로 클립보드에 복사해야 할 수 있습니다.
