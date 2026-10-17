# eFootball Kings Online v2

A Supabase-powered eFootball league and tournament platform.

## What's new in v2
- Player dashboard and profiles
- Seasons
- Competitions with league/group/knockout formats
- Competition entries
- Automatic round-robin fixture generation
- Fixtures and match reporting
- League standings
- Player rankings/ELO-ready fields
- Match approval and disputes
- Notifications
- Admin dashboard
- Player suspension/status controls
- Competition lifecycle controls
- Public results and recent activity
- Screenshot evidence storage

## Setup
1. Create a Supabase project.
2. Open Supabase SQL Editor and run `supabase-schema.sql` in one query.
3. Replace the values in `config.js` with your Supabase project URL and anon public key.
4. Register your first account.
5. In Supabase SQL Editor, promote that account to admin:

```sql
select id, email from auth.users;
update public.profiles set role='admin' where id='YOUR-USER-UUID';
```

6. Refresh the application.

## Local use
This is a static app. You can serve the folder with any static server, for example:

`python -m http.server 8080`

Then open `http://localhost:8080`.

## Deployment
The folder can be deployed to Vercel as a static site. No Node build step is required.

## Security notes
- Never put a Supabase service-role key in `config.js`.
- Only the anon/public key belongs in the browser.
- Admin actions are protected by database policies/functions.
- Match screenshots are stored in the `match-screenshots` bucket.
