from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/hello')
def hello():
    return jsonify({'message': 'Hello, World!'})

@app.route('/user/<user_id>')
def user(user_id):
    return jsonify({'id': user_id, 'name': 'User ' + user_id})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3003, threaded=True)
