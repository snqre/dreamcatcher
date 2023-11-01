from simple_thread import *

def asyncc(func):

    def wrapper(*args, **kwargs):
        simple_thread = SimpleThread(target=func, args=args)
        simple_thread.start()

        return func(*args, **kwargs)

    return wrapper