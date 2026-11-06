const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const path = require('node:path');

const template = fs.readFileSync(path.join(__dirname, '../../app/views/users/content_list.html.erb'), 'utf8');
const script = template.match(/<script>([\s\S]*?)<\/script>/)[1];
const flush = () => new Promise(resolve => setImmediate(resolve));

function setup() {
  const nodes = {};
  for (const id of ['grid-view', 'list-view', 'content-grid', 'content-list', 'content-loader', 'content-load-more', 'content-load-status']) {
    nodes[id] = {
      href: '/users/1/characters?page=2', children: [], events: {}, attributes: {},
      classList: { add() {}, remove() {} },
      addEventListener(name, callback) { this.events[name] = callback; },
      setAttribute(name, value) { this.attributes[name] = value; },
      removeAttribute(name) { delete this.attributes[name]; },
      append(...children) { this.children.push(...children); }
    };
  }
  const timers = new Map();
  const requests = [];
  let observer;
  class Observer {
    constructor(callback) { this.callback = callback; observer = this; }
    observe() { this.active = true; }
    disconnect() { this.active = false; }
    intersect() { this.callback([{ isIntersecting: true }]); }
  }
  const fetch = (url) => new Promise(resolve => requests.push({ url, resolve }));
  const document = {
    hidden: false,
    getElementById: id => nodes[id],
    addEventListener: (_, callback) => callback()
  };
  vm.runInNewContext(script, {
    document, window: { fetch, IntersectionObserver: Observer, AbortController, addEventListener() {} },
    IntersectionObserver: Observer, fetch, AbortController,
    DOMParser: class {
      parseFromString() {
        return { getElementById: id => ({ children: [id + '-new'] }) };
      }
    },
    setTimeout(callback, delay) { const key = {}; timers.set(key, { callback, delay }); return key; },
    clearTimeout(key) { timers.delete(key); }
  });
  return {
    nodes, requests, observer, document,
    cooldown() {
      for (const [key, timer] of timers) {
        if (timer.delay === 1000) { timers.delete(key); timer.callback(); }
      }
    },
    respond(nextUrl) {
      requests.at(-1).resolve({ ok: true, redirected: false, json: async () => ({ html: 'batch', next_url: nextUrl }) });
    }
  };
}

test('serializes requests, enforces cooldown, appends both views and stops at the end', async () => {
  const app = setup();
  app.observer.intersect();
  app.observer.intersect();
  assert.equal(app.requests.length, 1);
  app.respond('/users/1/characters?page=3');
  await flush();
  assert.deepEqual(app.nodes['content-grid'].children, ['content-grid-new']);
  assert.deepEqual(app.nodes['content-list'].children, ['content-list-new']);
  app.observer.intersect();
  assert.equal(app.requests.length, 1);
  app.cooldown();
  assert.equal(app.observer.active, true);
  app.observer.intersect();
  assert.equal(app.requests[1].url, '/users/1/characters?page=3');
  app.respond(null);
  await flush();
  app.cooldown();
  app.observer.intersect();
  assert.equal(app.requests.length, 2);
  assert.equal(app.observer.active, false);
  assert.equal(app.nodes['content-load-more'].hidden, true);
});

test('failed requests stop automatic loading and allow explicit retry of the same page', async () => {
  const app = setup();
  app.observer.intersect();
  app.requests[0].resolve({ ok: false });
  await flush();
  app.cooldown();
  assert.equal(app.observer.active, false);
  assert.equal(app.nodes['content-load-more'].textContent, 'Retry');
  assert.equal(app.nodes['content-grid'].children.length, 0);
  app.nodes['content-load-more'].events.click({ preventDefault() {} });
  assert.equal(app.requests.length, 2);
  assert.equal(app.requests[1].url, app.requests[0].url);
});

test('does not automatically request a batch in a hidden tab', () => {
  const app = setup();
  app.document.hidden = true;
  app.observer.intersect();
  assert.equal(app.requests.length, 0);
});
