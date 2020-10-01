local betterContacts = {
  _VERSION     = { 1, 1, 0 },
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
  printVersionInfo = false,
  printErrors = false,
  replaceDots = false,
  varname = "Zugname",
  varnameTrackID = "",
  chunkname = "KP-Eintrag",
  preventReturn0 = true,
  deprecatedUseGlobal = false,
}
betterContacts.getOptions = function() return options end
betterContacts.setOptions = function(newOptions)
  if type(newOptions) == "table" then
    -- if printVersionInfo changes from false to true, print the version info
    if newOptions.printVersionInfo and not options.printVersionInfo then
      print("BetterContacts_BH2 v".. table.concat(betterContacts._VERSION, ".").. " wurde eingebunden.")
    end
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
  if options.deprecatedUseGlobal then
    -- local function p is neccessary to prevent shadowing of variables z and s
    templateString = "local p=function() %s end;return function(z) local s=Zugname;Zugname=z;p();Zugname=s end;"
  else
    local params = options.varname
    if options.varnameTrackID ~= "" then 
      params = params .. "," .. options.varnameTrackID
    end
    templateString = "return function(" .. params .. ") %s end"
  end
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

-- low-effort mid-safety solution against return 0 in EEPMain
-- doesn't work if there is already a __newindex (correctly invoking that one is too complicated)
-- doesn't work if EEPMain is defined multiple times (__newindex is only called when a value is set for the first time)
mt.__newindex = mt.__newindex or function(self, key, value) -- if there is already a function, don't define a new one

  -- overwrite EEPMain with a wrapper function that checks for return 0
  if key == "EEPMain" and options.preventReturn0 then
    local oldEEPMain = value
    local warningWasAlreadyShown = false
    value = function()
      local returnValue = oldEEPMain()
      if returnValue == 0 then
        returnValue = 1  -- return 1 instead to let Lua run continuously
        if not warningWasAlreadyShown then
          print("\nAchtung!\nBetterContacts hat verhindert, dass die EEPMain mittels return 0 beendet wird.\nBitte passe dein Lua-Skript so an, dass die EEPMain **immer** mit return 1 beendet wird.\n")
          warningWasAlreadyShown = true -- prevent flooding the event window
        end
      end
      return returnValue
    end
  end
  rawset(_ENV, key, value) -- store the value in _ENV[key] without invoking this function again
end

setmetatable(betterContacts, {
  __call = function(_, newOptions)
    return betterContacts.setOptions(newOptions)
  end
})

return betterContacts
