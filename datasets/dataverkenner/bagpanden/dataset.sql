create or replace view public.dataverkenner_bagpanden_bagpanden_v1 WITH (security_barrier) as
select
bag_panden.id as "id",
bag_panden.identificatie as "pand_identificatie",
bag_panden.volgnummer as "pand_volgnummer",
bag_panden.geometrie as "pand_geometrie",
bag_panden.oorspronkelijk_bouwjaar as "pand_oorspronkelijk_bouwjaar",
bag_panden.naam as "pand_naam",
bag_panden.geconstateerd as "pand_geconstateerd",
bag_panden.status_omschrijving as "pand_status_omschrijving",
bag_panden.ligging_omschrijving as "pand_ligging_omschrijving",
bag_panden.type_woonobject as "pand_type_woonobject",
bag_panden.aantal_bouwlagen as "pand_aantal_bouwlagen",
bag_panden.hoogste_bouwlaag as "pand_hoogste_bouwlaag",
bag_panden.laagste_bouwlaag as "pand_laagste_bouwlaag",
bag_panden.documentdatum as "pand_documentdatum",
bag_panden.documentnummer as "pand_documentnummer",
bag_panden.begin_geldigheid as "pand_begin_geldigheid",
bag_panden.eind_geldigheid as "pand_eind_geldigheid"
from bag_panden
where bag_panden.eind_geldigheid is null
and bag_panden.status_omschrijving in ('Bouwaanvraag ontvangen','Bouwvergunning verleend','Bouw gestart','Pand in gebruik (niet ingemeten)','Pand in gebruik','Sloopvergunning verleend','Pand buiten gebruik','verbouwing pand');
