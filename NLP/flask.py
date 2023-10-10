from flask import Flask, request, jsonify
import main

app = Flask(__name__)

@app.route('/process', methods=['GET'])
def process_string():
    d = {}
    d['Query'] = main(str(request.args['Query']))
    return jsonify(d)
    

if __name__ == '__main__':
    app.run()
