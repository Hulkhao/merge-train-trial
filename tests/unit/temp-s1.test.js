const test = require('node:test');
const assert = require('node:assert');
const dispatch = require('../../src/index');

test('dispatch /temp returns Celsius body', () => {
  assert.deepEqual(dispatch('/temp', {}), { status: 200, body: '21C' });
});
