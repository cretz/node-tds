var ffi;

ffi = require('node-ffi');

exports.Sso = (function() {

  Sso._SecurityFunctionTable = ffi.Struct([['ulong', 'dwVersion'], ['pointer', 'EnumerateSecurityPackages'], ['pointer', 'Reserved1'], ['pointer', 'QueryCredentialsAttributes'], ['pointer', 'AcquireCredentialsHandle'], ['pointer', 'FreeCredentialsHandle'], ['pointer', 'Reserved2'], ['pointer', 'InitializeSecurityContext'], ['pointer', 'AcceptSecurityContext'], ['pointer', 'CompleteAuthToken'], ['pointer', 'DeleteSecurityContext'], ['pointer', 'ApplyControlToken'], ['pointer', 'QueryContextAttributes'], ['pointer', 'ImpersonateSecurityContext'], ['pointer', 'RevertSecurityContext'], ['pointer', 'MakeSignature'], ['pointer', 'VerifySignature'], ['pointer', 'FreeContextBuffer'], ['pointer', 'QuerySecurityPackageInfo'], ['pointer', 'Reserved3'], ['pointer', 'Reserved4'], ['pointer', 'ExportSecurityContext'], ['pointer', 'ImportSecurityContext'], ['pointer', 'AddCredentials'], ['pointer', 'Reserved8'], ['pointer', 'QuerySecurityContextToken'], ['pointer', 'EncryptMessage'], ['pointer', 'DecryptMessage'], ['pointer', 'SetContextAttributes']]);

  Sso._SecPkgInfo = ffi.Struct([['ulong', 'fCapabilities'], ['ushort', 'wVersion'], ['ushort', 'wRPCID'], ['ulong', 'cbMaxToken'], ['string', 'Name'], ['string', 'Comment']]);

  function Sso() {
    var packageInfo, packageInfoFunc;
    try {
      this._secure32 = new ffi.Library('secur32', {
        InitSecurityInterfaceA: ['pointer', []]
      });
      this._interface = new Sso._SecurityFunctionTable(this._secure32.InitSecurityInterfaceA());
      console.log('Got interface', this._interface.dwVersion, this._interface.QuerySecurityPackageInfo);
      packageInfo = new Sso._SecPkgInfo();
      console.log('Created package info', packageInfo, packageInfo.ref());
      packageInfoFunc = new ffi.ForeignFunction(this._interface.QuerySecurityPackageInfo, 'long', ['string', 'pointer'], false);
      console.log('Created package info func', packageInfoFunc);
      packageInfoFunc('NTLM', packageInfo.ref());
      console.log('Look what I got!', packageInfo);
      console.log('Done');
    } catch (err) {
      console.log('AHHHH!', err);
    }
  }

  return Sso;

})();
