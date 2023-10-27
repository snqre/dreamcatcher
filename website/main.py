from web3 import Web3
from flask import Flask, render_template, url_for, jsonify
import random
import server

# Flask.
app = Flask(__name__)

@app.route("/")
def home() -> str:
    return render_template("home.html")

@app.route("/base")
def base() -> str:
    return render_template("base.html")

if __name__ == "__main__":
    app.run(app)