// 特性开关：每条开发线在此追加一个条目（机械冲突设计点之二：配置并集）
module.exports = {
  flags: {
    '/hello': true,
    '/greet': true,
    '/now': true,
  },
};
