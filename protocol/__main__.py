from web3 import Web3
from bs4 import BeautifulSoup
import json
import requests


endpoints = Endpoints()

class ContractPolygon:

    def __init__(self, address):
        self.address = address
        self.rpc_url = "https://polygon-rpc.com"
        self.api = f"https://api.polygonscan.com/api?module=contract&action=getabi&address={self.address}&apikey=TDXT53T8YWESDFQ2CEFBKITHAXUHTMQS7F"
        self.abi = None
        self.interface = None

    def __getattr__(self, function_name):

        try:

            if function_name in [item["name"] for item in self.abi if item["type"] == "function"]:

                def call_function(*args):

                    return getattr(self.interface.functions, function_name)(*args).call()

                return call_function

            else:

                raise AttributeError(f"{self.__class__.__name__} has no attribute '{function_name}'")
        
        except:

            if function_name in [item["name"] for item in self.abi if item["type"] == "function"]:

                def call_function(*args):

                    return getattr(self.interface.functions, function_name)(*args).call().send()

                return call_function

            else:

                raise AttributeError(f"{self.__class__.__name__} has no attribute '{function_name}'")
            
    def import_abi(self):
        response = requests.get(self.api)

        if response.status_code == 200:
            json_response = response.json()

            if json_response["status"] == "1":
                abi_content = json.loads(json_response["result"])
                self.abi = abi_content
                interface = Web3(Web3.HTTPProvider(self.rpc_url))
                assert(interface.is_connected())
                self.interface = interface.eth.contract(address=self.address, abi=self.abi)

contract = ContractPolygon("0xC5C23B6c3B8A15340d9BB99F07a1190f16Ebb125" )
contract.import_abi()
print(contract.symbol())
print(contract.abi)