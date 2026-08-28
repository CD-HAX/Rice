#include <sensors/sensors.h>
#include <nvml.h>

#include <chrono>
#include <cctype>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <thread>
#include <vector>

namespace fs = std::filesystem;


// ============================================================
// CPU SENSOR
// ============================================================

struct CpuSensor {
    const sensors_chip_name* chip = nullptr;
    int subfeatureNumber = -1;
};


bool initializeCpuSensor(CpuSensor& sensor)
{
    const sensors_chip_name* chip = nullptr;
    int chipNr = 0;

    while ((chip = sensors_get_detected_chips(
                nullptr,
                &chipNr)) != nullptr) {

        char chipName[256];

        if (sensors_snprintf_chip_name(
                chipName,
                sizeof(chipName),
                chip) < 0) {
            continue;
        }

        if (std::string(chipName).rfind("k10temp", 0) != 0)
            continue;

        const sensors_feature* feature = nullptr;
        int featureNr = 0;

        while ((feature = sensors_get_features(
                    chip,
                    &featureNr)) != nullptr) {

            if (std::string(feature->name) != "temp1")
                continue;

            const sensors_subfeature* subfeature =
                sensors_get_subfeature(
                    chip,
                    feature,
                    SENSORS_SUBFEATURE_TEMP_INPUT
                );

            if (!subfeature)
                return false;

            sensor.chip = chip;
            sensor.subfeatureNumber =
                subfeature->number;

            return true;
        }
    }

    return false;
}


double readCpuTemperature(const CpuSensor& sensor)
{
    if (!sensor.chip ||
        sensor.subfeatureNumber < 0) {
        return -1.0;
    }

    double temperature = 0.0;

    if (sensors_get_value(
            sensor.chip,
            sensor.subfeatureNumber,
            &temperature) != 0) {
        return -1.0;
    }

    return temperature;
}


// ============================================================
// CPU USAGE
// ============================================================

struct CpuStats {

    unsigned long long user = 0;
    unsigned long long nice = 0;
    unsigned long long system = 0;
    unsigned long long idle = 0;
    unsigned long long iowait = 0;
    unsigned long long irq = 0;
    unsigned long long softirq = 0;
    unsigned long long steal = 0;
};


bool readCpuStats(CpuStats& stats)
{
    std::ifstream file("/proc/stat");

    if (!file.is_open())
        return false;

    std::string line;

    if (!std::getline(file, line))
        return false;

    std::istringstream stream(line);

    std::string cpu;

    stream >> cpu
           >> stats.user
           >> stats.nice
           >> stats.system
           >> stats.idle
           >> stats.iowait
           >> stats.irq
           >> stats.softirq
           >> stats.steal;

    return cpu == "cpu";
}


double calculateCpuUsage(
    const CpuStats& previous,
    const CpuStats& current)
{
    const auto previousIdle =
        previous.idle + previous.iowait;

    const auto currentIdle =
        current.idle + current.iowait;

    const auto previousTotal =
        previous.user +
        previous.nice +
        previous.system +
        previous.idle +
        previous.iowait +
        previous.irq +
        previous.softirq +
        previous.steal;

    const auto currentTotal =
        current.user +
        current.nice +
        current.system +
        current.idle +
        current.iowait +
        current.irq +
        current.softirq +
        current.steal;

    const auto totalDelta =
        currentTotal - previousTotal;

    const auto idleDelta =
        currentIdle - previousIdle;

    if (totalDelta == 0)
        return 0.0;

    return 100.0 *
        (1.0 -
         static_cast<double>(idleDelta) /
         static_cast<double>(totalDelta));
}


// ============================================================
// CPU FREQUENCY
// ============================================================

struct CpuFrequencyPath {
    fs::path currentPath;
    fs::path maximumPath;
};


struct CpuFrequency {

    double averageGHz = -1.0;
    double maximumGHz = -1.0;
    int cpuCount = 0;
};


std::vector<CpuFrequencyPath>
initializeCpuFrequencyPaths()
{
    std::vector<CpuFrequencyPath> paths;

    for (const auto& entry :
         fs::directory_iterator("/sys/devices/system/cpu")) {

        const std::string name =
            entry.path().filename().string();

        if (name.rfind("cpu", 0) != 0 ||
            name.size() <= 3) {
            continue;
        }

        bool numeric = true;

        for (size_t i = 3; i < name.size(); ++i) {

            if (!std::isdigit(
                    static_cast<unsigned char>(name[i]))) {

                numeric = false;
                break;
            }
        }

        if (!numeric)
            continue;

        const fs::path cpufreq =
            entry.path() / "cpufreq";

        const fs::path current =
            cpufreq / "scaling_cur_freq";

        const fs::path maximum =
            cpufreq / "scaling_max_freq";

        if (!fs::exists(current) ||
            !fs::exists(maximum)) {
            continue;
        }

        paths.push_back({
            current,
            maximum
        });
    }

    return paths;
}


