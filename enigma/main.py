import os
import telebot
from utils import telegram
from utils import polygon

telegram.set_api_key_for_telegram("")
telegram.set_username_for_telegram("enigma")
enigma = telegram.generate_interface()

@enigma.message_handler(commands=["start"])
def start(message):
    enigma.reply_to(message=message, text="Hello World")

@enigma.message_handler(commands=["get_block_number"])
def get_block_number(message):
    enigma.reply_to(message=message, text=f"{polygon.get_block_number()}")

@enigma.message_handler(commands=["call_dream_decimals"])
def call_dream_decimals(message):
    enigma.reply_to(message=message, text=f"{polygon.call_dream_decimals()}")

@enigma.message_handler(commands=["call_dream_get_current_snapshot_id"])
def call_dream_get_current_snapshot_id(message):
    enigma.reply_to(message=message, text=f"{polygon.call_dream_get_current_snapshot_id()}")

@enigma.message_handler(commands=["call_dream_name"])
def call_dream_name(message):
    enigma.reply_to(message=message, text=f"{polygon.call_dream_name()}")

@enigma.message_handler(commands=["call_dream_symbol"])
def call_dream_symbol(message):
    enigma.reply_to(message=message, text=f"{polygon.call_dream_symbol()}")

@enigma.message_handler(commands=["call_dream_total_supply"])
def call_dream_total_supply(message):
    enigma.reply_to(message=message, text=f"{polygon.call_dream_total_supply()}")

@enigma.message_handler(commands=["about"])
def about(message):
    enigma.reply_to(message=message, text=f"Dreamcatcher is an open-source cross-chain DAO built for robust large-scale ecosystem governance. Mirai is our decentralized investment platform for independent fund managers. Our governance is 100% on chain and we aim to create a fully decentralized protocol.")

enigma.polling()