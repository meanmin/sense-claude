# Troubleshooting Guide

Comprehensive error handling and resolution for Cochl.Sense Cloud API integration.

## Common Issues

### Installation Issues

#### Error: ModuleNotFoundError: No module named 'soundfile'

**Cause:** Missing dependency after installing cochl package.

**Solution:**
```bash
# Ensure virtual environment is activated
source venv/bin/activate  # macOS/Linux
venv\Scripts\activate      # Windows

# Install missing dependency
pip install soundfile

# Verify installation
python -c "import soundfile; print('✅ soundfile installed')"
```

---

#### Error: ModuleNotFoundError: No module named 'cochl_sense_api'

**Cause:** PyPI package distribution issue. The cochl package may not have installed its internal modules correctly.

**Solution:**
```bash
# Uninstall and reinstall with workaround
pip uninstall cochl -y
pip install cochl --no-deps
pip install soundfile requests numpy

# Verify installation
python << EOF
import cochl.sense as sense
print('✅ cochl installed correctly')
EOF
```

---

#### Error: ERROR: Could not find a version that satisfies the requirement cochl

**Cause:** Package not available for your Python version or platform.

**Solution:**
1. Check Python version (must be 3.9+):
   ```bash
   python --version
   ```

2. If Python 3.8 or lower, upgrade:
   - macOS: `brew install python@3.11`
   - Ubuntu: `sudo apt-get install python3.11`
   - Windows: Download from https://www.python.org/downloads/

3. Recreate virtual environment with correct Python:
   ```bash
   python3.11 -m venv venv
   source venv/bin/activate
   pip install cochl --no-deps
   pip install soundfile requests numpy
   ```

---

#### Error: RuntimeError: Could not find FFmpeg

**Cause:** FFmpeg not installed or not in system PATH.

**Solution by platform:**

**macOS:**
```bash
brew install ffmpeg
# Verify
ffmpeg -version
```

**Ubuntu:**
```bash
sudo apt-get update
sudo apt-get install ffmpeg
# Verify
ffmpeg -version
```

**Windows:**
1. Download FFmpeg from https://ffmpeg.org/download.html
2. Extract to `C:\ffmpeg`
3. Add to PATH:
   - Open System Properties → Environment Variables
   - Edit `Path` variable
   - Add `C:\ffmpeg\bin`
4. Restart terminal and verify:
   ```powershell
   ffmpeg -version
   ```

---

### API Key Issues

#### Error: Authentication failed: Invalid API key

**Cause:** API key is incorrect, expired, or not properly loaded.

**Solution:**
1. Check .env file exists and contains valid key:
   ```bash
   cat .env
   # Should show: COCHL_API_KEY=your_actual_key
   ```

2. Verify key is loaded in Python:
   ```python
   from dotenv import load_dotenv
   import os

   load_dotenv()
   api_key = os.getenv('COCHL_API_KEY')

   if not api_key:
       print("❌ API key not loaded")
   elif api_key == 'your_project_key_here':
       print("❌ Using example key, not real key")
   else:
       print(f"✅ Key loaded: {api_key[:10]}...")  # Show first 10 chars only
   ```

3. If key is valid but still fails, regenerate from dashboard:
   - Visit https://dashboard.cochl.ai
   - Go to your project
   - Generate new key
   - Update .env file

---

#### Error: ValueError: COCHL_API_KEY not configured

**Cause:** .env file not found or API key not set.

**Solution:**
```bash
# Create .env file
echo "COCHL_API_KEY=your_actual_key_here" > .env

# Verify .env is not in version control
grep -q ".env" .gitignore || echo ".env" >> .gitignore

# Test loading
python -c "from dotenv import load_dotenv; import os; load_dotenv(); print('Key exists:', bool(os.getenv('COCHL_API_KEY')))"
```

---

#### Error: API key works in terminal but not in application

**Cause:** .env file not in correct directory or not loaded before usage.

