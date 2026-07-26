# Sniffed Protocol Catalog

Source: `C:\Users\t-malgharib\AppData\Roaming\com.mygame.standalone\Local Store\rebuild.log`
Total log lines: 3,181
Distinct extension commands: 51

## Extension commands

| cmd | out | in | shapes |
|-----|----:|---:|-------:|
| `adminMessage` | 0 | 3 | 2 |
| `avatarLikeUpdated` | 0 | 4 | 1 |
| `banlist` | 1 | 1 | 2 |
| `buddyOnlineStatus` | 0 | 7 | 1 |
| `buddylist` | 1 | 1 | 2 |
| `cardlist` | 6 | 6 | 2 |
| `changeclothes` | 1 | 1 | 2 |
| `changelanguage` | 2 | 2 | 2 |
| `clothlist` | 1 | 1 | 2 |
| `config` | 1 | 1 | 2 |
| `displayAd` | 0 | 3 | 1 |
| `ditchguestpanel` | 1 | 0 | 1 |
| `externalTokenComplete` | 0 | 1 | 1 |
| `fishing.joinGame` | 0 | 6 | 1 |
| `fishing.leftGame` | 0 | 509 | 1 |
| `fishing.list` | 0 | 16 | 2 |
| `fishing.start` | 21 | 0 | 1 |
| `fishing.update` | 0 | 78 | 2 |
| `flatlist` | 1 | 1 | 2 |
| `getlanguages` | 1 | 1 | 2 |
| `globalchat.leave` | 2 | 2 | 2 |
| `handitemlist` | 8 | 8 | 2 |
| `init` | 1 | 1 | 2 |
| `initQueue` | 0 | 1 | 1 |
| `mediaevent` | 0 | 132 | 1 |
| `newslist` | 1 | 1 | 2 |
| `orderlist` | 1 | 1 | 2 |
| `ping` | 10 | 10 | 2 |
| `privatechatlist` | 1 | 1 | 2 |
| `profile` | 12 | 12 | 6 |
| `profilelike` | 8 | 8 | 2 |
| `purchase` | 2 | 2 | 3 |
| `questaccept` | 3 | 3 | 2 |
| `questlist` | 1 | 1 | 2 |
| `questlistroom` | 0 | 10 | 2 |
| `queststepcomplete` | 0 | 3 | 1 |
| `restartServer` | 0 | 1 | 1 |
| `roles` | 0 | 27 | 1 |
| `roomjoincomplete` | 27 | 27 | 2 |
| `saleproductlist` | 1 | 1 | 2 |
| `setactivegroup` | 1 | 1 | 2 |
| `shopproductlist` | 11 | 11 | 6 |
| `updateWallet` | 0 | 3 | 1 |
| `usedoor` | 1 | 25 | 2 |
| `usehanditem` | 4 | 4 | 2 |
| `usehousedoor` | 1 | 1 | 2 |
| `walkfinalrequest` | 39 | 39 | 2 |
| `walkrequest` | 79 | 73 | 4 |
| `whisper` | 2 | 4 | 3 |
| `whispernotify` | 0 | 62 | 2 |
| `xoaction` | 4 | 4 | 5 |

## SFS events

| event | count |
|-------|------:|
| `userVarUpd` | 798 |
| `userExitRoom` | 98 |
| `publicMsg` | 60 |
| `userEnterRoom` | 59 |
| `roomJoin` | 43 |
| `login` | 2 |
| `connection` | 1 |

## Command details

### `adminMessage`

**← (server → client push/response)** — 3 call(s)

- shape `{message:str,title:str,ts:int}` ×2
  - sample: `{"message":"Language has been changed to English successfully.\nPlease restart the game to apply changes.","ts":1780073086589,"title":"Language Changed"}`
- shape `{message:str,title:str,ts:int,type:str}` ×1
  - sample: `{"message":"فعالية اليوم :-\r\nhttps://tinyurl.com/yt5krrad","type":"ANNOUNCEMENT","ts":1780072644120,"title":"فريق مرحب"}`

### `avatarLikeUpdated`

**← (server → client push/response)** — 4 call(s)

- shape `{avatarID:str,status:int}` ×4
  - sample: `{"status":-1,"avatarID":"100999117"}`

### `banlist`

**→ (client → server request)** — 1 call(s)

- shape `{}` ×1
  - sample: `{}`

**← (server → client push/response)** — 1 call(s)

- shape `{bans:[],nextRequest:int,rid:int,ts:int}` ×1
  - sample: `{"bans":[],"ts":1780073160,"rid":235,"nextRequest":1000}`

**Typical follow-ups within 5 lines:**
- `banlist` ×2
- `fishing.leftGame` ×2

### `buddyOnlineStatus`

**← (server → client push/response)** — 7 call(s)

- shape `{avatarID:str,avatarName:str,buddyRating:int,gender:str,isOnline:bool,myRating:int}` ×7
  - sample: `{"myRating":1,"avatarID":"100979140","isOnline":false,"gender":"m","avatarName":"°•Bëbõø•°","buddyRating":1}`

### `buddylist`

**→ (client → server request)** — 1 call(s)

- shape `{}` ×1
  - sample: `{}`

**← (server → client push/response)** — 1 call(s)

- shape `{buddies:[{avatarID:str,avatarName:str,buddyRating:int,gender:str,imgPath:str,isOnline:bool,myRating:int,status:str},...],nextRequest:int,requests:[],rid:int}` ×1
  - sample: `{"rid":2,"requests":[],"buddies":[{"myRating":1,"gender":"m","avatarID":"100999149","isOnline":false,"status":"Strangers","imgPath":"1676581720","avatarName":"°•مالكي•°","buddyRating":1},{"myRating":1`

