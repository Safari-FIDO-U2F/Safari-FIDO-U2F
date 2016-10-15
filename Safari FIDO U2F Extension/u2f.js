(function() {
    var u2f = {};

    u2f._pending = null;

    /**
     * Dispatches register requests to available U2F tokens. An array of sign
     * requests identifies already registered tokens.
     * If the JS API version supported by the extension is unknown, it first sends a
     * message to the extension to find out the supported API version and then it sends
     * the register request.
     * @param {string=} appId
     * @param {Array<u2f.RegisterRequest>} registerRequests
     * @param {Array<u2f.RegisteredKey>} registeredKeys
     * @param {function((u2f.Error|u2f.RegisterResponse))} callback
     * @param {number=} opt_timeoutSeconds
     */
    u2f.register = function(appId, registerRequests, registeredKeys, callback, opt_timeoutSeconds) {
        opt_timeoutSeconds = opt_timeoutSeconds || 0;

        console.log("Bridge: register: ", appId);
        console.log("Bridge: register: ", registerRequests);
        console.log("Bridge: register: ", registeredKeys);
        console.log("Bridge: register: ", opt_timeoutSeconds);

        if (u2f._pending) {
            console.log("Pending... exit");
            return;
        }

        var challenge = null;
        for (var i = 0 ; i < registerRequests.length ; i += 1) {
            if (registerRequests[i].version == "U2F_V2") {
                challenge = registerRequests[i].challenge;
                break;
            }
        }
        if (!challenge) {
            callback({errorCode: 1});
            return;
        }

        u2f._pending = {
            type: "register",
            callback: callback
        };

        window.postMessage(JSON.stringify({
            _meta: "u2f_window2safari",
            name: "register",
            message: {
                appId: appId,
                timeoutSeconds: opt_timeoutSeconds,
                challenge: challenge,
            }
        }), window.location.origin);
    };

    /**
     * Dispatches an array of sign requests to available U2F tokens.
     * If the JS API version supported by the extension is unknown, it first sends a
     * message to the extension to find out the supported API version and then it sends
     * the sign request.
     * @param {string=} appId
     * @param {string=} challenge
     * @param {Array<u2f.RegisteredKey>} registeredKeys
     * @param {function((u2f.Error|u2f.SignResponse))} callback
     * @param {number=} opt_timeoutSeconds
     */
    u2f.sign = function(appId, challenge, registeredKeys, callback, opt_timeoutSeconds) {
        opt_timeoutSeconds = opt_timeoutSeconds || 0;

        console.log("Bridge: sign: ", appId);
        console.log("Bridge: sign: ", challenge);
        console.log("Bridge: sign: ", registeredKeys);
        console.log("Bridge: sign: ", opt_timeoutSeconds);

        if (u2f._pending) {
            console.log("Pending... exit");
            return;
        }

        var keyHandle = null;
        for (var i = 0 ; i < registeredKeys.length ; i += 1) {
            if (registeredKeys[i].version == "U2F_V2") {
                keyHandle = registeredKeys[i].keyHandle;
                break;
            }
        }
        if (!keyHandle) {
            callback({errorCode: 1});
            return;
        }

        u2f._pending = {
            type: "sign",
            keyHandle: keyHandle,
            callback: callback,
        };

        window.postMessage(JSON.stringify({
            _meta: "u2f_window2safari",
            name: "sign",
            message: {
                appId: appId,
                timeoutSeconds: opt_timeoutSeconds,
                challenge: challenge,
                keyHandle: keyHandle,
            }
        }), window.location.origin);
    };

    window.addEventListener("message", function(e) {
        if (e.origin != window.location.origin)
            return;
        var data = JSON.parse(e.data);
        if (data._meta != "u2f_safari2window" || data.name != "response")
            return;
        data = data.message;

        console.log("Bridge: message: ", data._id);
        console.log("Bridge: message: ", data.error);
        console.log("Bridge: message: ", data.result);

        var pending = u2f._pending;
        if (!pending)
            return;
        u2f._pending = null;

        if (data.error && data.error != 0) {
            pending.callback({
                errorCode: 1,
                errorMessage: data.error,
            });
            return;
        }

        var result = JSON.parse(data.result);
        if (pending.type == "register") {
            pending.callback({
                version: "U2F_V2",
                registrationData: result.registrationData,
                clientData: result.clientData,
            });
        } else if (pending.type == "sign") {
            pending.callback({
                version: "U2F_V2",
                keyHandle: pending.keyHandle,
                signatureData: result.signatureData,
                clientData: result.clientData,
            });
        }
    });

    window.u2f = u2f;
    console.log("FIDO U2F Safari Extension loaded");
})();
