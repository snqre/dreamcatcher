import importlib

def new(moduleName, modulePath=None):
    try:
        if (modulePath):
            return importlib.import_module(name=moduleName, package=modulePath)

        return importlib.import_module(name=moduleName)
    
    except Exception as error:
        print(f"{__name__}: failed to import disk: {error}")
        return None