local betterContacts = {
  _VERSION     = { 1, 0, 0 },
  _DESCRIPTION = 'Funktionsaufrufe mit Parametern (und mehr) in Kontaktpunkten',
  _URL         = 'https://github.com/EEP-Benny/BetterContacts',
  _LICENSE     = "MIT",
}

-- local variables, will be filled later
local queryOldIndex, getNewKey, templateString

betterContacts.options = {
  replaceCommas = false,
  varname = "Zugname",
  chunkname = "KP-Eintrag",
}
betterContacts.setOptions = function(newOptions)
  if type(newOptions) == "table" then
    --TODO: set options from newOptions
  end
  
  -- update local variables
  templateString = "return function(" .. betterContacts.options.varname .. ") %s end"
  if betterContacts.options.replaceCommas then
    getNewKey = function(key) return k:gsub("%.",",") end
  else
    getNewKey = function(key) return key end
  end
end
betterContacts.setOptions()

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
  local newKey = getNewKey(key)
  local parsed=load(string.format(templateString, newKey), betterContacts.options.chunkname)
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
