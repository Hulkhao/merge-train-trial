const test = require('node:test');
const assert = require('node:assert');
const dispatch = require('../../src/index');

test('dispatch /sum adds query params a and b', () => {
  assert.deepEqual(dispatch('/sum', { a: '1', b: '2' }), { status: 200, body: 3 });
});
