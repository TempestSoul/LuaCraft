local tArgs = { ... }
if #tArgs ~= 1 then
	-- Usage and quit
	print "Usage: remote <master|slave>"
	return
end

local role = tArgs[1]
local name = os.getComputerLabel()

local function findModem()
	local sides = { "left", "right", "back", "front", "top", "bottom" }
	for n = 1, #sides do
		if "modem" == peripheral.getType(sides[n]) then
			return sides[n]
		end
	end
end

local function sendCommand(cmd)
  local iStart, iEnd, target = string.find(cmd,"(%w+):%s*")
  if not iStart then
    rednet.broadcast(cmd, "task")
  else
    local id = rednet.lookup("task",target)
    if not id then
      print(target.." is not a valid name")
    else
      rednet.send(id, string.sub(cmd, iEnd), "task")
    end
  end
end

local function master()
	print "Enter a command to run on any slaves"
	local cmd
	repeat
		-- for true status updates, need a timer & pullEvent loop
		cmd = io.read()
  		sendCommand(cmd)
		local id, ack, num = rednet.receive("ack", 5)
		if id then
			print("Received by "..id..": "..ack)
		else
			print("Not acknowledged")
		end
	until cmd == "exit"
	print "Shutting down"
end

local function status()
	return "Not implemented"
end

local function slave()
	if name then
		rednet.host("task", name)
		print(name.." listening for commands")
	else
		print "Listening for commands"
	end
	local id, cmd, num = rednet.receive("task")
	while cmd ~= "exit" do
		rednet.send(id, "Starting "..cmd,"ack")
		if cmd == "status" then
			rednet.send(id, status(),"ack")
		else
			shell.run(cmd)
		end
		rednet.broadcast("finished "..cmd,"ack")
		id, cmd, num = rednet.receive("task")
	end
	print "Exiting..."
	if name then
		rednet.broadcast(name.." signing off", "task")
		rednet.unhost("task",name)
	end
end

local modemSide = findModem()
if modemSide then
  print("Opening modem on side "..modemSide)
  rednet.open(modemSide)
else
  print("No modem detected")
  return
end
term.clear()
term.setCursorPos(1,1)
if role == "master" then
	print "Starting as master"
	master()
elseif role == "slave" then
	print "Starting as slave"
	slave()
else
	print "Argument must be either master or slave"
end
print("Closing modem on side "..modemSide)
rednet.close(modemSide)
