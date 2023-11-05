import hashlib
import time

class Block:
    def __init__(self, timestamp: int, last_hash: str, messages: list = [], version: int = 0) -> None:
        self.last_hash = last_hash
        self.messages = messages
        self.version = version
        self.data = None
        self.hash = None
        self.has_been_minted = False
        self.timestamp = timestamp
    
    def __jsonify__(self):
        return {
            'last-hash': self.last_hash,
            'messages': self.messages,
            'version': self.version,
            'data': self.data,
            'hash': self.hash,
            'has_been_minted': self.has_been_minted,
            'timestamp': self.timestamp
        }
    
    def mint(self) -> None:
        original_state = self.has_been_minted
        try: 
            self.has_been_minted = True
            self.encode()
        except: self.has_been_minted = original_state
    
    def encode(self) -> None:
        self.data = ' >>> '.join(self.messages) + ' >>> ' + self.last_hash
        self.hash = hashlib.sha256(self.data.encode()).hexdigest()

    def stack_message(self, new_message: str) -> None:
        original_state = self.has_been_minted
        original_messages = self.messages
        original_data = self.data
        original_hash = self.hash
        original_timestamp = self.timestamp
        try:
            assert(self.has_been_minted is False)
            self.messages.append(new_message)
            self.encode() # re encode with new messages
        except: # reverts to last state
            self.has_been_minted = original_state
            self.messages = original_messages
            self.data = original_data
            self.hash = original_hash
            self.timestamp = original_timestamp

"""
x = 3
def x():
    pass
"""