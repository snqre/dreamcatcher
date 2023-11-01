import time, json

class Server:

    def __init__(self):
        self.is_running = False
        self.iterations = 0
        self.timestamp_start = None
        self.timestamp_end = None
    
    def run(self, seconds_interval):
        
        while self.is_running:
            self.hook_before_update()
            self.update()
            self.hook_after_update()
            time.sleep(seconds_interval)

    def update(self):
        pass

    def hook_before_update(self):
        pass

    def hook_after_update(self):
        self.iterations += 1
        self.save()

    def switch_on(self):
        self.is_running = True
        self.timestamp_start = time.time()
    
    def switch_off(self):
        self.is_running = False
        self.timestamp_end = time.time()

    def save(self, path):
        new_obj = self.__jsonify__()
        
        with open(path, "w") as f:
            json.dump(new_obj, f, indent=4)
    
    def __jsonify__(self):
        obj = {
            "is_running": self.is_running,
            "iterations": self.iterations,
            "timestamp_start": self.timestamp_start,
            "timestamp_end": self.timestamp_end
        }

        new_obj = json.dumps(obj)

        return new_obj