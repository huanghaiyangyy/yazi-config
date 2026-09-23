require("yaziline"):setup {
	separator_style = "curvy",
	select_symbol = "",
	yank_symbol = "",
	filename_max_length = 24, -- trim when filename > 24
	filename_trim_length = 6 -- trim 6 chars from both ends
}
require("starship"):setup {
	config_file = "~/.config/yazi/starship.toml",
}
require("git"):setup {}

Status:children_add(function()
	local h = cx.active.current.hovered
	if h == nil or ya.target_family() ~= "unix" then
		return ui.Line {}
	end

	return ui.Line {
		ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
		ui.Span(":"),
		ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
		ui.Span(" "),
	}
end, 500, Status.RIGHT)

-- 状态栏实时显示当前排序模式与显示模式 (Linemode)
Status:children_add(function()
	local pref = cx.active.pref
	if not pref then
		return ui.Span("")
	end

	local sort = tostring(pref.sort_by or "natural")
	local rev = pref.sort_reverse and "↓" or "↑"
	local icon = "󰒺"
	if sort == "mtime" or sort == "btime" then
		icon = "󱪺"
	elseif sort == "size" then
		icon = "󰉍"
	elseif sort == "extension" then
		icon = "󰈔"
	end

	local text = string.format(" %s %s %s ", icon, sort, rev)
	if pref.linemode and tostring(pref.linemode) ~= "none" then
		text = text .. string.format("[%s] ", tostring(pref.linemode))
	end

	return ui.Span(text):style(ui.Style():fg("#bd93f9"):bold())
end, 600, Status.RIGHT)

-- ── 状态栏：当前目录 Git 分支指示 ─────────────────────────────────────
local function get_git_branch(cwd)
	if not cwd or cwd == "" then return nil end
	local path = cwd
	while path and path ~= "" and path ~= "/" do
		local head_path = path .. "/.git/HEAD"
		local f = io.open(head_path, "r")
		if f then
			local content = f:read("*l") or ""
			f:close()
			local branch = content:match("^ref: refs/heads/(.+)$")
			if branch then
				return branch
			elseif #content >= 7 then
				return content:sub(1, 7)
			end
		end
		local parent = path:match("^(.+)/[^/]+$")
		if not parent or parent == path then break end
		path = parent
	end
	return nil
end

Status:children_add(function()
	local cwd = tostring(cx.active.current.cwd)
	local branch = get_git_branch(cwd)
	if branch then
		return ui.Span("  " .. branch .. " "):style(ui.Style():fg("#50fa7b"):bold())
	end
	return ui.Span("")
end, 300, Status.LEFT)

-- ── 状态栏：选中图片实时解析并显示分辨率 (零子进程开销，置于左下角文件名后) ─
local function get_image_info(path)
	local f = io.open(path, "rb")
	if not f then return nil end
	local head = f:read(4096)
	f:close()
	if not head or #head < 24 then return nil end

	-- PNG
	if head:sub(1, 8) == "\137PNG\r\n\26\n" and #head >= 24 then
		local w = head:byte(17) * 16777216 + head:byte(18) * 65536 + head:byte(19) * 256 + head:byte(20)
		local h = head:byte(21) * 16777216 + head:byte(22) * 65536 + head:byte(23) * 256 + head:byte(24)
		return string.format("%dx%d", w, h)
	end

	-- GIF
	if head:sub(1, 3) == "GIF" and #head >= 10 then
		local w = head:byte(7) + head:byte(8) * 256
		local h = head:byte(9) + head:byte(10) * 256
		return string.format("%dx%d", w, h)
	end

	-- JPEG
	if head:byte(1) == 0xFF and head:byte(2) == 0xD8 then
		local pos = 3
		while pos + 8 <= #head do
			if head:byte(pos) ~= 0xFF then
				pos = pos + 1
			else
				local marker = head:byte(pos + 1)
				if (marker >= 0xC0 and marker <= 0xC3) or (marker >= 0xC5 and marker <= 0xC7) or (marker >= 0xC9 and marker <= 0xCB) or (marker >= 0xCD and marker <= 0xCF) then
					local h = head:byte(pos + 5) * 256 + head:byte(pos + 6)
					local w = head:byte(pos + 7) * 256 + head:byte(pos + 8)
					return string.format("%dx%d", w, h)
				elseif marker == 0xDA or marker == 0xD9 then
					break
				else
					local len = head:byte(pos + 2) * 256 + head:byte(pos + 3)
					pos = pos + 2 + len
				end
			end
		end
	end

	return nil
end

