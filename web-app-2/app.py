from flask import Flask

app = Flask(__name__)


@app.route('/app2')
def hello_app2():
    return 'Hello, web {} - running version {}'.format(2,1.0)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')