Set = {}

Set.mt = {}

function Set.new(t)
    local set = {}
    setmetatable(set, Set.mt)
    for _, l in ipairs(t) do set[l] = true end
    return set
end

function Set.union(a,b)
    local res = Set.new{}
    for k in pairs(a) do res[k] = true end
    for k in pairs(b) do res[k] = true end
    return res
end

function Set.intersection(a,b)
    local res = Set.new{}
    for k in pairs(a) do
        res[k] = b[k]
    end
    return res
end

function Set.xor(a,b)
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

function Set.tostring(set)
    local s = "{"
    local sep = " "
    for e in pairs(set) do
        s = s .. sep .. e
        sep = ", "
    end
    return s .. "}"
end

function Set.print(s)
    print(Set.tostring(s))
end

Set.mt.__add = Set.union
Set.mt.__mul = Set.intersection
Set.mt.__div = Set.xor








s1 = Set.new({10, 20, 30, 50})
s2 = Set.new({30, 1})
Set.print(s1)
Set.print(s2)
s3 = s1 + s2
Set.print(s3)
Set.print(s3*s1*s2)
Set.print(s1/s2)

