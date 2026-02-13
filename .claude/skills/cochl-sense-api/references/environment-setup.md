# Environment Setup Guide

Detailed platform-specific instructions for setting up Cochl.Sense Cloud API.

## System Requirements

### Python Version

| Version | Status | Action |
|---------|--------|--------|
| Python 3.9+ | ✅ Required | Proceed |
| Python 3.8 or lower | ❌ Unsupported | Display warning |

**Warning for Python 3.8 or lower:**
```
⚠️ Python 3.8 and lower are NOT SUPPORTED
Dependency conflicts will occur. Upgrade to Python 3.9+

Check version: python --version
Upgrade: https://www.python.org/downloads/
```

## Platform-Specific Dependencies

### macOS

```bash
# Install system dependencies
brew install openssl portaudio ffmpeg sox

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install Python packages
pip install flask python-dotenv pydub
pip install cochl --no-deps
pip install soundfile requests numpy
```

**Troubleshooting on macOS:**
- If `brew` not found, install Homebrew: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
- If `portaudio` issues occur, try: `brew reinstall portaudio`
- For M1/M2 Macs, ensure Rosetta is installed if needed

### Ubuntu/Debian

```bash
# Update package list
sudo apt-get update

# Install system dependencies
sudo apt-get install -y \
    ffmpeg \
    sox \
    portaudio19-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    python3-dev \
    python3-venv

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install Python packages
pip install flask python-dotenv pydub
pip install cochl --no-deps
pip install soundfile requests numpy
```

**Troubleshooting on Ubuntu:**
- If `apt-get` permission denied, ensure you use `sudo`
- For older Ubuntu versions (< 20.04), you may need to add ffmpeg PPA:
  ```bash
  sudo add-apt-repository ppa:jonathonf/ffmpeg-4
  sudo apt-get update
  ```

### Windows

```powershell
# Install Python 3.9+ from https://www.python.org/downloads/

# Install ffmpeg (download from https://ffmpeg.org/download.html)
# Add ffmpeg to PATH environment variable

# Create virtual environment
python -m venv venv
venv\Scripts\activate

# Install Python packages
pip install flask python-dotenv pydub
pip install cochl --no-deps
pip install soundfile requests numpy
```

**Troubleshooting on Windows:**
- Ensure Python is added to PATH during installation
- If `pip` not recognized, use `python -m pip` instead of `pip`
- For ffmpeg, download static build and add to PATH
- If Visual Studio Build Tools error, install from: https://visualstudio.microsoft.com/downloads/

## Virtual Environment Best Practices

### Creating Virtual Environment

```bash
# Create
python -m venv venv

# Activate
source venv/bin/activate        # macOS/Linux
venv\Scripts\activate            # Windows

# Verify activation (prompt should show (venv))
which python  # macOS/Linux - should point to venv/bin/python
where python  # Windows - should point to venv\Scripts\python.exe
```

### Deactivating

```bash
deactivate
```

### Removing Virtual Environment

```bash
# Deactivate first
deactivate

# Remove directory
rm -rf venv  # macOS/Linux
rmdir /s venv  # Windows
```

## Dependency Installation Explained

### Why Install in Specific Order?

The `cochl` package has PyPI distribution issues, causing dependency resolution failures. The workaround:

1. **First:** Install general dependencies (flask, python-dotenv, pydub)
2. **Second:** Install cochl with `--no-deps` flag to skip automatic dependency resolution
3. **Third:** Manually install cochl's dependencies (soundfile, requests, numpy)

### Verifying Installation

```python
# Test imports
python << EOF
import cochl.sense as sense
import soundfile
import requests
import numpy
print("✅ All dependencies installed successfully")
EOF
```

Expected output: `✅ All dependencies installed successfully`

If any import fails, reinstall that specific package:
```bash
pip install --force-reinstall soundfile
```

## Project Structure Setup

### Complete Setup Script

