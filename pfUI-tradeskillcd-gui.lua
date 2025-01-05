-- load pfUI environment
setfenv(1, pfUI:GetEnvironment())

function pfUI.tradeskillcd:LoadGui()
  if not pfUI.gui then return end

  local function CreateSlashCmdLine(parent, index, cmd, description)
    parent.cmds = parent.cmds or {}
    if parent.cmds[index] then return end
    parent.cmds[index] = {}
    parent.cmds[index].cmd = parent:CreateFontString("Status", "LOW", "GameFontWhite")
    parent.cmds[index].cmd:SetFont(pfUI.font_default, C.global.font_size)
    parent.cmds[index].cmd:SetText("|cff33ffcc" .. cmd .. "|r")
    parent.cmds[index].cmd:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", - (parent:GetWidth() * 0.8), - (tonumber(C.global.font_size) * 2) * index)

    if description and description ~= "" then
      parent.cmds[index].desc = parent:CreateFontString("Status", "LOW", "GameFontWhite")
      parent.cmds[index].desc:SetFont(pfUI.font_default, C.global.font_size)
      parent.cmds[index].desc:SetText(" - " .. description)
      parent.cmds[index].desc:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", (parent:GetWidth() * 0.2), - (tonumber(C.global.font_size) * 2) * index)
    end

    parent:GetParent().objectCount = parent:GetParent().objectCount + 1
  end

  local old_gui = true
  
  if pfUI.gui.CreateGUIEntry then
    old_gui = false
  end

  if old_gui then
    local CreateConfig = pfUI.gui.CreateConfig
    local update = pfUI.gui.update

    if pfUI.gui.tabs.thirdparty then
      pfUI.gui.tabs.thirdparty.tabs.tradeskillcd = pfUI.gui.tabs.thirdparty.tabs:CreateTabChild(GetAddOnMetadata("pfUI-tradeskillcd", "X-LocalName"), true)
      pfUI.gui.tabs.thirdparty.tabs.tradeskillcd:SetScript("OnShow", function() 
        if not this.setup then

          CreateConfig(update["tradeskillcd"], this, T["Show Remaining Time (Date And Time Otherwise)"], C.tradecd, "show_remaining", "checkbox")
          CreateConfig(update["tradeskillcd"], this, T["Show Only Current Character"], C.tradecd, "show_current", "checkbox")
          CreateConfig(update["tradeskillcd"], this, T["Show Chat Notifications"], C.tradecd, "noti_chat", "checkbox")
          CreateConfig(update["tradeskillcd"], this, T["Cooldown Is Ready Announcement On Startup"], C.tradecd, "startup_announce", "checkbox")
          CreateConfig(update["tradeskillcd"], this, T["Cooldown Is Ready Warning"], C.tradecd, "noti_ready_rw", "checkbox")
          CreateConfig(update["tradeskillcd"], this, T["Cooldown Is Ready Sound"], C.tradecd, "noti_ready_sound", "checkbox")
          CreateConfig(update["tradeskillcd"], this, T["Perform Scan"], C.tradecd, "button", "button", pfUI.tradeskillcd.Scan, true)

          CreateConfig(update[c], this, T["SLASH COMMANDS:"], nil, nil, "header")
          CreateConfig(update[c], this, T["/pftc help"], nil, nil, "header", nil, true)
          CreateConfig(update[c], this, T["/pftc scan"], nil, nil, "header", nil, true)
          CreateConfig(update[c], this, T["/pftc status"], nil, nil, "header", nil, true)

          this.setup = true 
        end
      end)
    end
  else
    local Reload = pfUI.gui.Reload
    local CreateConfig = pfUI.gui.CreateConfig
    local CreateGUIEntry = pfUI.gui.CreateGUIEntry
    local U = pfUI.gui.UpdaterFunctions
    CreateGUIEntry(T["Thirdparty"], GetAddOnMetadata("pfUI-tradeskillcd", "X-LocalName"), function()
      CreateConfig(U["tradeskillcd"], T["Show Remaining Time (Date And Time Otherwise)"], C.tradecd, "show_remaining", "checkbox")
      CreateConfig(U["tradeskillcd"], T["Show Only Current Character"], C.tradecd, "show_current", "checkbox")
      CreateConfig(U["tradeskillcd"], T["Show Chat Notifications"], C.tradecd, "noti_chat", "checkbox")
      CreateConfig(U["tradeskillcd"], T["Cooldown Is Ready Announcement On Startup"], C.tradecd, "startup_announce", "checkbox")
      CreateConfig(U["tradeskillcd"], T["Cooldown Is Ready Warning"], C.tradecd, "noti_ready_rw", "checkbox")
      CreateConfig(U["tradeskillcd"], T["Cooldown Is Ready Sound"], C.tradecd, "noti_ready_sound", "checkbox")
      CreateConfig(U["tradeskillcd"], T["Perform Scan"], nil, nil, "button", pfUI.tradeskillcd.Scan)

      local slash_header = CreateConfig(nil, T["SLASH COMMANDS"], nil, nil, "header")
      CreateSlashCmdLine(slash_header, 1, "/pftc help", "Print out all available commands")
      CreateSlashCmdLine(slash_header, 2, "/pftc scan", "Perform tradeskill/item colldowns check")
      CreateSlashCmdLine(slash_header, 3, "/pftc status", "Report tradeskill cooldowns status")
      
      CreateConfig(nil, T["Version"] .. ": " .. GetAddOnMetadata("pfUI-tradeskillcd", "Version"), nil, nil, "header")
      CreateConfig(U["tradeskillcd"], T["Website"], nil, nil, "button", function()
        pfUI.chat.urlcopy.CopyText("https://gitlab.com/dein0s_wow_vanilla/pfUI-tradeskillcd")
      end)
      

    end)
  end
end

pfUI.tradeskillcd:LoadGui()
