"""
                                                                                 
        CCCCCCCCCCCCC                          tttt                             hhhhhhh             
     CCC::::::::::::C                       ttt:::t                             h:::::h             
   CC:::::::::::::::C                       t:::::t                             h:::::h             
  C:::::CCCCCCCC::::C                       t:::::t                             h:::::h             
 C:::::C       CCCCCC  aaaaaaaaaaaaa  ttttttt:::::ttttttt        cccccccccccccccch::::h hhhhh       
C:::::C                a::::::::::::a t:::::::::::::::::t      cc:::::::::::::::ch::::hh:::::hhh    
C:::::C                aaaaaaaaa:::::at:::::::::::::::::t     c:::::::::::::::::ch::::::::::::::hh  
C:::::C                         a::::atttttt:::::::tttttt    c:::::::cccccc:::::ch:::::::hhh::::::h 
C:::::C                  aaaaaaa:::::a      t:::::t          c::::::c     ccccccch::::::h   h::::::h
C:::::C                aa::::::::::::a      t:::::t          c:::::c             h:::::h     h:::::h
C:::::C               a::::aaaa::::::a      t:::::t          c:::::c             h:::::h     h:::::h
 C:::::C       CCCCCCa::::a    a:::::a      t:::::t    ttttttc::::::c     ccccccch:::::h     h:::::h
  C:::::CCCCCCCC::::Ca::::a    a:::::a      t::::::tttt:::::tc:::::::cccccc:::::ch:::::h     h:::::h
   CC:::::::::::::::Ca:::::aaaa::::::a      tt::::::::::::::t c:::::::::::::::::ch:::::h     h:::::h
     CCC::::::::::::C a::::::::::aa:::a       tt:::::::::::tt  cc:::::::::::::::ch:::::h     h:::::h
        CCCCCCCCCCCCC  aaaaaaaaaa  aaaa         ttttttttttt      cccccccccccccccchhhhhhh     hhhhhhh
        
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    DATATYPES

    ╔═══════╗
    ║INT    ║
    ╠═══════╣
    ║FLOAT  ║
    ╠═══════╣
    ║STR    ║
    ╠═══════╣
    ║BOOL   ║
    ╠═══════╣
    ║LIST   ║
    ╠═══════╣
    ║MAPPING║
    ╠═══════╣
    ║NONE   ║
    ╚═══════╝

    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    ABSTRACT SYNTAX TREE



"""

import re # definitely not adviced to do it this way
from colorama import Fore, Style
import time

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
        ("ON", r"on"),                  # on
        ("$", r"$"),                    # $
        ("WAIT", r"wait"),              # wait
        ("LOOKUP", r"lookup"),          # lookup
        ("LOOKFOR", r"lookfor"),        # lookfor
        ("DELEGATE", r"delegate"),      # delegate
        ("QUOTE01", r"'"),              # '
        ("QUOTE02", r'"'),              # "
        ("IDENTIFIER", r"[a-zA-Z_][a-zA-Z0-9_]*"),
        ("RETURN", r"return"),          # return
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

class Tag:
    
    def __init__(self, tag):
        style, instance, line, position = tag
        self.style = style
        self.instance = instance
        self.line = line
        self.position = position

