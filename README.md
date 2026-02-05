# OpenWrt Extra Menu

A customizable "3rd Party" menu for LuCI that lets you add links to local services and external web apps without editing Lua code.

## Features

- Adds a **3rd Party** top-level menu to LuCI
- Built-in **Menu Editor** for managing entries through the web interface
- Link to local services (Transmission, Adblock, custom apps)
- Link to external URLs (WiGLE uploads, cloud dashboards, etc.)
- Choose to embed apps inside LuCI or open them directly

## Requirements

- OpenWrt 24.x with modern LuCI (ucode stack)
- SSH access to your router

## Installation

1. Clone the repository to your PC:
   ```sh
   git clone https://github.com/GlowingBones/OpenWrt-Extra-Menu.git
   ```

2. Copy to your router:
   ```sh
   scp -r OpenWrt-Extra-Menu root@<router-ip>:/root/OpenWrt-Extra-Menu
   ```

3. SSH into the router and run the installer:
   ```sh
   ssh root@<router-ip>
   cd /root/OpenWrt-Extra-Menu
   chmod +x install.sh
   ./install.sh
   ```

4. Open LuCI in your browser. You should see a **3rd Party** menu.

## Using the Menu Editor

Navigate to **3rd Party > Menu Edit** in LuCI.

### Adding an Entry

| Field | Description |
|-------|-------------|
| **ID** | Short internal name (e.g., `transmission`) |
| **Label** | Display name shown in the menu |
| **Port** | Port number for local services (ignored for external URLs) |
| **Path** | Local path (`/transmission/web/`) or full URL (`https://example.com`) |
| **Embed** | Check to display inside LuCI, uncheck to open directly |

### Examples

| ID | Label | Port | Path | Embed |
|----|-------|------|------|-------|
| `transmission` | Transmission | 9091 | `/transmission/web/` | No |
| `pgp` | PGP Tools | 80 | `/pgp/` | Yes |
| `wigle` | WiGLE Upload | 80 | `https://wigle.net/uploads` | Yes |

### Editing and Deleting

- Click any row in the table to load it into the form
- Modify fields and click **Save entry** to update
- Use the **Delete entry** button to remove entries

After changes, the interface restarts automatically.

## Configuration File

Menu entries are stored in `/etc/thirdparty_menu.conf`:

```
id|Label|Port|Path|Embed
transmission|Transmission|9091|/transmission/web/|0
pgp|PGP Tools|80|/pgp/|1
```

You can edit this file manually. The Menu Editor reads and writes to this file.

## Repository Structure

```
OpenWrt-Extra-Menu/
├── install.sh                  # Installation script
├── etc/
│   └── thirdparty_menu.conf.example
└── luci/
    ├── controller/
    │   └── thirdparty.lua      # LuCI controller
    └── view/thirdparty/
        ├── embed.htm           # Iframe embed template
        └── medit.htm           # Menu editor page
```

## Uninstall

```sh
rm -f /usr/lib/lua/luci/controller/thirdparty.lua
rm -rf /usr/lib/lua/luci/view/thirdparty
rm -f /etc/thirdparty_menu.conf
rm -f /tmp/luci-indexcache*
rm -rf /tmp/luci-modulecache/*
/etc/init.d/rpcd restart
/etc/init.d/uhttpd restart
```

## License

MIT License - See [LICENSE](LICENSE) for details.
