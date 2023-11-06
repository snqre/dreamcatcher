source_code = """
self.storage['something'] = 83
self.declare_new_variable('som')
self.storage['som'] = self.storage['something']
self.water = 90000
global land
land = 29
"""

land = 9

class Component:
    def __init__(self):
        self.storage: dict = {}
        self.water = 9
    
    def execute(self, source_code: str):
        exec(source_code)
        self.execute(source_code)

    def declare_new_variable(self, identifier: str):
        self.storage[f'{identifier}'] = None
    
    def assign_to_variable(self, identifier: str, obj):
        self.storage[f'{identifier}'] = obj


x = Component()
x.execute(source_code)
print(x.storage['something'])
print(x.storage['som'])
print(x.water)
print(land)