from web3 import Web3
import web3
import eth_abi
from typing import Sequence
import solcx
import json
import os
from web3.middleware import geth_poa_middleware

class Web3Engine:
    def __init__(self):
        pass

    def send_transaction_with_signature(self, node_url:str, chain_id:int, address:str, contract_address:str, private_key:str, func_sig:str, args:Sequence, timeout:int=300, gas:int=2000000, gas_price:int=2000000000):
        node = Web3(Web3.HTTPProvider(f"{node_url}"))
        node.middleware_onion.inject(geth_poa_middleware, layer=0)
        private_key = f"0x{private_key}"
        nonce = node.eth.get_transaction_count(address)
        transaction = ({
            "from": address,
            "to": contract_address,
            "data": self.encode_with_signature(func_sig, args),
            "chainId": chain_id,
            "nonce": nonce,
            "gas": gas,
            "gasPrice": gas_price,
        })
        signed_transaction = node.eth.account.sign_transaction(transaction, private_key=private_key)
        transaction_hash = node.eth.send_raw_transaction(signed_transaction.rawTransaction)
        transaction_receipt = node.eth.wait_for_transaction_receipt(transaction_hash, timeout=timeout)
        return (transaction_receipt)

    def compile_and_deploy_contract(self, node_url:str, chain_id:int, address:str, private_key:str, compiler_version:str, contract_path:str, contract_name:str, constructor_args:list = []):
        self.compile_contract(compiler_version, contract_path, contract_name)
        abi_path = f"web3_engine/compiled/abi/{contract_name}.json"
        bytecode_path = f"web3_engine/compiled/bytecode/{contract_name}.json"
        return self.deploy_contract(node_url, chain_id, address, private_key, abi_path, bytecode_path, constructor_args)

    def deployContract(self, node_url:str):
        pass

    def deploy_contract(self, node_url:str, chain_id:int, address:str, private_key:str, abi_path:str, bytecode_path:str, constructor_args:list = [], timeout:int=300):
        node = Web3(Web3.HTTPProvider(f"{node_url}"))
        node.middleware_onion.inject(geth_poa_middleware, layer=0)
        private_key = f"0x{private_key}"
        with open(abi_path, "r") as file:
            abi = json.load(file)
        with open(bytecode_path, "r") as file:
            bytecode = json.load(file)
        contract = node.eth.contract(abi=abi, bytecode=bytecode)
        nonce = node.eth.get_transaction_count(address)
        transaction = contract.constructor(*constructor_args).build_transaction({
            "chainId": chain_id,
            "from": address,
            "nonce": nonce
        })
        signed_transaction = node.eth.account.sign_transaction(transaction, private_key=private_key)
        transaction_hash = node.eth.send_raw_transaction(signed_transaction.rawTransaction)
        transaction_receipt = node.eth.wait_for_transaction_receipt(transaction_hash, timeout=timeout)
        return (transaction_receipt.contractAddress, abi, bytecode)

    def compile_contract(self, compiler_version:str, contract_path:str, contract_name:str):
        solcx.install_solc(f"{compiler_version}", True)
        abi = self.compile_contract_abi(compiler_version, contract_path, contract_name)
        metadata = self.compile_contract_metadata(compiler_version, contract_path, contract_name)
        bytecode = self.compile_contract_bytecode(compiler_version, contract_path, contract_name)
        source_map = self.compile_contract_source_map(compiler_version, contract_path, contract_name)
        data = {
            "abi": abi,
            "metadata": metadata,
            "bytecode": bytecode,
            "sourceMap": source_map
        }
        self._save_to_json(f"web3_engine/compiled/raw/{contract_name}.json", data)
        return data

    def compile_contract_abi(self, compiler_version:str, contract_path:str, contract_name:str):
        solcx.install_solc(f"{compiler_version}", True)
        with open(contract_path, "r") as file:
            data = solcx.compile_standard(
                {
                    "language": "Solidity",
                    "sources": {
                        f"{contract_name}": {
                            "content": file.read()
                        }
                    },
                    "settings": {
                        "outputSelection": {
                            "*": {
                                "*": ["abi"]
                            }
                        }
                    }
                },
                solc_version=f"{compiler_version}"
            )
        self._save_to_json(f"web3_engine/compiled/abi/{contract_name}.json", data["contracts"][f"{contract_name}"][f"{contract_name}"]["abi"])
        return data
    
    def compile_contract_metadata(self, compiler_version:str, contract_path:str, contract_name:str):
        solcx.install_solc(f"{compiler_version}", True)
        with open(contract_path, "r") as file:
            data = solcx.compile_standard(
                {
                    "language": "Solidity",
                    "sources": {
                        f"{contract_name}": {
                            "content": file.read()
                        }
                    },
                    "settings": {
                        "outputSelection": {
                            "*": {
                                "*": ["metadata"]
                            }
                        }
                    }
                },
                solc_version=f"{compiler_version}"
            )
        self._save_to_json(f"web3_engine/compiled/metadata/{contract_name}.json", data)
        return data

    def compile_contract_bytecode(self, compiler_version:str, contract_path:str, contract_name:str):
        solcx.install_solc(f"{compiler_version}", True)
        with open(contract_path, "r") as file:
            data = solcx.compile_standard(
                {
                    "language": "Solidity",
                    "sources": {
                        f"{contract_name}": {
                            "content": file.read()
                        }
                    },
                    "settings": {
                        "outputSelection": {
                            "*": {
                                "*": ["evm.bytecode"]
                            }
                        }
                    }
                },
                solc_version=f"{compiler_version}"
            )
        self._save_to_json(f"web3_engine/compiled/bytecode/{contract_name}.json", data["contracts"][f"{contract_name}"][f"{contract_name}"]["evm"]["bytecode"]["object"])
        self._save_to_json(f"web3_engine/compiled/opcodes/{contract_name}.json", data["contracts"][f"{contract_name}"][f"{contract_name}"]["evm"]["bytecode"]["opcodes"])
        return (data["contracts"][f"{contract_name}"][f"{contract_name}"]["evm"]["bytecode"]["object"], data["contracts"][f"{contract_name}"][f"{contract_name}"]["evm"]["bytecode"]["opcodes"])
    
    def compile_contract_source_map(self, compiler_version:str, contract_path:str, contract_name:str):
        solcx.install_solc(f"{compiler_version}", True)
        with open(contract_path, "r") as file:
            data = solcx.compile_standard(
                {
                    "language": "Solidity",
                    "sources": {
                        f"{contract_name}": {
                            "content": file.read()
                        }
                    },
                    "settings": {
                        "outputSelection": {
                            "*": {
                                "*": ["evm.sourceMap"]
                            }
                        }
                    }
                },
                solc_version=f"{compiler_version}"
            )
        self._save_to_json(f"web3_engine/compiled/source_map/{contract_name}.json", data)
        return data

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

    def _save_to_json(self, path:str, data:dict):
        if os.path.exists(path):
            os.remove(path)
        with open(path, "w") as json_file:
            json.dump(data, json_file, indent=4)

    def _generate_json(self, keys:list, values:list):
        data:dict = {}
        for key, value in zip(keys, values):
            data[key] = value
        return data
    
    def _return_keys(self, data:dict):
        keys:list = []
        values:list = []
        for key, value in data.items():
            keys.append(key)
            values.append(value)
        return (keys, values)

engine = Web3Engine()
# this will be required to passing requests to console
engine.encode_with_signature("transfer(uint)", [7000000000000000000])