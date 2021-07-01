local component = {}
component.namespace = "scoreboard"
component.dependencies = {"theme"}
component.title = "Scoreboard"

function component:Constructor()
	if LocalPlayer():IsValid() then
		self:InitScoreboard()
	end
end

function component:ScoreboardShow()
	if not self.screen then
		self:InitScoreboard()
	end
	if self.StatsFromDerived then
		self.screen:SetVisible(true)
		return true
	end
end

function component:ScoreboardHide()
	if not self.screen then
		self:InitScoreboard()
	end
	if self.StatsFromDerived then
		self.screen:SetVisible(false)
		return true
	end
end

function component:ComponentInitialized(comp)
	if comp.ScoreboardStats then
		self:LoadStats(comp)
	end
end

function component:LoadStats(comp)
	local func = comp:ScoreboardStats()
	if func then
		self.StatsFromDerived = func
	end
end

local blur = Material( "pp/blurscreen" )
local function DrawBlurRect(x, y, w, h, effect, shade)
	local X, Y = 0,0
	
		surface.SetDrawColor(255,255,255)
		surface.SetMaterial(blur)

		for i = 1, effect or 5 do
			blur:SetFloat("$blur", i)
			blur:Recompute()

			render.UpdateScreenEffectTexture()

			surface.DrawTexturedRect(X, Y, ScrW(), ScrH())
		end
   
end

function component:GetSelectedPlayer()
	return self.screen.scoreboard.left.player and self.screen.scoreboard.left.player:IsValid() and self.screen.scoreboard.left.player or LocalPlayer()
end

