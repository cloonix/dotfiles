-- Enhanced linemode with better formatting and visual indicators
function Linemode:size_and_mtime()
	local time = math.floor(self._file.cha.mtime or 0)
	local time_str = ""
	
	if time == 0 then
		time_str = ""
	elseif os.date("%Y", time) == os.date("%Y") then
		time_str = "  " .. os.date("%b %d %H:%M", time)
	else
		time_str = "  " .. os.date("%b %d  %Y", time)
	end

	local size = self._file:size()
	local size_str = size and ya.readable_size(size) or "-"
	
	-- Add visual indicator for file size with colors
	local size_icon = ""
	local size_color = "white"
	if size then
		if size > 1024 * 1024 * 100 then -- > 100MB
			size_icon = " "
			size_color = "red"
		elseif size > 1024 * 1024 then -- > 1MB
			size_icon = " "
			size_color = "yellow"
		else
			size_icon = " "
			size_color = "green"
		end
	end
	
	return ui.Line {
		ui.Span(size_icon):fg(size_color),
		ui.Span(" " .. size_str):fg(size_color),
		ui.Span(time_str):fg("blue")
	}
end

-- Enhanced permissions linemode with colored permissions
function Linemode:permissions()
	local perm = self._file.cha:permissions()
	if not perm then
		return ui.Line("")
	end
	
	local spans = {}
	local type_icon = self._file.cha.is_dir and " " or " "
	table.insert(spans, ui.Span(type_icon))
	
	-- User permissions (owner)
	table.insert(spans, ui.Span(perm:sub(1, 3)):fg(perm:match("^r") and "green" or "dark_gray"))
	table.insert(spans, ui.Span(" "))
	-- Group permissions  
	table.insert(spans, ui.Span(perm:sub(4, 6)):fg(perm:match("^...r") and "yellow" or "dark_gray"))
	table.insert(spans, ui.Span(" "))
	-- Other permissions
	table.insert(spans, ui.Span(perm:sub(7, 9)):fg(perm:match("^......r") and "red" or "dark_gray"))
	
	return ui.Line(spans)
end

-- Setup plugins
require("bookmarks"):setup({
	last_directory = { enable = false, persist = true, mode = "dir" },
	persist = "vim",
	desc_format = "parent",
	file_pick_mode = "hover",
	custom_desc_input = false,
	show_keys = true,
	notify = {
		enable = true,  -- Enable notifications for better feedback
		timeout = 2,
		message = {
			new = "Bookmark saved: <key> → <folder>",
			delete = "Bookmark deleted: <key>",
			delete_all = "All bookmarks deleted",
		},
	},
})

require("simple-status"):setup()

require("git"):setup()

require("full-border"):setup({
	type = ui.Border.ROUNDED,  -- Use rounded borders for a modern look
})

-- Enhanced header component with visual flair
function Header:render(area)
	local line = ui.Line {}
	local sp = ui.Span(" ")
	
	-- Current directory icon and path
	local cwd = cx.active.current.cwd
	line = line:push(ui.Span("  "):fg("blue"):bold())
	line = line:push(ui.Span(tostring(cwd)):fg("cyan"):bold())
	line = line:push(sp)
	
	-- File count indicator
	local total = #cx.active.current.files
	local visible = cx.active.current.window.len
	if total > 0 then
		line = line:push(ui.Span(string.format("  %d items", total)):fg("gray"))
	end
	
	-- Selected files indicator
	local selected = #cx.active.selected
	if selected > 0 then
		line = line:push(sp)
		line = line:push(ui.Span(string.format(" %d selected", selected)):fg("magenta"):bold())
	end
	
	return {
		ui.Paragraph(area, { line }),
	}
end

-- Enhanced status bar with more information and visual indicators
function Status:render(area)
	local left = ui.Line {}
	local right = ui.Line {}
	local center = ui.Line {}
	
	-- Left side: mode indicator
	local mode = tostring(cx.active.mode):upper()
	local mode_icon = "󰆽"
	local mode_color = "blue"
	
	if mode == "SELECT" then
		mode_icon = ""
		mode_color = "magenta"
	elseif mode == "UNSET" then
		mode_icon = ""
		mode_color = "yellow"
	end
	
	left = left:push(ui.Span(" " .. mode_icon .. " "):bg(mode_color):fg("black"):bold())
	left = left:push(ui.Span(" "))
	
	-- Center: current file info
	local h = cx.active.current.hovered
	if h then
		local size = h:size()
		local size_str = size and ya.readable_size(size) or ""
		
		center = center:push(ui.Span(" "):fg("white"))
		center = center:push(ui.Span(h.name):fg("white"):bold())
		
		if h.link_to then
			center = center:push(ui.Span(" → "):fg("gray"))
			center = center:push(ui.Span(tostring(h.link_to)):fg("cyan"))
		end
		
		if size_str ~= "" then
			center = center:push(ui.Span(" "):fg("gray"))
			center = center:push(ui.Span(size_str):fg("yellow"))
		end
	end
	
	-- Right side: position indicator and file type
	local cursor = cx.active.current.cursor + 1
	local total = #cx.active.current.files
	local percent = 0
	if total > 0 then
		percent = math.floor((cursor / total) * 100)
	end
	
	right = right:push(ui.Span(string.format(" %d/%d ", cursor, total)):fg("white"))
	right = right:push(ui.Span(string.format(" %d%% ", percent)):bg("blue"):fg("black"):bold())
	
	return {
		ui.Paragraph(area:take_width(20), { left }),
		ui.Paragraph(area:skip_width(20):take_width(area.w - 40), { center }),
		ui.Paragraph(area:skip_width(area.w - 20), { right }),
	}
end
