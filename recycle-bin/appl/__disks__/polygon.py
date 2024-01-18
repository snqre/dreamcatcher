import requests
import json
import urllib.parse

# tool not designed for direct interaction use js on web app side
_rpcUrl = "https://polygon-rpc.com"

def rpcUrl():
    return _rpcUrl

def get(method, params):
    return requests.post(rpcUrl(), data=json.dumps({
        "jsonrpc": "2.0",
        "method": method,
        "params": params,
        "id": 1
    }), headers={"Content-Type": "application/json"}).json().get("result")

# query smart contract
def query(address, selector, args):
    return requests.post(rpcUrl(), json={
        "jsonrpc": "2.0",
        "method": "eth_call",
        "params": [{
            "to": address,
            "data": selector + args,
        }, "latest"],
        "id": 1
    }).json()

def balanceOf(address):
    return get("eth_getBalance", [address, "latest"])

def bytecodeOf(address):
    return requests.post(rpcUrl(), json={
        "jsonrpc": "2.0",
        "method": "eth_getCode",
        "params": [address, "latest"],
        "id": 1
    }).json()["result"]

def isEOA(address):
    return bytecodeOf(address) == "0x"

def computeHexToStandard(data):
    return int(data, 16)

def computeWeiToEther(wei):
    return wei / 1e18