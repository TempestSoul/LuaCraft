local tArgs = { ... }
if #tArgs < 1 then
	print( "Usage: dig <direction> <distance>" )
	return
end

local function digUp()
  turtle.digUp()
  return turtle.up()
end
local function digDown()
  turtle.digDown()
  return turtle.down()
end
local function dig()
  turtle.dig()
  return turtle.forward()
end

local tHandlers = {
	["fd"] = dig,
	["forward"] = dig,
	["forwards"] = dig,
	["bk"] = turtle.back,
	["back"] = turtle.back,
	["up"] = digUp,
	["dn"] = digDown,
	["down"] = digDown,
	["lt"] = turtle.turnLeft,
	["left"] = turtle.turnLeft,
	["rt"] = turtle.turnRight,
	["right"] = turtle.turnRight,
}

local nArg = 1
while nArg <= #tArgs do
	local sDirection = tArgs[nArg]
	local nDistance = 1
	if nArg < #tArgs then
		local num = tonumber( tArgs[nArg + 1] )
		if num then
			nDistance = num
			nArg = nArg + 1
		end
	end
	nArg = nArg + 1

	local fnHandler = tHandlers[string.lower(sDirection)]
	if fnHandler then
		while nDistance > 0 do
			if fnHandler() then
				nDistance = nDistance - 1
			elseif turtle.getFuelLevel() == 0 then
				print( "Out of fuel" )
				return
			else
				sleep(0.5)
			end
		end
	else
		print( "No such direction: "..sDirection )
		print( "Try: forward, back, up, down" )
		return
	end

end
