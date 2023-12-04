from time import *

stopwatchStack:dict = {}

def stopwatch(func):
    def wrapper(*args, **kwargs):
        before = time()
        value = func(*args, **kwargs)
        after = time()
        funcName = func.__name__
        secondsToComplete = after - before
        meter = "second(s)"
        funcStopwatchKey = f"{funcName}"
        if funcStopwatchKey not in stopwatchStack:
            stopwatchStack[funcStopwatchKey] = [secondsToComplete]
        else:
            stopwatchStack[funcStopwatchKey].append(secondsToComplete)
        if secondsToComplete >= 60:
            secondsToComplete /= 60
            meter = "minute(s)"
        elif secondsToComplete >= 3600:
            secondsToComplete /= 3600
            meter = "hour(s)"
        elif secondsToComplete >= 86400:
            secondsToComplete /= 86400
            meter = "day(s)"
        elif secondsToComplete >= 604800:
            secondsToComplete /= 604800
            meter = "week(s)"
        elif secondsToComplete >= 2419200:
            secondsToComplete /= 2419200
            meter = "month(s)"
        elif secondsToComplete >= 883008000:
            secondsToComplete /= 883008000
            meter = "year(s)"
        resultMessage:str = f"{funcName} completed in {secondsToComplete} {meter}"
        lastResultMessage:str = ""
        lastResult = 0
        if len(stopwatchStack[funcStopwatchKey]) >= 2:
            stack:list = []
            stack = stopwatchStack[funcStopwatchKey]
            lastResult = stack[len(stack) - 2]
            lastResultMessage:str = f"{funcName} last completed in {lastResult}"
        change = 0
        if lastResult != 0:
            change = ((secondsToComplete - lastResult) / lastResult)
        
        print(
            f"""
            result: {resultMessage}
            lastResult: {lastResultMessage}
            change: {round(change, 2)}%
            """
        )
        return value
    return wrapper


@stopwatch
def doSomething():
    return 2**9000000000

doSomething()
doSomething()
doSomething()
doSomething()
doSomething()