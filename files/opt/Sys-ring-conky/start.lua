----------------------------------
-- Author:      Zineddine SAIBI
-- Software:    Auzia Conky
-- Type:        Conky Theme
-- Version:     0.4
-- License:     GPL-3.0
-- repository:  https://www.github.com/SZinedine/auzia-conky
----------------------------------
require("abstract")

local S = require("rc/gauge")
local to_draw_titles = true

-- cpu_cores is the number of logical CPUs. The hand-tuned layouts of rc/gauge.lua
-- cover 0 (total only) and the even counts 2..12; every other count gets a
-- layout computed by build_cpu_layout(), one ring per thread.

-- Rings are spread between an inner and an outer radius (the bounds of the
-- 12-thread layout); thickness follows the spacing, and the percentage label
-- is written every k-th ring so the labels never pile up.
local function build_cpu_layout(n)
    local r_in, r_out = 82, 186
    local layout = {}
    local pitch = n > 1 and (r_out - r_in) / (n - 1) or 0
    local thick = n > 1 and math.max(1.5, math.min(12, pitch * 0.85)) or 30
    local step = math.max(1, math.ceil(9 / math.max(pitch, 0.1)))
    local font = math.max(7, math.min(12, math.floor(math.max(pitch, 6) * step * 1.1)))
    for i = 1, n do
        local r = n > 1 and (r_in + (i - 1) * pitch) or 130
        local text = nil
        -- always label the innermost and the outermost ring, then every step-th
        if i == 1 or i == n or (i - 1) % step == 0 then
            text = { x = 205, y = S.cpu.y - r + 6, post_particle = "%", size = font }
        end
        layout["core" .. i] = { number = i, radius = r, thickness = thick, max_value = 100,
                                begin_angle = 0, end_angle = -260, text = text }
    end
    layout.total = { number = 0, radius = 195, thickness = 2, max_value = 100,
                     begin_angle = 0, end_angle = -260, text = nil }
    layout.temperature = { number = -1, radius = 199, thickness = 2, max_value = 95,
                           begin_angle = 45, end_angle = -300,
                           text = { x = 345, y = 85, post_particle = "°C" } }
    return layout
end

local ncores = nil
local cpu_threads = tonumber(cpu_cores) or 4
if cpu_threads <= 0 then
    ncores = S.cpu.cores._0cores
elseif cpu_threads <= 12 and cpu_threads % 2 == 0 then
    ncores = S.cpu.cores["_" .. cpu_threads .. "cores"]
else
    ncores = build_cpu_layout(cpu_threads)
end


function start()
    draw_cpu()
    draw_memory()
    draw_clock()
    draw_disks()
    draw_battery()
    draw_titles()
    draw_net()
end


function draw_single_cpu_core(coreN)
    local val = nil
    if coreN.number >= 0 then val = cpu_percent(coreN.number)
    else val = cpu_temperature() -- Assuming cpu_temperature() returns the value needed
    end

    local numeric_value = tonumber(val) or 0
    local value_color = coreN.number < 0 and color_fromtemperature(val) or color_frompercent(numeric_value)
    ring_anticlockwise(S.cpu.x, S.cpu.y, coreN.radius, coreN.thickness, coreN.begin_angle, coreN.end_angle, numeric_value, coreN.max_value, value_color)

    if coreN.text ~= nil then
        local label = coreN.number < 0 and "CPU " or ""
        write(coreN.text.x, coreN.text.y, label .. tostring(val) .. coreN.text.post_particle, coreN.text.size or 12, value_color)
    end
end


function draw_cpu()
    for i in pairs(ncores) do
        draw_single_cpu_core(ncores[i])
    end

    write_list_proccesses_cpu(160, 147, 20, 4, 12, colors.text)

    local gpu_temp = gpu_temperature()
    local gpu_temp_text = gpu_temp ~= "" and (gpu_temp .. "°C") or "N/A"
    write(340, 125, "GPU: " .. gpu_temp_text, 11, color_fromtemperature(gpu_temp))
end


