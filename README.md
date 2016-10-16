# Safari FIDO U2F

**FIDO U2F support is possible in Safari, finally!**

## Quick Start

- Download [release](https://github.com/blahgeek/Safari-FIDO-U2F/releases)
- Open it
- enable `Safari FIDO U2F Extension` in Safari Preference

This extension requires *macOS 10.12* and later or macOS 10.11.5 when Safari 10 is installed.

## How?

This extension uses the new [Safari App Extensions](https://developer.apple.com/library/prerelease/content/documentation/NetworkingInternetWeb/Conceptual/SafariAppExtension_PG/index.html#//apple_ref/doc/uid/TP40017319-CH15-SW1) API introduced in Safari 10,
which allows safari extension to communicate with native app.

The native part uses [libu2f-host](https://github.com/Yubico/libu2f-host) as backend.

Only high-level JavaScript API is implemented for now: `register` and `sign` (see [FIDO U2F Javascript API Specification](https://fidoalliance.org/specs/fido-u2f-v1.0-nfc-bt-amendment-20150514/fido-u2f-javascript-api.html)), a new object `window.u2f` is exported. Both API 1.1 and API 1.0 specification is supported.

## Does it works in xxx.com?

Technically, this extension adds full FIDO U2F Javascript API to safari.
But as stated in the specification, the interface (for now) is browser dependent, so each website is required to add support for it (add some `if browser is safari` part).

Currently, most of the sites using U2F is using [u2f-api.js](https://demo.yubico.com/js/u2f-api.js) to provide
cross-browser support of U2F, so this extension provides JavaScript API that is compatible with it and will override it to seamlessly support a large set of website.
Still, there's websites that do not work properly (but not something I can do).

The following websites is working properly according to my test (Using macOS 10.12 with Yubikey 4):

- [Yubico U2F DEMO](https://demo.yubico.com/u2f)
- [Google's U2F DEMO](https://crxjs-dot-u2fdemo.appspot.com)
- :warning: Github Account Two-factor authentication
- :warning: Dropbox Account Security
- Fastmail

**:warning:: You need to [change Safari's User-Agent to chrome](http://www.howtogeek.com/211961/how-to-change-safaris-user-agent-in-os-x/) to make these sites working**

The following website does not work (yet):

- Google Account (and all kinds of google sites)

## Build

Just clone this project and build it with xcode. You will need `libu2f-host.a`, `libhidapi.a` and `libjson-c.a`. I recommend to install them from homebrew.
Note that hidapi stable version contains some bugs, HEAD version should be used.

Apple Developer ID may be needed (not tested).

## Disclaimer

I am not an expert in neither swift or javascript, and definitely not an expert of cryptography,
use it at your own risk. Contribution would be really appreciated.
