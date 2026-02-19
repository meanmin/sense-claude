# Cochl.Sense Audio Detection for Claude Code

Transform Claude into an audio AI expert. Instantly add sound detection, classification, and analysis capabilities to your projects—from barking dogs to breaking glass, sirens to speech.

## What You'll Get

With this plugin installed, Claude will automatically help you:

- 🎯 **Detect 500+ environmental sounds** in audio files (dog barks, sirens, alarms, baby crying, glass breaking, speech, etc.)
- 🔒 **Set up secure API authentication** with best practices (.env files, .gitignore)
- 🐍 **Handle Python dependencies correctly** (includes workarounds for PyPI issues)
- 📊 **Parse API responses** and extract sound tags with confidence scores
- 🚀 **Build production-ready applications** with proper error handling

---

## Installation (2 Steps)

### Step 1: Install the Claude Code Plugin

First, add the plugin to Claude Code:

```bash
# Add the marketplace
/plugin marketplace add meanmin/sense-claude

# Install the plugin
/plugin install cochl-sense-api
```

> ⚠️ **Silent output is normal** - The commands succeed without showing messages.

**Verify installation (optional):**

Open a new terminal window and run:
```bash
claude plugin list
```
You should see `cochl-sense-api` in the list.

---

### Step 2: Set Up Python Environment

Now set up the Python dependencies. **Choose one option:**

#### Option A: Automated Setup (Fastest) ⚡

Run our one-command installation script:

**macOS/Linux:**
```bash
./setup.sh
```

**Windows:**
```cmd
setup.bat
```

The script automatically:
- Detects Python 3.9+ version
- Creates virtual environment
- Installs all dependencies in correct order (including urllib3 fix)
- Validates the installation

**Done!** Skip to [Usage](#usage) below.

#### Option B: Let Claude Guide You 🤖

Simply ask Claude:

```
Help me set up Cochl audio detection
```

Claude will:
- Check if you have a Cochl API key
- Guide you through Python environment setup
- Install dependencies with proper workarounds
- Write secure, production-ready code
- Help you analyze audio files

**That's it!** The plugin makes Claude an expert in Cochl API setup.

---

## Usage

### Get Your API Key

1. Visit [dashboard.cochl.ai](https://dashboard.cochl.ai)
2. Sign up or log in
3. Create a new project
4. Copy your project key

### Quick Test

**Using the test script:**
```bash
source venv/bin/activate  # Activate virtual environment
python test_cochl.py your_audio.wav
```

**Or ask Claude:**
```
Analyze dog-bark.wav and tell me what sounds are detected
```

Claude will write and run the code for you!

---

## Example Use Cases

### Detect sounds in an audio file
```
"Analyze dog-bark.wav and tell me what sounds are detected"
```
**Result:** Claude writes code to detect barking, shows confidence scores, and handles errors gracefully.

### Build a Flask audio analysis API
```
"Create a Flask endpoint that accepts audio uploads and returns detected sounds"
```
**Result:** Claude builds a complete API with file upload, validation, Cochl API integration, and proper error responses.

See the `examples/` folder for a complete Flask web app example.

### Set up a batch processing pipeline
```
"Process all .wav files in the uploads/ directory and save results to JSON"
```
**Result:** Claude creates a script that processes multiple files, handles failures, and generates structured output.

---

## What Makes This Different

- **One-command installation**: Run `./setup.sh` and you're done - no manual dependency juggling
- **No more API documentation hunting**: Claude knows all the details
- **Handles PyPI quirks**: Includes `--no-deps` workarounds and urllib3 dependency fixes
- **Security by default**: Automatically sets up .env files and .gitignore
- **SDK-specific knowledge**: Knows that Python SDK uses `window_results`, not `events`
- **Production-ready patterns**: Error handling, validation, and demo modes included
- **Error-free experience**: Automated scripts prevent common installation pitfalls

---

## Requirements

- Python 3.9+ (Claude will check and warn if incompatible)
- A Cochl API key from [dashboard.cochl.ai](https://dashboard.cochl.ai)

---

## What's Included

This plugin contains:
- **Automated installation scripts**: `setup.sh` (macOS/Linux) and `setup.bat` (Windows)
- **cochl-sense-api skill**: Core API integration guidance
- **Test script**: Ready-to-use `test_cochl.py` for immediate audio analysis
- **Environment setup guides**: Platform-specific installation instructions
- **Troubleshooting database**: Common errors and solutions
- **Advanced features**: Batch processing, custom configuration, sensitivity tuning
- **Example Flask app**: Complete web application in `examples/` folder

---

## Supported Audio Formats

- ✅ **Native:** WAV, MP3, OGG
- ⚠️ **Requires conversion:** MP4, FLAC, M4A (use pydub)
- 📏 **File size limit:** 16MB recommended

---

## Support & Documentation

- **Cochl Dashboard**: [dashboard.cochl.ai](https://dashboard.cochl.ai)
- **Official API Docs**: [docs.cochl.ai](https://docs.cochl.ai/sense/cochl.sense-cloud-api/gettingstarted/)
- **Claude Code Skills**: [code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills)

---

## License

MIT License - See LICENSE file for details.

---

**Ready to add AI-powered sound detection to your project?**

```bash
# Step 1: Install plugin
/plugin marketplace add meanmin/sense-claude
/plugin install cochl-sense-api

# Step 2: Set up Python
./setup.sh

# Step 3: Start using!
python test_cochl.py your_audio.wav
```

Or just ask Claude: *"Help me detect sounds in my audio files"*
