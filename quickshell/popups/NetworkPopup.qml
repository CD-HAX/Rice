import QtQuick
import Quickshell
import qs.popups
import qs.widgets
import qs.windows
import qs.services

PopupWindow {
    id: root

    property var anchorItem
    property var targetScreen
    property bool expanded: false

    anchor.item: root.anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: 18

    implicitWidth: 380
    implicitHeight: 250
    color: "transparent"

    grabFocus: true
    visible: root.expanded && root.anchorItem !== null

    Rectangle {
        anchors.fill: parent
        radius: 0
        color: Theme.base
        border.width: 1
        border.color: Theme.muted

        Rectangle {
            width: parent.width
            height: 2
            color: Theme.accent
            anchors.top: parent.top
        }

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            // Header Row: Ethernet + Flexible Spacer + Small Mini Graph
            Row {
                width: parent.width
                spacing: 12

                Text {
                    text: "󰈀"
                    color: Theme.accent
                    font.pixelSize: 22
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    spacing: 2
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: "Ethernet"
                        color: Theme.foreground
                        font.pixelSize: 15
                        font.weight: Font.Bold
                    }

                    Text {
                        text: "ROUTING CRUMBS"
                        color: Theme.darkForeground
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        font.letterSpacing: 1
                    }
                }

                // Fixed Spacer replacing Layout.fillWidth
                Item {
                    width: parent.width - 240
                    height: 1
                }

                // Small Inline Canvas Graph
                Rectangle {
                    width: 100
                    height: 28
                    color: Theme.background
                    radius: 0
                    border.width: 1
                    border.color: Theme.muted
                    clip: true
                    anchors.verticalCenter: parent.verticalCenter

                    Canvas {
                        id: graphCanvas
                        anchors.fill: parent
                        anchors.margins: 2

                        Connections {
                            target: NetworkService
                            function onRxHistoryChanged() { graphCanvas.requestPaint() }
                            function onTxHistoryChanged() { graphCanvas.requestPaint() }
                        }

                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);

                            var rx = NetworkService.rxHistory;
                            var tx = NetworkService.txHistory;
                            if (!rx || rx.length < 2) return;

                            var maxVal = 1000000; // 1 Mb/s min floor
                            for (var i = 0; i < rx.length; i++) {
                                if (rx[i] > maxVal) maxVal = rx[i];
                                if (tx[i] > maxVal) maxVal = tx[i];
                            }

                            function drawSeries(data, strokeColor, fillColor) {
                                ctx.beginPath();
                                var step = width / (NetworkService.maxHistoryLength - 1);

                                ctx.moveTo(0, height);
                                for (var j = 0; j < data.length; j++) {
                                    var x = j * step;
                                    var y = height - ((data[j] / maxVal) * height);
                                    ctx.lineTo(x, y);
                                }

                                ctx.lineTo((data.length - 1) * step, height);
                                ctx.closePath();

                                if (fillColor) {
                                    ctx.fillStyle = fillColor;
                                    ctx.fill();
                                }

                                ctx.beginPath();
                                for (var k = 0; k < data.length; k++) {
                                    var sx = k * step;
                                    var sy = height - ((data[k] / maxVal) * height);
                                    if (k === 0) ctx.moveTo(sx, sy);
                                    else ctx.lineTo(sx, sy);
                                }
                                ctx.lineWidth = 1;
                                ctx.strokeStyle = strokeColor;
                                ctx.stroke();
                            }

                            drawSeries(rx, Theme.accent, Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.20));
                            drawSeries(tx, "#50fa7b", Qt.rgba(0.31, 0.98, 0.48, 0.15));
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.muted
            }

            // Realtime Stats Grid
            Grid {
                width: parent.width
                columns: 2
                rowSpacing: 8
                columnSpacing: 12

                StatRow { label: "Ping"; value: NetworkService.pingMs }
                StatRow { label: "Packet Loss"; value: NetworkService.packetLoss }

                StatRow { label: "Receiving"; value: NetworkService.rxRate }
                StatRow { label: "Sending"; value: NetworkService.txRate }

                StatRow { label: "Downloaded"; value: NetworkService.totalDownloaded }
                StatRow { label: "Uploaded"; value: NetworkService.totalUploaded }

                StatRow { label: "IP Address"; value: NetworkService.ipAddress }
                StatRow { label: "Gateway"; value: NetworkService.gateway }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.muted
            }

            // DNS Selection Row
            Column {
                width: parent.width
                spacing: 6

                Text {
                    text: "DNS PROVIDER"
                    color: Theme.darkForeground
                    font.pixelSize: 9
                    font.weight: Font.Bold
                    font.letterSpacing: 1
                }

                Row {
                    width: parent.width
                    spacing: 6

                    Repeater {
                        model: ["DHCP", "Cloudflare", "Google", "Quad9"]

                        delegate: Rectangle {
                            width: (parent.width - 18) / 4
                            height: 28
                            radius: 0
                            color: NetworkService.activeDns === modelData ? Theme.accent : "transparent"
                            border.width: 1
                            border.color: NetworkService.activeDns === modelData ? Theme.accent : Theme.muted

                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                color: NetworkService.activeDns === modelData ? "#FFFFFF" : Theme.foreground
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: NetworkService.setDns(modelData)
                            }
                        }
                    }
                }
            }
        }
    }

    component StatRow: Row {
        property string label: ""
        property string value: ""

        width: 168
        spacing: 6

        Text {
            text: label
            color: Theme.darkForeground
            font.pixelSize: 11
            width: 80
        }

        Text {
            text: value
            color: Theme.foreground
            font.pixelSize: 11
            font.family: Theme.monoFont
            font.weight: Font.DemiBold
            horizontalAlignment: Text.AlignRight
            width: 82
        }
    }
}