**Typical follow-ups within 5 lines:**
- `buddylist` ×2
- `mediaevent` ×1
- `roomjoincomplete` ×1

### `cardlist`

**→ (client → server request)** — 6 call(s)

- shape `{}` ×6
  - sample: `{}`

**← (server → client push/response)** — 6 call(s)

- shape `{items:[{active:int,base:int,clip:str,color:int,createdAt:str,expire:int,id:int,lifeTime:int,productID:int,quantity:int,roles:str,source:str,subType:str,timeLeft:int,transferrable:bool},...],nextRequest:int,rid:int,ts:int,type:str}` ×6
  - sample: `{"type":"CARD","items":[{"clip":"CARD_DIAMOND","quantity":1,"lifeTime":0,"id":23396,"base":0,"timeLeft":1999576,"transferrable":false,"productID":20003,"active":0,"color":0,"subType":"VIP","source":"P`

**Typical follow-ups within 5 lines:**
- `cardlist` ×12
- `handitemlist` ×6
- `mediaevent` ×3
- `fishing.update` ×2

### `changeclothes`

**→ (client → server request)** — 1 call(s)

- shape `{clothes:[int,...]}` ×1
  - sample: `{"clothes":[311718,215200,215201,215202,544998,545003,316264,545001]}`

**← (server → client push/response)** — 1 call(s)

- shape `{message:str,rid:int,status:str,ts:int}` ×1
  - sample: `{"message":"Clothes changed successfully","ts":1780072981,"rid":126,"status":"success"}`

**Typical follow-ups within 5 lines:**
- `changeclothes` ×1
- `usehanditem` ×1

### `changelanguage`

**→ (client → server request)** — 2 call(s)

- shape `{language:str}` ×2
  - sample: `{"language":"en"}`

**← (server → client push/response)** — 2 call(s)

- shape `{langFile:str,language:str,success:bool}` ×2
  - sample: `{"language":"en","langFile":"locale/en_UK.1","success":true}`

**Typical follow-ups within 5 lines:**
- `changelanguage` ×5
- `adminMessage` ×3

### `clothlist`

**→ (client → server request)** — 1 call(s)

- shape `{}` ×1
  - sample: `{}`

**← (server → client push/response)** — 1 call(s)

- shape `{items:[{active:int,base:int,clip:str,color:int,createdAt:str,expire:int,id:int,lifeTime:int,productID:int,quantity:int,roles:str,source:str,subType:str,timeLeft:int,transferrable:bool},...],nextRequest:int,rid:int,ts:int,type:str}` ×1
  - sample: `{"type":"CLOTH","items":[{"clip":"2b42umx_2","quantity":1,"lifeTime":2592000,"id":311718,"base":0,"timeLeft":1904037,"transferrable":false,"productID":12373,"active":1,"color":2,"subType":"GLASSES","s`

**Typical follow-ups within 5 lines:**
- `clothlist` ×2
- `walkfinalrequest` ×1

### `config`

**→ (client → server request)** — 1 call(s)

- shape `{}` ×1
  - sample: `{}`

**← (server → client push/response)** — 1 call(s)

- shape `{chatBaloons:[{id:int,name:str,requirements:str},...],diamondExchangeRate:int,farmCleaningCost:int,farmMaxPlantedItemSize:int,fileServer:[str],itemFile:str,langFile:str,language:str,masterRoles:[{index:int,name:str},...],moods:[{id:int,label:str},...],order:{avatarOrderLifeTime:int,customerGainMax:int,customerGainMin:int,maxOrder:int,orderLifeTime:int,prepareLifeTime:int},rid:int,roomTheme:[str,...],version:int,versionFile:str,webServer:str}` ×1
  - sample: `{"language":"ar","farmCleaningCost":10,"chatBaloons":[{"requirements":"AA==","id":1,"name":"Default"},{"requirements":"gA==","id":2,"name":"Silver"},{"requirements":"EA==","id":3,"name":"Yellow"},{"re`

**Typical follow-ups within 5 lines:**
- `config` ×2
- `externalTokenComplete` ×1

### `displayAd`

**← (server → client push/response)** — 3 call(s)

- shape `{ads:[{alias:str,assetUrl:str,clickUrl:str,id:int,impUrl:str,length:int,repeat:int,skipSecond:int,type:str}]}` ×3
  - sample: `{"ads":[{"assetUrl":"adsmarhab2.png","type":"BILLBOARD","length":0,"clickUrl":"https://www.facebook.com/marhabonline","alias":"billboard_BFreklam","impUrl":"","id":2,"repeat":0,"skipSecond":0}]}`

### `ditchguestpanel`

**→ (client → server request)** — 1 call(s)

- shape `{}` ×1
  - sample: `{}`

**Typical follow-ups within 5 lines:**
- `externalTokenComplete` ×1

### `externalTokenComplete`

**← (server → client push/response)** — 1 call(s)

- shape `{avatarID:str,token:str}` ×1
  - sample: `{"token":"6c3e7ce2-38e1-4448-a102-acbb114643ef","avatarID":"101002081"}`

### `fishing.joinGame`

**← (server → client push/response)** — 6 call(s)

- shape `{avatarID:str,rodX:int,rodY:int}` ×6
  - sample: `{"rodX":26,"rodY":6,"avatarID":"101004530"}`

### `fishing.leftGame`

**← (server → client push/response)** — 509 call(s)

- shape `{avatarID:str}` ×509
  - sample: `{"avatarID":"100999882"}`

### `fishing.list`

**← (server → client push/response)** — 16 call(s)

- shape `{fishers:[]}` ×12
  - sample: `{"fishers":[]}`
