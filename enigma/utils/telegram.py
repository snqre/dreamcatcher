import telebot

api_key_for_telegram:str
username_for_telegram:str
interface:str

def set_api_key_for_telegram(api:str):
    global api_key_for_telegram
    api_key_for_telegram = api

def get_api_key_for_telegram() -> str:
    return str(api_key_for_telegram)

def set_username_for_telegram(username:str):
    global username_for_telegram
    username_for_telegram = username

def get_username_for_telegram() -> str:
    return str(username_for_telegram)

def generate_interface() -> str:
    return telebot.TeleBot(token=api_key_for_telegram)