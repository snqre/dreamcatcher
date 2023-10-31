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

@dev Inbuilt threading


Naming =>

    camelCase


DataTypes =>

    int
    uint
    float
    str -> string
    bytes
    contract
    interface
    fund

Syntax =>

    Comments =>

        # a comment 
        
        <!-- also a comment -->

        /** also a comment */

        /**
        * very much also a comment
        *
        * @dev kind of like javascript but also like python
         */

    Declaration =>    

        x:int;
        x:contract;

    Keywords =>

        buy
        sell
        on
        in
        with
        while
        for
        if
        when
        connect
        disconnect
        jump
        await
        ERC20
        ERC4626
        
        command
        port
        run[<port>]
        
    Declare Console Command =>

        command --<consoleCommand>;
        

open <window.timelocks>

close <window.proposals>
delegate <vote>

__events.latest()
__events.trigger()

jump transfer() listen [] {{
    connect <chain> <address> aContract; # fetch ABI directly online | failed if not verified
    connect # connect to owner wallet
    
    connect <chain> <address> contract = [ABI];

    wait aContract.doSomething # call like you would onchain;

    pause function whilst transaction is being confirmed
    throw error if transaction not done

    time.sleep(2) # keep looping until transaction confirmed if keyward [ wait ] is used
    
    [ on ] polygon quickswap {{
        if ($ticker <> $price == 0.394) {{
            doSomething();
        }}
        [ after ] 3480 seconds [ buy ] 4000 $ticker $priceMin;
    }}

    # in this case the user acts as if they were the owner | will throw if this is not the case
    [ with ] aContract {{
        -> to
        <address>.deposit();
        call();
    }}

    [ on ] aContractWhichIDontOwn {{
        <!-- call functions -->
        withdraw();

        [ on ] anotherContract {{
            withdraw();
            super.withdraw();
        }}
    }}
    
    connect polygon <address> contractA;
    connect polygon <address> contractB;

    prog polygon contractC = contractA + contractB;

    {{ manage multiple contracts as one program, NOTE will check if there are any duplicate functions and throw }}.

    contractC.withdraw();
    



    polygon ERC20 <from> -> <to>; # easy transfer calls

    price = $ticker <> $price [ on ] ethereum uniswap;
    if (price != $ticker <> $price [ on ] polygon uniswap) {{
        doSomethingElse();
    }}
}}

jump transfer() listen [] {{
    x = 4;
    connect <address>
    pickup
    disconnect
}, 2 seconds}



<!-- this is a function comment -->
jump x() { $(time,object,message) {
    connect smart;
    smart.withdraw;
    disconnect smart;
}, 3600 seconds }

<!-- built in console function -->
listen

<!-- -->
in [ duration ]
buy | sell | long | short | 

$Ticker ethereum uniswap;
$Ticker polygon uniswap;


UI commands #

--spawn --600 --500 --left --window.timelock;
--clear window.timelock;
--dup window.timelock --right;

--setColor
--setBackground
--setProfile

--accounting;

--upload

--help

--reset
    are you sure?


--go # some

--gopro # remove all buttons for professionals

--polygon --erc20 --transfer --to --from --

--var --yourVariable
--set --yourVariable --59
--for --i --590 --++

"""
import threading;
import string;

DIGITS = "0123456789";
LETTERS = string.ascii_letters;
LETTERS_DIGITS = LETTERS + DIGITS;

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

class RTError(Error):
    def __init__(self, posStart, posEnd, details, context):
        super().__init__(posStart, posEnd, "Runtime Error", details);
        self.context = context;
    def asString(self):
        result = self.generateTraceback();
        result += f"{self.errorName}: {self.details}";
        result += "\n\n" + stringWithArrows(self.posStart.ftxt, self.posStart, self.posEnd);
        return result;
    def generateTraceback(self):
        result = "";
        pos = self.posStart;
        ctx = self.context;
        while ctx:
            result = f" File {pos.fn}, line {str(pos.ln + 1)}, in {ctx.displayName}\n" + result;
            pos = ctx.parentEntryPos;
            ctx = ctx.parent;
        return "Traceback (most recent call last):\n" + result;

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
    def advance(self, currentCharacter=None):
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

The token represents individual tokens generated by the lexer. Tokens have a
style (ie. INT, FLOAT, IDENTIFIER) and a value.

"""

