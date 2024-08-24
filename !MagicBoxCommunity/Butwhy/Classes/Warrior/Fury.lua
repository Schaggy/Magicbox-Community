local  addon, dark_addon = ...
local support = dark_addon.support

local SB = {}
local Fury = {}

Fury.stuff = function()

end

local function combat()
end

local function resting()
if castable(6673) and player.buff(6673).down then
	cast(6673)
	return true
end
end



local function interface()
local settings = {
	key = "fury_community",
    title = "Fury Warrior",
    width = 360,
    height = 620,
    resize = true,
    show = false,
    template = {
		{type = "header", text = 'Fury Warrior', align='center'},
		
	}

}

  configWindow = dark_addon.interface.builder.buildGUI(settings)

  dark_addon.interface.buttons.add_toggle({
    name = 'settings',
    label = 'Rotation Settings',
    font = 'dark_addon_icon',
    on = {
      label = dark_addon.interface.icon('cog'),
      color = dark_addon.interface.color.warrior_brown,
      color2 = dark_addon.interface.color.warrior_brown
    },
    off = {
      label = dark_addon.interface.icon('cog'),
      color = dark_addon.interface.color.red,
      color2 = dark_addon.interface.color.red
    },
    callback = function(self)
      if configWindow.parent:IsShown() then
        configWindow.parent:Hide()
      else
        configWindow.parent:Show()
      end
    end
  })
end

dark_addon.rotation.register(
  {
    spec = dark_addon.rotation.classes.warrior.fury,
    name = "fury",
    label = "",
    combat = combat,
    resting = resting,
    interface = interface
  }
)

for _, func in pairs(Fury) do
    setfenv(func, dark_addon.environment.env)
end
 
