from lark import Lark, Transformer, v_args

grammar = """
    start: expression

    expression: term "+" expression
              | term "-" expression
              | term
    term: factor "*" term
        | factor "/" term
        | factor
    factor: atom "^" factor
          | atom
    atom: NUMBER | "(" expression ")"
    %import common.NUMBER
    %import common.WS
    %ignore WS
"""

class AbstractSyntaxTree(Transformer):
    def expression(self, items):
        # Check if there are operators in the items
        operators = [item for item in items if isinstance(item, str)]
        
        if not operators:
            # If no operators are present, return the items directly
            return items
        elif len(items) == 3:
            left, operator, right = items
            return (operator, left, right)
        else:
            raise ValueError(f"Unexpected items in expression: {items}")


parser = Lark(grammar, start='expression', parser='lalr')

# Example usage
code = "(3 + 4) * (5 - 2)^2"
tree = parser.parse(code)

# Create a transformer and transform the parse tree
transformer = AbstractSyntaxTree()
ast = transformer.transform(tree)

print(ast)

def evaluate(node):
    if isinstance(node, list):
        # If it's a list of trees, evaluate each tree individually
        return [evaluate(subtree) for subtree in node]

    if node.data == "expression":
        # Evaluate the expression based on its children
        left_operand = evaluate(node.children[0])
        operator = node.children[1].children[0].value
        right_operand = evaluate(node.children[2])
        
        if operator == "+":
            return left_operand + right_operand
        elif operator == "-":
            return left_operand - right_operand

    elif node.data == "term":
        # Evaluate the term based on its children
        left_operand = evaluate(node.children[0])
        operator = node.children[1].children[0].value
        right_operand = evaluate(node.children[2])
        
        if operator == "*":
            return left_operand * right_operand
        elif operator == "/":
            return left_operand / right_operand

    elif node.data == "factor":
        # Evaluate the factor based on its children
        base = evaluate(node.children[0])
        if len(node.children) == 1:
            return base
        else:
            exponent = evaluate(node.children[2])
            return base ** exponent

    elif node.data == "atom":
        # Return the value of the atom (either a number or the result of an inner expression)
        if node.children[0].data == "NUMBER":
            return int(node.children[0].value)
        else:
            # It's an inner expression, so evaluate it
            return evaluate(node.children[1])

# Example usage:
result = evaluate(ast)
print(result)
