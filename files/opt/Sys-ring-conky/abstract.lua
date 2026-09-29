----------------------------------
-- Author:      Zineddine SAIBI
-- Software:    Namoudaj Conky
-- Type:        Template for Conky
-- Version:     0.5
-- License:     GPL-3.0
-- Repository:  https://www.github.com/SZinedine/namoudaj-conky
----------------------------------

require("cairo")
require("cairo_xlib")
require("imlib2")
require("settings")

---@alias font_slant_t
---| "CAIRO_FONT_SLANT_NORMAL"
---| "CAIRO_FONT_SLANT_ITALIC"
---| "CAIRO_FONT_SLANT_OBLIQUE"


---@alias font_weight_t
---| "CAIRO_FONT_WEIGHT_NORMAL"
---| "CAIRO_FONT_WEIGHT_BOLD"


---place an image on the screen
---@param x number
---@param y number
---@param file string
function image(x, y, file)
    if file == nil then
        return
    end

    local show = imlib_load_image(file)
    if show == nil then return end

    imlib_context_set_image(show)
    imlib_render_image_on_drawable(x, y)
    imlib_free_image()
    show = nil
end


---draw a line
--
---@param startx number
---@param starty number
---@param endx   number
---@param endy   number
---@param thick  number
---@param color  string
---@param alpha  number
--
function line(startx, starty, endx, endy, thick, color, alpha)
    cairo_set_line_width(cr, thick)
    cairo_set_line_cap (cr, CAIRO_LINE_CAP_BUTT)
    cairo_set_source_rgba(cr, color_convert(color, alpha))
    cairo_move_to(cr, startx, starty)
    cairo_line_to(cr, endx, endy)
    cairo_stroke(cr)
end


---draw a clockwise ring
---@param x           number
---@param y           number
---@param radius      number
---@param thickness   number
---@param angle_begin number
---@param angle_end   number
---@param value_str   string
---@param max_value   number
---@param fg_color    string
function ring_clockwise(x, y, radius, thickness, angle_begin, angle_end, value_str, max_value, fg_color)
    local value = tonumber(value_str)
    if value > max_value then value = max_value end

    angle_begin = angle_begin * (2 * math.pi / 360) - (math.pi / 2)
    angle_end   = angle_end   * (2 * math.pi / 360) - (math.pi / 2)
    local progress = (value / max_value) * (angle_end - angle_begin)

    cairo_set_line_width(cr, thickness)
    cairo_set_source_rgba(cr, color_convert(colors.bg, colors.bg_alpha))
    cairo_arc(cr, x, y, radius, angle_begin, angle_end)
    cairo_stroke(cr)

    cairo_set_line_width(cr, thickness)
    cairo_set_source_rgba(cr, color_convert(fg_color, colors.fg_alpha))
    cairo_arc(cr, x, y, radius, angle_begin, angle_begin + progress)
    cairo_stroke(cr)
end


---draw a anticlockwise ring
---@param x           number
---@param y           number
---@param radius      number
---@param thickness   number
---@param angle_begin number
---@param angle_end   number
---@param value_str   string
---@param max_value   number
---@param fg_color    string
function ring_anticlockwise(x, y, radius, thickness, angle_begin, angle_end, value_str, max_value, fg_color)
    local value = tonumber(value_str)
    if value > max_value then value = max_value end

    angle_begin = angle_begin * (2 * math.pi / 360) - (math.pi / 2)
    angle_end   = angle_end   * (2 * math.pi / 360) - (math.pi / 2)
    local progress = (value / max_value) * (angle_end - angle_begin)

    cairo_set_line_width(cr, thickness)
    cairo_set_source_rgba(cr, color_convert(colors.bg, colors.bg_alpha))
    cairo_arc_negative(cr, x, y, radius, angle_begin, angle_end)
    cairo_stroke(cr)

    cairo_set_line_width(cr, thickness)
    cairo_set_source_rgba(cr, color_convert(fg_color, colors.fg_alpha))
    cairo_arc_negative(cr, x, y, radius, angle_begin, angle_begin + progress)
    cairo_stroke(cr)
