#!/bin/bash
# Cochl.Sense API 자동 설치 스크립트
# 모든 dependency를 자동으로 설치합니다

set -e  # 에러 발생 시 스크립트 중단

echo "=========================================="
echo "Cochl.Sense API 자동 설치 시작"
echo "=========================================="
echo ""

# 색상 코드
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Python 버전 체크
echo "📌 Step 1: Python 버전 확인 중..."
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ ERROR: python3가 설치되어 있지 않습니다${NC}"
    echo "https://www.python.org/downloads/ 에서 Python을 다운로드하세요"
    exit 1
fi

# Python 3.9+ 버전 찾기
PYTHON_CMD=""
for cmd in python3.12 python3.11 python3.10 python3.9 python3; do
    if command -v $cmd &> /dev/null; then
        VERSION=$($cmd --version 2>&1 | cut -d' ' -f2)
        MAJOR=$(echo $VERSION | cut -d'.' -f1)
        MINOR=$(echo $VERSION | cut -d'.' -f2)

        if [ "$MAJOR" -eq 3 ] && [ "$MINOR" -ge 9 ]; then
            PYTHON_CMD=$cmd
            echo -e "${GREEN}✅ Python $VERSION 발견 ($cmd)${NC}"
            break
        fi
    fi
done

if [ -z "$PYTHON_CMD" ]; then
    echo -e "${RED}❌ ERROR: Python 3.9 이상이 필요합니다${NC}"
    echo "현재 설치된 Python 버전이 너무 낮습니다"
    echo "https://www.python.org/downloads/ 에서 Python 3.9+ 를 설치하세요"
    exit 1
fi

# 2. 가상환경 생성
echo ""
echo "📌 Step 2: 가상환경 생성 중..."
if [ -d "venv" ]; then
    echo -e "${YELLOW}⚠️  기존 venv 폴더가 발견되었습니다${NC}"
    read -p "삭제하고 새로 만드시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf venv
        echo "기존 venv 삭제됨"
    else
        echo "기존 venv를 사용합니다"
    fi
fi

if [ ! -d "venv" ]; then
    $PYTHON_CMD -m venv venv
    echo -e "${GREEN}✅ 가상환경 생성 완료${NC}"
else
    echo -e "${GREEN}✅ 가상환경 확인 완료${NC}"
fi

# 3. 가상환경 활성화
echo ""
echo "📌 Step 3: 가상환경 활성화 중..."
source venv/bin/activate

# 활성화 확인
if [ "$VIRTUAL_ENV" != "" ]; then
    echo -e "${GREEN}✅ 가상환경 활성화 완료${NC}"
    echo "   경로: $VIRTUAL_ENV"
else
    echo -e "${RED}❌ ERROR: 가상환경 활성화 실패${NC}"
    exit 1
fi

# 4. pip 업그레이드
echo ""
echo "📌 Step 4: pip 업그레이드 중..."
pip install --upgrade pip -q
echo -e "${GREEN}✅ pip 업그레이드 완료${NC}"

# 5. 핵심 dependency 설치
echo ""
echo "📌 Step 5: 핵심 라이브러리 설치 중..."
echo "   설치 중: flask, python-dotenv, pydub..."
pip install flask python-dotenv pydub -q
echo -e "${GREEN}✅ 핵심 라이브러리 설치 완료${NC}"

# 6. cochl 패키지 설치 (--no-deps)
echo ""
echo "📌 Step 6: cochl 패키지 설치 중 (--no-deps)..."
pip install cochl --no-deps -q
echo -e "${GREEN}✅ cochl 패키지 설치 완료${NC}"

# 7. cochl dependency 수동 설치
echo ""
echo "📌 Step 7: cochl dependencies 설치 중..."
echo "   설치 중: soundfile, requests, numpy, python-dateutil, pydantic..."
pip install soundfile requests numpy python-dateutil pydantic -q
echo -e "${GREEN}✅ cochl dependencies 설치 완료${NC}"

# 8. 설치 확인
echo ""
echo "📌 Step 8: 설치 확인 중..."
python << EOF
try:
    import cochl.sense as sense
    import soundfile
    import requests
    import numpy
    import dateutil
    import pydantic
    import flask
    from dotenv import load_dotenv
    print("${GREEN}✅ 모든 패키지가 정상적으로 import 되었습니다${NC}")
except ImportError as e:
    print(f"${RED}❌ Import 실패: {e}${NC}")
    exit(1)
EOF

# 9. 프로젝트 구조 확인
echo ""
echo "📌 Step 9: 프로젝트 구조 확인 중..."

# uploads 폴더 생성
if [ ! -d "uploads" ]; then
    mkdir uploads
    echo "uploads/ 폴더 생성됨"
fi

# .gitignore 확인
if [ ! -f ".gitignore" ]; then
    echo ".env" > .gitignore
    echo "uploads/" >> .gitignore
    echo "venv/" >> .gitignore
    echo "__pycache__/" >> .gitignore
    echo "*.pyc" >> .gitignore
    echo ".gitignore 파일 생성됨"
else
    grep -q "^\.env$" .gitignore || echo ".env" >> .gitignore
    grep -q "^uploads/$" .gitignore || echo "uploads/" >> .gitignore
    grep -q "^venv/$" .gitignore || echo "venv/" >> .gitignore
    echo ".gitignore 업데이트됨"
fi

# config.json 확인
if [ -f "config.json" ]; then
    echo -e "${GREEN}✅ config.json 확인 완료${NC}"
else
    echo -e "${YELLOW}⚠️  config.json이 없습니다 (생성을 건너뜁니다)${NC}"
fi

# .env 파일 확인
if [ -f ".env" ]; then
    echo -e "${GREEN}✅ .env 파일 확인 완료${NC}"
else
    echo -e "${YELLOW}⚠️  .env 파일이 없습니다${NC}"
    echo "   나중에 API 키를 설정하려면 .env 파일을 만들고"
    echo "   COCHL_API_KEY=your_key_here 를 추가하세요"
fi

# 10. 완료
echo ""
echo "=========================================="
echo -e "${GREEN}✅ 설치가 완료되었습니다!${NC}"
echo "=========================================="
echo ""
echo "다음 단계:"
echo "1. 가상환경 활성화:"
echo "   source venv/bin/activate"
echo ""
echo "2. API 키가 설정되어 있는지 확인:"
echo "   cat .env"
echo ""
echo "3. 테스트 스크립트 실행:"
echo "   python test_cochl.py your_audio_file.wav"
echo ""
echo "설치된 패키지 목록:"
pip list | grep -E "(cochl|soundfile|pydantic|flask|python-dotenv|pydub|numpy|requests)" | sed 's/^/  /'
echo ""
