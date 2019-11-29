ALTER TABLE ticket
    ALTER COLUMN bts_url TYPE VARCHAR(1024),
    ALTER COLUMN bts_project TYPE VARCHAR(1024),
    ALTER COLUMN url TYPE VARCHAR(1024),
    ALTER COLUMN ticket_id TYPE VARCHAR(256);

ALTER TABLE test_item
    ALTER COLUMN unique_id TYPE VARCHAR(1024),
    ALTER COLUMN code_ref TYPE VARCHAR;

DROP INDEX IF EXISTS log_attach_id_idx;
CREATE INDEX IF NOT EXISTS log_attach_id_idx
    ON log (attachment_id);

DROP INDEX IF EXISTS log_launch_id_idx;
CREATE INDEX IF NOT EXISTS log_launch_id_idx
    ON log (launch_id);

DROP INDEX IF EXISTS activity_creation_date_idx;
CREATE INDEX IF NOT EXISTS activity_creation_date_idx
    ON activity (creation_date);

DROP INDEX IF EXISTS activity_object_idx;
CREATE INDEX IF NOT EXISTS activity_object_idx
    ON activity (object_id);

CREATE MATERIALIZED VIEW project_info AS
(
SELECT count(DISTINCT public.project_user.user_id)       AS usersquantity,
       count(DISTINCT CASE
                          WHEN (public.launch.mode = 'DEFAULT'::public."launch_mode_enum" AND
                                public.launch.status <> 'IN_PROGRESS'::public."status_enum")
                              THEN public.launch.id END) AS launchesquantity,
       max(public.launch.start_time)                     AS lastrun,
       public.project.id,
       public.project.creation_date,
       public.project.name,
       public.project.project_type,
       public.project.organization,
       now()                                             AS last_refresh
FROM public.project
         LEFT OUTER JOIN public.launch ON public.project.id = public.launch.project_id
         LEFT OUTER JOIN public.project_user ON public.project.id = public.project_user.project_id
GROUP BY public.project.id, public.project.creation_date, public.project.name, public.project.project_type, public.project.organization
    );