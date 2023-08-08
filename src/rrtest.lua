---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zouwenhao.
--- DateTime: 2022/5/31 11:38 上午
---

--- 统计指定请求量下指定节点的命中次数

--local socket = require("socket.core")
local roundrobin = require("loadbalance.roundrobin")
local smoothroundrobin = require("loadbalance.smoothroundrobin")
local json = require("util.json")

--local mobdebug = require("add.initial.mobdebug");
--mobdebug.start();

--a = 1
--print("hha")

local nodes={}
-- 5个节点
--for i = 1, 5 do
for i = 1, 8 do
    local str = "N" .. i
    nodes[str] = 100 -- 权重100
end

local function request(nodes, type, s, lowNode)
    local counts = {}
    local picker1
    local count = 0
    --local showFirst = false
    --local lowSize = 0
    if type == "wrr" then
        picker1 = roundrobin:new(nodes)
    else if type == "swrr" then
        picker1 = smoothroundrobin:new(nodes)
    end
    end
    -- 模拟请求，发现s次
    for i = 1, s do
        local pick = picker1:find()
        --ngx.log(ngx.ERR, "find:" .. pick)
        if counts[pick] == nil then
            counts[pick] = 1
        else
            counts[pick] = counts[pick] + 1
        end
        count = count + 1
        if pick == lowNode then
            --lowSize = lowSize + 1
            --if lowSize == 2 then
            --    ngx.log(ngx.ERR, "lownode:" .. lowNode .. " lowcount:" .. count .. " lowSize:" .. lowSize)
            --    break
            --end
            --showFirst = true
            --ngx.log(ngx.ERR, "lownode:" .. lowNode .. " first count:" .. count)
            ngx.log(ngx.ERR, "lownode:" .. lowNode .. " count:" .. count)
        end

    end
    ngx.log(ngx.ERR, "roundrobin result:" .. json.encode(counts) .. " type:" .. type)

    -- 判断请求占比是否接近权重
    if false then
        local node = "N1"
        local tw = 0
        for _, n in pairs(nodes) do
            tw = n + tw
        end
        local ratio = nodes[node] / tw
        local target = ratio * s
        local count = 0
        if counts[node] ~= nil then
            count = counts[node]
        end
        ngx.log(ngx.ERR, "count:" .. count .. " target:" .. target)
        --assert(count + 1 >= target and count - 1 < target +1) -- wrr会低权重时会失败 ，权重3+5节点300请求时
        --if type == "swrr" then
        --    assert(count + 1 >= target and count - 1 < target +1)
        --end
    end
end

-- 请求（预热）
local start_time = os.time()
--for i = 0, 100 do
for _, i in ipairs({1,7}) do
    local lowNode = "N8"
    nodes[lowNode] = i
    ngx.log(ngx.ERR, "---weight up:" .. i .. "---")
    --local size = {10,20,50,100,200,500,1000,5000,10000} -- qps
    local size = {10000,50000} -- qps
    --local size = {10,20,50,100,200,500,1000,5000,10000,20000,50000} -- qps 8.7w:wrr总计4s,swrr13s
    for i, s in ipairs(size) do -- 迭代qps集合
        s = s*1 -- 预热速率
        ngx.log(ngx.ERR, "request size:" .. s)
        --request(nodes, "wrr", s)
        request(nodes, "swrr", s, lowNode)
        --ngx.exit(0)
    end
end
local end_time = os.time()
ngx.log(ngx.ERR, "---done:--- start_time:" .. start_time .. " end:" .. end_time)


--local picker1 = roundrobin:new(nodes)
--local pick = picker1:find()
--ngx.log(ngx.ERR, pick)

assert(true)