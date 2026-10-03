const { routes } = require('./routes');
const { flags } = require('./config');

// dispatch(path, query) -> { status, body }
function dispatch(path, query = {}) {
  const handler = routes[path];
  if (!handler) return { status: 404, body: 'not found' };
  if (flags[path] === false) return { status: 503, body: 'flag off' };
  return { status: 200, body: handler(query) };
}

module.exports = dispatch;
