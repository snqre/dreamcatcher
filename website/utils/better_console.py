from colorama import init, Fore, Style
import file_handler
import time

class Message:
    
    # init
    def __init__(self, id:int, timestamp:float, object:str, text:str, color:str, style:str) -> None:
        self._id:int = id
        self._timestamp:int = int(timestamp)
        self._object:str = object;
        self._text:str = text
        self._color:str = color
        self._style:str = style

    # id
    def id(self) -> int:
        return self._id

    # timestamp
    def timestamp(self) -> int:
        return self._timestamp
    
    # object
    def object(self) -> str:
        return self._object
    
    # text
    def text(self) -> str:
        return self._text
    
    # color
    def color(self) -> str:
        return self._color
    
    # style
    def style(self) -> str:
        return self._style

    # display fully formatted message
    def console_message(self) -> str:
        message:str = f"[{self._id}]: [{self._timestamp}]: [{self._object}]: {self._text}"
        new_message:str = f"{self._style}{self._color}{message}{Style.RESET_ALL}"
        return new_message
    
    def __json__(self):
        return {
            "id": self._id,
            "timestamp": self._timestamp,
            "object": self._object,
            "text": self._text,
            "color": self._color,
            "style": self._style}

# reset for each message
init(autoreset=True)

# storage
_storage:dict = {}
_logs:list = []
_path:str = "website/static/json/log.json"

# settings
_display:bool = False
_displayHistory:bool = False

def _save(msg:Message) -> None:
    global _storage, _logs, _path
    _storage["logs"] = [msg.__json__() for msg in _logs]
    _storage["display"] = display()
    _storage["displayHistory"] = displayHistory()
    file_handler.save_json(path=_path, data=_storage)

def _load() -> None:
    global _storage, _logs, _path
    if (file_handler.path_is_real(path=_path)):
        _storage = file_handler.load_json(path=_path)

def _initialize() -> None:
    global _storage, _logs, _path, _display, _displayHistory
    _load()
    for msg_data in _storage.get("logs", []):
        msg = Message(
            id=msg_data.get("id", 0),
            timestamp=msg_data.get("timestamp", 0),
            object=msg_data.get("object", ""),
            text=msg_data.get("text", ""),
            color=msg_data.get("color", Fore.RESET),
            style=msg_data.get("style", Style.NORMAL))
        _logs.append(msg)
        if (displayHistory()):
            print(f"{msg.style()}{msg.color()}{msg.console_message()}{Style.RESET_ALL}")
    _display = _storage.get("display")
    _displayHistory = _storage.get("displayHistory")

def display() -> bool:
    global _display
    return _display

def displayHistory() -> bool:
    global _displayHistory
    return _displayHistory

def toggle_display() -> None:
    """
    Display logs on terminal.

    NOTE Even if the display is turned off the logs will still be emitted.
    """
    global _display
    if (display()):
        _display = False
    else:
        _display = True

def toggle_display_history() -> None:
    """
    Display all past logs on terminal.

    NOTE Even if the display is turned off the logs will still be emitted.
    """
    global _displayHistory
    if (displayHistory()):
        _displayHistory = False
    else:
        _displayHistory = True
    _save()


def message(id:int) -> str:
    """
    Get a message by its ID.

    Parameters:
    - message_id (int): ID of the message to retrieve.

    Returns:
    - Message: The message with the specified ID.
    """
    for msg in _logs:
        if msg.id() == id:
            return msg.console_message()
    return ""

def search_logs_by_timestamp(start_timestamp:int, end_timestamp:int) -> list:

    """
    Search logs within a specified timestamp range.

    Parameters:
    - start_timestamp (int): Start timestamp for the search range.
    - end_timestamp (int): End timestamp for the search range.

    Returns:
    - list: List of logs within the specified timestamp range.
    """
    results:list = []
    for msg in _logs:
        if start_timestamp <= msg.timestamp() <= end_timestamp:
            results.append(msg)
    if not results:
        pass
    else:
        ids:list = []
        for entry in results:
            ids.append(entry.id())
    if (len(ids) != 0):
        return ids
    else:
        return None

def search_logs_by_object(object:str) -> list:
    pass

def clear() -> None:
    global _storage, _logs
    _logs.clear()
    _save()

def log(object:str, text:str) -> None:
    global _storage, _logs, _path
    msg:Message = Message(
        id=len(_logs), 
        timestamp=time.time(), 
        object=object, 
        text=text, 
        color=Fore.RESET, 
        style=Style.NORMAL)
    if display():
        print(msg.console_message())
    _logs.append(msg)
    _save(msg)

def log_success(object:str, text:str) -> None:
    global _storage, _logs, _path
    msg:Message = Message(
        id=len(_logs),
        timestamp=time.time(),
        object=object,
        text=text,
        color=Fore.GREEN,
        style=Style.NORMAL)
    if display():
        print(msg.console_message())
    _logs.append(msg)
    _save(msg)

def log_warning(object:str, text:str) -> None:
    global _storage, _logs, _path
    msg:Message = Message(
        id=len(_logs),
        timestamp=time.time(),
        object=object,
        text=text,
        color=Fore.YELLOW,
        style=Style.NORMAL)
    if display():
        print(msg.console_message())
    _logs.append(msg)
    _save(msg)

def log_error(object:str, text:str) -> None:
    global _storage, _logs, _path
    msg:Message = Message(
        id=len(_logs),
        timestamp=time.time(),
        object=object,
        text=text,
        color=Fore.RED,
        style=Style.NORMAL)
    if display():
        print(msg.console_message())
    _logs.append(msg)
    _save(msg)

def log_response(object:str, text:str) -> None:
    global _storage, _logs, _path
    msg:Message = Message(
        id=len(_logs),
        timestamp=time.time(),
        object=object,
        text=text,
        color=Fore.MAGENTA,
        style=Style.NORMAL)
    if display():
        print(msg.console_message())
    _logs.append(msg)
    _save(msg)

_initialize()

log_error("PROBLEM", "this is a problem")

toggle_display_history()
toggle_display()