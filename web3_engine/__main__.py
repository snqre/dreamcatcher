from web3 import Web3
import web3
import eth_abi
from typing import Sequence
import solcx

class Web3Engine:
    def __init__(self):
        pass

    def compile_contract(self, compiler_version:str, contract_path:str, contract_name:str):
        result = None
        solcx.install_solc(f"{compiler_version}", True)
        with open(contract_path, "r") as file:
            contract_file = file.read()
            result = solcx.compile_standard({
                    "language": "Solidity",
                    "sources": {
                        f"{contract_name}": {
                            "content": contract_file
                        }
                    },
                    "settings": {
                        "outputSelection": {
                            "*": {
                                "*": [
                                    "abi",
                                    "metadata",
                                    "evm.bytecode",
                                    "evm.sourceMap"
                                ]
                            }
                        }
                    }
                },
                solc_version = f"{compiler_version}"
            )
        return result

    def encode_with_signature(self, func_sig:str, args:Sequence):
        assert type(args) in (tuple, list)
        func_selector = Web3.keccak(text=func_sig)
        func_selector = func_selector.hex()
        func_selector = func_selector[:10]
        selector_text = func_sig[func_sig.find("(") + 1 : func_sig.rfind(")")]
        arg_types = selector_text.split(",")
        encoded_args = eth_abi.encode(arg_types, args)
        encoded_args = encoded_args.hex()
        result = f"{func_selector}{encoded_args}"
        return result
    
    def add_facet():
        pass

engine = Web3Engine()

result = engine.encode_with_signature("____setMultiSigDuration(uint256)", [69])
print(result)
result = engine.compile_contract("0.8.19", "contracts/polygon/diamonds/facets/ConsoleFacet/ConsoleFacet01.sol", "ConsoleFacet01")
print(result)