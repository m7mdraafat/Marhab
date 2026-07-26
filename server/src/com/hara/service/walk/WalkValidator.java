package com.hara.service.walk;

import com.hara.domain.model.Place;

/**
 * Server-side walk validation + delay computation. Mirrors
 * {@code Character.defineSteps} timing (see {@code docs/04 §4.8}):
 * cardinal moves take {@code 7 * 25ms / speed}, diagonals
 * {@code 11 * 25ms / speed}. For multi-tile walks we approximate by
 * Chebyshev distance (max(|dx|, |dy|)) treating each step as the diagonal
 * cost when both axes move — a conservative upper bound the client will
 * never beat.
 *
 * <p>Pathfinding-side validation is deferred to Wave 5+. Today we only:
 * <ul>
 *   <li>reject out-of-bounds targets,</li>
 *   <li>reject targets on non-walkable cells,</li>
 *   <li>compute a delay that matches the client's local walk timer.</li>
 * </ul>
 * That's enough to keep the avatar from desyncing on a freshly-spawned
 * open street.
 */
public final class WalkValidator {

    private static final int MS_PER_TICK         = 25;
    private static final int CARDINAL_SUBSTEPS   = 7;
    private static final int DIAGONAL_SUBSTEPS   = 11;
    private static final int MIN_DELAY_MS        = 100;
    private static final int MAX_DELAY_MS        = 60_000; // safety cap

    public enum Outcome { OK, OUT_OF_BOUNDS, BLOCKED }

    public static final class Result {
        public final Outcome outcome;
        public final long delayMs;
        private Result(Outcome outcome, long delayMs) {
            this.outcome = outcome; this.delayMs = delayMs;
        }
    }

    private WalkValidator() {}

    public static Result validate(Place place, int startX, int startY,
                                  int targetX, int targetY, double speed) {
        var grid = place.grid();
        if (!grid.inBounds(targetX, targetY)) {
            return new Result(Outcome.OUT_OF_BOUNDS, 0);
        }
        if (!grid.isPlainWalkable(targetX, targetY)) {
            return new Result(Outcome.BLOCKED, 0);
        }
        long delay = computeDelayMs(startX, startY, targetX, targetY, speed);
        return new Result(Outcome.OK, delay);
    }

    /** Visible for tests. */
    public static long computeDelayMs(int sx, int sy, int tx, int ty, double speed) {
        if (speed <= 0) speed = 1.0;
        int dx = Math.abs(tx - sx);
        int dy = Math.abs(ty - sy);
        int diagonalSteps = Math.min(dx, dy);
        int cardinalSteps = Math.abs(dx - dy);
        double substeps = diagonalSteps * (DIAGONAL_SUBSTEPS / speed)
                        + cardinalSteps * (CARDINAL_SUBSTEPS / speed);
        long ms = (long) Math.ceil(substeps * MS_PER_TICK);
        return Math.max(MIN_DELAY_MS, Math.min(MAX_DELAY_MS, ms));
    }
}
