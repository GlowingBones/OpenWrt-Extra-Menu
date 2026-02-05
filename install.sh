#!/bin/sh
set -e

BASE_DIR="$(dirname "$0")"

echo "Installing 3rd Party Menu Editor..."

# Create directories
mkdir -p /usr/lib/lua/luci/controller
mkdir -p /usr/lib/lua/luci/view/thirdparty

# Copy controller and views
cp "$BASE_DIR/luci/controller/thirdparty.lua" /usr/lib/lua/luci/controller/thirdparty.lua
cp "$BASE_DIR/luci/view/thirdparty/embed.htm" /usr/lib/lua/luci/view/thirdparty/embed.htm
cp "$BASE_DIR/luci/view/thirdparty/medit.htm" /usr/lib/lua/luci/view/thirdparty/medit.htm

chmod 644 /usr/lib/lua/luci/controller/thirdparty.lua
chmod 644 /usr/lib/lua/luci/view/thirdparty/embed.htm
chmod 644 /usr/lib/lua/luci/view/thirdparty/medit.htm

# Initial config, only if missing
if [ ! -f /etc/thirdparty_menu.conf ]; then
    cp "$BASE_DIR/etc/thirdparty_menu.conf.example" /etc/thirdparty_menu.conf
    chmod 644 /etc/thirdparty_menu.conf
    echo "Created /etc/thirdparty_menu.conf from example."
fi

# Clear LuCI caches and restart web services
rm -f /tmp/luci-indexcache*
rm -rf /tmp/luci-modulecache/* 2>/dev/null || true

/etc/init.d/rpcd restart >/dev/null 2>&1 || true
/etc/init.d/uhttpd restart >/dev/null 2>&1 || true

echo "Done! Open LuCI and look for the '3rd Party' menu."
