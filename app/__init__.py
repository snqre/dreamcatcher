from json import *
from typing import *
from flask import *
from json_sync import *

settings:Sync = Sync('app/static/json/settings.json');
app = Flask(__name__)

javascriptPath = "../static/js/main.js"
pageName = "Dreamcatcher"

@app.route('/')
def index():
    return f'''
        <!DOCTYPE html>
        <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
                <script type="module" src="{javascriptPath}"></script>
                <title>{pageName}</title>
            </head>
        </html>
    '''

if __name__ == '__main__':
    app.run(debug=True);