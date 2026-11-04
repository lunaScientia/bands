// Run the actual Max controller against parameter mocks with documented live.text
// semantics. These checks cover control state, not native Live UI/automation.
const fs = require('fs');
const vm = require('vm');
const assert = require('assert/strict');
const source = fs.readFileSync('source/bands_control.js', 'utf8');
const patch = JSON.parse(fs.readFileSync('source/BANDS.maxpat', 'utf8')).patcher;
const parameters = patch.boxes.map(w => w.box).filter(b => b.parameter_enable);

function harness(saved = {}) {
    const values = {}, objects = {}, outputs = {}, writes = [];
    const context = {
        jsarguments: ['bands_control.js', 'test'],
        arrayfromargs: a => Array.from(a),
        messnamed: (name, value) => { outputs[name] = Array.from(value); },
        patcher: { getnamed: name => {
            assert(objects[name], 'Unknown parameter: ' + name);
            return objects[name];
        } }
    };
    function emit(name) {
        if (name.startsWith('edge')) context.crossover(Number(name.slice(4)), values[name]);
        else if (/^(gain|solo|mute)\d$/.test(name)) context[name.slice(0, -1)](Number(name.slice(-1)), values[name]);
        else context[name](values[name]);
    }
    for (const box of parameters) {
        const name = box.varname;
        values[name] = saved[name] ?? box.saved_attribute_attributes.valueof.parameter_initial[0];
        objects[name] = { message: (selector, value) => {
            if (selector === 'set') { values[name] = value; writes.push([name, value]); return; }
            if (selector === 'bang') {
                if (box.maxclass === 'live.text') values[name] = values[name] ? 0 : 1;
            } else if (selector !== 'outputvalue') values[name] = selector;
            emit(name);
        } };
    }
    for (let i = 0; i < 5; i++) objects['range' + i] = {message: () => {}};
    vm.createContext(context);
    vm.runInContext(source, context);
    context.init();
    return { context, values, outputs, writes, event: (name, value) => objects[name].message(value),
        click: name => objects[name].message('bang') };
}
function verify(h) {
    const anySolo = Array.from({length: 5}, (_, i) => h.values['solo' + i]).some(Boolean);
    for (let i = 0; i < 5; i++) {
        const s = h.values['solo' + i], m = h.values['mute' + i];
        assert(!(s && m), 'Solo and Mute both on in band ' + i);
        assert.equal(h.context.solos[i], s);
        assert.equal(h.context.mutes[i], m);
        const active = !m && (!anySolo || s);
        const expected = active ? Math.pow(10, h.values['gain' + i] / 20) : 0;
        assert.deepEqual(h.outputs['test-gain' + i], [expected, 25]);
    }
}
for (let band = 0; band < 5; band++) {
    const h = harness();
    assert.equal(h.values.original, 0, 'init must not toggle Original');
    assert.equal(h.context.solos.reduce((a,b) => a+b, 0), 0, 'init must not activate Solo');
    verify(h);
    h.click('solo' + band); verify(h);
    h.click('mute' + band); verify(h);
    assert.equal(h.values['solo' + band], 0);
    assert.equal(h.values['mute' + band], 1);
    h.click('solo' + band); verify(h);
    assert.equal(h.values['mute' + band], 0);
    h.click('solo' + band); verify(h);
    assert.equal(h.values['mute' + band], 0, 'turning Solo off must not enable Mute');
    h.click('mute' + band); h.click('mute' + band); verify(h);
    assert.equal(h.values['solo' + band], 0, 'turning Mute off must not enable Solo');
}
const h = harness({gain0:-12, solo0:1, solo2:1, mute4:1, trim:-3, original:1, edge0:25});
verify(h);
const saved = {...h.values};
h.context.init(); h.context.init();
assert.deepEqual(h.values, saved, 'repeated init must preserve saved parameters');
verify(harness(saved));
h.event('mute0', 1); verify(h);
assert.equal(h.values.solo2, 1, 'another band must keep its Solo');
h.event('solo0', 1); verify(h);
assert.equal(h.values.solo2, 1, 'multiple solos must remain possible');
for (let i = 0; i < 5; i++) {
    const conflict = harness({['solo'+i]:1, ['mute'+i]:1});
    assert.equal(conflict.values['solo'+i], 1);
    assert.equal(conflict.values['mute'+i], 0);
    verify(conflict);
}
for (let n = 0; n < 2000; n++) {
    h.event((n % 3 ? 'solo' : 'mute') + n % 5, n % 4 ? 1 : 0);
    verify(h);
}
h.context.reset();verify(h);
assert.equal(h.values.original, 0);
assert.equal(h.values.trim, 0);
assert(h.context.solos.every(x => x === 0));
assert(h.context.mutes.every(x => x === 0));
const baseline = {jsarguments: ['bands_control.js', 'baseline']};
vm.createContext(baseline);
vm.runInContext(fs.readFileSync('tests/fixtures/v1-original/bands_control.js', 'utf8'), baseline);
for (const rate of [44100, 48000, 88200, 96000, 192000]) {
    for (const frequency of [15, 30, 49, 50, 80, 139, 140, 250, 599, 600, 2500, 8000]) {
        assert.equal(JSON.stringify(h.context.coeff(frequency, rate)), JSON.stringify(baseline.coeff(frequency, rate)));
    }
}
const report = {status:'PASS', checks:['S to M and M to S in every band', 'no automatic opposite activation on off', 'multiple Solo bands', 'parameter and audio state agree', 'repeated init and saved values', 'legacy conflicting state', '2000 control events', 'reset', 'original filter coefficients and 25ms gain ramps'], limitations:'Mocked native parameters; not a Live UI or automation integration test.'};
fs.writeFileSync('tests/controller-results.json', JSON.stringify(report, null, 2)+'\n');
console.log(JSON.stringify(report, null, 2));
