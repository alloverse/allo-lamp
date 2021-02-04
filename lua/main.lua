local mat4 = require("modules.mat4")
local vec3 = require("modules.vec3")
local ui = require("allo.deps.alloui.lua.alloui.ui")
local pl = {
    pretty = require("pl.pretty"),
    class = require("pl.class"),
}

local client = Client(
    arg[2], 
    "lamp"
)
local app = ui.App(client)

Transform = require 'transform'
Part = require 'part'
Stick = require 'stick'

-- The chandelier is built up of several sticks with balls, and a post
Lamp = pl.class.Lamp(Part)
function Lamp:_init(ball, stick, bounds)
    self:super(nil, bounds)

    local post = Part(stick)
    post.t:scale(0.02, 1, 0.02)
    post.t:position(0, 0, 0)

    self.views = {
        Stick(ball, stick, -1),
        Stick(ball, stick, -1+0.3, 1.5, 0.2),
        Stick(ball, stick, -1+0.6, 2, -0.1),
        post,
    }

    for _, view in pairs(self.views) do 
        self:addSubview(view)
    end
end
function Lamp:animate()
    for _, view in ipairs(self.views) do
        view:animate()
    end
end

-- load the needed assets
local asset = {
    ball = Asset.File("asset/ball.glb"),
    stick = Asset.File("asset/stick.glb"),
}

app.assetManager:add(asset)

local lamp = Lamp(asset.ball, asset.stick, ui.Bounds(0,2.9,-5.8,2,2,2))
lamp.grabbable = true -- makes it movable
app.mainView:addSubview(lamp)

-- run the animation
app:scheduleAction(0.1, true, function ()
    lamp:animate()
end)

if app:connect() then app:run() end