HUGO ?= hugo

build: # 构建静态文件
	$(HUGO)
server: # 开发环境
	$(HUGO) serve
serve-prod: # 发布环境
	$(HUGO) serve --disableFastRender -e production
