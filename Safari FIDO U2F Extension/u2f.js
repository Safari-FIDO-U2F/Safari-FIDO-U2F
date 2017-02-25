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
     *
     * Also support legacy function signature
     */
    u2f.register = function() {
        var arguments_offset = 0;
        var appId = null;
        if (typeof(arguments[0]) == "string") {
            appId = arguments[0];
            arguments_offset += 1;
        }

        var registerRequests = arguments[arguments_offset];
        var callback = arguments[arguments_offset + 2];

        console.log("FIDO U2F Safari Extension: registering ", appId);

        if (u2f._pending) {
            console.log("FIDO U2F Safari Extension: Pending action exists, exit");
            return;
        }

        var challenge = null;
        for (var i = 0 ; i < registerRequests.length ; i += 1) {
            if (registerRequests[i].version == "U2F_V2") {
                challenge = registerRequests[i].challenge;
                if (!appId)
                    appId = registerRequests[i].appId;
                break;
            }
        }
        if (!challenge || !appId) {
            callback({errorCode: 1});
            return;
        }

        u2f._pending = {
            type: "register",
            callback: callback
        };

        window.postMessage(JSON.stringify({
            _meta: "u2f_window2safari",
            name: "U2FRegister",
            message: {
                appId: appId,
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
     *
     * Also support legacy function signature
     */
    u2f.sign = function() {
        var arguments_offset = 0;
        var appId = null;
        var challenge = null;
        if (typeof(arguments[0]) == "string") {
            appId = arguments[0];
            challenge = arguments[1];
            arguments_offset += 2;
        }

        var registeredKeys = arguments[arguments_offset];
        var callback = arguments[arguments_offset + 1];

        console.log("FIDO U2F Safari Extension: signing ", appId);

        if (u2f._pending) {
            console.log("FIDO U2F Safari Extension: Pending action exists, exit");
            return;
        }

        var keyHandle = null;
        for (var i = 0 ; i < registeredKeys.length ; i += 1) {
            if (registeredKeys[i].version == "U2F_V2") {
                keyHandle = registeredKeys[i].keyHandle;
                if (!appId || !challenge) {
                    appId = registeredKeys[i].appId;
                    challenge = registeredKeys[i].challenge;
                }
                break;
            }
        }
        if (!keyHandle || !appId || !challenge) {
            callback({errorCode: 1});
            return;
        }

        u2f._pending = {
            type: "sign",
            callback: callback,
        };

        window.postMessage(JSON.stringify({
            _meta: "u2f_window2safari",
            name: "U2FSign",
            message: {
                appId: appId,
                challenge: challenge,
                keyHandle: keyHandle,
            }
        }), window.location.origin);
    };

    window.addEventListener("message", function(e) {
        if (e.origin != window.location.origin)
            return;

        if (!e.data.includes("u2f_safari2window")) // if the data includes our tag, it's safe to parse it as JSON
            return;

        var data = JSON.parse(e.data);
        if (data._meta != "u2f_safari2window" || data.name != "U2FResponse")
            return;
        data = data.message;

        console.log("FIDO U2F Safari Extension: got response, error = ", data.error);

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
                keyHandle: result.keyHandle,
                signatureData: result.signatureData,
                clientData: result.clientData,
            });
        }
    });

    if (window.u2f)
        window.u2f = u2f;
    Object.defineProperty(window, "u2f", {
        get: function() { return u2f; },
        set: undefined,  // prevent furthur change
    });
    console.log("FIDO U2F Safari Extension: loaded");
})();
