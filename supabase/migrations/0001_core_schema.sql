-- SIDCA core schema v1
-- Sistema de Inteligencia y Defensa Contra Amenazas

create extension if not exists pgcrypto;

create table if not exists public.sources (
    id uuid primary key default gen_random_uuid(),
    name text not null unique,
    source_type text not null check (source_type in (
        'feed','api','community','analyst','automated_engine','partner','internal','other'
    )),
    trust_score smallint not null default 50 check (trust_score between 0 and 100),
    active boolean not null default true,
    metadata jsonb not null default '{}'::jsonb,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists public.threats (
    id uuid primary key default gen_random_uuid(),
    slug text not null unique,
    name text not null,
    category text not null,
    description text,
    severity smallint not null default 50 check (severity between 0 and 100),
    metadata jsonb not null default '{}'::jsonb,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists public.indicators (
    id uuid primary key default gen_random_uuid(),
    indicator_type text not null check (indicator_type in (
        'url','domain','ip','phone','email','file_hash','app_package','apk_hash',
        'sms_sender','crypto_wallet','other'
    )),
    value text not null,
    normalized_value text not null,
    value_hash text not null,
    status text not null default 'unknown' check (status in (
        'unknown','benign','suspicious','malicious','inactive','disputed'
    )),
    first_seen_at timestamptz,
    last_seen_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique (indicator_type, normalized_value)
);

create index if not exists idx_indicators_type_hash
    on public.indicators(indicator_type, value_hash);
create index if not exists idx_indicators_status
    on public.indicators(status);
create index if not exists idx_indicators_last_seen
    on public.indicators(last_seen_at desc);

create table if not exists public.observations (
    id uuid primary key default gen_random_uuid(),
    indicator_id uuid not null references public.indicators(id) on delete cascade,
    source_id uuid not null references public.sources(id) on delete restrict,
    observed_at timestamptz not null default now(),
    verdict text not null default 'unknown' check (verdict in (
        'unknown','benign','suspicious','malicious'
    )),
    confidence_score smallint not null default 0 check (confidence_score between 0 and 100),
    external_reference text,
    raw_payload jsonb,
    evidence jsonb not null default '{}'::jsonb,
    created_at timestamptz not null default now()
);

create index if not exists idx_observations_indicator_time
    on public.observations(indicator_id, observed_at desc);
create index if not exists idx_observations_source_time
    on public.observations(source_id, observed_at desc);

create table if not exists public.indicator_threats (
    indicator_id uuid not null references public.indicators(id) on delete cascade,
    threat_id uuid not null references public.threats(id) on delete cascade,
    confidence_score smallint not null default 0 check (confidence_score between 0 and 100),
    first_linked_at timestamptz not null default now(),
    last_confirmed_at timestamptz,
    metadata jsonb not null default '{}'::jsonb,
    primary key (indicator_id, threat_id)
);

create table if not exists public.campaigns (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    description text,
    status text not null default 'suspected' check (status in (
        'suspected','active','inactive','archived'
    )),
    first_seen_at timestamptz,
    last_seen_at timestamptz,
    metadata jsonb not null default '{}'::jsonb,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists public.campaign_indicators (
    campaign_id uuid not null references public.campaigns(id) on delete cascade,
    indicator_id uuid not null references public.indicators(id) on delete cascade,
    confidence_score smallint not null default 0 check (confidence_score between 0 and 100),
    created_at timestamptz not null default now(),
    primary key (campaign_id, indicator_id)
);

create table if not exists public.user_reports (
    id uuid primary key default gen_random_uuid(),
    reporter_id uuid,
    indicator_id uuid references public.indicators(id) on delete set null,
    report_type text not null,
    category text,
    description text,
    occurred_at timestamptz,
    status text not null default 'pending' check (status in (
        'pending','accepted','rejected','duplicate','needs_review'
    )),
    idempotency_key text,
    metadata jsonb not null default '{}'::jsonb,
    created_at timestamptz not null default now(),
    reviewed_at timestamptz,
    unique (idempotency_key)
);

create index if not exists idx_user_reports_indicator
    on public.user_reports(indicator_id, created_at desc);
create index if not exists idx_user_reports_status
    on public.user_reports(status, created_at desc);

create table if not exists public.report_evidence (
    id uuid primary key default gen_random_uuid(),
    report_id uuid not null references public.user_reports(id) on delete cascade,
    evidence_type text not null,
    storage_path text,
    content_hash text,
    metadata jsonb not null default '{}'::jsonb,
    created_at timestamptz not null default now()
);

create table if not exists public.reporter_reputation (
    reporter_id uuid primary key,
    reports_total integer not null default 0 check (reports_total >= 0),
    reports_confirmed integer not null default 0 check (reports_confirmed >= 0),
    reports_rejected integer not null default 0 check (reports_rejected >= 0),
    trust_score smallint not null default 50 check (trust_score between 0 and 100),
    updated_at timestamptz not null default now()
);

create table if not exists public.risk_assessments (
    id uuid primary key default gen_random_uuid(),
    indicator_id uuid not null references public.indicators(id) on delete cascade,
    risk_score smallint not null check (risk_score between 0 and 100),
    confidence_score smallint not null check (confidence_score between 0 and 100),
    verdict text not null check (verdict in (
        'unknown','benign','suspicious','malicious','disputed'
    )),
    reasons jsonb not null default '[]'::jsonb,
    engine_version text not null,
    created_at timestamptz not null default now()
);

create index if not exists idx_risk_assessments_indicator_time
    on public.risk_assessments(indicator_id, created_at desc);

create table if not exists public.protection_rules (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    threat_id uuid references public.threats(id) on delete set null,
    rule_type text not null,
    priority integer not null default 100,
    enabled boolean not null default true,
    conditions jsonb not null default '{}'::jsonb,
    actions jsonb not null default '[]'::jsonb,
    valid_from timestamptz,
    valid_until timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- Generic updated_at helper.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
    new.updated_at = now();
    return new;
end;
$$;

create trigger trg_sources_updated_at
before update on public.sources
for each row execute function public.set_updated_at();

create trigger trg_threats_updated_at
before update on public.threats
for each row execute function public.set_updated_at();

create trigger trg_indicators_updated_at
before update on public.indicators
for each row execute function public.set_updated_at();

create trigger trg_campaigns_updated_at
before update on public.campaigns
for each row execute function public.set_updated_at();

create trigger trg_protection_rules_updated_at
before update on public.protection_rules
for each row execute function public.set_updated_at();

-- RLS is enabled now; policies are intentionally added in a later migration
-- once service identities and admin/user roles are defined.
alter table public.sources enable row level security;
alter table public.threats enable row level security;
alter table public.indicators enable row level security;
alter table public.observations enable row level security;
alter table public.indicator_threats enable row level security;
alter table public.campaigns enable row level security;
alter table public.campaign_indicators enable row level security;
alter table public.user_reports enable row level security;
alter table public.report_evidence enable row level security;
alter table public.reporter_reputation enable row level security;
alter table public.risk_assessments enable row level security;
alter table public.protection_rules enable row level security;