- shape `{fishers:[{avatarID:str,rodX:int,rodY:int}]}` ×4
  - sample: `{"fishers":[{"rodX":26,"rodY":6,"avatarID":"101004530"}]}`

### `fishing.start`

**→ (client → server request)** — 21 call(s)

- shape `{x:int,y:int}` ×21
  - sample: `{"y":6,"x":22}`

**Typical follow-ups within 5 lines:**
- `walkrequest` ×25
- `fishing.leftGame` ×14
- `mediaevent` ×8
- `fishing.update` ×4
- `whispernotify` ×1

### `fishing.update`

**← (server → client push/response)** — 78 call(s)

- shape `{states:[]}` ×64
  - sample: `{"states":[]}`
- shape `{states:[{avatarID:str,state:str}]}` ×14
  - sample: `{"states":[{"state":"HIT","avatarID":"101004530"}]}`

### `flatlist`

**→ (client → server request)** — 1 call(s)

- shape `{buildingID:int}` ×1
  - sample: `{"buildingID":3}`

**← (server → client push/response)** — 1 call(s)

- shape `{buddyHouses:[{ak:str,avatarID:str,clip:str,ds:str,fv:int,id:int,lk:bool,oc:int,rl:str,sp:int,tl:str},...],nextRequest:int,others:[{ak:str,avatarID:str,clip:str,ds:str,fv:int,id:int,lk:bool,oc:int,rl:str,sp:int,tl:str},...],rid:int,ts:int,youLiked:[],yourHouses:[{ak:str,avatarID:str,clip:str,ds:str,fv:int,id:int,lk:bool,oc:int,rl:str,sp:int,tl:str},...]}` ×1
  - sample: `{"youLiked":[],"ts":1780072756,"others":[{"ds":"Welcome to my cozy small cafe!","rl":"VIP","ak":"177438880a516d5c2f26ffdfaa96b03f7644d413c245b37067f17cbd07602368ac6b12208f2a9bc1b547f3abf8eb68869977b1a`

**Typical follow-ups within 5 lines:**
- `flatlist` ×2
- `fishing.leftGame` ×1

### `getlanguages`

**→ (client → server request)** — 1 call(s)

- shape `{}` ×1
  - sample: `{}`

**← (server → client push/response)** — 1 call(s)

- shape `{currentLanguage:str,languages:[{code:str,name:str},...]}` ×1
  - sample: `{"languages":[{"name":"العربية","code":"ar"},{"name":"English","code":"en"},{"name":"Türkçe","code":"tr"}],"currentLanguage":"ar"}`

**Typical follow-ups within 5 lines:**
- `getlanguages` ×2
- `fishing.leftGame` ×1

### `globalchat.leave`

**→ (client → server request)** — 2 call(s)

- shape `{}` ×2
  - sample: `{}`

**← (server → client push/response)** — 2 call(s)

- shape `{nextRequest:int,rid:int}` ×2
  - sample: `{"rid":172,"nextRequest":1000}`

**Typical follow-ups within 5 lines:**
- `globalchat.leave` ×4
- `buddyOnlineStatus` ×1
- `fishing.leftGame` ×1
- `profile` ×1

### `handitemlist`

**→ (client → server request)** — 8 call(s)

- shape `{page:int,search:str,sort:str}` ×8
  - sample: `{"sort":"created_desc","page":1,"search":""}`

**← (server → client push/response)** — 8 call(s)

- shape `{items:{list:[{active:int,base:int,clip:str,color:int,createdAt:str,expire:int,id:int,lifeTime:int,productID:int,quantity:int,roles:str,source:str,subType:str,timeLeft:int,transferrable:bool},...],page:int},nextRequest:int,pageSelected:int,rid:int,totalPages:int,ts:int}` ×8
  - sample: `{"items":{"list":[{"clip":"MXJgQddY","quantity":1,"lifeTime":0,"id":40731,"base":0,"timeLeft":0,"transferrable":true,"productID":22714,"active":1,"color":0,"subType":"TOY","source":"CAMPAIGN_REWARD","`

**Typical follow-ups within 5 lines:**
- `handitemlist` ×16
- `cardlist` ×6
- `mediaevent` ×6
- `fishing.update` ×2
- `whispernotify` ×1

### `init`

**→ (client → server request)** — 1 call(s)

- shape `{}` ×1
  - sample: `{}`

**← (server → client push/response)** — 1 call(s)

- shape `{bans:[],campaigns:[],checkAvatar:int,clothes:{items:[{active:int,base:int,clip:str,color:int,createdAt:str,expire:int,id:int,productID:int,quantity:int,roles:str,source:str,subType:str,transferrable:bool},...],type:str},completedAchievementsCount:int,createAvatar:bool,emailActive:int,extensionInfo:[{name:str,property:{cn:str}},...],gender:str,guest:bool,isBanned:bool,playerID:str,rid:int,room:{doorKey:str,dv:int,key:str,map:str,pv:int},selectedAvatarID:str,settings:{flatNotifications:str,hideRequests:str,incomingMessages:str,muteSound:str,onlyBuddyWhisper:str,showInvitations:str,tradeRequests:str,transferRequests:str,verifySession:str,whisperMessage:str,wideMode:str,wideScreenMode:str},ts:int,tutorialStep:int,universe:{fullness:int,key:str,name:str,recommended:bool,roles:str,roomAvailable:bool,roomFullness:int},wallet:[{avatarID:int,balance:int,currency:str},...]}` ×1
  - sample: `{"settings":{"transferRequests":"1","incomingMessages":"1","tradeRequests":"1","whisperMessage":"0","flatNotifications":"1","onlyBuddyWhisper":"0","hideRequests":"1","verifySession":"1","wideMode":"1"`

**Typical follow-ups within 5 lines:**
- `init` ×1
- `initQueue` ×1
- `restartServer` ×1

