import os
import telebot
from utils import Telegram
from utils import polygon

telegram = Telegram.Telegram()
telegram.setApiKey("")
telegram.setUsername("enigma")
enigma = telegram.generateInterface()

@enigma.message_handler(commands=["helloWorld"])
def helloWorld(message):
    enigma.reply_to(message=message,)

enigma.polling()