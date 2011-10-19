NS = require('logic')

NS:add({"fooo"}, "1", "2", "3")
print(NS:get("1")[1][1])

NS:add_tags(NS:get("1")[1], "6")
print(NS:get("6")[1][1])

--NS:add_tags({"baaar"}, "6")

print(NS:get_tags(NS:get("1")[1]))

NS:remove_tags(NS:get("1")[1], "1")

print(NS:get_tags(NS:get("6")[1]))

NS:remove_tags(NS:get("2")[1], "2", "3")

print(NS:get_tags(NS:get("6")[1]))

