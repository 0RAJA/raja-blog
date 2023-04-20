build: # 构建静态文件
	hugo
server: # 开发环境
	hugo serve
serve-prod: # 发布环境
	hugo serve --disableFastRender -e production