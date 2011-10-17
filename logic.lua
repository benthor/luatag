Set = {}

Set.mt = {}

function Set.new(t)
    local set = {}
    setmetatable(set, Set.mt)
    for _, l in ipairs(t) do set[l] = true end
    return set
end

-- this was Set.union
function Set.mt.__add(a,b)
    local res = Set.new{}
    for k in pairs(a) do res[k] = true end
    for k in pairs(b) do res[k] = true end
    return res
end

-- this was Set.intersection
function Set.mt.__mul(a,b)
    local res = Set.new{}
    for k in pairs(a) do
        res[k] = b[k]
    end
    return res
end

-- this was Set.xor
function Set.mt.__div(a,b)
    local res = Set.new{}
    for k in pairs(a) do
        if not b[k] then
            res[k] = a[k]
        end
    end
    for k in pairs(b) do 
        if not a[k] then
            res[k] = b[k]
        end
    end
    return res
end

function Set.mt.__le(a, b)
    for k in pairs(a) do
        if not b[k] then
            return false
        end
    end
    return true
end

function Set.mt.__lt(a,b)
    return a <= b and not (b <= a)
end

function Set.mt.__eq(a,b)
    return a <= b and b <= a
end

function Set.mt.__tostring(set)
    local s = "{"
    local sep = " "
    for e in pairs(set) do
        s = s .. sep .. e
        sep = ", "
    end
    return s .. " }"
end

-- TaOb => shorthand for TaggedObject
TaOb = {}

TaOb.mt = {}

function TaOb.new(URL, tags)
    taob = {}
    setmetatable(taob, TaOb.mt)
    taob.tags = tags
    taob.URL = URL
    return taob
end



s1 = Set.new({10, 20, 30, 50})
s2 = Set.new({30, 1})
print(s1)
print(s2)
s3 = s1 + s2
print(s3)
print(s3*s1*s2)
print(s1/s2)

s1 = Set.new{2,4}
s2 = Set.new{2,10,4}

print(s1 == s2 * s1)
print(s1)
print(s1 * s2)

