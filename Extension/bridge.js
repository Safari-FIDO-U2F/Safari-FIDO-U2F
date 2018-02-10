//  ----------------------------------------------------------------
//  Copyright (c) 2016-present, Yikai Zhao, Sam Deane, et al.
//
//  This source code is licensed under the MIT license found in the
//  LICENSE file in the root directory of this source tree.
//  ----------------------------------------------------------------

function forwardMessageToExtension(e) {
    if (e.origin == window.location.origin) {
        message = e.data;
        type = message.type;
        if ((type == "u2f_register_request") || (type == "u2f_sign_request")) {
//            console.log("extension <- " + JSON.stringify(message));
            safari.extension.dispatchMessage(type, message);
        }
    }
}

function forwardMessageFromExtension(e) {
    //    console.log("extension -> " + JSON.stringify(e.message.data));
    window.postMessage(e.message, window.location.origin);
}

function handleBeforeLoad(e) {
    document.removeEventListener("beforeload", handleBeforeLoad, true)
    var s = document.createElement('script');
    s.type = 'text/javascript';
    s.src = safari.extension.baseURI + 'u2f.js';
    document.head.appendChild(s);
}

window.addEventListener("message", forwardMessageToExtension, true);
safari.self.addEventListener("message", forwardMessageFromExtension);
document.addEventListener("beforeload", handleBeforeLoad , true);
