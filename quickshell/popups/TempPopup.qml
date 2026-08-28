import QtQuick
import Quickshell
import qs.popups
import qs.widgets
import qs.windows
import qs.services

PopupWindow {
    id: root

    property var anchorItem
    property bool hovered: false

    anchor.item: root.anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: 18

    visible: root.hovered && root.anchorItem !== null

    implicitWidth: 320
    implicitHeight: layout.height + 24
    color: "transparent"

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
            id: layout
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 12
            spacing: 12

            // Temperature Graph Section
            Row {
                width: parent.width
                spacing: 12

                Column {
                    spacing: 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: 70

                    Text {
                        text: "Thermals"
                        color: Theme.foreground
                        font.pixelSize: 13
                        font.weight: Font.Bold
                    }

                    Text {
                        text: "CPU & GPU"
                        color: Theme.darkForeground
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        font.letterSpacing: 1
                    }
                }

                // Small Inline Canvas Graph
                Rectangle {
                    width: parent.width - 82
                    height: 32
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
                            target: Hardware
                            function onCpuTemperatureHistoryChanged() { graphCanvas.requestPaint() }
                            function onGpuTemperatureHistoryChanged() { graphCanvas.requestPaint() }
                        }

                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);

                            var cpuHist = Hardware.cpuTemperatureHistory;
                            var gpuHist = Hardware.gpuTemperatureHistory;
                            if (!cpuHist || cpuHist.length < 2) return;

                            var maxVal = 100; // Normal max temp floor
                            for (var i = 0; i < cpuHist.length; i++) {
                                if (cpuHist[i] > maxVal) maxVal = cpuHist[i];
                            }
                            if (gpuHist) {
                                for (var i = 0; i < gpuHist.length; i++) {
                                    if (gpuHist[i] > maxVal) maxVal = gpuHist[i];
                                }
                            }

                            function drawSeries(data, strokeColor, fillColor) {
                                if (!data || data.length === 0) return;
                                ctx.beginPath();
                                var step = width / (60 - 1); // 60 data points

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

                            // CPU in Accent color, GPU in Green/Alternative
                            drawSeries(cpuHist, Theme.accent, Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.20));
                            drawSeries(gpuHist, "#50fa7b", Qt.rgba(0.31, 0.98, 0.48, 0.15));
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.muted
            }

            // Stats Text Block
            Text {
                width: parent.width
                color: Theme.foreground
                font.family: Theme.monoFont
                font.pixelSize: 11
                text:
                    "CPU\n" +
                    "──────────────\n" +
                    "Temperature    " +
                        Hardware.cpuTemperature.toFixed(1) + " °C\n" +
                    "Usage          " +
                        Hardware.cpuUsage.toFixed(1) + " %\n" +
                    "Frequency      " +
                        Hardware.cpuFrequency.toFixed(2) + " GHz\n" +
                    "Maximum        " +
                        Hardware.cpuMaxFrequency.toFixed(2) + " GHz\n" +
                    "Cores          " +
                        Hardware.cpuCores + "\n\n" +

                    "GPU\n" +
                    "──────────────\n" +
                    "Temperature    " +
                        Hardware.gpuTemperature.toFixed(0) + " °C\n" +
                    "Usage          " +
                        Hardware.gpuUsage.toFixed(0) + " %\n" +
                    "Power          " +
                        Hardware.gpuPower.toFixed(1) + " / " +
                        Hardware.gpuPowerLimit.toFixed(0) + " W\n" +
                    "VRAM           " +
                        Hardware.gpuMemoryUsed.toFixed(0) + " / " +
                        Hardware.gpuMemoryTotal.toFixed(0) + " MB\n" +
                    "Graphics       " +
                        Hardware.gpuGraphicsClock.toFixed(0) + " MHz\n" +
                    "Memory         " +
                        Hardware.gpuMemoryClock.toFixed(0) + " MHz\n" +
                    "SM             " +
                        Hardware.gpuSmClock.toFixed(0) + " MHz\n" +
                    "Fan            " +
                        Hardware.gpuFan.toFixed(0) + " %"
            }
        }
    }
}
