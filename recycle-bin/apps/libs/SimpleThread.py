import threading

class SimpleThread:
    def __init__(self, target, args=()) -> None:
        self.target = target
        self.args = args
        self.thread = threading.Thread(target=self.target, args=self.args)
    
    def start(self):
        self.thread.start()
    
    def join(self):
        self.thread.join()

def asyncc(func):
    def wrapper(*args, **kwargs):
        simple_thread = SimpleThread(target=func, args=args)
        simple_thread.start()
        return func(*args, **kwargs)
    return wrapper