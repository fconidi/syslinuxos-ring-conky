----------------------------------------------------------------------
-- rc/scale.lua — SysLinuxOS ring conky
--
-- Rileva la risoluzione dello schermo (X11) e ritorna un fattore di
-- scala proporzionale rispetto alla risoluzione di progetto 1920x1080
-- (finestra autorata a 1240x720). A 1920x1080 ritorna 1.0, quindi il
-- layout resta identico all'originale.
--
-- Usa min(W/1920, H/1080) cosi' il conky non sborda mai sul lato piu'
-- stretto e mantiene le proporzioni.
--
-- Override manuale per i test in VM (senza cambiare risoluzione):
--     export CONKY_RING_SCALE=1.5
----------------------------------------------------------------------

local DESIGN_W, DESIGN_H = 1920, 1080
local MIN_SCALE, MAX_SCALE = 0.5, 3.0

local function clamp(v)
    return math.max(MIN_SCALE, math.min(MAX_SCALE, v))
end

-- Override esplicito via variabile d'ambiente (comodo per il debug).
local forced = tonumber(os.getenv("CONKY_RING_SCALE") or "")
if forced then return clamp(forced) end

local function run(cmd)
    local h = io.popen(cmd)
    if not h then return "" end
    local out = h:read("*a") or ""
    h:close()
    return out
end

local function detect()
    local xr = run("xrandr --query 2>/dev/null")
    -- 1) output primario:  "... connected primary 1920x1080+0+0 ..."
    local w, h = xr:match("connected primary (%d+)x(%d+)")
    -- 2) primo output collegato con geometria:  "... connected 1920x1080+0+0 ..."
    if not w then w, h = xr:match("connected[^\n]- (%d+)x(%d+)%+%d") end
    -- 3) modo attivo segnato con '*':  "   1920x1080     60.00*+"
    if not w then w, h = xr:match("(%d+)x(%d+)%s+%d[%d%.]*%*") end
    -- 4) fallback xdpyinfo:  "  dimensions:    1920x1080 pixels"
    if not w then w, h = run("xdpyinfo 2>/dev/null"):match("dimensions:%s+(%d+)x(%d+)") end
    return tonumber(w), tonumber(h)
end

local w, h = detect()
if not (w and h) then return 1.0 end   -- niente X / rilevamento fallito: nessuno scaling

return clamp(math.min(w / DESIGN_W, h / DESIGN_H))
