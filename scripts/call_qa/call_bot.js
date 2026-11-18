#!/usr/bin/env node
/*
 * FG Tracker 1:1 call QA bot (signaling only, NO media).
 *
 * Plays the OTHER user of a 1:1 call on a real /callSignaling server
 * (socket.io v4) so the app's call flow can be tested end to end at the
 * signaling level. Every SDP / ICE value this bot sends is FAKE and clearly
 * marked as such: no audio or video ever flows.
 *
 * Pairs with integration_test/call_signaling_e2e_test.dart. See README.md.
 *
 * Environment (secrets are never logged):
 *   SIGNALING_URL      base server URL, e.g. https://staging.example.com
 *                      (the namespace below is appended)
 *   SIGNALING_NAMESPACE default /callSignaling
 *   BOT_USER_ID        user id of the bot test account (required)
 *   BOT_TOKEN          optional; sent as socket.io `auth.token`
 *   BOT_TOKEN_IN_QUERY 1 = also send it as `query.token` (off by default:
 *                      query strings end up in server / proxy logs)
 *   APP_USER_ID        user id of the app test account (required for
 *                      call-app; when set, calls from anyone else are ignored)
 *   MODE               one mode, a comma list, or "suite":
 *                        answer | reject | busy | timeout | answer-then-end |
 *                        answer-then-drop | call-app[:accept|:decline|:any]
 *                      A token may end in *N to repeat it, e.g.
 *                        MODE="answer*3,reject*3,call-app:accept*3"
 *   REPEAT             repeat count for a single MODE without *N (default 1)
 *   EXPECT             default expectation for call-app (accept|decline|any)
 *   ANSWER_DELAY_SECONDS   wait before answering / rejecting (default 2)
 *   HOLD_SECONDS       how long an answered call is held (default 5)
 *   DROP_SECONDS       socket outage in answer-then-drop (default 5)
 *   DROP_KIND          transport (default: engine closed, like a network
 *                      loss, auto reconnect) | client (socket.disconnect())
 *   RING_TIMEOUT_SECONDS  how long the bot rings the app in call-app, and
 *                      the base for the timeout mode wait (default 60)
 *   MIN_RING_SECONDS   timeout mode: fail if the caller gives up earlier
 *                      (default 30; the app rings 45 s, kCallRingTimeout)
 *   WAIT_CALL_SECONDS  how long a callee step waits for newCall (default 300)
 *   END_WAIT_SECONDS   answer mode: how long to wait for the app's hang-up
 *                      (default 180)
 *   STEP_GAP_SECONDS   pause before a call-app step (default 8)
 *   IS_VIDEO           1 = call-app places a video call (default voice)
 *   TIMEOUT_SECONDS    hard limit for the whole run (default 3600)
 *
 * Exit code: 0 when every step had the expected outcome, 1 otherwise.
 */
'use strict';

const { io } = require('socket.io-client');

// ---------------------------------------------------------------- config

const env = process.env;

function num(name, def) {
  const v = env[name];
  if (v === undefined || v === '') return def;
  const n = Number(v);
  if (!Number.isFinite(n) || n < 0) {
    console.error(`Invalid number in ${name}`);
    process.exit(1);
  }
  return n;
}

const CFG = {
  url: (env.SIGNALING_URL || '').replace(/\/+$/, ''),
  namespace: env.SIGNALING_NAMESPACE || '/callSignaling',
  botId: (env.BOT_USER_ID || '').trim(),
  token: env.BOT_TOKEN || '',
  tokenInQuery: env.BOT_TOKEN_IN_QUERY === '1',
  appUserId: (env.APP_USER_ID || '').trim(),
  mode: (env.MODE || '').trim(),
  repeat: num('REPEAT', 1),
  expect: (env.EXPECT || 'any').trim(),
  answerDelay: num('ANSWER_DELAY_SECONDS', 2),
  hold: num('HOLD_SECONDS', 5),
  drop: num('DROP_SECONDS', 5),
  dropKind: (env.DROP_KIND || 'transport').trim(),
  ringTimeout: num('RING_TIMEOUT_SECONDS', 60),
  minRing: num('MIN_RING_SECONDS', 30),
  waitCall: num('WAIT_CALL_SECONDS', 300),
  endWait: num('END_WAIT_SECONDS', 180),
  stepGap: num('STEP_GAP_SECONDS', 8),
  isVideo: env.IS_VIDEO === '1',
  timeout: num('TIMEOUT_SECONDS', 3600),
};

