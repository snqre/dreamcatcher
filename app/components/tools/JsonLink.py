from json import *
from typing import *
from typing import Any

something = {
        "veryAtomic": 1,
        "atomic": 2,
        "tiny": 4,
        "small": 8,
        "regular": 16,
        "big": 32,
        "large": 64,
        "veryLarge": 128,
        "massive": 256
}

class JsonLink:
    def __init__(self, data:dict={}) -> None:
        if len(data) != 0:
            for key, value in data.items():
                setattr(self, key, value)

    def __call__(self, __other:Any) -> bool:
        print(__other)
        return True
    
    def __setattr__(self, __name:str, __value:Any) -> bool:
        
        return True

x = JsonLink(data=something)
x.veryAtomic = 2
x.veryAtomic