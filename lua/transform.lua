local mat4 = require("modules.mat4")
local vec3 = require("modules.vec3")
local pl = {
    class = require("pl.class"),
}

-- A helper for managing position, rotation, scaling
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

return Transform