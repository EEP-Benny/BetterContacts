local betterContacts = {
  _VERSION     = { 1, 0, 0 },
  _DESCRIPTION = 'Funktionsaufrufe mit Parametern (und mehr) in Kontaktpunkten',
  _URL         = 'https://github.com/EEP-Benny/BetterContacts',
  _LICENSE     = "MIT",
}

-- local variables, will be filled later
local queryOldIndex, getNewKey, templateString

local function passThrough(key)
  return key
end
local function replaceDots(key)
  return string.gsub(key, "%.", ",")
end

local options = {
  printErrors = false,
  replaceDots = false,
  varname = "Zugname",
  chunkname = "KP-Eintrag",
}
betterContacts.getOptions = function() return options end
betterContacts.setOptions = function(newOptions)
  if type(newOptions) == "table" then
    -- transfer new options to local option table
    for key, newValue in pairs(newOptions) do
      local oldType = type(options[key])
      local newType = type(newValue)
      if newType == oldType then
        options[key] = newValue
      elseif oldType == "nil" then
        local message = string.format("Unbekannte Option '%s' (mit dem Wert %s)", key, newValue)
        error(message, 2)
      else
        local message = string.format("Die Option '%s' muss vom Typ %s sein, aber ist vom Typ %s", key, oldType, newType)
        error(message, 2)
      end
    end
  end
  
  -- update local variables
  getNewKey = options.replaceDots and replaceDots or passThrough
  templateString = "return function(" .. options.varname .. ") %s end"
end
betterContacts.setOptions() -- initialize local variables from default options

local mt = getmetatable(_ENV) or {}
setmetatable(_ENV, mt)

local oldIndex = mt.__index
if type(oldIndex) == "function" then
  queryOldIndex = oldIndex
elseif type(oldIndex) == "table" then
  queryOldIndex = function(self, key) return oldIndex[key] end
else
  queryOldIndex = function(self, key) return nil end
end

local function parseKey(self, key)
  if not string.find(key, "[^%w_]") then
    -- skip keys which only contain letters, numbers and underscores
    -- (those can be variable names, but not valid expressions)
    -- otherwise, we would get a "syntax error" for each missing global variables
    return nil
  end
  local newKey = getNewKey(key)
  local parsed, message = load(string.format(templateString, newKey), options.chunkname)
  if parsed then
    local myFunction = parsed()
    _ENV[key] = myFunction
    return myFunction
  elseif options.printErrors then
    print(message)
  end
  return nil
end

mt.__index = function(self, key)
  return parseKey(self, key) or queryOldIndex(self, key)
end

setmetatable(betterContacts, {
  __call = function(_, newOptions)
    return betterContacts.setOptions(newOptions)
  end
})

return betterContacts
