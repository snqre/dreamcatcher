from flet import *
from components.tools.harmony.JsonSync import *

class Navbar(JsonSync,UserControl):
    def __init__(self):
        UserControl().__init__()
        JsonSync().__init__(jsonPath="app/components/storage/navbar.json")
    
    def build(self):
        pass