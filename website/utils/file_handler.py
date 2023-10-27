import json, os

def load_json(path:str) -> dict:
    with open(path, "r") as f:
        return json.load(f)
    
def save_json(path:str, data:dict) -> None:
    with open(path, "w") as f:
        json.dump(data, f, indent=4)

def path_is_real(path:str) -> bool:
    if os.path.exists(path=path):
        return True
    else:
        return False