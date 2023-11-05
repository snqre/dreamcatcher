import re
import json
from tqdm import tqdm
from queue import Queue
from block import *
from interpreter import Interpreter

class Ledger:
    def __init__(self) -> None:
        self.chain = []
        self.queue = Queue()
        self.seconds_to_mint_block = 604800
        self.is_running = False
        self.enabled_queue_searching = False
        self.__pull__()

        self.allowed_opcode_list = [
            ('WHITESPACE', r'\s+'),
            ('NUMBER', r'-?\d+(\.\d+)?"'),
            ('POW', r'\*\*'),
            ('ADD', r'\+'),
            ('SUB', r'\-'),
            ('MUL', r'\*'),
            ('DIV', r'/'),
            ('LPAREN', r'\('),
            ('RPAREN', r'\)'),
            ('LBRACE', r'{'),
            ('RBRACE', r'}'),
            ('COLON', r':'),
            ('ASSIGN', r'='),
            ('OBJECT', r'object'),
            ('STORE', r'store'),
            ('RETURN', r'return'),
            ('IDENTIFIER', r'[a-zA-Z_][a-zA-Z0-9_]*'),
            ('EOF', r';')
        ]
    
    def __pull__(self) -> None:
        try:
            with open('chain.json', 'r') as file:
                self.chain = json.loads(file.read())
        except: self.__push__()

    def __push__(self) -> None:
        with open('chain.json', 'w') as file:
            json.dump(self.chain, file, default=lambda obj: obj.__jsonify__(), indent=4)

    def __mint__(self) -> None:
        self.__pull__()
        try:
            last_block = self.chain[-1]
            new_block = Block(int(time.time()), last_block['hash'], [], 0)
        except:
            new_block = Block(int(time.time()), '', [], 0)
        while not self.queue.empty():
            new_block.stack_message(self.queue.get())
        new_block.mint()
        self.chain.append(new_block)
        self.__push__()

    def run(self) -> None:
        while self.is_running:
            time.sleep(self.seconds_to_mint_block)
            self.__mint__()
            assert(self.validate())
            self.emit('LEDGER: a new block has been minted')

    def validate(self) -> bool:
        if len(self.chain) >= 20:
            for i in range(10, len(self.chain)):
                prev_block = self.chain[i - 1]
                curr_block = self.chain[i]
                if prev_block['hash'] != curr_block['last-hash']:
                    self.emit(f'LEDGER: !invalid block! {i}')
                    return False
            return True
        return True
        
    def emit(self, new_message: str) -> None:
        """emit must not be used without access control"""
        self.queue.put(new_message)
    
    def try_to_import_as_opcodes(self, message: str) -> list:
        result = []
        line = 1
        position = 0
        try:
            while message:
                matching = False
                for opcode in self.allowed_opcode_list:
                    identifier, instance = opcode
                    match = re.match(instance, message)
                    if match:
                        result.append((identifier, match.group(), line, position))
                        position += match.end()
                        message = message[match.end():]
                        matching = True
                        break
                if not matching: break
                line += message.count(';')
        except: pass
        return result

    def set_chain(self, new_chain: list) -> None:
        self.chain = new_chain
        self.emit(f'LEDGER: set chain to {new_chain}')
    
    def set_seconds_to_mint_block(self, seconds: int) -> None:
        self.seconds_to_mint_block = seconds
        self.emit(f'LEDGER: set seconds to mint block to {seconds} seconds')
    
    def increase_seconds_to_mint_block(self, seconds: int) -> None:
        self.seconds_to_mint_block += seconds
        self.emit(f'LEDGER: increased seconds to mint block by {seconds} seconds')
    
    def decrease_seconds_to_mint_block(self, seconds: int) -> None:
        self.seconds_to_mint_block -= seconds
        if self.seconds_to_mint_block < 0: self.seconds_to_mint_block = 0
        self.emit(f'LEDGER: decreased seconds to mint block by {seconds} seconds')
    
    def switch_on(self) -> None:
        self.is_running = True
        self.emit(f'LEDGER: switched on')

    def switch_off(self) -> None:
        self.is_running = False
        self.emit(f'LEDGER: switched off')
        
    def switch_on_queue_searching(self) -> None:
        self.enabled_queue_searching = True
        self.emit(f'LEDGER: switched on queue searching')
        
    def switch_off_queue_searching(self) -> None:
        self.enabled_queue_searching = False
        self.emit(f'LEDGER: switched off queue searching')
        
    def get_chain(self) -> list:
        return self.chain
    
    def get_block(self, i: int) -> dict:
        return self.chain[i]

    def lookup(self, obj: str) -> int:
        for block in self.chain:
            for msg in block['messages']:
                ops = self.try_to_import_as_opcodes(msg)
                #print(ops)
                print(self.interpret(ops))

    def interpret(self, ops: list):
        interpreter = Interpreter()
        interpreter.interpret(ops)



x = Ledger()
x.switch_on()
x.set_seconds_to_mint_block(5)
x.lookup('LEDGER')
x.run()