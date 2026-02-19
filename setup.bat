@echo off
REM Cochl.Sense API 자동 설치 스크립트 (Windows)
REM 모든 dependency를 자동으로 설치합니다

echo ==========================================
echo Cochl.Sense API 자동 설치 시작
echo ==========================================
echo.

REM 1. Python 버전 체크
echo [Step 1] Python 버전 확인 중...
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] python이 설치되어 있지 않습니다
    echo https://www.python.org/downloads/ 에서 Python을 다운로드하세요
    pause
    exit /b 1
)

for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo [OK] Python %PYTHON_VERSION% 발견

REM Python 3.9+ 확인 (간단한 체크)
python -c "import sys; exit(0 if sys.version_info >= (3, 9) else 1)" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python 3.9 이상이 필요합니다
    echo 현재 버전: %PYTHON_VERSION%
    echo https://www.python.org/downloads/ 에서 Python 3.9+ 를 설치하세요
    pause
    exit /b 1
)
echo [OK] Python 버전 확인 완료
echo.

REM 2. 가상환경 생성
echo [Step 2] 가상환경 생성 중...
if exist venv (
    echo [WARNING] 기존 venv 폴더가 발견되었습니다
    echo 기존 venv를 사용합니다
) else (
    python -m venv venv
    echo [OK] 가상환경 생성 완료
)
echo.

REM 3. 가상환경 활성화
echo [Step 3] 가상환경 활성화 중...
call venv\Scripts\activate.bat
if errorlevel 1 (
    echo [ERROR] 가상환경 활성화 실패
    pause
    exit /b 1
)
echo [OK] 가상환경 활성화 완료
echo.

REM 4. pip 업그레이드
echo [Step 4] pip 업그레이드 중...
python -m pip install --upgrade pip -q
echo [OK] pip 업그레이드 완료
echo.

REM 5. 핵심 dependency 설치
echo [Step 5] 핵심 라이브러리 설치 중...
echo    설치 중: flask, python-dotenv, pydub...
pip install flask python-dotenv pydub -q
echo [OK] 핵심 라이브러리 설치 완료
echo.

REM 6. cochl 패키지 설치 (--no-deps)
echo [Step 6] cochl 패키지 설치 중 (--no-deps)...
pip install cochl --no-deps -q
echo [OK] cochl 패키지 설치 완료
echo.

REM 7. cochl dependency 수동 설치
echo [Step 7] cochl dependencies 설치 중...
echo    설치 중: soundfile, requests, numpy, python-dateutil, pydantic, urllib3...
pip install soundfile requests numpy python-dateutil pydantic urllib3 -q
echo [OK] cochl dependencies 설치 완료
echo.

REM 8. 설치 확인
echo [Step 8] 설치 확인 중...
python -c "import cochl.sense, soundfile, requests, numpy, dateutil, pydantic, flask; from dotenv import load_dotenv; print('[OK] 모든 패키지가 정상적으로 import 되었습니다')"
if errorlevel 1 (
    echo [ERROR] 패키지 import 실패
    pause
    exit /b 1
)
echo.

REM 9. 프로젝트 구조 확인
echo [Step 9] 프로젝트 구조 확인 중...

if not exist uploads mkdir uploads
if not exist .gitignore (
    echo .env > .gitignore
    echo uploads/ >> .gitignore
    echo venv/ >> .gitignore
    echo __pycache__/ >> .gitignore
    echo *.pyc >> .gitignore
    echo [OK] .gitignore 파일 생성됨
) else (
    echo [OK] .gitignore 확인 완료
)

if exist config.json (
    echo [OK] config.json 확인 완료
) else (
    echo [WARNING] config.json이 없습니다
)

if exist .env (
    echo [OK] .env 파일 확인 완료
) else (
    echo [WARNING] .env 파일이 없습니다
    echo    나중에 API 키를 설정하려면 .env 파일을 만들고
    echo    COCHL_API_KEY=your_key_here 를 추가하세요
)
echo.

REM 10. 완료
echo ==========================================
echo [OK] 설치가 완료되었습니다!
echo ==========================================
echo.
echo 다음 단계:
echo 1. 가상환경 활성화:
echo    venv\Scripts\activate
echo.
echo 2. API 키가 설정되어 있는지 확인:
echo    type .env
echo.
echo 3. 테스트 스크립트 실행:
echo    python test_cochl.py your_audio_file.wav
echo.
echo 설치된 패키지 목록:
pip list | findstr /i "cochl soundfile pydantic flask python-dotenv pydub numpy requests"
echo.
pause
