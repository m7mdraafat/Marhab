package com.hara.protocol.handlers.boot;

import java.util.Optional;

import com.hara.domain.model.Account;
import com.hara.domain.model.Avatar;
import com.hara.domain.model.Place;
import com.hara.protocol.framework.HandlerBase;
import com.hara.protocol.presenter.InitResponsePresenter;
import com.hara.service.auth.AccountService;
import com.hara.service.auth.UserSession;
import com.hara.service.avatar.AvatarService;
import com.hara.service.catalog.PlaceCatalog;
import com.hara.service.room.RoomService;
import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.exceptions.SFSException;

/**
 * The {@code init} handler — the second request the splash sends and the
 * branch point of the entire first-time flow (per {@code docs/11 §11.2}):
 *
 * <ol>
 *   <li><strong>No avatar yet:</strong> delegate to
 *       {@link InitResponsePresenter#needsBaseCloth(Account)}.</li>
 *   <li><strong>Returning player:</strong> stamp + join the starter room,
 *       then delegate to {@link InitResponsePresenter#ready(Account, Avatar, Place)}.</li>
 * </ol>
 *
 * <p>This handler is intentionally thin: branching + side-effects only.
 * Wire-shape composition lives in {@link InitResponsePresenter}; account
 * lookup/fallback lives in {@link AccountService}; default settings and
 * codecs each have their own classes under {@code protocol.presenter}.
 */
public final class InitHandler extends HandlerBase {

    /** Initial spawn door for the local dev build. street01 d5 = beach-side exit. */
    private static final String STARTER_DOOR_KEY = "d5";

    private final AccountService accounts;
    private final AvatarService avatars;
    private final PlaceCatalog places;
    private final RoomService rooms;

    public InitHandler(AccountService accounts, AvatarService avatars,
                       PlaceCatalog places, RoomService rooms) {
        this.accounts = accounts;
        this.avatars  = avatars;
        this.places   = places;
        this.rooms    = rooms;
    }

    @Override
    protected String command() { return "init"; }

    @Override
    protected ISFSObject handle(User user, ISFSObject params) throws SFSException {
        long accountId = accounts.resolveOrMintForSession(user);
        Account account = accounts.requireById(accountId);
        Optional<Avatar> maybe = avatars.latestForAccount(accountId);

        if (maybe.isEmpty()) {
            return InitResponsePresenter.needsBaseCloth(account);
        }

        Avatar avatar = maybe.get();
        UserSession.setAvatarId(user, avatar.id());

        // Stamp room state + user vars and join the SFS room BEFORE the
        // reply lands, so the client's auto-join handler fires immediately
        // after Sanalika.process() runs. Spawn at the requested starter door
        // so the position matches the doorKey in the init reply.
        Place starter = places.starter();
        rooms.joinByKey(user, starter.key(), avatar, STARTER_DOOR_KEY);

        return InitResponsePresenter.ready(account, avatar, starter, STARTER_DOOR_KEY);
    }
}
