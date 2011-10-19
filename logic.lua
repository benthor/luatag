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

-- return set a minus all elements it shared with b
function Set.mt.__sub(a,b)
    return a / (b * a)
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
    print(s1-s2)
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

-- the heart of the tagging system
NS = {}

NS.DB = {}

-- tags as k,v pairs, k -> tag, v -> a set of object indices, see below
NS.DB.tags = {}

-- a set of all object indices as seen in the world
NS.DB.all_indices = Set.new{}

-- ipairs, index -> object
NS.DB.objects = {}

-- for bidirectional completeness
-- object -> index
NS.DB.indices = {}

-- for bidirectional completeness
-- object_id -> tagset
NS.DB.tagsets = Set.new{}

-- add tags for a given id
-- warning: it is not checked if object with id actually exists
function NS:_tag_id(id, ...)
    if # arg == 0 then
        error("should define at least one tag for now, the system currently doesn't handle untagged objects very well")
    end
    for _,tag in ipairs(arg) do
        local id_set = self.DB.tags[tag] or Set.new{}
        id_set = id_set + Set.new({id})
        self.DB.tags[tag] = id_set
    end
    -- also add id to world object indices list
    -- FIXME room for optimization, we don't need to always do this
    self.DB.all_indices = self.DB.all_indices + Set.new({id})
    -- finally, store the tagset indexed by object id
    tagset = self.DB.tagsets[id] or Set.new({})
    tagset = tagset + Set.new(arg)
    self.DB.tagsets[id] = tagset
end    

-- add a table/object to the world, with an arbitrary number of tags
function NS:add(t, ...)
    -- add object to world
    table.insert(self.DB.objects, t)
    -- new DB.objects table length is new object ID, equals its index
    local object_id = # self.DB.objects
    -- store index
    self.DB.indices[t] = object_id
    -- add any tags which might have been specified to the world
    NS:_tag_id(object_id, unpack(arg))
end

-- add (additional) tags to object
function NS:add_tags(t, ...)
    local object_id = self.DB.indices[t]
    print(object_id)
    NS:_tag_id(object_id, unpack(arg))
end

-- return a Set of those object indices which share the specified tags
function NS:get(...)
    local res = self.DB.all_indices
    for _,tag in ipairs(arg) do
        -- protect against bogus tags
        id_set = self.DB.tags[tag] or Set.new{}
        res = res * id_set
    end
    return res
end

function NS:all_tags_of_id(id)
    return NS.tagsets[id]
end

function NS:list(...)
    return NS.get(unpack(arg))
end

function NS_test()
    ns = NS
    function dbgfnc(func, input, expected_output)
        print("input: " .. tostring(input) .. " -> expected output: " .. expected_output .. " -> result: " .. tostring(func(input)))
    end

    t1 = {"foobar"}
    t2 = {"barfoospameggs"}
    t3 = {"spameggs"}
    t4 = {"nothing"}

    ns:add(t1, "foo", "bar")
    ns:add(t2, "bar", "foo", "spam", "eggs")
    ns:add(t3, "spam", "eggs")
    -- disabled, doesn't work for now
    -- ns.add_object_to_tags(t4)

    print(ns:get("foo"))
    print("1, 2")

    print(ns:get("foo", "spam"))

    ns:add_tags(t1, "spam")

    print(ns:get("foo", "spam"))
    print(ns.DB.tagsets[1])
end

NS_test()
