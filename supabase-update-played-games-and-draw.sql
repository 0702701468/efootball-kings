-- eFootball Kings: played games and draws update
-- Run in Supabase Dashboard > SQL Editor > New query.
-- Assumes supabase-schema.sql has already been run.

create or replace view public.league_standings
with (security_invoker = true)
as
with player_stats as (
  select
    p.id as player_id,
    p.name as player_name,
    count(m.id)::integer as played,
    count(m.id) filter (
      where (m.home_player_id = p.id and m.home_score > m.away_score)
         or (m.away_player_id = p.id and m.away_score > m.home_score)
    )::integer as wins,
    count(m.id) filter (where m.home_score = m.away_score)::integer as draws,
    count(m.id) filter (
      where (m.home_player_id = p.id and m.home_score < m.away_score)
         or (m.away_player_id = p.id and m.away_score < m.home_score)
    )::integer as losses,
    coalesce(sum(case when m.home_player_id = p.id then m.home_score
                      when m.away_player_id = p.id then m.away_score end),0)::integer as goals_for,
    coalesce(sum(case when m.home_player_id = p.id then m.away_score
                      when m.away_player_id = p.id then m.home_score end),0)::integer as goals_against
  from public.players p
  left join public.approved_matches m
    on m.home_player_id = p.id or m.away_player_id = p.id
  group by p.id, p.name
)
select player_id, player_name, played, wins, draws, losses, goals_for, goals_against,
       goals_for - goals_against as goal_difference,
       wins * 3 + draws as points
from player_stats;

grant select on public.league_standings to anon, authenticated;

select player_name, played, wins, draws, losses, goals_for, goals_against,
       goal_difference, points
from public.league_standings
order by points desc, goal_difference desc, goals_for desc, player_name asc;