end


---draw a rectangle from left to right
---@param   x           number
---@param   y           number
---@param   len         number
---@param   thick       number
---@param   value_str   string
---@param   max_value   number
---@param   color       string
function rectangle_leftright(x, y, len, thick, value_str, max_value, color)
    local value = tonumber(value_str)
    if value > max_value then value = max_value end

    cairo_set_source_rgba(cr, color_convert(colors.bg, colors.bg_alpha))
    cairo_rectangle(cr, x, y, len, thick)
    cairo_fill(cr)

    local progress = (len / max_value) * value
    cairo_set_source_rgba(cr, color_convert(color, colors.fg_alpha))
    cairo_rectangle(cr, x, y, progress, thick)
    cairo_fill(cr)
end


---draw a rectangle from left to right
---@param   x           number
---@param   y           number
---@param   len         number
---@param   thick       number
---@param   value_str   string
---@param   max_value   number
---@param   color       string
function rectangle_rightleft(x, y, len, thick, value_str, max_value, color)
    rectangle_leftright(x, y, -len, thick, value_str, max_value, color)
end


---draw a rectangle from left to right
---@param   x           number
---@param   y           number
---@param   len         number
---@param   thick       number
---@param   value_str   string
---@param   max_value   number
---@param   color       string
function rectangle_bottomup(x, y, len, thick, value_str, max_value, color)
    local value = tonumber(value_str)
    if value > max_value then value = max_value end

    cairo_set_source_rgba(cr, color_convert(colors.bg, colors.bg_alpha))
    cairo_rectangle(cr, x, y, thick, -len)
    cairo_fill(cr)
    cairo_set_source_rgba(cr, color_convert(color, colors.fg_alpha))

    local progress = (len / max_value) * value
    cairo_rectangle(cr, x, y, thick, -progress)
    cairo_fill(cr)
end


---draw a rectangle from left to right
---@param   x           number
---@param   y           number
---@param   len         number
---@param   thick       number
---@param   value_str   string
---@param   max_value   number
---@param   color       string
function rectangle_upbottom(x, y, len, thick, value_str, max_value, color)
    rectangle_bottomup(x, y, -len, thick, value_str, max_value, color)
end


---write text
---@param   x           number
---@param   y           number
---@param   text        string
---@param   font_size   number
---@param   color       string
---@param   font_name   string?          -- defaults to main_font defined in settings.lua
---@param   font_slant  font_slant_t?    -- defaults to normal
---@param   font_face   font_weight_t?   -- default to normal
---@param   alpha       number?          -- defaults to 1
function write(x, y, text, font_size, color, font_name, font_slant, font_face, alpha)
    font_name  = font_name or main_font
    alpha      = alpha or 1
    font_slant = font_slant or CAIRO_FONT_SLANT_NORMAL
    font_face  = font_face or CAIRO_FONT_WEIGHT_NORMAL

    cairo_select_font_face(cr, font_name, font_slant, font_face);
    cairo_set_font_size(cr, font_size)
    cairo_set_source_rgba(cr, color_convert(color, alpha))
    cairo_move_to(cr, x, y)
    cairo_show_text(cr, text)
    cairo_stroke(cr)
end


---convenience function to write text in bold
---@param   x           number
---@param   y           number
---@param   text        string
---@param   font_size   number
---@param   color       string
function write_bold(x, y, text, font_size, color)
    write(x, y, text, font_size, color, nil, nil, CAIRO_FONT_WEIGHT_BOLD)
end


---return a process according to its CPU consumption
---@param n any
---@return string
function getProcessN(n)
    local name = parse("top name " .. n)
    local value = parse("top cpu " .. n)
    return name .. value .. "%"
end


---return a process according to its memory consumption
---@param n any
---@return string
function getMemoryN(n)
    local name = parse("top_mem name " .. n)
    local value = parse("top_mem mem_res " .. n)
    return name .. value
end


