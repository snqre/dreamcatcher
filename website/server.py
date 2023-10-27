from utils import better_console
import time

_is_running:bool = False
_refresh_rate:int = 1

# getters
def is_running() -> bool:
    return _is_running

def refresh_rate() -> int:
    return _refresh_rate

# toggle server state
def switch_on() -> None:
    global _is_running
    _is_running = True
    better_console.log_success(object="SERVER", text="switch_on()")

def switch_off() -> None:
    global _is_running
    _is_running = False
    better_console.log_success(object="SERVER", text="switch_off()")

# do task while running
def update() -> None:
    better_console.log_success(object="SERVER", text="update()")

better_console.toggle_display()
switch_on()


# main
while _is_running:
    update()
    time.sleep(refresh_rate())