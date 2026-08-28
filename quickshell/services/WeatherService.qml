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

    property string location: "BANGALORE"
    property string currentTemp: ""
    property string feelsLike: ""
    property string windSpeed: ""
    property string humidity: ""
    property string weatherIcon: "󰖙"

    property var forecast: [
        { day: "SATURDAY", icon: "󰖕", high: "33°", low: "27°" },
        { day: "SUNDAY", icon: "󰖕", high: "33°", low: "27°" },
        { day: "MONDAY", icon: "󰙾", high: "33°", low: "27°" }
    ]

    property var countryCapitals: ({
        "singapore": "Singapore",
        "japan": "Tokyo",
        "india": "New Delhi",
        "usa": "Washington D.C.",
        "uk": "London",
        "germany": "Berlin",
        "france": "Paris",
        "canada": "Ottawa",
        "australia": "Canberra",
        "india": "New Delhi",
    })

    property Component fetchComp: Component {
        Process {
            id: proc
            stdout: StdioCollector {
                onStreamFinished: service.parseWeather(this.text)
            }
            onExited: proc.destroy()
        }
    }

    property Timer pollTimer: Timer {
        interval: 600000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: service.refreshWeather()
    }

    function updateLocation(newLoc) {
        if (!newLoc || newLoc.trim() === "") return;

        let cleaned = newLoc.trim();
        let lower = cleaned.toLowerCase();

        if (service.countryCapitals[lower]) {
            cleaned = service.countryCapitals[lower];
        }

        service.location = cleaned.toUpperCase();
        service.refreshWeather();
    }

    function refreshWeather() {
        var p = service.fetchComp.createObject(service, {
            command: ["curl", "-s", `https://wttr.in/${encodeURIComponent(service.location)}?format=j1`]
        });
        p.running = true;
    }

    function parseWeather(jsonStr) {
        if (!jsonStr) return;
        try {
            const data = JSON.parse(jsonStr);
            const current = data.current_condition[0];
            const todayWeather = data.weather[0];

            let isDay = true;
            if (todayWeather && todayWeather.astronomy && todayWeather.astronomy[0]) {
                const astro = todayWeather.astronomy[0];
                const obsTimeStr = current.localObsDateTime || "";

                if (obsTimeStr && astro.sunrise && astro.sunset) {
                    const parseMinutes = (time12h) => {
                        const parts = time12h.match(/(\d+):(\d+)\s*(AM|PM)/i);
                        if (!parts) return 0;
                        let h = parseInt(parts[1], 10);
                        const m = parseInt(parts[2], 10);
                        if (parts[3].toUpperCase() === "PM" && h < 12) h += 12;
                        if (parts[3].toUpperCase() === "AM" && h === 12) h = 0;
                        return h * 60 + m;
                    };

                    const obsMatch = obsTimeStr.match(/(\d+):(\d+)\s*(AM|PM)/i);
                    if (obsMatch) {
                        const currentMin = parseMinutes(`${obsMatch[1]}:${obsMatch[2]} ${obsMatch[3]}`);
                        const sunriseMin = parseMinutes(astro.sunrise);
                        const sunsetMin = parseMinutes(astro.sunset);
                        isDay = currentMin >= sunriseMin && currentMin < sunsetMin;
                    }
                }
            }

            service.currentTemp = current.temp_C + "°C";
            service.feelsLike = current.FeelsLikeC + "°C";
            service.windSpeed = current.windspeedKmph + " km/h";
            service.humidity = current.humidity + "%";
            service.weatherIcon = mapCodeToIcon(current.weatherCode, isDay);

            const weatherList = data.weather;
            let newForecast = [];
            const dayNames = ["SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"];

            for (let i = 0; i < Math.min(3, weatherList.length); i++) {
                const dayData = weatherList[i];
                const dateObj = new Date(dayData.date);
                const dayName = dayNames[dateObj.getDay()];

                const hourlyCode = dayData.hourly && dayData.hourly[4] ? dayData.hourly[4].weatherCode : "113";

                newForecast.push({
                    day: dayName,
                    icon: service.mapCodeToIcon(hourlyCode, true),
                    high: dayData.maxtempC + "°",
                    low: dayData.mintempC + "°"
                });
            }
            service.forecast = newForecast;
        } catch (e) {
            console.warn("Failed to parse weather data:", e);
        }
    }

    function mapCodeToIcon(code, isDay) {
        if (code === undefined || code === null) return isDay ? "󰖔" : "󰖙";

        const c = parseInt(code, 10);
        if (isNaN(c)) return isDay ? "󰖔" : "󰖙";

        if (c === 113) return isDay ? "󰖔" : "󰖙";
        if (c === 116) return isDay ? "󰖕" : "󰼱";
        if (c === 119 || c === 122 || c === 143 || c === 248 || c === 260) return "󰖐";
        if ((c >= 176 && c <= 308) || (c >= 353 && c <= 359)) return "󰙾";
        if ((c >= 311 && c <= 377) || (c >= 362 && c <= 371)) return "󰼶";
        if (c >= 386) return "󰙾";

        return isDay ? "󰖔" : "󰖙";
    }
}
