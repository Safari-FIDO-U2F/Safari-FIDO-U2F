// act as bridge between u2f.js and app extension

window.addEventListener("message", function(e) {
    if (e.origin != window.location.origin)
        return;
    var data = JSON.parse(e.data);
    console.log("in extension: ", JSON.stringify(data));
    if (data._meta != "u2f_window2safari")
        return;
    safari.extension.dispatchMessage(data.name, data.message);
});

safari.self.addEventListener("message", function(e) {
    console.log("in extension: ", e.name);
    console.log("in extension: ", JSON.stringify(e.message))
    window.postMessage(JSON.stringify({
        _meta: "u2f_safari2window",
        name: e.name,
        message: e.message,
    }), window.location.origin);
});

document.addEventListener("DOMContentLoaded", function(e) {
    var s = document.createElement('script');
    s.type = 'text/javascript';
    s.src = safari.extension.baseURI + 'u2f.js';
    document.head.appendChild(s);
});
