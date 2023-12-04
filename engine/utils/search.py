from os import walk, path
import importlib.util
from tqdm import tqdm, trange

def searchForFile(fileNameList:list, dirPath:str="/"):
    results = []
    for fileName in fileNameList:
        for root, dirs, files in walk(dirPath):
            if fileName in files:
                relativePath = path.relpath(path=path.join(root, fileName), start="/")
                results.append((fileName, relativePath))
    if len(results) != 0:
        return results
    else:
        return

def importFromSearch(fileNameList:list, dirPath:str="/"):
    results = []
    results = searchForFile(fileNameList=fileNameList, dirPath=dirPath)
    for result in results:
        (filename, relativePath) = result
        fullPath = path.abspath(path.join(dirPath, relativePath))
        moduleName = path.splitext(path.basename(fullPath))[0]
        spec = importlib.util.spec_from_file_location(moduleName, fullPath)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        print(module)