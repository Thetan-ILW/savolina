local Screen = require("osu_ui.views.Screen")
local Label = require("ui.Label")
local Page = require("svnplug.views.osu.Page")
local TextBox = require("osu_ui.ui.TextBox")
local Button = require("osu_ui.ui.Button")
local Rectangle = require("ui.Rectangle")
local Component = require("ui.Component")
local BackButton = require("osu_ui.ui.BackButton")
local Image = require("ui.Image")

---@class svnplug.osu.SavolinaLoadout : osu.ui.Screen
---@operator call: svnplug.osu.SavolinaLoadout
local View = Screen + {}

function View:keyPressed(event)
	if event[2] == "escape" then
		self:quit()
		return true
	end
end

function View:quit()
	self.scene:transitInScreen("mainMenu")
	self:transitOut()
end

function View:transitIn()
	Screen.transitIn(self)
	self.scene:showOverlay(0.4, 0.5)
end

function View:load()
	self.scene = self:findComponent("scene") ---@cast osu.ui.Scene
	self.width, self.height = self.parent:getDimensions()
	self:getViewport():listenForResize(self)

	self.assets = self.scene.assets
	self.fonts = self.scene.fontManager
	self.popup = self.scene.popupContainer
	self.assets:loadImage("loading")

	self.pages = self:addChild("pages", Component({ width = self.width, height = self.height, z = 0.1 }))
	self.page_count = 0

	self.svn_online_model = self.scene.game.svn_online_model ---@type svnplug.OnlineModel
	self.svn_online_model:listenForStateChanges(self, self.onlineStateUpdated)

	self:addChild("backButton", BackButton({
		y = self.height - 58,
		font = self.fonts:loadFont("Regular", 20),
		text = "back",
		hoverWidth = 93,
		hoverHeight = 58,
		z = 0.9,
		onClick = function ()
			self:quit()
		end,
	}))
end

function View:getPageName()
	self.page_count = self.page_count + 1
	return tostring(self.page_count)
end

function View:kill()
	self.svn_online_model:stopListeningForStateChanges(self)
end

---@param state svnplug.OnlineState
function View:onlineStateUpdated(state)
	self:transitOutPages()

	if state == "connecting" then
		self:pushConnectingPage()
	elseif state == "reconnecting" then
		self:pushReconnectingPage()
	elseif state == "auth_required" then
		self:pushLoginPage()
	elseif state == "ready" then
		self:pushLoadoutPage()
	end
end

function View:pushReconnectingPage()
	local page = self.pages:addChild(self:getPageName(), Page())
	page:addChild("text", Label({
		boxWidth = self.width,
		boxHeight = self.height,
		alignX = "center",
		alignY = "center",
		font = self.fonts:loadFont("Bold", 52),
		text = "Failed to connect. Reconnecting..."
	}))
end

function View:pushLoginPage()
	local page = self.pages:addChild(self:getPageName(), Page())

	local c = page:addChild("container", Component({
		x = self.width / 2,
		y = self.height / 2,
		origin = { x = 0.5, y = 0.5 },
		z = 0.1
	}))

	c:addChild("text", Label({
		y = 0,
		boxWidth = self.width,
		alignX = "center",
		font = self.fonts:loadFont("Bold", 32),
		text = "Log in",
		z = 0.1,
	}))

	c:addChild("emailLabel", Label({
		text = "Email",
		font = self.fonts:loadFont("Regular", 20),
		x = self.width / 2 - (400 / 2) + 5,
		y = 50,
	}))
	local email_textbox = c:addChild("email", TextBox({
		x = self.width / 2,
		y = 80,
		origin = { x = 0.5 },
		width = 400,
		height = 34,
		font = self.fonts:loadFont("Regular", 24),
	}))

	c:addChild("passwordLabel", Label({
		text = "Password",
		font = self.fonts:loadFont("Regular", 20),
		x = self.width / 2 - (400 / 2) + 5,
		y = 130,
	}))
	local password_textbox = c:addChild("password", TextBox({
		x = self.width / 2,
		y = 160,
		origin = { x = 0.5 },
		width = 400,
		height = 34,
		password = true,
		font = self.fonts:loadFont("Regular", 24),
	}))

	c:addChild("loginButton", Button({
		x = self.width / 2,
		y = 220,
		origin = { x = 0.5 },
		width = 400,
		height = 45,
		label = "Log in",
		font = self.fonts:loadFont("Regular", 24),
		color = { 0.05, 0.52, 0.65, 1 },
		onClick = function()
			self:transitOutPages()
			self:pushLoadingPage("Please wait...")
			self.svn_online_model:login(email_textbox.input, password_textbox.input)
		end
	}))

	c:addChild("registerButton", Button({
		x = self.width / 2,
		y = 275,
		origin = { x = 0.5 },
		width = 400,
		height = 45,
		label = "Sign Up",
		font = self.fonts:loadFont("Regular", 24),
		color = { 0.05, 0.52, 0.65, 1 },
		onClick = function ()
			self:transitOutPages()
			self:pushRegisterPage()
		end
	}))

	c:autoSize()

	page:addChild("background", Rectangle({
		x = self.width / 2,
		y = self.height / 2,
		origin = { x = 0.5, y = 0.5 },
		width = 450,
		height = c.height + 50,
		color = { 0.02, 0.02, 0.1, 1 },
		rounding = 14
	}))
