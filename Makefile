HUGO ?= hugo

build: # 构建静态文件
	$(HUGO)
check: # 构建并将警告视为错误
	$(HUGO) --panicOnWarning
server: # 开发环境
	$(HUGO) serve
serve-prod: # 发布环境
	$(HUGO) serve --disableFastRender -e production