class Stream:

    def __init__(self):
        self.tags = []

    def import_as_tags(self, source_code:str):
        lexer = Lexer(source_code)

        for tag in lexer.tags:
            self.add_last(Tag(tag))

    def combine(self, positionA:int, positionB:int, positionC:int, new_tag:Tag):
        pass
    
    def add_last(self, tag:Tag):
        self.tags.append(tag)
        self.recalculate_positions()
    
    def add_after_position(self, position:int, tag:Tag):
        position += 1
        self.tags.insert(position, tag)
        self.recalculate_positions()
    
    def add_before_position(self, position:int, tag:Tag):
        self.tags.insert(position, tag)
        self.recalculate_positions()

    def sub_last(self):
        self.tags.pop()
        self.recalculate_positions()

    def sub_after_position(self, position:int):
        position += 1
        self.tags.pop(position)
        self.recalculate_positions()
    
    def sub_before_position(self, position:int):
        position -= 1
        self.tags.pop(position)
        self.recalculate_positions()

    def recalculate_positions(self):
        current_position = 0

        for tag in self.tags:
            tag.position = current_position
            tag.line = self.get_position_line(tag.position)
            current_position += 1

    def get_position_line(self, position:int) -> int | None:
        current_line_number = 1
        current_position = 0

        for tag in self.tags:

            if current_position == position:
                
                return current_line_number

            if tag.style == "EOF":
                current_line_number += 1

            current_position += 1
        
        return None

    def get_paren_pairs(self):
        pairs = []
        stack = []
        
        stack_size:int = 0
        match_size:int = 0

        for tag in self.tags:

            if tag.style == "LPAREN":
                stack.append(tag.position)
                stack_size += 1

            if tag.style == "RPAREN":
                stack.append(tag.position)
                match_size += 1

                if stack_size == match_size:
                    number_of_LPAREN:int = stack_size / 2
                    number_of_RPAREN:int = stack_size / 2
                    
                    # one set
                    if number_of_LPAREN == 0.5 and number_of_RPAREN == 0.5:
                        LPAREN = stack[0]
                        LPAREN += 1
                        RPAREN = tag.position
                        RPAREN += 1
                        inner_tags:list = []

                        for i in range(LPAREN + 1, RPAREN):
                            inner_tags.append(i)
                        
                        pairs.append((LPAREN, RPAREN, inner_tags))
                        stack = []

                    # if it aint broke dont fix it
                    else:

                        number_of_paren = 0
                        number_of_paren += number_of_LPAREN
                        number_of_paren += number_of_RPAREN
                        number_of_paren *= 2
                        lparen:list = []
                        rparen:list = []
                        pulse:int = 0

                        for i in range(int(number_of_paren)):
                            
                            if pulse <= (number_of_LPAREN + number_of_RPAREN) - 1:
                                lparen.append(stack[i])
                                pulse += 1
                            
                            else:
                                rparen.append(stack[i])

                        print(self.pair_min_with_max(lparen, rparen))

                    stack_size = 0
                    match_size = 0

        # TODO fix this mess return should return the pos left paren and pos right paren, pos of all items within it
        print(pairs)
    
    def pair_min_with_max(self, listA:list, listB:list) -> list:
        tempA:list = []
        tempB:list = []
        paired_values = []
        length_of_listA = len(listA)
        length_of_listB = len(listB)
        
        for _ in range(length_of_listA):
            lowest = min(listA)
            index = listA.index(lowest)
            listA.pop(index)
            tempA.append(lowest)
        
        for _ in range(length_of_listB):
            highest = max(listB)
            index = listB.index(highest)
            listB.pop(index)
            tempB.append(highest)

        for i in range(len(tempA)):
            paired_values.append((tempA[i], tempB[i]))
        
        return paired_values

    def stream(self, speed:float):

        for tag in self.tags:
            string = tag.style

            if tag.style == "EOF":
                print(f"{Fore.RED}{string}{Style.RESET_ALL}")

            else:
                print(f"{Fore.CYAN}{string}{Style.RESET_ALL}")

            time.sleep(speed)


stream = Stream()
stream.import_as_tags("""(2 + 5 ** 3);""")
stream.get_paren_pairs()
stream.stream(0)

class Op:

    def __init__(self, position, begin, end):
        self.position = position
        self.begin = begin
        self.end = end

class Interpreter:

    def __init__(self, source_code):
        self.lexer = Lexer(source_code)
        self.tags = []
        self.style_stream = []

        for tag in self.lexer.tags:
            new_tag = Tag(tag)
            self.tags.append(new_tag)
            self.style_stream.append(new_tag.style)

    def parse(self):
        parsed = False

        while not parsed:
            newly_parsed = []
            current_tag = ""

            while current_tag != None:

                for tag in self.tags:
                    current_tag = tag
            
                current_tag = None
            

        current_tag = ""

        while current_tag != None:

            for tag in self.tags:

                pass

            current_tag = None




    def print_style_stream(self):
        
        for style in self.style_stream:
            print(style)
            time.sleep(0.1)

#interpreter = Interpreter(""");jump; 3 + 4; 89 / 2; ( noise noise);follow a_function; jump start; 2;""")

#interpreter.parse()