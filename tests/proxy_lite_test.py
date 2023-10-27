from scripts.helpful_scripts import get_account
from brownie import ProxyLite

def test_deploy():
    account = get_account()
    proxy_lite = ProxyLite.deploy({"from":account})