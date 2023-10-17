import json
import os

def get_json(path:str) -> dict:
    with open(path, "r") as f:
        return json.load(f)

def set_json(path:str, data:dict):
    with open(path, "w") as f:
        json.dump(data, f, indent=4)

def is_path_present(path:str) -> bool:
    if os.path.exists(path=path):
        return True
    else:
        return False