const CALLEE_MODES = new Set([
  'answer',
  'reject',
  'busy',
  'timeout',
  'answer-then-end',
  'answer-then-drop',
]);
const EXPECTS = new Set(['accept', 'decline', 'any']);

/// Same order as the cases in integration_test/call_signaling_e2e_test.dart
/// (each case runs 3 times there).
const SUITE = [
  'answer*3', // outgoing: bot answers, app hangs up
  'reject*3', // outgoing: bot declines
  'busy*3', // outgoing: bot is busy
  'timeout*3', // outgoing: bot never answers, app times out (45 s each)
  'answer-then-end*3', // outgoing: bot answers, bot hangs up
  'answer-then-drop*3', // outgoing: bot answers, bot's socket drops + returns
  'answer*3', // outgoing: bot answers, APP's socket drops + returns
  'call-app:accept*3', // incoming: bot calls, app accepts
  'call-app:decline*3', // incoming: bot calls, app declines
].join(',');

function parseSteps(mode) {
  const src = mode === 'suite' ? SUITE : mode;
  const tokens = src
    .split(',')
    .map((t) => t.trim())
    .filter(Boolean);
  const steps = [];
  for (const token of tokens) {
    const m = /^([a-z-]+)(?::([a-z]+))?(?:\*(\d+))?$/.exec(token);
    if (!m) throw new Error(`Bad MODE token "${token}"`);
    const name = m[1];
    const expect = m[2] || CFG.expect;
    const times = m[3]
      ? Number(m[3])
      : tokens.length === 1 && mode !== 'suite'
        ? CFG.repeat
        : 1;
    if (name !== 'call-app' && !CALLEE_MODES.has(name)) {
      throw new Error(`Unknown mode "${name}"`);
    }
    if (name === 'call-app' && !EXPECTS.has(expect)) {
      throw new Error(`Unknown call-app expectation "${expect}"`);
    }
    if (name !== 'call-app' && m[2]) {
      throw new Error(`Only call-app takes ":expect" ("${token}")`);
    }
    for (let i = 0; i < times; i++) steps.push({ mode: name, expect });
  }
  return steps;
}

// ---------------------------------------------------------------- logging

const SECRET_KEY = /token|auth|password|secret|credential|cookie/i;
const SDP_KEY = /^(sdp|sdpOffer|sdpAnswer|offer|answer|sdpOfferCompressed)$/i;

/// Never logs secrets or full SDP / ICE: lengths only.
function sanitize(value, key = '') {
  if (value === null || value === undefined) return value;
  if (SECRET_KEY.test(key)) return '<redacted>';
  if (typeof value === 'string') {
    if (SDP_KEY.test(key) || value.startsWith('v=0')) {
      return `<sdp len=${value.length}>`;
    }
    if (key === 'candidate') return `<candidate len=${value.length}>`;
    if (value.length > 160) return `<string len=${value.length}>`;
    return value;
  }
  if (Array.isArray(value)) return value.map((v) => sanitize(v, key));
  if (typeof value === 'object') {
    const out = {};
    for (const [k, v] of Object.entries(value)) out[k] = sanitize(v, k);
    return out;
  }
  return value;
}

function log(level, msg, data) {
  const line = `[${new Date().toISOString()}] [call-bot] ${level.padEnd(5)} ${msg}`;
  if (data === undefined) console.log(line);
  else console.log(`${line} ${JSON.stringify(sanitize(data))}`);
}

// ---------------------------------------------------------------- fake media

const FAKE_MARK = 'FG-CALL-QA FAKE SDP - signaling test only, NO media';

function fakeSdp(kind) {
  return [
    'v=0',
    'o=fg-call-qa 0 0 IN IP4 192.0.2.1',
    `s=${FAKE_MARK} (${kind})`,
    't=0 0',
    'a=x-fg-call-qa:fake',
    'm=audio 9 UDP/TLS/RTP/SAVPF 111',
    'c=IN IP4 192.0.2.1',
    'a=inactive',
    '',
  ].join('\r\n');
}

/// TEST-NET-1 address (RFC 5737): never routable.
const FAKE_ICE = {
  id: '0',
  label: 0,
  candidate: 'candidate:fgcallqa 1 udp 1 192.0.2.1 9 typ host',
};

