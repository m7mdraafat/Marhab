package com.hara.protocol.handlers.auth;

import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;
import com.smartfoxserver.v2.extensions.BaseClientRequestHandler;

/**
 * Handles the client's "config" extension command.
 *
 * Request format observed in the catch-all log:
 *   cmd  = "config"
 *   params = { "data": {...}, "sn": "config", "rid": <int>, "ts": <int> }
 *
 * Response must echo the same sn + rid so the client can match its pending
 * promise / callback. Fresh ts is fine. The `data` field carries the actual
 * bootstrap object the game reads.
 */
public class ConfigHandler extends BaseClientRequestHandler {

    @Override
    public void handleClientRequest(User user, ISFSObject params) {
        long rid = params != null && params.containsKey("rid") ? params.getLong("rid") : 0L;
        trace("ConfigHandler: rid=" + rid + " user=" + user.getName());

        // The client's ServiceModel does `callback(params.toObject())` -- the response
        // SFSObject we pass is unwrapped flat into the callback's argument. So we
        // build the config fields directly at the top level (no sn/rid envelope).
        ISFSObject response = buildConfigData();
        send("config", response, user);
        trace("  -> sent config response (rid=" + rid + ")");
    }

    /**
     * Flat object the client's ConfigCommand.responseFunction reads:
     *   moods, chatBaloons (sic), itemFile, versionFile, langFile,
     *   fileServer (array, index 0 used), webServer, language,
     *   farmCleaningCost, farmMaxPlantedItemSize,
     *   order { avatarOrderLifeTime, orderLifeTime, prepareLifeTime },
     *   roomTheme (optional), masterRoles.
     */
    private ISFSObject buildConfigData() {
        ISFSObject d = new SFSObject();

        // Mirrors values captured from live Marhab (server/sfs-passthrough.py
        // against marhab-sfs.newmarhab.net). The point is to make the inner
        // game fetch its assets from the still-live xo.newmarhab.net CDN
        // via our launcher's MyGameAssetProxy, so we get past the post-init
        // wall without authoring our own panel/room SWFs.
        ISFSArray fileServers = new SFSArray();
        fileServers.addUtfString("xo.newmarhab.net");
        d.putSFSArray("fileServer", fileServers);

        d.putUtfString("webServer",      "play.ragegames.net/ar");
        d.putUtfString("language",       "ar");
        d.putUtfString("langFile",       "locale/ar_AR.702");
        d.putUtfString("itemFile",       "data/ifile.2013");
        d.putUtfString("versionFile",    "data/vf.19910");

        d.putInt("rid", 0);
        d.putInt("version",                92);
        d.putInt("diamondExchangeRate",    30);
        d.putInt("farmCleaningCost",       10);
        d.putInt("farmMaxPlantedItemSize", 12);

        d.putSFSArray("moods",       buildMoods());
        d.putSFSArray("chatBaloons", buildChatBaloons());
        d.putSFSArray("masterRoles", buildMasterRoles());
        d.putSFSArray("roomTheme",   buildRoomTheme());
        d.putSFSObject("order",      buildOrder());

        return d;
    }

    // ---- helpers ----------------------------------------------------------

    private ISFSObject mood(int id, String label) {
        ISFSObject m = new SFSObject();
        m.putInt("id", id);
        m.putUtfString("label", label);
        return m;
    }

    private ISFSArray buildMoods() {
        ISFSArray a = new SFSArray();
        String[] labels = {
            "Cheerful","Peaceful","Crazy","Run Down","Unhappy","Nervous",
            "Broken Heart","Pessimistic","Pensive","Energetic","Romantical",
            "Sensitive","Excited","Curious","Depressed","Unstable","Worried",
            "Thoughtful","Mysterious","Mixed","Optimistic","Confused","Sucks",
            "Resents","Desperate","Regret","Alone","Questionable","Lethargic",
            "Approachable","Stressful"
        };
        for (int i = 0; i < labels.length; i++) a.addSFSObject(mood(i, labels[i]));
        return a;
    }

