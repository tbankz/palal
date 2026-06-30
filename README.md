# Palal

A static frontend seeded from `Palal25.1 copy.html` with a Netlify Functions placeholder.

## Setup

1. Install dependencies:
   ```bash
   cd /Users/Tae/Downloads/Palal
   npm install
   ```

2. Serve the static site locally:
   ```bash
   npm run start
   ```

3. Run local Netlify development:
   ```bash
   npm run dev
   ```

4. Build for deployment:
   ```bash
   npm run build
   ```

## Supabase + Netlify setup

### 1. Create the Supabase project

- Go to https://app.supabase.com and create a new project.
- Choose a database password and region.
- Wait for the database to initialize.

### 2. Get the Supabase database URL

- In the Supabase dashboard, open `Settings` > `Database` > `Connection string`.
- Copy the `postgresql://...` URL.

### 3. Configure Netlify environment variables

- In Netlify, open your site settings.
- Go to `Build & deploy` > `Environment` > `Environment variables`.
- Add one variable:
  - `SUPABASE_DB_URL` = your Supabase connection string

This tells Netlify to run the migration against Supabase during build.

### 4. Reset Supabase for a fresh start

If you already created tables manually, drop them before the first migration. In Supabase SQL editor, run:

```sql
DROP TABLE IF EXISTS public.prayer_feed CASCADE;
DROP TABLE IF EXISTS public.map_intercessions CASCADE;
DROP TABLE IF EXISTS public.user_data CASCADE;
DROP TABLE IF EXISTS public.prayer_reactions CASCADE;
DROP TABLE IF EXISTS public.circle_members CASCADE;
DROP TABLE IF EXISTS public.prayer_circles CASCADE;
DROP TABLE IF EXISTS public.comments CASCADE;
DROP TABLE IF EXISTS public.prayers CASCADE;
DROP TABLE IF EXISTS public.user_profiles CASCADE;
```

Then deploy. The build will recreate the schema from `schema.sql`.

### 5. Verify the Netlify build path

Netlify uses `npm run build` from `package.json`. That command now executes:

- `node ./scripts/migrate.js --build`

During Netlify build:
- if `SUPABASE_DB_URL` is set, it runs the remote migration against Supabase
- otherwise it skips schema migration for now so the build can complete

### 6. Manual Supabase migration test

If you want to test migration locally before deployment, export `SUPABASE_DB_URL` and run:

```bash
export SUPABASE_DB_URL="postgresql://..."
npm run migrate:remote
```

## Local workflow

- `npm run start` — serves the static site from `public`.
- `npm run dev` — starts the local Netlify dev server.
- `npm run migrate:local` — currently a no-op while local SQLite support is paused.
- `npm run migrate:remote` — runs the Supabase migration when `SUPABASE_DB_URL` is set.

## Project structure

- `public/index.html` — frontend HTML copied from `Palal25.1 copy.html`
- `netlify/functions/placeholder.js` — backend placeholder function
- `netlify.toml` — Netlify build settings and API route redirect
