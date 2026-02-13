# Advanced Features

Advanced usage patterns and optimization techniques for Cochl.Sense Cloud API.

## Batch Processing

### Sequential Processing

```python
import os
import cochl.sense as sense
from dotenv import load_dotenv

load_dotenv()

def process_batch(file_paths, api_key=None, api_config=None):
    """Process multiple audio files sequentially."""
    if api_key is None:
        api_key = os.getenv('COCHL_API_KEY')

    if api_config is None:
        api_config = sense.APIConfigFromJson('./config.json')

    client = sense.Client(api_key, api_config=api_config)
    results = []

    for i, file_path in enumerate(file_paths):
        print(f"Processing {i+1}/{len(file_paths)}: {os.path.basename(file_path)}")

        try:
            result = client.predict(file_path)
            events_data = result.events.to_dict(api_config)

            results.append({
                'file': os.path.basename(file_path),
                'success': True,
                'events': events_data
            })

        except Exception as e:
            results.append({
                'file': os.path.basename(file_path),
                'success': False,
                'error': str(e)
            })

    return results

# Usage
audio_files = ['audio1.wav', 'audio2.mp3', 'audio3.ogg']
batch_results = process_batch(audio_files)

# Print summary
success_count = sum(1 for r in batch_results if r['success'])
print(f"\n✅ Processed {success_count}/{len(batch_results)} files successfully")
```

### Parallel Processing

```python
from concurrent.futures import ThreadPoolExecutor, as_completed
import os
import cochl.sense as sense
from dotenv import load_dotenv

load_dotenv()

def process_single_file(file_path, api_key, api_config):
    """Process a single audio file."""
    try:
        client = sense.Client(api_key, api_config=api_config)
        result = client.predict(file_path)
        events_data = result.events.to_dict(api_config)

        return {
            'file': os.path.basename(file_path),
            'success': True,
            'events': events_data
        }
    except Exception as e:
        return {
            'file': os.path.basename(file_path),
            'success': False,
            'error': str(e)
        }

def process_batch_parallel(file_paths, max_workers=4):
    """Process multiple audio files in parallel."""
    api_key = os.getenv('COCHL_API_KEY')
    api_config = sense.APIConfigFromJson('./config.json')

    results = []

    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        # Submit all tasks
        future_to_file = {
            executor.submit(process_single_file, file_path, api_key, api_config): file_path
            for file_path in file_paths
        }

        # Collect results as they complete
        for future in as_completed(future_to_file):
            file_path = future_to_file[future]
            try:
                result = future.result()
                results.append(result)
                print(f"✅ Completed: {os.path.basename(file_path)}")
            except Exception as e:
                print(f"❌ Failed: {os.path.basename(file_path)} - {e}")

    return results

# Usage
audio_files = ['audio1.wav', 'audio2.mp3', 'audio3.ogg', 'audio4.wav']
results = process_batch_parallel(audio_files, max_workers=3)
```

**Best Practices for Batch Processing:**
- Use sequential processing for small batches (< 10 files)
- Use parallel processing for large batches (> 10 files)
- Limit `max_workers` to avoid rate limiting (recommended: 3-5)
- Implement exponential backoff for failed requests

---

## Custom Configuration

### Sensitivity Tuning

Adjust detection thresholds per sound tag:

```json
{
  "format": {
    "type": "json",
    "version": "2"
  },
  "sensitivity": {
    "Dog_bark": 0.7,
    "Gunshot": 0.9,
    "Glass_break": 0.85,
    "Car_horn": 0.6
  }
}
```

**How sensitivity works:**
- **Lower value** (e.g., 0.5): More detections, higher false positive rate
- **Higher value** (e.g., 0.9): Fewer detections, lower false positive rate
- **Default**: 0.5 (balanced)

**Use cases:**
- **Security applications** (gunshot, glass break): Use high sensitivity (0.8-0.9)
- **General monitoring** (dog bark, car horn): Use medium sensitivity (0.6-0.7)
- **Exploratory analysis**: Use low sensitivity (0.4-0.5)

### Tag Filtering

Enable only specific sound tags:

