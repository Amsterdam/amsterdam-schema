CREATE MATERIALIZED VIEW IF NOT EXISTS public.dataverkenner_pandligtinm_pandligtin_v1 as
select
bag_panden_v1.id as "id",
bag_panden_v1.identificatie as "identificatie",
bag_panden_v1.volgnummer as "volgnummer",
gebieden_buurten_v1.id as "gebieden_buurt_id",
gebieden_buurten_v1.identificatie as "gebieden_buurt_identificatie",
gebieden_buurten_v1.volgnummer as "gebieden_buurt_volgnummer",
gebieden_buurten_v1.naam as "gebieden_buurt_naam",
gebieden_buurten_v1.code as "gebieden_buurt_code",
gebieden_wijken_v1.id as "gebieden_wijk_id",
gebieden_wijken_v1.identificatie as "gebieden_wijk_identificatie",
gebieden_wijken_v1.volgnummer as "gebieden_wijk_volgnummer",
gebieden_wijken_v1.naam as "gebieden_wijk_naam",
gebieden_wijken_v1.code as "gebieden_wijk_code",
gebieden_stadsdelen_v1.id as "gebieden_stadsdeel_id",
gebieden_stadsdelen_v1.identificatie as "gebieden_stadsdeel_identificatie",
gebieden_stadsdelen_v1.volgnummer as "gebieden_stadsdeel_volgnummer",
gebieden_stadsdelen_v1.naam as "gebieden_stadsdeel_naam",
gebieden_stadsdelen_v1.code as "gebieden_stadsdeel_code",
gebieden_ggwgebieden_v1.id as "gebieden_ggwgebied_id",
gebieden_ggwgebieden_v1.identificatie as "gebieden_ggwgebied_identificatie",
gebieden_ggwgebieden_v1.volgnummer as "gebieden_ggwgebied_volgnummer",
gebieden_ggwgebieden_v1.naam as "gebieden_ggwgebied_naam",
gebieden_ggwgebieden_v1.code as "gebieden_ggwgebied_code",
gebieden_bouwblokken_v1.id as "gebieden_bouwblok_id",
gebieden_bouwblokken_v1.identificatie as "gebieden_bouwblok_identificatie",
gebieden_bouwblokken_v1.volgnummer as "gebieden_bouwblok_volgnummer",
gebieden_bouwblokken_v1.code as "gebieden_bouwblok_code",
bag_panden_v1.begin_geldigheid as "pand_begin_geldigheid",
bag_panden_v1.eind_geldigheid as "pand_eind_geldigheid"
from bag_panden_v1
left join gebieden_buurten_v1 on bag_panden_v1.ligt_in_buurt_id=gebieden_buurten_v1.id
left join gebieden_wijken_v1 on gebieden_buurten_v1.ligt_in_wijk_id = gebieden_wijken_v1.id
left join gebieden_stadsdelen_v1 on gebieden_wijken_v1.ligt_in_stadsdeel_id = gebieden_stadsdelen_v1.id
left join gebieden_ggwgebieden_v1 on gebieden_buurten_v1.ligt_in_ggwgebied_id = gebieden_ggwgebieden_v1.id
left join gebieden_bouwblokken_v1 on bag_panden_v1.ligt_in_bouwblok_id=gebieden_bouwblokken_v1.id
where gebieden_bouwblokken_v1.eind_geldigheid is null
and gebieden_buurten_v1.eind_geldigheid is null
and gebieden_wijken_v1.eind_geldigheid is null
and gebieden_ggwgebieden_v1.eind_geldigheid is null
and gebieden_stadsdelen_v1.eind_geldigheid is null
and bag_panden_v1.eind_geldigheid is null
and bag_panden_v1.status_omschrijving in ('Bouwaanvraag ontvangen','Bouwvergunning verleend','Bouw gestart','Pand in gebruik (niet ingemeten)','Pand in gebruik','Sloopvergunning verleend','Pand buiten gebruik','Verbouwing pand') with no data;
