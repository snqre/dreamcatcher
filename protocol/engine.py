from web3 import Web3
import eth_abi
from typing import Sequence

class Web3Engine:
    def __init__(self):
        pass

    def deploy_contract(self, contract_path:str):
        pass

    def send(self, url:str, address:str, gas:int, gas_price:int, key:str, func_sig:str, args:Sequence):
        node = Web3(Web3.HTTPProvider(f"{url}"))
        account = node.eth.account.privateKeyToAccount(key)
        encoded_data = self.encode_with_signature(func_sig, args)
        transaction = {
            "to": address,
            "gas": gas,
            "gasPrice": node.to_wei(f"{gas_price}", "gwei"),
            "nonce": node.eth.get_transaction_count(account.address),
            "data": encoded_data,
        }
        signed_transaction = node.eth.account.sign_transaction(transaction, key)
        transaction_hash = node.eth.send_raw_transaction(signed_transaction.raw_transaction)
        return transaction_hash

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
    
    def setNode(self, node:str):
        self.node = node
    


engine = Web3Engine()
result = engine.encode_with_signature("____setMultiSigDuration(uint256)", [69])
print(result)
