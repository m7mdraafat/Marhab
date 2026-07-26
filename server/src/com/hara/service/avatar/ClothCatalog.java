package com.hara.service.avatar;

import java.util.List;
import java.util.Map;

import com.hara.domain.enums.Gender;
import com.hara.domain.model.BaseClothOption;

/**
 * Curated starter wardrobe served by the {@code baseclothes} handler.
 * Wave 1-2 only needs enough variety to let the AvatarCreatePanel render
 * its carousels (body bottom/middle/top, shoes, pants, shirt, hair).
 *
 * <p><strong>Wire contract</strong>: each entry's {@code clip} is the
 * <em>bare</em> identifier from {@code ifile.1366} (e.g. {@code "A"},
 * {@code "n3"}, {@code "k52257s3"}). The client composes the SWF URL as
 * <pre>fileServer + "/static/items/clothes/" + gender + "_" + clip + "_" + color + (ver=="0" ? "" : "." + ver) + ".swf"</pre>
 * looking up the version via the {@code ifile.1366} row it already loaded.
 * Returning a composed name (e.g. {@code "m_A_1"}) would double-prefix and
 * 404 — every entry below was cross-verified against the mirrored disk
 * layout under {@code server/www/global/static/items/clothes/} for BOTH
 * genders.
 *
 * <p>{@code placeBit} carries the cloth-slot BITMASK value (not bit index):
 * body-bottom=1, body-middle=2, body-top=4, shoes=16, pants=64,
 * shirt=512, hair=131072 (see {@code docs/05 §5.3}). Memory note:
 * "baseclothes must return body slots placeBit 1, 2, and 4 (C, B, A)".
 *
 * <p>Future work: replace this hand-curated table with a query against the
 * parsed {@code ifile.1366} catalog filtered by {@code isBase=true}.
 */
public final class ClothCatalog {

    // Slot bitmasks (clip-slot, not Java enum)
    private static final int BIT_BODY_BOTTOM = 1;       // ClothType.BIT00
    private static final int BIT_BODY_MIDDLE = 2;       // BIT01
    private static final int BIT_BODY_TOP    = 4;       // BIT02
    private static final int BIT_SHOES       = 1 << 4;  // BIT04_FOOT       =  16
    private static final int BIT_PANTS       = 1 << 6;  // BIT06_LEG_TOP    =  64
    private static final int BIT_SHIRT       = 1 << 9;  // BIT09_SHIRT      = 512
    private static final int BIT_HAIR        = 1 << 17; // BIT17_HAIR       = 131072

    // Body parts use the same 4-color palette per ifile.1366.
    private static final int[] BODY_COLORS = { 1, 2, 8, 12 };

    /**
     * Same wardrobe for male and female today — every cloth listed below
     * exists as both an {@code m_*.swf} AND an {@code f_*.swf} on disk. The
     * {@code clip} field is the BARE identifier from {@code ifile.1366};
     * the client composes the URL as
     * {@code <gender>_<clip>_<color>[.<ver>].swf}.
     *
     * <p><strong>Why exactly one clip per slot?</strong> AvatarCreatePanel's
     * {@code randomAccesories()} fires {@code Math.random() * slot.length}
     * on every gender switch. With multiple clips per slot, each flip picks
     * a different SWF → forces a fresh download → loading spinner. The
     * panel's {@code waitingList} also accumulates stale entries from
     * mid-load switches (it never gets a {@code PackItemEvent} for a clip
     * the user flipped away from) so the spinner can persist indefinitely.
     * One clip per slot makes the random pick deterministic (always index 0)
     * → cached after first load → instant subsequent switches. Color
     * variety is preserved via the color picker on each slot.
     *
     * <p>Carousel layout (1 clip × N colors per slot):
     * <ul>
     *   <li>body bottom / middle / top — {@code C}, {@code B}, {@code A} × 4 colors</li>
     *   <li>hair  — {@code 84} × 12 colors</li>
     *   <li>shirt — {@code yby7z2ub} × 4 colors</li>
     *   <li>pants — {@code jv55e4xn} × 4 colors</li>
     *   <li>shoes — {@code abv74yn4} × 7 colors</li>
     * </ul>
     */
    private final List<BaseClothOption> options = List.of(
        // ---- body parts (shared C/B/A trio) ----
        new BaseClothOption(BIT_BODY_BOTTOM, "C", BODY_COLORS),
        new BaseClothOption(BIT_BODY_MIDDLE, "B", BODY_COLORS),
        new BaseClothOption(BIT_BODY_TOP,    "A", BODY_COLORS),

        // ---- one clip per slot, multiple colors each ----
        new BaseClothOption(BIT_HAIR,  "84",       new int[] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 }),
        new BaseClothOption(BIT_SHIRT, "yby7z2ub", new int[] { 9, 7, 6, 2 }),
        new BaseClothOption(BIT_PANTS, "jv55e4xn", new int[] { 7, 3, 5, 4 }),
        new BaseClothOption(BIT_SHOES, "abv74yn4", new int[] { 7, 5, 6, 9, 1, 2, 4 })
    );

    private final Map<String, List<BaseClothOption>> byGender = Map.of(
        Gender.MALE,   options,
        Gender.FEMALE, options
    );

    public List<BaseClothOption> optionsFor(String gender) {
        List<BaseClothOption> list = byGender.get(gender);
        return list == null ? List.of() : list;
    }
}
