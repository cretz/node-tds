assert = require 'assert'

{BufferBuilder} = require '../lib/buffer-builder'
{BufferStream} = require '../lib/buffer-stream'
{Packet} = require '../lib/packet'
{Login7Packet} = require '../lib/login7.packet'
{PreLoginPacket} = require '../lib/prelogin.packet'

assertPacket = (packetClass, expected, expectedStatus = 1) ->
  expected ?= new packetClass()
  bldr = expected.toBuffer new BufferBuilder()
  buff = bldr.toBuffer()
  stream = new BufferStream()
  stream.append buff
  stream.beginTransaction()
  header = Packet.retrieveHeader stream
  assert.equal header.type, expected.type, 
    'header.type expected ' + expected.type + ' got ' + header.type
  assert.equal header.status, expectedStatus, 
    'header.status expected ' + expectedStatus + ' got ' + header.status
  assert.equal header.length, buff.length,
    'header.length expected ' + buff.length + ' got ' + header.length
  assert.equal header.processId, 0,
    'header.processId expected 0 got ' + header.processId
  assert.equal header.packetId, 1,
    'header.packetId expected 1 got ' + header.packetId
  assert.equal header.window, 0,
    'header.window expected 0 got ' + header.window
  actual = new packetClass()
  actual.fromBuffer stream
  for key, value of expected
    # arrays are different
    if value instanceof Array
      for i in [0..value.length - 1]
        assert.equal actual[key][i], value[i],
          'expected ' + key + '[' + i + ']: ' + value + ' got ' + actual[key][i]
    else    
      assert.equal actual[key], value, 
        'expected ' + key + ': ' + value + ' got ' + actual[key]

describe 'Login7Packet', ->
  it 'should marshal to and from buffer'

describe 'PreLoginPacket', ->
  it 'should marshal to and from buffer', ->
    packet = new PreLoginPacket()
    packet.instanceName = 'Test'
    assertPacket PreLoginPacket, packet
