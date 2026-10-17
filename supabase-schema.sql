-- eFootball Kings Online v3 - production-ready Supabase foundation
create extension if not exists pgcrypto;

drop view if exists public.league_standings;

create table if not exists public.profiles(
 id uuid primary key references auth.users(id) on delete cascade,
 player_name text not null,
 role text not null default 'player' check(role in('player','admin')),
 avatar_url text,
 elo_rating integer not null default 1000,
 created_at timestamptz not null default now()
);
create table if not exists public.players(
 id uuid primary key default gen_random_uuid(), name text not null unique,
 status text not null default 'active' check(status in('active','suspended')),
 country text, team_name text, profile_id uuid unique references public.profiles(id) on delete set null,
 created_at timestamptz not null default now()
);
create table if not exists public.seasons(
 id uuid primary key default gen_random_uuid(), name text not null unique,
 status text not null default 'draft' check(status in('draft','active','completed')),
 starts_at timestamptz, ends_at timestamptz, created_at timestamptz not null default now()
);
create table if not exists public.competitions(
 id uuid primary key default gen_random_uuid(), season_id uuid not null references public.seasons(id) on delete cascade,
 name text not null, format text not null check(format in('league','group','knockout')),
 status text not null default 'draft' check(status in('draft','open','active','completed')),
 entry_fee numeric(12,2) not null default 0, currency text not null default 'KES', description text,
 created_at timestamptz not null default now()
);
create table if not exists public.competition_entries(
 id uuid primary key default gen_random_uuid(), competition_id uuid not null references public.competitions(id) on delete cascade,
 player_id uuid not null references public.players(id) on delete cascade,
 status text not null default 'registered' check(status in('registered','eliminated','qualified','champion')),
 seed integer, created_at timestamptz not null default now(), unique(competition_id,player_id)
);
create table if not exists public.fixtures(
 id uuid primary key default gen_random_uuid(), competition_id uuid not null references public.competitions(id) on delete cascade,
 round_name text, match_number integer, home_player_id uuid not null references public.players(id),
 away_player_id uuid not null references public.players(id), scheduled_at timestamptz,
 status text not null default 'scheduled' check(status in('scheduled','pending_verification','completed','cancelled')),
 home_score integer check(home_score>=0), away_score integer check(away_score>=0),
 winner_player_id uuid references public.players(id), created_at timestamptz not null default now(),
 constraint different_fixture_players check(home_player_id<>away_player_id)
);
create table if not exists public.match_submissions(
 id uuid primary key default gen_random_uuid(), fixture_id uuid not null references public.fixtures(id) on delete cascade,
 submitted_by uuid not null references public.profiles(id) on delete cascade,
 home_score integer check(home_score>=0), away_score integer check(away_score>=0), screenshot_url text,
 note text, status text not null default 'pending' check(status in('pending','approved','rejected')),
 created_at timestamptz not null default now(), reviewed_by uuid references public.profiles(id), reviewed_at timestamptz
);
create table if not exists public.approved_matches(
 id uuid primary key default gen_random_uuid(), submission_id uuid unique references public.match_submissions(id) on delete set null,
 fixture_id uuid unique references public.fixtures(id) on delete set null, competition_id uuid references public.competitions(id) on delete set null,
 home_player_id uuid not null references public.players(id), away_player_id uuid not null references public.players(id),
 home_score integer not null check(home_score>=0), away_score integer not null check(away_score>=0),
 home_name text not null, away_name text not null, approved_by uuid references public.profiles(id), approved_at timestamptz not null default now()
);
create table if not exists public.disputes(
 id uuid primary key default gen_random_uuid(), fixture_id uuid not null references public.fixtures(id) on delete cascade,
 raised_by uuid not null references public.profiles(id) on delete cascade, reason text not null,
 status text not null default 'open' check(status in('open','resolved','dismissed')), resolution text,
 resolved_by uuid references public.profiles(id), created_at timestamptz not null default now(), resolved_at timestamptz
);
create table if not exists public.notifications(
 id uuid primary key default gen_random_uuid(), user_id uuid references public.profiles(id) on delete cascade,
 title text not null, message text not null, read_at timestamptz, created_at timestamptz not null default now()
);
create table if not exists public.payments(
 id uuid primary key default gen_random_uuid(), user_id uuid references public.profiles(id) on delete set null,
 competition_id uuid references public.competitions(id) on delete set null, amount numeric(12,2) not null,
 currency text not null default 'KES', method text, reference text,
 status text not null default 'pending' check(status in('pending','paid','failed','refunded')), created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.players enable row level security;
alter table public.seasons enable row level security;
alter table public.competitions enable row level security;
alter table public.competition_entries enable row level security;
alter table public.fixtures enable row level security;
alter table public.match_submissions enable row level security;
alter table public.approved_matches enable row level security;
alter table public.disputes enable row level security;
alter table public.notifications enable row level security;
alter table public.payments enable row level security;

create or replace function public.is_admin() returns boolean language sql stable security definer set search_path=public as $$
 select exists(select 1 from public.profiles where id=auth.uid() and role='admin'); $$;

-- Safe to re-run: remove old policies first.
do $$ declare r record; begin
 for r in select schemaname, tablename, policyname from pg_policies where schemaname='public' loop
   execute format('drop policy if exists %I on %I.%I',r.policyname,r.schemaname,r.tablename);
 end loop;
end $$;

do $$ begin
 drop policy if exists "screenshot upload own" on storage.objects;
 drop policy if exists "screenshot public read" on storage.objects;
end $$;

create policy "profiles read" on public.profiles for select to authenticated using(true);
create policy "own profile insert" on public.profiles for insert to authenticated with check(auth.uid()=id and role='player');
create policy "own profile update" on public.profiles for update to authenticated using(auth.uid()=id) with check(auth.uid()=id and role='player');
create policy "admin profiles update" on public.profiles for update to authenticated using(public.is_admin()) with check(public.is_admin());

create policy "players public read" on public.players for select using(true);
create policy "admin player insert" on public.players for insert to authenticated with check(public.is_admin());
create policy "admin player update" on public.players for update to authenticated using(public.is_admin()) with check(public.is_admin());
create policy "admin player delete" on public.players for delete to authenticated using(public.is_admin());

create policy "seasons public read" on public.seasons for select using(true);
create policy "admin seasons write" on public.seasons for all to authenticated using(public.is_admin()) with check(public.is_admin());
create policy "competitions public read" on public.competitions for select using(true);
create policy "admin competitions write" on public.competitions for all to authenticated using(public.is_admin()) with check(public.is_admin());
create policy "entries public read" on public.competition_entries for select using(true);
create policy "entries own insert" on public.competition_entries for insert to authenticated with check(public.is_admin() or exists(select 1 from public.players p join public.profiles pr on pr.id=auth.uid() where p.profile_id=pr.id and p.id=player_id));
create policy "admin entries update" on public.competition_entries for all to authenticated using(public.is_admin()) with check(public.is_admin());
create policy "fixtures public read" on public.fixtures for select using(true);
create policy "admin fixtures write" on public.fixtures for all to authenticated using(public.is_admin()) with check(public.is_admin());
create policy "submissions own/admin read" on public.match_submissions for select to authenticated using(submitted_by=auth.uid() or public.is_admin());
create policy "submission insert own" on public.match_submissions for insert to authenticated with check(submitted_by=auth.uid() and status='pending');
create policy "admin submission update" on public.match_submissions for update to authenticated using(public.is_admin()) with check(public.is_admin());
create policy "approved public read" on public.approved_matches for select using(true);
create policy "dispute own/admin read" on public.disputes for select to authenticated using(raised_by=auth.uid() or public.is_admin());
create policy "dispute own insert" on public.disputes for insert to authenticated with check(raised_by=auth.uid());
create policy "admin dispute update" on public.disputes for update to authenticated using(public.is_admin()) with check(public.is_admin());
create policy "own notifications" on public.notifications for select to authenticated using(user_id=auth.uid() or public.is_admin());
create policy "own notifications update" on public.notifications for update to authenticated using(user_id=auth.uid()) with check(user_id=auth.uid());
create policy "admin notifications insert" on public.notifications for insert to authenticated with check(public.is_admin());
create policy "own payments" on public.payments for select to authenticated using(user_id=auth.uid() or public.is_admin());
create policy "admin payments write" on public.payments for all to authenticated using(public.is_admin()) with check(public.is_admin());

create or replace function public.create_competition(p_name text,p_season_id uuid,p_format text,p_entry_fee numeric default 0,p_description text default null) returns uuid language plpgsql security definer set search_path=public as $$
declare x uuid; begin if not public.is_admin() then raise exception 'Admin access required'; end if;
 insert into competitions(name,season_id,format,entry_fee,description) values(p_name,p_season_id,p_format,greatest(p_entry_fee,0),p_description) returning id into x; return x; end $$;
grant execute on function public.create_competition(text,uuid,text,numeric,text) to authenticated;

create or replace function public.create_league_fixtures(p_competition_id uuid) returns integer language plpgsql security definer set search_path=public as $$
declare a record; b record; n integer:=0; begin if not public.is_admin() then raise exception 'Admin access required'; end if;
 if not exists(select 1 from competitions where id=p_competition_id and format='league') then raise exception 'Competition must be a league'; end if;
 delete from fixtures where competition_id=p_competition_id and status='scheduled';
 for a in select player_id from competition_entries where competition_id=p_competition_id and status in('registered','qualified') order by coalesce(seed,999999),player_id loop
   for b in select player_id from competition_entries where competition_id=p_competition_id and status in('registered','qualified') and player_id>a.player_id order by coalesce(seed,999999),player_id loop
     n:=n+1; insert into fixtures(competition_id,round_name,match_number,home_player_id,away_player_id) values(p_competition_id,'League',n,a.player_id,b.player_id);
     n:=n+1; insert into fixtures(competition_id,round_name,match_number,home_player_id,away_player_id) values(p_competition_id,'League',n,b.player_id,a.player_id);
   end loop;
 end loop;
 update competitions set status='active' where id=p_competition_id; return n; end $$;
grant execute on function public.create_league_fixtures(uuid) to authenticated;

create or replace function public.review_match_submission(submission_id uuid,decision text) returns void language plpgsql security definer set search_path=public as $$
declare s match_submissions%rowtype; f fixtures%rowtype; h text; a text; begin
 if not public.is_admin() then raise exception 'Admin access required'; end if;
 if decision not in('approved','rejected') then raise exception 'Invalid decision'; end if;
 select * into s from match_submissions where id=submission_id for update;
 if not found or s.status<>'pending' then raise exception 'Submission not found or already reviewed'; end if;
 select * into f from fixtures where id=s.fixture_id for update; if not found then raise exception 'Fixture not found'; end if;
 update match_submissions set status=decision,reviewed_by=auth.uid(),reviewed_at=now() where id=s.id;
 if decision='approved' then
   if exists(select 1 from approved_matches where fixture_id=f.id) then raise exception 'Fixture already has an approved result'; end if;
   select name into h from players where id=f.home_player_id; select name into a from players where id=f.away_player_id;
   update fixtures set status='completed',home_score=s.home_score,away_score=s.away_score,winner_player_id=case when s.home_score>s.away_score then f.home_player_id when s.away_score>s.home_score then f.away_player_id else null end where id=f.id;
   insert into approved_matches(submission_id,fixture_id,competition_id,home_player_id,away_player_id,home_score,away_score,home_name,away_name,approved_by) values(s.id,f.id,f.competition_id,f.home_player_id,f.away_player_id,s.home_score,s.away_score,h,a,auth.uid());
   update profiles set elo_rating=greatest(0,elo_rating+case when s.home_score=s.away_score then 0 else 10 end) where id in(select profile_id from players where id in(f.home_player_id,f.away_player_id));
 end if;
end $$;
grant execute on function public.review_match_submission(uuid,text) to authenticated;

create or replace view public.league_standings as
select p.id player_id,p.name,p.status,
 coalesce(sum(case when m.home_player_id=p.id or m.away_player_id=p.id then 1 else 0 end),0)::int played,
 coalesce(sum(case when (m.home_player_id=p.id and m.home_score>m.away_score) or (m.away_player_id=p.id and m.away_score>m.home_score) then 1 else 0 end),0)::int wins,
 coalesce(sum(case when m.home_score=m.away_score and (m.home_player_id=p.id or m.away_player_id=p.id) then 1 else 0 end),0)::int draws,
 coalesce(sum(case when (m.home_player_id=p.id and m.home_score<m.away_score) or (m.away_player_id=p.id and m.away_score<m.home_score) then 1 else 0 end),0)::int losses,
 coalesce(sum(case when m.home_player_id=p.id then m.home_score when m.away_player_id=p.id then m.away_score else 0 end),0)::int gf,
 coalesce(sum(case when m.home_player_id=p.id then m.away_score when m.away_player_id=p.id then m.home_score else 0 end),0)::int ga,
 coalesce(sum(case when (m.home_player_id=p.id and m.home_score>m.away_score) or (m.away_player_id=p.id and m.away_score>m.home_score) then 3 when m.home_score=m.away_score and (m.home_player_id=p.id or m.away_player_id=p.id) then 1 else 0 end),0)::int points
from players p left join approved_matches m on m.home_player_id=p.id or m.away_player_id=p.id group by p.id,p.name,p.status;

insert into public.players(name) values('efootballwaina'),('Simoprince'),('Geniusj12'),('Young_power10'),('TafJosh12345'),('Romeo in trouble'),('Dawoods'),('SaintYng'),('BEING MWISE') on conflict(name) do nothing;
insert into public.seasons(name,status,starts_at) values('Kings Season 1','active',now()) on conflict(name) do nothing;
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types) values('match-screenshots','match-screenshots',true,8388608,array['image/png','image/jpeg','image/webp']) on conflict(id) do nothing;
create policy "screenshot upload own" on storage.objects for insert to authenticated with check(bucket_id='match-screenshots' and (storage.foldername(name))[1]=auth.uid()::text);
create policy "screenshot public read" on storage.objects for select using(bucket_id='match-screenshots');

-- After registering your account, run:
-- select id,email from auth.users;
-- update public.profiles set role='admin' where id='YOUR-USER-UUID';
