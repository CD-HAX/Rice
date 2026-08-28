import QtQuick
import Quickshell.Services.Notifications
import qs.popups
import qs.widgets
import qs.windows

pragma Singleton

Item {
    id: root

    property var history: []
    property var activeToasts: []
    property int unreadCount: 0

    NotificationServer {
        id: server
        
        onNotification: (notification) => {
            notification.tracked = true;
            
            let entry = {
                notifId: notification.id,
                appName: notification.appName,
                appIcon: notification.appIcon,
                summary: notification.summary,
                body: notification.body,
                urgency: notification.urgency,
                timestamp: new Date().toLocaleTimeString(Qt.locale(), Locale.ShortFormat),
                invokeDefault: () => {
                    let invoked = false;
                    if (notification.actions) {
                        for (let i = 0; i < notification.actions.length; i++) {
                            let a = notification.actions[i];
                            
                            // DBus default action is "default"
                            if (a && (a.identifier === "default" || a.id === "default")) {
                                if (typeof a.invoke === "function") {
                                    a.invoke();
                                    invoked = true;
                                }
                            }
                        }
                    }
                    if (typeof notification.dismiss === "function") {
                        try { notification.dismiss(); } catch (e) { console.error("Dismiss error:", e); }
                    }
                },
                dismiss: () => {
                    if (typeof notification.dismiss === "function") {
                        try { notification.dismiss(); } catch (e) {}
                    }
                }
            };

            let h = root.history.slice();
            h.unshift(entry);
            root.history = h;
            
            root.unreadCount++;

            let t = root.activeToasts.slice();
            t.unshift(entry);
            root.activeToasts = t;
        }
    }

    function removeToast(id) {
        root.activeToasts = root.activeToasts.filter(t => t.notifId !== id);
    }

    function removeHistory(id) {
        let entry = root.history.find(t => t.notifId === id);
        if (entry && typeof entry.dismiss === "function") entry.dismiss();
        root.history = root.history.filter(t => t.notifId !== id);
    }

    function clearHistory() {
        for (let entry of root.history) {
            if (typeof entry.dismiss === "function") entry.dismiss();
        }
        root.history = [];
        root.unreadCount = 0;
    }
    
    function markAllRead() {
        root.unreadCount = 0;
    }
}
