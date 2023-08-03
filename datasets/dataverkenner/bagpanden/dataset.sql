CREATE OR REPLACE VIEW public.dataverkenner_bagpanden_bagpanden WITH (security_barrier) AS 
SELECT bag_panden.id,
bag_panden.id AS pand_id,
bag_panden.identificatie AS pand_identificatie,
bag_panden.volgnummer AS pand_volgnummer,
bag_panden.geometrie AS pand_geometrie,
bag_panden.oorspronkelijk_bouwjaar AS pand_oorspronkelijk_bouwjaar,
bag_panden.naam AS pand_naam,
bag_panden.ligging_omschrijving AS pand_ligging_omschrijving,
bag_panden.type_woonobject AS pand_type_woonobject,
bag_panden.aantal_bouwlagen AS pand_aantal_bouwlagen,
bag_panden.hoogste_bouwlaag AS pand_hoogste_bouwlaag,
bag_panden.laagste_bouwlaag AS pand_laagste_bouwlaag,
bag_panden.begin_geldigheid AS pand_begin_geldigheid,
bag_panden.eind_geldigheid AS pand_eind_geldigheid
FROM bag_panden;