from dataclasses import dataclass

@dataclass
class Opcode:
    identifier: str
    instance : str
    line: int
    position: int