---write a list of $nb_todisplay processes into the screen
---@param   x              number
---@param   y              number
---@param   interval       number
---@param   nb_todisplay   number
---@param   font_size      number
---@param   color          string
function write_list_proccesses_cpu(x, y, interval, nb_todisplay, font_size, color)
    local array = {}
    for i = 1, nb_todisplay do
        table.insert(array, getProcessN(i))
    end
    write_line_by_line(x, y, interval, array, color, font_size, false)
end


---convenience function to write a list of running processes that consume the most memory
---@param   x              number
---@param   y              number
---@param   interval       number
---@param   nb_todisplay   number
---@param   font_size      number
---@param   color          string
function write_list_proccesses_mem(x, y, interval, nb_todisplay, font_size, color)
    local array = {}
    for i = 1, nb_todisplay do
        table.insert(array, getMemoryN(i))
    end
    write_line_by_line(x, y, interval, array, color, font_size, false)
end


-- write text in multiple lines.
-- the text is contained in `content`
-- each entry is a line separated with `interval`
---@param   x           number
---@param   y           number
---@param   interval    number
---@param   content     table<string>
---@param   color       string
---@param   font_size   number
---@param   bold        boolean?
function write_line_by_line(x, y, interval, content, color, font_size, bold)
    if bold == nil then bold = false end
    local yy = y
    for i in pairs(content) do
        if bold then write_bold(x, yy, content[i], font_size, color)
        else         write(x, yy, content[i], font_size, color)
        end
        yy = yy + interval
    end
end


---convinience function to use conky_parse()
---@param str string
---@return string
function parse(str)
    return conky_parse(string.format("${%s}", str))
end


---return a color according to the provided value (threshold)
---the colors are defined in "settings.lua"
---@param percent number
---@return string
function color_frompercent(percent)
    local  perc = tonumber(percent)
    if not perc then return colors.fg end
    if     perc > threshold_critical then return colors.critic
    elseif perc > threshold_warning  then return colors.warn
    else                                  return colors.fg
    end
end


---used for battery rate or other decreasing values
---for example, change the color when the battery is low
---@param percent number
---@return string
function color_frompercent_reverse(percent)
    local perc = tonumber(percent)
    if not perc then return colors.fg end
    if      perc < battery_threshold_critical then return colors.critic
    elseif  perc < battery_threshold_warning  then return colors.warn
    else                                           return colors.fg
    end
end

---return a color according to a temperature value
---@param temperature number|string
---@return string
function color_fromtemperature(temperature)
    local value = tonumber(temperature)
    if not value then return colors.fg end
    if value >= temperature_critical then return colors.critic end
    if value >= temperature_warning then return colors.warn end
    return colors.fg
end


---input hexadecimal color code, returns its corresponding RGB+Alpha representation
---@param colour string
---@param alpha  number
function color_convert(colour, alpha)
	return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end


-- Variable definitions to avoir repeating the same string concatenations
local function command_output(command)
    local handle = io.popen(command)
    if not handle then return "" end
    local output = handle:read("*a") or ""
    handle:close()
    return output:gsub("^%s+", ""):gsub("%s+$", "")
end

local function detect_network_interface()
    local iface = command_output("ip route get 1.1.1.1 2>/dev/null | awk '/dev/{for (i=1;i<=NF;i++) if ($i == \"dev\") {print $(i+1); exit}}'")
    if iface ~= "" then return iface end
    iface = command_output("ip route show default 2>/dev/null | awk 'NR==1 {print $5}'")
    if iface ~= "" then return iface end
    return "lo"
end

if net_interface == nil or net_interface == "" or net_interface == "auto" then
    net_interface = detect_network_interface()
end

local _download_speed    = "downspeed "               .. net_interface
local _download_speed_kb = "downspeedf "              .. net_interface
local _download_total    = "totaldown "               .. net_interface
local _upload_speed      = "upspeed "                 .. net_interface
local _upload_speed_kb   = "upspeedf "                .. net_interface
local _upload_total      = "totalup "                 .. net_interface
local _ssid              = "wireless_essid "          .. net_interface
local _wifi_signal       = "wireless_link_qual_perc " .. net_interface
local _local_ip          = "addr "                    .. net_interface


