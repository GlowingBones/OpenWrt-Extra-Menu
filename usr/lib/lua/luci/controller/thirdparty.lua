module("luci.controller.thirdparty", package.seeall)

local CONF = "/etc/thirdparty_menu.conf"

-- Clear LuCI caches and schedule daemon restarts in background
local function flush_cache()
    -- clear any index and module caches on disk
    os.execute("rm -f /tmp/luci-indexcache*")
    os.execute("rm -rf /tmp/luci-modulecache/* 2>/dev/null || true")

    -- restart rpcd and uhttpd in the background after a short delay
    os.execute("(sleep 1; /etc/init.d/rpcd restart >/dev/null 2>&1; /etc/init.d/uhttpd restart >/dev/null 2>&1) &")
end

local function read_items()
    local items = {}
    local f = io.open(CONF, "r")
    if not f then
        return items
    end

    for line in f:lines() do
        if line ~= "" then
            local id, label, port, path, embed =
                line:match("^([^|]+)|([^|]+)|([^|]+)|([^|]+)|([^|]+)$")

            -- backwards compatible with older 4 field lines
            if not id then
                id, label, port, path =
                    line:match("^([^|]+)|([^|]+)|([^|]+)|([^|]+)$")
                embed = "0"
            end

            if id and id ~= "" and id ~= "medit" then
                table.insert(items, {
                    id    = id,
                    label = label or id,
                    port  = port  or "80",
                    path  = path  or "/",
                    embed = embed or "0"
                })
            end
        end
    end

    f:close()
    return items
end

local function write_items(items)
    local f = io.open(CONF, "w")
    if not f then
        return
    end

    for _, it in ipairs(items) do
        local id = it.id or ""
        if id ~= "" and id ~= "medit" then
            local label = it.label or id
            local port  = it.port  or "80"
            local path  = it.path  or "/"
            local embed = it.embed or "0"
            f:write(string.format("%s|%s|%s|%s|%s
",
                id, label, port, path, embed))
        end
    end

    f:close()
end

local function build_url(host, port, path)
    if not path or path == "" then
        path = "/"
    end

    -- full external URL
    if path:match("^https?://") then
        return path
    end

    if path:sub(1,1) ~= "/" then
        path = "/" .. path
    end

    if port and port ~= "" and port ~= "80" then
        return "http://" .. host .. ":" .. port .. path
    else
        return "http://" .. host .. path
    end
end

local function redirect_to(host, port, path)
    local http = require "luci.http"
    local url = build_url(host, port, path)
    http.redirect(url)
end

function index()
    local root = entry({"admin", "thirdparty"}, firstchild(), _("3rd Party"), 80)
    root.dependent = false

    entry({"admin", "thirdparty", "medit"}, call("action_medit"), _("Menu Edit"), 5)

    local items = read_items()
    local order = 10

    for _, it in ipairs(items) do
        entry({"admin", "thirdparty", it.id}, call("action_item", it.id), it.label, order)
        order = order + 10
    end
end

function action_item(id)
    local http = require "luci.http"
    local tpl  = require "luci.template"

    local host = http.getenv("HTTP_HOST") or ""
    host = host:gsub(":%d+$", "")

    local items = read_items()
    local item

    for _, it in ipairs(items) do
        if it.id == id then
            item = it
            break
        end
    end

    if not item then
        http.status(404, "Not Found")
        http.write("Unknown 3rd Party item: " .. id)
        return
    end

    local embed = tostring(item.embed or "0")
    if embed == "1" or embed == "true" then
        local url = build_url(host, item.port or "80", item.path or "/")
        tpl.render("thirdparty/embed", {
            item = item,
            url  = url
        })
    else
        redirect_to(host, item.port or "80", item.path or "/")
    end
end

function action_medit()
    local http = require "luci.http"
    local tpl  = require "luci.template"

    local action = http.formvalue("action")
    local msg
    local items = read_items()

    if action == "add" then
        local id    = http.formvalue("id")    or ""
        local label = http.formvalue("label") or ""
        local port  = http.formvalue("port")  or "80"
        local path  = http.formvalue("path")  or "/"
        local embed = http.formvalue("embed") or "0"

        if embed ~= "1" then
            embed = "0"
        end

        if id ~= "" and label ~= "" then
            local newitems = {}
            for _, it in ipairs(items) do
                if it.id ~= id then
                    table.insert(newitems, it)
                end
            end
            table.insert(newitems, {
                id    = id,
                label = label,
                port  = port,
                path  = path,
                embed = embed
            })
            write_items(newitems)
            flush_cache()
            items = newitems
            msg = string.format("Saved entry '%s'.", id)
        else
            msg = "ID and Label are required."
        end
    elseif action == "delete" then
        local id = http.formvalue("id") or ""
        if id ~= "" then
            local newitems = {}
            local found = false
            for _, it in ipairs(items) do
                if it.id ~= id then
                    table.insert(newitems, it)
                else
                    found = true
                end
            end
            write_items(newitems)
            flush_cache()
            items = newitems
            if found then
                msg = string.format("Deleted '%s'.", id)
            else
                msg = string.format("ID '%s' not found.", id)
            end
        else
            msg = "ID is required to delete."
        end
    end

    items = read_items()

    tpl.render("thirdparty/medit", {
        items = items,
        msg   = msg
    })
end
