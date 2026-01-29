CREATE MATERIALIZED VIEW IF NOT EXISTS public.dataverkenner_tenaamstellingenm_tenaamstellingen_v1 as
select
brk_2_tenaamstellingen_v2.id as "id",
brk_2_tenaamstellingen_v2.identificatie as "identificatie",
brk_2_tenaamstellingen_v2.volgnummer as "volgnummer",
brk_2_tenaamstellingen_v2.aandeel_noemer as "aandeel_noemer",
brk_2_tenaamstellingen_v2.aandeel_teller as "aandeel_teller",
brk_2_tenaamstellingen_v2.van_brk_zakelijk_recht_identificatie as "van_brk_zakelijk_recht_identificatie",
brk_2_tenaamstellingen_v2.begin_geldigheid as "begin_geldigheid",
brk_2_tenaamstellingen_v2.eind_geldigheid as "eind_geldigheid",
brk_2_kadastralesubjecten_v1.identificatie as "kadastralesubjecten_identificatie",
brk_2_kadastralesubjecten_v1.voornamen as "kadastralesubjecten_voorvoegsels",
brk_2_kadastralesubjecten_v1.voornamen as "kadastralesubjecten_voornamen",
brk_2_kadastralesubjecten_v1.geslachtsnaam as "kadastralesubjecten_geslachtsnaam",
brk_2_kadastralesubjecten_v1.geslacht_code as "kadastralesubjecten_geslacht_code",
brk_2_kadastralesubjecten_v1.statutaire_naam as "kadastralesubjecten_statutaire_naam",
brk_2_kadastralesubjecten_v1.type_subject as "kadastralesubjecten_type_subject"
from brk_2_tenaamstellingen_v2
left join brk_2_kadastralesubjecten_v1 on brk_2_tenaamstellingen_v2.van_brk_kadastraalsubject_id = brk_2_kadastralesubjecten_v1.identificatie
WHERE (brk_2_tenaamstellingen_v2.datum_actueel_tot IS NULL or brk_2_tenaamstellingen_v2.eind_geldigheid> now())
AND (brk_2_kadastralesubjecten_v1.datum_actueel_tot IS NULL OR brk_2_kadastralesubjecten_v1.datum_actueel_tot> now())
with no data;

SELECT cron.schedule('dataverkenner_tenaamstellingenm_tenaamstellingen_refresh', '20 21 * * *', 'REFRESH MATERIALIZED VIEW public.dataverkenner_tenaamstellingenm_tenaamstellingen_v1');
