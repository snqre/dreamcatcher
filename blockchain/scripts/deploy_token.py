from brownie import Token
from scripts.helpful_scripts import get_account

def deploy(account_index = 0):
    account = get_account(account_index)
    token_contract = Token.deploy(account, {"from":account})
    return token_contract

def transfer(token_contract, amount, sender, reciever):
    print(token_contract.allowance(sender, reciever, {"from" : sender}))
    #amount = 1
    amount = 100000000 * 10 ** 18
    token_contract.approve(reciever, amount, {"from":sender})
    print(token_contract.allowance(sender, reciever, {"from" : sender}))
    token_contract.transferFrom(sender, reciever, amount, {"from" : sender})

def main():
    # for i in range(10):
    #     print()
    #     print()
    #     c = deploy()
    #     print(c.address)
    #     print(Token[-1])
    transfer(deploy(), 1, get_account(0), get_account(1))