bool readFrequency(
    const fs::path& path,
    unsigned long long& value)
{
    std::ifstream file(path);

    if (!file.is_open())
        return false;

    return static_cast<bool>(file >> value);
}


CpuFrequency readCpuFrequency(
    const std::vector<CpuFrequencyPath>& paths)
{
    CpuFrequency result;

    unsigned long long totalCurrent = 0;
    unsigned long long maximum = 0;

    for (const auto& path : paths) {

        unsigned long long current = 0;
        unsigned long long max = 0;

        if (!readFrequency(
                path.currentPath,
                current)) {
            continue;
        }

        if (!readFrequency(
                path.maximumPath,
                max)) {
            continue;
        }

        totalCurrent += current;

        if (max > maximum)
            maximum = max;

        ++result.cpuCount;
    }

    if (result.cpuCount > 0) {

        result.averageGHz =
            (static_cast<double>(totalCurrent) /
             result.cpuCount) /
            1'000'000.0;

        result.maximumGHz =
            static_cast<double>(maximum) /
            1'000'000.0;
    }

    return result;
}


// ============================================================
// NVIDIA GPU
// ============================================================

struct GpuTelemetry {

    double temperature = -1.0;
    double utilization = -1.0;

    double powerWatts = -1.0;
    double powerLimitWatts = -1.0;

    double memoryUsedMB = -1.0;
    double memoryTotalMB = -1.0;

    double graphicsClockMHz = -1.0;
    double memoryClockMHz = -1.0;
    double smClockMHz = -1.0;

    double fanPercent = -1.0;

    double voltage = -1.0;
};


bool nvmlSuccess(nvmlReturn_t result)
{
    return result == NVML_SUCCESS;
}


GpuTelemetry readGpuTelemetry(
    nvmlDevice_t device)
{
    GpuTelemetry gpu;


    // --------------------------------------------------------
    // Temperature
    // --------------------------------------------------------

    nvmlTemperature_v1_t temperature{};

    temperature.version = nvmlTemperature_v1;
    temperature.sensorType = NVML_TEMPERATURE_GPU;

    if (nvmlSuccess(
            nvmlDeviceGetTemperatureV(
                device,
                &temperature))) {

        gpu.temperature =
            static_cast<double>(temperature.temperature);
    }

    // --------------------------------------------------------
    // Utilization
    // --------------------------------------------------------

    nvmlUtilization_t utilization{};

    if (nvmlSuccess(
            nvmlDeviceGetUtilizationRates(
                device,
                &utilization))) {

        gpu.utilization =
            static_cast<double>(utilization.gpu);
    }


    // --------------------------------------------------------
    // Power
    // --------------------------------------------------------

    unsigned int power = 0;

    if (nvmlSuccess(
            nvmlDeviceGetPowerUsage(
                device,
                &power))) {

        gpu.powerWatts =
            static_cast<double>(power) / 1000.0;
    }


    unsigned int powerLimit = 0;

    if (nvmlSuccess(
            nvmlDeviceGetPowerManagementLimit(
                device,
                &powerLimit))) {

        gpu.powerLimitWatts =
            static_cast<double>(powerLimit) / 1000.0;
    }


    // --------------------------------------------------------
    // Memory
    // --------------------------------------------------------

    nvmlMemory_t memory{};

    if (nvmlSuccess(
            nvmlDeviceGetMemoryInfo(
                device,
                &memory))) {

        gpu.memoryUsedMB =
            static_cast<double>(memory.used) /
            (1024.0 * 1024.0);

        gpu.memoryTotalMB =
            static_cast<double>(memory.total) /
            (1024.0 * 1024.0);
    }


    // --------------------------------------------------------
    // Graphics clock
    // --------------------------------------------------------

    unsigned int clock = 0;

    if (nvmlSuccess(
            nvmlDeviceGetClockInfo(
                device,
                NVML_CLOCK_GRAPHICS,
                &clock))) {

        gpu.graphicsClockMHz =
            static_cast<double>(clock);
    }


    // --------------------------------------------------------
    // Memory clock
    // --------------------------------------------------------

    clock = 0;

    if (nvmlSuccess(
            nvmlDeviceGetClockInfo(
                device,
                NVML_CLOCK_MEM,
                &clock))) {

        gpu.memoryClockMHz =
            static_cast<double>(clock);
    }


    // --------------------------------------------------------
    // SM clock
    // --------------------------------------------------------

    clock = 0;

    if (nvmlSuccess(
            nvmlDeviceGetClockInfo(
                device,
                NVML_CLOCK_SM,
                &clock))) {

        gpu.smClockMHz =
            static_cast<double>(clock);
    }


    // --------------------------------------------------------
    // Fan
    // --------------------------------------------------------

    unsigned int fan = 0;

    if (nvmlSuccess(
            nvmlDeviceGetFanSpeed(
                device,
                &fan))) {

        gpu.fanPercent =
            static_cast<double>(fan);
    }


    // --------------------------------------------------------
    // Voltage
    // --------------------------------------------------------

    // NVML does not provide a reliable generic current-voltage
    // API for this GPU. Leave it unavailable rather than
    // manufacturing a value.

    return gpu;
}


