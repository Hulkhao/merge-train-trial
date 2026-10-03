const test = require('node:test');
const assert = require('node:assert');
const dispatch = require('../../src/index');

test('/greet greets by name', () => {
  const r = dispatch('/greet', { name: '小明' });
  assert.equal(r.status, 200);
  assert.equal(r.body, 'Hi, 小明!');
});

test('/greet falls back to stranger', () => {
  const r = dispatch('/greet', {});
  assert.equal(r.status, 200);
  assert.equal(r.body, 'Hi, stranger!');
});
