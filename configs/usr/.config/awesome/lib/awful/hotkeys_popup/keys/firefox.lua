local hotkeys_popup = require("lib.awful.hotkeys_popup.widget")
local fire_rule = { class = { "firefox" } }
for group_name, group_data in pairs({
    ["#Firefox: tabs"] = { color = "#009F00", rule_any = fire_rule }
}) do
    hotkeys_popup.add_group_rules(group_name, group_data)
end

local firefox_keys = {

    ["#Firefox: tabs"] = {{
        modifiers = {  },
        keys = {
            ["F1"] = "toggle tabs"
        }
    },{
        modifiers = { "Mod1" },
        keys = {
            ["1..9"] = "go to tab"
        }
    }, {
        modifiers = { "Ctrl" },
        keys = {
            t = "new tab",
            w = 'close tab',
            ['Tab'] = "next tab"
        }
    }, {
        modifiers = { "Ctrl", "Shift" },
        keys = {
          ['Tab'] = "previous tab"
        }
    }}
}

hotkeys_popup.add_hotkeys(firefox_keys)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