// ============================================================
// MAIN
// ============================================================

int main()
{
    // ========================================================
    // INITIALIZATION
    // ========================================================

    if (sensors_init(nullptr) != 0) {

        std::cerr
            << "Failed to initialize lm_sensors\n";

        return 1;
    }


    CpuSensor cpuSensor;

    if (!initializeCpuSensor(cpuSensor)) {

        std::cerr
            << "Warning: k10temp CPU sensor not found\n";
    }


    const auto cpuFrequencyPaths =
        initializeCpuFrequencyPaths();


    // --------------------------------------------------------
    // NVML
    // --------------------------------------------------------

    const nvmlReturn_t nvmlInitResult =
        nvmlInit();

    if (!nvmlSuccess(nvmlInitResult)) {

        std::cerr
            << "Failed to initialize NVML: "
            << nvmlErrorString(nvmlInitResult)
            << '\n';

        sensors_cleanup();

        return 1;
    }


    unsigned int gpuCount = 0;

    const nvmlReturn_t countResult =
        nvmlDeviceGetCount_v2(&gpuCount);

    if (!nvmlSuccess(countResult) ||
        gpuCount == 0) {

        std::cerr
            << "No NVIDIA GPU found\n";

        nvmlShutdown();
        sensors_cleanup();

        return 1;
    }


    nvmlDevice_t gpuDevice{};

    const nvmlReturn_t deviceResult =
        nvmlDeviceGetHandleByIndex_v2(
            0,
            &gpuDevice
        );

    if (!nvmlSuccess(deviceResult)) {

        std::cerr
            << "Failed to get NVIDIA GPU handle: "
            << nvmlErrorString(deviceResult)
            << '\n';

        nvmlShutdown();
        sensors_cleanup();

        return 1;
    }


    // ========================================================
    // INITIAL CPU STATISTICS
    // ========================================================

    CpuStats previousCpuStats;

    if (!readCpuStats(previousCpuStats)) {

        std::cerr
            << "Failed to read /proc/stat\n";

        nvmlShutdown();
        sensors_cleanup();

        return 1;
    }


    // ========================================================
    // MONITORING LOOP
    // ========================================================

    while (true) {

        std::this_thread::sleep_for(
            std::chrono::seconds(1)
        );


        // ----------------------------------------------------
        // CPU usage
        // ----------------------------------------------------

        CpuStats currentCpuStats;

        if (!readCpuStats(currentCpuStats))
            continue;

        const double cpuUsage =
            calculateCpuUsage(
                previousCpuStats,
                currentCpuStats
            );

        previousCpuStats =
            currentCpuStats;


        // ----------------------------------------------------
        // CPU temperature
        // ----------------------------------------------------

        const double cpuTemperature =
            readCpuTemperature(cpuSensor);


        // ----------------------------------------------------
        // CPU frequency
        // ----------------------------------------------------

        const CpuFrequency cpuFrequency =
            readCpuFrequency(cpuFrequencyPaths);


        // ----------------------------------------------------
        // GPU
        // ----------------------------------------------------

        const GpuTelemetry gpu =
            readGpuTelemetry(gpuDevice);


        // ----------------------------------------------------
        // Output
        // ----------------------------------------------------

        std::cout
            << "CPU_TEMP=" << cpuTemperature
            << " CPU_USAGE=" << cpuUsage
            << " CPU_FREQ=" << cpuFrequency.averageGHz
            << " CPU_MAX_FREQ=" << cpuFrequency.maximumGHz
            << " CPU_CORES=" << cpuFrequency.cpuCount

            << " GPU_TEMP=" << gpu.temperature
            << " GPU_USAGE=" << gpu.utilization
            << " GPU_POWER=" << gpu.powerWatts
            << " GPU_POWER_LIMIT=" << gpu.powerLimitWatts
            << " GPU_MEM_USED=" << gpu.memoryUsedMB
            << " GPU_MEM_TOTAL=" << gpu.memoryTotalMB
            << " GPU_GRAPHICS_CLOCK=" << gpu.graphicsClockMHz
            << " GPU_MEMORY_CLOCK=" << gpu.memoryClockMHz
            << " GPU_SM_CLOCK=" << gpu.smClockMHz
            << " GPU_FAN=" << gpu.fanPercent
            << " GPU_VOLTAGE=" << gpu.voltage
            << std::endl;
    }


    nvmlShutdown();
    sensors_cleanup();

    return 0;
}
