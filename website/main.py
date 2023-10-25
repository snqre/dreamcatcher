from web3 import Web3
from flask import Flask, render_template, url_for

# Flask.
website = Flask(__name__)

@website.route("/")
def home() -> str:
    return render_template("home.html")

@website.route("/whitepaper")
def whitepaper() -> str:
    return render_template("whitepaper.html")

@website.route("/roadmap")
def roadmap() -> str:
    return render_template("roadmap.html")

@website.route("/live_events")
def live_events() -> str:
    return render_template("live_events.html")

@website.route("/live_proposals")
def live_proposals() -> str:
    return render_template("live_proposals")

@website.route("/live_vault")
def live_vault() -> str:
    return render_template("live_vault")

if __name__ == "__main__":
    website.run(debug=True)