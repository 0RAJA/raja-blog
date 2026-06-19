# Raja's Blog

个人博客站点，用于记录技术笔记、旅行与生活内容。

站点地址：[https://blog.humraja.top/](https://blog.humraja.top/)

站点基于 [Hugo](https://gohugo.io/) 构建，主题使用
[DoIt](https://github.com/HEIGE-PCloud/DoIt) 子模块。

## 技术栈

- Hugo Extended `0.163.3`
- DoIt theme `v1.0.2`
- GitHub Actions 自动构建部署
- Algolia DocSearch 索引上传

本机 Hugo 建议固定版本，避免主题或 Hugo 上游更新导致构建结果不一致。

## 目录说明

- `content/`：博客正文与页面内容
- `static/`：静态资源，原样发布
- `assets/`：站点级样式覆盖
- `layouts/`：站点级模板覆盖
- `themes/DoIt/`：DoIt 主题子模块，不直接修改
- `config.toml`：站点、主题、搜索、导航等配置
- `.github/workflows/deploy.yml`：生产部署流程

## 初始化

```bash
git submodule update --init --recursive
hugo version
```

期望 Hugo 版本：

```text
hugo v0.163.3+extended
```

如果使用 Homebrew，可固定本机版本：

```bash
brew pin hugo
```

## 本地开发

```bash
make server
```

访问：

```text
http://localhost:1313/
```

生产环境模拟：

```bash
make serve-prod
```

构建验证：

```bash
make build
make check
```

## 内容约定

新增文章建议使用：

```bash
hugo new posts/<slug>.md
```

文章 front matter 建议补齐：

- `title`
- `description`
- `date`
- `lastmod`
- `tags`
- `categories`
- `featuredImagePreview`

首页摘要优先使用 `description`。如果没有 `description`，会兜底使用正文摘要并截断。

## 维护约定

- 不直接修改 `themes/DoIt/` 内的上游主题文件，站点定制放在 `assets/` 或 `layouts/`
- `public/`、`resources/` 为构建产物，默认不提交
- 配置集中维护在 `config.toml`，导航、搜索、主题参数调整建议一次性提交
- 图片和附件文件名建议使用小写加连字符，并确保 Markdown 引用路径大小写一致
- 涉及布局、样式、配置的改动，提交前至少执行 `make check`
- API Key、Algolia 凭据等敏感信息只通过环境变量或 GitHub Secrets 注入
- Commit 信息遵循 Conventional Commits，例如 `feat:`、`fix:`、`chore:`

## 友情链接

友情链接页面可使用 `friend` shortcode：

```html
<div class="flink" id="article-container">
  <div class="friend-list-div">
    {{< friend name="{友链名}" url="{友链地址}" logo="{友链图标链接}" word="{友链描述}" >}}
  </div>
</div>
```

## 部署

推送到 `master` 后触发 GitHub Actions：

1. 拉取仓库和子模块
2. 安装 Hugo Extended `0.163.3`
3. 执行 `hugo`
4. 上传 `public/index.json` 到 Algolia 索引 `raja-blog`

部署相关密钥通过 GitHub Secrets 注入：

- `ALGOLIA_APPLICATION_ID`
- `ALGOLIA_SEARCH_API_KEY`
- `ALGOLIA_ADMIN_API_KEY`

本地如需验证 Algolia 搜索配置，可在运行 Hugo 前注入公开查询配置：

```bash
export HUGO_PARAMS_SEARCH_ALGOLIA_APPID="your-application-id"
export HUGO_PARAMS_SEARCH_ALGOLIA_SEARCHKEY="your-search-api-key"
make server
```