-- functions to fetch some important system info
-- for other variables, see: <http://conky.sourceforge.net/variables.html>
function updates()              return parse("updates") end                 --  in seconds
function kernel()               return parse("kernel") end                  --  ex: 5.10.32-1-lts
function system_name()          return parse("sysname") end                 --  ex: Linux
function arch()                 return parse("machine") end                 --  ex: x86_64
function desktops()             return parse("desktop_number") end          --  total number of desktops
function desktop()              return parse("desktop") end                 --  ex: 3 (current desktop)
function desktop_name()         return parse("desktop_name") end            --  ex: Desktop 3
function username()             return parse("user_names") end
function running_threads()      return parse("running_threads") end
function memory()               return parse("mem") end
function memory_percent()       return parse("memperc") end
function memory_max()           return parse("memmax") end
function memory_cached()        return parse("cached") end
function memory_buffers()       return parse("buffers") end
function swap()                 return parse("swap") end
function swap_max()             return parse("swapmax") end
function swap_percent()         return parse("swapperc") end
function download_speed()       return parse(_download_speed) end           --  ex: 930B or 3kb
function download_speed_kb()    return parse(_download_speed_kb) end        --  ex: 0.9  or 3.0
function download_total()       return parse(_download_total) end
function upload_speed()         return parse(_upload_speed) end             --  ex: 930B or 3kb
function upload_speed_kb()      return parse(_upload_speed_kb) end          --  ex: 0.9  or 3.0
function upload_total()         return parse(_upload_total) end
function ssid()                 return parse(_ssid) end
function wifi_signal()          return parse(_wifi_signal) end              --  value in %
function local_ip()             return parse(_local_ip) end
function gw_iface()
    local handle = io.popen("ip route | grep default | awk '{print $5}' | head -n 1")
    if not handle then return "N/A" end
    local result = handle:read("*a")
    handle:close()
    return result:gsub("%s+", "") -- rimuove spazi bianchi e newline
end

function gw_ip()
    local handle = io.popen("ip route | grep default | awk '{print $3}' | head -n 1")
    if not handle then return "N/A" end
    local result = handle:read("*a")
    handle:close()
    return result:gsub("%s+", "") -- rimuove spazi bianchi e newline
end
function uptime()               return parse("uptime") end                  --  ex: 2d 13h 40m

function uptime_short()         return parse("uptime_short") end            --  ex: 2d 13h
function time_hrmin()           return parse("time %R") end                 --  ex: 15:40
function time_hrminsec()        return parse("time %T") end                 --  ex: 15:30:25
function time_hr12minsec()      return parse("time %R") end                 --  ex: 03:30:25 PM
function time_hour24()          return parse("time %H") end                 --  ex: 15
function time_hour12()          return parse("time %I") end                 --  ex: 3
function time_minute()          return parse("time %M") end                 --  ex: 30
function time_second()          return parse("time %S") end                 --  ex: 25
function time_am_pm_upper()     return parse("time %p") end                 --  ex: PM
function time_am_pm_lower()     return parse("time %P") end                 --  ex: pm
function time_day()             return parse("time %A") end                 --  ex: saturday
function time_day_short()       return parse("time %a") end                 --  ex: sat
function time_day_number()      return parse("time %d") end                 --  ex: 1
function time_month()           return parse("time %H") end                 --  ex: january
function time_month_short()     return parse("time %h") end                 --  ex: jan
function time_month_number()    return parse("time %m") end                 --  ex: 1
function time_year()            return parse("time %Y") end                 --  ex: 2021
function time_year_short()      return parse("time %y") end                 --  ex: 21
function utime()                return parse("utime") end                   --  UCT time --  ex: 2021-05-29 17:31:01
function diskio(device)         return parse("diskio " .. device) end       --  device ex: /dev/sda
function diskio_read(device)    return parse("diskio_read " .. device) end
function diskio_write(device)   return parse("diskio_write " .. device) end
function cpu_temperature()
    -- Intel: "Package id 0: +49.0°C", AMD: "Tctl: +52.0°C" / "Tdie: +52.0°C"
    -- grep -o extracts the first "+NN.N" value (current temp, before high/crit)
    local file = io.popen(
        "sensors 2>/dev/null | grep -m1 -E '^(Package id 0|Tctl|Tdie):'" ..
        " | grep -o '+[0-9]*\\.[0-9]*' | head -1 | tr -d '+'")
    if file then
        local result = file:read("*a"):match("^%s*(.-)%s*$")
        file:close()
        if result and result ~= "" and tonumber(result) ~= nil then
            return result
        end
    end
    return parse("acpitemp")   -- fallback
