local component = {}
component.dependencies = {"scoreboard", "theme"}
component.title = "Scoreboard sandbox"

	/*{ "sbox_maxprops", "Props" },
	{ "sbox_maxragdolls", "Ragdolls" },
	{ "sbox_maxvehicles", "Vehicles" },
	{ "sbox_maxeffects", "Effects" },
	{ "sbox_maxballoons", "Balloons" },
	{ "sbox_maxnpcs", "NPCs" },
	{ "sbox_maxdynamite", "Dynamite" },
	{ "sbox_maxlamps", "Lamps" },
	{ "sbox_maxlights", "Lights" },
	{ "sbox_maxwheels", "Wheels" },
	{ "sbox_maxthrusters", "Thrusters" },
	{ "sbox_maxhoverballs", "Hoverballs" },
	{ "sbox_maxbuttons", "Buttons" },
	{ "sbox_maxemitters", "Emitters" },
	{ "sbox_maxspawners", "Spawners" },
	{ "sbox_maxturrets", "Turrets" }*/

function component:ScoreboardStats()
	if engine.ActiveGamemode() == "sandbox" then
		return self.StatsFromDerived
	end
end

function component:StatsFromDerived(ply)
	local stats = {
		{
			stat = "Frags",
			important = true,
			func = function() return ply():IsValid() and ply():Frags() or 0 end
		},
		{
			stat = "Deaths",
			important = true,
			func = function() return ply():IsValid() and ply():Deaths() or 0 end
		},
		{
			stat = "Props",
			important = true,
			func = function() return ply():IsValid() and ply():GetCount("props") or 0 end,
			limit = function() return GetConVar("sbox_maxprops"):GetInt() end
		},
		{
			stat = "Ping",
			important = true,
			func = function() return ply():IsValid() and ply():Ping() or 0 end
		},
		{
			stat = "Ragdolls",
			func = function() return ply():IsValid() and ply():GetCount("ragdolls") or 0 end,
			limit = function() return GetConVar("sbox_maxragdolls"):GetInt() end
		},
		{
			stat = "Thrusters",
			func = function() return ply():IsValid() and ply():GetCount("thrusters") or 0 end,
			limit = function() return GetConVar("sbox_maxthrusters"):GetInt() end
		},
		{
			stat = "Vehicles",
			func = function() return ply():IsValid() and ply():GetCount("vehicles") or 0 end,
			limit = function() return GetConVar("sbox_maxvehicles"):GetInt() end
		},
		{
			stat = "NPCs",
			func = function() return ply():IsValid() and ply():GetCount("npcs") or 0 end,
			limit = function() return GetConVar("sbox_maxnpcs"):GetInt() end
		},
		{
			stat = "SENTS",
			func = function() return ply():IsValid() and ply():GetCount("sents") or 0 end,
			limit = function() return GetConVar("sbox_maxsents"):GetInt() end
		}
	}

	if galactic and galactic.pdManager then
		table.insert(stats, 
		{
			stat = "Playtime",
			important = true,
			func = function()
				if not ply():IsValid() then return "None" end
				self.PlayTime = os.time() - ply():Info().lastJoin + ply():Info().playTime
				return string.NiceTime(self.PlayTime)
			end
		})
	elseif ulx and ply():GetNWInt( "TotalUTime", -1 ) ~= -1 then
		table.insert(stats, 
		{
			stat = "Playtime",
			important = true,
			func = function()
				if not ply():IsValid() then return "None" end
				self.PlayTime = math.floor((ply():GetUTime() + CurTime() - ply():GetUTimeStart()))
				return string.NiceTime(self.PlayTime)
			end
		})
	end

	/*table.insert(stats, 
	{
		trivial = true,
		paint = function(self, pnl, w, h)
			pnl:SetHeight(w)
			pnl:SetHeight(galactic.theme.rem * 12)
			draw.NoTexture()

			local points = {}
			local maxPoints = 36
			for i = 1, maxPoints do
				local scale = .6 + math.cos(RealTime() + i / maxPoints * 2 * math.pi) * .2 + .2 * (i % 2)
				table.insert(points, { x = math.cos(i / maxPoints * math.pi * 2) * w / 2 * scale + w / 2, y = math.sin(i / maxPoints * math.pi * 2) * w / 2 * scale + w / 2})
			end
			surface.SetDrawColor( 255, 0, 0, 255 )
			surface.DrawPoly(points)
		end
	})*/

	return stats
end

galactic:Register(component)
