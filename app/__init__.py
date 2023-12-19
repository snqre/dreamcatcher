from json import *
from typing import *
from flask import *
from json_sync import *

settings:Sync = Sync('app/static/json/settings.json')

app = Flask(__name__)

@app.route("/")
def index():
    return render_template(
        'index.html',
        pageName=settings.pageName
    )

if __name__ == "__main__":
    app.run(debug=True)