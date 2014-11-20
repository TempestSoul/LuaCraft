-- try to draw a Bresenham dragon
local tArgs = { ... }
local limit = 0
if #tArgs > 1 then
	print("Usage: fractal [steps]")
	return
elseif #tArgs == 1 then
	limit = tonumber(tArgs[1])
end

local xPos,zPos = 0,0
local xDir,zDir = 0,1

local function turnLeft()
	turtle.turnLeft()
	xDir, zDir = -zDir, xDir
end

local function turnRight()
	turtle.turnRight()
	xDir, zDir = zDir, -xDir
end

local function forward()
	turtle.forward()
	xPos, zPos = xPos + xDir, zPos + zDir
end

local function dragon(n)
	-- returns true if turning left, else turn right
	local lastBit = bit.band(n, -n)
	return bit.band(n, bit.blshift(lastBit, 1)) ~= 0
end

local function place()
	if turtle.getItemCount() == 0 then
		local n = 1
		while n <= 16 and 0 == turtle.getItemCount(n) do
			n = n + 1
		end
		if n > 16 then
			return false
		else
			turtle.select(n)
		end
	end
	if not turtle.compareDown() then
		turtle.digDown()
		turtle.placeDown()
	end
	return true
end

local function step(blocks)
	-- move forward <blocks> blocks, placing blocks as we go
	for n = 1,blocks do
		if turtle.detectDown() then
			turtle.digDown()
		end
		if place() then
			forward()
		else
			print("Out of blocks, stopping")
			return false
		end
	end
	return true
end

local nSteps = 1
while 0 < turtle.getFuelLevel() and step(2) do
	if dragon(nSteps) then
		turnLeft()
	else
		turnRight()
	end
	nSteps = nSteps + 1
	if limit > 0 and nSteps > limit then
		print("All done!")
		return
	end
end
	