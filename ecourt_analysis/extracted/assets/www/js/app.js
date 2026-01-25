
    function onAppReady() {
        if (navigator.splashscreen && navigator.splashscreen.hide) {   // Cordova API detected
        }
    }
    document.addEventListener("deviceready", onAppReady, false);
    document.addEventListener("deviceready", onDeviceReady, false);
    var versions;
    versionChecked = false;
    function onDeviceReady() {       
        navigator.splashscreen.hide();
    }
