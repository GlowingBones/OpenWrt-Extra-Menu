LuCI 3rd Party Menu
===================

This adds a top level "3rd Party" menu to LuCI on OpenWrt with two entries:
- Transmission
- PGP Tools

Transmission redirects to the Transmission web interface on port 9091.
PGP Tools redirects to a browserPGP static site under /pgp.

Repository layout
-----------------
Recommended layout for this repo:

  README.md
  usr/
    lib/
      lua/
        luci/
          controller/
            thirdparty.lua

The file in this package is:
  usr/lib/lua/luci/controller/thirdparty.lua

Install on OpenWrt
------------------
1. Copy usr/lib/lua/luci/controller/thirdparty.lua into place on the router:

   scp usr/lib/lua/luci/controller/thirdparty.lua root@<router-ip>:/usr/lib/lua/luci/controller/

2. On the router, clear LuCI cache and restart services:

   rm -f /tmp/luci-indexcache
   rm -rf /tmp/luci-modulecache
   /etc/init.d/rpcd restart
   /etc/init.d/uhttpd restart

3. Log into LuCI in a browser. You should now see:
   - top level menu: 3rd Party
   - under it: Transmission and PGP Tools

Clicking the menu entries:

- 3rd Party -> Transmission
    http://<router-ip>:9091/transmission/web/

- 3rd Party -> PGP Tools
    http://<router-ip>/pgp/

Requirements
------------
- OpenWrt with LuCI installed.
- For Transmission:
  - Transmission daemon and web interface running on the same router, listening on port 9091.
- For PGP Tools:
  - browserPGP static files installed under /www/pgp so that http://<router-ip>/pgp/ already works.

Typical Transmission setup on OpenWrt:

  opkg update
  opkg install transmission-daemon-openssl transmission-web luci-app-transmission
  /etc/init.d/transmission enable
  /etc/init.d/transmission start

How to add more entries
-----------------------
To add more items under 3rd Party, edit thirdparty.lua.

1. Add another entry in function index(), for example:

   entry({"admin", "thirdparty", "zabbix"}, call("action_zabbix"), _("Zabbix"), 30)

2. Define the matching Lua function:

   function action_zabbix()
       local http = require "luci.http"
       local host = http.getenv("HTTP_HOST") or ""
       host = host:gsub(":%d+$", "")

       -- redirect to Zabbix UI on port 8080
       http.redirect("http://" .. host .. ":8080/")
   end

3. Clear LuCI cache and restart services again:

   rm -f /tmp/luci-indexcache
   rm -rf /tmp/luci-modulecache
   /etc/init.d/rpcd restart
   /etc/init.d/uhttpd restart

After that, LuCI will show:
  3rd Party -> Zabbix

License
-------
Add your chosen license text here (for example MIT, BSD, GPL, etc.).
