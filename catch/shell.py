import catch;

while True:
    text = input("catch: ");
    result, error = catch.run("<stdin>", text);
    if error: print(error.asString());
    else: print(result);