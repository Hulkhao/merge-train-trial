const test = require('node:test');
const assert = require('node:assert');
const { routes } = require('../../src/routes');

test('baseline route /hello is registered', () => {
  assert.equal(typeof routes['/hello'], 'function');
});