// ---------------------------------------------------------------- socket + events

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

let socket = null;
let connectCount = 0;
const events = []; // {seq, at, event, data}
const waiters = new Set();
let activeCall = null;
let unexpected = 0;

function mark() {
  return events.length;
}

/// Resolves with the first event (from index [fromSeq] on, including events
/// that already arrived) whose name is in [names] and that passes [pred];
/// resolves null after [timeoutMs].
function waitEvent(names, pred, timeoutMs, fromSeq = mark()) {
  const set = new Set(names);
  for (let i = fromSeq; i < events.length; i++) {
    const e = events[i];
    if (set.has(e.event) && pred(e.data)) return Promise.resolve(e);
  }
  return new Promise((resolve) => {
    const w = {
      check(e) {
        if (!set.has(e.event) || !pred(e.data)) return false;
        clearTimeout(timer);
        waiters.delete(w);
        resolve(e);
        return true;
      },
    };
    const timer = setTimeout(() => {
      waiters.delete(w);
      resolve(null);
    }, timeoutMs);
    waiters.add(w);
  });
}

function send(event, data) {
  log('->', event, data);
  socket.emit(event, data);
}

function str(v) {
  return v === undefined || v === null ? '' : String(v);
}

function parseMaybeJson(v) {
  if (typeof v !== 'string') return v && typeof v === 'object' ? v : {};
  try {
    const o = JSON.parse(v);
    return o && typeof o === 'object' ? o : {};
  } catch (_) {
    return {}; // compressed / unknown format
  }
}

function parseIncoming(d) {
  const callData = parseMaybeJson(d && d.callData);
  const callId = str(d.callId || callData.callId);
  return {
    callId,
    sessionId: str(
      d.sessionId || d.session_id || callData.sessionId || callData.session_id || callId,
    ),
    callerId: str(d.callerId || callData.callerId || d.remoteUserId),
    receiverId: CFG.botId,
    sdpOffer: d.sdpOffer || d.offer || null,
  };
}

/// Event belongs to [call] (or carries no id at all).
function sameCall(call) {
  return (d) => {
    if (!d || typeof d !== 'object') return true;
    const ids = [d.callId, d.sessionId, d.session_id].map(str).filter(Boolean);
    if (ids.length === 0) return true;
    return ids.includes(call.callId) || ids.includes(call.sessionId);
  };
}

const END_EVENTS = ['callEnded', 'endCall', 'missedCall'];

function connect() {
  const query = { callerId: CFG.botId };
  if (CFG.token && CFG.tokenInQuery) query.token = CFG.token;
  const opts = {
    transports: ['websocket'],
    query,
    forceNew: true,
    reconnection: true,
  };
  if (CFG.token) opts.auth = { token: CFG.token };

  log('INFO', `connecting to ${CFG.url}${CFG.namespace} as bot user ${CFG.botId}`);
  socket = io(`${CFG.url}${CFG.namespace}`, opts);

  socket.on('connect', () => {
    connectCount++;
    log('INFO', `connected (socket ${socket.id}, connect #${connectCount})`);
  });
  socket.on('disconnect', (reason) => log('INFO', `disconnected: ${reason}`));
  socket.on('connect_error', (err) =>
    log('WARN', `connect_error: ${err && err.message ? err.message : 'unknown'}`),
  );

  socket.onAny((event, data) => {
    const e = { seq: events.length, at: Date.now(), event, data };
    events.push(e);
    log('<-', event, data);

    if (event === 'force_logout') {
      log('ERROR', 'server sent force_logout to the bot account');
    }
    if (event === 'newCall' && activeCall) {
      const call = parseIncoming(data || {});
      if (call.callId && call.callId !== activeCall.callId) {
        unexpected++;
        log('WARN', `second newCall ${call.callId} during call ${activeCall.callId}: answering busy`);
        send('CallingStatus', {
          callId: call.callId,
          remoteUserId: call.callerId,
          callingStatus: 'busy',
        });
        send('rejectCall', { callId: call.callId, remoteUserId: call.callerId, reason: 'busy' });
      }
    }
    for (const w of [...waiters]) w.check(e);
  });

  return waitConnected(30000, 0);
}

