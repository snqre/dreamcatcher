from __disks__ import chaos
from __disks__ import polygon
import flask

application = flask.Flask(__name__)

@application.route("/")
def index():
    javascriptTemplate = "index"
    return flask.render_template("./baseline.html", javascriptTemplate=javascriptTemplate)

@application.route("/polygon/<address>")
def polygon(address):
    if (polygon.isEOA(address)):
        return "404: is not one of our vaults"
    response = polygon.computeHexToStandard(polygon.query(address, "0x84759", "0x"))
    
    return flask.render_template("./baseline.html", javascriptTemplate="polygon", address=address)

if __name__ == "__main__":
    application.run(debug=True)