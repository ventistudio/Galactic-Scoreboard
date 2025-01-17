local component = {}
component.dependencies = {"scoreboard", "theme"}
component.title = "Scoreboard DarkRP"

-- Table des groupes à afficher
local displayGroups = {
    ["superadmin"] = "Fondateur",
    ["admin"] = "Administrateur",
    ["modo"] = "Modérateur",
    ["mvp"] = "MVP",
    ["vsp"] = "VSP",
    ["vip"] = "VIP",
    ["verified"] = "Vérifié",
    ["members"] = "Membre"
}

function component:ScoreboardStats()
    if engine.ActiveGamemode() == "darkrp" then
        return self.StatsFromDerived
    end
end

function component:StatsFromDerived(ply)
    local stats = {
        {
            stat = "Groupe",
            important = true,
            func = function()
                if not ply():IsValid() then return "N/A" end
                local userGroup = ply():GetUserGroup()
                return displayGroups[userGroup] or "" -- Retourne une chaîne vide si le groupe n'est pas dans la liste
            end
        },
        {
            stat = "Métier",
            important = true,
            func = function() 
                if not ply():IsValid() then return "N/A" end
                return ply():getDarkRPVar("job") or "Inconnu"
            end
        },
        {
            stat = "Argent",
            important = true,
            func = function()
                if not ply():IsValid() then return 0 end
                return DarkRP.formatMoney(ply():getDarkRPVar("money") or 0)
            end
        },
        {
            stat = "Salaire",
            important = true,
            func = function()
                if not ply():IsValid() then return 0 end
                return DarkRP.formatMoney(ply():getDarkRPVar("salary") or 0)
            end
        },
        {
            stat = "Wanted",
            func = function()
                if not ply():IsValid() then return "Non" end
                return ply():getDarkRPVar("wanted") and "Oui" or "Non"
            end
        },
        {
            stat = "License",
            func = function()
                if not ply():IsValid() then return "Non" end
                return ply():getDarkRPVar("hasgun") and "Oui" or "Non"
            end
        },
        {
            stat = "Props",
            func = function() return ply():IsValid() and ply():GetCount("props") or 0 end,
            limit = function() return GetConVar("sbox_maxprops"):GetInt() end
        },
        {
            stat = "Ping",
            important = true,
            func = function() return ply():IsValid() and ply():Ping() or 0 end
        }
    }

    -- Ajout du temps de jeu si disponible
    if galactic and galactic.pdManager then
        table.insert(stats, 
        {
            stat = "Temps de jeu",
            important = true,
            func = function()
                if not ply():IsValid() then return "Aucun" end
                self.PlayTime = os.time() - ply():Info().lastJoin + ply():Info().playTime
                return string.NiceTime(self.PlayTime)
            end
        })
    end

    return stats
end

galactic:Register(component)
