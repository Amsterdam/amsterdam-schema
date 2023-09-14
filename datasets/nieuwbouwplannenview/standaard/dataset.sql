CREATE OR REPLACE VIEW public.nieuwbouwplannenview_standaard AS
SELECT
id                          ,
'n.b.' AS id_primavera		,
projectnaam_afkorting       ,
buurt_code                  ,
buurt_naam                  ,
wijk_code                   ,
wijk_naam                   ,
gebied_code                 ,
gebied_naam                 ,
stadsdeel_code              ,
stadsdeel_naam              ,
'n.b' AS grex						,
'n.b' AS gebiedsindeling_primavera	,
CASE WHEN start_bouw_gerealiseerd IS NULL 
          AND plaberum_publicatie <> 'FASe 0: Strategische Ruimte' THEN 'n.b.'::varchar
          ELSE zelfbouw::varchar END AS zelfbouw                                              ,
CASE WHEN start_bouw_gerealiseerd IS NULL 
          AND plaberum_publicatie <> 'FASe 0: Strategische Ruimte' THEN 'n.b.'::varchar
          ELSE sociale_huur_corporatie::varchar END AS sociale_huur_corporatie                ,
plaberum_publicatie                                                         ,
to_char(start_bouw_gepland, 'DD/MM/YYYY') AS start_bouw_gepland             ,
to_char(start_bouw_gerealiseerd, 'DD/MM/YYYY') AS start_bouw_gerealiseerd   ,
'n.b' AS oplevering_gepland ,
sociale_huur_zelfst_perm    ,
middeldure_huur             ,
sociale_koop                ,
vrije_sector_huur           ,
vrije_sector_koop           ,
vrije_sector_nb             ,
onbekend                    ,
CASE WHEN start_bouw_gerealiseerd IS NULL 
          AND plaberum_publicatie <> 'FASe 0: Strategische Ruimte' THEN 'n.b.'::varchar
          ELSE jongeren::varchar END AS jongeren                                              ,
CASE WHEN start_bouw_gerealiseerd IS NULL 
          AND plaberum_publicatie <> 'FASe 0: Strategische Ruimte' THEN 'n.b.'::varchar 
          ELSE studenten::varchar END AS studenten                                            ,
CASE WHEN start_bouw_gerealiseerd IS NULL 
          AND plaberum_publicatie <> 'FASe 0: Strategische Ruimte' THEN 'n.b.'::varchar 
          ELSE sh_onzelfst_en_of_tijdelijk::varchar END AS sh_onzelfst_en_of_tijdelijk        ,
CASE WHEN start_bouw_gerealiseerd IS NULL 
          AND plaberum_publicatie <> 'FASe 0: Strategische Ruimte' THEN 'n.b.'::varchar 
          ELSE onzelfstandig::varchar END AS onzelfstandig                                    ,
CASE WHEN start_bouw_gerealiseerd IS NULL 
          AND plaberum_publicatie <> 'FASe 0: Strategische Ruimte' THEN 'n.b.'::varchar 
          ELSE tijdelijk::varchar END AS tijdelijk                                            ,
totaal                                                                      ,
totaal_zelfst_perm                                                          ,
to_char(peildatum, 'DD/MM/YYYY') AS peildatum		                        ,
geometrie
FROM public.nieuwbouwplannen_projecten
WHERE start_bouw_gerealiseerd IS NOT NULL
OR    (start_bouw_gerealiseerd IS NULL AND plaberum_publicatie <> 'FASe 0: Strategische Ruimte')
;