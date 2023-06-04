from brownie import accounts, network

def get_account(i = 0):
    if (network.show_active() == "development"):
        return accounts[i]