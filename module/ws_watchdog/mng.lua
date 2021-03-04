local skynet = require "skynet"
local config = require "config"
local timer = require "timer"
local md5 = require "md5"

local M = {} -- 模块接口
local RPC = {} -- 协议绑定处理函数

local GATE -- gate 服务地址
local AGENT -- agent 服务地址
local TIMEOUT_AUTH = 10 -- 认证超时 10 秒
local noauth_fds = {} -- 未通过认证的客户端

function M.init(gate, agent)
    GATE = gate
    AGENT = agent
end

function M.open_fd(fd)
end

function M.close_fd(fd)
end

function M.handle_proto(req, fd)
    -- 根据协议 ID 找到对应的处理函数
    -- local func = RPC[req.pid]
    -- local res = func(req, fd)



    local trst = {
        ["data"] = "结果"
    }
    return trst
end

return M