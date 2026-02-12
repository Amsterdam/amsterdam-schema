CREATE MATERIALIZED VIEW IF NOT EXISTS public.dataverkenner_zakelijkerechtenm_zakelijkerechten_v1 as
SELECT
    brk_2_zakelijkerechten_v1.id AS "id",
    brk_2_zakelijkerechten_v1.identificatie AS "identificatie",
    brk_2_zakelijkerechten_v1.volgnummer AS "volgnummer",
    brk_2_zakelijkerechten_v1.rust_op_brk_kadastraal_object_identificatie AS "rust_op_brk_kadastraal_object_identificatie",
    brk_2_zakelijkerechten_v1.aard_zakelijk_recht_omschrijving AS "aard_zakelijk_recht_omschrijving",
    brk_2_zakelijkerechten_v1.betrokken_bij_appartementsrechtsplitsing_vve AS "betrokken_bij_appartementsrechtsplitsing_vve",
    brk_2_zakelijkerechten_v1.vve_identificatie_ontstaan_uit_id AS "vve_identificatie_ontstaan_uit_id",
    brk_2_zakelijkerechten_v1.vve_identificatie_betrokken_bij_id AS "vve_identificatie_betrokken_bij_id",
    brk_2_zakelijkerechten_v1.begin_geldigheid AS "begin_geldigheid",
    brk_2_zakelijkerechten_v1.eind_geldigheid AS "eind_geldigheid"
FROM
    brk_2_zakelijkerechten_v1
    WHERE (brk_2_zakelijkerechten_v1.datum_actueel_tot IS NULL OR brk_2_zakelijkerechten_v1.datum_actueel_tot > now())
with no data;