end
function cpu_temperature_sensors()  return cpu_temperature() end            --  kept for compatibility

local hardware_cache = {}

local function cached_command(name, interval, command)
    local now = tonumber(updates()) or 0
    local cached = hardware_cache[name]
    if cached == nil or now - cached.at >= interval then
        hardware_cache[name] = {
            at = now,
            value = command_output(command)
        }
    end
    return hardware_cache[name].value
end

function gpu_temperature()
    return cached_command("gpu_temperature", 5,
        "if command -v nvidia-smi >/dev/null 2>&1; then " ..
        "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -1; " ..
        "else sensors 2>/dev/null | grep -m1 -E 'edge:|junction:' | grep -oE '[0-9]+(\\.[0-9]+)?' | head -1; fi")
end

function gpu_usage()
    return cached_command("gpu_usage", 5,
        "if command -v nvidia-smi >/dev/null 2>&1; then " ..
        "nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -1; " ..
        "elif [ -r /sys/class/drm/card0/device/gpu_busy_percent ]; then " ..
        "cat /sys/class/drm/card0/device/gpu_busy_percent; else printf 'N/A'; fi")
end

function fan_speed()
    return cached_command("fan_speed", 5,
        "if command -v nvidia-smi >/dev/null 2>&1; then " ..
        "nvidia-smi --query-gpu=fan.speed --format=csv,noheader 2>/dev/null | head -1; " ..
        "else sensors 2>/dev/null | grep -m1 -E 'fan[0-9]+:' | awk '{print $2}'; fi")
end


---@param n? number | nil
---@return string | nil
function cpu_percent(n)
    if n == nil or n == 0 or n == "" then return parse("cpu") end
    if n > 0 and n <= 32             then return parse("cpu cpu" .. n)
    else                                  return nil end
end


---@param fs string
---@return string | nil
function fs_used(fs)
    if fs == nil then return nil
    else              return parse("fs_used " .. fs)
    end
end


---@param fs string
---@return string | nil
function fs_used_perc(fs)
    if fs == nil then return nil
    else              return parse("fs_used_perc " .. fs)
    end
end


---@param fs string
---@return string | nil
function fs_size(fs)
    if fs == nil then return nil
    else              return parse("fs_size " .. fs)
    end
end


---@param fs string
---@return string | nil
function fs_free_perc(fs)
    if fs == nil then return nil
    else              return parse("fs_free_perc " .. fs)
    end
end


---@param fs string
---@return string | nil
function fs_free(fs)
    if fs == nil then return nil
    else              return parse("fs_free " .. fs)
    end
end


---@type string | nil holds the IP adress value.
local public_ip = nil


---@return string|nil
function get_public_ip()
    return public_ip
end


---Don't call this function every seconde because it is slow and public IP doesn't change much anyway.
---Warning: if your internet connection is disfunctioning, this function may prevent the whole conky from launching
---@return nil
function update_public_ip()
    if not use_public_ip then
        print("Warning: Turn on the variable use_public_ip (set it to true) in settings.lua before calling the function update_public_ip()")
        public_ip = nil
    end

    -- fetch IP from the internet. other websites: "ifconfig.me/ip", "ident.me", "api.ipify.org"
    local file = io.popen("curl -4fsS --max-time 5 https://api.ipify.org 2>/dev/null")
    if not file then
        public_ip = "No Address"
        return nil
    end

    local output = file:read("*a")
    file:close()
    if output == nil or output == "" or string.len(output:gsub("%s", "")) > 39 then
        public_ip = "No Address"
        return nil
    end

    public_ip = tostring(output)
    return output
