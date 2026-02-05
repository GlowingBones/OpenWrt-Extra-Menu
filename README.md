# OpenWrt LuCI 3rd Party Menu Editor (MEdit)

This adds a **"3rd Party"** top level menu to LuCI and a **Menu Edit** page where you can add, edit, and delete links to local or external web apps. It is designed for OpenWrt 24.x with the modern LuCI (ucode) stack.

You can:
- Add entries pointing to local services (Transmission, PGP tools, etc).
- Add entries pointing to full external URLs (for example wigle uploads).
- Choose whether each entry opens embedded inside LuCI or in its own page.
- Let non technical users manage the menu through a simple page instead of editing Lua.

## Files in this repository

- `thirdparty.lua`  
  LuCI controller that defines the **3rd Party** menu and Menu Editor, and routes per item.

- `embed.htm`  
  LuCI view that embeds a third party app in an iframe under the LuCI header.

- `medit.htm`  
  LuCI view for the Menu Editor page.  
  - Shows current entries in a table.  
  - Clicking a row loads it into the form for editing.  
  - Has a confirmation overlay.  
  - On "Apply changes" it submits and redirects back to `/cgi-bin/luci`.

- `thirdparty_menu.conf.example`  
  Example configuration with a few entries.

- `install.sh`  
  Helper script to copy files into the right locations on the router and restart services.

## Installation

1. Copy the repo to the router

   From your PC, in the directory where you cloned this repo:

   ```sh
   scp -r ./ root@your-openwrt-ip:/root/thirdparty-menu
   ```

   Replace `your-openwrt-ip` with the address of your OpenWrt device.

2. SSH into the router

   ```sh
   ssh root@your-openwrt-ip
   ```

3. Run the installer

   ```sh
   cd /root/thirdparty-menu
   chmod +x install.sh
   ./install.sh
   ```

4. Open LuCI

   - In a browser go to your LuCI interface.
   - You should see a **3rd Party** top level menu.
   - Under it there is **Menu Edit** plus any items defined in `/etc/thirdparty_menu.conf`.

## Using the Menu Editor

Open: `3rd Party -> Menu Edit`.

### Current entries

- The top table shows all configured entries.
- Click any row to prefill the Add / update form with that entry data.
- The "ID to delete" field below is also filled with the clicked ID, so you can delete it easily.

### Add or update an entry

Fields:

- **ID**  
  Short internal name, for example `transmission` or `pgp`.  
  If you reuse an ID, the entry is updated.

- **Label**  
  Display name that appears in the 3rd Party menu.

- **Port**  
  - For local services behind LuCI: `80`, `9091`, etc.  
  - If **Path** is a full URL (starting with `http://` or `https://`), this value is ignored.

- **Path**  
  - Local example: `/transmission/web/` or `/pgp/`.  
  - External example: `https://wigle.net/uploads`.  
  - If it starts with `http://` or `https://` it is treated as a complete external URL.  
  - Otherwise it is treated as a path on the current OpenWrt host.

- **Embed**  
  - Checked: the target opens inside an iframe within LuCI and keeps the OpenWrt header and menu.  
  - Unchecked: the browser navigates directly to the target URL.

Flow:

1. Fill ID, Label, Port, Path, Embed as needed.
2. Press **Save entry**.
3. A confirmation overlay explains that the interface will restart.
4. Click **Apply changes**.
   - The change is submitted.
   - LuCI caches are cleared and rpcd/uhttpd restart in the background.
   - The browser is redirected to `/cgi-bin/luci`.
5. Log back in if needed.  
   The new entry now appears under the **3rd Party** menu.

### Delete an entry

1. Click the row of the entry you want to remove.  
   - The "ID to delete" field is filled automatically.
2. Press **Delete entry**.
3. Confirmation overlay appears, click **Apply changes**.
4. After redirect and login, the item is gone from the 3rd Party menu.

## Configuration file format

Runtime configuration lives in:

```txt
/etc/thirdparty_menu.conf
```

Each non empty line:

```txt
id|Label|Port|Path|Embed
```

- `id`  
  Internal key, must be unique and must not be `medit`.

- `Label`  
  Text shown in the menu.

- `Port`  
  Port number used when `Path` is a local path.

- `Path`  
  - If it starts with `http://` or `https://`, used as is.  
  - Otherwise treated as a local path on the OpenWrt host.

- `Embed`  
  - `0` open direct.  
  - `1` embed inside LuCI.

You can edit this file by hand or manage it from **Menu Edit**. The controller ignores lines that do not match the pipe format, so you can add comment lines if you like.

## Notes

- Tested on OpenWrt x86_64 with modern LuCI.  
- Designed so non technical users can manage external and local tools from one place.  
- If LuCI structure changes in future releases, only `thirdparty.lua` may need adjustment, the config file and views should stay usable.