### `initQueue`

**← (server → client push/response)** — 1 call(s)

- shape `{p:int,ts:int}` ×1
  - sample: `{"p":1,"ts":1780072643}`

### `mediaevent`

**← (server → client push/response)** — 132 call(s)

- shape `{mediaEventID:int,path:{groupID:str,stream_path:str},status:bool}` ×132
  - sample: `{"path":{"groupID":"","stream_path":"https://s.newmarhab.net:2083/marhab"},"mediaEventID":344,"status":true}`

### `newslist`

**→ (client → server request)** — 1 call(s)

- shape `{}` ×1
  - sample: `{}`

**← (server → client push/response)** — 1 call(s)

- shape `{news:[{content:str,date:str,id:int,imageUrl:str,metaKey:str,priority:int,title:str}],rid:int,ts:int}` ×1
  - sample: `{"news":[{"date":"2025-02-10 07:33:41","priority":1,"imageUrl":"test.jpg","id":1,"metaKey":"news-opened","content":"Welcome to Marhab Friends","title":"Welcome"}],"ts":1780073155,"rid":234}`

**Typical follow-ups within 5 lines:**
- `newslist` ×2
- `fishing.leftGame` ×1

### `orderlist`

**→ (client → server request)** — 1 call(s)

- shape `{}` ×1
  - sample: `{}`

**← (server → client push/response)** — 1 call(s)

- shape `{nextRequest:int,orders:[],rid:int,ts:int}` ×1
  - sample: `{"orders":[],"ts":1780072759,"rid":46,"nextRequest":1000}`

**Typical follow-ups within 5 lines:**
- `orderlist` ×2
- `roles` ×1
- `walkrequest` ×1

### `ping`

**→ (client → server request)** — 10 call(s)

- shape `{}` ×10
  - sample: `{}`

**← (server → client push/response)** — 10 call(s)

- shape `{message:str}` ×10
  - sample: `{"message":"pong"}`

**Typical follow-ups within 5 lines:**
- `ping` ×20
- `fishing.leftGame` ×5
- `walkrequest` ×4
- `shopproductlist` ×2
- `whispernotify` ×2

### `privatechatlist`

**→ (client → server request)** — 1 call(s)

- shape `{}` ×1
  - sample: `{}`

**← (server → client push/response)** — 1 call(s)

- shape `{groupList:[{avatarID:str,id:str,lastMessage:{content:str,date:int,id:int,sender:str},name:str,unreadCount:int}],nextRequest:int,rid:int,ts:int}` ×1
  - sample: `{"ts":1780073144,"rid":232,"groupList":[{"name":"Bob","id":"ff0a801a54b84e7ca5cd64fce1326f3b","unreadCount":0,"lastMessage":{"date":1757583970000,"sender":"101002081","id":1757583970000,"content":"اشط`

**Typical follow-ups within 5 lines:**
- `privatechatlist` ×2
- `fishing.leftGame` ×2

### `profile`

**→ (client → server request)** — 12 call(s)

- shape `{avatarID:str}` ×12
  - sample: `{"avatarID":"101003214"}`

**← (server → client push/response)** — 12 call(s)

- shape `{avarageRating:str,avatarAge:int,avatarCity:str,avatarName:str,badges:[{clip:str,quantity:int},...],banCount:int,cards:[{clip:str,expire:int,productID:int,quantity:int,subType:str},...],dislikeCount:int,duration:int,emailRegistered:int,flats:[],hasBestFriend:bool,isBuddy:bool,isRequest:bool,likeCount:int,mood:int,nextRequest:int,privilegeId:int,rid:int,runWinTeam:str,skin:{clip:str,property:{alpha:str,bgColor:str,cn:str,textColor:str}},status:str,stickers:[{clip:str,q:int},...],totalBuddies:int,ts:int}` ×3
  - sample: `{"privilegeId":1,"ts":1780072676,"runWinTeam":"","hasBestFriend":false,"avatarAge":26,"isBuddy":false,"banCount":0,"likeCount":808,"avatarName":"Musttfa","dislikeCount":0,"stickers":[{"q":1,"clip":"Au`
- shape `{avarageRating:str,avatarAge:int,avatarCity:str,avatarName:str,badges:[{clip:str,quantity:int},...],banCount:int,cards:[{clip:str,expire:int,productID:int,quantity:int,subType:str},...],dislikeCount:int,duration:int,emailRegistered:int,flats:[{favCount:int,id:int,imgPath:str,title:str,type:str}],hasBestFriend:bool,isBuddy:bool,isRequest:bool,likeCount:int,mood:int,nameColor:str,nameFont:str,nextRequest:int,privilegeId:int,rid:int,runWinTeam:str,skin:{clip:str,property:{alpha:str,bgColor:str,cn:str,textColor:str}},status:str,stickers:[{clip:str,q:int},...],totalBuddies:int,ts:int}` ×3
  - sample: `{"privilegeId":1,"nameColor":"FF6600","status":"• اللي داق مسيره يشتاق • ؛)","avatarAge":26,"ts":1780072740,"isBuddy":false,"banCount":0,"likeCount":245,"avatarName":"• أبـو عـلي •","dislikeCount":0,"`
