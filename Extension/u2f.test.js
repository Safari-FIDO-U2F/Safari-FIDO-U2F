require('./u2f');

test('u2f is defined', () => {
    expect(window.u2f).toBeDefined();
});

test('isSafari is true', () => { expect(window.u2f.isSafari).toBeTruthy() });

test('version is 1.1', done => {
    function callback(info)
    {
        expect(info["js_api_version"]).toBe(1.1);
        done();
    }

    u2f.getApiVersion(callback);
});

test('app id set correctly', () => {
    var request = u2f.basicRequest_("test", "myAppID", [ "myKey" ]);
    expect(request.appId).toBe("myAppID");
});

test('type set correctly', () => {
    var request = u2f.basicRequest_("myType", "myAppID", [ "myKey" ]);
    expect(request.type).toBe("myType");
});

test('keys set correctly', () => {
    var registeredKeys = [ 'myKey' ];
    var request = u2f.basicRequest_("myType", "myAppID", registeredKeys);
    expect(request.registeredKeys).toBe(registeredKeys);
});

test('timeout set correctly', () => {
    var request = u2f.basicRequest_("myType", "myAppID", [ "myKey" ], null, 123);
    expect(request.timeoutSeconds).toBe(123);
});

test('timeout defaulted correctly', () => {
    var request = u2f.basicRequest_("myType", "myAppID", [ "myKey" ]);
    expect(request.timeoutSeconds).toBe(u2f.EXTENSION_TIMEOUT_SEC);
});

test('request ids are unique', () => {
    var request1 = u2f.basicRequest_("test", "appID", [ "myKey" ]);
    var request2 = u2f.basicRequest_("test", "appID", [ "myKey" ]);
    expect(request1.requestId).toBeDefined();
    expect(request1.requestId).not.toBe(request2.requestId);
});

test('register request', () => {
    var registerRequests = [ "myRequests" ];
    var request = u2f.registerRequest_("myAppID", registerRequests, [ "myKey" ]);
    expect(request.type).toBe(u2f.MessageTypes.U2F_REGISTER_REQUEST);
    expect(request.registerRequests).toBe(registerRequests);
});


test('sign request', () => {
    var request = u2f.signRequest_("myAppID", "myChallenge", [ "myKey" ]);
    expect(request.type).toBe(u2f.MessageTypes.U2F_SIGN_REQUEST);
    expect(request.challenge).toBe("myChallenge");
});

test('response fires callback', done => {
    function callback(responseData)
    {
        expect(responseData).toBe("myResponse");
        done();
    };

    var request = u2f.basicRequest_("test", "appID", [ "myKeys" ], callback);
    var message = {
        data : {
            responseData : "myResponse",
            requestId : request.requestId
        }
    };
    u2f.responseHandler_(message);
});

test('missing request id throws exception', () => {
    function handleResponse()
    {
        var message = {
            data : {
                responseData : "myResponse"
            }
        };
        u2f.responseHandler_(message);
    }
    expect(handleResponse).toThrow();
});

test('missing unregistered id throws exception', () => {
    function handleResponse()
    {
        var message = {
            data : {
                responseData : "myResponse",
                requestId : 1234567
            }
        };
        u2f.responseHandler_(message);
    }
    expect(handleResponse).toThrow();
});
