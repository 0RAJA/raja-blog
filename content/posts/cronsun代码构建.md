---
title: "Cronsun代码构建" # 标题
subtitle: "Cronsun代码构建" # 副标题
description: "" # 文章内容描述
date: 2024-04-16T11:45:28+08:00 # 时间
lastmod: 2024-04-16T11:45:28+08:00 # 上次修改时间
tags: ["go","vue"] # 标签
categories: ["技术"] # 分类
draft: false # 是否为草稿
hiddenFromHomePage: false # 私人

---

<!--more-->

> [cronsun 说明](https://github.com/shunfei/cronsun)

cronsun 前端采用 vue 编写，打包后转为 go 静态代码并被一起编译为二进制包。代码目录为 cronsun/web/ui​。但由于依赖库版本等问题需要修改部分构建代码。

1. 新增 cronsun/web/ui/copy-files.js​

   ```js
   const fs = require('fs');
   fs.copyFileSync('index.html', './dist/index.html');
   ```

2. 修改 cronsun/web/ui/package.json​

   ```json
   {
    "name": "cronsun-web-ui",
    "version": "1.0.0",
    "description": "",
    "scripts": {
      "dev": "cross-env NODE_ENV=development webpack-dev-server --open --inline --hot --disableHostCheck=true",
      "build": "cross-env NODE_ENV=production webpack --progress --hide-modules && node copy-files.js",
      "test": "echo \"Error: no test specified\" && exit 1"
    },
    "private": true,
    "author": "heshitan@sunteng.com",
    "dependencies": {
      "chart.js": "^2.5.0",
      "core-js": "^3.36.1",
      "jquery": "^3.1.1",
      "jquery.cookie": "^1.4.1",
      "semantic-ui": "^2.5.0",
      "vue": "^2.3.4",
      "vue-router": "^2.2.1",
      "vuex": "^2.3.1"
    },
    "devDependencies": {
      "babel-core": "^6.0.0",
      "babel-loader": "^6.0.0",
      "babel-preset-es2015": "^6.0.0",
      "cross-env": "^3.0.0",
      "css-loader": "^0.26.1",
      "file-loader": "^0.9.0",
      "style-loader": "^0.13.1",
      "vue-loader": "^10.0.0",
      "vue-template-compiler": "^2.3.4",
      "webpack": "^2.1.0-beta.25",
      "webpack-dev-server": "^2.1.0-beta.9"
    }
   }
   ```

3. 修改 cronsun/web/ui/webpack.config.js​

   ```js
   var path = require('path')
   var webpack = require('webpack')
   
   var fontPublicPath = process.env.NODE_ENV === 'production' ? '/ui/' : '';
   module.exports = {
    entry: path.resolve(__dirname, 'src', 'main.js'),
    output: {
      path: path.resolve(__dirname, './dist'),
      publicPath: '/',
      filename: 'build.js'
    },
    module: {
      rules: [
        {
          test: /\.vue$/,
          loader: 'vue-loader',
          options: {
            loaders: {
              // Since sass-loader (weirdly) has SCSS as its default parse mode, we map
              // the "scss" and "sass" values for the lang attribute to the right configs here.
              // other preprocessors should work out of the box, no loader config like this nessessary.
              'scss': 'vue-style-loader!css-loader!sass-loader',
              'sass': 'vue-style-loader!css-loader!sass-loader?indentedSyntax'
            }
            // other vue-loader options go here
          }
        },
        {
          test: /\.js$/,
          loader: 'babel-loader',
          exclude: /node_modules/
        },
        {
          test: /\.(png|jpg|gif|svg|ttf|woff|woff2|eot)\w*/,
          loader: 'file-loader',
          options: {
            publicPath: fontPublicPath,
            name: '[name].[ext]?[hash]'
          }
        },
        {
          test: /\.css$/,
          loader: 'style-loader!css-loader'
        }
      ]
    },
    resolve: {
      alias: {
        'vue$': 'vue/dist/vue.common.js',
        'semantic$': 'semantic-ui/dist/semantic.min.js',
        'semanticcss$': 'semantic-ui/dist/semantic.min.css',
        'charts$': 'chart.js/dist/Chart.min.js'
      }
    },
    devServer: {
      proxy: {
        '/v1': {
          target: 'http://127.0.0.1:7079',
          secure: false
        }
      },
      historyApiFallback: true,
      noInfo: true
    },
    performance: {
      hints: false
    },
    devtool: '#eval-source-map'
   }
   
   if (process.env.NODE_ENV === 'production') {
    module.exports.devtool = '#source-map'
    // http://vue-loader.vuejs.org/en/workflow/production.html
    module.exports.plugins = (module.exports.plugins || []).concat([
      new webpack.DefinePlugin({
        'process.env': {
          NODE_ENV: '"production"'
        }
      }),
      new webpack.LoaderOptionsPlugin({
        minimize: true
      })
    ])
   }
   ```

4. node 版本为 14.21.3​ (可以采用 nvm 进行管理)

   mac M 芯片此版本安装需要 rosetta [在 Apple Silicon M1/M2 Mac 电脑上安装 Rosetta 2 运行 intel 应用](https://macoshome.com/course/6879.html)

   ```shell
   > cronsun/web/ui
   npm install semantic-ui --ignore-scripts
   npm i
   npm run build
   ```

5. 通过脚本将前端代码转为 go 静态文件

   ```shell
   > cronsun/web
   sh gen_bindata.sh
   ```

6. 构建 go 二进制文件

   ```shell
   > cronsun
   sh build.sh
   ```

   生成的二进制文件就在 cronsun/dist​ ​下
