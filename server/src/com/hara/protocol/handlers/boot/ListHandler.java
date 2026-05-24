package com.hara.protocol.handlers.boot;

import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;
import com.smartfoxserver.v2.extensions.BaseClientRequestHandler;

/**
 * Returns well-formed empty-list responses for the client's "give me my X list"
 * requests. Each command expects a specific top-level field in the response so
 * a generic {ok:true} stub would make the client NPE the moment it eventually
 * fires the request. Shapes verified against decompiled source in
 * rebuild/inventory/snl_780_src.
 *
 * Routing is by request command name via getRequestId().
 */
public class ListHandler extends BaseClientRequestHandler {

    @Override
    public void handleClientRequest(User user, ISFSObject params) {
        // The client envelope carries the command name in "sn".
        String cmd = (params != null && params.containsKey("sn"))
                ? params.getUtfString("sn") : "?";
        ISFSObject response = buildResponseFor(cmd);
        send(cmd, response, user);
        trace("ListHandler: empty-list response for " + cmd + " user=" + user.getName());
    }

    private ISFSObject buildResponseFor(String cmd) {
        ISFSObject r = new SFSObject();
        switch (cmd) {
            case "buddylist":
                r.putSFSArray("buddies", new SFSArray());
                r.putSFSArray("requests", new SFSArray());
                break;
            case "privatechatlist":
                r.putSFSArray("groupList", new SFSArray());
                break;
            case "orderlist":
                r.putSFSArray("orders", new SFSArray());
                break;
            case "questlist":
                // questModel.questlist = param1; the whole response IS the list.
                r.putSFSArray("quests", new SFSArray());
                break;
            case "baseclothes":
                // AvatarCreatePanel.onListResponse stores response as _data,
                // then onGenderChange reads _data.m / _data.f. Each entry is
                // {placeBit:"...", clip:"...", colors:[...]} grouped by
                // placeBit into rows. placeBit -> UI-row mapping
                // (from AvatarCreatePanel.iterateMedia call sites):
                //   "1"      body
                //   "131072" hair (sac)
                //   "512"    tshirt
                //   "64"     pants
                //   "16"     shoes
                //
                // Items below are real clips harvested from Marhab's
                // ifile.2013 then HEAD-probed against the live CDN
                // (rebuild/probe-clothes.ps1). Even though ifile registers
                // both m_ and f_ keys for every entry, the CDN often only
                // ships one gender, and only certain (clip,color) combos
                // resolve. Tables below contain ONLY combos that returned
                // HTTP 200. URL pattern:
                //   http://xo.newmarhab.net/global/static/items/clothes/
                //     <gender>_<clip>_<color>[.<version>].swf
                // Resolved by MyGameAssetProxy -> write-through disk cache
                // -> first scroll seeds, subsequent runs are offline.
                r.putSFSArray("m", buildClothes(CLOTHES_M));
                r.putSFSArray("f", buildClothes(CLOTHES_F));
                break;
            default:
                // Should not happen if MyGameExtension only routes the four
                // commands above to us, but keep a safe fallback.
                r.putBool("ok", true);
        }
        return r;
    }

    /**
     * Real cloth entries harvested from Marhab's ifile.2013 and HEAD-verified
     * live on the CDN. Format per row: {clipName, placeBit, color1, ...}.
     * placeBits: 1+2+4 = body composite (3 skin layers C/B/A that share a
     * color palette; AvatarCreatePanel.iterateMedia("1",...) requires ALL
     * THREE to be present or it throws and the panel renders nothing).
     * 131072=hair, 512=tshirt, 64=pants, 16=shoes.
     * To extend / refresh: run rebuild/probe-clothes.ps1 and copy verified
     * rows here.
     */
    private static final Object[][] CLOTHES_M = {
        // body composite (must keep colors aligned across 1/2/4)
        {"C",        "1", 1, 2, 8, 12},
        {"B",        "2", 1, 2, 8, 12},
        {"A",        "4", 1, 2, 8, 12},
        // hair
        {"dg5sDd7n", "131072", 3},
        {"dPnu3XPC", "131072", 12},
        {"92",       "131072", 7, 8, 9},
        // tshirt
        {"w53a7tcY", "512", 3},
        {"m8Oiqo9L", "512", 5},
        {"sw1",      "512", 3, 5, 7},
        {"uhV5G2d6", "512", 3},
        // pants
        {"bjb4xrw8", "64", 3},
        {"ymvDDtH6", "64", 10},
        {"fE3eds12", "64", 7},
        {"pys5hv47", "64", 4, 1, 8, 3},
        {"1427",     "64", 4, 5, 8},
        {"tgdflOAT", "64", 3, 4, 5, 7, 13},
        // shoes
        // NOTE: 'dwxsxbsf' removed -- CDN's m_dwxsxbsf_3.swf actually exports
        // class m_dwxsxbsf_9 and m_dwxsxbsf_9.swf is 404. Class-name mismatch
        // makes SwfRequest.registerClass log EXPORT NOT FOUND and the avatar
        // panel's waitingList never drains -> loading spinner stuck forever.
        // Verified by rebuild/audit-clothes.ps1 (only bad entry of 71).
        {"y55tRREf", "16", 10},
        {"yvygwir1", "16", 9},
    };

    private static final Object[][] CLOTHES_F = {
        // body composite (must keep colors aligned across 1/2/4)
        {"C",        "1", 1, 2, 8, 12},
        {"B",        "2", 1, 2, 8, 12},
        {"A",        "4", 1, 2, 8, 12},
        {"yc",       "1", 1},
        // hair
        {"debm8fsy", "131072", 3},
        {"ep8225up", "131072", 9},
        {"92",       "131072", 7, 8, 1},
        {"b94dmesj", "131072", 1},
        // tshirt
        {"g4BSse3E", "512", 10},
        {"w53a7tcY", "512", 3},
        {"8mzau8mn", "512", 8},
        // pants
        {"fE3eds12", "64", 7},
        // shoes
        {"56utrmk8", "16", 3, 7, 6, 9},
        {"XbcCuV58", "16", 3, 4},
        {"ulrpzhgi", "16", 9},
    };

    private ISFSArray buildClothes(Object[][] table) {
        ISFSArray arr = new SFSArray();
        for (Object[] entry : table) {
            ISFSObject item = new SFSObject();
            item.putUtfString("clip",     (String) entry[0]);
            item.putUtfString("placeBit", (String) entry[1]);
            ISFSArray colors = new SFSArray();
            for (int i = 2; i < entry.length; i++) {
                colors.addInt((Integer) entry[i]);
            }
            item.putSFSArray("colors", colors);
            arr.addSFSObject(item);
        }
        return arr;
    }
}
