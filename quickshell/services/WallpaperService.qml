pragma Singleton
import QtQuick
import Quickshell
import qs.popups
import qs.widgets
import qs.windows
import Quickshell.Io
import qs.popups
import qs.widgets
import qs.windows

QtObject {
    id: root

    property var wallpapers: []
    property var avatars: []
    property string activeWallpaper: configAdapter.activeWallpaper

    property string wallpaperDir: configAdapter.wallpaperDir
    property string avatarDir: configAdapter.avatarDir
    property string activeAvatar: configAdapter.activeAvatar
    property var favorites: configAdapter.favorites

    property FileView configFile: FileView {
        path: `${Quickshell.env("HOME")}/.config/quickshell/assets/wallpaper_config.json`
        watchChanges: true
        blockLoading: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()

        JsonAdapter {
            id: configAdapter
            property string wallpaperDir: `${Quickshell.env("HOME")}/Pictures/wallpapers`
            property string avatarDir: `${Quickshell.env("HOME")}/Pictures/LEWDP`
            property string activeAvatar: ""
            property string activeWallpaper: ""
            property var favorites: []
        }
    }

    property Process scanProc: Process {
        id: scanProc
        command: ["/bin/bash", "-c", `find "${configAdapter.wallpaperDir}" -maxdepth 1 -type f \\( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.webp" \\)`]

        stdout: StdioCollector {
            onStreamFinished: {
                let paths = this.text.split("\n").filter(p => p.trim() !== "");
                let list = [];
                for (let p of paths) {
                    let filename = p.substring(p.lastIndexOf('/') + 1);
                    list.push({
                        path: p,
                        name: filename,
                        fileUrl: "file://" + p,
                        favorite: configAdapter.favorites.includes(p)
                    });
                }
                root.wallpapers = list;
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text.trim() !== "")
                    console.error("Wallpaper scan error:", this.text)
            }
        }
    }

    property Process avatarScanProc: Process {
        id: avatarScanProc
        command: ["/bin/bash", "-c", `mkdir -p "${configAdapter.avatarDir}" && find "${configAdapter.avatarDir}" -maxdepth 1 -type f \\( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.webp" \\)`]

        stdout: StdioCollector {
            onStreamFinished: {
                let paths = this.text.split("\n").filter(p => p.trim() !== "");
                let list = [];
                for (let p of paths) {
                    let filename = p.substring(p.lastIndexOf('/') + 1);
                    list.push({
                        path: p,
                        name: filename,
                        fileUrl: "file://" + p
                    });
                }
                root.avatars = list;
            }
        }
    }

    Component.onCompleted: {
        scanProc.running = true;
        avatarScanProc.running = true;
    }

    function reload() {
        scanProc.running = false;
        scanProc.running = true;
    }

    function reloadAvatars() {
        avatarScanProc.running = false;
        avatarScanProc.running = true;
    }

    function setWallpaperDir(path) {
        if (!path || path.trim() === "") return;
        configAdapter.wallpaperDir = path.trim();
        reload();
    }

    function setAvatarDir(path) {
        if (!path || path.trim() === "") return;
        configAdapter.avatarDir = path.trim();
        reloadAvatars();
    }

    function setAvatar(path) {
        configAdapter.activeAvatar = path;
    }

    function toggleFavorite(path) {
        let favs = configAdapter.favorites.slice();
        const idx = favs.indexOf(path);
        if (idx >= 0) favs.splice(idx, 1);
        else favs.push(path);
        configAdapter.favorites = favs;

        root.wallpapers = root.wallpapers.map(w => Object.assign({}, w, {
            favorite: configAdapter.favorites.includes(w.path)
        }));
    }

    function applyWallpaper(path) {
        configAdapter.activeWallpaper = path;
        let applyProc = Qt.createQmlObject(`
            import Quickshell
            import qs.popups
            import qs.widgets
            import qs.windows
            import Quickshell.Io
            Process {
                command: ["/bin/bash", "-c", "( /home/odysseus/aether/build/bin/aether --generate '${path}' --extract-mode normal; bash /home/odysseus/.config/quickshell/services/apply_theme.sh ) & ( awww img '${path}' --transition-type fade --transition-step 63 --transition-angle 0 --transition-duration 2 --transition-fps 60 --resize fit || hyprpaper -w '${path}' || feh --bg-fill '${path}' ) & wait"];
                running: true;
                stdout: StdioCollector {
                    onStreamFinished: console.log("applyWallpaper stdout:", this.text)
                }
                stderr: StdioCollector {
                    onStreamFinished: console.log("applyWallpaper stderr:", this.text)
                }
            }
        `, root);
    }


    property int aetherVersion: 0

    function syncFromAether() {
        configAdapter.activeWallpaper = `${Quickshell.env("HOME")}/.config/aether/theme/backgrounds/wallpaper.jpg`;
        root.aetherVersion++;
    }

    function launchAetherCarousel() {
        Quickshell.execDetached(["qs", "-c", `${Quickshell.env("HOME")}/.config/quickshell/aether-wallpapers`]);
    }

    function launchAetherGUI() {
        Quickshell.execDetached(["/home/odysseus/aether/build/bin/aether"]);
    }

    function launchAetherPicker() {
        Quickshell.execDetached(["qs", "-c", "aether-wallpapers"]);
    }
}