- shape `{avarageRating:str,avatarAge:int,avatarCity:str,avatarName:str,badges:[{clip:str,quantity:int},...],banCount:int,cards:[{clip:str,expire:int,productID:int,quantity:int,subType:str},...],dislikeCount:int,duration:int,emailRegistered:int,flats:[{favCount:int,id:int,imgPath:str,title:str,type:str},...],hasBestFriend:bool,isBuddy:bool,isRequest:bool,likeCount:int,mood:int,nameColor:str,nameFont:str,nextRequest:int,privilegeId:int,rid:int,runWinTeam:str,skin:{clip:str,property:{alpha:str,bgColor:str,cn:str,textColor:str}},status:str,stickers:[{clip:str,q:int},...],totalBuddies:int,ts:int}` ×3
  - sample: `{"privilegeId":1,"nameColor":"DC143C","status":"][ هي في المساء وحيده , وانا وحيد مثلها ][","avatarAge":26,"ts":1780073033,"isBuddy":false,"banCount":0,"likeCount":114,"avatarName":"_Nseny","dislikeCo`
- shape `{avarageRating:str,avatarAge:int,avatarCity:str,avatarName:str,badges:[{clip:str,quantity:int},...],banCount:int,cards:[{clip:str,expire:int,productID:int,quantity:int,subType:str},...],dislikeCount:int,duration:int,emailRegistered:int,flats:[{favCount:int,id:int,imgPath:str,title:str,type:str},...],hasBestFriend:bool,isBuddy:bool,isRequest:bool,likeCount:int,mood:int,nextRequest:int,privilegeId:int,rid:int,runWinTeam:str,skin:{clip:str,property:{alpha:str,bgColor:str,cn:str,textColor:str}},status:str,stickers:[{clip:str,q:int},...],totalBuddies:int,ts:int}` ×2
  - sample: `{"mood":1,"ts":1780072668,"runWinTeam":"","hasBestFriend":false,"isBuddy":false,"banCount":0,"avatarAge":26,"likeCount":114,"avatarName":"كابتشينو","dislikeCount":0,"stickers":[{"q":1,"clip":"AutumnSt`
- shape `{avarageRating:str,avatarAge:int,avatarCity:str,avatarName:str,badges:[{clip:str,quantity:int},...],banCount:int,cards:[{clip:str,expire:int,productID:int,quantity:int,subType:str},...],dislikeCount:int,duration:int,emailRegistered:int,flats:[{favCount:int,id:int,imgPath:str,title:str,type:str},...],hasBestFriend:bool,isBuddy:bool,isRequest:bool,likeCount:int,mood:int,nextRequest:int,privilegeId:int,rid:int,runWinTeam:str,skin:{clip:str,property:{alpha:str,bgColor:str,cn:str,textColor:str}},status:str,stickers:[{clip:str,q:int}],totalBuddies:int,ts:int}` ×1
  - sample: `{"mood":5,"ts":1780072693,"runWinTeam":"","avatarAge":26,"isBuddy":false,"banCount":0,"likeCount":56,"avatarName":"Mariam12345","dislikeCount":0,"stickers":[{"q":1,"clip":"CampSticker"}],"emailRegiste`

**Typical follow-ups within 5 lines:**
- `profile` ×21
- `mediaevent` ×8
- `fishing.leftGame` ×8
- `fishing.update` ×2
- `fishing.joinGame` ×1

### `profilelike`

**→ (client → server request)** — 8 call(s)

- shape `{avatarID:str,avatarLike:int}` ×8
  - sample: `{"avatarLike":1,"avatarID":"101003214"}`

**← (server → client push/response)** — 8 call(s)

- shape `{dislikeCount:int,likeCount:int,nextRequest:int,rid:int,ts:int}` ×8
  - sample: `{"dislikeCount":0,"ts":1780072671,"rid":14,"likeCount":115,"nextRequest":2000}`

**Typical follow-ups within 5 lines:**
- `profilelike` ×13
- `fishing.leftGame` ×6
- `mediaevent` ×4
- `avatarLikeUpdated` ×2
- `whispernotify` ×1

### `purchase`

**→ (client → server request)** — 2 call(s)

- shape `{items:[{quantity:int,shopProductID:int}],objectID:int,shopID:int}` ×2
  - sample: `{"objectID":0,"shopID":5,"items":[{"quantity":4,"shopProductID":20261}]}`

**← (server → client push/response)** — 2 call(s)

- shape `{cost:[{currency:str,price:int}],items:[{items:[{active:...,base:...,clip:...,color:...,createdAt:...,expire:...,id:...,lifeTime:...,productID:...,quantity:...,roles:...,source:...,subType:...,timeLeft:...,transferrable:...},...],type:str}],nextRequest:int,rid:int,ts:int}` ×1
  - sample: `{"nextRequest":1000,"items":[{"type":"OBJECT","items":[{"clip":"dn5nQVHY","quantity":1,"lifeTime":0,"id":200007962,"base":0,"timeLeft":0,"transferrable":false,"productID":20261,"active":0,"color":0,"s`
- shape `{errorCode:int,errorMessage:str,rid:int,ts:int}` ×1
  - sample: `{"ts":1780072726,"rid":30,"errorCode":429,"errorMessage":"Please wait before making another purchase"}`

**Typical follow-ups within 5 lines:**
- `purchase` ×6
- `updateWallet` ×2

### `questaccept`

**→ (client → server request)** — 3 call(s)

- shape `{id:str}` ×3
  - sample: `{"id":"6605585"}`

**← (server → client push/response)** — 3 call(s)

- shape `{curVal:int,id:int,nextRequest:int,reqVal:int,rid:int,ts:int}` ×3
  - sample: `{"ts":1780072747,"curVal":1,"nextRequest":1000,"reqVal":1,"id":6605585,"rid":40}`

**Typical follow-ups within 5 lines:**
- `questaccept` ×6
- `queststepcomplete` ×3
- `fishing.leftGame` ×1
- `walkrequest` ×1

### `questlist`

**→ (client → server request)** — 1 call(s)

- shape `{showDetail:bool}` ×1
  - sample: `{"showDetail":false}`

**← (server → client push/response)** — 1 call(s)

