CREATE OR REPLACE VIEW public.nieuwbouwplannenview_openbaar AS
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
case when (peildatum like '01/01/%' or peildatum like '01/07/%')
           AND start_bouw_gerealiseerd is NULL
           AND plaberum_publicatie <> 'Fase 0: Strategische Ruimte' then zelfbouw
           ELSE 'n.b.' END as zelfbouw,
case when (peildatum like '01/01/%' or peildatum like '01/07/%')
           AND start_bouw_gerealiseerd is NULL
           AND plaberum_publicatie <> 'Fase 0: Strategische Ruimte' then sociale_huur_corporatie
           ELSE 'n.b.' END as sociale_huur_corporatie,
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
case when (peildatum like '01/01/%' or peildatum like '01/07/%')
           AND start_bouw_gerealiseerd is NULL
           AND plaberum_publicatie <> 'Fase 0: Strategische Ruimte' then jongeren
           ELSE 'n.b.' END as jongeren,
case when (peildatum like '01/01/%' or peildatum like '01/07/%')
           AND start_bouw_gerealiseerd is NULL
           AND plaberum_publicatie <> 'Fase 0: Strategische Ruimte' then studenten
           ELSE 'n.b.' END as studenten,
case when (peildatum like '01/01/%' or peildatum like '01/07/%')
           AND start_bouw_gerealiseerd is NULL
           AND plaberum_publicatie <> 'Fase 0: Strategische Ruimte' then sh_onzelfst_en_of_tijdelijk
           ELSE 'n.b.' END as sh_onzelfst_en_of_tijdelijk,
case when (peildatum like '01/01/%' or peildatum like '01/07/%')
           AND start_bouw_gerealiseerd is NULL
           AND plaberum_publicatie <> 'Fase 0: Strategische Ruimte' then onzelfstandig
           ELSE 'n.b.' END as onzelfstandig,
case when (peildatum like '01/01/%' or peildatum like '01/07/%')
           AND start_bouw_gerealiseerd is NULL
           AND plaberum_publicatie <> 'Fase 0: Strategische Ruimte' then tijdelijk
           ELSE 'n.b.' END as tijdelijk,
totaal                     ,
totaal_zelfst_perm         ,
plaberum_publicatie        ,
start_bouw_gepland         ,
start_bouw_gerealiseerd    ,
oplevering_gepland         ,
peildatum				   ,
geometrie
FROM public.nieuwbouwplannen_projecten
WHERE ((peildatum LIKE '01/01/%' OR peildatum LIKE '01/07/%') AND start_bouw_gerealiseerd IS NOT NULL)
OR    ((peildatum LIKE '01/01/%' OR peildatum LIKE '01/07/%') AND start_bouw_gerealiseerd IS NULL AND plaberum_publicatie <> 'Fase 0: Strategische Ruimte');