-- HR Acknowledgment Portal — Supabase Schema
-- Run this entire script in Supabase SQL Editor (one-time setup)

-- ===== EMPLOYEES =====
create table if not exists employees (
  id uuid primary key default gen_random_uuid(),
  first_name text not null,
  last_name text not null,
  preferred_name text,
  email text not null unique,
  department text,
  job_level text,
  employment_type text,
  supervisor_name text,
  supervisor_email text,
  folder_name text generated always as (
    last_name || ', ' || first_name ||
    case when preferred_name is not null and preferred_name <> '' then ' (' || preferred_name || ')' else '' end
  ) stored,
  created_at timestamptz default now()
);

-- ===== FORMS =====
create table if not exists forms (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  pdf_data text,                     -- base64 PDF (kept small; large PDFs should use Storage)
  signature_markers jsonb default '[]'::jsonb,  -- [{page, x, y, label}]
  due_date date,
  required_levels text[],            -- e.g. {'IC','Manager'}
  required_departments text[],       -- e.g. {'Engineering','HR'}
  attestation_text text default 'By signing below, I acknowledge I have read and understand this document. I agree that my electronic signature is the legal equivalent of my handwritten signature, in accordance with the ESIGN Act and UETA.',
  active boolean default true,
  created_at timestamptz default now()
);

-- ===== SIGNATURES =====
create table if not exists signatures (
  id uuid primary key default gen_random_uuid(),
  employee_id uuid references employees(id) on delete cascade,
  form_id uuid references forms(id) on delete cascade,
  status text default 'pending',     -- pending | partial | completed
  signed_at timestamptz,
  ip_address text,
  user_agent text,
  signature_data jsonb,              -- [{marker_id, drawn_signature_base64, typed_name, timestamp, intent_confirmed}]
  esign_consent_at timestamptz,
  record_id text unique default ('REC-' || substr(md5(random()::text), 1, 10)),
  unique (employee_id, form_id)
);

-- ===== AUDIT LOG =====
create table if not exists audit_log (
  id uuid primary key default gen_random_uuid(),
  employee_id uuid references employees(id) on delete set null,
  form_id uuid references forms(id) on delete set null,
  event_type text not null,          -- consent_given | identity_verified | form_opened | page_viewed | signature_placed | form_completed | session_complete | reminder_sent
  event_data jsonb,
  ip_address text,
  user_agent text,
  created_at timestamptz default now()
);

-- ===== REMINDERS =====
create table if not exists reminders (
  id uuid primary key default gen_random_uuid(),
  employee_id uuid references employees(id) on delete cascade,
  form_id uuid references forms(id) on delete cascade,
  reminder_type text not null,       -- day_minus_7 | day_minus_3 | day_minus_1 | supervisor_escalation
  scheduled_for timestamptz not null,
  sent_at timestamptz,
  channel text,                      -- email | teams
  status text default 'scheduled',   -- scheduled | sent | skipped | failed
  created_at timestamptz default now()
);

-- ===== INDEXES =====
create index if not exists idx_signatures_employee on signatures(employee_id);
create index if not exists idx_signatures_form on signatures(form_id);
create index if not exists idx_signatures_status on signatures(status);
create index if not exists idx_audit_employee on audit_log(employee_id);
create index if not exists idx_audit_created on audit_log(created_at desc);
create index if not exists idx_reminders_scheduled on reminders(scheduled_for);
create index if not exists idx_employees_dept on employees(department);

-- ===== ROW LEVEL SECURITY =====
-- For initial setup with shared anon key, we keep RLS off so the 4 HR users can read/write.
-- Once you're ready to lock it down, enable RLS and add policies tied to authenticated users.
alter table employees disable row level security;
alter table forms disable row level security;
alter table signatures disable row level security;
alter table audit_log disable row level security;
alter table reminders disable row level security;
