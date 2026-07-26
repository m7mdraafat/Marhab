package com.hara.protocol.presenter;

import com.hara.domain.model.Wallet;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;

/**
 * Wire-shape codec for {@link Wallet}. The {@code wallet} field in the
 * init reply / {@code updateWallet} push is an Array of
 * {@code {currency, balance}} pairs, per
 * {@code AvatarModel.updateWallet(param1:Array)} which iterates and
 * dispatches per-currency {@code BalanceEvent.BALANCE_UPDATE}s. Sending an
 * object instead throws a Type Coercion error client-side.
 */
public final class WalletCodec {

    private WalletCodec() {}

    public static ISFSArray encode(Wallet wallet) {
        ISFSArray out = new SFSArray();
        out.addSFSObject(entry("SANIL",     wallet.sanil()));
        out.addSFSObject(entry("DIAMOND",   wallet.diamond()));
        out.addSFSObject(entry("PEPSICOIN", wallet.pepsicoin()));
        return out;
    }

    private static SFSObject entry(String currency, long balance) {
        SFSObject row = new SFSObject();
        row.putUtfString("currency", currency);
        // Client reads balance as String/Number indistinctly — send as UTF
        // string to match the live Marhab wire dump.
        row.putUtfString("balance", Long.toString(balance));
        return row;
    }
}
