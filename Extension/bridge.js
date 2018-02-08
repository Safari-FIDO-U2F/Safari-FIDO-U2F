//  ----------------------------------------------------------------
//  Copyright (c) 2016-present, Yikai Zhao, Sam Deane, et al.
//
//  This source code is licensed under the MIT license found in the
//  LICENSE file in the root directory of this source tree.
//  ----------------------------------------------------------------

// act as bridge between u2f.js and app extension

window.addEventListener("message", function(e) {
    if (e.origin == window.location.origin) {
        message = e.data;
        type = message.type;
        if ((type == "u2f_register_request") || (type == "u2f_sign_request")) { // if the data includes our tag, it's safe to parse it as JSON
            console.log("passing on message to extension: " + JSON.stringify(message));
            safari.extension.dispatchMessage(type, message);
        }
    }
});

safari.self.addEventListener("message", function(e) {
    console.log("passing on message from extension: " + JSON.stringify(e.message.data));
    window.postMessage(e.message, window.location.origin);
});

document.addEventListener("DOMContentLoaded", function(e) {
    var s = document.createElement('script');
    s.type = 'text/javascript';
    s.src = safari.extension.baseURI + 'u2f.js';
    document.head.appendChild(s);
});

document.addEventListener("BeforeLoad", function(e) {
                          console.log("before load");
                          });