- shape `{nextRequest:int,quests:[{curVal:int,currentStep:int,id:int,metaKey:str,reqVal:int,rewardMultiplier:int,status:str,steps:[{botKey:...,itemClip:...,itemLifetime:...,itemQuantity:...,requirementValue:...,roomKey:...,step:...},...],totalStep:int,type:str},...],rid:int,ts:int}` ×1
  - sample: `{"ts":1780072645,"quests":[{"totalStep":5,"steps":[{"itemQuantity":1,"itemLifetime":-1,"roomKey":"street01","requirementValue":1,"itemClip":"dt678TPO","botKey":"tahsin","step":1},{"itemQuantity":1,"it`

**Typical follow-ups within 5 lines:**
- `questlist` ×2
- `roles` ×1
- `fishing.list` ×1

### `questlistroom`

**← (server → client push/response)** — 10 call(s)

- shape `{quests:[{currentStep:int,id:int,isInCurrentRoom:bool,metaKey:str,rewardMultiplier:int,rewards:[{data:...,type:...}],roomKey:str,status:str,step:{botKey:str,cn:str,curVal:int,items:[...],reqVal:int},totalStep:int}]}` ×9
  - sample: `{"quests":[{"isInCurrentRoom":true,"status":"NEW","rewards":[{"data":{"amount":250},"type":"SANIL"}],"currentStep":1,"rewardMultiplier":1,"totalStep":7,"id":8567428,"metaKey":"sapling_task","step":{"r`
- shape `{quests:[{currentStep:int,id:int,isInCurrentRoom:bool,metaKey:str,rewardMultiplier:int,rewards:[{data:...,type:...}],roomKey:str,status:str,step:{botKey:str,cn:str,curVal:int,items:[...],reqVal:int},totalStep:int},...]}` ×1
  - sample: `{"quests":[{"isInCurrentRoom":true,"status":"NEW","rewards":[{"data":{"amount":250},"type":"SANIL"}],"currentStep":1,"rewardMultiplier":1,"totalStep":6,"id":1798810,"metaKey":"flower","step":{"reqVal"`

### `queststepcomplete`

**← (server → client push/response)** — 3 call(s)

- shape `{id:int,metaKey:str,nextRoom:str,type:str}` ×3
  - sample: `{"type":"PERIODIC","id":6605585,"metaKey":"paperDelivery","nextRoom":"hairdresser"}`

### `restartServer`

**← (server → client push/response)** — 1 call(s)

- shape `{isRestartWaiting:bool,reason:str}` ×1
  - sample: `{"reason":"","isRestartWaiting":false}`

### `roles`

**← (server → client push/response)** — 27 call(s)

- shape `{roles:str}` ×27
  - sample: `{"roles":"AA=="}`

### `roomjoincomplete`

**→ (client → server request)** — 27 call(s)

- shape `{}` ×27
  - sample: `{}`

**← (server → client push/response)** — 27 call(s)

- shape `{}` ×27
  - sample: `{}`

**Typical follow-ups within 5 lines:**
- `roomjoincomplete` ×54
- `roles` ×27
- `fishing.list` ×14
- `displayAd` ×3
- `walkrequest` ×3

### `saleproductlist`

**→ (client → server request)** — 1 call(s)

- shape `{booth:str}` ×1
  - sample: `{"booth":"VIPSALES"}`

**← (server → client push/response)** — 1 call(s)

- shape `{defaultCurrency:str,nextRequest:int,products:[{baseAmount:int,baseCurrency:str,baseSaleCurrency:str,baseSalePrice:int,booth:str,description:str,giftAmount:int,id:int,imgUrl:str,method:{amount:int,inGame:str,keyword:str,saleCurrency:str,salePrice:int},title:str,type:str}],purchaseToken:str,rid:int}` ×1
  - sample: `{"purchaseToken":"cf57215cd6df5df9a688b772e25c0ca388b0103e76c77ff47e3cae8b7c4decac","rid":93,"defaultCurrency":"USD","products":[{"type":"CARD","giftAmount":0,"description":"متجر مرحب","imgUrl":"d8e26`

**Typical follow-ups within 5 lines:**
- `saleproductlist` ×2
- `fishing.leftGame` ×1

### `setactivegroup`

**→ (client → server request)** — 1 call(s)

- shape `{groupID:str}` ×1
  - sample: `{"groupID":"0"}`

**← (server → client push/response)** — 1 call(s)

- shape `{nextRequest:int,rid:int,updateUnread:int}` ×1
  - sample: `{"updateUnread":0,"rid":31,"nextRequest":500}`

**Typical follow-ups within 5 lines:**
- `setactivegroup` ×2
- `fishing.leftGame` ×2

### `shopproductlist`

**→ (client → server request)** — 11 call(s)

- shape `{shopID:int}` ×11
  - sample: `{"shopID":5}`

**← (server → client push/response)** — 11 call(s)

- shape `{nextRequest:int,rid:int,shopProductList:{},shoppingBagInfos:[],ts:int}` ×4
  - sample: `{"ts":1780072705,"rid":24,"shopProductList":{},"shoppingBagInfos":[],"nextRequest":1000}`
- shape `str` ×2
  - sample: `{"nextRequest":1000,"ts":1780072703,"rid":23,"shopProductList":{"DOOR":[{"clip":"cf_h1","colors":[],"priority":100,"furnLocation":7,"publishDate":"2015-07-15","lifetime":0,"publishTime":342960397,"cou`
