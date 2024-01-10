from json import *
from typing import *
class Sync:
    def __init__(self, jsonPath:str):
        self.jsonPath = jsonPath
        self.data = {}
        try:
            with open(self.jsonPath, "r") as jsonFile:
                self.data = load(jsonFile)
            if len(self.data) != 0:
                for key, value in self.data.items():
                    setattr(self, key, value)
        except FileNotFoundError:
            with open(self.jsonPath, "w") as jsonFile:
                self.data = load(jsonFile)
    def __setattr__(self, _name:str, _value:Any):
        self.__dict__[_name] = _value
        _temp = {}
        with open(self.jsonPath, "r") as jsonFile:
            _temp = load(jsonFile)
        _temp[f"{_name}"] = _value
        try:
            with open(self.jsonPath, "w") as jsonFile:
                dump(_temp, jsonFile, indent=4)
        except:
            pass
        finally:
            pass
    def __getattr__(self, _name:str):
        try:
            return self.__getattribute__(_name)
        except AttributeError:
            return setattr(self, _name, None)