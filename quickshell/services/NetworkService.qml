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
    id: service

    // Live Metrics
    property string rxRate: "0 Mb/s"
    property string txRate: "0 Mb/s"
    property string totalDownloaded: "0 MB"
    property string totalUploaded: "0 MB"

    property string pingMs: "0 ms"
    property string packetLoss: "0%"
    property string ipAddress: "127.0.0.1"
    property string gateway: "127.0.0.1"
    property string activeDns: "DHCP"

    property var rxHistory: []
    property var txHistory: []
    property int maxHistoryLength: 30

    property real prevRxBytes: 0
    property real prevTxBytes: 0
    property double lastTime: 0

    // Process: /proc/net/dev
    property Process netProc: Process {
        command: ["cat", "/proc/net/dev"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: service.parseDev(this.text)
        }
    }

    // Process: Ping stats (1 packet)
    property Process pingProc: Process {
        command: ["ping", "-c", "1", "-w", "1", "1.1.1.1"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: service.parsePing(this.text)
        }
    }

    // Process: IP & Gateway
    property Process routeProc: Process {
        command: ["sh", "-c", "ip route show default | awk '{print $3}'; ip -4 addr show scope global | grep inet | awk '{print $2}' | cut -d/ -f1 | head -n1"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: service.parseRoute(this.text)
        }
    }

    // Poll Timer
    property Timer pollTimer: Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            service.netProc.running = true;
            if (!service.pingProc.running)
                service.pingProc.running = true;
            if (!service.routeProc.running)
                service.routeProc.running = true;
        }
    }

    function parseDev(data) {
        if (!data)
            return;
        const now = Date.now();
        const lines = data.split("\n");
        let totalRxBytes = 0;
        let totalTxBytes = 0;

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i].trim();
            if (!line || line.startsWith("Inter") || line.startsWith("face") || line.startsWith("lo:"))
                continue;

            const parts = line.split(":")[1]?.trim().split(/\s+/);
            if (parts && parts.length >= 9) {
                totalRxBytes += parseFloat(parts[0]) || 0;
                totalTxBytes += parseFloat(parts[8]) || 0;
            }
        }

        service.totalDownloaded = formatDataSize(totalRxBytes);
        service.totalUploaded = formatDataSize(totalTxBytes);

        if (service.lastTime > 0) {
            const timeDiff = (now - service.lastTime) / 1000;
            if (timeDiff > 0) {
                const rxBitsSec = Math.max(0, ((totalRxBytes - service.prevRxBytes) * 8) / timeDiff);
                const txBitsSec = Math.max(0, ((totalTxBytes - service.prevTxBytes) * 8) / timeDiff);

                service.rxRate = formatSpeedBits(rxBitsSec);
                service.txRate = formatSpeedBits(txBitsSec);

                let rxArr = service.rxHistory.slice();
                let txArr = service.txHistory.slice();
                rxArr.push(rxBitsSec);
                txArr.push(txBitsSec);
                if (rxArr.length > service.maxHistoryLength)
                    rxArr.shift();
                if (txArr.length > service.maxHistoryLength)
                    txArr.shift();

                service.rxHistory = rxArr;
                service.txHistory = txArr;
            }
        }

        service.prevRxBytes = totalRxBytes;
        service.prevTxBytes = totalTxBytes;
        service.lastTime = now;
    }

    function parsePing(data) {
        if (!data) {
            service.pingMs = "N/A";
            service.packetLoss = "100%";
            return;
        }

        const lossMatch = data.match(/(\d+)%\s+packet loss/);
        if (lossMatch)
            service.packetLoss = lossMatch[1] + "%";

        const timeMatch = data.match(/time=([\d.]+)\s*ms/);
        if (timeMatch)
            service.pingMs = parseFloat(timeMatch[1]).toFixed(1) + " ms";
        else
            service.pingMs = "N/A";
    }

    function parseRoute(data) {
        if (!data)
            return;
        const lines = data.trim().split("\n");
        if (lines.length >= 1 && lines[0])
            service.gateway = lines[0].trim();
        if (lines.length >= 2 && lines[1])
            service.ipAddress = lines[1].trim();
    }

    // Dynamic process component for executing interactive system commands
    property Component dnsExecComp: Component {
        Process {
            id: dnsProc
            onExited: dnsProc.destroy()
        }
    }

    function setDns(provider) {
        service.activeDns = provider;

        let dnsServers = "";
        if (provider === "Cloudflare") {
            dnsServers = "1.1.1.1 1.0.0.1";
        } else if (provider === "Google") {
            dnsServers = "8.8.8.8 8.8.4.4";
        } else if (provider === "Custom") {
            dnsServers = "9.9.9.9";
        }

        let bashCmd = "";
        if (provider === "DHCP") {
            bashCmd = 'CONN="$(nmcli -t -f NAME con show --active | head -n1)"; nmcli con mod "$CONN" ipv4.ignore-auto-dns no && nmcli con up "$CONN"';
        } else {
            bashCmd = `CONN="$(nmcli -t -f NAME con show --active | head -n1)"; nmcli con mod "$CONN" ipv4.ignore-auto-dns yes && nmcli con mod "$CONN" ipv4.dns "${dnsServers}" && nmcli con up "$CONN"`;
        }

        // Spawn shell process to apply network settings
        var proc = service.dnsExecComp.createObject(service, {
            command: ["sh", "-c", bashCmd]
        });
        proc.running = true;
    }

    function formatSpeedBits(bits) {
        if (bits >= 1000000)
            return (bits / 1000000).toFixed(1) + " Mb/s";
        if (bits >= 1000)
            return (bits / 1000).toFixed(0) + " Kb/s";
        return bits.toFixed(0) + " b/s";
    }

    function formatDataSize(bytes) {
        if (bytes >= 1073741824)
            return (bytes / 1073741824).toFixed(1) + " GB";
        if (bytes >= 1048576)
            return (bytes / 1048576).toFixed(1) + " MB";
        if (bytes >= 1024)
            return (bytes / 1024).toFixed(0) + " KB";
        return bytes.toFixed(0) + " B";
    }
}
