const test = require('node:test');
const assert = require('node:assert');
const dispatch = require('../../src/index');

test('/temp returns 200 with Fahrenheit body', () => {
  const res = dispatch('/temp', {});
  assert.equal(res.status, 200);
  assert.equal(res.body, '70F');
});
