from web3 import Web3

polygon:str = "https://polygon-rpc.com"

interface_for_polygon:Web3 = Web3(Web3.HTTPProvider(polygon))

# check connection
if (interface_for_polygon.is_connected()):
    print (f"onchain_interface: succesfully connected to polygon mainnet at {polygon}")
else:
    print(f"onchain_interface: failed to connect to polygon mainnet")