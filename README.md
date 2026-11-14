# TAPREVIEW PRO — RAVKIRKESH

A responsive multi-shop QR + NFC landing-page platform built with React, TypeScript, Vite, Tailwind CSS and Supabase.

## Included

- Supabase email/password administrator sign-in (no public sign-up screen)
- Multi-shop create, edit, delete and search
- Per-shop public landing page at `/shop/<slug>`
- Google Review, WhatsApp, Instagram, Facebook, YouTube, Website and unlimited custom links
- Per-shop QR code export as PNG and SVG
- NFC URL copy, Web NFC write attempt where supported, and manual Android NFC app instructions
- 8 × 6 inch landscape acrylic stand artwork export as PDF and high-resolution PNG
- Private customer records for admins
- SQL schema with Row Level Security policies
- Vercel-ready deployment configuration

## Requirements

- Node.js 20 or newer
- A Supabase project
- A modern browser. Web NFC is supported only on compatible Android browsers/devices and requires a secure context (HTTPS).

## 1. Install and run locally

```bash
npm install
cp .env.example .env
npm run dev
```

Open the local URL printed by Vite. The app will show a configuration message on sign-in until the Supabase environment values are filled in.

## 2. Configure Supabase

1. Create a project at https://supabase.com/dashboard.
2. Open **Project Settings → API** and copy the Project URL and anon/publishable key.
3. Put them in `.env`:

```env
VITE_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
VITE_SUPABASE_ANON_KEY=YOUR_ANON_OR_PUBLISHABLE_KEY
```

4. Open **SQL Editor**, paste and run `supabase/schema.sql`.
5. Open **Authentication → Users** and create the administrator user. Disable public sign-ups in Authentication settings.
6. Copy the admin user's UUID and run this in SQL Editor:

```sql
insert into public.admin_users (user_id)
values ('PASTE-AUTH-USER-UUID-HERE');
```

Only allow-listed admin UUIDs can create, update or delete shops and customer records. Do not expose the Supabase service-role key in this frontend project. The anon/publishable key is designed to be used with the RLS policies in this schema.

## 3. Build

```bash
npm run build
npm run preview
```

The production files are generated in `dist/`.

## 4. Deploy free-tier to Vercel

1. Push this project to a Git repository (keep `.env` out of Git).
2. Import the repository at https://vercel.com/new.
3. Set the framework preset to **Vite** (normally detected automatically).
4. Add `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` in Vercel Project → Settings → Environment Variables.
5. Deploy. Add a rewrite so client-side routes resolve: this project includes `vercel.json`.
6. Open the deployed URL and sign in. Create one test shop and test its `/shop/<slug>` URL in a private browser window.

A custom domain can be connected later in Vercel Project → Settings → Domains. If you change the production domain, create fresh print QR codes after the final URL is set; QR codes contain the absolute site URL.

## 5. QR, print and NFC notes

- QR codes point to the shop's own public landing page, not directly to an external social link.
- PDF export uses an exact 8 × 6 inch landscape page. Print at 100% / actual size, not “fit to page”. Always scan a physical proof before ordering bulk acrylic stands.
- PNG is rendered at high scale from the print artwork. SVG export is available for the QR code itself.
- Web NFC is browser/device dependent. It requires HTTPS, user interaction, NFC hardware and browser permission. The app only reports success after the browser's write promise resolves; verify the tag with another device.
- For unsupported devices, copy the shop URL and use a reputable NFC tag-writing application on Android.

## 6. Important deployment checks

Before using this for real customer-facing business:

- Confirm RLS policies in Supabase and ensure only intended admin user UUIDs exist in `admin_users`.
- Test public shop reads and private customer records using both signed-out and signed-in sessions.
- Confirm that every external URL is correct and starts with `https://` (or an intended `http://` URL).
- Add your final deployment domain before producing QR/NFC tags for customers.
- Back up your Supabase database regularly.

## Current scope / transparent limitations

- Shop logo is currently entered as a public image URL. The SQL schema creates a `shop-logos` storage bucket and access policies for future in-app upload integration; a dedicated file-picker upload flow is not wired into this initial source package.
- Customer management currently supports adding and viewing customer records; edit/delete customer controls are not included in this first version.
- The dashboard's shop count and customer count are live database counts from fetched rows, not analytics events or review counts. Google does not provide a review count from the URL alone.
- No real review is submitted by this app. Customers are directed to the shop's original Google Review or social URL.
- Supabase, hosting, domain, NFC hardware and real-world print quality cannot be validated until configured on your accounts/devices.
