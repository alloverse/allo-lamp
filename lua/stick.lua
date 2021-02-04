local vec3 = require("modules.vec3")
local pl = {
    class = require("pl.class"),
}
-- A helper view crating 2 balls with a stick between them
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
return Stick