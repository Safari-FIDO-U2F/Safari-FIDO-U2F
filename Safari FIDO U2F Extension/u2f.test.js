require('./u2f');

test('u2f is defined', () => {
    expect(window.u2f).toBeDefined();
});

test('isSafari is true', () => { expect(window.u2f.isSafari) });

test('version is 1.1', done => {
    function callback(info) {
        expect(info["js_api_version"]).toBe(1.1);
        done();
    }

    u2f.getApiVersion(callback);
});

test('app id set correctly', () => {
  var request = u2f.basicRequest("test", "myAppID", null);
  expect(request.appId).toBe("myAppID");
});

test('type set correctly', () => {
  var request = u2f.basicRequest("myType", "myAppID", null);
  expect(request.type).toBe("myType");
});

test('request ids are unique', () => {
  var request1 = u2f.basicRequest("test", "appID", null);
  var request2 = u2f.basicRequest("test", "appID", null);
  expect(request1.requestId).toBeDefined();
  expect(request1.requestId).not.toBe(request2.requestId);
});

test('basic request', done => {
  function callback(info) {
    console.log(info);
    done();
  };

  var request = u2f.basicRequest("test", "appID", callback);
  console.log(request);
  var message = {};
  message.data = request;
  u2f.responseHandler_(message);
});
