const test = require('node:test');
const assert = require('node:assert');
const dispatch = require('../../src/index');

test('baseline dispatch /hello', () => {
  const r = dispatch('/hello');
  assert.equal(r.status, 200);
  assert.match(r.body, /merge-train trial/);
});

test('unknown route returns 404', () => {
  assert.equal(dispatch('/nope').status, 404);
});
