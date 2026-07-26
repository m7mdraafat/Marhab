# 8. Proposed database schema (PostgreSQL)

[← Asset pipeline](07-asset-pipeline.md)  ·  [Index](README.md)  ·  [Next: Server build plan →](09-server-build-plan.md)

## Design notes

- Target: **PostgreSQL 17** with JDBC (HikariCP pool).
- Modular monolith — one DB, schemas per bounded context.
- All currency values in `bigint`. All timestamps `timestamptz`. All IDs
  `bigint` generated as identity, except surrogate UUIDs where needed.
- Email lookups: `text` + functional unique index on `lower(email)`
  (avoid `citext` for portability).
- Password hashing: Argon2id (Konscious-equivalent in Java: `BouncyCastle` or
  `de.mkammerer.argon2`) with OWASP 2024 params.
- Naming: snake_case tables, snake_case columns, plural table names.
- Keep [../docs/db/schema.sql](db/schema.sql) (TBD) as source of truth
  initially; add an idempotent baseline migration in a follow-up.

## 8.1 Identity & auth

```sql
CREATE SCHEMA auth;

CREATE TABLE auth.accounts (
  id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  email           text NOT NULL,
  email_verified  boolean NOT NULL DEFAULT false,
  phone           text,
  phone_verified  boolean NOT NULL DEFAULT false,
  password_hash   text NOT NULL,                 -- Argon2id
  password_algo   text NOT NULL DEFAULT 'argon2id',
  status          text NOT NULL DEFAULT 'active', -- active | deactivated | banned
  deactivation_reason text,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX accounts_email_lower_uk ON auth.accounts (lower(email));

CREATE TABLE auth.access_tokens (
  token_hash   bytea PRIMARY KEY,               -- SHA-256 of raw token
  account_id   bigint NOT NULL REFERENCES auth.accounts(id) ON DELETE CASCADE,
  issued_at    timestamptz NOT NULL DEFAULT now(),
  expires_at   timestamptz NOT NULL,
  revoked_at   timestamptz,
  client_kind  text NOT NULL,                   -- "web" | "desktop" | "mobile"
  device_id    text,
  ip           inet
);
CREATE INDEX access_tokens_account_idx ON auth.access_tokens (account_id)
  WHERE revoked_at IS NULL;

CREATE TABLE auth.security_keys (               -- 2FA / captcha challenges
  id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  account_id  bigint NOT NULL REFERENCES auth.accounts(id) ON DELETE CASCADE,
  kind        text NOT NULL,                    -- "captcha" | "key"
  challenge   text NOT NULL,
  consumed_at timestamptz,
  created_at  timestamptz NOT NULL DEFAULT now()
);
```

## 8.2 Avatars

