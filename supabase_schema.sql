-- منارة الحدباء للاستثمار العقاري: جدول Supabase
-- الصقه كله في Supabase > SQL Editor > New query ثم اضغط Run

create table if not exists public.aqarati_items (
  user_id uuid    not null default auth.uid() references auth.users(id) on delete cascade,
  uid     text    not null,
  kind    text    not null,                -- hood | prop | req
  ts      bigint  not null default 0,      -- وقت آخر تعديل (Date.now)
  deleted boolean not null default false,
  data    jsonb   not null default '{}'::jsonb,
  primary key (user_id, uid)               -- مطلوب لأن التطبيق يستعمل onConflict: user_id,uid
);

create index if not exists aqarati_items_user_kind_idx
  on public.aqarati_items (user_id, kind);

-- الحماية: كل مستخدم يشوف ويعدّل بياناته فقط
alter table public.aqarati_items enable row level security;

drop policy if exists "aqarati_select_own" on public.aqarati_items;
drop policy if exists "aqarati_insert_own" on public.aqarati_items;
drop policy if exists "aqarati_update_own" on public.aqarati_items;
drop policy if exists "aqarati_delete_own" on public.aqarati_items;

create policy "aqarati_select_own" on public.aqarati_items
  for select to authenticated using (auth.uid() = user_id);
create policy "aqarati_insert_own" on public.aqarati_items
  for insert to authenticated with check (auth.uid() = user_id);
create policy "aqarati_update_own" on public.aqarati_items
  for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "aqarati_delete_own" on public.aqarati_items
  for delete to authenticated using (auth.uid() = user_id);
