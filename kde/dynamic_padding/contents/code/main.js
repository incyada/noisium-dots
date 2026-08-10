//just set this to true for debugging, if its ever needed that is
const DEBUG = false;

function log(...args) { if (DEBUG) print("[dynamic_padding]", ...args); }

function setPaddingRecursive(tile, value) {
    tile.padding = value;
    for (const child of tile.tiles) {
        setPaddingRecursive(child, value);
    }
}

//padding to add when the deskotp changes, no matter the screen
function updatePadding() {
    const padding = readConfig("padding", 12);
    log("padding value from config:", padding);
    for (const desktop of workspace.desktops) {
        for (const screen of workspace.screens) {
            const tm = workspace.tilingForScreen(screen);
            if (!tm || !tm.rootTile) continue;
            log("applying padding to screen:", screen, "desktop:", desktop);
            setPaddingRecursive(tm.rootTile, padding);
        }
    }
}

//run the function when:
// a new desktop has been created
// a window has been moved into a desktop
// a window has been added to a desktop, if it didnt apply upon creation of said desktop
updatePadding();
workspace.desktopsChanged.connect(updatePadding);
workspace.windowAdded.connect(updatePadding);
workspace.currentDesktopChanged.connect(() => {
    const padding = readConfig("padding", 12);
    const tm = workspace.tilingForScreen(workspace.activeScreen);
    if (!tm || !tm.rootTile) return;
    log("applying padding to active screen on desktop change");
    setPaddingRecursive(tm.rootTile, padding);
});