```sql
CREATE SCHEMA avatar;

CREATE TABLE avatar.avatars (
  id                  bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  account_id          bigint NOT NULL REFERENCES auth.accounts(id) ON DELETE CASCADE,
  name                text NOT NULL,
  gender              char(1) NOT NULL CHECK (gender IN ('m','f')),
  guest               boolean NOT NULL DEFAULT false,
  privilege_id        int NOT NULL DEFAULT 1,    -- 0 guest, 1 standard, 2 mod, 3 admin, 4 owner
  permission_bits     bigint NOT NULL DEFAULT 0, -- AvatarPermission bitset
  mood                int NOT NULL DEFAULT 0,    -- BuddyMoods index
  status_message      text,
  avatar_size         numeric(4,2) NOT NULL DEFAULT 1.00,
  speed               numeric(4,2) NOT NULL DEFAULT 1.00,
  universe_key        text,
  platform            text,
  created_at          timestamptz NOT NULL DEFAULT now(),
  selected_at         timestamptz
);
CREATE UNIQUE INDEX avatars_name_lower_uk ON avatar.avatars (lower(name));
CREATE INDEX avatars_account_idx ON avatar.avatars (account_id);

CREATE TABLE avatar.settings (
  avatar_id              bigint PRIMARY KEY REFERENCES avatar.avatars(id) ON DELETE CASCADE,
  wide_mode              boolean,
  show_invitations       boolean,
  transfer_requests      boolean,
  incoming_messages      boolean,
  trade_requests         boolean,
  whisper_message        boolean,
  flat_notifications     boolean,
  only_buddy_whisper     boolean,
  verify_session         boolean
);

CREATE TABLE avatar.balances (
  avatar_id   bigint NOT NULL REFERENCES avatar.avatars(id) ON DELETE CASCADE,
  currency    text NOT NULL,            -- 'SANIL' | 'DIAMOND' | 'PEPSICOIN'
  amount      bigint NOT NULL DEFAULT 0 CHECK (amount >= 0),
  PRIMARY KEY (avatar_id, currency)
);

CREATE TABLE avatar.bans (
  id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  avatar_id   bigint NOT NULL REFERENCES avatar.avatars(id) ON DELETE CASCADE,
  ban_type    text NOT NULL CHECK (ban_type IN ('CHAT','LOGIN')),
  reason      text NOT NULL,
  start_at    timestamptz NOT NULL DEFAULT now(),
  end_at      timestamptz,
  created_by  bigint REFERENCES avatar.avatars(id)
);
CREATE INDEX bans_active_idx ON avatar.bans (avatar_id)
  WHERE end_at IS NULL OR end_at > now();
```

## 8.3 Items / inventory / clothes

```sql
CREATE SCHEMA inventory;

CREATE TABLE inventory.product_catalog (        -- mirrors ifile.* (cloths + items)
  product_id    text PRIMARY KEY,
  product_type  text NOT NULL,                  -- ProductType (OBJECT|CLOTH|HAND|FLAT|CARD|FARMING|PROFILE_SKIN)
  sub_type      text,                           -- ProductSubType (FOOD|TOY|CHECK|…)
  clip          text NOT NULL,                  -- asset key
  width         int,
  height        int,
  layers        int,
  flags         int NOT NULL DEFAULT 0,         -- ItemType bitset
  default_color int,
  vip_only      boolean NOT NULL DEFAULT false,
  age_restricted int                            -- 0=none, 13, 18
);

CREATE TABLE inventory.user_items (             -- inventory + worn + base outfit
  id             bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  avatar_id      bigint NOT NULL REFERENCES avatar.avatars(id) ON DELETE CASCADE,
  product_id     text NOT NULL REFERENCES inventory.product_catalog(product_id),
  quantity       int NOT NULL DEFAULT 1 CHECK (quantity >= 0),
  color          int,
  is_equipped    boolean NOT NULL DEFAULT false,    -- worn now
  is_base        boolean NOT NULL DEFAULT false,    -- in default outfit
  is_transferable boolean NOT NULL DEFAULT true,
  life_time_sec  int NOT NULL DEFAULT 0,            -- 0 = permanent
  expires_at     timestamptz,
  acquired_at    timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX user_items_avatar_idx ON inventory.user_items (avatar_id);
CREATE INDEX user_items_expiring_idx ON inventory.user_items (expires_at)
  WHERE expires_at IS NOT NULL;

CREATE TABLE inventory.purchase_history (
  id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  avatar_id       bigint NOT NULL REFERENCES avatar.avatars(id),
  shop_id         int NOT NULL,
  object_id       int NOT NULL,
  product_id      text NOT NULL REFERENCES inventory.product_catalog(product_id),
  quantity        int NOT NULL,
  color           int,
  paid_currency   text NOT NULL,
  paid_amount     bigint NOT NULL,
  purchased_at    timestamptz NOT NULL DEFAULT now()
);
```

## 8.4 Rooms / streets / flats

