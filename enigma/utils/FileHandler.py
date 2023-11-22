import json
import os

class FileHandler:
    def getJson(path:str) -> dict:
        with open(path, "r") as file:
            return json.load(file)
    
    def setJson(path:str, data:dict):
        with open(path, "w") as file:
            json.dump(data, file, indent=4)

    def thisFileExists(path:str) -> bool:
        if os.path.exists(path=path): return True
        else: False