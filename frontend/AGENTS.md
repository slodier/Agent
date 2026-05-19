# Vue3

## 日期时间

- 涉及"日期/天数/签到/排行/今日/昨日"等业务时，必须先确认时区：
  - UTC
  - 用户本地时区
  - Asia/Shanghai（北京时间）
  - 或服务端固定时区
- 时区未明确前，不允许擅自实现日期逻辑
- 禁止使用 `new Date('YYYY-MM-DD')` 解析业务日期
  - `YYYY-MM-DD` 会按 UTC 0 点解析，东八区会变成当天 08:00
- 按北京时间/业务日期计算时，必须固定 Asia/Shanghai
- 起始日必须用以下方式之一：
  - 服务端返回时间戳
  - `new Date(year, month - 1, day)`
  - 服务端返回 YYYY-MM-DD 后，拆分成年月日再构造 Date
- 禁止把"服务端时间戳"和"前端本地时区日期"混算
- 时间戳必须确认是秒还是毫秒
- 计算天数前，必须确认基准是 UTC 日期、用户本地日期还是北京时间业务日期

## 代码风格

- 必须使用 setup 语法，禁止 Options API
- 使用箭头函数
- composable 按功能拆分，超过一个文件复用的逻辑必须抽 composable
- props/emits 必须定义类型
- 禁止滥用 watch，使用前先确认 computed 是否更适合

## 请求

- 登录失效统一处理：`return new Promise(() => {})`，不允许 `Promise.reject('')`
- 请求必须加锁防重复触发，包括：表单提交、列表、按钮、初始化请求
- 列表页切换 tab/筛选条件时，必须取消上一个请求（AbortController）
- 删除操作必须二次确认

## 表单

- 提交前必须 trim 字符串，防止空格导致校验通过但数据异常
- 金额、手机号、身份证等必须前端格式校验，不能只依赖后端

## 样式

- 禁止 inline style，统一使用 class
- uniapp 单位使用 rpx，其它场景使用 px
- 禁止滥用 `!important`
- 禁止使用 tailwind class，除非项目已明确接入 tailwind.css（HBuilder/uniapp 环境不支持）
- 从蓝湖/墨刀复制 html/css 后，必须去掉无用结构和样式，禁止保留无意义 div 嵌套
- 暗色/亮色状态必须确认

## 组件通信

- 禁止子组件直接修改 props，必须通过 emit
- 禁止多层 props drilling，跨层级通信使用 provide/inject 或 pinia

## 权限与路由

- 路由必须懒加载，禁止全量 import
- 动态路由必须在登录后重新初始化

## 性能

- 禁止在 template 中写复杂表达式，必须抽成 computed

## 安全


## 排行/排名

- 排名分页时必须按全局偏移计算

---

# UniApp / 小程序

## 平台能力

- web-view 跳小程序使用：`wx.miniProgram.navigateTo`
- 图片长按识别使用：`show-menu-by-longpress`
- web-view 中 H5 页面长按二维码，仅支持微信体系：
  - 小程序码、微信个人码、企业微信个人码
  - 普通群码、互通群码、公众号二维码
  - 其它二维码不保证支持，属于微信能力限制
- `chooseImage`/`chooseVideo` 返回会触发 onShow，注意副作用
- `uni.showToast` 可能被系统清掉，关键提示勿依赖

## 开发注意

- 代码确认无误但多次修改不生效时，尝试关闭 HBuilder 后重新运行微信小程序
- 不允许频繁 onLoad 请求
- 必须确认安卓/iOS 差异
- 必须确认微信/支付宝差异

## 性能

- 长列表必须分页
- 图片必须懒加载
- 视频必须确认码率
