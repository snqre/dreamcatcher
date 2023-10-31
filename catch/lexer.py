import re # definitely not adviced to do it this way
from colorama import Fore, Style

class Lexer:

    style_list = [
        ("TAB", r"\t"),                 #   
        ("WHITESPACE", r"\s+"),         #
        ("NUMBER", r"\d+"),             # 0123456789
        ("POW", r"\*\*"),               # **
        ("ADD", r"\+"),                 # +
        ("SUB", r"\-"),                 # -
        ("MUL", r"\*"),                 # *
        ("DIV", r"/"),                  # /
        ("TLPAREN", r"\(\(\("),         # (((
        ("TRPAREN", r"\)\)\)"),         # )))
        ("DLPAREN", r"\(\("),           # ((
        ("DRPAREN", r"\)\)"),           # ))
        ("LPAREN", r"\("),              # )
        ("RPAREN", r"\)"),              # (
        ("TLBRACE", r"\{\{\{"),         # {{{
        ("TRBRACE", r"\}\}\}"),         # }}}
        ("DLBRACE", r"\{\{"),           # {{
        ("DRBRACE", r"\}\}"),           # }}
        ("LBRACE", r"{"),               # {
        ("RBRACE", r"}"),               # }
        ("EQ", r"=="),                  # ==
        ("NOEQ", r"!="),                # !=
        ("LESSTHANEQ", r"\<\="),        # <=
        ("MORETHANEQ", r"\>\="),        # >=
        ("LESS", r"<"),                 # <
        ("MORE", r">"),                 # >
        ("ASSIGN", r"="),               # =
        ("NOT", r"!"),                  # !
        ("FALSE", r"false"),            # false
        ("TRUE", r"true"),              # true
        ("NONE", r"none"),              # none
        ("AND", r"\&\&"),               # &&
        ("OR", r"\|\|"),                # ||
        ("FOR", r"for"),                # for
        ("WHILE", r"while"),            # while
        ("EVAL", r"eval"),              # eval
        ("EXEC", r"exec"),              # exec
        ("JUMP", r"jump"),              # jump
        ("LISTEN", r"listen"),          # listen
        ("FOLLOW", r"follow"),          # follow
        ("STORE", r"store"),            # store
        ("EMIT", r"emit"),              # emit
        ("CONNECT", r"connect"),        # connect
        ("DISCONNECT", r"disconnect"),  # disconnect
        ("WAIT", r"wait"),              # wait
        ("LOOKUP", r"lookup"),          # lookup
        ("LOOKFOR", r"lookfor"),        # lookfor
        ("DELEGATE", r"delegate"),      # delegate
        ("QUOTE01", r"'"),              # '
        ("QUOTE02", r'"'),              # "
        ("IDENTIFIER", r"[a-zA-Z_][a-zA-Z0-9_]*"),
        ("EOF", r";")                   # ;
    ]

    def __init__(self, source_code):
        self.source_code = source_code
        self.tags = self.tag(self.source_code)

    def tag(self, source_code):
        tags = []
        line = 1
        position = 0

        try:

            while source_code:
                matched = False

                for style in self.style_list:
                    tag, pattern = style
                    match = re.match(pattern, source_code)

                    if match:
                        tags.append((tag, match.group(), line, position))
                        position += match.end()
                        source_code = source_code[match.end():]
                        matched = True
                        break
                
                if not matched:
                    raise ValueError(f"illegal character at {Fore.RED}line {line}{Style.RESET_ALL}, {Fore.RED}position {position}{Style.RESET_ALL}")
                
                line += match.group().count(";")

        except ValueError as e:
            print(f"IllegalCharError: {e}")
        
        return tags
    
    def print_tags(self):
        print(self.tags);
    
    def print_source(self):
        current_tag = ""

        while current_tag != None:

            for tag in self.tags:
                style, instance, l, position = tag

                if style == "EOF":
                    print(f"{Fore.RED}{style}{Style.RESET_ALL}")
                
                else:
                    print(f"{Fore.BLUE}{style}{Style.RESET_ALL}")
            
            current_tag = None

    def print_source_code(self):
        line_list = []
        current_tag = ""
        
        while current_tag != None:
            line = []

            for tag in self.tags:
                style, instance, l, position = tag
                line.append((style, instance))

                if style == "EOF":
                    line_list.append(line)
                    line = []
                
            current_tag = None
        
        line_number = 1
        for line in line_list:
            line_string = ""
            
            for tag in line:
                style, instance = tag

                line_string += instance
            
            print(f"{Fore.BLUE}{line_number}| {Style.RESET_ALL}{line_string}")
            line_number += 1