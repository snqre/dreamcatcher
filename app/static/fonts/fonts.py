from os import *
from warnings import *

class MissingFonts(Warning):
    def __init__(self, message="Unable to locate fonts"):
        self.message = message
        super().__init__(self.message)

fontsPath:str = "app/static/fonts"

if path.isdir(fontsPath):
    results = []
    for root, dirs, files in walk(fontsPath):
        folderName = path.relpath(root, fontsPath)
        for file in files:
            if file.endswith(".ttf"):
                filePath = path.join(root, file)
                filePath = filePath.replace("\\", "/")
                fileName = file
                fileName = fileName.replace(".ttf", "")
                results.append((folderName, fileName, filePath))
    if len(results) == 0: warn(MissingFonts(), stacklevel=2)
else:
    raise FileNotFoundError(f"Unable to locate {fontsPath}")

FONTS = {}
for result in results:
    (folderName, fileName, filePath) = result
    FONTS[f"{fileName}"] = filePath

del results
del root
del dirs
del file
del filePath
del fileName
del fontsPath