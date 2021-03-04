local skynet = require "skynet"
local socket = require "skynet.socket"
local log = require "log"
local json = require "json"
local md5 = require "md5.core"
local p_login = require "protocol_json.p_login"
-- local mng = require "ws_agent.mng"

--[[
    用户发来登录名账号密码
        检测是否在数据库
            是
                登陆成功 创建md5的token返回 后续验证token通过
                登陆失败 返回报错
            否 创建新uuid账号 自动登录 创建md5的token返回 后续验证token通过
]]


local CMD = {}
CMD.login = function(gate, watchdog)
    log.info("login.login")

end


CMD.register = function(gate, watchdog)
    log.info("login.register")


end


skynet.start(function()
    log.debug("----------------login logic")
    log.debug(p_login.p_register)
    skynet.dispatch("lua", function(session, source, cmd, ...)
        log.debug("#####    login")
        log.debug(cmd)
        --skynet.trace()
        local f = CMD[cmd]
        skynet.ret(skynet.pack(f(...)))
    end)
end)