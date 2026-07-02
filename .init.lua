-- Global Configuration
HidePath('/usr/share/zoneinfo/')
HidePath('/usr/share/ssl/')
unix = require 'unix'

-- GLOBAL FLEX
local BRAND = "redbean/3.0.0 (Actually Portable Executable)"
ProgramBrand(BRAND)
ProgramHeader("X-Powered-By", "Cosmopolitan Libc")
ProgramHeader("X-Architecture", "Actually Portable Executable")
ProgramHeader("X-Deployed-With", "Kamal 2")
ProgramHeader("X-Host-OS", "Rocky Linux 8")
ProgramHeader("X-Infrastructure", "OVH US Bare Metal")

-- Clean URLs: Parcel content-hashes asset filenames (name.1a2b3c4d.ext),
-- so map every hashed zip asset back to its unhashed name and serve
-- e.g. /resume.pdf from /resume.<whatever this build's hash is>.pdf.
local clean_urls
local function ResolveCleanUrl(path)
    if not clean_urls then
        clean_urls = {}
        for _, zpath in ipairs(GetZipPaths()) do
            local clean = zpath:gsub("%.%x%x%x%x%x%x%x%x(%..+)$", "%1")
            if clean ~= zpath and clean_urls[clean] == nil then
                clean_urls[clean] = zpath
            end
        end
    end
    return clean_urls[path]
end

function OnHttpRequest()
    local path = GetPath()
    local host = GetHost()

    -- Safety check for HTTP/1.0 or direct IP access
    if not host then host = "" end

    -- Health Check
    if path == "/up" then
        SetStatus(200)
        SetHeader("Content-Type", "text/plain")
        Write("OK")
        return
    end

    -- DYNAMIC FLEX
    local function apply_dynamic_flex()
        local usage = unix.getrusage()
        local rss_mb = usage:maxrss() / 1024
        SetHeader("X-Running-On", GetHostOs() .. ' / ' .. GetHostIsa())
        SetHeader("X-Cpu-Core", tostring(GetCpuCore()))
        SetHeader('X-Server-RAM-RSS', string.format('%.2f MB', rss_mb))
    end

    -- Serve Assets
    local is_html = path:match("%.html$") or path:match("/$")

    -- Note: Route() always resolves (it generates its own 404), so it
    -- can't be used as a fallthrough test. RoutePath() returns a bool,
    -- but doesn't resolve the root directory index itself. Headers set
    -- before routing are discarded, so flex only after resolution.
    if RoutePath() then
        if is_html then
            apply_dynamic_flex()
        end
        return
    end

    if path:sub(-1) == "/" and RoutePath(path .. "index.html") then
        apply_dynamic_flex()
        return
    end

    -- Unhashed asset names fall through RoutePath(); serve the hashed asset
    local hashed = ResolveCleanUrl(path)
    if hashed then
        ServeAsset(hashed)
        return
    end

    -- 404 Not Found
    SetStatus(404)
    SetHeader("Content-Type", "text/html; charset=utf-8")

    if is_html then
        apply_dynamic_flex()
    end

    Write([[
        <!doctype html>
        <title>404 Not Found</title>
        <style>body{font-family:system-ui;padding:2rem;line-height:1.5;text-align:center}</style>
        <h1>404 Not Found</h1>
        <p>The page you are looking for does not exist. <a href="https://]] .. host .. [[">Go to home page?</a></p>
        <hr>
        <p><small>]] .. BRAND .. [[</small></p>
    ]])
end