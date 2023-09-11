CREATE OR REPLACE VIEW public.nieuwbouwplannenview_openbaar as
SELECT
id                          ,
id_primavera                ,
projectnaam_afkorting       ,
buurt_code                  ,
buurt_naam                  ,
wijk_code                   ,
wijk_naam                   ,
gebied_code                 ,
gebied_naam                 ,
stadsdeel_code              ,
stadsdeel_naam              ,
grex                        ,
gebiedsindeling_primavera   ,
case when (peildatum::varchar like '%01-01' or peildatum::varchar like '%07-01')
           AND start_bouw_gerealiseerd is NULL
           AND plaberum_publicatie <> 'Fase 0: Strategische Ruimte' then zelfbouw::varchar
           ELSE 'n.b.'::varchar END as zelfbouw,
case when (peildatum::varchar like '%01-01' or peildatum::varchar like '%07-01')
           AND start_bouw_gerealiseerd is NULL
           AND plaberum_publicatie <> 'Fase 0: Strategische Ruimte' then sociale_huur_corporatie::varchar
           ELSE 'n.b.'::varchar END as sociale_huur_corporatie,
plaberum_publicatie         ,
start_bouw_gepland          ,
start_bouw_gerealiseerd     ,
oplevering_gepland          ,
sociale_huur_zelfst_perm    ,
middeldure_huur             ,
sociale_koop                ,
vrije_sector_huur           ,
vrije_sector_koop           ,
vrije_sector_nb             ,
onbekend                    ,
case when (peildatum::varchar like '%01-01' or peildatum::varchar like '%07-01')
           AND start_bouw_gerealiseerd is NULL
           AND plaberum_publicatie <> 'Fase 0: Strategische Ruimte' then jongeren::varchar
           ELSE 'n.b.'::varchar END as jongeren,
case when (peildatum::varchar like '%01-01' or peildatum::varchar like '%07-01')
           AND start_bouw_gerealiseerd is NULL
           AND plaberum_publicatie <> 'Fase 0: Strategische Ruimte' then studenten::varchar
           ELSE 'n.b.'::varchar END as studenten,
case when (peildatum::varchar like '%01-01' or peildatum::varchar like '%07-01')
           AND start_bouw_gerealiseerd is NULL
           AND plaberum_publicatie <> 'Fase 0: Strategische Ruimte' then sh_onzelfst_en_of_tijdelijk::varchar
           ELSE 'n.b.'::varchar END as sh_onzelfst_en_of_tijdelijk,
case when (peildatum::varchar like '%01-01' or peildatum::varchar like '%07-01')
           AND start_bouw_gerealiseerd is NULL
           AND plaberum_publicatie <> 'Fase 0: Strategische Ruimte' then onzelfstandig::varchar
           ELSE 'n.b.'::varchar END as onzelfstandig,
case when (peildatum::varchar like '%01-01' or peildatum::varchar like '%07-01')
           AND start_bouw_gerealiseerd is NULL
           AND plaberum_publicatie <> 'Fase 0: Strategische Ruimte' then tijdelijk::varchar
           ELSE 'n.b.'::varchar END as tijdelijk,
totaal                                                                      ,
totaal_zelfst_perm                                                          ,
plaberum_publicatie                                                         ,
to_char(start_bouw_gepland, 'DD/MM/YYYY') as start_bouw_gepland             ,
to_char(start_bouw_gerealiseerd, 'DD/MM/YYYY') as start_bouw_gerealiseerd   ,
to_char(oplevering_gepland, 'DD/MM/YYYY') as oplevering_gepland             ,
to_char(peildatum, 'DD/MM/YYYY') as peildatum		                        ,
geometrie
FROM public.nieuwbouwplannen_projecten
WHERE ((peildatum::varchar LIKE '%01-01' OR peildatum::varchar LIKE '%07-01') AND start_bouw_gerealiseerd IS NOT NULL)
OR    ((peildatum::varchar LIKE '%01-01' OR peildatum::varchar LIKE '%07-01') AND start_bouw_gerealiseerd IS NULL AND plaberum_publicatie <> 'Fase 0: Strategische Ruimte')
;