```sql
CREATE SCHEMA room;

CREATE TABLE room.room_catalog (                -- public streets + room templates
  room_key       text PRIMARY KEY,
  title          text NOT NULL,
  room_type      text NOT NULL,                 -- 'STREET' | 'HOUSE' | 'CAFE' | 'GARAGE' | 'HOSPITAL' | 'LAND' | 'OFFICE'
  category       text,                          -- INDOOR | OUTDOOR | BUSINESS
  width          int NOT NULL,
  height         int NOT NULL,
  grid           text NOT NULL,                 -- encoded walkability
  doors          jsonb NOT NULL DEFAULT '[]',   -- door definitions
  bots           jsonb NOT NULL DEFAULT '[]',
  extensions     jsonb NOT NULL DEFAULT '[]',
  source_swf_key text NOT NULL                  -- "/dynamic/rooms-2x/{key}.swf"
);

CREATE TABLE room.flats (                       -- user-owned rooms (HOUSE/CAFE/…)
  id             bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  flat_uid       uuid NOT NULL DEFAULT gen_random_uuid(),
  owner_id       bigint NOT NULL REFERENCES avatar.avatars(id),
  base_room_key  text NOT NULL REFERENCES room.room_catalog(room_key),
  flat_type      text NOT NULL,                 -- UserRoomTypes
  name           text NOT NULL,
  description    text,
  password_hash  text,                          -- entry password (Argon2id) — nullable
  is_public      boolean NOT NULL DEFAULT true,
  sponsor_expires_at timestamptz,
  created_at     timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX flats_uid_uk ON room.flats (flat_uid);
CREATE INDEX flats_owner_idx ON room.flats (owner_id);
CREATE INDEX flats_name_trgm ON room.flats USING gin (name gin_trgm_ops);

CREATE TABLE room.flat_design (                 -- room editor saved state
  flat_id        bigint PRIMARY KEY REFERENCES room.flats(id) ON DELETE CASCADE,
  grid_state     jsonb NOT NULL,
  furniture      jsonb NOT NULL,                -- [{itemId, x, y, z, rotation, frame, state, lock}]
  updated_at     timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE room.flat_favorites (
  avatar_id  bigint NOT NULL REFERENCES avatar.avatars(id) ON DELETE CASCADE,
  flat_id    bigint NOT NULL REFERENCES room.flats(id) ON DELETE CASCADE,
  PRIMARY KEY (avatar_id, flat_id)
);

CREATE TABLE room.flat_visits (                 -- userFlatEntered telemetry
  id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  flat_id      bigint NOT NULL REFERENCES room.flats(id),
  visitor_id   bigint NOT NULL REFERENCES avatar.avatars(id),
  entered_at   timestamptz NOT NULL DEFAULT now()
);
```

## 8.5 Social

```sql
CREATE SCHEMA social;

CREATE TABLE social.buddies (
  avatar_id        bigint NOT NULL REFERENCES avatar.avatars(id) ON DELETE CASCADE,
  buddy_id         bigint NOT NULL REFERENCES avatar.avatars(id) ON DELETE CASCADE,
  state            text NOT NULL CHECK (state IN ('PENDING','ACCEPTED','BLOCKED')),
  my_rating        int NOT NULL DEFAULT 0,
  buddy_rating     int NOT NULL DEFAULT 0,
  created_at       timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (avatar_id, buddy_id),
  CHECK (avatar_id <> buddy_id)
);
CREATE INDEX buddies_buddy_idx ON social.buddies (buddy_id, state);

CREATE TABLE social.private_chat_groups (
  id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  group_uid       uuid NOT NULL DEFAULT gen_random_uuid(),
  group_name      text,
  created_at      timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX pcg_uid_uk ON social.private_chat_groups (group_uid);

CREATE TABLE social.private_chat_members (
  group_id        bigint NOT NULL REFERENCES social.private_chat_groups(id) ON DELETE CASCADE,
  avatar_id       bigint NOT NULL REFERENCES avatar.avatars(id) ON DELETE CASCADE,
  unread_count    int NOT NULL DEFAULT 0,
  PRIMARY KEY (group_id, avatar_id)
);

CREATE TABLE social.private_messages (
  id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  group_id        bigint NOT NULL REFERENCES social.private_chat_groups(id) ON DELETE CASCADE,
  sender_id       bigint NOT NULL REFERENCES avatar.avatars(id),
  content         text NOT NULL,
  sent_at         timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX pm_group_sent_idx ON social.private_messages (group_id, sent_at DESC);

CREATE TABLE social.user_blocks (
  avatar_id   bigint NOT NULL REFERENCES avatar.avatars(id) ON DELETE CASCADE,
  blocked_id  bigint NOT NULL REFERENCES avatar.avatars(id) ON DELETE CASCADE,
  created_at  timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (avatar_id, blocked_id)
);

CREATE TABLE social.chat_history (             -- public chat audit log
  id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  room_key    text NOT NULL,
  flat_id     bigint REFERENCES room.flats(id),
  sender_id   bigint NOT NULL REFERENCES avatar.avatars(id),
  message     text NOT NULL,
  sent_at     timestamptz NOT NULL DEFAULT now()
) PARTITION BY RANGE (sent_at);
-- + monthly partitions
```

