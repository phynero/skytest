all : help

help:
	@echo "支持下面命令:"
	@echo "make s       # 开服"

s:
	@./skynet/skynet etc/config.cfg


