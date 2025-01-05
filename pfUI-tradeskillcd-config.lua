--                MODULE        SUBGROUP       ENTRY               VALUE
-- pfUI:UpdateConfig("module_template", nil, nil, 0)

-- load pfUI environment
setfenv(1, pfUI:GetEnvironment())

function pfUI.tradeskillcd:LoadConfig()
  pfUI:UpdateConfig("tradecd",    nil,           "startup_announce", "1")
  pfUI:UpdateConfig("tradecd",    nil,           "show_remaining",   "1")
  pfUI:UpdateConfig("tradecd",    nil,           "show_current",     "0")
  pfUI:UpdateConfig("tradecd",    nil,           "noti_chat",        "1")
  pfUI:UpdateConfig("tradecd",    nil,           "noti_ready_rw",    "1")
  pfUI:UpdateConfig("tradecd",    nil,           "noti_ready_sound", "1")
  pfUI:UpdateConfig("tradecd",    nil,           "button",           "default")
end

pfUI.tradeskillcd:LoadConfig()
