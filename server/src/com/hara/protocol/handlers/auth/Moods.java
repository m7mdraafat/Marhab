package com.hara.protocol.handlers.auth;

import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;

/**
 * Minimal mood catalog returned in the {@code config} reply. The client
 * stores this list on {@code buddyModel.moods}; index is the on-wire mood
 * id stored in the {@code mood} UserVariable. Order must stay stable —
 * adding new moods at the end is safe; reordering is not.
 *
 * <p>Mirrors the labels in {@code BuddyMoods.as}.
 */
final class Moods {

    private static final String[] LABELS = {
        "Cheerful", "Peaceful", "Crazy", "Run Down", "Unhappy",
        "Nervous", "Broken Heart", "Pessimistic", "Pensive", "Energetic",
        "Romantical", "Sensitive", "Excited", "Curious", "Depressed",
        "Unstable", "Worried", "Thoughtful", "Mysterious", "Mixed",
        "Optimistic", "Confused", "Sucks", "Resents", "Desperate",
        "Regret", "Alone", "Questionable", "Lethargic", "Approachable",
        "Stressful"
    };

    private Moods() {}

    static ISFSArray array() {
        ISFSArray arr = new SFSArray();
        for (int i = 0; i < LABELS.length; i++) {
            ISFSObject o = new SFSObject();
            o.putInt("id", i);
            o.putUtfString("label", LABELS[i]);
            arr.addSFSObject(o);
        }
        return arr;
    }
}
