create or replace view public.dataverkenner_bagpanden_bagpanden_v1 WITH (security_barrier) as
select
bag_panden_v1.id as "id",
bag_panden_v1.identificatie as "pand_identificatie",
bag_panden_v1.volgnummer as "pand_volgnummer",
bag_panden_v1.geometrie as "pand_geometrie",
bag_panden_v1.oorspronkelijk_bouwjaar as "pand_oorspronkelijk_bouwjaar",
bag_panden_v1.naam as "pand_naam",
bag_panden_v1.geconstateerd as "pand_geconstateerd",
bag_panden_v1.status_omschrijving as "pand_status_omschrijving",
bag_panden_v1.ligging_omschrijving as "pand_ligging_omschrijving",
bag_panden_v1.type_woonobject as "pand_type_woonobject",
bag_panden_v1.aantal_bouwlagen as "pand_aantal_bouwlagen",
bag_panden_v1.hoogste_bouwlaag as "pand_hoogste_bouwlaag",
bag_panden_v1.laagste_bouwlaag as "pand_laagste_bouwlaag",
bag_panden_v1.documentdatum as "pand_documentdatum",
bag_panden_v1.documentnummer as "pand_documentnummer",
bag_panden_v1.begin_geldigheid as "pand_begin_geldigheid",
bag_panden_v1.eind_geldigheid as "pand_eind_geldigheid"
from bag_panden_v1
where bag_panden_v1.eind_geldigheid is null
and bag_panden_v1.status_omschrijving in ('Bouwaanvraag ontvangen','Bouwvergunning verleend','Bouw gestart','Pand in gebruik (niet ingemeten)','Pand in gebruik','Sloopvergunning verleend','Pand buiten gebruik','verbouwing pand');
