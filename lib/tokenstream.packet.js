var ColMetaDataToken, DoneToken, EnvChangeToken, ErrorMessageToken, InfoMessageToken, LoginAckToken, Packet, ReturnStatusToken, RowToken,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

ColMetaDataToken = require('./colmetadata.token').ColMetaDataToken;

DoneToken = require('./done.token').DoneToken;

EnvChangeToken = require('./envchange.token').EnvChangeToken;

ErrorMessageToken = require('./error.message.token').ErrorMessageToken;

InfoMessageToken = require('./info.message.token').InfoMessageToken;

LoginAckToken = require('./loginack.token').LoginAckToken;

Packet = require('./packet').Packet;

ReturnStatusToken = require('./returnstatus.token').ReturnStatusToken;

RowToken = require('./row.token').RowToken;

/**
Packet for TokenStream (0x04)

@spec 2.2.4.2
*/

exports.TokenStreamPacket = (function(_super) {

  __extends(TokenStreamPacket, _super);

  TokenStreamPacket.type = 0x04;

  TokenStreamPacket.name = 'TokenStream';

  function TokenStreamPacket() {
    this.type = 0x04;
    this.name = 'TokenStream';
  }

  TokenStreamPacket.prototype._getTokenFromType = function(type) {
    switch (type) {
      case ColMetaDataToken.type:
        return new ColMetaDataToken;
      case DoneToken.type:
      case DoneToken.type2:
      case DoneToken.type3:
        return new DoneToken;
      case EnvChangeToken.type:
        return new EnvChangeToken;
      case ErrorMessageToken.type:
        return new ErrorMessageToken;
      case InfoMessageToken.type:
        return new InfoMessageToken;
      case LoginAckToken.type:
        return new LoginAckToken;
      case ReturnStatusToken.type:
        return new ReturnStatusToken;
      case RowToken.type:
        return new RowToken;
      default:
        throw new Error('Unrecognized type: ' + type);
    }
  };

  TokenStreamPacket.prototype.nextToken = function(stream, context) {
    var token, type;
    type = stream.readByte();
    if (context.logDebug) console.log('Retrieved token type: ', type);
    token = this._getTokenFromType(type);
    token.fromBuffer(stream, context);
    if (context.logDebug) console.log('Retrieved token: ', token);
    return token;
  };

  return TokenStreamPacket;

})(Packet);
