---
name: cochl-sense-api
description: >
  Identify and classify environmental sounds (barking, sirens, speech, alarms,
  baby crying, glass breaking, etc.) using Cochl.Sense Cloud API. Use when the
  user mentions "analyze audio", "detect sound", "what sound is this", "identify
  noise", uploads audio files (.wav/.mp3/.ogg), or asks about sound recognition
  and audio classification. Handles API authentication, dependency installation,
  and result parsing.
license: MIT
version: 2.0.0
author: Cochl
mcp-server: cochl-sense
category: audio-analysis
tags: audio, sound-detection, machine-learning, api-integration
documentation: https://docs.cochl.ai
---

# Cochl.Sense Cloud API Integration

Expert guidance for implementing Cochl.Sense audio detection features quickly and safely.

## Core Workflow

### Step 1: API Key Setup (MANDATORY FIRST)

**Before ANY implementation, verify API key:**

```
"An API key is required to use the Cochl API.
Do you have an API key from the Cochl Dashboard?"
```

| User Response | Action |
|---------------|--------|
| **NO** | Provide dashboard instructions, then **WAIT** |
| **YES** | Request key, proceed to configuration |

**If NO, provide:**
```
Steps to obtain a Cochl API Key:
1. Visit https://dashboard.cochl.ai
2. Sign up or Log in
3. Create a New Project
4. Copy the Project Key
5. Confirm when ready
```

**CRITICAL:** Do not proceed without API key. Never hardcode keys.

**Configuration:**
```bash
# 1. Create .env file
echo "COCHL_API_KEY=user_provided_key" > .env

# 2. Verify .gitignore
grep -q ".env" .gitignore || echo ".env" >> .gitignore

# 3. Create .env.example
echo "COCHL_API_KEY=your_project_key_here" > .env.example
```

### Step 2: Environment Setup

**Python Version Requirement:**
- Python 3.9+ REQUIRED
- Python 3.8 or lower NOT SUPPORTED
- ⚠️ **Python 3.11+ REQUIRES virtual environment** (externally-managed-environment protection)

**CRITICAL: Create Virtual Environment FIRST**

Python 3.11+ blocks system-wide package installation. ALWAYS use virtual environment:

```bash
# 1. Create virtual environment (MANDATORY for Python 3.11+)
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 2. Verify activation
which python  # Should show venv/bin/python
```

**Install Dependencies IN THIS ORDER:**

```bash
# 3. Install core dependencies
pip install flask python-dotenv pydub

# 4. Install cochl WITHOUT dependencies (PyPI workaround)
pip install cochl --no-deps

# 5. Install cochl dependencies manually (INCLUDING python-dateutil)
pip install soundfile requests numpy python-dateutil==2.0.0.post0
```

**Why this order?**
- `--no-deps`: Cochl package has PyPI availability issues
- `python-dateutil==2.0.0.post0`: Required by cochl but skipped by --no-deps
- Manual installation prevents dependency conflicts

For detailed platform-specific installation instructions, see [references/environment-setup.md](references/environment-setup.md)

**Project Structure:**
```bash
mkdir -p uploads
echo "uploads/" >> .gitignore

cat > config.json << 'EOF'
{
  "format": {
    "type": "json",
    "version": "2"
  }
}
EOF
```

### Step 3: Implementation

**Core Pattern:**
```python
import os
import cochl.sense as sense
from dotenv import load_dotenv

load_dotenv()

# ALWAYS validate API key first
api_key = os.getenv('COCHL_API_KEY')
if not api_key or api_key == 'your_project_key_here':
    raise ValueError("COCHL_API_KEY not configured. Visit https://dashboard.cochl.ai")

# Load config and initialize
api_config = sense.APIConfigFromJson('./config.json')
client = sense.Client(api_key, api_config=api_config)

# Process audio
result = client.predict('audio_file.wav')
events_data = result.events.to_dict(api_config)
```

**Audio Format Support:**
- ✅ Native: WAV, MP3, OGG
- ⚠️ Requires conversion: MP4, FLAC, M4A (use Pydub)
- File size limit: 16MB recommended

**Response Structure (CRITICAL):**

⚠️ Python SDK uses `window_results`, NOT `events` (differs from REST API):

```json
{
  "session_id": "uuid",
  "window_results": [
    {
      "start_time": 0,
      "end_time": 2,
      "sound_tags": [
        {"name": "Dog_bark", "probability": 0.838}
      ]
    }
  ]
}
```

**Parsing:**
```python
events_data = result.events.to_dict(api_config)
window_results = events_data.get('window_results', [])  # NOT 'events'

for window in window_results:
    for tag in window['sound_tags']:
        name = tag['name']
        confidence = tag['probability'] * 100
        print(f"{name}: {confidence:.2f}%")
```

### Step 4: Error Handling

**Common Errors:**

| Error | Cause | Solution |
|-------|-------|----------|
| externally-managed-environment | Python 3.11+ blocks system install | Create venv: `python -m venv venv && source venv/bin/activate` |
| ModuleNotFoundError: cochl | cochl not installed or venv not activated | Activate venv and `pip install cochl --no-deps` |
| ModuleNotFoundError: soundfile | Missing dependency | `pip install soundfile numpy` |
| ModuleNotFoundError: dateutil | Missing cochl dependency | `pip install python-dateutil==2.0.0.post0` |
| Authentication error | Invalid API key | Verify .env file |
| Unsupported format | Wrong file type | Convert to WAV/MP3/OGG |
| File too large | Size exceeds 16MB | Compress or split file |

For detailed troubleshooting, see [references/troubleshooting.md](references/troubleshooting.md)

## Demo Mode (Optional)

Use when API key unavailable or for UI testing:

```python
api_key = os.getenv('COCHL_API_KEY')

if not api_key or api_key == 'your_project_key_here':
    # Return mock data
    return {
        'success': True,
        'events': {
            'window_results': [
                {
                    'start_time': 0.5,
                    'end_time': 2.3,
                    'sound_tags': [{'name': 'Speech', 'probability': 0.95}]
                }
            ]
        },
        'mode': 'demo',
        'note': '⚠️ Demo Mode: Configure COCHL_API_KEY for real analysis'
    }
```

## Advanced Features

For batch processing, custom configuration, and sensitivity tuning, see [references/advanced-features.md](references/advanced-features.md)

## Quick Reference

**Key API Methods:**
- `sense.APIConfigFromJson(path)` - Load config
- `sense.Client(key, api_config)` - Initialize client
- `client.predict(file_path)` - Analyze audio
- `result.events.to_dict(api_config)` - Parse results

**Critical Reminders:**
1. ✅ Always check API key first - Never proceed without it
2. ✅ Use environment variables - Never hardcode
3. ✅ **Create virtual environment FIRST** - MANDATORY for Python 3.11+
4. ✅ Check Python 3.9+ - Warn on 3.8 or lower
5. ✅ Install cochl with --no-deps - Then install dependencies manually INCLUDING python-dateutil
6. ✅ Use `window_results` key - NOT `events` (SDK differs from REST API)
7. ✅ Keep .env out of git - Always verify .gitignore

**Important Links:**
- Dashboard (API keys): https://dashboard.cochl.ai
- Documentation: https://docs.cochl.ai/sense/cochl.sense-cloud-api/gettingstarted/
- Python Downloads: https://www.python.org/downloads/
