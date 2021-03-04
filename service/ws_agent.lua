local skynet = require "skynet"
local socket = require "skynet.socket"
local log = require "log"
local mng = require "ws_agent.mng"
local json = require "json"
-- require "services"

local WATCHDOG -- watchdog 服务地址
local GATE -- gate 服务地址

local MOD_LOGIN

local CMD = {}
CMD.init = function(gate, watchdog)
    GATE = gate
    WATCHDOG = watchdog
    -- mng.init(GATE, WATCHDOG)
end

CMD.login = function(subcmd,...)
    skynet.call(MOD_LOGIN, subcmd, ...)
end




skynet.start(function()
    skynet.dispatch("lua", function(session,source,cmd,...)
        log.debug("#####    ws_agent")
        log.debug(cmd)
        --skynet.trace()
        local f = CMD[cmd]
        skynet.ret(skynet.pack(f(...)))
    end)


    MOD_LOGIN = skynet.newservice("login")
end)