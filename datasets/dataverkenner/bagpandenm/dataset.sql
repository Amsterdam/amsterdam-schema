CREATE MATERIALIZED VIEW IF NOT EXISTS public.dataverkenner_bagpandenm_bagpanden_v1 AS WITH verblijfsobjecten AS
  ( SELECT ligt_in_panden_id,
           array_agg(verblijfsobjecten_identificatie) AS vots
   FROM bag_verblijfsobjecten_ligt_in_panden
   LEFT JOIN bag_verblijfsobjecten vot ON bag_verblijfsobjecten_ligt_in_panden.verblijfsobjecten_id = vot.id
   WHERE bag_verblijfsobjecten_ligt_in_panden.eind_geldigheid IS NULL
     AND vot.status_omschrijving IN ('Verblijfsobject gevormd',
                                     'Verblijfsobject in gebruik (niet ingemeten)',
                                     'Verblijfsobject in gebruik',
                                     'Verblijfsobject buiten gebruik',
                                     'Verbouwing verblijfsobject')
   GROUP BY ligt_in_panden_id)
SELECT bag_panden.id AS "id",
       bag_panden.identificatie AS "pand_identificatie",
       bag_panden.volgnummer AS "pand_volgnummer",
       bag_panden.geometrie AS "pand_geometrie",
       bag_panden.oorspronkelijk_bouwjaar AS "pand_oorspronkelijk_bouwjaar",
       bag_panden.naam AS "pand_naam",
       bag_panden.geconstateerd AS "pand_geconstateerd",
       bag_panden.status_omschrijving AS "pand_status_omschrijving",
       bag_panden.ligging_omschrijving AS "pand_ligging_omschrijving",
       bag_panden.type_woonobject AS "pand_type_woonobject",
       bag_panden.aantal_bouwlagen AS "pand_aantal_bouwlagen",
       bag_panden.hoogste_bouwlaag AS "pand_hoogste_bouwlaag",
       bag_panden.laagste_bouwlaag AS "pand_laagste_bouwlaag",
       bag_panden.documentdatum AS "pand_documentdatum",
       bag_panden.documentnummer AS "pand_documentnummer",
       bag_panden.begin_geldigheid AS "pand_begin_geldigheid",
       bag_panden.eind_geldigheid AS "pand_eind_geldigheid",
       verblijfsobjecten.vots::_VARCHAR AS "verblijfsobjecten_identificaties"
FROM bag_panden
LEFT JOIN verblijfsobjecten ON bag_panden.id = verblijfsobjecten.ligt_in_panden_id
WHERE bag_panden.eind_geldigheid IS NULL
  AND bag_panden.status_omschrijving IN ('Bouwaanvraag ontvangen',
                                         'Bouwvergunning verleend',
                                         'Bouw gestart',
                                         'Pand in gebruik (niet ingemeten)',
                                         'Pand in gebruik',
                                         'Sloopvergunning verleend',
                                         'Pand buiten gebruik',
                                         'Verbouwing pand') WITH NO DATA;
