require("colors")

--[[
possible values of THEME
    blue dark         blue light
    deepblue dark     deepblue light
    green dark        green light
    emerald dark      emerald light
    yellow  dark      yellow light
    purple dark       purple light
    violet dark       violet light
    crimson dark      crimson light
    maroon dark       maroon light
    pink dark         pink light
    cyan  dark        cyan light
    aquamarine dark   aquamarine light
    monochrome dark   monochrome light
    gruvbox  dark     gruvbox light
    contrast dark     contrast light
]]
THEME = "blue dark"     -- choose one of the above

--[[
waiting time before starting conky
this prevents issues when conky is launched at startup
]]
startup_delay = 5           -- secondes

--[[
change colors when a value exceeds defined thresholds
]]
change_color_on_threshold = true

--[[
CPU Cores (threads really)
number of logical CPUs, detected at boot by check_cpu.sh. 0 draws only the
total usage. Up to 12 threads every thread gets a ring; with more threads
consecutive threads are grouped and each ring shows the group average.
]]
cpu_cores = 4

--[[
The interface is detected from the default route; set CONKY_NET_INTERFACE
when a specific interface must be monitored.
]]
net_interface = os.getenv("CONKY_NET_INTERFACE") or "auto"

--[[
this depends on your own internet speed
]]
download_rate_maximum = 1000     -- kb
upload_rate_maximum   = 1000     -- kb

--[[
This is the default font used in write() if no other is provided
]]
main_font = "Mono"

--[[
the public ip is fetched from the internet.
There is no need to refresh it every second like the other values

WARNING: this feature exploits third party services,
therefore we cannot garantee your privacy if you turn it on
]]
use_public_ip = false
public_ip_refresh_rate = 60     -- secondes

----------------------------------------------

colors = get_color_table(THEME)

if change_color_on_threshold == false then
    colors.warn  = colors.fg
    colors.critic = colors.fg
end

-- threshold variables are used to change the colors of the indicators
-- by using the functions color_frompercent(perc) and color_frompercent_reverse(perc)
threshold_warning          = 60
threshold_critical         = 80
temperature_warning        = 70
temperature_critical       = 85
battery_threshold_warning  = 30
battery_threshold_critical = 18
