local core = {}

core.internal = {}

core.internal.system = {}
core.internal.system.loaded = {}
core.internal.system.active = {}

core.internal.state = {}
core.internal.state.loaded = {}
core.internal.state.current = {}

core.internal.callbackList = {
    "draw","focus","gamepadaxis","gamepadpressed","gamepadreleased","joystickadded","joystickaxis","joystickhat","joystickpressed","joystickreleased","joystickremoved",
    "keypressed","keyreleased","load","mousefocus","mousemoved","mousepressed","mousereleased","quit","resize","textinput","threaderror","update","visible"
}

local function callbackHandler(callback,...)
	local toCall = {}
	local highest = 1
	for systemKey, systemVal in pairs(core.internal.system.active) do
		if type(systemVal[callback]) == "function" then
			local priority = highest
			if type(systemVal.prioritys) == "table" then priority = systemVal.prioritys[callback] or highest+1 else priority = highest+1 end
			highest = math.max(highest, priority)
			toCall[priority] = systemVal[callback]
		end
	end
	for callbackPriority, callbackVal in pairs(toCall) do callbackVal(...) end
end

function core.registerSystem(systemKey,system)
	if not core.internal.system.loaded[systemKey] then
		core.internal.system.loaded[systemKey] = system
		_G[systemKey] = system
		print("Registered System '"..systemKey.."'")
	end
end

function core.activateSystem(systemKey)
	if type(core.internal.system.loaded[systemKey]) == "table" and not core.internal.system.active[systemKey] then
		core.internal.system.active[systemKey] = core.internal.system.loaded[systemKey]
		print("Activated System '"..systemKey.."'")
	end
end

function core.deactivateSystem(systemKey)
	if type(core.internal.system.active[systemKey]) == "table" then
		core.internal.system.active[systemKey] = nil
		print("Deactivated System '"..systemKey.."'")
	end
end

function core.registerStates(states)
	for stateKey, stateVal in pairs(states) do
		core.registerState(stateKey, stateVal)
	end
end

function core.registerState(stateKey,stateSystems)
	if not core.internal.state.loaded[stateKey] then
		core.internal.state.loaded[stateKey] = {name=stateKey,systems=stateSystems}
		print("Registered State '"..stateKey.."'")
	end
end

function core.loadState(stateKey)
	if type(core.internal.state.loaded[stateKey]) == "table" then
		for systemKey, systemVal in pairs(core.internal.system.active) do
			if type(systemVal.onStateClose) == "function" then systemVal.onStateClose(core.internal.state.current.name) end
		end
		local state = core.internal.state.loaded[stateKey]
		core.internal.state.current = state
		core.internal.system.active = {}
		for systemIndex, systemKey in pairs(state.systems) do
			local system = core.internal.system.loaded[systemKey]
			if type(system.onStateLoad) == "function" then system.onStateLoad(stateKey) end
			core.internal.system.active[systemKey] = system
		end
		print("Loaded State '"..stateKey.."'")
	end
end

function core.registerCallbacks(callbacks)
	for callbackKey, callbackVal in pairs(callbacks) do
		core.registerCallback(callbackVal)
	end
end

function core.registerCallback(callback)
	love[callback] = function(...) callbackHandler(callback, ...) end
	print("Registered Callback '"..callback.."'")
end

core.registerCallbacks(core.internal.callbackList)

return core