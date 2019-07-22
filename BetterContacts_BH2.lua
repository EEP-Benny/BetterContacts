local betterContacts = {
  _VERSION     = { 1, 0, 0 },
  _DESCRIPTION = 'Funktionsaufrufe mit Parametern (und mehr) in Kontaktpunkten',
  _URL         = 'https://github.com/EEP-Benny/BetterContacts',
  _LICENSE     = "MIT",
}

betterContacts.options = {
  
}
betterContacts.setOptions = function(newOptions)
  --TODO
end

local mt = getmetatable(_ENV) or {}
setmetatable(_ENV, mt)

local oldIndex = mt.__index
local function queryOldIndex(self, key)
  if type(oldIndex) == "table" then
    return oldIndex[key]
  elseif type(oldIndex) == "function" then
    return oldIndex(self, key)
  else
    return nil
  end
end

local function parseKey(self, key)
  local parsed=load("return function(Zugname) " .. key .. " end")
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