```json
{
  "format": {
    "type": "json",
    "version": "2"
  },
  "tags": [
    "Dog_bark",
    "Cat_meow",
    "Baby_cry",
    "Doorbell"
  ]
}
```

**Benefits:**
- Faster processing
- Reduced response size
- Focus on relevant sounds

**Available tags:** See full list at https://docs.cochl.ai/sense/cochl.sense-cloud-api/sound-tags/

### Result Summarization

Group nearby events by time margin:

```json
{
  "format": {
    "type": "json",
    "version": "2"
  },
  "result_summary": {
    "margin": 2.0
  }
}
```

**Effect:**
- Events within `margin` seconds are grouped together
- Reduces noise from repeated detections
- Useful for continuous monitoring

---

## Advanced Processing Patterns

### Real-time Stream Processing

```python
import os
import time
import cochl.sense as sense
from dotenv import load_dotenv
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

load_dotenv()

class AudioFileHandler(FileSystemEventHandler):
    """Monitor directory for new audio files and process automatically."""

    def __init__(self, api_key, api_config):
        self.client = sense.Client(api_key, api_config=api_config)
        self.api_config = api_config

    def on_created(self, event):
        """Called when a new file is created."""
        if event.is_directory:
            return

        file_path = event.src_path
        if file_path.endswith(('.wav', '.mp3', '.ogg')):
            print(f"New audio file detected: {file_path}")
            self.process_audio(file_path)

    def process_audio(self, file_path):
        """Process audio file."""
        try:
            # Wait for file to be fully written
            time.sleep(1)

            result = self.client.predict(file_path)
            events_data = result.events.to_dict(self.api_config)

            # Extract detections
            window_results = events_data.get('window_results', [])
            for window in window_results:
                for tag in window['sound_tags']:
                    print(f"  🔊 {tag['name']}: {tag['probability']*100:.1f}% "
                          f"at {window['start_time']:.1f}s")

        except Exception as e:
            print(f"  ❌ Error processing {file_path}: {e}")

# Usage
def monitor_directory(directory='./uploads'):
    """Monitor directory for new audio files."""
    api_key = os.getenv('COCHL_API_KEY')
    api_config = sense.APIConfigFromJson('./config.json')

    event_handler = AudioFileHandler(api_key, api_config)
    observer = Observer()
    observer.schedule(event_handler, directory, recursive=False)
    observer.start()

    print(f"📁 Monitoring {directory} for new audio files...")
    print("Press Ctrl+C to stop")

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()

# Run
monitor_directory()
```

**Requirements:**
```bash
pip install watchdog
```

---

### Audio Format Conversion Pipeline

```python
from pydub import AudioSegment
import os

class AudioConverter:
    """Convert various audio formats to WAV for processing."""

    SUPPORTED_FORMATS = ['mp3', 'wav', 'ogg', 'flac', 'm4a', 'aac']
    VIDEO_FORMATS = ['mp4', 'avi', 'mov', 'mkv']

    @staticmethod
    def convert_to_wav(input_path, output_path=None, sample_rate=16000):
        """
        Convert audio to WAV format.

        Args:
            input_path: Path to input audio/video file
            output_path: Path to save WAV file (optional)
            sample_rate: Target sample rate in Hz (default: 16000)

        Returns:
            Path to converted WAV file
        """
        if output_path is None:
            name, _ = os.path.splitext(input_path)
            output_path = f"{name}_converted.wav"

        try:
            # Load audio (works with both audio and video files)
            audio = AudioSegment.from_file(input_path)

            # Set sample rate
            audio = audio.set_frame_rate(sample_rate)

            # Convert to mono if stereo
            if audio.channels > 1:
                audio = audio.set_channels(1)

            # Export as WAV
            audio.export(output_path, format='wav')

            print(f"✅ Converted {input_path} → {output_path}")
            print(f"   Sample rate: {sample_rate} Hz, Channels: 1 (mono)")

            return output_path

        except Exception as e:
            print(f"❌ Conversion failed: {e}")
            return None

    @staticmethod
    def get_audio_info(file_path):
        """Get audio file information."""
        audio = AudioSegment.from_file(file_path)

        return {
            'duration': len(audio) / 1000.0,  # seconds
            'sample_rate': audio.frame_rate,
            'channels': audio.channels,
            'sample_width': audio.sample_width,
            'frame_count': audio.frame_count()
        }

# Usage
converter = AudioConverter()

# Convert video to audio
wav_file = converter.convert_to_wav('video.mp4', 'extracted_audio.wav')

# Get audio information
info = converter.get_audio_info(wav_file)
print(f"Duration: {info['duration']:.2f}s")
print(f"Sample rate: {info['sample_rate']} Hz")
```

