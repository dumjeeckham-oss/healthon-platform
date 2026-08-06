-- Phase 4 Admin CMS: audit_log
CREATE TABLE IF NOT EXISTS public.audit_log (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id    UUID NOT NULL,
  admin_name  TEXT NOT NULL,
  action      TEXT NOT NULL,
  target_type TEXT NOT NULL,
  target_id   TEXT,
  target_name TEXT,
  changes     JSONB,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
