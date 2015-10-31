from autobahn.asyncio.websocket import WebSocketServerProtocol, \
  WebSocketServerFactory
from time import sleep
import json

class MyServerProtocol(WebSocketServerProtocol):

  def atRow(self, arg):
    self.__atRow = arg
    return self

  def onVar(self, arg):
    self.__onVar = arg
    return self

  def setReadout(self, arg):
    self.__setReadout = arg
    return self

  def asValue(self, arg):
    msg = dict()
    msg['func'] = 'setDataAtRowProp'
    msg['args'] = [
      str(self.__atRow),
      str(self.__onVar) + '.readouts.' + str(self.__setReadout),
      str(arg),
      ''
    ]
    json_msg = json.dumps(msg, ensure_ascii=False)
    print(json_msg)
    return self.sendMessage(str.encode(json_msg), False)    
    #self.sendMessage(str.encode('{"func": "setDataAtRowProp", "args":[' + str(0) + ',"VI.readouts.1",' + str(arg) + ',""]}'), False)

  def onConnect(self, request):
    print("Client connecting: {0}".format(request.peer))

  def onOpen(self):
    print("WebSocket connection open.")

  def onMessage(self, payload, isBinary):
    if isBinary:
      print("Binary message received: {0} bytes.".format(len(payload)))
      # Must be text
      return
    # Decone incoming json
    self.decoded = json.loads(payload.decode('utf8'))
    # Simple alias
    model = self.decoded['data']['model']
    rows = self.decoded['input']
    atRow = self.atRow
    startRow = self.decoded["selection"][0]
    startCol = self.decoded["selection"][1]
    endRow = self.decoded["selection"][2]
    endCol = self.decoded["selection"][3]
    sleep(0.1)
    return exec(self.decoded["data"]["model"]["additional_options"]["automation"])
    #self.atRow(1).onVar('VI').setReadout(2).asValue(3)
    #self.sendMessage(b'{"func": "setDataAtRowProp", "args":[0,"VI.readouts.1",12,""]}', False)

  def onClose(self, wasClean, code, reason):
    print("WebSocket connection closed: {0}".format(reason))


if __name__ == '__main__':

  try:
    import asyncio
  except ImportError:
    # Trollius >= 0.3 was renamed
    import trollius as asyncio

  factory = WebSocketServerFactory("ws://127.0.0.1:9000", debug=False)
  factory.protocol = MyServerProtocol

  loop = asyncio.get_event_loop()
  coro = loop.create_server(factory, '0.0.0.0', 9000)
  server = loop.run_until_complete(coro)

  try:
    loop.run_forever()
  except KeyboardInterrupt:
    pass
  finally:
    server.close()
    loop.close()