/// Waits until the socket has connected more than [afterCount] times.
async function waitConnected(timeoutMs, afterCount = connectCount) {
  const end = Date.now() + timeoutMs;
  while (Date.now() < end) {
    if (socket.connected && connectCount > afterCount) return true;
    await sleep(100);
  }
  return false;
}

async function waitDisconnected(timeoutMs) {
  const end = Date.now() + timeoutMs;
  while (Date.now() < end) {
    if (!socket.connected) return true;
    await sleep(50);
  }
  return false;
}

/// Drops the signaling socket for about [seconds] and waits for it to return.
async function dropAndReconnect(seconds) {
  const before = connectCount;
  const ms = Math.max(0, seconds * 1000);
  log('INFO', `dropping signaling socket for ~${seconds}s (kind=${CFG.dropKind})`);
  if (CFG.dropKind === 'client') {
    socket.disconnect();
    await sleep(ms);
    socket.connect();
  } else {
    const m = socket.io;
    m.reconnectionDelay(ms);
    m.reconnectionDelayMax(ms);
    m.randomizationFactor(0);
    // Closing the engine looks like a network loss to the server
    // ("transport close") and triggers the client's auto reconnect.
    if (m.engine) m.engine.close();
    await waitDisconnected(3000);
  }
  const ok = await waitConnected(ms + 30000, before);
  const m = socket.io;
  m.reconnectionDelay(1000);
  m.reconnectionDelayMax(5000);
  m.randomizationFactor(0.5);
  return ok;
}

// ---------------------------------------------------------------- steps

function fromApp(d) {
  if (!CFG.appUserId) return true;
  const call = parseIncoming(d || {});
  if (call.callerId === CFG.appUserId) return true;
  log('WARN', `ignoring newCall from user ${call.callerId} (not APP_USER_ID)`);
  return false;
}

function endPayload(call, remote, caller, receiver) {
  return {
    callId: call.callId,
    remoteUserId: remote,
    callerId: caller,
    receiverId: receiver,
    sessionId: call.sessionId,
  };
}

/// Callee side of an accept: answerCall directly when newCall carried the
/// offer, else acceptCallFromCallKit -> sdpOfferFromCaller -> answerCall.
async function answer(call) {
  await sleep(CFG.answerDelay * 1000);
  if (!call.sdpOffer) {
    const from = mark();
    send('acceptCallFromCallKit', {
      callerId: call.callerId,
      sessionId: call.sessionId,
      callId: call.callId,
      receiverId: CFG.botId,
    });
    const o = await waitEvent(['sdpOfferFromCaller'], sameCall(call), 30000, from);
    if (!o) return 'no sdpOfferFromCaller within 30 s after acceptCallFromCallKit';
  }
  send('answerCall', {
    callId: call.callId,
    callerId: call.callerId,
    sdpAnswer: { sdp: fakeSdp('answer'), type: 'answer' },
  });
  send('IceCandidate', { remoteUserId: call.callerId, iceCandidate: FAKE_ICE });
  return null;
}