---

### Event Filtering and Analysis

```python
from typing import List, Dict

class EventAnalyzer:
    """Analyze and filter audio detection events."""

    @staticmethod
    def filter_by_confidence(events_data, min_confidence=0.7):
        """Filter events by minimum confidence threshold."""
        filtered = []

        window_results = events_data.get('window_results', [])
        for window in window_results:
            filtered_tags = [
                tag for tag in window['sound_tags']
                if tag['probability'] >= min_confidence
            ]

            if filtered_tags:
                filtered.append({
                    'start_time': window['start_time'],
                    'end_time': window['end_time'],
                    'sound_tags': filtered_tags
                })

        return filtered

    @staticmethod
    def filter_by_tags(events_data, allowed_tags: List[str]):
        """Filter events to include only specific sound tags."""
        filtered = []

        window_results = events_data.get('window_results', [])
        for window in window_results:
            filtered_tags = [
                tag for tag in window['sound_tags']
                if tag['name'] in allowed_tags
            ]

            if filtered_tags:
                filtered.append({
                    'start_time': window['start_time'],
                    'end_time': window['end_time'],
                    'sound_tags': filtered_tags
                })

        return filtered

    @staticmethod
    def get_top_sounds(events_data, top_n=5):
        """Get most frequently detected sounds."""
        sound_counts = {}

        window_results = events_data.get('window_results', [])
        for window in window_results:
            for tag in window['sound_tags']:
                name = tag['name']
                sound_counts[name] = sound_counts.get(name, 0) + 1

        # Sort by frequency
        sorted_sounds = sorted(sound_counts.items(),
                              key=lambda x: x[1],
                              reverse=True)

        return sorted_sounds[:top_n]

    @staticmethod
    def create_timeline(events_data):
        """Create timeline of all detected sounds."""
        timeline = []

        window_results = events_data.get('window_results', [])
        for window in window_results:
            for tag in window['sound_tags']:
                timeline.append({
                    'time': window['start_time'],
                    'duration': window['end_time'] - window['start_time'],
                    'sound': tag['name'],
                    'confidence': tag['probability']
                })

        # Sort by time
        timeline.sort(key=lambda x: x['time'])

        return timeline

# Usage
analyzer = EventAnalyzer()

# Process audio
result = client.predict('audio.wav')
events_data = result.events.to_dict(api_config)

# Filter high-confidence events
high_conf = analyzer.filter_by_confidence(events_data, min_confidence=0.8)
print(f"High confidence events: {len(high_conf)}")

# Filter specific sounds
dog_sounds = analyzer.filter_by_tags(events_data, ['Dog_bark', 'Dog_growl'])
print(f"Dog-related sounds: {len(dog_sounds)}")

# Get top sounds
top_sounds = analyzer.get_top_sounds(events_data, top_n=3)
print("Top 3 sounds:")
for sound, count in top_sounds:
    print(f"  {sound}: {count} occurrences")

# Create timeline
timeline = analyzer.create_timeline(events_data)
print("\nTimeline:")
for event in timeline[:5]:  # Show first 5
    print(f"  {event['time']:.1f}s: {event['sound']} "
          f"({event['confidence']*100:.1f}%)")
```

---

## Performance Optimization

### Client Connection Pooling

