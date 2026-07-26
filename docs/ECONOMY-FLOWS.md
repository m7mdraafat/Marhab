# Old Client Economy Flows

This note records verified client behavior from the decompiled AIR/SWF client. Do not use it as product design by itself; use it as the compatibility contract for our server and website.

## What Is Verified

The old client already has in-game economy surfaces for Sanil, Diamond, VIP cards, regular shop products, room shops, sale products, and sale items.

The main purchase controller is `client/src/com/oyunstudyosu/controller/PurchaseController.as`.

It listens for:

```text
PurchaseEvent.PURCHASE
PurchaseEvent.FLAT_PURCHASE
```

Before sending a purchase request, it checks current avatar balances:

```text
SANIL
DIAMOND
```

If balance is enough, it sends SmartFox extension requests:

```text
purchase
flatpurchase
```

Request payload shape:

```json
{
  "shopID": 123,
  "objectID": 0,
  "items": [
    {
      "shopProductID": 456,
      "quantity": 1,
      "color": "optional"
    }
  ]
}
```

The response can grant these item groups:

```text
CLOTH
OBJECT
HAND
CARD
FLAT
```

For `CARD`, the client shows:

```text
Vip card purchase completed.
```

## VIP Card Flow

VIP card UI is opened inside the game through `VipCardPanelProperty`:

```text
VipCardPanelProperty -> PanelVO("VipCardPanel") -> PanelModel.openPanel
```

The panel asset is in the version manifest:

```text
VipCardPanel=panels/1449237199236-29
```

Local mirrored asset:

```text
assets/cdn-mirror/global/dynamic/panels/1449237199236-29.swf
```

So the old client supports an in-game VIP card panel. The exact buttons inside that panel live in the dynamic panel SWF, but the shell and backend purchase path are verified.

## Shop And Pack-Like Flow

The old client opens several in-game shop panels from room doors, bots, objects, or HUD events:

```text
ShopPanelProperty      -> ShopPanel
RoomShopPanelProperty  -> RoomShopPanel
SaleProductPanel       -> SaleProductPanel
SaleItemPanelProperty  -> SaleItemPanel
PaymentPanelProperty   -> PaymentPanel
```

Verified panel assets:

```text
ShopPanel=panels/PNSH65.11
RoomShopPanel=panels/PNLRM9
SaleItemPanel=panels/1449237199236-25.1
SaleProductPanel=panels/SPP.5
PaymentPanel=panels/934354YnI.5
```

Local mirrored assets:

```text
assets/cdn-mirror/global/dynamic/panels/PNSH65.11.swf
assets/cdn-mirror/global/dynamic/panels/PNLRM9.swf
assets/cdn-mirror/global/dynamic/panels/1449237199236-25.1.swf
assets/cdn-mirror/global/dynamic/panels/SPP.5.swf
assets/cdn-mirror/global/dynamic/panels/934354YnI.5.swf
```

Inventory items have subtype and type flags. The client has explicit support for:

```text
ProductSubType.PACKAGE
ItemType.TYPE_PACKAGE
ItemType.TYPE_VIP
```

Package items show `dragToOpen` in item info, which means packs are not only a website concept in the old client. The old client can represent packages as inventory items.

## Currency Top-Up / Payment Panel Flow

When Sanil or Diamond balance is insufficient, `PurchaseController` does not complete the purchase. It opens a top-up surface:

```text
ExternalInterface.call("Sanalika.openSanilPurchasePanel")
ExternalInterface.call("Sanalika.openDiamondPurchasePanel")
```

For desktop/AIR fallback, it opens:

```text
gameModel.webServer + "/payment"
```

HUD balance buttons also open these panels:

```text
SanilBalanceClip   -> HudEvent.OPEN_SANIL_PURCHASE_PANEL
DiamondBalanceClip -> HudEvent.OPEN_DIAMOND_PURCHASE_PANEL
HudModel           -> PaymentPanel or SaleProductPanel
```

For our no-real-payment version, this should become an internal economy/top-up or rewards page, not external checkout.

## Wallet Updates

The client listens for an extension event:

```text
updateWallet
```

Expected payload shape:

```json
{
  "reason": "someLocalizationKey",
  "wallet": [
    { "currency": "SANIL", "balance": "1000" },
    { "currency": "DIAMOND", "balance": "50" }
  ]
}
```

`AvatarModel.updateWallet` supports:

```text
SANIL
DIAMOND
PEPSICOIN
```

The client updates HUD balances via `BalanceEvent.BALANCE_UPDATE`.

## Diamond Exchange And Transfers

There is an in-game Diamond-to-Sanil exchange property:

```text
ExchangeProperty -> requestData("exchangediamond", { "diamondQuantity": n })
```

There is also buddy Diamond transfer support:

```text
diamondtransferrequest
diamondtransferresponse
respondDiamondTransferRequest
diamondTransferResult
```

These are server-side economy contracts, not website-only features.

## VIP Permissions And Status

The client has VIP-related permissions and state fields:

```text
AvatarPermission.VIP
AvatarPermission.VIP_GOLD
AvatarPermission.VIP_DIAMOND
AvatarPermission.VIP_SILVER
AvatarPermission.DIAMOND_CLUB
AvatarPermission.CARD_SANALIKAX
AvatarModel.isDiamondClub
AvatarModel.vipType
AvatarModel.hasCafeCard
```

Room cell access can depend on permissions, for example Diamond Club cells check `AvatarPermission.DIAMOND_CLUB`.

## Website Boundary From The Old Client

The old client uses `gameModel.webServer` for browser/web handoffs:

```text
/payment
/download
/logout
```

It also calls JavaScript bridge methods when running embedded in a browser wrapper:

```text
Sanalika.getPRM
Sanalika.openSanilPurchasePanel
Sanalika.openDiamondPurchasePanel
Sanalika.openProductPurchasePanel
```

This means the old game expected a website shell, but many economy actions still happen in-game and go through SmartFox extension requests.

## Compatibility Recommendation

Based on verified client behavior:

1. Keep VIP-card purchase/use available in-game.
2. Keep item/shop/card purchases backed by SmartFox `purchase` and `flatpurchase` handlers.
3. Use the website for account, login, download, profile, rewards, pack browsing, and optional pack management.
4. If packs are sold or granted on the website, they should still appear as game inventory items when the player logs in.
5. Do not design the first economy as website-only. The old client already contains in-game purchase, wallet update, package, and VIP-card flows.

## Backend Contracts We Need First

Minimum server handlers for this area:

```text
purchase
flatpurchase
updateWallet
exchangediamond
diamondtransferrequest
diamondtransferresponse
avatarsalescollect
```

Minimum server data concepts:

```text
wallets
wallet_transactions
shops
shop_products
player_inventory
vip_cards
vip_subscriptions
player_permissions
```

Every currency mutation should be server-authoritative and recorded as a transaction. The client balance check is only UI convenience; the server must re-check balance and ownership.