async function calleeStep(step) {
  const got = await waitEvent(['newCall'], fromApp, CFG.waitCall * 1000);
  if (!got) return { ok: false, detail: `no newCall within ${CFG.waitCall} s` };
  const call = parseIncoming(got.data || {});
  activeCall = call;
  const startSeq = got.seq + 1;
  const mine = sameCall(call);
  log('INFO', `incoming call ${call.callId} from ${call.callerId} (offer in newCall: ${!!call.sdpOffer})`);

  if (step.mode === 'busy') {
    send('CallingStatus', { callId: call.callId, remoteUserId: call.callerId, callingStatus: 'busy' });
    await sleep(CFG.answerDelay * 1000);
    send('rejectCall', { callId: call.callId, remoteUserId: call.callerId, reason: 'busy' });
    await sleep(2000);
    return { ok: true, detail: 'sent CallingStatus busy + rejectCall(busy)' };
  }

  send('CallingStatus', { callId: call.callId, remoteUserId: call.callerId, callingStatus: 'Ringing' });

  if (step.mode === 'reject') {
    await sleep(CFG.answerDelay * 1000);
    send('rejectCall', { callId: call.callId, remoteUserId: call.callerId, reason: 'declined' });
    await sleep(2000);
    return { ok: true, detail: 'sent rejectCall(declined)' };
  }

  if (step.mode === 'timeout') {
    const t0 = Date.now();
    const end = await waitEvent(END_EVENTS, mine, (CFG.ringTimeout + 30) * 1000, startSeq);
    if (!end) return { ok: false, detail: 'caller never gave up (no callEnded / missedCall)' };
    const s = Math.round((Date.now() - t0) / 1000);
    if (s < CFG.minRing) {
      return { ok: false, detail: `caller gave up after ${s} s (< MIN_RING_SECONDS ${CFG.minRing})` };
    }
    return { ok: true, detail: `caller gave up after ${s} s via ${end.event}` };
  }

  // answer, answer-then-end, answer-then-drop
  const err = await answer(call);
  if (err) return { ok: false, detail: err };

  if (step.mode === 'answer') {
    const end = await waitEvent(END_EVENTS, mine, CFG.endWait * 1000, startSeq);
    if (!end) return { ok: false, detail: `app did not hang up within ${CFG.endWait} s` };
    return { ok: true, detail: `app hung up (${end.event})` };
  }

  const early = await waitEvent(END_EVENTS, mine, CFG.hold * 1000, startSeq);
  if (early) return { ok: false, detail: `call ended before the bot hung up (${early.event})` };

  if (step.mode === 'answer-then-drop') {
    const back = await dropAndReconnect(CFG.drop);
    if (!back) return { ok: false, detail: 'bot socket did not reconnect' };
    const after = mark();
    // NEW event, the backend may not support it yet: the reply (if any) is
    // only logged.
    // Same shape as the app (calling_controller.dart _onSignalingReconnected).
    send('rejoinCall', {
      callId: call.callId,
      sessionId: call.sessionId,
      remoteUserId: call.callerId,
    });
    const ended = await waitEvent(END_EVENTS, mine, CFG.hold * 1000, after);
    if (ended) {
      return { ok: false, detail: `call did not survive the bot's socket drop (${ended.event})` };
    }
    const endedDuringDrop = events
      .slice(startSeq)
      .find((e) => END_EVENTS.includes(e.event) && mine(e.data));
    if (endedDuringDrop) {
      return { ok: false, detail: `received ${endedDuringDrop.event} around the drop` };
    }
  }

  send('endCall', endPayload(call, call.callerId, call.callerId, CFG.botId));
  await sleep(1000);
  return { ok: true, detail: 'bot hung up' };
}

async function callAppStep(step) {
  await sleep(CFG.stepGap * 1000);
  const from = mark();
  send('makeCall', {
    remoteUserId: CFG.appUserId,
    sdpOffer: { sdp: fakeSdp('offer'), type: 'offer' },
    is_video: CFG.isVideo,
    callerId: CFG.botId,
  });
  const created = await waitEvent(['callCreated'], () => true, 15000, from);
  if (!created) return { ok: false, detail: 'no callCreated within 15 s' };
  const call = {
    callId: str(created.data && created.data.callId),
    sessionId: str(created.data && (created.data.sessionId || created.data.session_id)),
  };
  if (!call.sessionId) call.sessionId = call.callId;
  activeCall = call;
  const mine = sameCall(call);

  const outcomeEvents = [
    'callAnswered',
    'callRejected',
    'callStatus',
    'callError',
    'callBlocked',
    ...END_EVENTS,
  ];
  const isOutcome = mine;
  let outcome = null;
  let detail = '';
  const deadline = Date.now() + CFG.ringTimeout * 1000;
  let seq = from;
  while (!outcome) {
    const left = deadline - Date.now();
    if (left <= 0) break;
    const e = await waitEvent(outcomeEvents, isOutcome, left, seq);
    if (!e) break;
    seq = e.seq + 1;
    if (e.event === 'callStatus') {
      const st = str(e.data && (e.data.status || e.data.callingStatus)).toLowerCase();
      if (st === 'rejected' || st === 'declined' || st === 'busy') {
        outcome = 'decline';
        detail = `callStatus ${st}`;
      }
      continue; // Ringing etc.
    }
    if (e.event === 'callAnswered') outcome = 'accept';
    else if (e.event === 'callRejected') outcome = 'decline';
    else if (e.event === 'callError' || e.event === 'callBlocked') outcome = 'error';
    else outcome = 'ended';
    detail = e.event;
  }

  if (!outcome) {
    send('missCall', { callId: call.callId, remoteUserId: CFG.appUserId });
    send('endCall', endPayload(call, CFG.appUserId, CFG.botId, CFG.appUserId));
    outcome = 'timeout';
    detail = `no answer within ${CFG.ringTimeout} s`;
  }

  if (outcome === 'accept') {
    send('IceCandidate', { remoteUserId: CFG.appUserId, iceCandidate: FAKE_ICE });
    const early = await waitEvent(END_EVENTS, mine, CFG.hold * 1000, seq);
    if (early) {
      return { ok: false, detail: `app accepted, then the call ended early (${early.event})` };
    }
    send('endCall', endPayload(call, CFG.appUserId, CFG.botId, CFG.appUserId));
    await sleep(1000);
  }

  const want = step.expect;
  const ok =
    (want === 'any' && (outcome === 'accept' || outcome === 'decline')) || want === outcome;
  return { ok, detail: `outcome=${outcome} (${detail}), expected=${want}` };
}