    private ISFSObject role(String name, int index) {
        ISFSObject r = new SFSObject();
        r.putUtfString("name", name);
        r.putInt("index", index);
        return r;
    }

    private ISFSArray buildMasterRoles() {
        ISFSArray a = new SFSArray();
        Object[][] rows = {
            {"TRANSFER",2}, {"BARTER",3}, {"VIP",4}, {"VIP_GOLD",5},
            {"WHISPER",6}, {"VIP_DIAMOND",7}, {"VIP_SILVER",8},
            {"AGE_18PLUS",9}, {"AGE_13MINUS",10}, {"VERIFIED_EMAIL",11},
            {"VERIFIED_PHONE",12}, {"HOLIDAY_VISA_TURKEY",13}, {"DIAMOND_CLUB",14},
            {"HOLIDAY_VISA_ABUDABI",15}, {"CARD_SECURITY",16},
            {"HOLIDAY_VISA_SPAIN",17}, {"CARD_JOURNALIST",18}, {"CARD_DIRECTOR",19},
            {"MODERATOR",20}, {"CARD_PHOTOGRAPHER",21}, {"EDITOR_SECURITY",22},
            {"CARD_PAINTER",23}, {"PARTY",24}, {"SPACE_COSTUME",25}, {"KEY",26},
            {"CARD_ACTOR",27}, {"CARD_GUARD",28}, {"CARD_GUIDE",29}, {"PLATO",30},
            {"FORUM",31}, {"CARD_SANALIKAX",32}, {"CafeSmiley",33}, {"KIDO",34},
            {"AIRPASS",35}, {"RUNWIN",36}, {"SNOWBALL",37},
            {"HOLIDAY_VISA_JAPON",38}, {"HOLIDAY_VISA_TR_JPN",39}, {"VISITOR",40},
            {"SECURITY",41}, {"SWIM",42}, {"SKATE",43}, {"CARD_MUSIC",44},
            {"BONUS_X2",45}, {"SHORTCUT",46}, {"SHIP_LICENSE",47},
            {"CARD_CAPITAN",48}, {"EVENT",49}, {"NPC",50}, {"STAGE",51},
            {"NOT_VISITOR",52}
        };
        for (Object[] r : rows) a.addSFSObject(role((String) r[0], (Integer) r[1]));
        return a;
    }

    private ISFSObject balloon(int id, String name, String requirementsB64) {
        ISFSObject b = new SFSObject();
        b.putInt("id", id);
        b.putUtfString("name", name);
        b.putUtfString("requirements", requirementsB64);
        return b;
    }

    private ISFSArray buildChatBaloons() {
        ISFSArray a = new SFSArray();
        a.addSFSObject(balloon(1,  "Default",     "AA=="));
        a.addSFSObject(balloon(2,  "Silver",      "gA=="));
        a.addSFSObject(balloon(3,  "Yellow",      "EA=="));
        a.addSFSObject(balloon(4,  "Grey",        "QA=="));
        a.addSFSObject(balloon(23, "Black",       "QA=="));
        a.addSFSObject(balloon(24, "Red",         "EA=="));
        a.addSFSObject(balloon(25, "Pink",        "EA=="));
        a.addSFSObject(balloon(26, "DiamondClub", "ACA="));
        a.addSFSObject(balloon(30, "SanalikaX",   "AAAAgA=="));
        return a;
    }

    private ISFSArray buildRoomTheme() {
        ISFSArray a = new SFSArray();
        a.addUtfString("fest");
        a.addUtfString("ramadan");
        return a;
    }

    private ISFSObject buildOrder() {
        ISFSObject o = new SFSObject();
        o.putInt("maxOrder",            10);
        o.putInt("orderLifeTime",       240);
        o.putInt("avatarOrderLifeTime", 14400);
        o.putInt("prepareLifeTime",     30);
        o.putInt("customerGainMin",     10);
        o.putInt("customerGainMax",     100);
        return o;
    }
}
