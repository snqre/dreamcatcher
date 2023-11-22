import telebot

class Telegram:
    def __init__(self, apiKey:str, username:str="", interface:str=""):
        self.apiKey = apiKey
        self.username = username
        self.interface = interface

    def apiKey(self) -> str:
        return self.apiKey
    
    def username(self) -> str:
        return self.username
    
    def interface(self) -> str:
        return self.interface

    def setApiKey(self, apiKey:str):
        self.apiKey = apiKey

    def setUsername(self, username:str):
        self.username = username

    def generateInterface() -> str:
        return telebot.TeleBot(token=self.apiKey)