-- an implementation of 'strict tables'
-- http://snippets.luacode.org/snippets/Strict_Tables_132
-- some support functions

local function field_not_found(tbl,key,name)
    error("field '"..key.."' is not in "..(name or getmetatable(tbl)._name),2)
end

local function equals (s1,s2) -- naive memberwise comparison
    for k,v in pairs(s1) do
        if s2[k] ~= v then return false end
    end
    return true
end

local function _tostring(tbl) -- default function to convert to string
    local strs = {}
    for k,v in pairs(tbl) do
        table.insert(strs,k.."="..tostring(v))
    end
    return ('%s {%s}'):format(getmetatable(tbl)._name,table.concat(strs,','))
end

local function _type (o) -- type for tables is their metatable!
    local t = type(o)
    if t == 'table' then return getmetatable(t) end
    return t
end

local function _typename (o) -- use the _name for metatables if available
    local t = _type(o)
    if type(t) ~= 'string' then
        t = t._name or tostring(t)
    end
    return t
end

--- defining a strict table constructor ---
local ctor_mt = {
  -- instances can be created by calling the strict object
  __call = function(smt,t)
    local obj = t or {}  -- pass it a table (or nothing)
    local fields = smt._fields
    -- attempt to set a non-existent/wrong-type field in ctor?
    for k,v in pairs(obj) do
            local f = fields[k]
      if not f then
        field_not_found(nil,k,smt._name)
            elseif _type(f) ~= _type(v) then
                error("field '"..k.."' must be of type ".._typename(f),2)
      end
    end
    -- fill in any default values if not supplied
    for k,v in pairs(fields) do
      if not obj[k] then
        obj[k] = v
      end
    end
        setmetatable(obj,smt)
    return obj
  end;
}

-- creating a new strict table triggered by strict.NAME {FIELDS}
local Strict = { type = _type }

function Strict.arg (Type,o)
    if getmetatable(o) == Type then
        return o
    else
        return Type(o)
    end
end

setmetatable(Strict,{
  __index = function(tbl,sname)
    -- return a function that creates the table from its fields
    return function(spec)
            -- we re-use the spec as our metatable, so __tostring etc can be overriden
            local smt = spec
            -- and put the strict in the enclosing context
            local context = __ENV or _G
            context[sname] = smt
            -- the strict table has a callable constructor
            setmetatable(smt,ctor_mt)
            -- provide a default memberwise equals if requested
            if smt.__eq == true then
                smt.__eq = equals
            end
            -- provide a default tostring if not specified
            if not smt.__tostring then
                smt.__tostring = _tostring
            end
            -- can provide a sort order by giving the key to compare on
            if type(smt.__lt) == 'string' then
                local key = smt.__lt
                smt.__lt = function(t1,t2)
                    return t1[key] < t2[key]
                end
            end
            -- a strict table's fields may not contain functions!
            local fields = {}
            for k,v in pairs(smt) do
                if type(v) ~= 'function' then
                    fields[k] = v
                end
            end
            smt._fields = fields
            -- reading or writing an undefined field of this table is an error
            smt.__index = field_not_found
            smt.__newindex = field_not_found
            smt._name = sname
    end
  end
})

return Strict
