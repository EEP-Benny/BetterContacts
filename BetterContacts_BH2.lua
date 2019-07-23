local betterContacts = {
  _VERSION     = { 1, 0, 0 },
  _DESCRIPTION = 'Funktionsaufrufe mit Parametern (und mehr) in Kontaktpunkten',
  _URL         = 'https://github.com/EEP-Benny/BetterContacts',
  _LICENSE     = "MIT",
}

-- local variables, will be filled later
local queryOldIndex, getNewKey, templateString

local function doNothing(key)
  return key
end
local function replaceCommas(key)
  return string.gsub(key, "%.", ",")
end

local options = {
  replaceCommas = false,
  varname = "Zugname",
  chunkname = "KP-Eintrag",
}
betterContacts.getOptions = function() return options end
betterContacts.setOptions = function(newOptions)
  if type(newOptions) == "table" then
    if type(newOptions.replaceCommas) == "boolean" then
      options.replaceCommas = newOptions.replaceCommas
    end
    if type(newOptions.varname) == "string" then
      options.varname = newOptions.varname
    end
    if type(newOptions.chunkname) == "string" then
      options.chunkname = newOptions.chunkname
    end
  end
  
  -- update local variables
  getNewKey = options.replaceCommas and replaceCommas or doNothing
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
    return nil
  end
  local newKey = getNewKey(key)
  local parsed=load(string.format(templateString, newKey), options.chunkname)
  if parsed then
    local myFunction=parsed()
    _ENV[key]=myFunction
    return myFunction
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