- shape `{nextRequest:int,rid:int,shopProductList:{BAG:[{clip:str,colors:[...],countDownType:str,currency:str,discount:int,furnLocation:int,id:int,lifetime:int,price:int,priority:int,productID:int,publishDate:str,publishTime:int,roles:str,subType:str,type:str},...],COSTUME:[{clip:str,colors:[...,...],countDownType:str,currency:str,discount:int,furnLocation:int,id:int,lifetime:int,price:int,priority:int,productID:int,publishDate:str,publishTime:int,roles:str,subType:str,type:str},...],DRINK:[{clip:str,colors:[],countDownType:str,currency:str,discount:int,furnLocation:int,id:int,lifetime:int,price:int,priority:int,productID:int,publishDate:str,publishTime:int,roles:str,subType:str,type:str},...],EFFECT:[{clip:str,colors:[...],countDownType:str,currency:str,discount:int,furnLocation:int,id:int,lifetime:int,price:int,priority:int,productID:int,publishDate:str,publishTime:int,roles:str,subType:str,type:str},...],FOOD:[{clip:str,colors:[...],countDownType:str,currency:str,discount:int,furnLocation:int,id:int,lifetime:int,price:int,priority:int,productID:int,publishDate:str,publishTime:int,roles:str,subType:str,type:str},...],GLASSES:[{clip:str,colors:[...],countDownType:str,currency:str,discount:int,furnLocation:int,id:int,lifetime:int,price:int,priority:int,productID:int,publishDate:str,publishTime:int,roles:str,subType:str,type:str}],HAIR:[{clip:str,colors:[...],countDownType:str,currency:str,discount:int,furnLocation:int,id:int,lifetime:int,price:int,priority:int,productID:int,publishDate:str,publishTime:int,roles:str,subType:str,type:str},...],HAT:[{clip:str,colors:[...,...],countDownType:str,currency:str,discount:int,furnLocation:int,id:int,lifetime:int,price:int,priority:int,productID:int,publishDate:str,publishTime:int,roles:str,subType:str,type:str},...],PANTS:[{clip:str,colors:[...,...],countDownType:str,currency:str,discount:int,furnLocation:int,id:int,lifetime:int,price:int,priority:int,productID:int,publishDate:str,publishTime:int,roles:str,subType:str,type:str},...],SHIRT:[{clip:str,colors:[...,...],countDownType:str,currency:str,discount:int,furnLocation:int,id:int,lifetime:int,price:int,priority:int,productID:int,publishDate:str,publishTime:int,roles:str,subType:str,type:str},...],SHOES:[{clip:str,colors:[...,...],countDownType:str,currency:str,discount:int,furnLocation:int,id:int,lifetime:int,price:int,priority:int,productID:int,publishDate:str,publishTime:int,roles:str,subType:str,type:str},...],TOY:[{clip:str,colors:[],countDownType:str,currency:str,discount:int,furnLocation:int,id:int,lifetime:int,price:int,priority:int,productID:int,publishDate:str,publishTime:int,roles:str,subType:str,type:str},...]},shoppingBagInfos:[],ts:int}` ×2
  - sample: `{"nextRequest":1000,"ts":1780072823,"rid":85,"shopProductList":{"EFFECT":[{"clip":"2x2vjnmr","colors":["7"],"priority":0,"furnLocation":0,"publishDate":"2024-03-13","lifetime":86400,"publishTime":6891`
- shape `{nextRequest:int,rid:int,shopProductList:{TOY:[{clip:str,colors:[],countDownType:str,currency:str,discount:int,furnLocation:int,id:int,lifetime:int,price:int,priority:int,productID:int,publishDate:str,publishTime:int,roles:str,subType:str,type:str},...]},shoppingBagInfos:[],ts:int}` ×2
  - sample: `{"ts":1780072990,"shoppingBagInfos":[],"rid":132,"shopProductList":{"TOY":[{"clip":"rhfm82na","colors":[],"priority":0,"furnLocation":0,"publishDate":"2022-12-28","lifetime":604800,"publishTime":67629`
- shape `{nextRequest:int,rid:int,shopProductList:{HAT:[{clip:str,colors:[...],countDownType:str,currency:str,discount:int,furnLocation:int,id:int,lifetime:int,price:int,priority:int,productID:int,publishDate:str,publishTime:int,roles:str,subType:str,type:str},...],SHIRT:[{clip:str,colors:[...],countDownType:str,currency:str,discount:int,furnLocation:int,id:int,lifetime:int,price:int,priority:int,productID:int,publishDate:str,publishTime:int,roles:str,subType:str,type:str},...],TOY:[{clip:str,colors:[],countDownType:str,currency:str,discount:int,furnLocation:int,id:int,lifetime:int,price:int,priority:int,productID:int,publishDate:str,publishTime:int,roles:str,subType:str,type:str},...]},shoppingBagInfos:[],ts:int}` ×1
  - sample: `{"ts":1780073043,"rid":152,"shopProductList":{"HAT":[{"clip":"ed","colors":["9"],"priority":13,"furnLocation":0,"publishDate":"2016-10-20","lifetime":2592000,"publishTime":273119435,"countDownType":"A`

**Typical follow-ups within 5 lines:**
- `shopproductlist` ×32
- `fishing.leftGame` ×3
- `updateWallet` ×1
- `purchase` ×1
- `whisper` ×1

### `updateWallet`

**← (server → client push/response)** — 3 call(s)

- shape `{reason:str,wallet:[{balance:int,currency:str},...]}` ×3
  - sample: `{"reason":"SHOPPING_BUY","wallet":[{"currency":"SANIL","balance":225681},{"currency":"DIAMOND","balance":138}]}`

### `usedoor`

**→ (client → server request)** — 1 call(s)

- shape `{key:str,type:str}` ×1
  - sample: `{"type":"door","key":"d1"}`

**← (server → client push/response)** — 25 call(s)

