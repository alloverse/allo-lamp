-- a little helper class for displaying parts of the lamp
local pl = {
    class = require("pl.class"),
}

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
return Part