function component:InitScoreboard()
	for _, comp in ipairs(galactic.components) do
		self:ComponentInitialized(comp)
	end

	if not self.StatsFromDerived then return end

	if galactic.scoreboardPanel then galactic.scoreboardPanel:Remove() end

	self.screen = vgui.Create("Panel")
	//self.screen:SetVisible(false)
	self.screen:Dock(FILL)
	self.screen.Paint = function(pnl, w, h)
		DrawBlurRect(0, 0, ScrW(), ScrH(), 5)
		surface.SetDrawColor(ColorAlpha(galactic.theme.colors.block, 50))
		surface.DrawRect(0, 0, w, h)
	end
	galactic.scoreboardPanel = self.screen


	self.screen.scoreboard = self.screen:Add("Panel")
	self.screen.scoreboard:MakePopup()
	self.screen.scoreboard:SetKeyboardInputEnabled(false)
	self.screen.scoreboard.Paint = function(pnl, w, h)
		pnl:SetWidth(galactic.theme.rem * 16 * 4)

		local leftHeight = self.screen.scoreboard.left.modelHolder:GetTall() + self.screen.scoreboard.left.stats.custom.canvas:GetTall() + self.screen.scoreboard.left.stats.roles:GetTall() + self.screen.scoreboard.left.stats.nick:GetTall() + self.screen.scoreboard.left.stats.admin:GetTall()
		local rightHeight = self.screen.scoreboard.container.header:GetTall() + self.screen.scoreboard.container.body:GetCanvas():GetTall() + self.screen.scoreboard.container.infoBar:GetTall()
		if leftHeight > rightHeight then
			pnl:SetHeight(leftHeight)
		else
			pnl:SetHeight(rightHeight)
		end

		local maxHeight = ScrH() - galactic.theme.rem * 8
		if pnl:GetTall() > maxHeight then
			pnl:SetHeight(maxHeight)
		end

		pnl:Center()
	end

	self.screen.scoreboard.left = self.screen.scoreboard:Add("Panel")
	self.screen.scoreboard.left:Dock(LEFT)
	self.screen.scoreboard.left.Paint = function(pnl, w, h)
		pnl:SetWidth(galactic.theme.rem * 12)
	end

	self.screen.scoreboard.left.modelHolder = self.screen.scoreboard.left:Add("Panel")
	self.screen.scoreboard.left.modelHolder:Dock(TOP)
	self.screen.scoreboard.left.modelHolder.Paint = function(pnl, w, h)
		pnl:SetHeight(galactic.theme.rem * 12 * 1.5)
	end

	self.screen.scoreboard.left.modelHolder.model = self.screen.scoreboard.left.modelHolder:Add("DModelPanel")
	self.screen.scoreboard.left.modelHolder.model:Dock(FILL)
	self.screen.scoreboard.left.modelHolder.model:SetFOV(30)
	self.screen.scoreboard.left.modelHolder.model:SetModel(LocalPlayer():GetModel())
	self.screen.scoreboard.left.modelHolder.model.Entity.GetPlayerColor = function()
		return self:GetSelectedPlayer():GetPlayerColor()
	end
	self.screen.scoreboard.left.modelHolder.model.LayoutEntity = function(pnl, Entity) end
	self.screen.scoreboard.left.modelHolder.model.PreDrawModel = function(pnl, Entity)
		if pnl.Entity:GetModel() != self:GetSelectedPlayer():GetModel() then
			pnl:SetModel(self:GetSelectedPlayer():GetModel())
			self.screen.scoreboard.left.modelHolder.model.Entity.GetPlayerColor = function()
				return self:GetSelectedPlayer():GetPlayerColor()
			end
		end
		pnl.idleRotation = math.cos(RealTime() / 2) * 22.5
		local headPos = pnl.Entity:GetBonePosition(pnl.Entity:LookupBone("ValveBiped.Bip01_Head1") or pnl.Entity:LookupBone("ValveBiped.Bip01_Spine"))
		if not pnl.Entity:LookupBone("ValveBiped.Bip01_Head1") then
			headPos.z = headPos.z + 20
		end
		pnl:SetLookAt(headPos + Vector(0, 0, -10))
		pnl:SetCamPos(Vector(50, 0, headPos.z - 10))



		local dragSpeed = 5
		if pnl.rotation == nil then
			pnl.rotation = 180
		end
		if pnl.acceleration == nil then
			pnl.acceleration = 0
		end



		if pnl:IsHovered() and not pnl.isDragging and input.IsMouseDown(MOUSE_LEFT) then
			pnl.isDragging = true
			pnl.dragStartPosX = input.GetCursorPos() - pnl.rotation * 20 / dragSpeed
		end

		if not input.IsMouseDown(MOUSE_LEFT) and pnl.isDragging then
			pnl.isDragging = false
		end

		if pnl.isDragging then
			pnl.acceleration = pnl.rotation
			pnl.rotation = - (pnl.dragStartPosX - input.GetCursorPos()) / (20 / dragSpeed)
			pnl.acceleration = (pnl.rotation - pnl.acceleration) * 1 / RealFrameTime()
		else
			/*pnl.rotation = (pnl.rotation + pnl.acceleration * RealFrameTime()) % 360
			pnl.acceleration = pnl.acceleration - pnl.acceleration * RealFrameTime() * friction
			pnl.acceleration = pnl.acceleration + (180 - pnl.rotation) * RealFrameTime() * friction*/
		end
		Entity:SetAngles(Angle(0, pnl.idleRotation + pnl.rotation + 180, 0))

	end

	self.screen.scoreboard.left.modelHolder.model.triangle = self.screen.scoreboard.left.modelHolder.model:Add("Panel")
	self.screen.scoreboard.left.modelHolder.model.triangle:Dock(BOTTOM)
	self.screen.scoreboard.left.modelHolder.model.triangle:SetMouseInputEnabled(false)
	self.screen.scoreboard.left.modelHolder.model.triangle.Paint = function(pnl, w, h)
		pnl:SetHeight(galactic.theme.rem * 12)

		surface.SetDrawColor(galactic.theme.colors.blockFaint)
		draw.NoTexture()
		local triangle = {
				{ x = 0, y = pnl:GetTall() },
				{ x = pnl:GetWide(), y = 0 },
				{ x = pnl:GetWide(), y = pnl:GetTall() }
		}
		surface.DrawPoly(triangle)
	end

	self.screen.scoreboard.left.modelHolder.model.imgBorder = self.screen.scoreboard.left.modelHolder.model:Add("DButton")
	self.screen.scoreboard.left.modelHolder.model.imgBorder:SetMouseInputEnabled(true)
	self.screen.scoreboard.left.modelHolder.model.imgBorder.Paint = function(pnl, w, h)
		pnl:SetSize(galactic.theme.rem * 4, galactic.theme.rem * 4)
		pnl:SetPos(galactic.theme.rem - galactic.theme.rem / 4, galactic.theme.rem * 13 + galactic.theme.rem / 4)
		draw.RoundedBox(galactic.theme.round, 0, 0, w, h, galactic.theme.colors.blockFaint)
	end
	self.screen.scoreboard.left.modelHolder.model.imgBorder.DoClick = function()
		self:GetSelectedPlayer():ShowProfile()
	end

	self.screen.scoreboard.left.modelHolder.model.imgBorder.img = self.screen.scoreboard.left.modelHolder.model.imgBorder:Add("AvatarImage")
	self.screen.scoreboard.left.modelHolder.model.imgBorder.img:Dock(FILL)
	self.screen.scoreboard.left.modelHolder.model.imgBorder.img:SetMouseInputEnabled(false)
	self.screen.scoreboard.left.modelHolder.model.imgBorder.img:SetPlayer(self:GetSelectedPlayer(), 64)
	self.screen.scoreboard.left.modelHolder.model.imgBorder.img:DockMargin(galactic.theme.rem / 4, galactic.theme.rem / 4, galactic.theme.rem / 4, galactic.theme.rem / 4)
	self.screen.scoreboard.left.modelHolder.model.imgBorder.img.Paint = function(pnl, w, h)
		pnl:SetPlayer(self:GetSelectedPlayer(), 256)
	end

	self.screen.scoreboard.left.stats = self.screen.scoreboard.left:Add("Panel")
	self.screen.scoreboard.left.stats:Dock(FILL)
	self.screen.scoreboard.left.stats.Paint = function(pnl, w, h)
		draw.RoundedBoxEx(galactic.theme.round, 0, 0, w, h, galactic.theme.colors.blockFaint, _, _, true, _)
	end

	self.screen.scoreboard.left.stats.admin = self.screen.scoreboard.left.stats:Add("Panel")
	self.screen.scoreboard.left.stats.admin:Dock(TOP)
	self.screen.scoreboard.left.stats.admin.Paint = function(pnl, w, h)
		pnl:DockMargin(galactic.theme.rem, 0, galactic.theme.rem, 0)
		local ply = self:GetSelectedPlayer()
		local txtW, txtH = draw.SimpleText(ply:IsSuperAdmin() and "SUPERADMIN" or ply:IsAdmin() and "ADMIN" or "",
				"GalacticP",
				0,
				0,
				ply:IsSuperAdmin() and galactic.theme.colors.red or ply:IsAdmin() and galactic.theme.colors.yellow or nil,
				TEXT_ALIGN_LEFT)
		pnl:SetHeight(txtH)
	end

	self.screen.scoreboard.left.stats.nick = self.screen.scoreboard.left.stats:Add("Panel")
	self.screen.scoreboard.left.stats.nick:Dock(TOP)
	self.screen.scoreboard.left.stats.nick.Paint = function(pnl, w, h)
		pnl:DockMargin(galactic.theme.rem, 0, galactic.theme.rem, 0)
		local txtW, txtH = draw.SimpleText(self:GetSelectedPlayer():Nick(),
				"GalacticH3",
				0,
				0,
				galactic.theme.colors.text,
				TEXT_ALIGN_LEFT)
		pnl:SetHeight(txtH)
	end

	self.screen.scoreboard.left.stats.roles = self.screen.scoreboard.left.stats:Add("Panel")
	self.screen.scoreboard.left.stats.roles:Dock(TOP)
	self.screen.scoreboard.left.stats.roles:SetHeight(16*2.5*2)
	self.screen.scoreboard.left.stats.roles.Paint = function(pnl, w, h)
		pnl:DockMargin(galactic.theme.rem, 0, 0, 0)
		pnl:SetHeight(16)
	end

	self.screen.scoreboard.left.stats.roles.render = self:GetRoleList(self.screen.scoreboard.left.stats.roles, function() return self:GetSelectedPlayer() end)
	self.screen.scoreboard.left.stats.roles.render:Dock(TOP)

	self.screen.scoreboard.left.stats.custom = self:CreateScroll(self.screen.scoreboard.left.stats)

	self.screen.scoreboard.left.stats.custom.canvas = self.screen.scoreboard.left.stats.custom:GetCanvas()
	self.screen.scoreboard.left.stats.custom.canvas.Paint = function(pnl, w, h)
		pnl:DockPadding(galactic.theme.rem, 0, galactic.theme.rem, galactic.theme.rem)
		draw.RoundedBoxEx(galactic.theme.round, 0, 0, w, h, galactic.theme.colors.blockFaint, _, _, true, _)
	end

	local stats = self:GetStats(function() return self:GetSelectedPlayer() end)

	for _, stat in ipairs(stats) do
		local test = self.screen.scoreboard.left.stats.custom:Add("Panel")
		test:Dock(TOP)
		test.Paint = function(pnl, w, h)
			pnl:DockMargin(0, galactic.theme.rem / 2, 0, 0)
			if stat.limit then
				local procentUsed = stat.func() / stat.limit()
				local lineWidth = w * procentUsed
				draw.NoTexture()
				surface.SetDrawColor(galactic.theme:Blend(galactic.theme.colors.blue, galactic.theme.colors.red, procentUsed))
				surface.DrawLine(w - lineWidth, h - 1, w, h - 1)
			end
			local txtW, txtH = draw.SimpleText(stat.stat,
					"GalacticP",
					0,
					0,
					galactic.theme.colors.textFaint,
					TEXT_ALIGN_LEFT)
			draw.SimpleText(stat.func(),
					"GalacticPBold",
					pnl:GetWide(),
					0,
					galactic.theme.colors.text,
					TEXT_ALIGN_RIGHT)
			pnl:SetHeight(txtH)
		end
		if stat.paint then
			test.Paint = function(pnl, w, h)
				pnl:DockMargin(0, galactic.theme.rem / 2, 0, 0)
				stat.paint(stat, pnl, w, h)
			end
		end
	end

	self.screen.scoreboard.container = self.screen.scoreboard:Add("Panel")
	self.screen.scoreboard.container:Dock(FILL)
	self.screen.scoreboard.container.Paint = function(pnl, w, h)
	end

	self.screen.scoreboard.container.header = self.screen.scoreboard.container:Add("Panel")
	self.screen.scoreboard.container.header:Dock(TOP)
	self.screen.scoreboard.container.header.Paint = function(pnl, w, h)
		pnl:SetHeight(galactic.theme.rem * 6)
	end

	self.screen.scoreboard.container.header.description = self.screen.scoreboard.container.header:Add("DLabel")
	self.screen.scoreboard.container.header.description:SetFont("GalacticH3")
	self.screen.scoreboard.container.header.description:Dock(BOTTOM)
	self.screen.scoreboard.container.header.description:SetAutoStretchVertical(true)
	self.screen.scoreboard.container.header.description.Paint = function(pnl, w, h)
		pnl:DockMargin(0, 0, 0, galactic.theme.rem)
		pnl:SetTextColor(galactic.theme.colors.text)
		pnl:SetText("Currently playing " ..
				GAMEMODE.Name ..
				" on the map " ..
				game.GetMap() ..
				", with " ..
				(#player.GetAll() >= 2 and (#player.GetAll() - 1) or "no") ..
				" other player" ..
				(#player.GetAll() != 2 and "s" or ""))
	end

	self.screen.scoreboard.container.header.hostName = self.screen.scoreboard.container.header:Add("DLabel")
	self.screen.scoreboard.container.header.hostName:Dock(BOTTOM)
	self.screen.scoreboard.container.header.hostName:SetFont("GalacticH1")
	self.screen.scoreboard.container.header.hostName:SetAutoStretchVertical(true)
	self.screen.scoreboard.container.header.hostName.Paint = function(pnl, w, h)
		pnl:SetTextColor(galactic.theme.colors.text)
		pnl:SetText(GetHostName():upper())
	end

	self.screen.scoreboard.container.infoBar = self.screen.scoreboard.container:Add("Panel")
	self.screen.scoreboard.container.infoBar:Dock(TOP)
	self.screen.scoreboard.container.infoBar.Paint = function(pnl, w, h)
		pnl:DockPadding(galactic.theme.rem / 2, galactic.theme.rem / 2, galactic.theme.rem / 2, 0)
		pnl:SetHeight(galactic.theme.rem * 2)
		draw.RoundedBoxEx(galactic.theme.round, 0, 0, w, h, galactic.theme.colors.blockFaint, _, true, _, _)
	end

	self.screen.scoreboard.container.infoBar.container = self.screen.scoreboard.container.infoBar:Add("Panel")
	self.screen.scoreboard.container.infoBar.container:Dock(FILL)
	self.screen.scoreboard.container.infoBar.container.Paint = function(pnl, w, h)
		local paddingRight = galactic.theme.rem * 3
		pnl:DockPadding(0, 0, paddingRight, 0)
		draw.RoundedBox(galactic.theme.round, 0, 0, w, h, galactic.theme.colors.block)
	end


	local stats2 = self:GetStats(function() return ply end)

	local unitsPerGroup = 2
	local stats = {}
	for _, stat in ipairs(stats2) do
		if stat.important then
			table.insert(stats, stat)
		end
	end
	stats = table.Reverse(stats)

	for _, stat in ipairs(stats) do
		self:AddSimpleStat(self.screen.scoreboard.container.infoBar.container, function() return stat.stat or "" end, function() return galactic.theme.colors.textFaint end)
	end

	self.screen.scoreboard.container.body = self:CreateScroll(self.screen.scoreboard.container)

	for _, ply in ipairs(player.GetAll()) do
		self:AddPlayerLine(ply)
	end
end

function component:AddPlayerLine(ply)
	local line = self.screen.scoreboard.container.body:Add("Panel")
	line:Dock(TOP)
	line:SetSelectable(true)
	line:SetCursor("hand")
	line.player = ply

	line.Paint = function(pnl, w, h)
		if not pnl.player:IsValid() then
			pnl:Remove()
			return
		end

		local rank = -pnl.player:Frags()
		if galactic and galactic.roleManager then
			rank = pnl.player:Rank()
		end
		pnl:SetZPos(rank)

		pnl:DockMargin(0, 0, 0, galactic.theme.rem / 4)
		pnl:SetTall(galactic.theme.rem * 3)
		pnl:DockPadding(galactic.theme.rem / 2, galactic.theme.rem / 2, galactic.theme.rem / 2, galactic.theme.rem / 2)

		draw.RoundedBoxEx(galactic.theme.round, 0, 0, w, h, galactic.theme.colors.block)
		if pnl:IsHovered() and not pnl:IsSelected() then
			if input.IsMouseDown(MOUSE_LEFT) and not pnl.hasLeftClicked then
				self.screen.scoreboard.container.body:UnselectAll()
				pnl:SetSelected(true)
				self.screen.scoreboard.left.player = pnl.player
			end
			draw.RoundedBox(galactic.theme.round, 0, 0, w, h, galactic.theme.colors.red)
		end

		pnl.hasLeftClicked = input.IsMouseDown(MOUSE_LEFT)

		if pnl:IsSelected() then
			draw.RoundedBox(galactic.theme.round, 0, 0, w, h, galactic.theme.colors.blue)
		end
	end

	line.link = line:Add("DButton")
	line.link:Dock(LEFT)
	line.link:SetMouseInputEnabled(true)
	line.link.Paint = function(pnl, w, h)
		pnl:DockMargin(0, 0, galactic.theme.rem / 2, 0)
		pnl:SetSize(galactic.theme.rem * 2, galactic.theme.rem * 2)
	end
	line.link.DoClick = function()
		ply:ShowProfile()
	end

	line.link.image = line.link:Add("AvatarImage")
	line.link.image:Dock(FILL)
	line.link.image:SetPlayer(ply, 64)
	line.link.image:SetMouseInputEnabled(false)

	line.basicInfo = line:Add("Panel")
	line.basicInfo:Dock(FILL)
	line.basicInfo:SetMouseInputEnabled(false)

	line.basicInfo.name = line.basicInfo:Add("DLabel")
	line.basicInfo.name:Dock(TOP)
	line.basicInfo.name:SetFont("GalacticPBold")
	line.basicInfo.name:SetAutoStretchVertical(true)
	line.basicInfo.name.Paint = function(pnl, w, h)
		pnl:SetTextColor(galactic.theme.colors.text)
		pnl:SetText(ply:IsValid() and ply:Nick() or "Undefined")
	end

	line.basicInfo.roles = self:GetRoleList(line.basicInfo, function() return ply end)
	line.basicInfo.roles:Dock(TOP)

	line.mute = line:Add("DImageButton");
	line.mute:Dock(RIGHT);
	line.mute.DoClick = function(pnl)
		ply:SetMuted(!ply:IsMuted())
	end
	line.mute.Paint = function(pnl, w, h)
		line.mute:DockMargin(galactic.theme.rem / 2, 0, 0, 0)
		line.mute:SetSize(galactic.theme.rem * 2, galactic.theme.rem * 2)

		if ply:IsValid() then
			if ply:IsMuted() then
				pnl:SetImage("icon32/muted.png");
			else
				pnl:SetImage("icon32/unmuted.png");
			end
		end
	end

	local stats2 = self:GetStats(function() return ply end)

	local unitsPerGroup = 1
	local stats = {}
	for _, v in ipairs(stats2) do
		if v.important then
			table.insert(stats, v)
		end
	end
	stats = table.Reverse(stats)

	for _, stat in ipairs(stats) do
		self:AddSimpleStat(line, stat.func, function() return galactic.theme.colors.text end)
	end

	return line
end

function component:AddSimpleStat(pnl, func, colorFunc)
	local statPanel = pnl:Add("DLabel")
	statPanel:Dock(RIGHT)
	statPanel:SetFont("GalacticPBold")
	statPanel:SetContentAlignment(5)
	statPanel.Paint = function(pnl, w, h)
		pnl:SetWidth(galactic.theme.rem * 4)
		pnl:SetTextColor(colorFunc())
		pnl:SetText(func())
		/*surface.SetDrawColor(255,0,255)
		surface.DrawRect(0, 0, w, h)*/
	end

	return statPanel
end

function component:GetRoleList(pnl, ply)
	local roles = pnl:Add("Panel")
	roles.Paint = function(pnl, w, h)
		if not ply():IsValid() then return end
		surface.SetFont("GalacticSubBold")
		local posX, posY = 0, 0

		if galactic and galactic.roleManager then
			for _, role in ipairs(ply():Roles()) do
				if not role.title then break end
				local txtW, txtH = surface.GetTextSize(role.title:upper())
				if posX + txtW + galactic.theme.rem / 2 > pnl:GetWide() then
					posX = 0
					posY = posY + galactic.theme.rem + galactic.theme.rem / 4
				end
				draw.RoundedBox(galactic.theme.round, posX, posY, txtW + galactic.theme.rem / 2, galactic.theme.rem, role.color)

				local txtColor = Color(255, 255, 255)
				if (role.color.r + role.color.g + role.color.b) / 3 > 155 then
					txtColor = Color(0, 0, 0)
				end
				draw.SimpleText(role.title:upper(), "GalacticSubBold", posX + galactic.theme.rem / 4, posY + galactic.theme.rem / 2, txtColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				posX = posX + txtW + galactic.theme.rem / 2 + galactic.theme.rem / 4
			end
		else
			local txtW, txtH = surface.GetTextSize(team.GetName(ply():Team()):upper())
			if posX + txtW + galactic.theme.rem / 2 > pnl:GetWide() then
				posX = 0
				posY = posY + galactic.theme.rem + galactic.theme.rem / 4
			end
			draw.RoundedBox(galactic.theme.round, posX, posY, txtW + galactic.theme.rem / 2, galactic.theme.rem, team.GetColor(ply():Team()))

			local txtColor = Color(255, 255, 255)
			if (team.GetColor(ply():Team()).r + team.GetColor(ply():Team()).g + team.GetColor(ply():Team()).b) / 3 > 155 then
				txtColor = Color(0, 0, 0)
			end
			draw.SimpleText(team.GetName(ply():Team()):upper(), "GalacticSubBold", posX + galactic.theme.rem / 4, posY + galactic.theme.rem / 2, txtColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			posX = posX + txtW + galactic.theme.rem / 2 + galactic.theme.rem / 4
		end

		pnl:SetHeight(posY + galactic.theme.rem)
	end

	return roles
end

function component:GetStats(ply)
	return self:StatsFromDerived(ply)
end

function component:Think()
	if not self.screen then return end

	for _, ply in ipairs(player.GetAll()) do
		local found = false
		for _, line in ipairs(self.screen.scoreboard.container.body:GetCanvas():GetChildren()) do
			if ply == line.player then
				found = true
				break
			end
		end
		if not found then
			self:AddPlayerLine(ply)
		end
	end


	// Make model spin, brrr
	local modelPanel = self.screen.scoreboard.left.modelHolder.model
	if not modelPanel.isDragging then
		local friction = 2
		modelPanel.rotation = (modelPanel.rotation + modelPanel.acceleration * RealFrameTime()) % 360
		modelPanel.acceleration = modelPanel.acceleration - modelPanel.acceleration * RealFrameTime() * friction
		modelPanel.acceleration = modelPanel.acceleration + (180 - modelPanel.rotation) * RealFrameTime() * friction
	end

end

function component:CreateScroll(pnl)
	local scrollPanel = pnl:Add("DScrollPanel")
	scrollPanel:Dock(FILL)
	scrollPanel.Paint = function(pnl, w, h)
		draw.RoundedBoxEx(galactic.theme.round, 0, 0, w, h, galactic.theme.colors.blockFaint, _, _, _, true)
	end


	scrollPanel.vBar = scrollPanel:GetVBar()
	scrollPanel.vBar:SetHideButtons(true)
	scrollPanel.vBar:SetVisible(true)
	scrollPanel.vBar:Dock(RIGHT)
	scrollPanel.vBar.Paint = function(pnl, w, h)
		pnl:SetWidth(galactic.theme.rem / 2)
		pnl:DockMargin(0, galactic.theme.rem / 2, galactic.theme.rem / 2, galactic.theme.rem / 2)
	end
	scrollPanel.vBar.btnGrip.Paint = function(pnl, w, h)
		draw.RoundedBox(galactic.theme.round, 0, 0, w, h, galactic.theme.colors.block)
	end

	scrollPanel.canvas = scrollPanel:GetCanvas()
	scrollPanel.canvas.Paint = function(pnl, w, h)
		local paddingRight = galactic.theme.rem / 2
		if scrollPanel.vBar:IsVisible() then
			paddingRight = galactic.theme.rem
		end
		pnl:DockPadding(galactic.theme.rem / 2, galactic.theme.rem / 2, paddingRight, galactic.theme.rem / 2)
	end

	return scrollPanel
end

galactic:Register(component)
