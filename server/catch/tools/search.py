from os import walk, path
import importlib.util

def getSearchOrigin():
    return path.abspath(__file__)

def searchForFile(filename: str):
    for root, dirs, files in walk("/"):  # Start the search from the root directory ("/")
        if filename in files:
            relative_path = path.relpath(path=path.join(root, filename), start="/")
            return relative_path
    return None

filename_to_search = "rxconfig.py"  # Replace with the actual script name you're looking for
relative_path = searchForFile(filename_to_search)

if relative_path:
    print(f"Script '{filename_to_search}' found at relative path: {relative_path}")

    # Import the script dynamically
    full_path = path.abspath(path.join("/", relative_path))
    module_name = path.splitext(path.basename(full_path))[0]
    spec = importlib.util.spec_from_file_location(module_name, full_path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)

    # Now you can use the functions or variables from the imported script
    # For example:
    # module.some_function()

else:
    print(f"Script '{filename_to_search}' not found on the computer.")
