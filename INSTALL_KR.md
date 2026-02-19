# Cochl.Sense API 설치 가이드 (한국어)

이 가이드는 Python 환경 설정 없이 **바로 실행 가능한** 자동 설치 방법을 제공합니다.

## 🚀 빠른 시작 (추천)

### macOS / Linux

터미널에서 다음 명령어만 실행하세요:

```bash
./setup.sh
```

### Windows

명령 프롬프트나 PowerShell에서 다음 명령어를 실행하세요:

```cmd
setup.bat
```

**끝입니다!** 스크립트가 자동으로 모든 것을 설치합니다.

---

## 📋 자동 설치 스크립트가 하는 일

자동 설치 스크립트는 다음을 **자동으로** 처리합니다:

1. ✅ Python 버전 확인 (3.9+ 필요)
2. ✅ 가상환경 자동 생성
3. ✅ pip 업그레이드
4. ✅ 핵심 라이브러리 설치 (flask, python-dotenv, pydub)
5. ✅ cochl 패키지 설치 (PyPI 이슈 우회)
6. ✅ cochl dependencies 설치 (soundfile, numpy, requests, python-dateutil, pydantic)
7. ✅ 설치 확인 및 검증
8. ✅ 프로젝트 구조 설정 (.gitignore, uploads 폴더 등)

**수동으로 할 필요가 전혀 없습니다!**

---

## ⚡ 설치 후 바로 사용하기

### 1. API 키 확인

`.env` 파일에 API 키가 있는지 확인:

```bash
cat .env  # macOS/Linux
type .env  # Windows
```

API 키가 없다면 [dashboard.cochl.ai](https://dashboard.cochl.ai)에서 발급받으세요.

### 2. 테스트 실행

```bash
# 가상환경 활성화
source venv/bin/activate  # macOS/Linux
venv\Scripts\activate     # Windows

# 오디오 파일 분석
python test_cochl.py sample.wav
```

---

## 🔧 문제 해결

### "Python 3.9 이상이 필요합니다" 에러

현재 시스템에 Python 3.9 이상이 설치되어 있지 않습니다.

**해결 방법:**
1. [python.org](https://www.python.org/downloads/)에서 Python 3.11 또는 3.12 다운로드
2. 설치 후 `setup.sh` (또는 `setup.bat`) 다시 실행

### "python3가 설치되어 있지 않습니다" 에러

Python이 설치되어 있지 않거나 PATH에 등록되지 않았습니다.

**해결 방법:**
1. Python 설치 확인:
   ```bash
   python3 --version
   python --version
   ```
2. 설치되어 있지 않다면 [python.org](https://www.python.org/downloads/)에서 다운로드

### 가상환경 활성화 실패

**macOS/Linux:**
```bash
source venv/bin/activate
```

**Windows (CMD):**
```cmd
venv\Scripts\activate.bat
```

**Windows (PowerShell):**
```powershell
venv\Scripts\Activate.ps1
```

PowerShell에서 "실행 정책" 에러가 발생하면:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 📦 수동 설치 (고급 사용자용)

자동 스크립트를 사용하지 않고 수동으로 설치하려면:

```bash
# 1. 가상환경 생성
python3 -m venv venv
source venv/bin/activate

# 2. 핵심 라이브러리 설치
pip install flask python-dotenv pydub

# 3. cochl 설치 (--no-deps 플래그 필수)
pip install cochl --no-deps

# 4. cochl dependencies 설치
pip install soundfile requests numpy python-dateutil pydantic

# 5. 설치 확인
python -c "import cochl.sense; print('설치 성공!')"
```

---

## 🔍 설치 확인

설치가 제대로 되었는지 확인하려면:

```bash
# 가상환경 활성화
source venv/bin/activate  # macOS/Linux
venv\Scripts\activate     # Windows

# 패키지 확인
pip list | grep cochl
```

다음과 같이 표시되어야 합니다:
```
cochl              1.0.13
pydantic           2.12.5
pydantic_core      2.41.5
```

---

## 💡 사용 예시

### 간단한 오디오 분석

```python
import os
import cochl.sense as sense
from dotenv import load_dotenv

load_dotenv()

api_key = os.getenv('COCHL_API_KEY')
api_config = sense.APIConfigFromJson('./config.json')
client = sense.Client(api_key, api_config=api_config)

result = client.predict('sample.wav')
events_data = result.events.to_dict(api_config)

for window in events_data.get('window_results', []):
    for tag in window['sound_tags']:
        print(f"{tag['name']}: {tag['probability']*100:.2f}%")
```

### 제공된 테스트 스크립트 사용

```bash
python test_cochl.py your_audio_file.wav
```

출력 예시:
```
✅ API key loaded successfully
📁 Processing audio file: dog-bark.wav
✅ API configuration loaded
✅ Cochl.Sense client initialized

🔍 Analyzing audio...

============================================================
🎵 DETECTED SOUNDS
============================================================

⏱️  Window 1: 0.0s - 2.0s
   🔊 Dog_bark: 83.84%
   🔊 Animal: 65.21%

============================================================
✅ Analysis complete!
============================================================
```

---

## 🛠️ 지원되는 오디오 포맷

- ✅ **네이티브 지원:** WAV, MP3, OGG
- ⚠️ **변환 필요:** MP4, FLAC, M4A (pydub 사용)
- 📏 **파일 크기 제한:** 16MB 권장

---

## 📞 지원

- **Cochl Dashboard:** [dashboard.cochl.ai](https://dashboard.cochl.ai)
- **API 문서:** [docs.cochl.ai](https://docs.cochl.ai)
- **GitHub Issues:** [github.com/meanmin/sense-claude](https://github.com/meanmin/sense-claude)

---

## ✨ 주요 변경사항

**v2.0.0 - 자동 설치 스크립트 추가**
- `setup.sh` (macOS/Linux) 자동 설치 스크립트 추가
- `setup.bat` (Windows) 자동 설치 스크립트 추가
- 한 번의 명령으로 모든 dependency 자동 설치
- Python 버전 자동 감지 및 검증
- 에러 없는 설치 경험 제공

---

**이제 복잡한 설정 없이 바로 사용하세요! 🚀**
