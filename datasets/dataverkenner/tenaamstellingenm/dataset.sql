CREATE MATERIALIZED VIEW IF NOT EXISTS public.dataverkenner_tenaamstellingenm_tenaamstellingen_v1 as
select
brk_2_tenaamstellingen.id as "id",
brk_2_tenaamstellingen.identificatie as "identificatie",
brk_2_tenaamstellingen.volgnummer as "volgnummer",
brk_2_tenaamstellingen.aandeel_noemer as "aandeel_noemer",
brk_2_tenaamstellingen.aandeel_teller as "aandeel_teller",
brk_2_tenaamstellingen.van_brk_zakelijk_recht_identificatie as "van_brk_zakelijk_recht_identificatie",
brk_2_tenaamstellingen.begin_geldigheid as "begin_geldigheid",
brk_2_tenaamstellingen.eind_geldigheid as "eind_geldigheid",
brk_2_kadastralesubjecten.identificatie as "kadastralesubjecten_identificatie",
brk_2_kadastralesubjecten.voornamen as "kadastralesubjecten_voorvoegsels",
brk_2_kadastralesubjecten.voornamen as "kadastralesubjecten_voornamen",
brk_2_kadastralesubjecten.geslachtsnaam as "kadastralesubjecten_geslachtsnaam",
brk_2_kadastralesubjecten.geslacht_code as "kadastralesubjecten_geslacht_code",
brk_2_kadastralesubjecten.statutaire_naam as "kadastralesubjecten_statutaire_naam",
brk_2_kadastralesubjecten.type_subject as "kadastralesubjecten_type_subject"
from brk_2_tenaamstellingen
left join brk_2_kadastralesubjecten on brk_2_tenaamstellingen.van_brk_kadastraalsubject_id = brk_2_kadastralesubjecten.identificatie
WHERE (brk_2_tenaamstellingen.datum_actueel_tot IS NULL or brk_2_tenaamstellingen.eind_geldigheid> now())
AND (brk_2_kadastralesubjecten.datum_actueel_tot IS NULL OR brk_2_kadastralesubjecten.datum_actueel_tot> now())
with no data;
