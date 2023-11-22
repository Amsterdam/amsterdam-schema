CREATE OR REPLACE VIEW public.mapserver_eikenprocessierups_kaart
  WITH (security_barrier)
  AS
    SELECT id, geometrie AS geom, urgentie_status_kaartlaag AS urgentie_status
      FROM public.ziekte_plagen_exoten_groen_eikenprocessierups epr
      WHERE epr.ranking = 1
;
