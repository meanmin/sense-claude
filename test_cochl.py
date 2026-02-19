#!/usr/bin/env python3
"""
Test script for Cochl.Sense API integration
Analyzes an audio file and detects environmental sounds
"""
import os
import sys
import cochl.sense as sense
from dotenv import load_dotenv

def main():
    # Load environment variables
    load_dotenv()

    # Validate API key
    api_key = os.getenv('COCHL_API_KEY')
    if not api_key or api_key == 'your_project_key_here':
        print("❌ ERROR: COCHL_API_KEY not configured")
        print("Please set your API key in the .env file")
        print("Visit https://dashboard.cochl.ai to get your key")
        sys.exit(1)

    print("✅ API key loaded successfully")

    # Check if audio file path is provided
    if len(sys.argv) < 2:
        print("\nUsage: python test_cochl.py <audio_file_path>")
        print("Example: python test_cochl.py sample.wav")
        sys.exit(1)

    audio_file = sys.argv[1]

    # Verify file exists
    if not os.path.exists(audio_file):
        print(f"❌ ERROR: File not found: {audio_file}")
        sys.exit(1)

    print(f"📁 Processing audio file: {audio_file}")

    try:
        # Load API configuration
        api_config = sense.APIConfigFromJson('./config.json')
        print("✅ API configuration loaded")

        # Initialize client
        client = sense.Client(api_key, api_config=api_config)
        print("✅ Cochl.Sense client initialized")

        # Analyze audio
        print("\n🔍 Analyzing audio...")
        result = client.predict(audio_file)

        # Parse results
        events_data = result.events.to_dict(api_config)
        window_results = events_data.get('window_results', [])

        print("\n" + "="*60)
        print("🎵 DETECTED SOUNDS")
        print("="*60)

        if not window_results:
            print("No sounds detected in the audio file.")
        else:
            for idx, window in enumerate(window_results, 1):
                start_time = window.get('start_time', 0)
                end_time = window.get('end_time', 0)
                sound_tags = window.get('sound_tags', [])

                print(f"\n⏱️  Window {idx}: {start_time:.1f}s - {end_time:.1f}s")

                if sound_tags:
                    for tag in sound_tags:
                        name = tag.get('name', 'Unknown')
                        probability = tag.get('probability', 0)
                        confidence = probability * 100
                        print(f"   🔊 {name}: {confidence:.2f}%")
                else:
                    print("   (No sounds detected in this window)")

        print("\n" + "="*60)
        print("✅ Analysis complete!")
        print("="*60)

    except Exception as e:
        print(f"\n❌ ERROR: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()
