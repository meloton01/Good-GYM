import assert from 'node:assert/strict';
import { describe, test } from 'node:test';

import { mergeBest } from '../../src/domain/leaderboard_entry';
import { estimateOneRepMax } from '../../src/domain/one_rep_max';
import { monthKey, periodKeys, weekKey } from '../../src/domain/period_keys';
import { parseReason, parseRecordId, parseRecordInput } from '../../src/domain/record_input';
import { canAppeal, reviewBlocker } from '../../src/domain/review';
import { weightClassFor } from '../../src/domain/weight_class';

const now = new Date('2026-11-05T12:00:00Z');

/** Корректная заявка с заменой отдельных полей. */
const input = (extra: Record<string, unknown> = {}) => ({
  uploadId: 'abcdefghij0123456789',
  exerciseId: 'squat',
  weightKg: 140,
  reps: 3,
  performedAt: now.getTime() - 3_600_000,
  sex: 'male',
  bodyWeightKg: 82.5,
  ...extra,
});

describe('e1rm', () => {
  test('Epley formula rounded to 0.1 kg', () => {
    assert.equal(estimateOneRepMax(100, 5), 116.7);
    assert.equal(estimateOneRepMax(140, 3), 154);
  });

  test('single rep equals the weight', () => {
    assert.equal(estimateOneRepMax(180, 1), 180);
  });
});

describe('weight class', () => {
  test('upper bound is inclusive', () => {
    assert.equal(weightClassFor('male', 83), 'm83');
    assert.equal(weightClassFor('male', 83.1), 'm93');
    assert.equal(weightClassFor('female', 47), 'f47');
  });

  test('heavier than the last bound', () => {
    assert.equal(weightClassFor('male', 130), 'm120plus');
    assert.equal(weightClassFor('female', 90), 'f84plus');
  });
});

describe('period keys', () => {
  test('ISO week belongs to the year of its Thursday', () => {
    assert.equal(weekKey(new Date('2026-11-05T00:00:00Z')), 'w2026-45');
    assert.equal(weekKey(new Date('2027-01-01T00:00:00Z')), 'w2026-53');
    assert.equal(weekKey(new Date('2025-12-29T00:00:00Z')), 'w2026-01');
  });

  test('all time, month and week', () => {
    assert.equal(monthKey(now), 'm2026-11');
    assert.deepEqual(periodKeys(now), ['all', 'm2026-11', 'w2026-45']);
  });
});

describe('record input', () => {
  test('accepts a valid submission', () => {
    const parsed = parseRecordInput(input(), now);
    assert.equal(parsed?.weightKg, 140);
    assert.equal(parsed?.performedAt.getTime(), now.getTime() - 3_600_000);
  });

  test('rejects fields outside limits', () => {
    for (const extra of [
      { uploadId: '../other/file' },
      { exerciseId: 'curl' },
      { weightKg: 0 },
      { weightKg: 501 },
      { reps: 0 },
      { reps: 2.5 },
      { sex: 'other' },
      { bodyWeightKg: 20 },
      { performedAt: now.getTime() + 60_000 },
      { performedAt: now.getTime() - 400 * 86_400_000 },
      { performedAt: 'yesterday' },
    ]) {
      assert.equal(parseRecordInput(input(extra), now), null, JSON.stringify(extra));
    }
  });

  test('pull-ups allow zero added weight', () => {
    assert.notEqual(parseRecordInput(input({ exerciseId: 'pull_up', weightKg: 0 }), now), null);
  });

  test('reason and record id', () => {
    assert.equal(parseReason('  bar not visible '), 'bar not visible');
    assert.equal(parseReason('no'), null);
    assert.equal(parseReason('x'.repeat(301)), null);
    assert.equal(parseRecordId({ recordId: 'abcdefghij0123456789' }), 'abcdefghij0123456789');
    assert.equal(parseRecordId({ recordId: 'a/b' }), null);
  });
});

describe('review', () => {
  test('moderator cannot review own or reviewed records', () => {
    assert.equal(reviewBlocker({ uid: 'm1', status: 'pending' }, 'm1'), 'own-record');
    assert.equal(reviewBlocker({ uid: 'u1', status: 'approved' }, 'm1'), 'not-pending');
    assert.equal(reviewBlocker({ uid: 'u1', status: 'pending' }, 'm1'), null);
  });

  test('appeal only once, only by the author, only after rejection', () => {
    assert.equal(canAppeal({ uid: 'u1', status: 'rejected', appealed: false }, 'u1'), true);
    assert.equal(canAppeal({ uid: 'u1', status: 'rejected', appealed: true }, 'u1'), false);
    assert.equal(canAppeal({ uid: 'u1', status: 'approved', appealed: false }, 'u1'), false);
    assert.equal(canAppeal({ uid: 'u1', status: 'rejected', appealed: false }, 'u2'), false);
  });
});

describe('leaderboard best', () => {
  const record = { id: 'r1', weightKg: 140, e1rmKg: 154, sex: 'male', weightClass: 'm83' };

  test('first record sets both metrics', () => {
    assert.deepEqual(mergeBest(null, record), {
      bestWeightKg: 140,
      bestWeightRecordId: 'r1',
      bestE1rmKg: 154,
      bestE1rmRecordId: 'r1',
      sex: 'male',
      weightClass: 'm83',
    });
  });

  test('metrics improve independently', () => {
    const current = mergeBest(null, record)!;
    const lighterButMoreReps = { ...record, id: 'r2', weightKg: 130, e1rmKg: 160 };
    const merged = mergeBest(current, lighterButMoreReps)!;
    assert.equal(merged.bestWeightRecordId, 'r1');
    assert.equal(merged.bestE1rmRecordId, 'r2');
    assert.equal(mergeBest(merged, { ...record, id: 'r3', weightKg: 100, e1rmKg: 110 }), null);
  });
});
