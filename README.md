# Safari FIDO U2F

**FIDO U2F support for Safari**

## Quick Start

To use the extension:

- Download [the latest release](https://github.com/Safari-FIDO-U2F/Safari-FIDO-U2F/releases)
- Run It
- Quit Safari (if it is open)
- Click `Open Safari Preferences`
- Enable the `Safari FIDO U2F Extension`

This extension requires macOS 10.12 and later, or macOS 10.11.5 and Safari 10.

## Supported Sites

The FIDO U2F specification defines a high-level javascript API, but leaves it up to the browser to implement it. It also leaves it up to individual sites
to work out if the API is present / supported.

This extension works by injecting support for the high-level FIDO U2F Javascript API into the current page.

Many sites will notice that `window.u2f` is present, and should just work. The following have been tested:

- [Yubico Demo](https://demo.yubico.com/u2f)
- [Google Demo](https://crxjs-dot-u2fdemo.appspot.com)
- [AkiSec Demo](https://akisec.com/demo/)
- [u2f.bin.coffee Demo](https://u2f.bin.coffee)
- [U2F Test Page](https://alexander.sagen.me/u2f-test-page/)
- [Github Account Two-factor authentication](https://help.github.com/articles/configuring-two-factor-authentication-via-fido-u2f/)
- Fastmail

## Problems

There are two main reasons for sites not working:

- The extension works by injecting code into to the page as it loads. Some sites perform their checks too early, before the injected code is present. Note that version 2.0 of the plugin now injects code quite early, and seems to have fixed most of these issues. 

- Some sites assume that only Chrome supports U2F on the Mac, and won't even try to use U2F if they detect Safari. As a workaround, [changing Safari's User-Agent to Chrome](http://www.howtogeek.com/211961/how-to-change-safaris-user-agent-in-os-x/) may make these sites function. Unfortunately, other incompatibilities between Chrome and Safari can then often cause problems, since the site attempts to use unrelated Chrome-only features. Really the way to fix these sites is to talk to their developers and ask them to use another way to determine whether to enable their U2F support. Checking that `window.u2f` is non-null should be enough. 


## Technical Details

This extension uses the [Safari App Extensions](https://developer.apple.com/library/prerelease/content/documentation/NetworkingInternetWeb/Conceptual/SafariAppExtension_PG/index.html#//apple_ref/doc/uid/TP40017319-CH15-SW1) API introduced in Safari 10, which allows a Safari extension to be built using native code, and embedded in another app.

The native part is written in Swift, and uses [libu2f-host](https://github.com/Yubico/libu2f-host) to actually talk to the hardware.

A small `bridge.js` script is injected into the top level page automatically by the extension.

This performs three tasks:
- listen for `beforeload`, and use it to inject another script `u2f.js` into the document
- listen for `u2f_` messages posted by `u2f.js`, and passes them on to the native code
- listen for messages sent back from the native code and pass them back to `u2f.js` for processing

The `u2f.js` script implements the high-level JavaScript API described in the [FIDO U2F Javascript API Specification](https://fidoalliance.org/specs/fido-u2f-v1.0-nfc-bt-amendment-20150514/fido-u2f-javascript-api.html). 

It does this by setting `window.u2f` to an object which provides implementations of `u2f.register`,  `u2f.sign` and `u2f.getApiVersion`. Both the API 1.1 and API 1.0 variants of `register` and `sign` are supported. If the page had already set `window.u2f`, we attempt to merge our implementation into it, rather than completely replacing it. If we get there first, we try to lock down the `window.u2f` property so that other scripts can't replace it with a different object (they can still set custom properties on it though). We also provide a non-standard `u2f.isSafari` function which can be used to detect whether this particular implementation is present.
 
The high-level implementation converts the supplied parameters into a dictionary and sends this through for processing by the native code. The native code effectively implements the low-level API also described in the specification. In theory a site is free to talk directly to the native code by posting messages to it using the low-level API. 

The high-level API is asynchronous, and returns its results via callbacks. A `requestId` parameter is used to track requests sent to the extension. When replies come back from the extension, the same `requestId` is used to associate the reply with the correct callback, which is then called.  

As mentioned in [problems](#problems) above, the fact that we have to wait for the `u2f.js` script to load can in theory cause timing problems. If a page has code which decides whether to enable U2F support based on whether `window.u2f` is present, it's possible that it will run too early. We now inject `u2f.js` by listening for the `beforeload` event. This seems to get sent early enough (before `DOMContentLoaded`) that most pages work. 

## To Build With Xcode

- Clone this project
- Open Xcode workspace and select the scheme `application`
- Extensions must be code signed. To build locally, you will need to adjust the `Development Team` setting of the project to a team that you have Mac Developer certificates for
- Choose `Run` from the `Product` menu.
- Xcode should build & launch the small app. You can then enable the extension from within Safari.

## Dependencies

This plugin makes use of the following:

- hidapi: https://github.com/signal11/hidapi.git
- json-c: https://github.com/json-c/json-c.git
- u2f-host: https://github.com/Yubico/libu2f-host.git

For the sake of simplicity, compiled binaries for all three are committed to this repo.

The source for all three is available in the github repos above.

If you wish to build the libraries locally instead, you can do so using Homebrew, with `brew install hidapi json-c libu2f-host`.

## Testing

There are two sets of unit tests.

- The Swift tests can be run by choosing `Test` from the `Product` menu. These primarily test the code which formats incoming request dictionaries from the javascript side, and parses outgoing responses from the hardware side. We don't currently test the hardware itself, and therefore the tests can be run without hardware being present.
- The javascript tests use Jest. You can install the dependencies for this from the command line with `npm install`. The tests can then be run with `npm test`.  

## Continuous Integration

CI is set up using [Travis](https://travis-ci.org/Safari-FIDO-U2F/Safari-FIDO-U2F). 

Committing branches or making pull requests in this repository will trigger builds of the tests. If you fork the repo, you will probably need to tweak `.travis.yml` if you want to run the tests with your own instance.


## Still To Do

There are a few things still to do. See the [issues](https://github.com/Safari-FIDO-U2F/Safari-FIDO-U2F/issues) for more details.

If you find sites that don't work, or features that are missing feel free to make an issue to report them.

If you have the urge to contribute, that would be welcome. The code does not all follow a consistent standard yet but we're slowly cleaning it up. 

By all means just hack on the code and make a pull request, but it might be best to check your plan first by making an issue and discussing it. 

## Disclaimer

The authors of this extension are not security, cryptography or javascript experts.

This extension is still experimental, and use of it is entirely at your own risk!

All feedback and other contributions welcomed.

In particular, please [tell us about sites that do / don't work](https://github.com/Safari-FIDO-U2F/Safari-FIDO-U2F/issues)! Please also consider contacting the owners of those sites to make them aware of this extension, so that we can work together to fix any problems.
