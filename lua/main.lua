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

Transform = pl.class()
function Transform:_init()
    self._m = mat4:identity()
    self._position = vec3()
    self._scale = vec3(1, 1, 1)
    self._rotation = {angle = 0, axis = vec3()}
end

function Transform:mat4()
    local m = mat4.identity()
    m:scale(m, self._scale)
    m:rotate(m, self._rotation.angle, self._rotation.axis)
    m:translate(m, self._position)
    return m
end

function Transform:position(x, y, z)
    if x and y and z then 
        self._position = vec3(x, y, z)
    else
        self._position = x        
    end
    return self._position
end

function Transform:scale(x, y, z)
    if x and y and z then
        self._scale = vec3(x, y, z)
    elseif x and type(x) == "number" then
        self._scale = vec3(x, x, x)
    else
        self._scale = x
    end
    return self._scale
end

function Transform:rotation(angle, axis)
    if angle and axis then
        self._rotation.angle = angle
        self._rotation.axis = axis
    end
    return self._rotation.angle, self._rotation.axis
end

Part = pl.class.Part(AssetView)
function Part:_init(asset, bounds)
    self:super(asset, bounds)
    self.t = Transform()
    self.color = {0,0,1}
    self.time = math.random()
end

function Part:specification()
    self:setTransform(self.t:mat4())
    local spec = AssetView.specification(self)

    spec.material = {
        color =  self.color,
        shader_name = "pbr",
    }
    return spec
end
function Part:animate()
    self.time = self.time + 0.01
    self:setTransform(self.t:mat4())
    self.color = {1 + 0.5*math.cos(self.time*self.time), 1 + 0.5*math.sin(self.time + self.time), 1 + 0.5*math.cos(self.time + 10)}
    self:updateComponents({
        material = self:specification().material
    })
    return AssetView.specification(self)
end

Stick = pl.class.Stick(Part)
function Stick:_init(ball, stick, y, r, off)
    self:super()

    self.time = r or 0
    off = off or 0

    self.t:position(0, y or 1, 0)
    self.t:rotation(0, vec3(0, 1, 0))

    self.ball1 = Part(ball)
    self.ball2 = Part(ball)
    self.stick = Part(stick)

    self.ball1.t:scale(0.2)
    self.ball1.t:position(0, 0, -0.6 + off)
    self.ball2.t:scale(0.2)
    self.ball2.t:position(0, 0, 0.6 + off)
    self.stick.t:position(0, 0, off)
    self.stick.t:scale(vec3(0.02, 0.5, 0.02))
    self.stick.t:rotation(3.14/2, vec3(1, 0, 0))

    self:addSubview(self.ball1)
    self:addSubview(self.ball2)
    self:addSubview(self.stick)
end

function Stick:animate()
    self.time = self.time + 0.01
    local _, axis = self.t:rotation()
    self.t:rotation(math.sin(self.time) * 2, axis)
    self:setTransform(self.t:mat4())

    self.ball1:animate()
    self.ball2:animate()
    self.stick:animate()
end


Lamp = pl.class.Lamp(Part)
function Lamp:_init(ball, stick, bounds)
    self:super(nil, bounds)

    local holder = Part(stick)
    holder.t:scale(0.02, 1, 0.02)
    holder.t:position(0, 0, 0)

    self.views = {
        Stick(ball, stick, -1),
        Stick(ball, stick, -1+0.3, 1.5, 0.2),
        Stick(ball, stick, -1+0.6, 2, -0.1),
        holder,
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

local asset = {
    ball = Asset.File("asset/ball.glb"),
    stick = Asset.File("asset/stick.glb"),
}

app.assetManager:add(asset)

local lamp = Lamp(asset.ball, asset.stick, ui.Bounds(0,2.9,-5.8,2,2,2))
lamp.grabbable = true
app.mainView:addSubview(lamp)

app:scheduleAction(0.1, true, function ()
    lamp:animate()
end)

if app:connect() then app:run() end