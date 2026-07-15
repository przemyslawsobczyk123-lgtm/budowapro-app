import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = dirname(fileURLToPath(import.meta.url));
const html = readFileSync(resolve(root, "index.html"), "utf8");
const script = readFileSync(resolve(root, "app.js"), "utf8");
const extendedStyles = readFileSync(resolve(root, "extended.css"), "utf8");

const values = (attribute) =>
  [...html.matchAll(new RegExp(`${attribute}="([^"]+)"`, "g"))].map((match) => match[1]);

const screens = values("data-screen");
const screenSet = new Set(screens);
const ids = values("id");
const idSet = new Set(ids);
const prototypeTargets = values("data-target");
const shortcuts = values("data-shortcut");
const primaryTargets = values("data-app-target");

assert.equal(screens.length, screenSet.size, "Every screen name must be unique");
assert.equal(screens.length, 17, "The target prototype must expose all 17 detailed screens");
assert.equal(ids.length, idSet.size, "Every DOM id must be unique");
assert.equal(primaryTargets.length, 5, "The mobile navigation must contain exactly five tabs");
assert.deepEqual(primaryTargets, ["overview", "stages", "costs", "technical", "more"]);

for (const target of [...prototypeTargets, ...shortcuts, ...primaryTargets]) {
  assert.ok(screenSet.has(target), `Navigation target does not exist: ${target}`);
}

for (const labelledBy of values("aria-labelledby")) {
  for (const id of labelledBy.split(/\s+/)) {
    assert.ok(idSet.has(id), `aria-labelledby points to missing id: ${id}`);
  }
}

for (const id of values("for")) {
  assert.ok(idSet.has(id), `Label points to missing form control: ${id}`);
}

for (const screen of screens) {
  assert.match(script, new RegExp(`(?:"${screen}"|${screen}):\\s*\\{`), `Missing screen metadata: ${screen}`);
}

assert.match(html, /extended\.css/, "Extended component styles must be loaded");
assert.match(extendedStyles, /technical-evidence-grid\.jpg/, "Technical evidence asset must be referenced");
assert.ok(
  existsSync(resolve(root, "assets", "technical-evidence-grid.jpg")),
  "Technical evidence asset must exist locally",
);

assert.doesNotMatch(html, /on(click|change|submit)=/i, "Use event listeners instead of inline handlers");
assert.doesNotMatch(script, /console\.(log|warn|error)/, "Prototype must not contain debug console output");

console.log(`Mockup contract OK: ${screens.length} screens, ${primaryTargets.length} primary tabs.`);
