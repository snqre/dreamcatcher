from flask import Flask, render_template, url_for, jsonify
from asyncc import *
import asyncio

# Flask.
app = Flask(__name__)

@app.route("/")
def home() -> str:
    return render_template("home.html")

@app.route("/base")
def base() -> str:
    return render_template("base.html")

if __name__ == "__main__":
    app.run()