```bash
#!/bin/bash

# Create directories
mkdir -p uploads
mkdir -p logs

# Create .gitignore
cat > .gitignore << 'EOF'
.env
uploads/
logs/
venv/
__pycache__/
*.pyc
.DS_Store
EOF

# Create config.json
cat > config.json << 'EOF'
{
  "format": {
    "type": "json",
    "version": "2"
  }
}
EOF

# Create .env.example
cat > .env.example << 'EOF'
COCHL_API_KEY=your_project_key_here
EOF

echo "✅ Project structure created"
```

### Verify Setup Checklist

Run this verification:

```bash
# Check files exist
[ -f .env ] && echo "✅ .env exists" || echo "❌ .env missing"
[ -f .env.example ] && echo "✅ .env.example exists" || echo "❌ .env.example missing"
[ -f config.json ] && echo "✅ config.json exists" || echo "❌ config.json missing"
[ -d uploads ] && echo "✅ uploads/ exists" || echo "❌ uploads/ missing"

# Check .gitignore
grep -q ".env" .gitignore && echo "✅ .env in .gitignore" || echo "❌ .env NOT in .gitignore"

# Check Python version
python --version | grep -q "3.9\|3.10\|3.11\|3.12" && echo "✅ Python 3.9+" || echo "❌ Python version incompatible"

# Check virtual environment
[ -n "$VIRTUAL_ENV" ] && echo "✅ Virtual environment activated" || echo "❌ Virtual environment NOT activated"
```

## Docker Setup (Optional)

For containerized deployment:

```dockerfile
FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    sox \
    portaudio19-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Run application
CMD ["python", "app.py"]
```

**requirements.txt:**
```
flask==3.0.0
python-dotenv==1.0.0
pydub==0.25.1
cochl==0.5.0
soundfile==0.12.1
requests==2.31.0
numpy==1.26.0
```

**Build and run:**
```bash
docker build -t cochl-sense-api .
docker run -p 5000:5000 --env-file .env cochl-sense-api
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Test Cochl Integration

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Set up Python 3.11
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install system dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y ffmpeg sox portaudio19-dev

      - name: Install Python dependencies
        run: |
          pip install flask python-dotenv pydub
          pip install cochl --no-deps
          pip install soundfile requests numpy

      - name: Run tests
        env:
          COCHL_API_KEY: ${{ secrets.COCHL_API_KEY }}
        run: |
          python -m pytest tests/
```

## Security Considerations

### API Key Management

**DO:**
- ✅ Store API keys in .env file
- ✅ Add .env to .gitignore
- ✅ Use environment variables in code
- ✅ Rotate keys periodically
- ✅ Use different keys for dev/prod

**DON'T:**
- ❌ Hardcode API keys in source code
- ❌ Commit .env to version control
- ❌ Share API keys in public channels
- ❌ Use production keys in development
- ❌ Log API keys in application logs

### Environment Variable Loading

**Secure loading pattern:**
```python
import os
from dotenv import load_dotenv

# Load from .env
load_dotenv()

# Validate
api_key = os.getenv('COCHL_API_KEY')
if not api_key:
    raise ValueError("COCHL_API_KEY environment variable not set")

if api_key == 'your_project_key_here':
    raise ValueError("COCHL_API_KEY is still using example value")

# Use key
# ... rest of implementation
```

## Performance Optimization

### Caching Client Instance

```python
# Global client instance (reuse across requests)
_client = None

def get_client():
    global _client
    if _client is None:
        api_key = os.getenv('COCHL_API_KEY')
        api_config = sense.APIConfigFromJson('./config.json')
        _client = sense.Client(api_key, api_config=api_config)
    return _client
```

### Connection Pooling

For high-traffic applications:
```python
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

session = requests.Session()
retry = Retry(connect=3, backoff_factor=0.5)
adapter = HTTPAdapter(max_retries=retry, pool_connections=100, pool_maxsize=100)
session.mount('http://', adapter)
session.mount('https://', adapter)
```

## Next Steps

After completing environment setup:
1. Test API key validation
2. Process a sample audio file
3. Review [troubleshooting.md](troubleshooting.md) for common issues
4. Explore [advanced-features.md](advanced-features.md) for optimization