## 8.6 Economy

```sql
CREATE SCHEMA economy;

CREATE TABLE economy.transfers (              -- gift/transfer 3-way handshake
  id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  transfer_uid    uuid NOT NULL DEFAULT gen_random_uuid(),
  sender_id       bigint NOT NULL REFERENCES avatar.avatars(id),
  target_id       bigint NOT NULL REFERENCES avatar.avatars(id),
  item_id         bigint REFERENCES inventory.user_items(id),
  diamond_amount  bigint,
  state           text NOT NULL CHECK (state IN ('PENDING','ACCEPTED','REJECTED','CANCELLED','EXPIRED')),
  created_at      timestamptz NOT NULL DEFAULT now(),
  resolved_at     timestamptz,
  CHECK (item_id IS NOT NULL OR diamond_amount IS NOT NULL)
);
CREATE UNIQUE INDEX transfers_uid_uk ON economy.transfers (transfer_uid);
CREATE INDEX transfers_target_pending_idx ON economy.transfers (target_id)
  WHERE state = 'PENDING';

CREATE TABLE economy.barter_sessions (
  id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  barter_uid   uuid NOT NULL DEFAULT gen_random_uuid(),
  initiator_id bigint NOT NULL REFERENCES avatar.avatars(id),
  partner_id   bigint NOT NULL REFERENCES avatar.avatars(id),
  state        text NOT NULL,                 -- INVITED|ACCEPTED|NEGOTIATING|CONFIRMED|CANCELLED
  initiator_offer jsonb NOT NULL DEFAULT '[]',
  partner_offer   jsonb NOT NULL DEFAULT '[]',
  created_at   timestamptz NOT NULL DEFAULT now(),
  resolved_at  timestamptz
);
CREATE UNIQUE INDEX barter_uid_uk ON economy.barter_sessions (barter_uid);

CREATE TABLE economy.diamond_transfer_quota (
  avatar_id    bigint NOT NULL REFERENCES avatar.avatars(id) ON DELETE CASCADE,
  day          date NOT NULL,
  amount       bigint NOT NULL DEFAULT 0,
  PRIMARY KEY (avatar_id, day)
);

CREATE TABLE economy.drops (                  -- ground drops the room is showing
  id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  room_key    text NOT NULL,
  flat_id     bigint REFERENCES room.flats(id),
  product_id  text NOT NULL REFERENCES inventory.product_catalog(product_id),
  x           int NOT NULL,
  y           int NOT NULL,
  expires_at  timestamptz NOT NULL,
  claimed_by  bigint REFERENCES avatar.avatars(id),
  claimed_at  timestamptz
);
```

## 8.7 Quests / achievements / missions

