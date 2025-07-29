CREATE MATERIALIZED VIEW IF NOT EXISTS public.dataverkenner_pandligtinm_pandligtin_v1 as
select
bag_panden.id as "id",
bag_panden.identificatie as "identificatie",
bag_panden.volgnummer as "volgnummer",
gebieden_buurten.id as "gebieden_buurt_id",
gebieden_buurten.identificatie as "gebieden_buurt_identificatie",
gebieden_buurten.volgnummer as "gebieden_buurt_volgnummer",
gebieden_buurten.naam as "gebieden_buurt_naam",
gebieden_buurten.code as "gebieden_buurt_code",
gebieden_wijken.id as "gebieden_wijk_id",
gebieden_wijken.identificatie as "gebieden_wijk_identificatie",
gebieden_wijken.volgnummer as "gebieden_wijk_volgnummer",
gebieden_wijken.naam as "gebieden_wijk_naam",
gebieden_wijken.code as "gebieden_wijk_code",
gebieden_stadsdelen.id as "gebieden_stadsdeel_id",
gebieden_stadsdelen.identificatie as "gebieden_stadsdeel_identificatie",
gebieden_stadsdelen.volgnummer as "gebieden_stadsdeel_volgnummer",
gebieden_stadsdelen.naam as "gebieden_stadsdeel_naam",
gebieden_stadsdelen.code as "gebieden_stadsdeel_code",
gebieden_ggwgebieden.id as "gebieden_ggwgebied_id",
gebieden_ggwgebieden.identificatie as "gebieden_ggwgebied_identificatie",
gebieden_ggwgebieden.volgnummer as "gebieden_ggwgebied_volgnummer",
gebieden_ggwgebieden.naam as "gebieden_ggwgebied_naam",
gebieden_ggwgebieden.code as "gebieden_ggwgebied_code",
gebieden_bouwblokken.id as "gebieden_bouwblok_id",
gebieden_bouwblokken.identificatie as "gebieden_bouwblok_identificatie",
gebieden_bouwblokken.volgnummer as "gebieden_bouwblok_volgnummer",
gebieden_bouwblokken.code as "gebieden_bouwblok_code",
bag_panden.begin_geldigheid as "pand_begin_geldigheid",
bag_panden.eind_geldigheid as "pand_eind_geldigheid"
from bag_panden
left join gebieden_buurten on bag_panden.ligt_in_buurt_id=gebieden_buurten.id
left join gebieden_wijken on gebieden_buurten.ligt_in_wijk_id = gebieden_wijken.id
left join gebieden_stadsdelen on gebieden_wijken.ligt_in_stadsdeel_id = gebieden_stadsdelen.id
left join gebieden_ggwgebieden on gebieden_buurten.ligt_in_ggwgebied_id = gebieden_ggwgebieden.id
left join gebieden_bouwblokken on bag_panden.ligt_in_bouwblok_id=gebieden_bouwblokken.id
where gebieden_bouwblokken.eind_geldigheid is null
and gebieden_buurten.eind_geldigheid is null
and gebieden_wijken.eind_geldigheid is null
and gebieden_ggwgebieden.eind_geldigheid is null
and gebieden_stadsdelen.eind_geldigheid is null
and bag_panden.eind_geldigheid is null
and bag_panden.status_omschrijving in ('Bouwaanvraag ontvangen','Bouwvergunning verleend','Bouw gestart','Pand in gebruik (niet ingemeten)','Pand in gebruik','Sloopvergunning verleend','Pand buiten gebruik','Verbouwing pand') with no data;
