import requests

class Proxy:
    def __init__(self):
        self.myId
        self.apiEndpoint
        self.chain

    def __pull__(self):
        response = requests.get(self.apiEndpoint)
        if response.status_code == 200:
            self.chain = response.json()

    def execute(self, sourceCode: str):
        exec(sourceCode)
    
    def requestUniqueAccessToken(self):
        pass

    def skim(self):
        response = requests.get(self.apiEndpoint)
        if response.status_code == 200:
            chain = response.json()
            

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