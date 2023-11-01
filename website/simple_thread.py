import threading

class SimpleThread:

    def __init__(self, target, args=()):
        self.target = target
        self.args = args
        self.thread = threading.Thread(target=self.target, args=self.args)
    
    def start(self):
        self.thread.start()
    
    def join(self):
        self.thread.join()