**Solution:**
1. Ensure .env is in project root (same directory as your main script)
2. Load .env at the very top of your script:
   ```python
   from dotenv import load_dotenv
   import os

   # Load BEFORE importing cochl
   load_dotenv()

   # Now import and use cochl
   import cochl.sense as sense
   ```

3. Check working directory:
   ```python
   import os
   print("Current directory:", os.getcwd())
   print(".env exists:", os.path.exists('.env'))
   ```

---

### Audio Processing Issues

#### Error: Unsupported audio format

**Cause:** File format not natively supported (MP4, FLAC, M4A, etc.).

**Solution:**
```python
from pydub import AudioSegment

def convert_to_wav(input_path, output_path):
    """Convert any audio format to WAV."""
    try:
        audio = AudioSegment.from_file(input_path)
        audio.export(output_path, format="wav")
        return output_path
    except Exception as e:
        print(f"Conversion failed: {e}")
        return None

# Usage
wav_file = convert_to_wav("input.mp4", "output.wav")
if wav_file:
    result = client.predict(wav_file)
```

**Supported input formats for conversion:**
- Audio: MP3, WAV, OGG, FLAC, AAC, M4A
- Video: MP4, AVI, MOV (extracts audio track)

---

#### Error: File too large to process

**Cause:** Audio file exceeds 16MB limit.

**Solution 1 - Compress audio:**
```python
from pydub import AudioSegment

def compress_audio(input_path, output_path, bitrate="64k"):
    """Reduce file size by lowering bitrate."""
    audio = AudioSegment.from_file(input_path)
    audio.export(output_path, format="mp3", bitrate=bitrate)
    return output_path

compressed = compress_audio("large.wav", "compressed.mp3", bitrate="32k")
```

**Solution 2 - Split into chunks:**
```python
from pydub import AudioSegment

def split_audio(input_path, chunk_length_ms=30000):
    """Split audio into chunks (default 30 seconds)."""
    audio = AudioSegment.from_file(input_path)
    chunks = []

    for i, start in enumerate(range(0, len(audio), chunk_length_ms)):
        chunk = audio[start:start + chunk_length_ms]
        chunk_path = f"chunk_{i}.wav"
        chunk.export(chunk_path, format="wav")
        chunks.append(chunk_path)

    return chunks

# Process each chunk
chunks = split_audio("large_file.wav")
for chunk in chunks:
    result = client.predict(chunk)
    # Process result...
```

---

#### Error: KeyError: 'window_results'

**Cause:** Using wrong key to access results (REST API structure vs. SDK structure).

**Solution:**
```python
# ❌ WRONG - REST API structure
events = events_data.get('events', [])  # This key doesn't exist in SDK

# ✅ CORRECT - SDK structure
window_results = events_data.get('window_results', [])

# Safe parsing with error handling
def parse_results(events_data):
    """Safely parse SDK response."""
    if not isinstance(events_data, dict):
        raise ValueError("events_data must be a dictionary")

    window_results = events_data.get('window_results', [])
    if not window_results:
        print("⚠️ No sound events detected")
        return []

    detections = []
    for window in window_results:
        for tag in window.get('sound_tags', []):
            detections.append({
                'sound': tag['name'],
                'confidence': tag['probability'] * 100,
                'start': window['start_time'],
                'end': window['end_time']
            })

    return detections
```

---

### Runtime Issues

#### Error: Connection timeout / Request timeout

**Cause:** Network issues or API server overload.

**Solution:**
```python
import time
from requests.exceptions import Timeout, ConnectionError

def predict_with_retry(client, file_path, max_retries=3, timeout=30):
    """Predict with automatic retry on timeout."""
    for attempt in range(max_retries):
        try:
            result = client.predict(file_path)
            return result
        except (Timeout, ConnectionError) as e:
            if attempt < max_retries - 1:
                wait_time = 2 ** attempt  # Exponential backoff: 1s, 2s, 4s
                print(f"⚠️ Attempt {attempt + 1} failed, retrying in {wait_time}s...")
                time.sleep(wait_time)
            else:
                print(f"❌ All {max_retries} attempts failed")
                raise

# Usage
try:
    result = predict_with_retry(client, "audio.wav")
except Exception as e:
    print(f"Failed to process audio: {e}")
```

