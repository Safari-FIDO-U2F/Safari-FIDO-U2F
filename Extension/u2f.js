//  ----------------------------------------------------------------
//  Copyright (c) 2016-present, Yikai Zhao, Sam Deane, et al.
//
//  This source code is licensed under the MIT license found in the
//  LICENSE file in the root directory of this source tree.
//  ----------------------------------------------------------------

(function() {

var u2f = window.u2f || {};

u2f._pending = null;


u2f.extensionVersion = "$U2F_VERSION";
u2f.extensionBuild = "$U2F_BUILD";

/**
  * Message types for messsages to/from the extension
  * @const
  * @enum {string}
  */
u2f.MessageTypes = {
    'U2F_REGISTER_REQUEST' : 'u2f_register_request',
    'U2F_REGISTER_RESPONSE' : 'u2f_register_response',
    'U2F_SIGN_REQUEST' : 'u2f_sign_request',
    'U2F_SIGN_RESPONSE' : 'u2f_sign_response',
    'U2F_GET_API_VERSION_REQUEST' : 'u2f_get_api_version_request',
    'U2F_GET_API_VERSION_RESPONSE' : 'u2f_get_api_version_response'
};


/**
 * Response status codes
 * @const
 * @enum {number}
 */
u2f.ErrorCodes = {
    'OK' : 0,
    'OTHER_ERROR' : 1,
    'BAD_REQUEST' : 2,
    'CONFIGURATION_UNSUPPORTED' : 3,
    'DEVICE_INELIGIBLE' : 4,
    'TIMEOUT' : 5
};


u2f.CallbackMissingException = function() {
    this.message = 'Response does not have a callback registered.';
    this.name = 'CallbackMissingException';
};

/**
 * A counter for requestIds.
 * @type {number}
 * @private
 */
u2f.reqCounter_ = 0;


/**
 * A map from requestIds to client callbacks
 * @type {Object.<number,(function((u2f.Error|u2f.RegisterResponse))
 *                       |function((u2f.Error|u2f.SignResponse)))>}
 * @private
 */
u2f.callbackMap_ = {};


/**
 * Default extension response timeout in seconds.
 * @const
 */
u2f.EXTENSION_TIMEOUT_SEC = 30;


/**
 * Handles response messages from the extension.
 * @param {MessageEvent.<u2f.Response>} message
 * @private
 */
u2f.responseHandler_ = function(message) {
    var response = message.data;
    var data = response['responseData']
    if (data) {
     var reqId = response['requestId'];
     if (!reqId || !u2f.callbackMap_[reqId]) {
        throw new u2f.CallbackMissingException();
     }

     var cb = u2f.callbackMap_[reqId];
     delete u2f.callbackMap_[reqId];
     u2f.log("got response " + JSON.stringify(data));
     cb(data);
    }
};


u2f.basicRequest_ = function(type, appId, registeredKeys, callback, opt_timeoutSeconds) {
    var timeoutSeconds = (typeof opt_timeoutSeconds !== 'undefined' ? opt_timeoutSeconds : u2f.EXTENSION_TIMEOUT_SEC);
    var reqId = ++u2f.reqCounter_;
    u2f.callbackMap_[reqId] = callback;
    return {
        type : type,
        appId : appId,
        registeredKeys : registeredKeys,
        timeoutSeconds : timeoutSeconds,
        requestId : reqId
    };
};

u2f.registerRequest_ = function(appId, registerRequests, registeredKeys, callback, opt_timeoutSeconds) {
    if (typeof(appId) != "string") {
        // convert from 1.0 parameters
        opt_timeoutSeconds = callback
        callback = registeredKeys
        registeredKeys = registerRequests
        registerRequests = appId
        appId = registerRequests[0].appId
    }

    var request = u2f.basicRequest_(u2f.MessageTypes.U2F_REGISTER_REQUEST, appId, registeredKeys, callback, opt_timeoutSeconds);
    request.registerRequests = registerRequests;
    return request;
};

u2f.signRequest_ = function(appId, challenge, registeredKeys, callback, opt_timeoutSeconds) {
    if (typeof(appId) != "string") {
        // convert from 1.0 parameters
        opt_timeoutSeconds = callback
        callback = challenge
        registeredKeys = appId
        challenge = registeredKeys[0].challenge
        appId = registeredKeys[0].appId
    }

    var request = u2f.basicRequest_(u2f.MessageTypes.U2F_SIGN_REQUEST, appId, registeredKeys, callback, opt_timeoutSeconds);
    request.challenge = challenge;
    return request;
};

/**
 * Creates or retrieves the MessagePort singleton to use.
 * @param {function((MessagePort|u2f.WrappedChromeRuntimePort_))} callback
 * @private
 *
 * For this implementation we always use window as the port.
 * There's not really any need to dispatch through a function like this,
 * it's done mostly for uniformity with the Yubico/Google implementation,
 * just in case anything is relying on getPortSingleton_ existing.
 */
 u2f.getPortSingleton_ = function(callback) {
    callback(window);
 }

 
/**
 * Log a tagged message to the console.
 *
 */
 
 u2f.log = function(message) {
    console.log("FIDO-U2F: " + message)
 };

 
 /**
  * Log a tagged error to the console.
  *
  */

 u2f.error = function(message) {
    console.error("FIDO-U2F: " + message)
 };
 

/**
 * Dispatches register requests to available U2F tokens. An array of sign
 * requests identifies already registered tokens.
 * @param {string=} appId
 * @param {Array<u2f.RegisterRequest>} registerRequests
 * @param {Array<u2f.RegisteredKey>} registeredKeys
 * @param {function((u2f.Error|u2f.RegisterResponse))} callback
 * @param {number=} opt_timeoutSeconds
 */

u2f.register = function(appId, registerRequests, registeredKeys, callback, opt_timeoutSeconds) {
    u2f.getPortSingleton_(function(port) {
        var request = u2f.registerRequest_(appId, registerRequests, registeredKeys, callback, opt_timeoutSeconds);
        u2f.log("registering " + JSON.stringify(request));
        port.postMessage(request, window.location.origin);
    });
};



/**
 * Dispatches an array of sign requests to available U2F tokens.
 * @param {string=} appId
 * @param {string=} challenge
 * @param {Array<u2f.RegisteredKey>} registeredKeys
 * @param {function((u2f.Error|u2f.SignResponse))} callback
 * @param {number=} opt_timeoutSeconds
 */

u2f.sign = function(appId, challenge, registeredKeys, callback, opt_timeoutSeconds) {
    u2f.getPortSingleton_(function(port) {
        var request = u2f.signRequest_(appId, challenge, registeredKeys, callback, opt_timeoutSeconds)
        u2f.log("signing " + JSON.stringify(request));
        window.postMessage(request, window.location.origin);
    });
};



/**
 * Not part of the official API, but provided as a way of detecting that this extension has injected the implementation.
 */

u2f.isSafari = function() {
    return true;
};


/**
 Return the API version.
 */

u2f.getApiVersion = function(callback, opt_timeoutSeconds) {
    callback({ 'js_api_version' : 1.1 });
};


/**
  Listener to process messages to/from the extension.
*/

window.addEventListener("message", u2f.responseHandler_, true)



/**
 Inject the u2f object as window.u2f.
 If there was a previous window.u2f, we will modify it rather than completely replacing it,
 so any custom data attached to it should be preserved unless it happens to clash with our implementation.
 */

Object.defineProperty(window, "u2f", {
    get : function() {
        return u2f;
    },
    set : undefined, // prevent furthur change
});

u2f.log("v" + u2f.extensionVersion + " (" + u2f.extensionBuild + ") loaded");
})();
