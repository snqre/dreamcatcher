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

def info(msg, *args, **kwargs):
    logging.info(msg=msg, *args, **kwargs);

def debug(msg, *args, **kwargs):
    logging.debug(msg=msg, *args, **kwargs);