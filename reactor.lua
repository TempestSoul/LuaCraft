local peri = peripheral.getNames()
local reactorName, monitorSide
for i = 1,#peri do
  local type = peripheral.getType(peri[i])
  --print('found '..type)
  if type == 'BigReactors-Reactor' then
    reactorName = peri[i]
  elseif type == 'monitor' then
    monitorSide = peri[i]
  end
end

if not reactorName then
  print("No reactor found")
  return
end

local function createLabel(parent, labelTxt, x, y, width, height)
  local label = window.create(parent,x,y,width,height)
  label.write(labelTxt)
  return label
end

local function regulatePower(reactor, maxPower)
  local power = reactor.getEnergyStored()
  if power < maxPower * 0.2 and not reactor.getActive() then
    reactor.setActive(true)
  elseif power > maxPower * 0.8 and reactor.getActive() then
    reactor.setActive(false)
  end
end

local function displayStats(display, tblStats)
  display.clear()
  local line = 1
	for key, value in pairs(tblStats) do
  display.setCursorPos(1,line)
  local printed = string.format("%24s: %15s",tostring(key),tostring(value))
		display.write(printed)
  line = line + 1
	end
end

local screen = term.current()
if monitorSide then
  screen = peripheral.wrap(monitorSide)
end
screen.setBackgroundColor(colors.black)
screen.clear()
screen.setCursorPos(1,1)

local reactor = peripheral.wrap(reactorName)
local maxPower = 10000000

while true do
  regulatePower(reactor, maxPower)
  local stats = {}
  stats.Active = reactor.getActive()
  stats.StoredPower = reactor.getEnergyStored()
  stats.FuelTemp = reactor.getFuelTemperature()
  stats.CasingTemp = reactor.getCasingTemperature()
  stats["Energy Prod. Last Tick"] = reactor.getEnergyProducedLastTick()
  stats.FuelConsumedLastTick = reactor.getFuelConsumedLastTick()
  stats.Reactivity = reactor.getFuelReactivity()
  displayStats(screen, stats)
  os.sleep(0.5)
end
