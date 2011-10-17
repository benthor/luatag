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

function set_test()
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



-- the heart of the tagging system

World = {}

-- tags as k,v pairs, k -> tag, v -> a set of object indices, see below
World.tags = {}

-- a set of all tags as seen in the world
World.tagset = Set.new{}

-- ipairs, indices -> objects
World.objects = {}

-- for bidirectional completeness
-- objects -> indices
World.indices = {}

-- add tags for a given id
-- warning: it is not checked if object with id actually exists
function World.add_tags_for_id(id, ...)
    for _,tag in ipairs(arg) do
        id_set = World.tags[tag] or Set.new{}
        id_set = id_set + Set.new{object_id}
        World.tags[tag] = id_set
        -- also add all tags to the world
        -- FIXME there is some redundancy here. Room for optimization
        World.tagset = World.tagset + id_set
    end
end    

-- add a table/object to the world, with an arbitrary number of tags
function World.add_object_to_tags(t, ...)
    -- add object to world
    table.insert(World.objects, t)
    -- new World.objects table length is new object ID, equals its index
    object_id = # World.objects
    -- store index
    World.indices[t] = object_id
    -- add any tags which might have been specified to the world
    World.add_tags_for_id(object_id, unpack(arg))
end

-- add (additional) tags to object
function World.add_tags_to_object(t, ...)
    local object_id = World.indices[t]
    World.add_tags_for_id(object_id)
end

-- return a Set of those object indices which share the specified tags
function World.limit_to_tags(...)
    local res = World.tagset
    for _,tag in ipairs(arg) do
        -- protect against bogus tags
        id_set = World.tags[tag] or Set.new{}
        res = res * id_set
    end
    return res
end


function dbgfnc(func, input, expected_output)
    print("input: " .. tostring(input) .. " -> expected output: " .. expected_output .. " -> result: " .. tostring(func(input)))
end

t1 = {"foobar"}
t2 = {"barfoospameggs"}
t3 = {"spameggs"}
t4 = {"nothing"}

World.add_object_to_tags(t1, "foo", "bar")
World.add_object_to_tags(t2, "bar", "foo", "spam", "eggs")
World.add_object_to_tags(t3, "spam", "eggs")
World.add_object_to_tags(t4)

dbgfnc(World.limit_to_tags, "foo", "1, 2")
dbgfnc(World.limit_to_tags, "eggs", "2, 3")
dbgfnc(World.limit_to_tags, "nothing", "{ }")
dbgfnc(World.limit_to_tags, nil, "{1, 2, 3, 4} -> oh crap!")


