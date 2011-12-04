assert = require 'assert'

{BufferBuilder} = require '../lib/buffer-builder'
{BufferStream} = require '../lib/buffer-stream'
{Packet} = require '../lib/packet'
{PreLoginPacket} = require '../lib/prelogin.packet'

assertPacket = (packetClass, expected) ->
  expected ?= new packetClass()
  bldr = expected.toBuffer new BufferBuilder()
  buff = bldr.toBuffer()
  stream = new BufferStream()
  stream.append buff
  stream.beginTransaction()
  header = Packet.retrieveHeader stream
  assert.equal header.type, expected.type, 'Wrong type'
  actual = new packetClass()
  actual.fromBuffer stream
  console.log 'comparing %s with expected %s', actual, expected
  for key, value of expected
    assert.equal actual[key], value, 
      'Expected ' + key + ': ' + value + ', actual ' + actual[key]

describe 'PreLoginPacket', ->
  it 'should marshal to and from buffer', ->
    packet = new PreLoginPacket()
    packet.instanceName = 'Test'
    assertPacket PreLoginPacket, packet
