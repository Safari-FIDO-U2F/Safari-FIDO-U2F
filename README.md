# Safari FIDO U2F

**FIDO U2F support is possible in Safari, finally!**

## Quick Start

- Download [release](https://github.com/blahgeek/Safari-FIDO-U2F/releases)
- Open it
- Enable the `Safari FIDO U2F Extension` in Safari Preferences

This extension requires *macOS 10.12* and later or macOS 10.11.5 when Safari 10 is installed.

## How?

This extension uses the new [Safari App Extensions](https://developer.apple.com/library/prerelease/content/documentation/NetworkingInternetWeb/Conceptual/SafariAppExtension_PG/index.html#//apple_ref/doc/uid/TP40017319-CH15-SW1) API introduced in Safari 10, which allows Safari extension to communicate with native app.

The native part uses [libu2f-host](https://github.com/Yubico/libu2f-host) as the backend.

Only the high-level JavaScript API is implemented for now: `register` and `sign` (see [FIDO U2F Javascript API Specification](https://fidoalliance.org/specs/fido-u2f-v1.0-nfc-bt-amendment-20150514/fido-u2f-javascript-api.html)). A new object `window.u2f` is exported. Both the API 1.1 and API 1.0 specifications are supported.

## Does it work in xxx.com?

Technically, this extension adds the full FIDO U2F Javascript API to safari.

But as stated in the specification, the interface (for now) is browser dependent, so each website is required to add support for it (by adding some code to test `if browser is safari`...).

Currently, most of the sites using U2F are using [u2f-api.js](https://demo.yubico.com/js/u2f-api.js) to provide
cross-browser support of U2F. This extension provides a JavaScript API that is compatible with it and will override it to seamlessly, so should support a large set of websites.

However, there are still websites that do not work properly.

The following sites working according to my latest tests (Using macOS 10.12 with Yubikey 4):

- [Yubico U2F DEMO](https://demo.yubico.com/u2f)
- [Google's U2F DEMO](https://crxjs-dot-u2fdemo.appspot.com)
- [Github Account Two-factor authentication](https://help.github.com/articles/configuring-two-factor-authentication-via-fido-u2f/)
- :warning: Dropbox Account Security
- Fastmail

**:warning:: You need to [change Safari's User-Agent to chrome](http://www.howtogeek.com/211961/how-to-change-safaris-user-agent-in-os-x/) to make these sites work**

The following websites do not work (yet):

- Google Account (and all kinds of google sites)

## Build

- Clone this project
- Install the build tools that required to build dependencies: `brew install autoconf automake libtool pkg-config`
- Open Xcode project and select and build target libu2f-host
- Change target to Safari FIDO U2F and build it

Apple Developer ID may be needed (not tested).

## Disclaimer

I am not an expert in neither swift or javascript, and definitely not an expert of cryptography, use it at your own risk. Contribution would be really appreciated.
