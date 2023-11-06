class Content:
    def __init__(self, origin: str, destination: str, sourceCode: str = ''):
        self.origin: str = origin
        self.destination: str = destination
        self.sourceCode: str = sourceCode

    def message(self):
        return f'origin={self.origin} destination={self.destination} sourceCode={self.sourceCode}'