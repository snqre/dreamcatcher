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
        ("DEL", r"DEL"),                # DEL
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
                
                # EOF HARD CODE
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
    
    def mul_op(self, position:int) -> float:
        position_of_mul:int = position
        found_lnumber:bool = False
        found_rnumber:bool = False
        current_position:int = position_of_mul
        current_position -= 1
        stack = []

        while found_lnumber == False:
            current_tag = self.tags[current_position]
            self.mark_for_deletion(current_tag.position)

            if current_tag.style == "NUMBER":
                stack.append(current_tag.instance)
                found_lnumber = True
            
            current_position -= 1
        
        current_position = position
        current_position += 1

        while found_rnumber == False:
            current_tag = self.tags[current_position]
            self.mark_for_deletion(current_tag.position)

            if current_tag.style == "NUMBER":
                stack.append(current_tag.instance)
                found_rnumber = True
            
            current_position += 1
        
        result = float(stack[0]) * float(stack[1])
        self.tags[position_of_mul] = Tag(("NUMBER", str(result), self.get_position_line(position_of_mul), position_of_mul))
        self.delete()
        self.delete()
        self.delete()
        self.recalculate_positions()

        return result

    def div_op(self, position:int) -> float:
        position_of_div:int = position
        found_lnumber = False
        found_rnumber = False
        current_position = position_of_div
        current_position -= 1
        stack = []
        
        while found_lnumber == False:
            current_tag = self.tags[current_position]
            self.mark_for_deletion(current_tag.position)

            if current_tag.style == "NUMBER":
                stack.append(current_tag.instance)
                found_lnumber = True
            
            current_position -= 1

        current_position = position
        current_position += 1

        while found_rnumber == False:
            current_tag = self.tags[current_position]
            self.mark_for_deletion(current_tag.position)

            if current_tag.style == "NUMBER":
                stack.append(current_tag.instance)
                found_rnumber = True
            
            current_position += 1
        
        result = float(stack[0]) / float(stack[1])
        self.tags[position_of_div] = Tag(("NUMBER", str(result), self.get_position_line(position_of_div), position_of_div))
        self.delete()
        self.delete()
        self.delete()
        self.recalculate_positions()

        return result

    def add_op(self, position:int) -> float:
        position_of_add:int = position
        found_lnumber = False
        found_rnumber = False
        current_position = position_of_add
        current_position -= 1
        stack = []

        while found_lnumber == False:
            current_tag = self.tags[current_position]
            self.mark_for_deletion(current_tag.position)

            if current_tag.style == "NUMBER":
                stack.append(current_tag.instance)
                found_lnumber = True
            
            current_position -= 1
        
        current_position = position
        current_position += 1

        while found_rnumber == False:
            current_tag = self.tags[current_position]
            self.mark_for_deletion(current_tag.position)

            if current_tag.style == "NUMBER":
                stack.append(current_tag.instance)
                found_rnumber = True
            
            current_position += 1
        
        result = float(stack[0]) + float(stack[1])
        self.tags[position_of_add] = Tag(("NUMBER", str(result), self.get_position_line(position_of_add), position_of_add))
        self.delete()
        self.delete()
        self.delete()
        self.recalculate_positions()

        return result
    
    def sub_op(self, position:int) -> float:
        position_of_sub:int = position
        found_lnumber = False
        found_rnumber = False
        current_position = position_of_sub
        current_position -= 1
        stack = []

        while found_lnumber == False:
            current_tag = self.tags[current_position]
            self.mark_for_deletion(current_tag.position)

            if current_tag.style == "NUMBER":
                stack.append(current_tag.instance)
                found_lnumber = True
            
            current_position -= 1

        current_position = position
        current_position += 1

        while found_rnumber == False:
            current_tag = self.tags[current_position]
            self.mark_for_deletion(current_tag.position)

            if current_tag.style == "NUMBER":
                stack.append(current_tag.instance)
                found_rnumber = True
            
            current_position += 1
        
        result = float(stack[0]) - float(stack[1])
        self.tags[position_of_sub] = Tag(("NUMBER", str(result), self.get_position_line(position_of_sub), position_of_sub))
        self.delete()
        self.delete()
        self.delete()
        self.recalculate_positions()

        return result

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

    def sub(self, position):
        self.tags.pop(position)
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
    
    def delete(self):
        
        for tag in self.tags:

            if tag.style == "DEL":
                self.sub(tag.position)

    def mark_for_deletion(self, position:int):
        self.tags[position] = Tag(("DEL", "DEL", self.get_position_line(position), position))

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
        stack = []
        pairs = []

        for i, tag in enumerate(self.tags):

            if tag.style == "LPAREN":
                stack.append(i)

            elif tag.style == "RPAREN":

                if stack:
                    open_index = stack.pop()
                    close_index = i
                    pairs.append((open_index, close_index))

        return pairs
    
    def get_brace_pairs(self):
        stack = []
        pairs = []

        for i, tag in enumerate(self.tags):

            if tag.style == "LBRACE":
                stack.append(i)
        
            elif tag.style == "RBRACE":
            
                if stack:
                    open_index = stack.pop()
                    close_index = i
                    pairs.append((open_index, close_index))
        
        return pairs
    
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

    def stream(self, speed:float, source:str, on_one_line:bool):
        string = ""

        for tag in self.tags:

            if not on_one_line:

                if source == "style":
                    string = tag.style
                
                elif source == "instance":
                    string = tag.instance
                
                elif source == "position":
                    string = tag.position
                
                elif source == "line":
                    string = tag.line

                if tag.style == "EOF":
                    print(f"{Fore.RED}{string}{Style.RESET_ALL}")

                else:
                    print(f"{Fore.CYAN}{string}{Style.RESET_ALL}")

                time.sleep(speed)
            
            else:

                if source == "style":
                    
                    if tag.style == "EOF":
                        string += f"{Fore.RED}{tag.style} >{Style.RESET_ALL}"

                    else:
                        string += f"{tag.style} {Fore.RED}>{Style.RESET_ALL}"
                
                elif source == "instance":
                    string += tag.instance

                elif source == "position":
                    string += f"{tag.position} {Fore.RED}>{Style.RESET_ALL}"
                
                elif source == "line":
                    string += f"{tag.line} {Fore.RED}>{Style.RESET_ALL}"
                
        if on_one_line:

            print(string)




stream = Stream()
stream.import_as_tags("""( ( -24940 - 2293 )(((()))));jump;;;;;;;{ this {Ids} }""")
#print(stream.get_paren_pairs())
#print(stream.get_brace_pairs())

stream.stream(0.05, "instance", True)
stream.add_op(6)
stream.stream(0.05, "instance", True)