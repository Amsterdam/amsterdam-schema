create or replace view public.dataverkenner_panden WITH (security_barrier) as
select 
bag_panden.identificatie as "pand_identificatie",
bag_panden.volgnummer as "pand_volgnummer",
bag_panden.registratiedatum as "pand_registratiedatum",
bag_panden.geconstateerd as "pand_geconstateerd",
bag_panden.geometrie as "pand_geometrie",
bag_panden.oorspronkelijk_bouwjaar as "pand_oorspronkelijk_bouwjaar",
bag_panden.status_code as "pand_status_code",
bag_panden.status_omschrijving as "pand_status_omschrijving",
bag_panden.begin_geldigheid as "pand_begin_geldigheid",
bag_panden.eind_geldigheid as "pand_eind_geldigheid",
bag_panden.documentdatum as "pand_documentdatum",
bag_panden.documentnummer as "pand_documentnummer",
bag_panden.naam as "pand_naam",
bag_panden.ligging_code as "pand_ligging_code",
bag_panden.ligging_omschrijving as "pand_ligging_omschrijving",
bag_panden.type_woonobject as "pand_type_woonobject",
bag_panden.aantal_bouwlagen as "pand_aantal_bouwlagen",
bag_panden.hoogste_bouwlaag as "pand_hoogste_bouwlaag",
bag_panden.laagste_bouwlaag as "pand_laagste_bouwlaag",
bag_panden.heeft_dossier_id as "pand_heeft_dossier",
bag_panden.bagproces_code as "pand_bagproces_code",
bag_panden.bagproces_omschrijving as "pand_bagproces_omschrijving",
bag_verblijfsobjecten.identificatie as "verblijfsobject_identificatie",
bag_verblijfsobjecten.volgnummer as "verblijfsobject_volgnummer",
gebieden_buurten.identificatie as "gebieden_buurt_identificatie",
gebieden_buurten.volgnummer as "gebieden_buurt_volgnummer",
gebieden_buurten.naam as "gebieden_buurt_naam",
gebieden_buurten.code as "gebieden_buurt_code",
gebieden_wijken.identificatie as "gebieden_wijk_identificatie",
gebieden_wijken.volgnummer as "gebieden_wijk_volgnummer",
gebieden_wijken.naam as "gebieden_wijk_naam",
gebieden_wijken.code as "gebieden_wijk_code",
gebieden_stadsdelen.identificatie as "gebieden_stadsdeel_identificatie",
gebieden_stadsdelen.volgnummer as "gebieden_stadsdeel_volgnummer",
gebieden_stadsdelen.naam as "gebieden_stadsdeel_naam",
gebieden_stadsdelen.code as "gebieden_stadsdeel_code",
gebieden_ggwgebieden.identificatie as "gebieden_ggwgebied_identificatie",
gebieden_ggwgebieden.volgnummer as "gebieden_ggwgebied_volgnummer",
gebieden_ggwgebieden.naam as "gebieden_ggwgebied_naam",
gebieden_ggwgebieden.code as "gebieden_ggwgebied_code",
gebieden_bouwblokken.identificatie as "gebieden_bouwblok_identificatie",
gebieden_bouwblokken.volgnummer as "gebieden_bouwblok_volgnummer",
gebieden_bouwblokken.code as "gebieden_bouwblok_code"
from bag_panden
left join bag_verblijfsobjecten_ligt_in_panden on bag_panden.identificatie = bag_verblijfsobjecten_ligt_in_panden.ligt_in_panden_identificatie
left join bag_verblijfsobjecten on bag_verblijfsobjecten_ligt_in_panden.verblijfsobjecten_identificatie = bag_verblijfsobjecten.identificatie
left join gebieden_buurten on bag_verblijfsobjecten.ligt_in_buurt_id=gebieden_buurten.id
left join gebieden_wijken on gebieden_buurten.ligt_in_wijk_id = gebieden_wijken.id
left join gebieden_stadsdelen on gebieden_wijken.ligt_in_stadsdeel_id = gebieden_stadsdelen.id
left join gebieden_ggwgebieden on gebieden_buurten.ligt_in_ggwgebied_id = gebieden_ggwgebieden.id 
left join gebieden_bouwblokken on bag_panden.ligt_in_bouwblok_id=gebieden_bouwblokken.id;