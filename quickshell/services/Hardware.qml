pragma Singleton

import Quickshell
import qs.popups
import qs.widgets
import qs.windows
import Quickshell.Io
import qs.popups
import qs.widgets
import qs.windows
import QtQuick

Item {
    id: root

    property real cpuTemperature: 0
    property var cpuTemperatureHistory: []
    property real cpuUsage: 0
    property real cpuFrequency: 0
    property real cpuMaxFrequency: 0
    property int cpuCores: 0

    property real gpuTemperature: 0
    property var gpuTemperatureHistory: []
    property real gpuUsage: 0
    property real gpuPower: 0
    property real gpuPowerLimit: 0
    property real gpuMemoryUsed: 0
    property real gpuMemoryTotal: 0
    property real gpuGraphicsClock: 0
    property real gpuMemoryClock: 0
    property real gpuSmClock: 0
    property real gpuFan: 0
    property real gpuVoltage: -1

    Process {
        id: monitor

        command: [
            "/home/odysseus/.config/quickshell/hardware-monitor/hardware-monitor"
        ]

        running: true

        stdout: SplitParser {
            onRead: data => root.parseLine(data)
        }
    }

    function parseLine(line) {
        const values = {}

        const parts = line.trim().split(" ")

        for (const part of parts) {
            const separator = part.indexOf("=")

            if (separator === -1)
                continue

            const key = part.substring(0, separator)
            const value = part.substring(separator + 1)

            values[key] = Number(value)
        }

        if (values.CPU_TEMP !== undefined) {
            root.cpuTemperature = values.CPU_TEMP
            
            var cpuHist = root.cpuTemperatureHistory
            cpuHist.push(values.CPU_TEMP)
            if (cpuHist.length > 60) cpuHist.shift()
            root.cpuTemperatureHistory = cpuHist
            root.cpuTemperatureHistoryChanged()
        }

        if (values.CPU_USAGE !== undefined)
            root.cpuUsage = values.CPU_USAGE

        if (values.CPU_FREQ !== undefined)
            root.cpuFrequency = values.CPU_FREQ

        if (values.CPU_MAX_FREQ !== undefined)
            root.cpuMaxFrequency = values.CPU_MAX_FREQ

        if (values.CPU_CORES !== undefined)
            root.cpuCores = values.CPU_CORES

        if (values.GPU_TEMP !== undefined) {
            root.gpuTemperature = values.GPU_TEMP
            
            var gpuHist = root.gpuTemperatureHistory
            gpuHist.push(values.GPU_TEMP)
            if (gpuHist.length > 60) gpuHist.shift()
            root.gpuTemperatureHistory = gpuHist
            root.gpuTemperatureHistoryChanged()
        }

        if (values.GPU_USAGE !== undefined)
            root.gpuUsage = values.GPU_USAGE

        if (values.GPU_POWER !== undefined)
            root.gpuPower = values.GPU_POWER

        if (values.GPU_POWER_LIMIT !== undefined)
            root.gpuPowerLimit = values.GPU_POWER_LIMIT

        if (values.GPU_MEM_USED !== undefined)
            root.gpuMemoryUsed = values.GPU_MEM_USED

        if (values.GPU_MEM_TOTAL !== undefined)
            root.gpuMemoryTotal = values.GPU_MEM_TOTAL

        if (values.GPU_GRAPHICS_CLOCK !== undefined)
            root.gpuGraphicsClock = values.GPU_GRAPHICS_CLOCK

        if (values.GPU_MEMORY_CLOCK !== undefined)
            root.gpuMemoryClock = values.GPU_MEMORY_CLOCK

        if (values.GPU_SM_CLOCK !== undefined)
            root.gpuSmClock = values.GPU_SM_CLOCK

        if (values.GPU_FAN !== undefined)
            root.gpuFan = values.GPU_FAN

        if (values.GPU_VOLTAGE !== undefined)
            root.gpuVoltage = values.GPU_VOLTAGE
    }
}
