local skynet = require "skynet"
require "skynet.manager"
local socket = require "skynet.socket"
local websocket = require "http.websocket"
local socketdriver = require "skynet.socketdriver"
local log = require "log"

local WATCHDOG -- watchdog 服务的地址
local MAXCLIENT -- 客户端数量上限
local nodelay

-----------------------------------  websocket handler  -----------------------------------
local handler = {}
handler.connect = function(fd)
    log.info("--------->  websocket handler.connect",fd)
end

handler.message = function(fd,msg)
    log.info("--------->  websocket handler.message",fd,msg)
    skynet.send(WATCHDOG, "lua", "socket", "data", fd, msg)
end

handler.handshake = function(fd,header,url)
    log.info("--------->  websocket handler.handshake",fd)
    local addr = websocket.addrinfo(fd)
    log.debug("ws handshake from: ", tostring(fd), ", url:", url, ", addr:", addr)
end

handler.ping = function(fd)
    log.info("--------->  websocket handler.ping",fd)
end

handler.pong = function(fd)
    log.info("--------->  websocket handler.pong",fd)
end

handler.close = function(fd,code,reason)
    log.info("--------->  websocket handler.close",fd)
end

handler.error = function(fd)
    log.info("--------->  websocket handler.error",fd)
end

handler.warning = function(fd,size)
    log.info("--------->  websocket handler.warning",fd)
end


-----------------------------------  CMD  -----------------------------------
local CMD = {}

CMD.open = function(source, conf)
    WATCHDOG = conf.watchdog or source
    MAXCLIENT = conf.maxclient or 1024
    local address = conf.address or "0.0.0.0"
    local port = assert(conf.port)
    local protocol = conf.protocol or "ws"
    nodelay = conf.nodelay

    -- 启动 websocket
    local fd = socket.listen(address,port)
    log.info(string.format("Listen websocket port %s  protocol: %s  ",port,protocol))
    socket.start(fd,function(fd,addr)
        websocket.accept(fd,handler,protocol,addr)
    end)
end

CMD.response = function(source, fd, msg)
    log.debug("ws response: ", tostring(fd), ", msg:", msg)
    -- forward msg
    websocket.write(fd, msg)
end

skynet.start(function()
    skynet.dispatch("lua",function(session,source,cmd,...)
        log.debug("#####    ws_gate")
        log.debug(cmd)
        local f = CMD[cmd]
        if not f then
            -- log.error("simplewebsocket cant dispatch cmd:",(cmd or nil))
            skynet.ret(skynet.pack({ok = false}))
            return
        end
        if session == 0 then
            f(source,...)
        else
            skynet.ret(skynet.pack(f(source,...)))
        end
    end)

    skynet.register(".ws_gate")
    log.info("ws_gate booted.")
end)