import os
import telebot
from utils import file_handler
from utils import telegram

telegram.set_api_key_for_telegram()
telegram.set_username_for_telegram()
enigma = telegram.generate_interface()

@enigma.message_handler(commands=["start"])
def start(message):
    enigma.reply_to(message=message, text="Hello World")

enigma.polling()