class Component:
    def __init__(self):
        self.storage: dict = {}
    
    def declare_new_variable(self, identifier: str):
        self.storage[f'{identifier}'] = None
    
    def assign_to_variable(self, identifier: str, obj):
        self.storage[f'{identifier}'] = obj