INT        = "INT";          # 0
FLOAT      = "FLOAT";        # 0.00
IDENTIFIER = "IDENTIFIER"    #
KEYWORD    = "KEYWORD"       #
ADD        = "ADD";          # +
SUB        = "SUB";          # -
MUL        = "MUL";          # *
DIV        = "DIV";          # /
POW        = "POW";          # **
EQ         = "EQ";           # =
LPA        = "LPA";          # )
RPA        = "RPA";          # (
LCB        = "LCB";          # }
RCB        = "RCB";          # {
EOF        = "EOF";          # ;

KEYWORDS = [
    "store"
];

class Token:
    def __init__(self, style, val=None, posStart=None, posEnd=None):
        self.style = style;
        self.val = val;
        # TODO
        if posStart:
            self.posStart = posStart.copy();
            self.posEnd = posStart.copy();
            self.posEnd.advance();
        if posEnd:
            self.posEnd = posEnd.copy();
    def matches(self, style, val):
        return self.style == style and self.val == val;
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

The lexer is responsible for tokenizing the input code. It defines different
token types like numbers, identifiers, keywords, and operators.

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
            while self.currentCharacter != None and (self.currentCharacter in " \t\n"):
                self.advance();
            # space
            if self.currentCharacter in "\t":
                self.advance();
            # numbers
            elif self.currentCharacter in DIGITS:
                tkns.append(self.makeNumber());
            elif self.currentCharacter in LETTERS:
                tkns.append(self.makeIdentifier());
            # +
            elif self.currentCharacter == "+":
                tkns.append(Token(ADD, posStart=self.pos));
                self.advance();
            # -
            elif self.currentCharacter == "-":
                tkns.append(Token(SUB, posStart=self.pos));
                self.advance();
            # *
            elif self.currentCharacter == "*":
                self.advance();
                # **
                if self.currentCharacter == "*":
                    tkns.append(Token(POW, posStart=self.pos));
                    self.advance();
                else:
                    tkns.append(Token(MUL, posStart=self.pos));
            # =
            elif self.currentCharacter == "=":
                tkns.append(Token(EQ, posStart=self.pos));
                self.advance();
            # /
            elif self.currentCharacter == "/":
                tkns.append(Token(DIV, posStart=self.pos));
                self.advance();
            # (
            elif self.currentCharacter == "(":
                tkns.append(Token(LPA, posStart=self.pos));
                self.advance();
            # )
            elif self.currentCharacter == ")":
                tkns.append(Token(RPA, posStart=self.pos));
                self.advance();
            # {
            elif self.currentCharacter == "{":
                tkns.append(Token(LCB, posStart=self.pos));
                self.advance();
            # }
            elif self.currentCharacter == "}":
                tkns.append(Token(RCB, posStart=self.pos));
                self.advance();
            # ;
            elif self.currentCharacter == ";":
                tkns.append(Token(EOF, posStart=self.pos));
                self.advance();
            # none
            else:
                posStart = self.pos.copy();
                character = self.currentCharacter;
                self.advance();
                return [], IllegalCharError(posStart, self.pos, f"'{character}'");
        tkns.append(Token(EOF));
        return tkns, None;
    def makeNumber(self):
        numString = " ";
        dotCount = 0;
        posStart = self.pos.copy();
        while self.currentCharacter != None and (self.currentCharacter in DIGITS or self.currentCharacter == "."):
            if self.currentCharacter == ".":
                if dotCount == 1: break;
                dotCount += 1;
                numString += ".";
            else:
                numString += self.currentCharacter;
            self.advance();
        if dotCount == 0:
            return Token(INT, int(numString), posStart, self.pos);
        else:
            return Token(FLOAT, float(numString), posStart, self.pos);
    def makeIdentifier(self):
        idString = "";
        posStart = self.pos.copy();
        while self.currentCharacter != None and self.currentCharacter in LETTERS_DIGITS + "_":
            idString += self.currentCharacter;
            self.advance();
        tknType = KEYWORD if idString in KEYWORD else IDENTIFIER;
        return Token(tknType, idString, posStart, self.pos);