end


--[[
    The following will define multiple variables and functions according to the machine where it is ran
    the default value is a nil, so it is necessary to check in case you want to use the second battery.
]]

has_battery         = nil    ---@type boolean  | nil
has_second_battery  = nil    ---@type boolean  | nil
battery1_percent    = nil    ---@type function | nil for the first battery. nil if it doesn't exist
battery2_percent    = nil    ---@type function | nil for the second battery if it exists. nil if it doesn't
battery_percent     = nil    ---@type function | nil returns the value of the battery. adapts to single or double batteries. nil if no battery
battery1_index      = nil    ---@type number   | nil index of the first battery. nil if there is no battery. This is the number that follows 'BAT' ex: 'BAT0'
battery2_index      = nil    ---@type number   | nil index of the second battery. nil if there is no battery or no second battery
initialized_battery = false  ---@type boolean        check if the function `init_battery()` has already been called
discharging_battery = function() return false end  -- check if the battery is discharging or not
local called_init_battery_once = false ---@type boolean  sometimes, conky doesn't detect the battery the first time we require it.


---this function is ran a single time to initialize the variables and functions related to the battery
---check if there is a battery or multiple batteries
---define the functions that return battery values
---define discharging_battery() according to the number of batteries
---NOTE: before calling this function, first check if the variable `initialized_battery` is false.
function init_battery()
    -- Bail out immediately on desktops / VMs that have no battery hardware.
    -- parse("battery_percent BATx") can return "100" on AC-only machines
    -- (AC adapter detected as "full"), causing a spurious battery ring to appear.
    -- Checking /sys first is cheap and reliable.
    local f = io.popen("ls /sys/class/power_supply/BAT*/present 2>/dev/null | head -1")
    local bat_present = f and f:read("*l") or nil
    if f then f:close() end
    if not bat_present or bat_present == "" then
        has_battery = false
        initialized_battery = true
        return
    end

    if not called_init_battery_once then
        called_init_battery_once = true
    else
        initialized_battery = true
    end

    local bat_indexes = {}  ---@type table<number>
    local size = 0          -- how many batteries found

    -- determine how many batteries by calling them (even if it will print out error messages)
    local bt0 = parse("battery_percent BAT0")
    local bt1 = parse("battery_percent BAT1")
    local bt2 = parse("battery_percent BAT2")

    if bt0 ~= nil and bt0 ~= "0" then 
        table.insert(bat_indexes, 0) 
        size = size + 1
    end
    if bt1 ~= nil and bt1 ~= "0" then 
        table.insert(bat_indexes, 1) 
        size = size + 1
    end
    if bt2 ~= nil and bt2 ~= "0" then 
        table.insert(bat_indexes, 2) 
        size = size + 1
    end

    if size == 0 then
        has_battery = false 
        has_second_battery = false 
    elseif size >= 1 then
        has_battery = true
        battery1_index = bat_indexes[1]
        battery1_percent = function() return parse("battery_percent BAT" .. bat_indexes[1]) end

        if size == 1 then
            battery_percent = function()
                return tonumber(battery1_percent())
            end

            discharging_battery = function()
                return string.match(parse("battery BAT" .. battery1_index), "discharging")
            end
        end

        if size >= 2 then
            has_second_battery = true 
            battery2_index = bat_indexes[2]

            ---@return string
            battery2_percent = function()
                return parse("battery_percent BAT" .. bat_indexes[2])
            end

            ---@return integer
            battery_percent = function() 
                local b0 = tonumber(battery1_percent())
                local b1 = tonumber(battery2_percent())
                return math.floor((b0 + b1)/2)
            end

            ---@return boolean
            discharging_battery = function() 
                if string.match(parse("battery BAT" .. battery1_index), "discharging") then return true end
                if string.match(parse("battery BAT" .. battery2_index), "discharging") then return true end
                return false
            end
        end
    end
end