---

#### Error: Rate limit exceeded

**Cause:** Too many API requests in short period.

**Solution:**
```python
import time
from datetime import datetime, timedelta

class RateLimiter:
    """Simple rate limiter for API calls."""
    def __init__(self, max_calls_per_minute=60):
        self.max_calls = max_calls_per_minute
        self.calls = []

    def wait_if_needed(self):
        """Wait if rate limit would be exceeded."""
        now = datetime.now()
        # Remove calls older than 1 minute
        self.calls = [call for call in self.calls if now - call < timedelta(minutes=1)]

        if len(self.calls) >= self.max_calls:
            sleep_time = 60 - (now - self.calls[0]).seconds
            print(f"⚠️ Rate limit reached, waiting {sleep_time}s...")
            time.sleep(sleep_time)
            self.calls = []

        self.calls.append(now)

# Usage
limiter = RateLimiter(max_calls_per_minute=30)

for file in audio_files:
    limiter.wait_if_needed()
    result = client.predict(file)
```

---

#### Error: Memory error when processing multiple files

**Cause:** Loading too many large files into memory simultaneously.

**Solution:**
```python
import gc

def process_files_memory_safe(file_paths, client, api_config):
    """Process files one at a time to avoid memory issues."""
    results = []

    for i, file_path in enumerate(file_paths):
        print(f"Processing {i+1}/{len(file_paths)}: {file_path}")

        try:
            result = client.predict(file_path)
            events_data = result.events.to_dict(api_config)
            results.append({
                'file': file_path,
                'events': events_data
            })

            # Clean up
            del result
            gc.collect()  # Force garbage collection

        except Exception as e:
            print(f"❌ Failed to process {file_path}: {e}")
            results.append({
                'file': file_path,
                'error': str(e)
            })

    return results
```

---

### Configuration Issues

#### Error: JSONDecodeError when loading config.json

**Cause:** Malformed JSON in config file.

**Solution:**
```bash
# Validate JSON syntax
python -m json.tool config.json

# If error, recreate config
cat > config.json << 'EOF'
{
  "format": {
    "type": "json",
    "version": "2"
  }
}
EOF

# Verify
python << EOF
import json
with open('config.json') as f:
    config = json.load(f)
    print('✅ Valid JSON:', config)
EOF
```

---

#### Error: Config file not found

**Cause:** Running script from wrong directory.

**Solution:**
```python
import os

def get_config_path():
    """Get absolute path to config.json."""
    # Get directory where script is located
    script_dir = os.path.dirname(os.path.abspath(__file__))
    config_path = os.path.join(script_dir, 'config.json')

    if not os.path.exists(config_path):
        raise FileNotFoundError(
            f"config.json not found at {config_path}. "
            "Ensure config.json is in the same directory as your script."
        )

    return config_path

# Usage
config_path = get_config_path()
api_config = sense.APIConfigFromJson(config_path)
```

---

## Diagnostic Tools

### Complete Health Check Script