"""
.##....##..#######..########..########..######.
.###...##.##.....##.##.....##.##.......##....##
.####..##.##.....##.##.....##.##.......##......
.##.##.##.##.....##.##.....##.######....######.
.##..####.##.....##.##.....##.##.............##
.##...###.##.....##.##.....##.##.......##....##
.##....##..#######..########..########..######.

NumberNode: represents a numeric value.
BinOpNode: represents a binary operation (ie. + - * /).
UnaryOpNode: represents a unary operation (ie -).
"""

class NumberNode:
    def __init__(self, tkn):
        self.tkn = tkn;
        self.posStart = self.tkn.posStart;
        self.posEnd = self.tkn.posEnd;
    def __repr__(self):
        return f"{self.tkn}";

class VarAccessNode:
    def __init__(self, varNameTkn):
        self.varNameTkn = varNameTkn;
        self.posStart = self.varNameTkn.posStart;
        self.posEnd = self.varNameTkn.posEnd;

class VarAssignNode:
    def __init__(self, varNameTkn, valueNode):
        self.varNameTkn = varNameTkn;
        self.valueNode = valueNode;
        self.posStart = self.varNameTkn.posStart;
        self.posEnd = self.valueNode.posEnd;

class BinOpNode:
    def __init__(self, leftNode, opTkn, rightNode):
        self.leftNode = leftNode;
        self.opTkn = opTkn;
        self.rightNode = rightNode;
        self.posStart = self.leftNode.posStart;
        self.posEnd = self.rightNode.posEnd;
    def __repr__(self):
        return f"({self.leftNode}, {self.opTkn}, {self.rightNode})";

class UnaryOpNode:
    def __init__(self, opTkn, node):
        self.opTkn = opTkn;
        self.node = node;
        self.posStart = self.opTkn.posStart;
        self.posEnd = self.node.posEnd;
    def __repr__(self):
        return f"({self.opTkn}, {self.node})";

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

The parser takes the tokens generated by the lexer and constructs an
abstract syntax tree (ast). It defines methods for partsing different parts
of the language, such as expression, terms, and factors.
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
        if not res.error and self.currentTkn.style != EOF:
            return res.failure(InvalidSyntaxError(self.currentTkn.posStart, self.currentTkn.posEnd, "Expected '+', '-', '*' or '/'"));
        return res;

    def atom(self):
        res = ParseResult();
        tkn = self.currentTkn;
        if tkn.style in (INT, FLOAT):
            res.register(self.advance());
            return res.success(NumberNode(tkn));
    
        elif tkn.style == IDENTIFIER:
            res.register(self.advance());
            return res.success(VarAccessNode(tkn));

        elif tkn.style == LPA:
            res.register(self.advance());
            expression = res.register(self.expression());

            if res.error: return res;
        
            if self.currentTkn.style == RPA:
                res.register(self.advance());
                return res.success(expression);
        
            else:
                return res.failure(InvalidSyntaxError(self.currentTkn.posStart, self.currentTkn.posEnd, "Expected ')'"));
        
        return res.failure(InvalidSyntaxError(tkn.posStart, tkn.posEnd, "Expected int, float, '+', '-' or '(')"));

    def power(self):
        return self.binOp(self.atom, (POW,), self.factor);
    def factor(self):
        res = ParseResult();
        tkn = self.currentTkn;
        if tkn.style in (ADD, SUB):
            res.register(self.advance());
            factor = res.register(self.factor());
            if res.error: return res;
            return res.success(UnaryOpNode(tkn, factor));
        return self.power();
    def term(self):
        return self.binOp(self.factor, (MUL, DIV));
    def expression(self):
        res = ParseResult();
        # IF IT BREAKS LOOK HERE!!!!!!!!!!
        if self.currentTkn.matches(KEYWORD, "store"):
            res.register(self.advance());
            if self.currentTkn.style != IDENTIFIER:
                return res.failure(InvalidSyntaxError(self.currentTkn.posStart, self.currentTkn.posEnd, "Expected identifier"));
            varName = self.currentTkn;
            res.register(self.advance());

            if self.currentTkn.style != EQ:
                return res.failure(InvalidSyntaxError(self.currentTkn.posStart, self.currentTkn.posEnd, "Expected '='"));
    
            res .register(self.advance());
            expression = res.register(self.expression());
            if res.error: return res;
            return res.success(VarAssignNode(varName, expression));

        return self.binOp(self.term, (ADD, SUB));
    def binOp(self, funcA, ops, funcB=None):
        if funcB == None:
            funcB = funcA;
        res = ParseResult();
        left = res.register(funcA());
        if res.error: return res;
        while self.currentTkn.style in ops:
            opTkn = self.currentTkn;
            res.register(self.advance());
            right = res.register(funcB());
            if res.error: return res;
            left = BinOpNode(left, opTkn, right);
        return res.success(left);

