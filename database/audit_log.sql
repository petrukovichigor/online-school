-- audit log. Every INSERT / UPDATE / DELETE on the main tables is recorded in audit_log.
-- Run once, after scheme.sql and seed.sql (so the seed rows are not logged).
BEGIN;

CREATE TABLE audit_log (
    log_id      BIGSERIAL    PRIMARY KEY,
    changed_at  TIMESTAMP  NOT NULL DEFAULT now(),
    table_name  VARCHAR(50)  NOT NULL,
    action      VARCHAR(6)   NOT NULL,
    actor       TEXT,        -- student:<id> | teacher:<id> | app:anonymous | external:<application_name> (<db user>)
    old_data    JSONB,       -- row before the change (UPDATE, DELETE)
    new_data    JSONB,       -- row after the change (INSERT, UPDATE)

    CONSTRAINT audit_action_valid CHECK (action IN ('INSERT', 'UPDATE', 'DELETE'))
);

CREATE INDEX audit_log_changed_at_idx ON audit_log (changed_at DESC);
CREATE INDEX audit_log_table_idx      ON audit_log (table_name, changed_at DESC);

CREATE OR REPLACE FUNCTION audit_row_change() RETURNS trigger AS $$
DECLARE
    old_j   JSONB;
    new_j   JSONB;
    v_actor TEXT;
BEGIN
    -- password hashes and salaries never go into the log
    IF TG_OP IN ('UPDATE', 'DELETE') THEN
        old_j := to_jsonb(OLD) - ARRAY['password_hash', 'salary'];
    END IF;
    IF TG_OP IN ('INSERT', 'UPDATE') THEN
        new_j := to_jsonb(NEW) - ARRAY['password_hash', 'salary'];
    END IF;

    -- an UPDATE that changed nothing visible is not worth a log row
    IF TG_OP = 'UPDATE' AND old_j = new_j THEN
        RETURN NULL;
    END IF;

    -- the app sets app.actor for every write; if it is empty, the change came from outside the app
    v_actor := NULLIF(current_setting('app.actor', true), '');
    IF v_actor IS NULL THEN
        v_actor := 'external:' || COALESCE(NULLIF(current_setting('application_name', true), ''), 'unknown')
                   || ' (' || session_user || ')';
    END IF;

    INSERT INTO audit_log (table_name, action, actor, old_data, new_data)
    VALUES (TG_TABLE_NAME, TG_OP, v_actor, old_j, new_j);

    RETURN NULL;  -- AFTER trigger: the return value is ignored
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
    t TEXT;
BEGIN
    FOREACH t IN ARRAY ARRAY['students', 'teachers', 'categories', 'courses', 'lessons',
                             'homeworks', 'course_subscriptions', 'payments', 'homework_submissions']
    LOOP
        EXECUTE format(
            'CREATE TRIGGER %I AFTER INSERT OR UPDATE OR DELETE ON %I
             FOR EACH ROW EXECUTE FUNCTION audit_row_change()', t || '_audit', t);
    END LOOP;
END $$;

COMMIT;

-- Useful queries:
-- latest changes:        SELECT changed_at, table_name, action, actor, new_data FROM audit_log ORDER BY changed_at DESC LIMIT 50;
-- who touched payments:  SELECT changed_at, action, actor, old_data, new_data FROM audit_log WHERE table_name = 'payments' ORDER BY changed_at DESC;
-- changes from the IDE:  SELECT * FROM audit_log WHERE actor LIKE 'external:%' ORDER BY changed_at DESC;
-- new enrollments today: SELECT * FROM audit_log WHERE table_name = 'course_subscriptions' AND action = 'INSERT' AND changed_at::date = current_date;
