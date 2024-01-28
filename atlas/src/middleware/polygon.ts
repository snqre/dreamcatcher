import {Web3, eth, Contract} from "web3";

interface Polygon {
  nodeUrl: () => string,
  node: () => Web3,
  setNodeUrl: (url: string) => void
}

const polygon = (function() {
  let _nodeUrl: string;

  function nodeUrl(): string {
    return _nodeUrl;
  }

  function node(): Web3 {
    return new Web3(new Web3.providers.HttpProvider(nodeUrl()));
  }

  function setNodeUrl(url: string) {
    _nodeUrl = url;
  }

  return {
    nodeUrl,
    node,
    setNodeUrl
  }
})();

const de = function() {
  let _address: string;
  let _abi: any[];
  let _nodeUrl: string;

  function nodeUrl(): string {
    return _nodeUrl;
  }

  function address() {
    return _address;
  }

  function abi() {
    return _abi;
  }

  function controller() {
    const web3 = new Web3(nodeUrl());
    return new web3.eth.Contract(abi(), address());
  }

  function view(signature: string, ...args: any[]) {
    return controller().methods[signature](args).call();
  }

  function lowLevelCall(signature: string, data: string) {

  }

  return {
    address,
    abi,
    controller
  }
}