```sql
CREATE SCHEMA progress;

CREATE TABLE progress.quest_catalog (
  quest_id     text PRIMARY KEY,
  meta_key     text NOT NULL,
  quest_type   text NOT NULL CHECK (quest_type IN ('ADVENTURE','PERIODIC','ACHIVEMENT')),
  name         text NOT NULL,
  description  text NOT NULL,
  detail_data  jsonb NOT NULL DEFAULT '{}',
  active       boolean NOT NULL DEFAULT true
);

CREATE TABLE progress.quest_steps (
  id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  quest_id     text NOT NULL REFERENCES progress.quest_catalog(quest_id) ON DELETE CASCADE,
  step_index   int NOT NULL,
  room_key     text NOT NULL REFERENCES room.room_catalog(room_key),
  required_value int NOT NULL,
  reward       jsonb NOT NULL DEFAULT '{}',
  UNIQUE (quest_id, step_index)
);

CREATE TABLE progress.quest_progress (
  avatar_id    bigint NOT NULL REFERENCES avatar.avatars(id) ON DELETE CASCADE,
  quest_id     text NOT NULL REFERENCES progress.quest_catalog(quest_id) ON DELETE CASCADE,
  current_step int NOT NULL DEFAULT 0,
  current_value int NOT NULL DEFAULT 0,
  started_at   timestamptz NOT NULL DEFAULT now(),
  completed_at timestamptz,
  PRIMARY KEY (avatar_id, quest_id)
);

CREATE TABLE progress.achievement_catalog (
  achievement_id text PRIMARY KEY,
  name           text NOT NULL,
  description    text NOT NULL,
  trigger_kind   text NOT NULL,             -- ITEM_OWNED | ROOMS_VISITED | LEVEL | …
  trigger_data   jsonb NOT NULL,
  reward_count   int NOT NULL DEFAULT 1
);

CREATE TABLE progress.achievement_progress (
  avatar_id      bigint NOT NULL REFERENCES avatar.avatars(id) ON DELETE CASCADE,
  achievement_id text NOT NULL REFERENCES progress.achievement_catalog(achievement_id) ON DELETE CASCADE,
  unlocked_at    timestamptz NOT NULL DEFAULT now(),
  claimed_at     timestamptz,
  PRIMARY KEY (avatar_id, achievement_id)
);

CREATE TABLE progress.missions (
  campaign_id   text PRIMARY KEY,
  meta_key      text NOT NULL,
  starts_at     timestamptz NOT NULL,
  ends_at       timestamptz NOT NULL,
  steps         jsonb NOT NULL,
  rewards       jsonb NOT NULL
);

CREATE TABLE progress.mission_progress (
  avatar_id     bigint NOT NULL REFERENCES avatar.avatars(id) ON DELETE CASCADE,
  campaign_id   text NOT NULL REFERENCES progress.missions(campaign_id) ON DELETE CASCADE,
  current_step  int NOT NULL DEFAULT 0,
  completed_at  timestamptz,
  PRIMARY KEY (avatar_id, campaign_id)
);

CREATE TABLE progress.daily_gift_log (        -- campaigns delivered via init.campaigns[]
  avatar_id    bigint NOT NULL REFERENCES avatar.avatars(id) ON DELETE CASCADE,
  campaign_id  text NOT NULL,
  claimed_at   timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (avatar_id, campaign_id, claimed_at)
);
```

## 8.8 World — interactive objects, farm, gathering, café orders

