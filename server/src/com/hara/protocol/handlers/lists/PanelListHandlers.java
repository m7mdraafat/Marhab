package com.hara.protocol.handlers.lists;

import com.hara.protocol.framework.HandlerBase;
import com.hara.protocol.framework.ResponseBuilder;
import com.hara.protocol.wire.ServerEnvelope;
import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;

/**
 * Container for the panel-list stub handlers. Each returns the wire shape
 * the live Marhab server uses (verified via {@code docs/protocol-sniffed.md})
 * with an empty payload. They unblock the client's panel callbacks so the
 * UI shows "you have nothing yet" instead of an infinite spinner.
 *
 * <p>When real persistence lands, only the inner {@code handle()} body
 * needs to change — the wire envelopes stay identical.
 */
public final class PanelListHandlers {

    private PanelListHandlers() {}

    // --------------------------------------------------------------------
    // Item-style lists: {type, items[], rid, nextRequest, ts}
    // --------------------------------------------------------------------
    public static final class CardListHandler extends HandlerBase {
        @Override protected String command() { return "cardlist"; }
        @Override protected ISFSObject handle(User user, ISFSObject params) {
            return ServerEnvelope.stamp(
                new ResponseBuilder()
                    .putStr("type", "CARD")
                    .putEmptyArr("items"))
                .build();
        }
    }

    // --------------------------------------------------------------------
    // Hand items: paginated, {items:{list[],page}, totalPages, pageSelected, rid, ts, nextRequest}
    // --------------------------------------------------------------------
    public static final class HandItemListHandler extends HandlerBase {
        @Override protected String command() { return "handitemlist"; }
        @Override protected ISFSObject handle(User user, ISFSObject params) {
            int page = params.containsKey("page") ? params.getInt("page") : 1;
            ISFSObject items = new SFSObject();
            items.putSFSArray("list", new SFSArray());
            items.putInt("page", page);
            return ServerEnvelope.stamp(
                new ResponseBuilder()
                    .putObj("items",        items)
                    .putInt("totalPages",   0)
                    .putInt("pageSelected", page))
                .build();
        }
    }

    // --------------------------------------------------------------------
    // Buddy list: {buddies[], requests[], rid, nextRequest}
    // --------------------------------------------------------------------
    public static final class BuddyListHandler extends HandlerBase {
        @Override protected String command() { return "buddylist"; }
        @Override protected ISFSObject handle(User user, ISFSObject params) {
            return ServerEnvelope.stamp(
                new ResponseBuilder()
                    .putEmptyArr("buddies")
                    .putEmptyArr("requests"))
                .build();
        }
    }

    // --------------------------------------------------------------------
    // Ban list: {bans[], rid, nextRequest, ts}
    // --------------------------------------------------------------------
    public static final class BanListHandler extends HandlerBase {
        @Override protected String command() { return "banlist"; }
        @Override protected ISFSObject handle(User user, ISFSObject params) {
            return ServerEnvelope.stamp(
                new ResponseBuilder().putEmptyArr("bans"))
                .build();
        }
    }

    // --------------------------------------------------------------------
    // News: {news[], rid, ts} -- no nextRequest in production
    // --------------------------------------------------------------------
    public static final class NewsListHandler extends HandlerBase {
        @Override protected String command() { return "newslist"; }
        @Override protected ISFSObject handle(User user, ISFSObject params) {
            return new ResponseBuilder()
                .putInt ("rid", ServerEnvelope.nextRid())
                .putLong("ts",  ServerEnvelope.nowSec())
                .putEmptyArr("news")
                .build();
        }
    }

    // --------------------------------------------------------------------
    // Flat list: {yourHouses[], buddyHouses[], others[], youLiked[], rid, nextRequest, ts}
    // --------------------------------------------------------------------
    public static final class FlatListHandler extends HandlerBase {
        @Override protected String command() { return "flatlist"; }
        @Override protected ISFSObject handle(User user, ISFSObject params) {
            return ServerEnvelope.stamp(
                new ResponseBuilder()
                    .putEmptyArr("yourHouses")
                    .putEmptyArr("buddyHouses")
                    .putEmptyArr("others")
                    .putEmptyArr("youLiked"))
                .build();
        }
    }

    // --------------------------------------------------------------------
    // Active business orders: {orders[], rid, nextRequest, ts}
    // --------------------------------------------------------------------
    public static final class OrderListHandler extends HandlerBase {
        @Override protected String command() { return "orderlist"; }
        @Override protected ISFSObject handle(User user, ISFSObject params) {
            return ServerEnvelope.stamp(
                new ResponseBuilder().putEmptyArr("orders"))
                .build();
        }
    }

    // --------------------------------------------------------------------
    // Private chat history: {groupList[], rid, nextRequest, ts}
    // --------------------------------------------------------------------
    public static final class PrivateChatListHandler extends HandlerBase {
        @Override protected String command() { return "privatechatlist"; }
        @Override protected ISFSObject handle(User user, ISFSObject params) {
            return ServerEnvelope.stamp(
                new ResponseBuilder().putEmptyArr("groupList"))
                .build();
        }
    }

    // --------------------------------------------------------------------
    // Quest list: {quests[], rid, ts, nextRequest}
    // --------------------------------------------------------------------
    public static final class QuestListHandler extends HandlerBase {
        @Override protected String command() { return "questlist"; }
        @Override protected ISFSObject handle(User user, ISFSObject params) {
            return ServerEnvelope.stamp(
                new ResponseBuilder().putEmptyArr("quests"))
                .build();
        }
    }

    // --------------------------------------------------------------------
    // Shop product list: {shopProductList:{}, shoppingBagInfos[], rid, nextRequest, ts}
    // Live server returns shopProductList keyed by category ("DOOR", "HAT", etc.).
    // Empty {} keeps the shop UI alive but with no purchasable items.
    // --------------------------------------------------------------------
    public static final class ShopProductListHandler extends HandlerBase {
        @Override protected String command() { return "shopproductlist"; }
        @Override protected ISFSObject handle(User user, ISFSObject params) {
            return ServerEnvelope.stamp(
                new ResponseBuilder()
                    .putEmptyObj("shopProductList")
                    .putEmptyArr("shoppingBagInfos"))
                .build();
        }
    }

    // --------------------------------------------------------------------
    // VIP / hard-currency sales: {products[], purchaseToken:"", defaultCurrency:"USD", rid, nextRequest}
    // --------------------------------------------------------------------
    public static final class SaleProductListHandler extends HandlerBase {
        @Override protected String command() { return "saleproductlist"; }
        @Override protected ISFSObject handle(User user, ISFSObject params) {
            ISFSArray products = new SFSArray();
            return new ResponseBuilder()
                .putInt ("rid",             ServerEnvelope.nextRid())
                .putInt ("nextRequest",     ServerEnvelope.NEXT_DEFAULT)
                .putStr ("purchaseToken",   "")
                .putStr ("defaultCurrency", "USD")
                .putArr ("products",        products)
                .build();
        }
    }
}