```python
import os
import cochl.sense as sense
from dotenv import load_dotenv

class CochlClientPool:
    """Singleton client pool for reusing connections."""

    _instance = None
    _client = None
    _api_config = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(CochlClientPool, cls).__new__(cls)
        return cls._instance

    def get_client(self):
        """Get or create client instance."""
        if self._client is None:
            load_dotenv()
            api_key = os.getenv('COCHL_API_KEY')

            if not api_key:
                raise ValueError("COCHL_API_KEY not configured")

            self._api_config = sense.APIConfigFromJson('./config.json')
            self._client = sense.Client(api_key, api_config=self._api_config)

        return self._client, self._api_config

# Usage in Flask app
from flask import Flask, request, jsonify

app = Flask(__name__)
client_pool = CochlClientPool()

@app.route('/analyze', methods=['POST'])
def analyze_audio():
    """Analyze uploaded audio file."""
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400

    file = request.files['file']
    file_path = f"./uploads/{file.filename}"
    file.save(file_path)

    try:
        # Reuse client from pool
        client, api_config = client_pool.get_client()

        result = client.predict(file_path)
        events_data = result.events.to_dict(api_config)

        return jsonify({
            'success': True,
            'events': events_data
        })

    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500
```

### Caching Results

```python
import hashlib
import json
import os
from functools import lru_cache

def get_file_hash(file_path):
    """Calculate MD5 hash of file."""
    hash_md5 = hashlib.md5()
    with open(file_path, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

class ResultCache:
    """Cache API results to avoid redundant processing."""

    def __init__(self, cache_dir='./cache'):
        self.cache_dir = cache_dir
        os.makedirs(cache_dir, exist_ok=True)

    def get_cache_path(self, file_hash):
        """Get cache file path for given hash."""
        return os.path.join(self.cache_dir, f"{file_hash}.json")

    def get(self, file_path):
        """Get cached result for file."""
        file_hash = get_file_hash(file_path)
        cache_path = self.get_cache_path(file_hash)

        if os.path.exists(cache_path):
            with open(cache_path, 'r') as f:
                return json.load(f)

        return None

    def set(self, file_path, result):
        """Cache result for file."""
        file_hash = get_file_hash(file_path)
        cache_path = self.get_cache_path(file_hash)

        with open(cache_path, 'w') as f:
            json.dump(result, f)

# Usage
cache = ResultCache()

def predict_with_cache(client, api_config, file_path):
    """Predict with caching."""
    # Check cache first
    cached = cache.get(file_path)
    if cached:
        print(f"✅ Using cached result for {file_path}")
        return cached

    # Process and cache
    result = client.predict(file_path)
    events_data = result.events.to_dict(api_config)

    cache.set(file_path, events_data)
    print(f"💾 Cached result for {file_path}")

    return events_data
```

---

## Integration Examples

### Flask REST API

```python
from flask import Flask, request, jsonify
import os
import cochl.sense as sense
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

# Initialize client
api_key = os.getenv('COCHL_API_KEY')
api_config = sense.APIConfigFromJson('./config.json')
client = sense.Client(api_key, api_config=api_config)

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint."""
    return jsonify({'status': 'ok'}), 200

@app.route('/analyze', methods=['POST'])
def analyze():
    """Analyze audio file."""
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400

    file = request.files['file']

    if file.filename == '':
        return jsonify({'error': 'Empty filename'}), 400

    # Save uploaded file
    file_path = f"./uploads/{file.filename}"
    file.save(file_path)

    try:
        # Process audio
        result = client.predict(file_path)
        events_data = result.events.to_dict(api_config)

        return jsonify({
            'success': True,
            'filename': file.filename,
            'events': events_data
        }), 200

    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

    finally:
        # Clean up uploaded file
        if os.path.exists(file_path):
            os.remove(file_path)

if __name__ == '__main__':
    app.run(debug=True, port=5000)
```

**Test the API:**
```bash
curl -X POST -F "file=@audio.wav" http://localhost:5000/analyze
```

---

## Best Practices Summary

1. **Reuse client instances** - Create once, use many times
2. **Implement caching** - Avoid reprocessing identical files
3. **Use parallel processing** - For batch operations
4. **Filter results** - Focus on relevant detections
5. **Monitor rate limits** - Implement backoff strategies
6. **Handle errors gracefully** - Log failures, continue processing
7. **Clean up resources** - Delete temporary files
8. **Validate inputs** - Check file formats and sizes before processing
9. **Log operations** - Track processing history for debugging
10. **Use configuration** - Externalize thresholds and settings
