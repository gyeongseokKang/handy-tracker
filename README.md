# Handy Tracker

<div align="center">
  <h1>🔍 Handy Tracker</h1>
  <p>업무 자동화를 위한 스크립트 모음</p>
</div>

## 설치

아래 명령어로 저장소를 클론합니다:

```bash
git clone https://github.com/yourusername/handy-tracker.git
cd handy-tracker
chmod +x script/*.sh
```

## 커밋 요약 도구

하루 또는 주 단위로 Git 커밋을 요약하여 업무 보고서나 회고 작성에 활용할 수 있는 도구입니다.

### 일일 커밋 요약

- [`summarize-daliy-commit.sh`](./docs/summarize-daliy-commit.md) &mdash; 지정된 날짜(기본: 오늘)의 모든 Git 저장소 커밋을 요약합니다.

### 주간 커밋 요약

- [`summarize-weekly-commit.sh`](./docs/summarize-weekly-commit.md) &mdash; 지정된 날짜가 속한 주의 모든 Git 저장소 커밋을 요약합니다.

## 주요 기능

- 여러 Git 저장소의 커밋을 한 번에 검색 및 요약
- 일일/주간 단위 커밋 통계 자동 생성
- 클립보드 자동 복사로 보고서 작성 시간 단축
- 저장소/프로젝트별 그룹화로 정리된 결과 제공

## 요구사항

- Bash 쉘
- Git
- macOS (pbcopy 명령어 사용)

## 사용 예시

### 일일 커밋 요약

```bash
# 오늘 작성한 모든 커밋 요약
./script/summarize-daliy-commit.sh

# 특정 날짜의 커밋 요약
./script/summarize-daliy-commit.sh 2023-09-15
```

### 주간 커밋 요약

```bash
# 이번 주 전체 커밋 요약
./script/summarize-weekly-commit.sh

# 특정 날짜가 속한 주의 커밋 요약
./script/summarize-weekly-commit.sh 2023-09-15
```

## 참고

- 스크립트는 macOS 환경에서 테스트되었습니다. 다른 운영체제에서는 `pbcopy` 명령어 대신 다른 방법으로 클립보드에 복사해야 할 수 있습니다.
- 파일명에 공백이 있으면 실행 시 따옴표로 감싸거나 이스케이프 문자를 사용해야 합니다.

## 라이센스

이 프로젝트는 MIT 라이센스로 제공됩니다.

## 기여하기

기여는 언제나 환영합니다! Pull Request를 통해 기여해주세요.
