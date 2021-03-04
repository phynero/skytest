local protocol = {}

local p_register = {}
p_register.c2s = {
    method = "register",
    token = "",
    params = {
        account = "",
        pwd = "",
    }
}
p_register.s2c = {
    status = 0,
    data = {
        token = "",
        uid = "",
    },
}

local p_login = {}
p_login.c2s = {
    method = "login",
    token = "",
    params = {
        account = "",
        pwd = "",
    }
}

p_login.s2c = {
    status = 0,
    data = {
        token = "",
        uid = "",
    },
}

protocol.login = p_login
protocol.register = p_register
return protocol