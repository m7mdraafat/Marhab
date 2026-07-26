package com.hara.extension;

import java.nio.file.Paths;

import com.hara.events.UserDisconnectEventHandler;
import com.hara.events.UserJoinZoneEventHandler;
import com.hara.events.UserLoginEventHandler;
import com.hara.infra.config.HaraConfig;
import com.hara.infra.id.IdGen;
import com.hara.persistence.AccountRepository;
import com.hara.persistence.AvatarRepository;
import com.hara.persistence.InMemoryAccountRepository;
import com.hara.persistence.InMemoryAvatarRepository;
import com.hara.protocol.handlers.auth.ConfigHandler;
import com.hara.protocol.handlers.avatar.AvatarCreateHandler;
import com.hara.protocol.handlers.avatar.BaseClothListHandler;
import com.hara.protocol.handlers.avatar.BaseClothesHandler;
import com.hara.protocol.handlers.avatar.ChangeClothesHandler;
import com.hara.protocol.handlers.avatar.ChangeSmileyHandler;
import com.hara.protocol.handlers.avatar.ClothListHandler;
import com.hara.protocol.handlers.avatar.SaveBaseClothesHandler;
import com.hara.protocol.handlers.avatar.UseChatBalloonHandler;
import com.hara.protocol.handlers.boot.ChangeLanguageHandler;
import com.hara.protocol.handlers.boot.EmptyListHandler;
import com.hara.protocol.handlers.boot.EmptyOkHandler;
import com.hara.protocol.handlers.boot.GetLanguagesHandler;
import com.hara.protocol.handlers.boot.InitHandler;
import com.hara.protocol.handlers.boot.SetActiveGroupHandler;
import com.hara.protocol.handlers.chat.GroupWhisperHandler;
import com.hara.protocol.handlers.chat.WhisperHandler;
import com.hara.protocol.handlers.lists.PanelListHandlers;
import com.hara.protocol.handlers.room.RoomJoinCompleteHandler;
import com.hara.protocol.handlers.room.TeleportHandler;
import com.hara.protocol.handlers.room.UseDoorHandler;
import com.hara.protocol.handlers.shop.PurchaseHandler;
import com.hara.protocol.handlers.shop.UseHandItemHandler;
import com.hara.protocol.handlers.social.ProfileHandler;
import com.hara.protocol.handlers.social.ProfileLikeHandler;
import com.hara.protocol.handlers.walk.WalkFinalRequestHandler;
import com.hara.protocol.handlers.walk.WalkRequestHandler;
import com.hara.service.auth.AccountService;
import com.hara.service.avatar.AvatarService;
import com.hara.service.avatar.ClothCatalog;
import com.hara.service.catalog.PlaceCatalog;
import com.hara.service.room.RoomService;
import com.hara.service.walk.WalkSessionRegistry;
import com.smartfoxserver.v2.core.SFSEventType;
import com.smartfoxserver.v2.extensions.IClientRequestHandler;
import com.smartfoxserver.v2.extensions.SFSExtension;

/**
 * SmartFoxServer entry point. Wires the dependency graph (in-memory
 * repos → services → handlers) and registers every named extension
 * request plus the lifecycle event handlers. Keep this file
 * REGISTRATION-ONLY — no business logic, no per-request work.
 *
 * <p>Deployment: built into {@code dist/HaraExtension.jar}, deployed
 * by {@code server/restart-sfs.ps1} into
 * {@code <SFS_HOME>/extensions/HaraExtension/HaraExtension.jar} and bound
 * as the main extension of the SFS zone via the zone config XML.
 *
 * <p>Today's scope covers PLAN.md Waves 1-3 + the {@code roomjoincomplete}
 * push from Wave 4 — exactly what the first-time flow in
 * {@code docs/11-first-time-flow.md} needs to land a player in
 * {@code street01} and walk around.
 */
public final class HaraExtension extends SFSExtension {

    private AccountService accountService;
    private AvatarService avatarService;
    private PlaceCatalog places;
    private RoomService roomService;
    private WalkSessionRegistry walkSessions;

    @Override
    public void init() {
        getLogger().info("[hara] init() starting; folder={}", getCurrentFolder());

        // --- 1. infra & config -------------------------------------------------
        HaraConfig config = HaraConfig.from(getConfigProperties(),
            getCurrentFolder() == null ? null : Paths.get(getCurrentFolder()));
        IdGen ids = new IdGen();

        // --- 2. persistence (in-memory today; DB in Phase 9) ------------------
        AccountRepository accountRepo = new InMemoryAccountRepository();
        AvatarRepository  avatarRepo  = new InMemoryAvatarRepository();

        // --- 3. services -------------------------------------------------------
        this.accountService = new AccountService(accountRepo, ids);
        this.avatarService  = new AvatarService(avatarRepo, ids);
        ClothCatalog cloth  = new ClothCatalog();
        this.places         = new PlaceCatalog(config.starterRoom(), config.wwwRoot(), config.versionFilePath());
        this.roomService    = new RoomService(this, places);
        this.walkSessions   = new WalkSessionRegistry();

        // --- 4. SFS lifecycle events ------------------------------------------
        addEventHandler(SFSEventType.USER_LOGIN,      new UserLoginEventHandler(accountService));
        addEventHandler(SFSEventType.USER_JOIN_ZONE,  new UserJoinZoneEventHandler(accountService));
        addEventHandler(SFSEventType.USER_DISCONNECT, new UserDisconnectEventHandler(walkSessions));
        addEventHandler(SFSEventType.USER_LOGOUT,     new UserDisconnectEventHandler(walkSessions));

        // --- 5. request handlers (one class per command) ----------------------
        registerBootHandlers(config);
        registerAvatarHandlers(cloth);
        registerRoomHandlers();
        registerWalkHandlers();
        registerChatHandlers();
        registerPanelLists();
        registerSocialHandlers();
        registerShopHandlers();
        registerListStubs();
        registerOkStubs();

        getLogger().info("[hara] init() ok — starter room='{}' cdn='{}'",
            config.starterRoom(), config.cdnHost());
    }

