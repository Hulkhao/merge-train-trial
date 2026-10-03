// 路由注册表：每条开发线在此追加一个路由条目（机械冲突设计点之一：注册并集）
module.exports = {
  routes: {
    '/hello': () => 'Hello, merge-train trial!',
  },
};
