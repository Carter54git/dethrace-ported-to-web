/* Carmageddon web port — IDBFS for saves (game DATA comes from preload at /carma) */

var Module = Module || {};

/* Stable WebAudio buffer for miniaudio ScriptProcessor backend. */
(function () {
    var Orig = window.AudioContext || window.webkitAudioContext;
    if (!Orig) {
        return;
    }
    function PatchedAudioContext(opts) {
        opts = opts || {};
        if (!opts.latencyHint) {
            opts.latencyHint = 'playback';
        }
        return new Orig(opts);
    }
    PatchedAudioContext.prototype = Orig.prototype;
    window.AudioContext = PatchedAudioContext;
    if (window.webkitAudioContext) {
        window.webkitAudioContext = PatchedAudioContext;
    }
})();

Module.webGLContextAttributes = {
    alpha: false,
    antialias: false,
    depth: true,
    stencil: false,
    preserveDrawingBuffer: true,
    powerPreference: 'high-performance'
};

Module.preRun = Module.preRun || [];
Module.preRun.push(function () {
    if (Module._dethraceIdbfsMounted) {
        return;
    }
    Module._dethraceIdbfsMounted = true;

    /* Do NOT mount IDBFS on /carma — that would hide preloaded game files */
    try {
        FS.mkdir('/persistent');
    } catch (e) {
        /* already exists */
    }

    try {
        FS.mount(IDBFS, {}, '/persistent');
    } catch (e) {
        console.warn('IDBFS mount skipped:', e);
        return;
    }

    Module.addRunDependency('idbfs-sync');
    FS.syncfs(true, function (err) {
        if (err) {
            console.warn('IDBFS sync:', err);
        }
        Module.removeRunDependency('idbfs-sync');
    });
});

window.addEventListener('beforeunload', function () {
    if (typeof FS === 'undefined') {
        return;
    }
    try {
        FS.syncfs(false, function () {});
    } catch (e) {
        /* ignore */
    }
});

/* Browsers block AudioContext until a user gesture */
(function () {
    function resumeContext(ctx) {
        if (ctx && typeof ctx.resume === 'function' && ctx.state === 'suspended') {
            ctx.resume().catch(function (e) {
                console.warn('WebAudio resume:', e);
            });
        }
    }

    function resumeWebAudio() {
        if (typeof window.miniaudio === 'undefined') {
            return;
        }
        try {
            for (var i = 0; i < window.miniaudio.devices.length; i++) {
                var device = window.miniaudio.devices[i];
                if (!device) {
                    continue;
                }
                resumeContext(device.webaudio);
            }
        } catch (e) {
            console.warn('WebAudio resume:', e);
        }
    }

    function onUserGesture() {
        resumeWebAudio();
        var allRunning = true;
        if (typeof window.miniaudio !== 'undefined') {
            for (var i = 0; i < window.miniaudio.devices.length; i++) {
                var device = window.miniaudio.devices[i];
                if (device && device.webaudio && device.webaudio.state === 'suspended') {
                    allRunning = false;
                }
            }
        }
        if (allRunning) {
            document.removeEventListener('pointerdown', onUserGesture);
            document.removeEventListener('keydown', onUserGesture);
        }
    }

    document.addEventListener('pointerdown', onUserGesture, true);
    document.addEventListener('keydown', onUserGesture, true);
})();