// ---------------------------------------------------------------- main

let finished = false;

function finish(code, why) {
  if (finished) return;
  finished = true;
  log(code === 0 ? 'PASS' : 'FAIL', why);
  try {
    if (socket) socket.disconnect();
  } catch (_) {
    /* ignore */
  }
  setTimeout(() => process.exit(code), 200);
}

async function main() {
  const missing = [];
  if (!CFG.url) missing.push('SIGNALING_URL');
  if (!CFG.botId) missing.push('BOT_USER_ID');
  if (!CFG.mode) missing.push('MODE');
  if (missing.length) {
    console.error(`Missing env: ${missing.join(', ')} (see scripts/call_qa/README.md)`);
    process.exit(1);
  }
  if (!['transport', 'client'].includes(CFG.dropKind)) {
    console.error('DROP_KIND must be transport or client');
    process.exit(1);
  }

  let steps;
  try {
    steps = parseSteps(CFG.mode);
  } catch (e) {
    console.error(e.message);
    process.exit(1);
  }
  if (steps.some((s) => s.mode === 'call-app') && !CFG.appUserId) {
    console.error('call-app needs APP_USER_ID');
    process.exit(1);
  }

  const hard = setTimeout(() => finish(1, `global timeout (${CFG.timeout} s)`), CFG.timeout * 1000);

  log('INFO', `plan: ${steps.length} step(s): ${steps.map((s) => (s.mode === 'call-app' ? `call-app:${s.expect}` : s.mode)).join(', ')}`);
  log('INFO', 'all SDP / ICE sent by this bot is FAKE (signaling only, no media)');

  if (!(await connect())) {
    clearTimeout(hard);
    finish(1, 'could not connect to the signaling server within 30 s');
    return;
  }

  const results = [];
  for (let i = 0; i < steps.length; i++) {
    const step = steps[i];
    const label = step.mode === 'call-app' ? `call-app:${step.expect}` : step.mode;
    log('STEP', `${i + 1}/${steps.length} ${label} - start`);
    const t0 = Date.now();
    let r;
    try {
      r = step.mode === 'call-app' ? await callAppStep(step) : await calleeStep(step);
    } catch (e) {
      r = { ok: false, detail: `exception: ${e && e.message ? e.message : e}` };
    }
    activeCall = null;
    r.ms = Date.now() - t0;
    results.push({ label, ...r });
    log(r.ok ? 'OK' : 'FAIL', `${i + 1}/${steps.length} ${label}: ${r.detail} (${r.ms} ms)`);
    if (finished) return;
  }

  clearTimeout(hard);
  const failed = results.filter((r) => !r.ok);
  log('INFO', '---------------- summary ----------------');
  results.forEach((r, i) =>
    log(r.ok ? 'OK' : 'FAIL', `${i + 1}. ${r.label}: ${r.detail}`),
  );
  if (unexpected) log('WARN', `${unexpected} unexpected overlapping newCall event(s)`);
  if (failed.length || unexpected) {
    finish(1, `${failed.length} of ${results.length} step(s) failed, ${unexpected} unexpected call(s)`);
  } else {
    finish(0, `all ${results.length} step(s) passed`);
  }
}

process.on('SIGINT', () => finish(1, 'interrupted'));
process.on('unhandledRejection', (e) =>
  finish(1, `unhandled rejection: ${e && e.message ? e.message : e}`),
);

main();
