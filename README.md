# Play Anything

거의 모든 미디어 파일을 **Blackmagic DeckLink SDI 출력**으로 바로 송출하는 Windows용 플레이어입니다.
코덱·해상도·프레임레이트·오디오 구성이 제각각인 파일(휴대폰 영상, CCTV, 유튜브 클립, 정지 이미지 등)을 자동 분석해 방송 규격(1080i 29.97 / UHD 59.94)으로 변환하며 실시간 출력합니다.

[AutoHotkey v1](https://www.autohotkey.com/)로 작성된 GUI가 **FFmpeg**(DeckLink 출력), **mpv**(프리뷰·IN/OUT 마킹), **MediaInfo**(파일 분석)를 제어합니다.

> Created & maintained by sendust (SBS)

---

## 주요 기능

- **아무 파일이나 SDI 출력** — MediaInfo로 해상도·스캔 방식·프레임레이트·오디오 채널을 분석하고, 알맞은 FFmpeg 필터를 자동 선택
  - 프로그레시브 → 인터레이스 변환, 1440 → 1920 스케일링, 레터박스/필러박스 패딩
  - 모노 1~32채널 / 스테레오 다중 트랙을 8채널(7.1)·16채널 PCM으로 매핑
  - 오디오만 있는 파일은 테스트 화면 + 자막과 함께 출력
- **정지 이미지 출력** — 이미지 파일은 10초간 출력
- **타이틀 카드** — 입력한 텍스트로 타이틀 화면(5초)을 만들어 송출 (`naverdic.ttf` 폰트 사용)
- **프리뷰 & IN/OUT 마킹** — mpv로 미리 보면서 `i` / `o` 키로 구간 지정, 지정한 구간만 출력
- **플레이리스트** — 클립·타이틀을 목록에 추가, 순서 변경, 선택 행부터 연속 재생, 저장/불러오기
- **파일명 번호 매기기** — 플레이리스트 순서대로 파일명 앞에 `0001_` 형식의 번호 부여
- **SDI 프리뷰 모니터** — 출력 중인 영상을 RTSP로 재전송해 작은 mpv 창으로 확인
- **유튜브 다운로드** — URL과 저장 파일명을 입력해 `youtube-dl`로 바로 다운로드
- **최근 재생 목록** — 최근 재생한 20개 클립 표시
- **오류 리포트** — FFmpeg가 바로 종료되면 `error_report.txt`를 생성해 메모장으로 표시
- **UHD 출력** (개발 중) — 3840x2160 59.94p 출력용 필터 세트 포함

## 구성 요소

| 파일 | 설명 |
|---|---|
| `PlayAnything.ahk` | 메인 프로그램 (GUI, 재생 제어, 플레이리스트, 유튜브 다운로드) |
| `param_processor.ahk` | 미디어 속성 → FFmpeg/mpv 필터 파라미터 매핑 (HD/UHD, 오디오 구성별) |
| `mediainfo.ahk` + `MediaInfo.dll` | MediaInfo 래퍼 클래스 |
| `Socket_nonblock.ahk` | 논블로킹 UDP 소켓 (FFmpeg 진행 상황 수신용) |
| `mark_inout_file.lua` | mpv IN/OUT 마킹 스크립트 |
| `playanything.ini` | 설정 파일 |
| `naverdic.ttf` | 타이틀 생성용 폰트 |
| `list.txt` | 저장된 플레이리스트 |
| `bin/` | mpv, RTSP 서버 설정, 아이콘, DeckLink 장치 확인 배치 파일 |
| `backup_to_jungbi2.bat`, `restore_from_jungbi2.bat` | 사내 공유 폴더로 백업/복원 (robocopy `/mir`) |
| `PlayAnything_backup*.ahk`, `*.bak` | 이전 버전 백업 |

## 요구 사항

- Windows (64bit 권장)
- [AutoHotkey v1.1](https://www.autohotkey.com/)
- Blackmagic DeckLink 카드 + Desktop Video 드라이버
- 아래 실행 파일을 `bin\`에 직접 넣어야 합니다 (`.gitignore`로 저장소에서 제외됨)

  | 파일 | 용도 |
  |---|---|
  | `bin\ffmpeg.exe` | DeckLink 출력을 지원하는 FFmpeg 빌드 |
  | `bin\mpv.exe` | 프리뷰 / SDI 모니터 (`mpv.com`은 포함됨) |
  | `bin\rtsp-simple-server.exe` | SDI 프리뷰용 RTSP 서버 (설정: `rtsp-simple-server.yml`) |
  | `bin\youtube-dl.exe` | 유튜브 다운로드 |
  | `bin\DeviceConfigure.exe` | 시작 시 DeckLink 장치 초기화 (`init_string` 인자 사용) |

## 설치 및 실행

1. 저장소를 클론하고 위 실행 파일들을 `bin\`에 복사합니다.
2. `log\` 폴더를 생성합니다 (`log\all_player.log`에 기록).
3. 출력할 DeckLink 장치 이름을 확인합니다.
   ```bat
   bin\list_decklink.bat
   ```
4. `playanything.ini`를 환경에 맞게 수정합니다.
5. `PlayAnything.ahk`를 실행합니다.

## 설정 (`playanything.ini`)

```ini
[general]
ffmpeg_port = 8877                          ; FFmpeg 진행상황 수신 UDP 포트
decklink = DeckLink Studio 4K               ; 출력 DeckLink 장치 이름
init_string = -d 0 -o 3                     ; DeviceConfigure.exe 인자
sdi_preview = rtsp://127.0.0.1:8554/anything1   ; SDI 프리뷰 RTSP 주소
sdi_geometry = --geometry=640x480+10+30     ; SDI 프리뷰 창 크기/위치

[youtube]
location = d:\capture                       ; 유튜브 다운로드 폴더
```

## 사용 방법

### 단일 클립 출력
1. 파일을 창에 **드래그 앤 드롭** → 정보창에 미디어 분석 결과 표시
2. **Preview** — mpv로 열어 `i`(IN) / `o`(OUT)로 구간 지정 (생략 시 전체 출력)
3. **CUE** — 첫 프레임을 SDI로 출력해 대기
4. **PLAY** — SDI 출력 시작 / **STOP** — 정지

화면 상단에 현재 TC, IN/OUT 지점, 남은 시간이 표시됩니다.

### 플레이리스트
- **ADD ▼** — 현재 클립을 목록에 추가 (여러 파일을 한꺼번에 드롭하면 자동 추가)
- **TITLE ▼** — 입력한 텍스트로 타이틀 카드 추가 (`AUTO TITLE` 체크 시 클립 추가 때마다 자동 삽입)
- **NUMBER** — 목록 순서대로 실제 파일명 앞에 번호 부여
- **▲ / ▼ / Delete** — 순서 변경 / 삭제
- 행 **더블클릭** — 해당 클립 불러오기
- **PLAY_LIST** — 선택한 행부터 끝까지 연속 재생
- **SAVE EDIT / LOAD** — `list.txt`로 저장 / 불러오기

### 유튜브 다운로드
`Youtube URL`과 `YOUTUBE SAVE FILENAME`을 입력하고 **Download**를 누르면 `[youtube] location` 폴더에 `<파일명>_<시각>.<ext>`로 저장됩니다.

## 단축키 (프리뷰 창)

| 키 | 동작 |
|---|---|
| `i` / `o` | IN / OUT 지점 지정 |
| `Ctrl + i` / `Ctrl + o` | IN / OUT 지점으로 이동 |
| `d` | 길이 확인 |
| `Enter` | 현재 클립을 플레이리스트에 추가 |
| `j` / `k` / `l` | 1초 뒤로 / 일시정지 / 1초 앞으로 |

## 참고

- 미디어 길이에 1초를 더해 출력합니다 (DeckLink 출력 안정성 확보).
- 기본 출력 규격은 1080i 29.97 (`uyvy422`, PCM 16bit)입니다. UHD 출력(`play_media_uhd`)은 개발 중입니다.
