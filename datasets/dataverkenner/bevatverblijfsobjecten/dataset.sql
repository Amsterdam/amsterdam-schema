create or replace view public.dataverkenner_bevatverblijfsobjecten_bevatverblijfsobjecten_v1 WITH (security_barrier) as
select
bag_verblijfsobjecten_ligt_in_panden.verblijfsobjecten_id as "id",
bag_verblijfsobjecten_ligt_in_panden.verblijfsobjecten_id as "verblijfsobjecten_id",
bag_verblijfsobjecten_ligt_in_panden.verblijfsobjecten_identificatie as "verblijfsobjecten_identificatie",
bag_verblijfsobjecten_ligt_in_panden.verblijfsobjecten_volgnummer as "verblijfsobjecten_volgnummer",
bag_verblijfsobjecten_ligt_in_panden.ligt_in_panden_id as "ligt_in_panden_id",
bag_verblijfsobjecten_ligt_in_panden.ligt_in_panden_identificatie as "ligt_in_panden_identificatie",
bag_verblijfsobjecten_ligt_in_panden.ligt_in_panden_volgnummer as "ligt_in_panden_volgnummer",
bag_verblijfsobjecten_ligt_in_panden.begin_geldigheid as "begin_geldigheid",
bag_verblijfsobjecten_ligt_in_panden.eind_geldigheid as "eind_geldigheid"
from bag_verblijfsobjecten_ligt_in_panden
left join bag_verblijfsobjecten vot
on bag_verblijfsobjecten_ligt_in_panden.verblijfsobjecten_id = vot.id
left join bag_panden pnd
on bag_verblijfsobjecten_ligt_in_panden.ligt_in_panden_id = pnd.id
where bag_verblijfsobjecten_ligt_in_panden.eind_geldigheid is null
and vot.status_omschrijving in ('Verblijfsobject gevormd','Verblijfsobject in gebruik (niet ingemeten)','Verblijfsobject in gebruik','Verblijfsobject buiten gebruik','Verbouwing verblijfsobject')
and pnd.status_omschrijving in ('Bouwaanvraag ontvangen','Bouwvergunning verleend','Bouw gestart','Pand in gebruik (niet ingemeten)','Pand in gebruik','Sloopvergunning verleend','Pand buiten gebruik','Verbouwing pand');