"""
.########..##.....##.##....##.########.####.##.....##.########....########..########..######..##.....##.##.......########
.##.....##.##.....##.###...##....##.....##..###...###.##..........##.....##.##.......##....##.##.....##.##..........##...
.##.....##.##.....##.####..##....##.....##..####.####.##..........##.....##.##.......##.......##.....##.##..........##...
.########..##.....##.##.##.##....##.....##..##.###.##.######......########..######....######..##.....##.##..........##...
.##...##...##.....##.##..####....##.....##..##.....##.##..........##...##...##.............##.##.....##.##..........##...
.##....##..##.....##.##...###....##.....##..##.....##.##..........##....##..##.......##....##.##.....##.##..........##...
.##.....##..#######..##....##....##....####.##.....##.########....##.....##.########..######...#######..########....##...
"""

class RTResult:
    def __init__(self):
        self.val = None;
        self.error = None;
    def register(self, res):
        if res.error: self.error = res.error;
        return res.val;
    def success(self, val):
        self.val = val;
        return self;
    def failure(self, error):
        self.error = error;
        return self;

"""
.##.....##....###....##.......##.....##.########..######.
.##.....##...##.##...##.......##.....##.##.......##....##
.##.....##..##...##..##.......##.....##.##.......##......
.##.....##.##.....##.##.......##.....##.######....######.
..##...##..#########.##.......##.....##.##.............##
...##.##...##.....##.##.......##.....##.##.......##....##
....###....##.....##.########..#######..########..######.
"""

class Number:
    def __init__(self, val):
        self.val = val;
        self.setPos();
        self.setContext();
    def setPos(self, posStart=None, posEnd=None):
        self.posStart = posStart;
        self.posEnd = posEnd;
        return self;
    def setContext(self, context=None):
        self.context = context;
        return self;
    def add(self, other):
        if isinstance(other, Number):
            return Number(self.val + other.val).setContext(self.context), None;
    def sub(self, other):
        if isinstance(other, Number):
            return Number(self.val - other.val).setContext(self.context), None;
    def mul(self, other):
        if isinstance(other, Number):
            return Number(self.val * other.val).setContext(self.context), None;
    def div(self, other):
        if isinstance(other, Number):
            if other.val == 0:
                return None, RTError(other.posStart, other.posEnd, "Division by zero", self.context);
            return Number(self.val / other.val).setContext(self.context), None;
    def pow(self, other):
        if isinstance(other, Number):
            return Number(self.val ** other.val).setContext(self.context), None;
    def __repr__(self):
        return str(self.val);

"""
..######...#######..##....##.########.########.##.....##.########
.##....##.##.....##.###...##....##....##........##...##.....##...
.##.......##.....##.####..##....##....##.........##.##......##...
.##.......##.....##.##.##.##....##....######......###.......##...
.##.......##.....##.##..####....##....##.........##.##......##...
.##....##.##.....##.##...###....##....##........##...##.....##...
..######...#######..##....##....##....########.##.....##....##...
"""

class Context:
    def __init__(self, displayName, parent=None, parentEntryPos=None):
        self.displayName = displayName;
        self.parent = parent;
        self.parentEntryPos = parentEntryPos;
        self.symbolTable = None;

"""
..######..##....##.##.....##.########...#######..##..........########....###....########..##.......########
.##....##..##..##..###...###.##.....##.##.....##.##.............##......##.##...##.....##.##.......##......
.##.........####...####.####.##.....##.##.....##.##.............##.....##...##..##.....##.##.......##......
..######.....##....##.###.##.########..##.....##.##.............##....##.....##.########..##.......######..
.......##....##....##.....##.##.....##.##.....##.##.............##....#########.##.....##.##.......##......
.##....##....##....##.....##.##.....##.##.....##.##.............##....##.....##.##.....##.##.......##......
..######.....##....##.....##.########...#######..########.......##....##.....##.########..########.########
"""

