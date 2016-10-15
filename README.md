# Safari FIDO U2F

**FIDO U2F support is possible in Safari, finally!**

## Quick Start

- Download [release](https://github.com/blahgeek/Safari-FIDO-U2F/releases)
- Open it
- enable `Safari FIDO U2F Extension` in Safari Preference

This extension requires *macOS 10.12* and later or macOS 10.11.5 when Safari 10 is installed.

## Tested Websites

The following websites is working properly according to my test (Using macOS 10.12 with Yubikey 4):

- [Yubico U2F DEMO](https://demo.yubico.com/u2f)
- [Google's U2F DEMO](https://crxjs-dot-u2fdemo.appspot.com)

Other websites should also work. Please create issues if you find any website not working properly.

## How?

This extension uses the new [Safari App Extensions](https://developer.apple.com/library/prerelease/content/documentation/NetworkingInternetWeb/Conceptual/SafariAppExtension_PG/index.html#//apple_ref/doc/uid/TP40017319-CH15-SW1) API introduced in Safari 10,
which allows safari extension to communicate with native app.

The native part uses [libu2f-host](https://github.com/Yubico/libu2f-host) as backend.

According to [FIDO U2F Javascript API Specification](https://fidoalliance.org/specs/fido-u2f-v1.0-nfc-bt-amendment-20150514/fido-u2f-javascript-api.html),
high-level JavaScript API is implemented: `register` and `sign`, a new object `window.u2f` is exported. Both API 1.1 and API 1.0 specification is supported.
The JavaScript API is compatible with the widely-used [u2f-api.js](https://demo.yubico.com/js/u2f-api.js) and will override it, which make it possible to support
a large set of website supporting U2F without other change (though it's hacky).

## Build

Just clone this project and build it with xcode. You will need `libu2f-host.a`, `libhidapi.a` and `libjson-c.a`. I recommend to install them from homebrew.
Note that hidapi stable version contains some bugs, HEAD version should be used.

Apple Developer ID may be needed (not tested).

## Disclaimer

I am not an expert in neither swift or javascript, and definitely not an expert of cryptography,
use it at your own risk. Contribution would be really appreciated.
