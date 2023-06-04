from scripts.deploy_token import deploy
from scripts.helpful_scripts import get_account
from brownie import Token

def test_deploy_10times():
    for i in range(10):
        token_contract = deploy()

def test_deploy():
    account = get_account(0)
    token_contract = Token.deploy(account, {"from":account})

def test_approvals():
    sender = get_account(0)
    reciever = get_account(1)
    token_contract = Token[-1]
    assert token_contract.allowance(sender, reciever) == 0
    #token_contract = deploy()
    amount = 50000000 * 10 ** 18
    transaction = token_contract.approve(reciever, amount, {"from" : sender})
    transaction.wait(1)
    assert token_contract.allowance(sender, reciever) == amount

def test_transfer():
    sender = get_account(0)
    reciever = get_account(1)
    token_contract = Token[-1]
    starting_balance = token_contract.balanceOf(sender)
    #token_contract = deploy()
    amount = 50000000 * 10 ** 18
    transaction = token_contract.approve(reciever, amount, {"from" : sender})
    transaction.wait(1)
    assert token_contract.balanceOf(reciever) == 0
    token_contract.transferFrom(sender, reciever, amount, {"from" : sender})
    assert token_contract.balanceOf(reciever) == amount
    assert token_contract.balanceOf(sender) == starting_balance - amount