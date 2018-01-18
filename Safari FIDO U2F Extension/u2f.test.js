require('./u2f');

test('u2f is defined', () => {
  expect(window.u2f).toBeDefined();
});

test('isSafari is true', () => {
  expect(window.u2f.isSafari)
});

test('version is 1.1', done => {
  function callback(info) {
    expect(info["js_api_version"]).toBe(1.1);
    done();
  }

  u2f.getApiVersion(callback);
});
