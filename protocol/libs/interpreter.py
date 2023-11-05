from lark import Lark, Transformer
import op

class Interpreter(Transformer):
    grammer = """
    start: expression
    expression: IDENTIFIER | NUMBER | assignment
    
    assignment: IDENTIFIER "=" expression

    IDENTIFIER: /[a-zA-Z_][a-zA-Z0-9_]*/
    NUMBER: /-?\d+(\.\d+)?/
    %ignore /\s+/
    """

    def __init__(self) -> None:
        pass
    
    def assignment(self, items: list):
        return ('assignment', items[0], items[1])



    def interpret(self, opcodes: list) -> None:
       parser = Lark(Interpreter.grammer, parser='lalr', transformer=Interpreter())
       tree = parser.parse(opcodes)
       print(tree)