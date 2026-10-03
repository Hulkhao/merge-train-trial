const test = require('node:test');
const assert = require('node:assert');
const dispatch = require('../../src/index');

test('/now returns 200 with ISO datetime body', () => {
  const res = dispatch('/now', {});
  assert.equal(res.status, 200);
  assert.match(res.body, /^\d{4}-\d{2}-\d{2}T/);
});
