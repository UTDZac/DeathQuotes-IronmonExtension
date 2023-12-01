local function DeathQuotes()
	local self = {}
	-- Define descriptive attributes of the custom extension that are displayed on the Tracker settings
	self.version = "1.0"
	self.name = "Death Quotes"
	self.author = "UTDZac"
	self.description = "Let's you change the death quotes that appear on the Game Over screen."
	self.github = "UTDZac/DeathQuotes-IronmonExtension"
	self.url = string.format("https://github.com/%s", self.github)

	local QUOTES_FILENAME = "DeathQuotesList.json"
	local NEWLINE = "\r\n"
	self.DefaultQuotes = {}

	function self.getFilepathForQuotes()
		return FileManager.getCustomFolderPath() .. QUOTES_FILENAME
	end
	function self.getQuotesFromFile()
		local filepath = self.getFilepathForQuotes()
		if not filepath then
			return {}
		end
		return FileManager.decodeJsonFile(filepath) or {}
	end
	---@param quotes table
	function self.saveQuotesToFile(quotes)
		local filepath = self.getFilepathForQuotes()
		if not filepath then
			return
		end
		FileManager.encodeToJsonFile(filepath, quotes or {})
	end

	function self.openPopup()
		local x, y, w, h, lineHeight = 20, 15, 600, 405, 20
		local bottomPadding = 115
		local form = Utils.createBizhawkForm("Edit Death Quotes", w, h, 80, 20)

		forms.label(form, "Edit existing quotes or add new ones; one per line:", x, y, w - 40, lineHeight)
		y = y + 20

		local quotesAsText = table.concat(Resources.GameOverScreenQuotes or {}, NEWLINE)
		local quotesTextBox = forms.textbox(form, quotesAsText, w - 40, h - bottomPadding, nil, x - 1, y, true, true, "Vertical")
		y = y + (h - bottomPadding) + 10

		forms.button(form, Resources.AllScreens.Save, function()
			local quotes = Utils.split(forms.gettext(quotesTextBox) or "", NEWLINE, true) or {}
			Resources.GameOverScreenQuotes = {}
			FileManager.copyTable(quotes, Resources.GameOverScreenQuotes)
			self.saveQuotesToFile(quotes)
			Utils.closeBizhawkForm(form)
		end, x + 115, y)
		forms.button(form, "(Default)", function()
			if self.DefaultQuotes and #self.DefaultQuotes > 0 then
				forms.settext(quotesTextBox, table.concat(self.DefaultQuotes, NEWLINE))
			end
		end, x + 225, y)
		forms.button(form, Resources.AllScreens.Cancel, function()
			Utils.closeBizhawkForm(form)
		end, x + 335, y)
	end


	-- EXTENSION FUNCTIONS
	-- Executed when the user clicks the "Check for Updates" button while viewing the extension details within the Tracker's UI
	function self.checkForUpdates()
		local versionCheckUrl = string.format("https://api.github.com/repos/%s/releases/latest", self.github)
		local versionResponsePattern = '"tag_name":%s+"%w+(%d+%.%d+)"' -- matches "1.0" in "tag_name": "v1.0"
		local downloadUrl = string.format("https://github.com/%s/releases/latest", self.github)
		local compareFunc = function(a, b) return a ~= b and not Utils.isNewerVersion(a, b) end -- if current version is *older* than online version
		local isUpdateAvailable = Utils.checkForVersionUpdate(versionCheckUrl, self.version, versionResponsePattern, compareFunc)
		return isUpdateAvailable, downloadUrl
	end

	-- Executed when the user clicks the "Options" button while viewing the extension details within the Tracker's UI
	function self.configureOptions()
		self.openPopup()
	end

	-- Executed only once: When the extension is enabled by the user, and/or when the Tracker first starts up, after it loads all other required files and code
	function self.startup()
		self.DefaultQuotes = {}
		FileManager.copyTable(Resources.GameOverScreenQuotes, self.DefaultQuotes)

		if FileManager.fileExists(self.getFilepathForQuotes()) then
			local quotes = self.getQuotesFromFile()
			Resources.GameOverScreenQuotes = {}
			FileManager.copyTable(quotes, Resources.GameOverScreenQuotes)
		end
	end

	-- Executed only once: When the extension is disabled by the user, necessary to undo any customizations, if able
	function self.unload()
		if self.DefaultQuotes and #self.DefaultQuotes > 0 then
			Resources.GameOverScreenQuotes = {}
			FileManager.copyTable(self.DefaultQuotes, Resources.GameOverScreenQuotes)
		end
	end

	return self
end
return DeathQuotes