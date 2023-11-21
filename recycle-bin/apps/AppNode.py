from libs.Node import Node
from flask import Flask, request, jsonify
from threading import Thread
import time

app = Flask(__name__)
node = Node()

@app.route('/')
def index():
    return 'HelloWorld'



def run():
    while True:
        time.sleep(1)
        node.update()

@app.before_first_request
def beforeFirstRequest():
    newThread = Thread(target=run)
    newThread.start()

if __name__ == '__main__':
    app.run(debug=True)