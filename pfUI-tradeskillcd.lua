pfUI:RegisterModule("tradeskillcd", function ()

  local colors = {
    ["red"] = "|cffFF0000",
    ["green"] = "|cff00FF00",
    ["cyan"] = "|cff33ffcc",
    ["white"] = "|cffffffff",
    ["grey"] = "|cff555555",
  }

  local function ColorText(color, text)
    if not colors[color] or colors[color] == "" then
      return text
    else
      return colors[color] .. text .. "|r"
    end
  end

  local config
  local player_name = UnitName("player")
  local realm_name = GetRealmName()
  local msg_pref = GetAddOnMetadata("pfUI-tradeskillcd", "Title") .. "|r: "
  local msg_ready = ColorText("green", T["Ready"] .. "!")

  pfUI_cache["tradeskillcd"] = pfUI_cache["tradeskillcd"] or {}
  pfUI_cache["tradeskillcd"][realm_name] = pfUI_cache["tradeskillcd"][realm_name] or {}
  pfUI_cache["tradeskillcd"][realm_name][player_name] = pfUI_cache["tradeskillcd"][realm_name][player_name] or {}


  local tradeskill_list = {
    [1] = {name = "Alchemy", texture = "Interface\\Icons\\Trade_Alchemy"},
    [2] = {name = "Tailoring", texture = "Interface\\Icons\\Trade_Tailoring"},
    [3] = {name = "Leatherworking", texture = "Interface\\Icons\\INV_Misc_ArmorKit_17"},
    [4] = {name = "Engineering", texture = "Interface\\Icons\\Trade_Engineering"},
    [5] = {name = "Herbalism", texture = "Interface\\Icons\\Trade_Herbalism"},
  }

  local tradeskill_items = {
    ["7076"] = {t = 86400, i = 1}, -- Essence of Earth
    ["7078"] = {t = 86400, i = 1}, -- Essence of Fire
    ["7082"] = {t = 86400, i = 1}, -- Essence of Air
    ["7080"] = {t = 86400, i = 1}, -- Essence of Water
    ["12803"] = {t = 86400, i = 1}, -- Living Essence
    ["12808"] = {t = 86400, i = 1}, -- Essence of Undeath
    ["12360"] = {t = 172800, i = 1}, -- Arcanite Bar
    ["15409"] = {t = 259200, i = 3}, -- Refined Deeprock Salt
    ["14342"] = {t = 345600, i = 2}, -- Mooncloth
    ["17202"] = {t = 86400, i = 4}, -- Snowball
    ["7068"]  = {t = 600 ,i = 1}, -- Elemental Fire
    ["11024"] = {t = 600, i = 5}, -- Evergreen Herb Casing
    ["6037"] = {t = 172800, i = 1}, -- Truesilver Bar
    ["3577"] = {t = 172800, i = 1}, -- Gold Bar
    -- ["21536"] = {t = 86400,  i = 5}, -- Elune Stone
  }

  local tradeskill_tools = {
    ["11020"] = {t = 600, i = 5}, -- Evergreen Pouch
    ["17716"] = {t = 86400, i = 4}, -- SnowMaster 9000
    ["15846"] = {t = 259200, i = 3}, -- Salt Shaker
  }

  pfUI.tradeskillcd = CreateFrame("Frame", "pfTradeskillCD", UIParent)
  pfUI.tradeskillcd:RegisterEvent("VARIABLES_LOADED")
  pfUI.tradeskillcd:RegisterEvent("PLAYER_LOGIN")

  pfUI.tradeskillcd.skillmon = CreateFrame("Frame", "pfTradeskillCDSkillmonitor", UIParent)
  pfUI.tradeskillcd.skillmon:RegisterEvent("SPELLS_CHANGED")
  pfUI.tradeskillcd.scanner = CreateFrame("Frame", "pfTradeskillCDScanner", UIParent)
  pfUI.tradeskillcd.scanner:RegisterEvent("CHAT_MSG_LOOT")

  local function ScanSpellbook()
    -- professions are always on the first tab
    local _, _, offset, num = GetSpellTabInfo(1)
    for id = offset + 1, offset + num do
      local spell_texture = GetSpellTexture(id, BOOKTYPE_SPELL)
      local spell_name = GetSpellName(id, BOOKTYPE_SPELL)
      for i in tradeskill_list do
        if spell_texture == tradeskill_list[i].texture then
          tradeskill_list[i].spell_id = id
          tradeskill_list[i].name = spell_name
        end
      end
    end
    for i in tradeskill_list do
      if tradeskill_list[i].spell_id ~= nil then
        if tradeskill_list[i].texture ~= GetSpellTexture(tradeskill_list[i].spell_id, BOOKTYPE_SPELL) then
          tradeskill_list[i].spell_id = nil
          pfUI_cache["tradeskillcd"][realm_name][player_name][i] = nil
        end
      end
    end
  end

  local function FormatTimeleft(timeleft)
    if timeleft == 0 then
      timeleft = msg_ready
    else
      if config.show_remaining == "1" then
        timeleft = pfUI.api.GetColoredTimeString(timeleft - time())
      else
        timeleft = date("%d-%b-%y %H:%M", timeleft)
      end
    end
    return timeleft
  end

  local function ReportTradeskillReady(realm, player, trade_index)
    local msg
    if config.show_current == "1" then
      if player ~= player_name then
        return
      else
        msg = tradeskill_list[trade_index].name .. " cooldown is " .. msg_ready
      end
    else
      msg = player .. " -> " .. tradeskill_list[trade_index].name .. " cooldown is " .. msg_ready
    end
    if config.noti_chat == "1" then
      DEFAULT_CHAT_FRAME:AddMessage(msg_pref .. msg)
    end
    if config.noti_ready_rw == "1" then
      UIErrorsFrame:AddMessage(msg_pref .. msg)
    end
    if config.noti_ready_sound == "1" then
      PlaySound("LEVELUP")
    end
  end

  local function ReportTradeskillStatus()
    local send_report = false
    local report_lines = {}
    table.insert(report_lines, msg_pref .. "STATUS")
    if config.show_current == "1" then
      for ti in pfUI_cache["tradeskillcd"][realm_name][player_name] do
        local timeleft = FormatTimeleft(pfUI_cache["tradeskillcd"][realm_name][player_name][ti])
        table.insert(report_lines, "|cffffffff -> " .. tradeskill_list[ti].name .. "|r" .. ": " .. timeleft)
        send_report = true
      end
    else
      for pn in pfUI_cache["tradeskillcd"][realm_name] do
        for ti in pfUI_cache["tradeskillcd"][realm_name][pn] do
          local timeleft = FormatTimeleft(pfUI_cache["tradeskillcd"][realm_name][pn][ti])
          table.insert(report_lines, pn .. "|cffffffff -> " .. tradeskill_list[ti].name .. "|r" .. ": " .. timeleft)
          send_report = true
        end
      end
    end
    if send_report then
      for i in report_lines do
        DEFAULT_CHAT_FRAME:AddMessage(report_lines[i])
      end
    end
  end

  local function UpdateTradeskill()
    if (this.tick or 1) > GetTime() then return else this.tick = GetTime() + 1 end
    for rn in pfUI_cache["tradeskillcd"] do
      for pn in pfUI_cache["tradeskillcd"][rn] do
        for ti in pfUI_cache["tradeskillcd"][rn][pn] do
          if pfUI_cache["tradeskillcd"][rn][pn][ti] ~= 0 and pfUI_cache["tradeskillcd"][rn][pn][ti] <= time() then
            pfUI_cache["tradeskillcd"][rn][pn][ti] = 0
            ReportTradeskillReady(rn, pn, ti)
          end
        end
      end
    end
  end

  local function ManualTradeskillCheck(prof_id)
    local check_time = time()
    for ti in tradeskill_list do
      if tradeskill_list[ti].spell_id then
        if not prof_id or (prof_id and prof_id == ti) then
          CastSpell(tradeskill_list[ti].spell_id, BOOKTYPE_SPELL)
          for i=1,GetNumTradeSkills() do
            local cooldown = GetTradeSkillCooldown(i)
            if cooldown then
              pfUI_cache["tradeskillcd"][realm_name][player_name][ti] = check_time + cooldown
              if config.noti_chat == "1" then
                local msg = tradeskill_list[ti].name .. " is set on cooldown for " .. pfUI.api.GetColoredTimeString(cooldown)
                DEFAULT_CHAT_FRAME:AddMessage(msg_pref .. msg)
                break
              end
            end
          end
        end
      end
    end
    CloseTradeSkill()
  end

  local function ManualItemCheck()
    local check_time = time()
    for bag=-1,10 do
      local bag_size = GetContainerNumSlots(bag)
      if (bag_size > 0) then
        for slot=1, bag_size do
          local item_link = GetContainerItemLink(bag,slot)
          if item_link and item_link ~= "" then
            local _, _, item_id = strfind(item_link, "(%d+):")
            if tradeskill_tools[item_id] then
              local start, duration, _ = GetContainerItemCooldown(bag, slot)
              if (start > 0 and duration == tradeskill_tools[item_id].t) then
                local cooldown = tradeskill_tools[item_id].t - (GetTime() - start)
                pfUI_cache["tradeskillcd"][realm_name][player_name][tradeskill_tools[item_id].i] = check_time + cooldown
                if config.noti_chat == "1" then
                  local msg = tradeskill_list[tradeskill_tools[item_id].i].name .. " is set on cooldown for " .. pfUI.api.GetColoredTimeString(cooldown)
                  DEFAULT_CHAT_FRAME:AddMessage(msg_pref .. msg)
                end
              end
            end
          end
        end
      end
    end
  end

  local function CheckTradeskillUsed()
    local check_time = time()
    local _, _, item_id = strfind(arg1, "(%d+):")
    local filter_created = gsub(LOOT_ITEM_CREATED_SELF, "%%.-s.", "")
    if strfind(arg1, filter_created) then
      if not tradeskill_items[item_id] then return end
      if item_id == "6037" or item_id == "3577" then
        ManualTradeskillCheck(1)
      else
        pfUI_cache["tradeskillcd"][realm_name][player_name][tradeskill_items[item_id].i] = check_time + tradeskill_items[item_id].t
        if config.noti_chat == "1" then
          local msg = tradeskill_list[tradeskill_items[item_id].i].name .. " is set on cooldown for " .. pfUI.api.GetColoredTimeString(tradeskill_items[item_id].t)
          DEFAULT_CHAT_FRAME:AddMessage(msg_pref .. msg)
        end
      end
    end
  end

  local function CheckTradeskill()
    CheckTradeskillUsed()
  end

  local function ManualCheck()
    ManualTradeskillCheck()
    ManualItemCheck()
  end

  local function ReadyAnnounce()
    for rn in pfUI_cache["tradeskillcd"] do
      for pn in pfUI_cache["tradeskillcd"][rn] do
        for ti in pfUI_cache["tradeskillcd"][rn][pn] do
          if pfUI_cache["tradeskillcd"][rn][pn][ti] == 0 then
            ReportTradeskillReady(rn, pn, ti)
          end
        end
      end
    end
  end

  local function HookUpTooltip()

    -- hook pfPanelWidgetClock:Tooltip
    local delayTooltipHook = CreateFrame("Frame")
    local delayedExecutionTime = GetTime() + 1


    delayTooltipHook:SetScript("OnUpdate", function()

      if(delayedExecutionTime > GetTime()) then
        return
      end


      if pfUI.panel and pfPanelWidgetClock then
        --local widget_clock = getglobal("pfPanelWidgetClock")
        pfPanelWidgetClock.Old_Tooltip_tradeskillcd = pfPanelWidgetClock.Tooltip
        pfPanelWidgetClock.Tooltip = function()
          local unknown = true
          pfPanelWidgetClock.Old_Tooltip_tradeskillcd()
          GameTooltip:AddLine(" ")
          GameTooltip:AddLine(ColorText("grey", "Tradeskill Cooldowns"))
          if config.show_current == "1" then
            for ti in pfUI_cache["tradeskillcd"][realm_name][player_name] do
              local timeleft = FormatTimeleft(pfUI_cache["tradeskillcd"][realm_name][player_name][ti])
              unknown = false
              GameTooltip:AddDoubleLine(ColorText("white", " -> " .. tradeskill_list[ti].name), timeleft)
              -- GameTooltip:AddDoubleLine("|cffffffff -> " .. tradeskill_list[ti].name .. "|r", timeleft)
            end
          else
            for pn in pfUI_cache["tradeskillcd"][realm_name] do
              for ti in pfUI_cache["tradeskillcd"][realm_name][pn] do
                local timeleft = FormatTimeleft(pfUI_cache["tradeskillcd"][realm_name][pn][ti])
                unknown = false
                GameTooltip:AddDoubleLine(pn .. ColorText("white", " -> " .. tradeskill_list[ti].name), timeleft)
              end
            end
          end
          if unknown then
            GameTooltip:AddLine("Filler Tradeskill")
            pfPanelWidgetClock.Old_Tooltip_tradeskillcd()
          end
          GameTooltip:Show()
        end
      end



      this:Hide()

    end)
  end

  function pfUI.tradeskillcd:UpdateConfig()
  end

  local function SlashHandler(msg)
    local function HelpCommand()
      DEFAULT_CHAT_FRAME:AddMessage(msg_pref)
      DEFAULT_CHAT_FRAME:AddMessage("|cff33ffcc/pftc help|r - " .. "Print out all available commands")
      DEFAULT_CHAT_FRAME:AddMessage("|cff33ffcc/pftc scan|r - " .. "Perform tradeskill/item colldowns check")
      DEFAULT_CHAT_FRAME:AddMessage("|cff33ffcc/pftc status|r - " .. "Report tradeskill cooldowns status")
    end
    local commands = {
      ["help"] = function() HelpCommand() end,
      ["scan"] = function() ManualCheck() end,
      ["status"] = function() ReportTradeskillStatus() end,
    }
    if not msg or msg == "" or msg == "help" then
      commands["help"]()
    elseif not commands[msg] then
      DEFAULT_CHAT_FRAME:AddMessage(msg_pref .. "command not found, use |cff33ffcc/pftc help|r")
    else
      commands[msg]()
    end
    return
  end

  _G.SLASH_PFTC1 = "/pftc"
  _G.SlashCmdList.PFTC = SlashHandler

  -- allow external usage (GUI button)
  pfUI.tradeskillcd.Scan = ManualCheck

  pfUI.tradeskillcd:SetScript("OnEvent", function()
    if event == "VARIABLES_LOADED" then
      config = C.tradecd
      ScanSpellbook()
      HookUpTooltip()
    else
      ReadyAnnounce()
    end
  end)
  pfUI.tradeskillcd.scanner:SetScript("OnEvent", CheckTradeskill)
  pfUI.tradeskillcd.scanner:SetScript("OnUpdate", UpdateTradeskill)
  pfUI.tradeskillcd.skillmon:SetScript("OnEvent", ScanSpellbook)

end)
