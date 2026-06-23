---
title: Web 安全核心架构：CSRF 与状态管理
slug: web-security-core-architecture-csrf-and-status-management-z1oikp
date: '2026-05-18 21:18:34+08:00'
lastmod: '2026-06-24 00:09:20+08:00'
tags:
  - csrf
  - 安全
  - cookie
  - 同源
  - 跨站
categories:
  - 技术
keywords: csrf,安全,cookie,同源,跨站
description: >-
  该文章聚焦Web安全核心架构，围绕CSRF与状态管理展开。CSRF本质是利用浏览器自动携带Cookie的机制发起“写”攻击，其防御与同源策略（SOP防读）无关，CORS配置不能替代CSRF防御。防御矩阵包括：SameSite
  Cookie（Strict/Lax/None）作为现代基线；CSRF
  Token（会话级绑定，最坚固）；双重Cookie验证（无状态但有子域XSS风险）；降级方案中推荐使用Origin白名单而非Referer。状态管理方面，Cookie安全三剑客——HttpOnly（防XSS窃取）、Secure（强制HTTPS）、SameSite（防CSRF）是关键；JWT的安全性取决于存储载体而非格式本身。文章强调工程实践：GET请求必须幂等，避免使用GET修改状态。
toc: true
isCJKLanguage: true
---



# Web 安全核心架构：CSRF 与状态管理

# Web 安全核心架构：CSRF 与状态管理

## 一、 核心概念与本质区别

### 1. CSRF (Cross-Site Request Forgery) 跨站请求伪造

- **本质：**  借刀杀人。利用浏览器**自动携带 Cookie** 的机制，在用户无感知的情况下，诱导浏览器以用户的合法身份向目标服务器发起**状态修改**请求。
- **攻击核心：**  这是一个“写/执行”攻击。黑客发得出请求，但受限于同源策略，看不到响应结果。
- **触发方式：**  `<a>`​ 标签（GET）、`<img>`​ 标签（GET）、`<form>` 隐藏表单静默提交（POST）。

### 2. 同源策略与 CORS 机制

- **同源策略 (SOP)：**  浏览器的底层安全基石。防的是“读”。限制跨域 JavaScript 读取 DOM、Cookie，以及拦截跨域 AJAX 的响应内容。
- **CORS (跨域资源共享)：**  服务端配置的白名单机制，用于打破 SOP，允许合法的跨域“读”。
- **关系警示：**  CORS 防不住 HTML 原生表单发起的跨站 POST 请求（简单请求无预检）。**配了 CORS 不等于防了 CSRF，两者独立。**

---

## 二、 CSRF 防御矩阵

### 1. 现代基线：SameSite Cookie 属性

决定了浏览器在跨站请求时是否携带 Cookie，是成本最低、收益最高的防御。

- **Strict：**  绝对禁止跨站发送。最安全，但用户从外部链接点进系统时需重新登录。
- **Lax（现代浏览器默认）：**  拦截绝大多数跨站请求。**仅允许顶级导航（如点击** `<a>`​ **、**​`GET`​ **方式表单提交）且为 GET 请求时携带**。 **。**

  - 默认 lax 则只允许会明显跳转到目标站点的请求才会携带目标的 cookie，常见的 ajax、img、iframe 这些都不会，但是还是 GET 请求还是会可能被诱导触发

    **工程要求：系统内的所有 GET 请求必须是幂等的（只读），严禁使用 GET 修改状态；** 否则需要引入 token 或者 直接 Strict 不让跨站发送这个 cookie
- **None：**  允许所有跨站发送。用于跨域 SSO 或第三方组件（必须同时配置 `Secure` 属性）。

### 2. 会话级校验：CSRF Token (Session-bound)

业界最坚固的传统防御方案，用于弥补老旧浏览器或 `SameSite=None` 的场景。

- **原理：**  服务端生成高强度随机 Token 并绑定当前 Session。前端发请求时，将 Token 放入自定义 Header（如 `X-CSRF-Token`）。服务端对比 Header Token 与 Session Token。
- **优势：**  黑客跨域读不到 DOM 和内存，无法伪造正确的 Header。不受子域名 XSS 污染 Cookie 的影响。
- **成本：**  服务端需维护状态（Session/Redis）。

