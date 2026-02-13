import os
from flask import Flask, render_template, request, jsonify
from werkzeug.utils import secure_filename
from dotenv import load_dotenv
import cochl.sense as sense
from cochl.sense import Result

# Load environment variables
load_dotenv()

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = 'uploads'
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max file size

# Allowed audio file extensions
ALLOWED_EXTENSIONS = {'wav', 'mp3', 'ogg'}

# Create uploads folder if it doesn't exist
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

# Check API key
api_key = os.getenv('COCHL_API_KEY')
if not api_key or api_key == 'your_project_key_here':
    print("WARNING: COCHL_API_KEY not configured properly")
    print("Please visit https://dashboard.cochl.ai to get your API key")

def allowed_file(filename):
    """Check if the file extension is allowed"""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/')
def index():
    """Render the main page"""
    return render_template('index.html')

@app.route('/analyze', methods=['POST'])
def analyze_audio():
    """Analyze uploaded audio file"""

    # Check if file is present
    if 'audio' not in request.files:
        return jsonify({'success': False, 'error': '파일이 없습니다'}), 400

    file = request.files['audio']

    # Check if filename is empty
    if file.filename == '':
        return jsonify({'success': False, 'error': '파일이 선택되지 않았습니다'}), 400

    # Check if file type is allowed
    if not allowed_file(file.filename):
        return jsonify({
            'success': False,
            'error': f'지원되지 않는 파일 형식입니다. 허용된 형식: {", ".join(ALLOWED_EXTENSIONS)}'
        }), 400

    try:
        # Save file
        filename = secure_filename(file.filename)
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)

        # Load API configuration
        api_config = sense.APIConfigFromJson('./config.json')

        # Initialize Cochl client
        client = sense.Client(api_key, api_config=api_config)

        # Analyze audio
        result: Result = client.predict(filepath)

        # Convert results to dictionary
        events_data = result.events.to_dict(api_config)

        # Extract window_results from API response
        # API returns: {"session_id": "...", "window_results": [...]}
        window_results = events_data.get('window_results', [])

        # Clean up uploaded file
        os.remove(filepath)

        # Format response according to actual API structure
        # API returns window_results with sound_tags
        formatted_events = []

        for window in window_results:
            start_time = window.get('start_time', 0)
            end_time = window.get('end_time', 0)
            sound_tags = window.get('sound_tags', [])

            # Process each sound tag in this window
            for tag in sound_tags:
                formatted_events.append({
                    'tag': tag.get('name', 'Unknown'),
                    'confidence': round(tag.get('probability', 0) * 100, 2),
                    'start_time': round(start_time, 2),
                    'end_time': round(end_time, 2)
                })

        if formatted_events:
            return jsonify({
                'success': True,
                'events': formatted_events,
                'message': f'{len(formatted_events)}개의 소리 이벤트가 감지되었습니다'
            })
        else:
            return jsonify({
                'success': True,
                'events': [],
                'message': '감지된 소리 이벤트가 없습니다'
            })

    except Exception as e:
        # Clean up file if it exists
        if os.path.exists(filepath):
            os.remove(filepath)

        return jsonify({
            'success': False,
            'error': f'오디오 분석 중 오류가 발생했습니다: {str(e)}'
        }), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001)