```sql
CREATE SCHEMA world;

CREATE TABLE world.scene_objects (              -- placed interactive objects on a room
  id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  meta_key        text NOT NULL,                -- the "id" sent in changeobjectframe etc.
  room_key        text REFERENCES room.room_catalog(room_key),
  flat_id         bigint REFERENCES room.flats(id),
  product_id      text REFERENCES inventory.product_catalog(product_id),
  property_class  text NOT NULL,                -- "FrameProperty", "FarmProperty", …
  property_data   jsonb NOT NULL DEFAULT '{}',
  x               int NOT NULL,
  y               int NOT NULL,
  z               int NOT NULL DEFAULT 0,
  frame           int NOT NULL DEFAULT 0,
  state           int NOT NULL DEFAULT 0,
  locked          boolean NOT NULL DEFAULT false,
  CHECK ((room_key IS NULL) <> (flat_id IS NULL))   -- one or the other
);
CREATE UNIQUE INDEX scene_objects_meta_uk ON world.scene_objects (
  coalesce(flat_id::text, ''), coalesce(room_key, ''), meta_key);

CREATE TABLE world.farm_plots (
  scene_object_id  bigint PRIMARY KEY REFERENCES world.scene_objects(id) ON DELETE CASCADE,
  crop_id          text REFERENCES inventory.product_catalog(product_id),
  state            text NOT NULL,               -- EMPTY | PLANTED | SEEDLING | PRODUCT | DRY
  planted_at       timestamptz,
  ripens_at        timestamptz,
  withers_at       timestamptz
);

CREATE TABLE world.gathering_sessions (
  id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  scene_object_id bigint NOT NULL REFERENCES world.scene_objects(id) ON DELETE CASCADE,
  avatar_id       bigint NOT NULL REFERENCES avatar.avatars(id),
  started_at      timestamptz NOT NULL DEFAULT now(),
  completes_at    timestamptz NOT NULL,
  collected_at    timestamptz
);

CREATE TABLE world.cafe_orders (
  id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  cafe_flat_id bigint NOT NULL REFERENCES room.flats(id),
  customer_id  bigint NOT NULL REFERENCES avatar.avatars(id),
  items        jsonb NOT NULL,
  state        text NOT NULL,                  -- REQUESTED | PREPARED | DELIVERED | CANCELLED
  created_at   timestamptz NOT NULL DEFAULT now(),
  resolved_at  timestamptz
);
```

## 8.9 Reports, moderation, audit

```sql
CREATE SCHEMA mod;

CREATE TABLE mod.reports (
  id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  reporter_id  bigint NOT NULL REFERENCES avatar.avatars(id),
  target_id    bigint NOT NULL REFERENCES avatar.avatars(id),
  reason       text NOT NULL,
  context      jsonb NOT NULL DEFAULT '{}',
  state        text NOT NULL DEFAULT 'OPEN',
  created_at   timestamptz NOT NULL DEFAULT now(),
  resolved_at  timestamptz,
  resolved_by  bigint REFERENCES avatar.avatars(id)
);

CREATE TABLE mod.role_assignments (             -- RBAC for admins/mods
  avatar_id    bigint NOT NULL REFERENCES avatar.avatars(id) ON DELETE CASCADE,
  role         text NOT NULL,                  -- ADMIN|MOD|EDITOR|JOURNALIST|…
  granted_by   bigint REFERENCES avatar.avatars(id),
  granted_at   timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (avatar_id, role)
);

CREATE TABLE mod.audit_log (
  id           bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  actor_id     bigint REFERENCES avatar.avatars(id),
  action       text NOT NULL,
  target_kind  text,
  target_id    text,
  payload      jsonb,
  at           timestamptz NOT NULL DEFAULT now()
) PARTITION BY RANGE (at);
```

## 8.10 Catalog / config

```sql
CREATE SCHEMA catalog;

CREATE TABLE catalog.moods (
  id       int PRIMARY KEY,
  label_key text NOT NULL
);

CREATE TABLE catalog.chat_balloons (
  id            int PRIMARY KEY,
  label_key     text NOT NULL,
  vip_only      boolean NOT NULL DEFAULT false,
  cost_currency text,
  cost_amount   bigint
);

CREATE TABLE catalog.shop_products (
  id           int PRIMARY KEY,
  shop_id      int NOT NULL,
  product_id   text NOT NULL REFERENCES inventory.product_catalog(product_id),
  currency     text NOT NULL,
  price        bigint NOT NULL,
  active       boolean NOT NULL DEFAULT true
);

CREATE TABLE catalog.master_roles (
  role_id  int PRIMARY KEY,
  name     text NOT NULL
);

CREATE TABLE catalog.app_config (             -- single-row dynamic config
  k        text PRIMARY KEY,
  v        jsonb NOT NULL,
  updated_at timestamptz NOT NULL DEFAULT now()
);
```

---

[← Asset pipeline](07-asset-pipeline.md)  ·  [Index](README.md)  ·  [Next: Server build plan →](09-server-build-plan.md)
