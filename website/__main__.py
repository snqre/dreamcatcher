from flask import Flask, render_template, url_for, jsonify

# Flask.
app = Flask(__name__)

@app.route("/")
def home():
    return render_template("home.html")

@app.route("/base")
def base():
    return render_template("base.html")

@app.route("/widget_container")
def widget_container():
    return render_template("widget_container.html")

@app.route("/landing")
def landing():
    return render_template("landing.html")

if __name__ == "__main__":
    app.run(debug=True)