import logging, time

"""
* event-driven architecture
*
* ref: https://www.redhat.com/en/topics/integration/what-is-event-driven-architecture
*
* CRITICAL:  50
* ERROR:     40
* WARNING:   30
* SUCCESS:   25
* INFO:      20
* DEBUG:     10
"""

# configure logging system
logging.basicConfig(filename="app.log", level=logging.INFO, format="%(asctime)s - %(levelname)s - %(filename)s - %(message)s");

# custom
SUCCESS:int = 25;
logging.addLevelName(SUCCESS, "SUCCESS");

def most_recent_details() -> dict | None:

    """
    Retrieves the most recent log entry from the specified log file.

    Args:
    - file_path (str): Path to the log file.

    Returns:
    - str: The most recent log entry.
    """
    with open("app.log", "r") as f:
        lines = f.readlines();
        if lines:
            entry = lines[-1].strip()
            timestamp, level, filename, message = entry.split(" - ", 3);
            severity = logging.getLevelName(level.strip());
            log_details = {
                "timestamp": timestamp.strip(),
                "severity": severity,
                "filename": filename.strip(),
                "message": message.strip()};
            return log_details;
        else:
            return None

# custom wrapper for success log
def success(msg, *args, **kwargs):
    logging.log(level=SUCCESS, msg=msg, *args, **kwargs);

# native logging wrappers

# logging.critical
def critical(msg, *args, **kwargs):
    logging.critical(msg=msg, *args, **kwargs);

# logging.error
def error(msg, *args, **kwargs):
    logging.error(msg=msg, *args, **kwargs);

# logging.warning
def warning(msg, *args, **kwargs):
    logging.warning(msg=msg, *args, **kwargs);

# logging.info
def info(msg, *args, **kwargs):
    logging.info(msg=msg, *args, **kwargs);

# logging.debug
def debug(msg, *args, **kwargs):
    logging.debug(msg=msg, *args, **kwargs);