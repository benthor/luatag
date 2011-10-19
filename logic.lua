Set = require('set')

-- the heart of the tagging system
NameSpace = {}

NameSpace.DB = {}

-- tags as k,v pairs, k -> tag, v -> a set of object indices, see below
NameSpace.DB.tags = {}

-- a set of all object indices as seen in the world
NameSpace.DB.all_indices = Set.new{}

-- ipairs, index -> object
NameSpace.DB.objects = {}

-- for bidirectional completeness
-- object -> index
NameSpace.DB.indices = {}

-- for bidirectional completeness
-- object_id -> tagset
NameSpace.DB.tagsets = Set.new{}

-- add tags for a given id
-- warning: it is not checked if object with id actually exists
function NameSpace:_tag_id(id, ...)
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

function NameSpace:_untag_id(id, ...)
    if # arg == 0 then
        error("should at least define one tag to remove, I am very pedantic about this")
    end
    for _,tag in ipairs(arg) do
        local id_set = self.DB.tags[tag] or error("tag "..tag.." doesn't exist in DB")
        id_set = id_set - Set.new({id})
        self.DB.tags[tag] = id_set
    end
    -- TODO, need to check if that tag was globally the last and remove it entirely
    -- TODO, need to check if that tag was the last of the object, garbage collect?
    tagset = self.DB.tagsets[id] or error("possibly corrupt namespace, id not found in tagsets")
    tagset = tagset - Set.new(arg)
    self.DB.tagsets[id] = tagset
end

-- add a table/object to the world, with an arbitrary number of tags
function NameSpace:add(t, ...)
    -- add object to world
    table.insert(self.DB.objects, t)
    -- new DB.objects table length is new object ID, equals its index
    local object_id = # self.DB.objects
    -- store index
    self.DB.indices[t] = object_id
    -- add any tags which might have been specified to the world
    NameSpace:_tag_id(object_id, unpack(arg))
end

-- add additional tags to object
function NameSpace:add_tags(t, ...)
    local object_id = self.DB.indices[t]
    if not object_id then
        error("can't add tags to unknown object")
    end
    NameSpace:_tag_id(object_id, unpack(arg))
end

function NameSpace:remove_tags(t, ...)
    local object_id = self.DB.indices[t]
    if not object_id then
        error("can't remove tags from unknown object")
    end
    NameSpace:_untag_id(object_id, unpack(arg))
end
 

-- return a Set of those object indices which share the specified tags
function NameSpace:_get_ids(...)
    local res = self.DB.all_indices
    for _,tag in ipairs(arg) do
        -- protect against bogus tags
        id_set = self.DB.tags[tag] or Set.new{}
        res = res * id_set
    end
    return res
end

function NameSpace:get(...)
    local ids = NameSpace:_get_ids(unpack(arg))
    local res = {}
    for id in pairs(ids) do
        table.insert(res,self.DB.objects[id])
    end
    return res
end


function NameSpace:get_tags(t)
    id = self.DB.indices[t]
    return self.DB.tagsets[id]
end

return NameSpace