class SymbolTable:
    def __init__(self):
        self.symbols = {};
        self.parent = None;
    
    def get(self, name):
        value = self.symbols.get(name, None);
        if value == None and self.parent:
            return self.parent.get(name);
        return value;
    
    def set(self, name, value):
        self.symbols[name] = value;
    
    def remove(self, name):
        del self.symbols[name];

"""
.####.##....##.########.########.########..########..########..########.########.########.########.
..##..###...##....##....##.......##.....##.##.....##.##.....##.##..........##....##.......##.....##
..##..####..##....##....##.......##.....##.##.....##.##.....##.##..........##....##.......##.....##
..##..##.##.##....##....######...########..########..########..######......##....######...########.
..##..##..####....##....##.......##...##...##........##...##...##..........##....##.......##...##..
..##..##...###....##....##.......##....##..##........##....##..##..........##....##.......##....##.
.####.##....##....##....########.##.....##.##........##.....##.########....##....########.##.....##

The interpreter visits the nodes in the abstract syntax tree and performs the
corresponding operations. It has methods for visiting different types of
nodes.
"""

class Interpreter:
    def visit(self, node, context):
        methodName = f"visit{type(node).__name__}";
        method = getattr(self, methodName, self.noVisitMethod);
        return method(node, context);
    def noVisitMethod(self, node, context):
        raise Exception(f"No visit{type(node).__name__} method defined");
    def visitNumberNode(self, node, context):
        return RTResult().success(Number(node.tkn.val).setContext(context).setPos(node.posStart, node.posEnd));

    def visitVarAccessNode(self, node, context):
        res = RTResult();
        varName = node.varNameTkn.value;
        value = context.symbolTable.get(varName);

        if not value:
            return res.failure(RTError(
                node.posStart,
                node.posEnd,
                f"'{varName}' is not defined",
                context
            ));

        return res.success(value);

    def visitVarAssignNode(self, node, context):
        res = RTResult();
        varName = node.varNameTkn.value;
        value = res.register(self.visit(node.valueNode, context));

        if res.error: return res;

        context.symbolTable.set(varName, value);
        return res.success(value);

    def visitBinOpNode(self, node, context):
        res = RTResult();
        left = res.register(self.visit(node.leftNode, context));
        if res.error: return res;
        right = res.register(self.visit(node.rightNode, context));
        if res.error: return res;
        if node.opTkn.style == ADD:
            result, error = left.add(right);
        elif node.opTkn.style == SUB:
            result, error = left.sub(right);
        elif node.opTkn.style == MUL:
            result, error = left.mul(right);
        elif node.opTkn.style == DIV:
            result, error = left.div(right);
        elif node.opTkn.style == POW:
            result, error = left.pow(right);
        if error:
            return res.failure(error);
        else:
            return res.success(result.setPos(node.posStart, node.posEnd));
    def visitUnaryOpNode(self, node, context):
        res = RTResult();
        number = res.register(self.visit(node.node, context));
        if res.error: return res;
        error = None;
        if node.opTkn.style == SUB:
            number, error = number.mul(Number(-1));
        if error:
            return res.failure(error);
        else:
            return res.success(number.setPos(node.posStart, node.posEnd));

"""
.########..##.....##.##....##
.##.....##.##.....##.###...##
.##.....##.##.....##.####..##
.########..##.....##.##.##.##
.##...##...##.....##.##..####
.##....##..##.....##.##...###
.##.....##..#######..##....##
"""

globalSymbolTable = SymbolTable();
globalSymbolTable.set("false", False);
globalSymbolTable.set("true", True);

def run(fn, text):

    # generate tokens
    lexer = Lexer(fn, text);
    tkns, error = lexer.makeTokens();
    if error: return None, error;

    # generate AST
    parser = Parser(tkns);
    ast = parser.parse();
    if ast.error: return None, ast.error;

    # run
    interpreter = Interpreter();
    context = Context("<program>");
    context.symbolTable = globalSymbolTable;
    result = interpreter.visit(ast.node, context);

    # return
    return result.val, result.error;