### 3. 无状态校验：双重 Cookie 验证 (Double Submit Cookie)

- **原理：**  服务端通过 `Set-Cookie` 下发 Token。前端每次请求，JS 读取该 Cookie，并复制一份放到 Header 中。服务端仅对比 Header 和 Cookie 的值是否一致。
- **优势：**  服务端无状态，易于扩展。
- **致命缺陷：**  如果任何一个子域名存在 XSS 漏洞，黑客可以利用“子域可写父域”的机制，向主域名种入伪造的 Cookie，从而瞬间击穿防御。**高安系统禁用。**

### 4. 降级方案：Referer / Origin 白名单校验

- **适用场景：**  兼容不支持 SameSite 的远古浏览器，或纯对外跨域 API 的纵深防御。
- **避坑指南：**  Referer 极度不可靠（受隐私插件、HTTPS 降级、`<meta>`​ 标签影响极易丢失，导致正常请求误报 403）。现代工程应**直接废弃 Referer 校验，改用受浏览器底层保护的 Origin 字段**进行白名单拦截。

---

## 三、 状态管理载体与安全属性

### 1. Cookie 安全三剑客

|**属性**|**作用机制**|**主要防御目标**|**务实建议**|
| -| -------------------------------------------------------------------------------------------| ---------------------------------------------------------------------------------------------| --------------------------------------------------------------------------------------------------|
|**HttpOnly**|禁止 JavaScript 通过 `document.cookie` 读取该 Cookie。|**XSS (跨站脚本攻击)** 。即便页面被注入了恶意脚本，脚本也偷不走敏感的 Session ID。|存放认证凭证（Session ID、JWT）的 Cookie **必须**开启。|
|**Secure**|规定该 Cookie 只能在加密连接（HTTPS）中被传输。如果在 HTTP 下发起请求，浏览器直接拒绝发送。|**MITM (中间人攻击)** 、网络嗅探。防止 Token 在公网明文传输被截获。<br />避免 HTTP 降级窃取，或者利用 http 跳转时间差获取<br />|生产环境**强制开启**（SameSite\=None 时为强制必须）。|
|**SameSite**|​`Strict`：完全禁止跨站发送。<br /><br />`Lax`：仅允许安全的顶级导航跳转（GET）跨站发送。<br /><br />`None`：允许所有跨站发送。|**CSRF (跨站请求伪造)** 。切断浏览器自动携带凭证的后门。|现代浏览器默认设为 `Lax`​。如果是跨域 API 必须设为 `None`​，且此时**强制要求同时开启 Secure**（第三方支付网关、SSO、三方客服系统等）。|

### 2. JWT (JSON Web Token) 考量

- JWT 只是​**凭证格式**​，不决定安全性，决定安全性的是​**存储载体**。
- **存 Cookie：**  面临与 Session ID 一模一样的 CSRF 风险，需要配 SameSite 或 Token 防御。
- **存 LocalStorage/内存，放 Header 传输：**  物理免疫 CSRF（浏览器不会自动带），但极度害怕 XSS（JS 可直接读取）。

---

## 其他

### 为什么 SameSite\=None 强制要求开启 Secure

因为 SameSite\=None 的 cookie 大概率会被各种地方带来带去，经常可能出现 中间人 攻击，因此限制必须 https 才会传递

### 高级降维打击：XSS 与子域接管

**任何防御 CSRF 的机制，在 XSS 和 子域接管 面前均形同虚设。**

1. **同域 XSS：**  黑客代码在当前页面合法运行，直接读取 DOM/内存中的 CSRF Token，或者干脆重写 `fetch` 直接带着合法身份静默调用所有接口。
2. **子域 XSS：**  利用 Cookie 的 Domain 继承机制，污染父域 Cookie，击穿无状态的双重 Cookie 验证。
3. **子域接管 (Subdomain Takeover)：**  黑客接管废弃子域，利用 SSO 系统对内部子域的过度信任（宽泛的 Redirect URI），静默获取 OAuth 授权凭证，完成最高级别的身份盗用。

**安全铁律：防 CSRF 的底线是全站无 XSS 漏洞，且内部系统的信任边界配置必须遵循最小权限原则。**
