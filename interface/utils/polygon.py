import web3
import queue
import asyncio

async def request(address: str, abi :str, sig: str):
  pass

async def foo():
  asyncio.create_task()
  return 'yolo'

print(asyncio.run(foo()))

class Polygon:
  def __init__(self):
    self._polygonUrlRPC = None
    self.interface = None
    self.queue = queue.Queue()
    self.stack = []

  async def request(self, address: str, abi: str, signature: str) -> int:
    await self.queue.put((address, abi, signature))
    # return an id on the queue where a response will be stored
    return 29

  async def process(self):
    response = ''
    self.stack.append(response)
  

  async def isConnected(self):
    try:
      if (self.interface.is_connected()):
        return True
      return False
    except:
      return 'ERROR'
  