function draw_memory()
    local memperc = memory_percent()
    local swpperc = swap_percent()
    local usedmem = string.format("Usage: %s / %s (%s%s)", memory(), memory_max(), memperc, "%")

    ring_clockwise(S.mem.x, S.mem.y, S.mem.radius, 18, 0, 320, memperc, 100, color_frompercent(tonumber(memperc)))
    ring_clockwise(S.mem.x, S.mem.y, S.mem.radius-18, 14, 0, 320, swpperc, 100, color_frompercent(tonumber(swpperc)))
    write(S.mem.text.indicators.x, S.mem.text.indicators.y, "ram: " ..memperc .. "%", 12, colors.text)
    write(S.mem.text.indicators.x, S.mem.text.indicators.y+22, "swap: " ..swpperc .. "%", 12, colors.text)

    write(S.mem.text.process_title.x, S.mem.text.process_title.y, usedmem, 12, colors.text)
    write_list_proccesses_mem(S.mem.text.processes.x, S.mem.text.processes.y, 20, 5, 12, colors.text)
end


function draw_clock()
    local s = time_second()
    local m = time_minute()
    local h = time_hour24()
    local date = string.format("%s, %s %s, %s", time_day_short(), time_month_short(), time_day_number(), time_year())

    ring_clockwise(S.clock.x, S.clock.y, S.clock.radius, S.clock.width/4, 60, 420, s, 59, colors.fg)
    ring_clockwise(S.clock.x, S.clock.y, S.clock.radius+7, S.clock.width/2, -60, 300, m, 59, colors.fg)
    ring_clockwise(S.clock.x, S.clock.y, S.clock.radius+18, S.clock.width, 0, 360, h, 23, colors.fg)

    write_bold(S.clock.hr.x, S.clock.hr.y, h, S.clock.font_height, colors.text)
    write(S.clock.mn.x, S.clock.mn.y, m, S.clock.font_m, colors.text)
    write(S.clock.dt.x, S.clock.dt.y, date, 12, colors.text)
    write(S.clock.ut.x, S.clock.ut.y, "Uptime: " .. uptime_short(), 11, colors.text)
end


-- backing device of a mount without the btrfs [/subvol] suffix, cached (refresh ~60s)
local _src_cache = {}
local function mount_source(path)
    local c = _src_cache[path]
    if c and os.time() - c.t < 60 then return c.v end
    local f = io.popen("findmnt -no SOURCE -T " .. path .. " 2>/dev/null")
    local out = f and f:read("*l") or ""
    if f then f:close() end
    local v = (out:gsub("%[.*%]$", ""))
    _src_cache[path] = { t = os.time(), v = v }
    return v
end

function draw_disks()
    local rt = fs_used_perc("/")
    local hm = fs_used_perc("/home")
    local src_rt, src_hm = mount_source("/"), mount_source("/home")
    -- same filesystem (btrfs subvolumes): / and /home report identical usage
    local shared = src_rt ~= "" and src_rt == src_hm
    local rt_text = string.format("Root: %s / %s (%s)", fs_used("/"), fs_size("/"), fs_free("/"))
    local hm_text = string.format("Home: %s / %s (%s)", fs_used("/home"), fs_size("/home"), fs_free("/home"))
    if shared then
        rt_text = string.format("Root+Home: %s / %s (%s)", fs_used("/"), fs_size("/"), fs_free("/"))
    end

    ring_anticlockwise(S.disk.x, S.disk.y, S.disk.radius, S.disk.thickness, S.disk.begin_angle, S.disk.end_angle, rt, 100, color_frompercent(tonumber(rt)))
    write(S.disk.x+45, S.disk.y-S.disk.radius+10, rt_text, 11, colors.text)
    if not shared then
        ring_anticlockwise(S.disk.x, S.disk.y, S.disk.radius-22, S.disk.thickness, S.disk.begin_angle, S.disk.end_angle, hm, 100, color_frompercent(tonumber(hm)))
        write(S.disk.x+40, S.disk.y-S.disk.radius+35, hm_text, 11, colors.text)
    end

    local dsk_info = {
        "Read:  " .. diskio_read(""),
        "Write: " .. diskio_write(""),
    }
    write_line_by_line(S.disk.x-40, S.disk.y-10, 20, dsk_info, colors.text, 12)

