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
                                                                                                    
        
@dev Welcome to catch. Catch is a custom language used on Dreamcatcher to integrate blockchain smart contracts, event-driven programs, and more.
     Using .catch you can add, remove, and update functions (jumps) at run time. The built in modularity mechanisms allows anyone to install
     .catch modules from the market place to run trading algorithms ie. if cnn does x, then do y. Event driven programs, which can allow
     chaining of jumps. If $BTC is above $30,000, call x, which calls y, and so on. Multiple functions can listen to these events and
     react accordingly.

@dev Catch comes with built in types such the smart datatype which is a wrapper for contracts. Easily wrap contracts and interact with them
     in catch as if you were directly interacting with them on the blockchain. NOTE __connect must be called prior writing to contract.

1. Lexer

== Commands
    

in [ float ] { seconds, hours, days, weeks, months, years }

buy / sell [ float ]

<chain> <ERC20/ERC712> <address> -> <address>

__events.latest()
__events.trigger()



jump transfer() listen [] {{
    x = 4;
    __recent;
    __lastBlock;
    __auth(address);
    __connect;
}, 2 seconds}
"""

import itertools;
import re;

DIGITS = "0123456789";

def stringWithArrows(text, posStart, posEnd):
    result = "";
    idxStart = max(text.rfind("\n", 0, posStart.idx), 0);
    idxEnd = text.find("\n", idxStart + 1);
    if idxEnd < 0: idxEnd = len(text);
    lineCount = posEnd.ln - posStart.ln + 1;
    for i in range(lineCount):
        line = text[idxStart:idxEnd];
        colStart = posStart.col if i == 0 else 0;
        colEnd = posEnd.col if i == lineCount - 1 else len(line) - 1;
        result += line + "\n";
        result += " " * colStart + "^" * (colEnd - colStart);
        idxStart = idxEnd;
        idxEnd = text.find("\n", idxStart + 1);
        if idxEnd < 0: idxEnd = len(text);
    return result.replace("\t", "");

"""
.########.########..########...#######..########...######.
.##.......##.....##.##.....##.##.....##.##.....##.##....##
.##.......##.....##.##.....##.##.....##.##.....##.##......
.######...########..########..##.....##.########...######.
.##.......##...##...##...##...##.....##.##...##.........##
.##.......##....##..##....##..##.....##.##....##..##....##
.########.##.....##.##.....##..#######..##.....##..######.
"""

class Error:
    def __init__(self, posStart, posEnd, errorName, details):
        self.posStart = posStart;
        self.posEnd = posEnd;
        self.errorName = errorName;
        self.details = details;
    def asString(self):
        result = f"{self.errorName}: {self.details}";
        result += f"File {self.posStart.fn}, line {self.posStart.ln + 1}";
        result += "\n\n" + stringWithArrows(self.posStart.ftxt, self.posStart, self.posEnd);
        return result;

class IllegalCharError(Error):
    def __init__(self, posStart, posEnd, details):
        super().__init__(posStart, posEnd, "Illegal Character", details);

class InvalidSyntaxError(Error):
    def __init__(self, posStart, posEnd, details=""):
        super().__init__(posStart, posEnd, "Invalid Syntax", details);

"""
.########...#######...######..####.########.####..#######..##....##
.##.....##.##.....##.##....##..##.....##.....##..##.....##.###...##
.##.....##.##.....##.##........##.....##.....##..##.....##.####..##
.########..##.....##..######...##.....##.....##..##.....##.##.##.##
.##........##.....##.......##..##.....##.....##..##.....##.##..####
.##........##.....##.##....##..##.....##.....##..##.....##.##...###
.##.........#######...######..####....##....####..#######..##....##
"""

class Position:
    def __init__(self, idx, ln, col, fn, ftxt):
        self.idx = idx;
        self.ln = ln;
        self.col = col;
        self.fn = fn;
        self.ftxt = ftxt;
    def advance(self, currentCharacter):
        self.idx += 1;
        self.col += 1;
        if currentCharacter == "\n":
            self.ln += 1;
            self.col = 0;
        return self;
    def copy(self):
        return Position(self.idx, self.ln, self.col, self.fn, self.ftxt);

"""
.########..#######..##....##.########.##....##..######.
....##....##.....##.##...##..##.......###...##.##....##
....##....##.....##.##..##...##.......####..##.##......
....##....##.....##.#####....######...##.##.##..######.
....##....##.....##.##..##...##.......##..####.......##
....##....##.....##.##...##..##.......##...###.##....##
....##.....#######..##....##.########.##....##..######.
"""

INT      = "INT";    # 0
FLOAT    = "FLOAT";  # 0.00
ADD      = "ADD";    # +
SUB      = "SUB";    # -
MUL      = "MUL";    # *
DIV      = "DIV";    # /
LPA      = "LPA";    # )
RPA      = "RPA";    # (
LCB      = "LCB";    # }
RCB      = "RCB";    # {
EOF      = ";";      # ;
JUMP     = "JUMP";   # jump

class Token:
    def __init__(self, style, val=None, posStart=None, posEnd=None):
        self.style = style;
        self.val = val;
        if posStart:
            self.posStart = posStart.copy();
            self.posEnd = posStart.copy();
            self.posEnd.advance();
        if posEnd:
            self.posEnd = posEnd.copy();
    def __repr__(self) -> str:
        if self.val: return f"{self.style}:{self.val}";
        return f"{self.style}";

"""
.##.......########.##.....##.########.########.
.##.......##........##...##..##.......##.....##
.##.......##.........##.##...##.......##.....##
.##.......######......###....######...########.
.##.......##.........##.##...##.......##...##..
.##.......##........##...##..##.......##....##.
.########.########.##.....##.########.##.....##
"""

class Lexer:
    def __init__(self, fn, text):
        self.fn = fn;
        self.text:str = text;
        self.pos = Position(-1, 0, -1, fn, text);
        self.currentCharacter = None;
        self.advance();
    def advance(self):
        self.pos.advance(self.currentCharacter);
        self.currentCharacter = self.text[self.pos.idx] if self.pos.idx < len(self.text) else None
    def makeTokens(self) -> list | None:
        tkns:list = []
        while self.currentCharacter != None:
            if self.currentCharacter in "\t":
                self.advance();
            elif self.currentCharacter in DIGITS:
                tkns.append(self.makeNumber());
            elif self.currentCharacter == "+":
                tkns.append(Token(ADD));
                self.advance();
            elif self.currentCharacter == "-":
                tkns.append(Token(SUB));
                self.advance();
            elif self.currentCharacter == "*":
                tkns.append(Token(MUL));
                self.advance();
            elif self.currentCharacter == "/":
                tkns.append(Token(DIV));
                self.advance();
            elif self.currentCharacter == "(":
                tkns.append(Token(LPA));
                self.advance();
            elif self.currentCharacter == ")":
                tkns.append(Token(RPA));
                self.advance();
            elif self.currentCharacter == "{":
                tkns.append(Token(LCB));
                self.advance();
            elif self.currentCharacter == "}":
                tkns.append(Token(RCB));
                self.advance();
            elif self.currentCharacter == ";":
                tkns.append(Token(EOF));
                self.advance();
            elif self.currentCharacter == "jump":
                tkns.append(Token(JUMP));
                self.advance();
            else:
                posStart = self.pos.copy();
                character = self.currentCharacter;
                self.advance();
                return [], IllegalCharError(posStart, self.pos, f"'{character}'");
        return tkns, None;
    def makeNumber(self):
        numString = " ";
        dotCount = 0;
        while self.currentCharacter != None and self.currentCharacter in DIGITS + ".":
            if self.currentCharacter == ".":
                if dotCount == 1: break;
                dotCount += 1;
                numString += ".";
            else:
                numString += self.currentCharacter;
            self.advance();
        if dotCount == 0:
            return Token(INT, int(numString));
        else:
            return Token(FLOAT, float(numString));

"""
.##....##..#######..########..########..######.
.###...##.##.....##.##.....##.##.......##....##
.####..##.##.....##.##.....##.##.......##......
.##.##.##.##.....##.##.....##.######....######.
.##..####.##.....##.##.....##.##.............##
.##...###.##.....##.##.....##.##.......##....##
.##....##..#######..########..########..######.
"""

class NumberNode:
    def __init__(self, tkn):
        self.tkn = tkn;
    def __repr__(self):
        return f"{self.tkn}";

class BinOpNode:
    def __init__(self, leftNode, opTkn, rightNode):
        self.leftNode = leftNode;
        self.opTkn = opTkn;
        self.rightNode = rightNode;
    def __repr__(self):
        return f"({self.leftNode}, {self.opTkn}, {self.rightNode})";

"""
.########.....###....########...######..########....########..########..######..##.....##.##.......########
.##.....##...##.##...##.....##.##....##.##..........##.....##.##.......##....##.##.....##.##..........##...
.##.....##..##...##..##.....##.##.......##..........##.....##.##.......##.......##.....##.##..........##...
.########..##.....##.########...######..######......########..######....######..##.....##.##..........##...
.##........#########.##...##.........##.##..........##...##...##.............##.##.....##.##..........##...
.##........##.....##.##....##..##....##.##..........##....##..##.......##....##.##.....##.##..........##...
.##........##.....##.##.....##..######..########....##.....##.########..######...#######..########....##...
"""

class ParseResult:
    def __init__(self):
        self.error = None;
        self.node = None;
    def register(self, res):
        if isinstance(res, ParseResult):
            if res.error: self.error = res.error;
            return res.node;
        return res;
    def success(self, node):
        self.node = node;
        return self;
    def failure(self, error):
        self.error = error;
        return self;

"""
.########.....###....########...######..########.########.
.##.....##...##.##...##.....##.##....##.##.......##.....##
.##.....##..##...##..##.....##.##.......##.......##.....##
.########..##.....##.########...######..######...########.
.##........#########.##...##.........##.##.......##...##..
.##........##.....##.##....##..##....##.##.......##....##.
.##........##.....##.##.....##..######..########.##.....##
"""

class Parser:
    def __init__(self, tkns):
        self.tkns = tkns;
        self.tknIdx = -1;
        self.advance();
    def advance(self):
        self.tknIdx += 1;
        if self.tknIdx < len(self.tkns):
            self.currentTkn = self.tkns[self.tknIdx];
        return self.currentTkn;
    def parse(self):
        res = self.expression();
        return res;
    def factor(self):
        res = ParseResult();
        tkn = self.currentTkn;
        if tkn.style in (INT, FLOAT):
            res.register(self.advance());
            return NumberNode(tkn);
    def term(self):
        return self.binOp(self.factor, (MUL, DIV));
    def expression(self):
        return self.binOp(self.term, (ADD, SUB));
    def binOp(self, func, ops):
        left = func();
        while self.currentTkn.style in ops:
            opTkn = self.currentTkn;
            self.advance();
            right = func();
            left = BinOpNode(left, opTkn, right);
        return left;

"""
.########..##.....##.##....##
.##.....##.##.....##.###...##
.##.....##.##.....##.####..##
.########..##.....##.##.##.##
.##...##...##.....##.##..####
.##....##..##.....##.##...###
.##.....##..#######..##....##
"""

def run(fn, text):
    lexer = Lexer(fn, text);
    tkns, error = lexer.makeTokens();
    if error: return None, error;

    # AST
    parser = Parser(tkns);
    ast = parser.parse();

    return ast, None;

""" 
def getUserInput():
    for i in itertools.count():
        try:
            yield i, input("in [%d]: " % i);
        except KeyboardInterrupt:
            pass;
        except EOFError:
            break;

def executeUserInput(i, userInput, storage):
    exec(userInput, storage);

def main():

    storage:dict = {};
    
    for i, userInput in getUserInput():
        executeUserInput(i, userInput, storage);


if __name__ == "__main__":
    main();
"""