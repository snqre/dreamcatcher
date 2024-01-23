from os import walk, path
import importlib.util

class File():
  def __init__(self):
    self.myData = None
    self.myPath = None
    self.searchForFileResults = None

  def data(self):
    return self.myData
  
  def path(self):
    return self.myPath
  
  def setPath(self, path):
    self.myPath = path
    return self
  
  def searchForFile(self, names: list, path: str = '/'):
    results = []
    for name in names:
      for root, dirs, files in walk(path):
        if name in files:
          relativePath = path.relpath(path=path.join(root, name), start='/')
          results.append((name, relativePath))
    if len(results) != 0:
      self.searchForFileResults = results
      return self
    else:
      return self

  def importFromSearch(self, names, path = '/'):
    self.searchForFile(names, path)
    for result in self.searchForFileResults:
      (name, relativePath) = result
      fullPath = path.abspath(path.join(path, relativePath))
      moduleName = path.splitext(path.basename(fullPath))[0]
      spec = importlib.util.spec_from_file_location(moduleName, fullPath)
      module = importlib.util.module_from_spec(spec)
      spec.loader.exec_module(module)

  def latestBlockNumber():
    pass
  