end


function draw_net()
    ring_clockwise(S.net.x, S.net.y, S.net.radius, 15, S.net.begin_angle, S.net.end_angle, download_speed_kb(), download_rate_maximum, colors.fg)
    ring_clockwise(S.net.x, S.net.y, S.net.radius-18, 15, S.net.begin_angle, S.net.end_angle, upload_speed_kb(), upload_rate_maximum, colors.fg)

    write(S.net.indicators.down.x, S.net.indicators.down.y, "▼ ".. download_speed(), 12, colors.text)
    write(S.net.indicators.up.x, S.net.indicators.up.y, "▲ "..upload_speed(), 12, colors.text)

    write(S.net.total.down.x-50, S.net.y, "Total ", 12, colors.text)
    write(S.net.total.down.x, S.net.total.down.y, "▼".. download_total(), 12, colors.text)
    write(S.net.total.up.x, S.net.total.up.y, "▲"..upload_total(), 12, colors.text)

local inf = {}
table.insert(inf, "Interface:      " .. gw_iface())
table.insert(inf, "SSID:           " .. string.sub(ssid(), 0, 15))
table.insert(inf, "Wifi Signal:    " .. wifi_signal() .. "%")
table.insert(inf, "Local IP:       " .. local_ip())
table.insert(inf, "Gateway:        " .. gw_ip())
if use_public_ip then
    if get_public_ip == nil or (updates()%public_ip_refresh_rate) == 0 then
        update_public_ip()
    end
    table.insert(inf, "Public IP:      " .. get_public_ip())
end
write_line_by_line(S.net.x + 180, S.net.y +90, 20, inf, colors.text, 12)
end


function draw_battery()
    if not has_battery then return end
    if not initialized_battery and tonumber(updates()) > startup_delay + 6  then
        init_battery()
    end
    
    -- HO RIDOTTO l'offset Y. Un numero PIÙ PICCOLO mantiene il blocco più in alto.
    local y_offset = 10 
    
    local bat = battery_percent()
    
    -- Anello
    ring_anticlockwise(S.battery.x, S.battery.y + y_offset, S.battery.radius, S.battery.width , S.battery.begin, S.battery.end_, bat, 100, color_frompercent_reverse(tonumber(bat)))
    
    -- Testo Percentuale
    write(S.battery.text.perc.x, S.battery.text.perc.y + y_offset, bat .. "%", 15, colors.text)
    
    -- Testo Titolo ("Battery") - Ora dovrebbe riapparire
    write(S.battery.text.title.x, S.battery.text.title.y + y_offset, "Battery", 15, colors.text)
end


function draw_titles()
    if not to_draw_titles then return end
    write(180, 270, "CPU", 18, colors.text)
    write(325, S.net.y+80, "Internet", 15, colors.text)
    write(S.mem.text.ring_title.x, S.mem.text.ring_title.y, "Memory", 18, colors.text)
    write(S.disk.x+100, S.disk.y-S.disk.radius+130, "Hard Disk", 15, colors.text)
end


function conky_main()
    if conky_window == nil then
        return
    elseif colors == nil then
        io.stderr:write("Fatal Error. Please define a theme")
    end

    local updates_ = tonumber(updates())
    if initialized_battery == false and updates_ > startup_delay  then
        init_battery()
    end

    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable,
                                         conky_window.visual, conky_window.width,
                                         conky_window.height)
    cr = cairo_create(cs)

    -- Auto-scaling proporzionale (vedi rc/scale.lua). A 1920x1080 vale 1.0 (no-op).
    -- SCALE e' definito in conkyrc; il dofile e' un fallback se il global non e'
    -- condiviso. Scalando il context cairo si ridimensionano in modo uniforme
    -- anelli, spessori, posizioni testo e dimensioni dei font.
    local screen_scale = SCALE or dofile("rc/scale.lua")
    cairo_scale(cr, screen_scale, screen_scale)

    start()

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
    cr = nil
end