- shape `{room:{doorKey:str,dv:int,key:str,map:str,pv:int},universe:{fullness:int,key:str,name:str,recommended:bool,roles:str,roomAvailable:bool,roomFullness:int}}` ×25
  - sample: `{"universe":{"fullness":3,"roles":"AA==","roomFullness":0,"roomAvailable":true,"name":"جزيرة مرحب","key":"w1","recommended":false},"room":{"dv":0,"doorKey":"d1","pv":0,"key":"street01","map":"PG1hcCB0`

**Typical follow-ups within 5 lines:**
- `usedoor` ×1
- `ping` ×1
- `buddyOnlineStatus` ×1

### `usehanditem`

**→ (client → server request)** — 4 call(s)

- shape `{id:int}` ×4
  - sample: `{"id":4068008}`

**← (server → client push/response)** — 4 call(s)

- shape `{message:str,rid:int,status:str,ts:int}` ×4
  - sample: `{"message":"Hand item equipped successfully.","ts":1780072923,"rid":110,"status":"success"}`

**Typical follow-ups within 5 lines:**
- `usehanditem` ×8
- `fishing.update` ×1
- `whispernotify` ×1
- `mediaevent` ×1

### `usehousedoor`

**→ (client → server request)** — 1 call(s)

- shape `{avatarID:str,flatID:str,password:str}` ×1
  - sample: `{"password":"","avatarID":"101002081","flatID":"1000824"}`

**← (server → client push/response)** — 1 call(s)

- shape `{nextRequest:int,rid:int,room:{buildingID:int,doorKey:str,dv:int,key:str,map:str,pv:int,roomName:str,roomType:str},ts:int}` ×1
  - sample: `{"room":{"roomName":"Cafe of M7MED","buildingID":3,"doorKey":"d1","dv":0,"pv":0,"key":"cafe01","roomType":"cafe01","map":"PG1hcCB4T3JpZ2luPSc0MjYnIHlPcmlnaW49JzU2Myc+PGNoYWlyIGludGVyYWN0aXZlPSdmYWxzZS`

**Typical follow-ups within 5 lines:**
- `usehousedoor` ×1
- `fishing.leftGame` ×1

### `walkfinalrequest`

**→ (client → server request)** — 39 call(s)

- shape `{}` ×39
  - sample: `{}`

**← (server → client push/response)** — 39 call(s)

- shape `{nextRequest:int,rid:int}` ×39
  - sample: `{"rid":6,"nextRequest":100}`

**Typical follow-ups within 5 lines:**
- `walkfinalrequest` ×76
- `fishing.leftGame` ×18
- `fishing.update` ×4
- `questlistroom` ×4
- `mediaevent` ×4

### `walkrequest`

**→ (client → server request)** — 79 call(s)

- shape `{door:bool,x:int,y:int}` ×79
  - sample: `{"y":23,"door":false,"x":25}`

**← (server → client push/response)** — 73 call(s)

- shape `{delay:int,doorX:int,doorY:int,isDoor:bool}` ×29
  - sample: `{"isDoor":true,"delay":1680,"doorY":23,"doorX":47}`
- shape `{delay:int}` ×22
  - sample: `{"delay":5280}`
- shape `{message:str,status:str}` ×22
  - sample: `{"status":"error","message":"The target position is not walkable."}`

**Typical follow-ups within 5 lines:**
- `walkrequest` ×154
- `fishing.leftGame` ×50
- `mediaevent` ×13
- `fishing.update` ×6
- `whispernotify` ×2

### `whisper`

**→ (client → server request)** — 2 call(s)

- shape `{message:str,receiver:str}` ×2
  - sample: `{"receiver":"100979572","message":"jl"}`

**← (server → client push/response)** — 4 call(s)

- shape `{message:str,receiver:str,receivers:[str,...],sender:str,ts:int}` ×2
  - sample: `{"message":"لايك يبرو","sender":"100979572","ts":1780072830,"receiver":"101002081","receivers":["100979409","101002081"]}`
- shape `{message:str,receiver:str,sender:str,ts:int}` ×2
  - sample: `{"message":"jl","sender":"101002081","ts":1780072852,"receiver":"100979572"}`

**Typical follow-ups within 5 lines:**
- `whisper` ×3
- `fishing.leftGame` ×3
- `whispernotify` ×1

### `whispernotify`

**← (server → client push/response)** — 62 call(s)

- shape `{receiver:str,rid:int,sender:str,ts:int}` ×39
  - sample: `{"sender":"101007803","ts":1780072741,"rid":326,"receiver":"101004296"}`
- shape `{receiverNames:[str,...],receivers:[str,...],rid:int,sender:str,ts:int}` ×23
  - sample: `{"sender":"100999882","ts":1780072645,"rid":209,"receivers":["100998545","100979429"],"receiverNames":["Aia","خالد"]}`

### `xoaction`

**→ (client → server request)** — 4 call(s)

- shape `{action:str}` ×3
  - sample: `{"action":"rooms"}`
- shape `{action:str,type:str}` ×1
  - sample: `{"action":"create","type":"public"}`

**← (server → client push/response)** — 4 call(s)

- shape `{action:str,myLosses:int,myTotal:int,myWins:int,rooms:[]}` ×2
  - sample: `{"myTotal":0,"rooms":[],"myWins":0,"action":"rooms","myLosses":0}`
- shape `{action:str,roomId:int,roomType:str,status:str}` ×1
  - sample: `{"action":"created","status":"waiting","roomId":27082,"roomType":"public"}`
- shape `{action:str,status:str}` ×1
  - sample: `{"status":"refunded","action":"left"}`

**Typical follow-ups within 5 lines:**
- `xoaction` ×9
- `fishing.leftGame` ×4
- `updateWallet` ×2
- `fishing.update` ×2
