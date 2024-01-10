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
        ("NUMBER", r"-?\d+(\.\d+)?"),             # 0123456789
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

class Stream02:

    def __init__(self):
        self.tags = []

    def import_as_tags(self, source_code:str):
        lexer = Lexer(source_code)

        for tag in lexer.tags:
            self.add_last(Tag(tag))

    def parse(self):
        paren_pairs = self.get_paren_pairs()
        
        # parse paren first
        for pair in paren_pairs:
            open_index, close_index = pair
            pow_op_list = self.get_pow_op_list(open_index, close_index)
            mul_op_list = self.get_mul_op_list(open_index, close_index)
            div_op_list = self.get_div_op_list(open_index, close_index)
            add_op_list = self.get_add_op_list(open_index, close_index)
            sub_op_list = self.get_sub_op_list(open_index, close_index)

            for pow_op in pow_op_list:
                self.pow_op(pow_op)
            
            for mul_op in mul_op_list:
                self.mul_op(mul_op)

            for div_op in div_op_list:
                self.div_op(div_op)

            for add_op in add_op_list:
                self.add_op(add_op)

            for sub_op in sub_op_list:
                self.sub_op(sub_op)
        
        source_code_size = len(self.tags) - 1
        pow_op_list = []
        mul_op_list = []
        div_op_list = []
        add_op_list = []
        sub_op_list = []
        pow_op_list = self.get_pow_op_list(0, source_code_size)
        mul_op_list = self.get_mul_op_list(0, source_code_size)
        div_op_list = self.get_div_op_list(0, source_code_size)
        add_op_list = self.get_add_op_list(0, source_code_size)
        sub_op_list = self.get_sub_op_list(0, source_code_size)

        for pow_op in pow_op_list:
            self.pow_op(pow_op)
        
        for mul_op in mul_op_list:
            self.mul_op(mul_op)

        for div_op in div_op_list:
            self.div_op(div_op)

        for add_op in add_op_list:
            self.add_op(add_op)

        for sub_op in sub_op_list:
            self.sub_op(sub_op)
        
        for tag in self.tags:

            if tag.style == "LPAREN" or tag.style == "RPAREN":
                self.mark_for_deletion(tag.position)
        
        self.delete()

    def pow_op(self, position:int) -> float:
        position_of_pow:int = position
        found_lnumber = False
        found_rnumber = False
        current_position = position_of_pow
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
        
        result = float(stack[0]) ** float(stack[1])
        self.tags[position_of_pow] = Tag(("NUMBER", str(result), self.get_position_line(position_of_pow), position_of_pow))
        self.delete()
        self.delete()
        self.delete()
        self.recalculate_positions()

        return result

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
    
    def get_pow_op_list(self, range_start:int, range_end:int) -> list:
        
        return self.get_op_list(range_start, range_end, "POW")
    
    def get_mul_op_list(self, range_start:int, range_end:int) -> list:
        
        return self.get_op_list(range_start, range_end, "MUL")
    
    def get_div_op_list(self, range_start:int, range_end:int) -> list:

        return self.get_op_list(range_start, range_end, "DIV")
    
    def get_add_op_list(self, range_start:int, range_end:int) -> list:

        return self.get_op_list(range_start, range_end, "ADD")

    def get_sub_op_list(self, range_start:int, range_end:int) -> list:

        return self.get_op_list(range_start, range_end, "SUB")

    def get_op_list(self, range_start:int, range_end:int, style:str) -> list:
        current_position = range_start
        end_position = range_end
        end_position += 1
        stack = []

        while current_position is not end_position:
            current_tag = self.tags[current_position]

            if current_tag.style == style:
                stack.append(current_position)

            current_position += 1
        
        return stack

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


class Opcode:
    
    def __init__(self) -> None:
        self.opcode:str = None
        self.instance:str = None
        self.line:int = None
        self.position:int = None

    def import_from_tag(self, tag:tuple) -> None:
        opcode, instance, line, position = tag
        self.opcode:str = opcode
        self.instance:str = instance
        self.line:int = line
        self.position:int = position

    def config(self, opcode:str, instance:str, line:int, position:int) -> None:
        self.opcode:str = opcode
        self.instance:str = instance
        self.line:int = line
        self.position:int = position

class Stream:

    def __init__(self):
        pass

    def import_as_opcode(self, source_code:str) -> list:
        stream:list = []
        lexer:Lexer = Lexer(source_code=source_code)

        for tag in lexer.tags:            
            opcode = Opcode()
            opcode.import_from_tag(tag)
            stream.append(opcode)

        return stream

    def split_into_line(self, stream:list) -> list:
        new_stream:list = []
        line:list = []

        for opcode in stream:
            line.append(opcode)

            if opcode.opcode == "EOF":
                new_stream.append(line)
                line:list = []
        
        return new_stream
    
    def delete(self, stream:list) -> list:

        for opcode in stream:
            
            if opcode.instance == "DEL":
                stream.pop(opcode.position)
            
        return stream
    
    def mark_for_deletion(self, stream:list, positions:list) -> list:

        for opcode in stream:

            if opcode.position in positions:
                opcode.instance = "DEL"
        
        return stream

    def recalculate_positions(self, stream:list) -> list:        
        current_position = 0
        new_stream:list = []

        for opcode in stream:
            opcode.position = current_position
            opcode.line = self.get_position_line(stream, opcode.position)
            current_position += 1
            new_stream.append(opcode)
        
        return new_stream
    
    def search(self, stream:list, search_opcode:str, start_position:int, direction:str) -> tuple:
        found:bool = False
        if direction is "l": current_position = start_position - 1
        if direction is "r": current_position = start_position + 1
        in_between:list = []
        result:None = None

        while found is False:
            current_opcode = stream[current_position]
            in_between.append(current_position)

            if current_opcode.opcode is search_opcode:
                result = current_opcode.instance
                found = True
            
            if direction is "l": current_position -= 1
            if direction is "r": current_position += 1
        
        return (result, in_between)
    
    def get_pairs(self, stream:list, opcode_base_string:str) -> list:
        """ie. PAREN for LPAREN and RPAREN"""
        stack:list = []
        pairs:list = []

        for i, opcode in enumerate(stream):

            if opcode.opcode == f"L{opcode_base_string}":
                stack.append(i)
            
            elif opcode.opcode == f"R{opcode_base_string}":

                if stack:
                    open_index = stack.pop()
                    close_index = i
                    pairs.append((open_index, close_index))
        
        return pairs

    def get_position_line(self, stream:list, position:int) -> int | None:
        current_line_number = 1
        current_position = 0

        for opcode in stream:

            if current_position is position:

                return current_line_number
            
            if opcode.opcode == "EOF":
                current_line_number += 1
            
            current_position += 1
        
        return None

stream = Stream()
stack = []
stack = stream.import_as_opcode(source_code="this is a sourc(e) code; 2 + 2; x = 2;")
result, in_between = stream.search(stack, "NUMBER", 0, "r")
stack = stream.mark_for_deletion(stack, in_between)
stack = stream.delete(stack)
stack = stream.delete(stack)
string = ""
for op in stack:

    string += op.instance

print(string)