end

function View:pushRegisterPage()
	local page = self.pages:addChild(self:getPageName(), Page())

	local c = page:addChild("container", Component({
		x = self.width / 2,
		y = self.height / 2,
		origin = { x = 0.5, y = 0.5 },
		z = 0.1
	}))

	c:addChild("text", Label({
		y = 0,
		boxWidth = self.width,
		alignX = "center",
		font = self.fonts:loadFont("Bold", 32),
		text = "Sign Up",
		z = 0.1,
	}))

	c:addChild("nameLabel", Label({
		text = "Name",
		font = self.fonts:loadFont("Regular", 20),
		x = self.width / 2 - (400 / 2) + 5,
		y = 50,
	}))

	local name_textbox = c:addChild("name", TextBox({
		x = self.width / 2,
		y = 80,
		origin = { x = 0.5 },
		width = 400,
		height = 34,
		font = self.fonts:loadFont("Regular", 24),
	}))

	c:addChild("emailLabel", Label({
		text = "Email",
		font = self.fonts:loadFont("Regular", 20),
		x = self.width / 2 - (400 / 2) + 5,
		y = 130,
	}))
	local email_textbox = c:addChild("email", TextBox({
		x = self.width / 2,
		y = 160,
		origin = { x = 0.5 },
		width = 400,
		height = 34,
		font = self.fonts:loadFont("Regular", 24),
	}))

	c:addChild("passwordLabel", Label({
		text = "Password",
		font = self.fonts:loadFont("Regular", 20),
		x = self.width / 2 - (400 / 2) + 5,
		y = 210,
	}))
	local password_textbox = c:addChild("password", TextBox({
		x = self.width / 2,
		y = 240,
		origin = { x = 0.5 },
		width = 400,
		height = 34,
		password = true,
		font = self.fonts:loadFont("Regular", 24),
	}))

	c:addChild("confirmPasswordLabel", Label({
		text = "Confirm password",
		font = self.fonts:loadFont("Regular", 20),
		x = self.width / 2 - (400 / 2) + 5,
		y = 290,
	}))

	local confirm_password_textbox = c:addChild("confirmPassword", TextBox({
		x = self.width / 2,
		y = 320,
		origin = { x = 0.5 },
		width = 400,
		height = 34,
		password = true,
		font = self.fonts:loadFont("Regular", 24),
	}))

	c:addChild("registerButton", Button({
		x = self.width / 2,
		y = 380,
		origin = { x = 0.5 },
		width = 400,
		height = 45,
		label = "Sign Up",
		font = self.fonts:loadFont("Regular", 24),
		color = { 0.05, 0.52, 0.65, 1 },
		onClick = function ()
			if not email_textbox.input:find("@") then
				self.popup:add("Email is invalid.", "error")
				return
			end

			if password_textbox.input ~= confirm_password_textbox.input then
				self.popup:add("Passwords don't match!", "error")
				return
			end

			if password_textbox.input:len() < 6 then
				self.popup:add("Password is too short. Make it longer.", "error")
				return
			end

			self:transitOutPages()
			self.svn_online_model:register(name_textbox.input, email_textbox.input, password_textbox.input)
		end
	}))

	c:addChild("loginButton", Button({
		x = self.width / 2,
		y = 435,
		origin = { x = 0.5 },
		width = 400,
		height = 45,
		label = "Log in",
		font = self.fonts:loadFont("Regular", 24),
		color = { 0.05, 0.52, 0.65, 1 },
		onClick = function()
			self:transitOutPages()
			self:pushLoginPage()
		end
	}))

	c:autoSize()

	page:addChild("background", Rectangle({
		x = self.width / 2,
		y = self.height / 2,
		origin = { x = 0.5, y = 0.5 },
		width = 450,
		height = c.height + 50,
		color = { 0.02, 0.02, 0.1, 1 },
		rounding = 14
	}))
end

---@param text string?
function View:pushLoadingPage(text)
	local page = self.pages:addChild(self:getPageName(), Page())

	local c = page:addChild("container", Component({
		y = self.height / 2,
		origin = { y = 0.5 }
	}))

	local img = self.assets:loadImage("loading")
	c:addChild("image", Image({
		x = self.width / 2,
		y = img:getHeight() / 2,
		origin = { x = 0.5, y = 0.5 },
		image = self.assets:loadImage("loading"),
		update = function(this)
			this.angle = (love.timer.getTime() * 2) % (math.pi * 2)
		end
	}))

	c:addChild("text", Label({
		y = img:getHeight(),
		boxWidth = self.width,
		alignX = "center",
		font = self.fonts:loadFont("Regular", 34),
		text = text or "Loading..."
	}))

	c:autoSize()
end

function View:pushLoadoutPage()
	local page = self.pages:addChild(self:getPageName(), Page())

	page:addChild("text", Label({
		boxWidth = self.width,
		boxHeight = self.height,
		alignX = "center",
		alignY = "center",
		font = self.fonts:loadFont("Regular", 34),
		text = require("inspect")(self.svn_online_model.session_user)
	}))
end

function View:transitOutPages()
	for _, child in pairs(self.pages.children) do
		child:transitOut()
	end
end

return View