Status:children_add(function()
	local h = cx.active.current.hovered
	if h and not h.cha.is_dir then
		local name = h.name or tostring(h.url)
		local ext = name:match("%.([^%.]+)$")
		ext = ext and ext:lower() or ""
		if ext == "png" or ext == "jpg" or ext == "jpeg" or ext == "gif" or ext == "webp" then
			local res = get_image_info(tostring(h.url))
			if res then
				return ui.Span(" [ " .. res .. " ] "):style(ui.Style():fg("#50fa7b"):bold())
			end
		end
	end
	return ui.Span("")
end, 3500, Status.LEFT)

-- yamb: Ubuntu 收藏夹式快速跳转 (已导入 GTK 书签)
local yamb_bookmarks = {}
local home = os.getenv("HOME")
local sep = package.config:sub(1,1)
local function add_bookmark(tag, path, key) table.insert(yamb_bookmarks, { tag = tag, path = path, key = key }) end
add_bookmark("HOME", home .. sep, "h")
add_bookmark("Pictures", home .. sep .. "Pictures" .. sep, "p")
add_bookmark("Videos", home .. sep .. "Videos" .. sep, "v")
add_bookmark("Obsidian", home .. sep .. "Documents"..sep.."Obsidian_Vault" .. sep, "o")
add_bookmark("sentry_algo", home .. sep .. "Documents"..sep.."sentry_algo" .. sep, "s")
add_bookmark("fawvw_apa", home .. sep .. "fawvw_apa_env" .. sep, "f")
add_bookmark("nexus_x86", home .. sep .. "nexus_x86" .. sep, "n")
add_bookmark("ws", home .. sep .. "ws" .. sep, "w")
add_bookmark("IMG_PROC", home .. sep .. "IMG_PROC" .. sep, "i")
-- 如需更多，参考 ~/.config/gtk-3.0/bookmarks 自动导入
require("yamb"):setup {
	bookmarks = yamb_bookmarks,
	cli = "fzf",
	jump_notify = true,
	keys = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
	path = home .. "/.config/yazi/bookmark",
}

require("bookmarks"):setup {
	last_directory = { enable = false, persist = false, mode = "dir" },
	persist = "none", -- "none" | "all" | "vim" (仅 A-Z 持久化)
	desc_format = "full", -- "full" | "parent"
	file_pick_mode = "hover", -- "hover" | "parent"
	custom_desc_input = false,
	show_keys = false,
	notify = {
		enable = false,
		timeout = 1,
		message = {
			new = "New bookmark '<key>' -> '<folder>'",
			delete = "Deleted bookmark in '<key>'",
			delete_all = "Deleted all bookmarks",
		},
	},
}

-- ── bunny.yazi (带按键提示的哪吒式书签面板) ───────────────────────────
require("bunny"):setup({
	hops = {
		-- 专有项目与核心工作目录
		{ key = "s", path = "~/Documents/sentry_algo", desc = "sentry_algo" },
		{ key = "a", path = "~/fawvw_apa_env/apa_docs/自动泊车", desc = "apa_docs/自动泊车" },
		{ key = "j", path = "~/fawvw_apa_env/J02泊车项目资料", desc = "fawvw_apa_env/J02项目资料" },
		{ key = "f", path = "~/fawvw_apa_env", desc = "fawvw_apa_env" },
		{ key = "o", path = "~/Documents/Obsidian_Vault", desc = "Obsidian_Vault" },

		-- 常用系统目录
		{ key = "h", path = "~", desc = "Home (~)" },
		{ key = "m", path = "/media/huang", desc = "/media/huang (外挂盘)" },
		{ key = "/", path = "/", desc = "Root (/)" },
	},
	desc_strategy = "path",
	ephemeral = true, -- 允许按 Enter 动态创建临时书签
	tabs = true,      -- 允许按数字跳到其他打开的 Tab
	notify = true,    -- 跳转后右下角通知提示
	fuzzy_cmd = "fzf",
})

-- ── keep-preferences.yazi (独立记忆每个目录的排序与显示偏好) ─────────
require("keep-preferences"):setup({
	path_preferences = {
		{
			-- 下载与备份资料目录：默认按最新修改时间排序，并显示修改时间
			path = "Downloads",
			defaults = {
				sort_by = "mtime",
				sort_reverse = true,
				linemode = "mtime",
			},
		},
		{
			path = "huang_bk",
			defaults = {
				sort_by = "mtime",
				sort_reverse = true,
				linemode = "mtime",
			},
		},
	},
})

-- ── linemode-plus.yazi (同时显示文件大小与修改时间，智能折叠当天日期) ─────
require("linemode-plus"):setup {
	date_mode = "custom",
	custom = {
		order = { "year", "month", "day" },
		separator = "-",
		year_digits = 2, -- 短年份（如 26-03-24），节省文件名横向显示空间
	},
}

-- ── zoxide (进入目录时自动累积历史访问频次与时间权重) ─────────────────
require("zoxide"):setup {
	update_db = true,
}


