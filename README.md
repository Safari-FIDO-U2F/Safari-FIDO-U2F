# Safari FIDO U2F

**FIDO U2F support is possible in Safari, finally!**

## Quick Start

To just test the extension without building it:

- Download [the latest release](https://github.com/blahgeek/Safari-FIDO-U2F/releases)
- Run It
- Click `Open Safari Preferences`
- Enable the `Safari FIDO U2F Extension`

This extension requires *macOS 10.12* and later or macOS 10.11.5 when Safari 10 is installed.

## How?

This extension uses the new [Safari App Extensions](https://developer.apple.com/library/prerelease/content/documentation/NetworkingInternetWeb/Conceptual/SafariAppExtension_PG/index.html#//apple_ref/doc/uid/TP40017319-CH15-SW1) API introduced in Safari 10, which allows a Safari extension to be built using native code, and embedded in another app.

The native part uses [libu2f-host](https://github.com/Yubico/libu2f-host) as the backend.

Only the high-level JavaScript API is implemented for now: `register` and `sign` (see [FIDO U2F Javascript API Specification](https://fidoalliance.org/specs/fido-u2f-v1.0-nfc-bt-amendment-20150514/fido-u2f-javascript-api.html)). A new object `window.u2f` is exported. Both the API 1.1 and API 1.0 specifications are supported.

## Does It Work With Site xyz.com?

Technically, this extension adds the full FIDO U2F Javascript API to Safari.

But as stated in the specification, the interface (for now) is browser dependent, so each website is required to add support for it (by adding some code to test `if browser is safari`...).

Currently, most of the sites using U2F are using [u2f-api.js](https://demo.yubico.com/js/u2f-api.js) to provide
cross-browser support of U2F. This extension provides a JavaScript API that is compatible with it and will override it seamlessly, so should support a large set of websites.

However, there are still websites that do not work properly.

The following sites should work out of the box:

- [Yubico U2F DEMO](https://demo.yubico.com/u2f)
- [Google's U2F DEMO](https://crxjs-dot-u2fdemo.appspot.com)
- [Github Account Two-factor authentication](https://help.github.com/articles/configuring-two-factor-authentication-via-fido-u2f/)
- Fastmail

## Problems

Plenty of sites do not work yet.

The extension works by injecting a u2f javascript object into to the page. Because of the way Safari's extensions work, it's not possible to inject this object early enough for all sites to spot that it is there. Some sites check too early, and/or add their own object which then gets overwritten.

In addition, some sites base their checks on the idea that only Chrome supports U2F on the Mac. Because of this, you may need to [change Safari's User-Agent to Chrome](http://www.howtogeek.com/211961/how-to-change-safaris-user-agent-in-os-x/) to make these sites work.


## To Build With Xcode

- Clone this project
- Install the dependencies using Homebrew: `brew install hidapi json-c libu2f-host`
- Open Xcode workspace and select the scheme `Safari FIDO U2F`
- Extensions must be code signed. To build locally, you will need to adjust the `Development Team` setting of both targets to a team that you have Mac Developer certificates for
- Choose `Run` from the `Product` menu.
- Xcode should build & launch the small app. You can then enable the extension from within Safari.

## Disclaimer

The authors of this extension are not security, cryptography or javascript experts.
Use of the extension is entirely at your own risk! 

All feedback and other contributions welcomed.
In particular, please let us know about sites that do/don't work ok!
