from scripts.deploy_token import deploy
from scripts.helpful_scripts import get_account
from brownie import Token, exceptions, Vault
import pytest

def test_deploy_10times():
    for i in range(10):
        token_contract = deploy()

def test_deploy():
    account = get_account(0)
    token_contract = Token.deploy(account, {"from":account})

def test_transfer():
    sender = get_account(0)
    reciever = get_account(1)
    token_contract = Token[-1]
    amount = 50000000 * 10 ** 18
    assert token_contract.balanceOf(sender) > 0
    starting_balance = token_contract.balanceOf(sender)
    assert token_contract.balanceOf(reciever) == 0
    token_contract.transfer(reciever, amount, {"from" : sender})
    assert token_contract.balanceOf(reciever) == amount
    assert token_contract.balanceOf(sender) == starting_balance - amount

def test_transfer_from_without_approve():
    sender = get_account(0)
    reciever = get_account(2)
    token_contract = Token[-1]
    amount = 50000000 * 10 ** 18
    starting_balance = token_contract.balanceOf(sender)
    assert token_contract.balanceOf(reciever) == 0
    with pytest.raises(exceptions.VirtualMachineError):
        token_contract.transferFrom(sender, reciever, amount, {"from" : sender})
    assert token_contract.balanceOf(reciever) == 0
    assert token_contract.balanceOf(sender) == starting_balance

def test_stake():
    sender = get_account(0)
    thief = get_account(1)
    token_contract = Token[-1]
    amount = 50000000 * 10 ** 18
    assert token_contract.balanceOf(sender) > 0
    token_contract.stake(amount, {"from" : sender})
    assert token_contract.stakeOf(sender) == amount
    withdrawed_balance = 100000000 * 10 ** 18
    with pytest.raises(exceptions.VirtualMachineError):
        token_contract.unstake(1, {"from" : thief})
    with pytest.raises(exceptions.VirtualMachineError):
        token_contract.unstake(withdrawed_balance, {"from" : sender})
    withdrawed_balance = 10000000 * 10 ** 18
    token_contract.unstake(withdrawed_balance, {"from" : sender})
    assert token_contract.stakeOf(sender) == amount - withdrawed_balance

def test_update_vault():
    sender = get_account(0)
    vault = Vault.deploy({"from" : sender})
    token_contract = Token[-1]
    assert token_contract.stakeOf(sender) > 0
    token_contract.update(vault, {"from" : sender})
    #assert token_contract.stakeOf(sender) == 0
    with pytest.raises(exceptions.VirtualMachineError):
        token_contract.unstake(1, {"from" : sender})

def test_thief_approve():
    sender = get_account(0)
    reciever = get_account(1)
    token_contract = Token[-1]
    assert token_contract.allowance(sender, reciever) == 0
    amount = 10000000 * 10 ** 18
    transaction = token_contract.approve(reciever, amount, {"from" : reciever})
    transaction.wait(1)
    assert token_contract.allowance(sender, reciever) == 0

def test_burn():
    burner = get_account(1)
    token_contract = Token[-1]
    new_burn = 1
    starting_balance = token_contract.balanceOf(burner)
    starting_supply = token_contract.totalSupply()
    assert token_contract.balanceOf(burner) == starting_balance
    with pytest.raises(exceptions.VirtualMachineError):
        token_contract.burn(new_burn, {"from" : burner})
    assert token_contract.totalSupply() == starting_supply
    assert token_contract.balanceOf(burner) == starting_balance

def test_burn_admin():
    burner = get_account(0)
    token_contract = Token[-1]
    new_burn = 1
    starting_balance = token_contract.balanceOf(burner)
    starting_supply = token_contract.totalSupply()
    assert token_contract.balanceOf(burner) == starting_balance
    token_contract.burn(new_burn, {"from" : burner})
    assert token_contract.totalSupply() == starting_supply - new_burn
    assert token_contract.balanceOf(burner) == starting_balance - new_burn


def test_mint():
    admin = get_account(0)
    thief = get_account(1)
    reciever = get_account(2)
    token_contract = Token[-1]
    starting_supply = token_contract.totalSupply()
    new_mint = 1
    starting_balance = token_contract.balanceOf(admin)
    with pytest.raises(exceptions.VirtualMachineError):
        new_mint = token_contract.mint(admin, new_mint, {"from" : admin})
    assert token_contract.totalSupply() == starting_supply
    assert token_contract.balanceOf(admin) == starting_balance

    

