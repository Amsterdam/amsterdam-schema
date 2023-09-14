CREATE OR REPLACE VIEW public.nieuwbouwplannenview_openbaar AS
SELECT
id                          ,
'n.b.' as id_primavera		,
projectnaam_afkorting       ,
buurt_code                  ,
buurt_naam                  ,
wijk_code                   ,
wijk_naam                   ,
gebied_code                 ,
gebied_naam                 ,
stadsdeel_code              ,
stadsdeel_naam              ,
'n.b' as grex						,
'n.b' as gebiedsindeling_primavera	,
CASE WHEN extract(DAY from peildatum) = 1 AND (extract(MONTH from peildatum) = 7 OR extract(MONTH from peildatum) = 1)
           AND start_bouw_gerealiseerd IS NULL
           AND plaberum_publicatie <> 'Fase 0: Strategische Ruimte' THEN 'n.b.'::varchar
           ELSE zelfbouw::varchar END as zelfbouw                                                                           ,
CASE WHEN extract(DAY from peildatum) = 1 AND (extract(MONTH from peildatum) = 7 OR extract(MONTH from peildatum) = 1)
           AND start_bouw_gerealiseerd IS NULL
           AND plaberum_publicatie <> 'Fase 0: Strategische Ruimte' THEN 'n.b.'::varchar
           ELSE sociale_huur_corporatie::varchar END as sociale_huur_corporatie                                             ,
plaberum_publicatie                                                         ,
to_char(start_bouw_gepland, 'DD/MM/YYYY') as start_bouw_gepland             ,
to_char(start_bouw_gerealiseerd, 'DD/MM/YYYY') as start_bouw_gerealiseerd   ,
'n.b' as oplevering_gepland ,
sociale_huur_zelfst_perm    ,
middeldure_huur             ,
sociale_koop                ,
vrije_sector_huur           ,
vrije_sector_koop           ,
vrije_sector_nb             ,
onbekend                    ,
CASE WHEN extract(DAY from peildatum) = 1 AND (extract(MONTH from peildatum) = 7 OR extract(MONTH from peildatum) = 1)
           AND start_bouw_gerealiseerd IS NULL
           AND plaberum_publicatie <> 'Fase 0: Strategische Ruimte' THEN 'n.b.'::varchar
           ELSE jongeren::varchar END as jongeren                                                                           ,
CASE WHEN extract(DAY from peildatum) = 1 AND (extract(MONTH from peildatum) = 7 OR extract(MONTH from peildatum) = 1)
           AND start_bouw_gerealiseerd IS NULL
           AND plaberum_publicatie <> 'Fase 0: Strategische Ruimte' THEN 'n.b.'::varchar 
           ELSE studenten::varchar END as studenten                                                                         ,
CASE WHEN extract(DAY from peildatum) = 1 AND (extract(MONTH from peildatum) = 7 OR extract(MONTH from peildatum) = 1)
           AND start_bouw_gerealiseerd IS NULL
           AND plaberum_publicatie <> 'Fase 0: Strategische Ruimte' THEN 'n.b.'::varchar 
           ELSE sh_onzelfst_en_of_tijdelijk::varchar END as sh_onzelfst_en_of_tijdelijk                                     ,
CASE WHEN extract(DAY from peildatum) = 1 AND (extract(MONTH from peildatum) = 7 OR extract(MONTH from peildatum) = 1)
           AND start_bouw_gerealiseerd IS NULL
           AND plaberum_publicatie <> 'Fase 0: Strategische Ruimte' THEN 'n.b.'::varchar 
           ELSE onzelfstandig::varchar END as onzelfstandig                                                                 ,
CASE WHEN extract(DAY from peildatum) = 1 AND (extract(MONTH from peildatum) = 7 OR extract(MONTH from peildatum) = 1)
           AND start_bouw_gerealiseerd IS NULL
           AND plaberum_publicatie <> 'Fase 0: Strategische Ruimte' THEN 'n.b.'::varchar 
           ELSE tijdelijk::varchar END as tijdelijk                                                                         ,
totaal                                                                      ,
totaal_zelfst_perm                                                          ,
to_char(peildatum, 'DD/MM/YYYY') as peildatum		                        ,
geometrie
FROM public.nieuwbouwplannen_projecten
WHERE (extract(DAY from peildatum) = 1 
AND (extract(MONTH from peildatum) = 7 OR extract(MONTH from peildatum) = 1) 
AND start_bouw_gerealiseerd IS NOT NULL)
OR    (extract(DAY from peildatum) = 1 
AND (extract(MONTH from peildatum) = 7 OR extract(MONTH from peildatum) = 1) 
AND start_bouw_gerealiseerd IS NULL AND plaberum_publicatie <> 'Fase 0: Strategische Ruimte')
;