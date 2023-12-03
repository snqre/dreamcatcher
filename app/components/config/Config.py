from json import *
from dataclasses import *

config = {}
with open("app/config.json") as file:
    config = load(file)

