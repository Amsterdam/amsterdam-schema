CREATE MATERIALIZED VIEW IF NOT EXISTS public.dataverkenner_bagpandenm_bagpanden_v1 AS WITH verblijfsobjecten AS
  ( SELECT ligt_in_panden_id,
           array_agg(verblijfsobjecten_identificatie) AS vots
   FROM bag_verblijfsobjecten_ligt_in_panden_v1
   LEFT JOIN bag_verblijfsobjecten_v1 vot ON bag_verblijfsobjecten_ligt_in_panden_v1.verblijfsobjecten_id = vot.id
   WHERE bag_verblijfsobjecten_ligt_in_panden_v1.eind_geldigheid IS NULL
     AND vot.status_omschrijving IN ('Verblijfsobject gevormd',
                                     'Verblijfsobject in gebruik (niet ingemeten)',
                                     'Verblijfsobject in gebruik',
                                     'Verblijfsobject buiten gebruik',
                                     'Verbouwing verblijfsobject')
   GROUP BY ligt_in_panden_id)
SELECT bag_panden_v1.id AS "id",
       bag_panden_v1.identificatie AS "pand_identificatie",
       bag_panden_v1.volgnummer AS "pand_volgnummer",
       bag_panden_v1.geometrie AS "pand_geometrie",
       bag_panden_v1.oorspronkelijk_bouwjaar AS "pand_oorspronkelijk_bouwjaar",
       bag_panden_v1.naam AS "pand_naam",
       bag_panden_v1.geconstateerd AS "pand_geconstateerd",
       bag_panden_v1.status_omschrijving AS "pand_status_omschrijving",
       bag_panden_v1.ligging_omschrijving AS "pand_ligging_omschrijving",
       bag_panden_v1.type_woonobject AS "pand_type_woonobject",
       bag_panden_v1.aantal_bouwlagen AS "pand_aantal_bouwlagen",
       bag_panden_v1.hoogste_bouwlaag AS "pand_hoogste_bouwlaag",
       bag_panden_v1.laagste_bouwlaag AS "pand_laagste_bouwlaag",
       bag_panden_v1.documentdatum AS "pand_documentdatum",
       bag_panden_v1.documentnummer AS "pand_documentnummer",
       bag_panden_v1.begin_geldigheid AS "pand_begin_geldigheid",
       bag_panden_v1.eind_geldigheid AS "pand_eind_geldigheid",
       verblijfsobjecten.vots::_VARCHAR AS "verblijfsobjecten_identificaties"
FROM bag_panden_v1
LEFT JOIN verblijfsobjecten ON bag_panden_v1.id = verblijfsobjecten.ligt_in_panden_id
WHERE bag_panden_v1.eind_geldigheid IS NULL
  AND bag_panden_v1.status_omschrijving IN ('Bouwaanvraag ontvangen',
                                         'Bouwvergunning verleend',
                                         'Bouw gestart',
                                         'Pand in gebruik (niet ingemeten)',
                                         'Pand in gebruik',
                                         'Sloopvergunning verleend',
                                         'Pand buiten gebruik',
                                         'Verbouwing pand') WITH NO DATA;
