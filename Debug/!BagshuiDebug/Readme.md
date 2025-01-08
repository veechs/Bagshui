# !BagshuiDebug
Install this addon to enable [Bagshui](https://github.com/veechs/Bagshui)’s debug output (i.e. `Bagshui:PrintDebug()`).

There are also a few other debug flags scattered around that won’t function otherwise.

All it does is set the global `BAGSHUI_DEBUG` to `true`.

This exists as a separate addon so there’s no need to turn off debug for releases, since it’s off by default.
