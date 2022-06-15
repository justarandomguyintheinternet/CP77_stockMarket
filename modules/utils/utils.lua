miscUtils = {}

function miscUtils.deepcopy(origin)
	local orig_type = type(origin)
    local copy
    if orig_type == 'table' then
        copy = {}
        for origin_key, origin_value in next, origin, nil do
            copy[miscUtils.deepcopy(origin_key)] = miscUtils.deepcopy(origin_value)
        end
        setmetatable(copy, miscUtils.deepcopy(getmetatable(origin)))
    else
        copy = origin
    end
    return copy
end

function miscUtils.indexValue(table, value)
    local index={}
    for k,v in pairs(table) do
        index[v]=k
    end
    return index[value]
end

function miscUtils.has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function miscUtils.getIndex(tab, val)
    local index = nil
    for i, v in ipairs(tab) do
		if v == val then
			index = i
		end
    end
    return index
end

function miscUtils.removeItem(tab, val)
    table.remove(tab, miscUtils.getIndex(tab, val))
end

function miscUtils.split(s, delimiter) --https://www.codegrepper.com/code-examples/lua/lua+split+string+by+space
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function miscUtils.isSameInstance(a, b)
	return Game['OperatorEqual;IScriptableIScriptable;Bool'](a, b)
end

function miscUtils.remap(value, low1, high1, low2, high2) -- Made by github copilot
    return low2 + (value - low1) * (high2 - low2) / (high1 - low1)
end

function miscUtils.playSound(name, mult)
    local m = mult or 1

    for _ = 1, m do
        local audioEvent = SoundPlayEvent.new ()
        audioEvent.soundName = name
        GetPlayer():QueueEvent(audioEvent)
    end
end

return miscUtils