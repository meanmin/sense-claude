# Cochl.Sense Audio Detection for Claude Code

Transform Claude into an audio AI expert. Instantly add sound detection, classification, and analysis capabilities to your projects—from barking dogs to breaking glass, sirens to speech.

## What You'll Get

With this plugin installed, Claude will automatically help you:

- 🎯 **Detect 500+ environmental sounds** in audio files (dog barks, sirens, alarms, baby crying, glass breaking, speech, etc.)
- 🔒 **Set up secure API authentication** with best practices (.env files, .gitignore)
- 🐍 **Handle Python dependencies correctly** (includes workarounds for PyPI issues)
- 📊 **Parse API responses** and extract sound tags with confidence scores
- 🚀 **Build production-ready applications** with proper error handling

## Installation

### Step 1: Add the Marketplace

```bash
/plugin marketplace add meanmin/cochl-sense-claude-starter
```

### Step 2: Install the Plugin

```bash
/plugin install cochl-sense-api
```

That's it! Claude now has expert knowledge of the Cochl.Sense API.

## Quick Start

Once installed, simply ask Claude:

```
"Help me detect sounds in this audio file"
```

Claude will:
1. ✅ Check if you have a Cochl API key (and guide you to get one if needed)
2. ✅ Set up your Python environment correctly
3. ✅ Install dependencies with proper workarounds
4. ✅ Write secure, production-ready code
5. ✅ Parse results and show you detected sounds with confidence scores

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

### Set up a batch processing pipeline
```
"Process all .wav files in the uploads/ directory and save results to JSON"
```
**Result:** Claude creates a script that processes multiple files, handles failures, and generates structured output.

## What Makes This Different

- **No more API documentation hunting**: Claude knows all the details
- **Handles PyPI quirks**: Includes `--no-deps` workarounds and dependency fixes
- **Security by default**: Automatically sets up .env files and .gitignore
- **SDK-specific knowledge**: Knows that Python SDK uses `window_results`, not `events`
- **Production-ready patterns**: Error handling, validation, and demo modes included

## Requirements

- Python 3.9+ (Claude will check and warn if incompatible)
- A Cochl API key from [dashboard.cochl.ai](https://dashboard.cochl.ai)

## What's Included

This plugin contains:
- **cochl-sense-api skill**: Core API integration guidance
- **Environment setup guides**: Platform-specific installation instructions
- **Troubleshooting database**: Common errors and solutions
- **Advanced features**: Batch processing, custom configuration, sensitivity tuning

## Getting Your API Key

Claude will guide you through this automatically, but here's the quick version:

1. Visit [dashboard.cochl.ai](https://dashboard.cochl.ai)
2. Sign up or log in
3. Create a new project
4. Copy your project key
5. Tell Claude you have it—Claude handles the rest

## Support & Documentation

- **Cochl Dashboard**: [dashboard.cochl.ai](https://dashboard.cochl.ai)
- **Official API Docs**: [docs.cochl.ai](https://docs.cochl.ai/sense/cochl.sense-cloud-api/gettingstarted/)
- **Claude Code Skills**: [code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills)

## License

MIT License - See LICENSE file for details.

---

**Ready to add AI-powered sound detection to your project?**

```bash
/plugin marketplace add meanmin/cochl-sense-claude-starter
/plugin install cochl-sense-api
```

Then just ask Claude: *"Help me detect sounds in my audio files"*
