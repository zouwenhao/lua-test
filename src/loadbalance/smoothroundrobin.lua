local json = require("util.json")

local pairs = pairs
local next = next
local tonumber = tonumber
local setmetatable = setmetatable


local _M = {}
local mt = { __index = _M }


local function copy(nodes)
    local newnodes = {}
    local index = 1
    for id, weight in pairs(nodes) do
        local node = {}
        node["id"] = id
        node["weight"] = weight
        node["cw"] = 0
        newnodes[index] = node
        index = index + 1
    end

    return newnodes
end


function _M.new(_, nodes)
    local newnodes = copy(nodes)
    local tw = 0
    for _, node in pairs(newnodes) do
        tw = tw + node["weight"]
    end
    local self = {
        nodes = newnodes,  -- it's safer to copy one
        tw = tw,
    }
    ngx.log(ngx.ERR, "nodes:", json.encode(newnodes))
    return setmetatable(self, mt)
end


local function find(self)
    local nodes = self.nodes
    local tw = self.tw
    --core.log.error("smooth" .. core.json.encode(self))
    local max = 0
    local index = 1

    --local countPre = 0
    --for i, node in pairs(nodes) do
    --    countPre = countPre + node["cw"]
    --end
    --ngx.log(ngx.ERR, "nodes: 1 count" .. countPre, json.encode(nodes))
    for i, node in pairs(nodes) do
        local effectiveWeight = node["weight"]



        node["cw"] = node["cw"] + effectiveWeight
        -- 9节点 权重1的 185命中
        -- 8节点 权重1的 176命中
        -- 7节点 权重1的 175命中
        -- 6节点 权重1的 166命中
        -- 5节点 权重1的 161命中
        -- 4节点 权重1的 151命中
        -- 3节点 权重1的 135命中
        -- 2节点 权重1的 100命中
        if node["cw"] > max then
            max = node["cw"]
            index = i
        end
        --node["cw"] = node["cw"] + node["weight"]
        -- 9节点 权重1的 97命中

        -- 8节点 权重1的 92命中
        -- 8节点 权重2的 50命中
        -- 8节点 权重3的 36命中
        -- 8节点 权重4的 29命中
        -- 8节点 权重5的 22命中
        -- 8节点 权重6~10的 15命中

        -- 6节点 权重1的 86命中
        -- 5节点 权重1的 81命中
        -- 4节点 权重1的 76命中
        -- 3节点 权重1的 67命中
        -- 2节点 权重1的 51命中
    end
    nodes[index]["cw"] = nodes[index]["cw"] - tw
    --countPre = 0
    --for i, node in pairs(nodes) do
    --    countPre = countPre + node["cw"]
    --end
    --ngx.log(ngx.ERR, "nodes: 2 count" .. countPre, json.encode(nodes))
    return nodes[index]["id"]
end
_M.find = find
_M.next = find


return _M
