import re

# Lexer
token_patterns = [
    (r'\d+', 'INTEGER'),
    (r'\+', 'PLUS'),
    (r'-', 'MINUS'),
    (r'\*\*', 'POWER'),
    (r'\*', 'MULTIPLY'),
    (r'/', 'DIVIDE'),
    (r'\s+', 'SPACE'),
]

def lexer(input_string):
    tokens = []
    while input_string:
        for pattern, token_type in token_patterns:
            regex = re.compile(pattern)
            match = regex.match(input_string)
            if match:
                value = match.group()
                if token_type != 'SPACE':
                    tokens.append((token_type, value))
                input_string = input_string[len(value):].lstrip()
                break
        else:
            raise SyntaxError("Invalid character: {}".format(input_string[0]))
    return tokens

# Parser
class Parser:
    def __init__(self, tokens):
        self.tokens = tokens
        self.current_token = None
        self.advance()

    def advance(self):
        if self.tokens:
            self.current_token = self.tokens.pop(0)
        else:
            self.current_token = (None, None)

    def parse(self):
        result = self.parse_expression()
        if self.current_token[0] is not None:
            raise SyntaxError("Unexpected token: {}".format(self.current_token))
        return result

    def parse_expression(self):
        left = self.parse_term()

        while self.current_token[0] in ('PLUS', 'MINUS'):
            token_type, value = self.current_token
            self.advance()

            right = self.parse_term()

            if token_type == 'PLUS':
                left += right
            elif token_type == 'MINUS':
                left -= right

        return left

    def parse_term(self):
        left = self.parse_factor()

        while self.current_token[0] in ('MULTIPLY', 'DIVIDE', 'POWER'):
            token_type, value = self.current_token
            self.advance()

            right = self.parse_factor()

            if token_type == 'MULTIPLY':
                left *= right
            elif token_type == 'DIVIDE':
                left /= right
            elif token_type == 'POWER':
                left **= right

        return left

    def parse_factor(self):
        token_type, value = self.current_token
        if token_type == 'INTEGER':
            self.advance()
            return int(value)
        else:
            raise SyntaxError("Unexpected token: {}".format(self.current_token))

# Main
def main():
    while True:
        try:
            text = input(">>> ")
        except EOFError:
            break

        if not text:
            continue

        tokens = lexer(text)
        print("Tokens:", tokens)

        parser = Parser(tokens)
        try:
            result = parser.parse()
            print("Result:", result)
        except SyntaxError as e:
            print("Syntax Error:", e)

if __name__ == "__main__":
    main()
