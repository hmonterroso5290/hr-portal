# HR Acknowledgment Portal — GitHub Pages Deployment Guide

## What you have in this folder
- `index.html` — The HR portal (single file, works in any browser)
- `supabase-schema.sql` — Database setup script (run once in Supabase)
- `DEPLOY-README.md` — This guide

## Architecture
- **GitHub Pages** hosts the portal (free, reliable)
- **Supabase** stores all data — employees, forms, signatures, audit log (free)
- All 4 HR team members visit the same URL → see the same live data

---

## Step 1 — Create a free GitHub account (2 minutes)

1. Go to **https://github.com/signup**
2. Enter your email (you can use your work email or personal)
3. Create a password
4. Pick a username — something like `helen-newegg` or `helenmonterroso`
5. Verify your email (GitHub sends a confirmation)
6. When asked about your plan, pick **Free**
7. You can skip the "tell us about yourself" questions

---

## Step 2 — Create the repository and upload the portal (3 minutes)

1. Once logged in, click the **+** in the top-right → **New repository**
2. Repository name: `hr-portal`
3. Set it to **Public** (required for free GitHub Pages — your code is public but your Supabase data is not)
4. Check **Add a README file**
5. Click **Create repository**

Now upload the portal:

6. On the repo page, click **Add file → Upload files**
7. Drag `index.html` from your folder onto the page (you can also drag `supabase-schema.sql` and `DEPLOY-README.md` if you want them in the repo)
8. Scroll down → click **Commit changes**

---

## Step 3 — Turn on GitHub Pages (1 minute)

1. In your repo, click **Settings** (top of the page)
2. In the left sidebar, click **Pages**
3. Under **Source**, pick **Deploy from a branch**
4. Under **Branch**, pick **main** and **/ (root)** → click **Save**
5. Wait ~1 minute — GitHub will show: "Your site is live at `https://YOUR-USERNAME.github.io/hr-portal/`"

That URL is what you'll share with your HR team. **Save it.**

If you open it now, the portal loads but shows "Not configured — add Supabase keys" in the top-right. That's expected — we set up Supabase next.

---

## Step 4 — Set up Supabase (5 minutes)

### 4a. Create the project
1. Go to **https://supabase.com** → click **Sign up** (free)
2. Click **New project**
3. Name it `hr-portal`
4. Set a database password (save it somewhere — you won't need it for the portal, but Supabase requires one)
5. Region: pick **West US (North California)**
6. Click **Create new project** → wait ~60 seconds

### 4b. Run the database schema
1. In Supabase, click **SQL Editor** (left sidebar) → **+ New query**
2. Open `supabase-schema.sql` from this folder, copy the entire contents, paste into the editor
3. Click **Run** → should say "Success. No rows returned."

### 4c. Copy your keys
1. In Supabase, click **Settings** (gear icon) → **API**
2. You'll see two values:
   - **Project URL** (looks like `https://abcdefgh.supabase.co`)
   - **anon public** key (long string starting with `eyJ...`)
3. Keep this tab open

---

## Step 5 — Wire your keys into index.html (2 minutes)

1. Go back to your GitHub repo → click `index.html`
2. Click the pencil icon (top-right) to edit
3. Find these two lines near the top of the script section:
   ```
   const SUPABASE_URL = "YOUR_SUPABASE_URL";
   const SUPABASE_ANON_KEY = "YOUR_SUPABASE_ANON_KEY";
   ```
4. Replace the placeholder text with your actual values (keep the quotes):
   ```
   const SUPABASE_URL = "https://abcdefgh.supabase.co";
   const SUPABASE_ANON_KEY = "eyJhbGciOi...";
   ```
5. Scroll down → click **Commit changes**

GitHub Pages will redeploy automatically (~30 seconds).

---

## Step 6 — Test it (3 minutes)

1. Open your live URL: `https://YOUR-USERNAME.github.io/hr-portal/`
2. **Top-right corner**: the sync dot should be **green** and say "Live"
   - If red → double-check your Supabase keys in index.html
3. Try the full flow:
   - **Employees** → add one manually or upload a sample Excel
   - **Forms** → click **+ New Form**, upload a test PDF, click to drop signature markers, save
   - **Sign Portal** → use **Demo Mode** to walk through signing as that employee
   - **Audit Log** → confirm every event was logged
4. **Share the URL with your 4 HR team members** — they all see the same live data

---

## Notes

- All 4 HR team members visit the same URL and see the same employees, forms, signatures in real time
- The `anon` key in `index.html` is safe to be public — it only grants what your Supabase RLS policies allow
- For very large PDFs (>1 MB each), we should switch to Supabase Storage later — flag me when you're ready
- M365 integration (auto-send reminders via Outlook + Teams, mirror signed forms to SharePoint/OneDrive) is a separate next step — the data model is ready

## Troubleshooting
- **Sync dot is red** — Most likely a typo in your Supabase URL or anon key. Open browser dev tools (F12) → Console tab for the exact error.
- **PDFs don't render** — Use Chrome or Edge (Safari sometimes has issues with PDF.js).
- **Excel import skips rows** — Column headers must be: First Name, Last Name, Email, Department, Supervisor, Supervisor Email (case-sensitive on first letter; spelling matters).

Need help on any step? Just tell me where you are and what you're seeing.
