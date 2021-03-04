local skynet = require "skynet"
local mng = require "ws_watchdog.mng"
local log = require "log"
local json = require "json"

local GATE -- gate 服务地址
local AGENT -- agent 服务地址

---------------------------------------------  SOCKET  ---------------------------------------------  
local SOCKET = {} -- ws_watchdog 的 socket 相关的操作接口
SOCKET.open = function(fd,addr)
    log.debug("New client from:", addr,fd)
    mng.open_fd(fd)
end
SOCKET.close = function(fd)
    log.debug("socket close:", fd)
    mng.close_fd(fd)
end
SOCKET.error = function(fd,msg)
    log.debug("socket error:", fd,msg)
    mng.close_fd(fd)
end
SOCKET.warning = function(fd,size)
    log.warn("socket warning", fd, size, "K")
end
SOCKET.data = function(fd,msg)
    log.debug("socket data", fd, msg)
    local req = json.decode(msg)
    print("=============SOCKET.data","req")
    for k, v in pairs(req) do
        print("k",k)
        print("v",v)
    end
    -- 解析客户端消息 pid为协议id
    -- if not req.pid then     -- 没有协议
    --     log.error("auth failed. fd:",fd,",msg:",msg)
    --     return
    -- end

    -- todo判断客户端是否通过认证
    -- skynet.call(GATE,"lua","respone",fd,json.encode(res))

    -- 协议处理逻辑
    -- todo 规范格式
    local res = mng.handle_proto(req,fd)
    if res then
        skynet.call(GATE,"lua","response",fd,json.encode(res))
    end
end
---------------------------------------------  SOCKET  END  ---------------------------------------------  


---------------------------------------------  CMD  ---------------------------------------------  
local CMD = {} -- ws_watchdog 服务操作接口

CMD.start = function(conf)
    skynet.call(GATE,"lua","open",conf)
end

CMD.kick = function(fd)
    mng.close_fd(fd)
end
---------------------------------------------  CMD  END  ---------------------------------------------  

skynet.start(function()
    skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
        log.debug("#####    ws_watchdog")
        log.debug(cmd)
        log.debug(subcmd)
        if cmd == "socket" then
            local f_socket = SOCKET[subcmd]
            if not f_socket then
                return log.error("ws_watchdog dispatch not find f_socket ",subcmd)
            end
            f_socket(...)
        else
            local f = assert(CMD[cmd])
            skynet.ret(skynet.pack(f(subcmd,...)))
        end
    end)

    -- 启动gate
    GATE = skynet.newservice("ws_gate")
    -- 启动agent
    AGENT = skynet.newservice("ws_agent")

    -- 初始化 watchdog 管理器
    mng.init(GATE,AGENT)

    -- 初始化 agent 管理器
    skynet.call(AGENT,"lua","init",GATE,skynet.self())
end)