```python
#!/usr/bin/env python3
"""
Cochl.Sense API Health Check
Run this to diagnose common issues.
"""

import os
import sys
from dotenv import load_dotenv

def check_python_version():
    """Check Python version compatibility."""
    version = sys.version_info
    if version.major == 3 and version.minor >= 9:
        print(f"✅ Python version: {version.major}.{version.minor}.{version.micro}")
        return True
    else:
        print(f"❌ Python version: {version.major}.{version.minor}.{version.micro} (3.9+ required)")
        return False

def check_dependencies():
    """Check if all required packages are installed."""
    required = {
        'cochl.sense': 'cochl',
        'soundfile': 'soundfile',
        'requests': 'requests',
        'numpy': 'numpy',
        'pydub': 'pydub',
        'flask': 'flask',
        'dotenv': 'python-dotenv'
    }

    all_ok = True
    for module, package in required.items():
        try:
            __import__(module.split('.')[0])
            print(f"✅ {package} installed")
        except ImportError:
            print(f"❌ {package} missing - run: pip install {package}")
            all_ok = False

    return all_ok

def check_api_key():
    """Check API key configuration."""
    load_dotenv()
    api_key = os.getenv('COCHL_API_KEY')

    if not api_key:
        print("❌ COCHL_API_KEY not found in .env")
        return False
    elif api_key == 'your_project_key_here':
        print("❌ COCHL_API_KEY is using example value")
        return False
    else:
        print(f"✅ COCHL_API_KEY loaded ({len(api_key)} characters)")
        return True

def check_files():
    """Check required files exist."""
    files = {
        '.env': 'Environment variables',
        'config.json': 'API configuration',
        '.gitignore': 'Git ignore file'
    }

    all_ok = True
    for file, description in files.items():
        if os.path.exists(file):
            print(f"✅ {file} exists ({description})")
        else:
            print(f"❌ {file} missing ({description})")
            all_ok = False

    # Check .env in .gitignore
    if os.path.exists('.gitignore'):
        with open('.gitignore') as f:
            if '.env' in f.read():
                print("✅ .env is in .gitignore")
            else:
                print("❌ .env NOT in .gitignore (security risk!)")
                all_ok = False

    return all_ok

def check_ffmpeg():
    """Check FFmpeg installation."""
    import subprocess
    try:
        result = subprocess.run(['ffmpeg', '-version'],
                              capture_output=True,
                              text=True,
                              timeout=5)
        if result.returncode == 0:
            version = result.stdout.split('\n')[0]
            print(f"✅ {version}")
            return True
    except (FileNotFoundError, subprocess.TimeoutExpired):
        print("❌ FFmpeg not installed or not in PATH")
        return False

def main():
    """Run all checks."""
    print("=" * 50)
    print("Cochl.Sense API Health Check")
    print("=" * 50)

    checks = [
        ("Python Version", check_python_version),
        ("Dependencies", check_dependencies),
        ("API Key", check_api_key),
        ("Files", check_files),
        ("FFmpeg", check_ffmpeg)
    ]

    results = []
    for name, check_func in checks:
        print(f"\n[{name}]")
        try:
            results.append(check_func())
        except Exception as e:
            print(f"❌ Check failed with error: {e}")
            results.append(False)

    print("\n" + "=" * 50)
    if all(results):
        print("✅ All checks passed! System ready.")
    else:
        print("❌ Some checks failed. Fix issues above.")
        sys.exit(1)

if __name__ == '__main__':
    main()
```

**Run diagnostic:**
```bash
python health_check.py
```

---

## Getting Help

### Collecting Debug Information

When reporting issues, include:

```python
import sys
import os
import platform

print("=== Debug Information ===")
print(f"Python: {sys.version}")
print(f"Platform: {platform.platform()}")
print(f"OS: {platform.system()} {platform.release()}")

try:
    import cochl
    print(f"cochl version: {cochl.__version__}")
except:
    print("cochl: not installed")

try:
    import soundfile
    print(f"soundfile version: {soundfile.__version__}")
except:
    print("soundfile: not installed")

print(f"Current directory: {os.getcwd()}")
print(f"Files: {os.listdir('.')}")
```

### Support Resources

- **Documentation:** https://docs.cochl.ai
- **Dashboard:** https://dashboard.cochl.ai
- **Email Support:** support@cochl.ai
- **GitHub Issues:** Report skill-specific issues

### Before Contacting Support

1. Run health check script above
2. Collect debug information
3. Note exact error message
4. List steps to reproduce
5. Check if .env and config.json are properly configured