    @Override
    public void destroy() {
        getLogger().info("[hara] destroy()");
        super.destroy();
    }

    // -----------------------------------------------------------------------
    // command registration — grouped by wave for readability
    // -----------------------------------------------------------------------

    private void registerBootHandlers(HaraConfig config) {
        addHandler("config", new ConfigHandler(config));
        addHandler("init",   new InitHandler(accountService, avatarService, places, roomService));
        addHandler("ping",   new EmptyOkHandler("ping"));
        // Fired by GuestPanel when the user clicks "Continue as Guest" — the
        // panel handles state locally (sets avatarModel.guest=true and dispatches
        // INITIALIZE); the server-side notification is purely informational.
        addHandler("ditchguestpanel", new EmptyOkHandler("ditchguestpanel"));
        // Language picker + setactivegroup are part of the early boot handshake
        // (settings panel + group unread tracking).
        addHandler("getlanguages",    new GetLanguagesHandler());
        addHandler("changelanguage",  new ChangeLanguageHandler());
        addHandler("setactivegroup",  new SetActiveGroupHandler());
    }

    private void registerAvatarHandlers(ClothCatalog cloth) {
        addHandler("baseclothes",     new BaseClothesHandler(cloth));
        addHandler("savebaseclothes", new SaveBaseClothesHandler(accountService, avatarService));
        addHandler("avatarcreate",    new AvatarCreateHandler(accountService, avatarService));
        addHandler("clothlist",       new ClothListHandler(avatarService));
        addHandler("baseclothlist",   new BaseClothListHandler(avatarService));
        addHandler("changeclothes",   new ChangeClothesHandler(this, avatarService));
        addHandler("changesmiley",    new ChangeSmileyHandler(this));
        addHandler("usechatballoon",  new UseChatBalloonHandler(this));
        addHandler("changesettings",  new EmptyOkHandler("changesettings"));
    }

    private void registerRoomHandlers() {
        addHandler("teleport",         new TeleportHandler(places, roomService, avatarService));
        addHandler("usedoor",          new UseDoorHandler(places, roomService, avatarService));
        addHandler("roomjoincomplete", new RoomJoinCompleteHandler(this));
    }

    private void registerWalkHandlers() {
        addHandler("walkrequest",      new WalkRequestHandler(places, walkSessions));
        addHandler("walkfinalrequest", new WalkFinalRequestHandler(this, walkSessions, places, roomService, avatarService));
    }

    private void registerChatHandlers() {
        addHandler("whisper",      new WhisperHandler(this));
        addHandler("groupwhisper", new GroupWhisperHandler(this));
    }

    /**
     * Typed panel-list handlers. Each returns the live-Marhab wire shape
     * (verified via docs/protocol-sniffed.md) with an empty payload so the
     * client's panels unblock and show "you have nothing" instead of
     * spinning indefinitely.
     */
    private void registerPanelLists() {
        addHandler("cardlist",        new PanelListHandlers.CardListHandler());
        addHandler("handitemlist",    new PanelListHandlers.HandItemListHandler());
        addHandler("buddylist",       new PanelListHandlers.BuddyListHandler());
        addHandler("banlist",         new PanelListHandlers.BanListHandler());
        addHandler("newslist",        new PanelListHandlers.NewsListHandler());
        addHandler("flatlist",        new PanelListHandlers.FlatListHandler());
        addHandler("orderlist",       new PanelListHandlers.OrderListHandler());
        addHandler("privatechatlist", new PanelListHandlers.PrivateChatListHandler());
        addHandler("questlist",       new PanelListHandlers.QuestListHandler());
        addHandler("shopproductlist", new PanelListHandlers.ShopProductListHandler());
        addHandler("saleproductlist", new PanelListHandlers.SaleProductListHandler());
    }

    /** Social interactions: profile card, like/dislike. */
    private void registerSocialHandlers() {
        addHandler("profile",     new ProfileHandler());
        addHandler("profilelike", new ProfileLikeHandler());
    }

    /** Shop / hand-item actions (placeholder responses until inventory persists). */
    private void registerShopHandlers() {
        addHandler("purchase",    new PurchaseHandler());
        addHandler("usehanditem", new UseHandItemHandler());
    }

    /** Empty {@code items:[]} for the remaining lists the client polls eagerly. */
    private void registerListStubs() {
        String[] commands = {
            "achievementlist", "notificationlist",
            "specialitemlist", "stickerlist", "universelist", "smileylist",
            "listexpirables"
        };
        for (String c : commands) addHandler(c, new EmptyListHandler(c));
    }

    /** Generic {@code {}} for misc UI fire-and-forgets so callbacks resolve. */
    private void registerOkStubs() {
        String[] commands = {
            "usesticker", "changemood", "changestatusmessage",
            "changeuniverse", "livemessage", "debugcommand", "tutorialupdated",
            "globalchat.leave", "globalchat.join"
        };
        for (String c : commands) addHandler(c, new EmptyOkHandler(c));
    }

    /** Tiny adapter so the registration block above reads cleanly. */
    private void addHandler(String name, IClientRequestHandler handler) {
        addRequestHandler(name, handler);
    }
}
