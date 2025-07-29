create or replace view public.dataverkenner_zakelijkerechten_zakelijkerechten_v1 WITH (security_barrier) as
SELECT
    brk_2_zakelijkerechten.id AS "id",
    brk_2_zakelijkerechten.identificatie AS "identificatie",
    brk_2_zakelijkerechten.volgnummer AS "volgnummer",
    brk_2_zakelijkerechten.rust_op_brk_kadastraal_object_identificatie AS "rust_op_brk_kadastraal_object_identificatie",
    brk_2_zakelijkerechten.aard_zakelijk_recht_omschrijving AS "aard_zakelijk_recht_omschrijving",
    brk_2_zakelijkerechten.betrokken_bij_appartementsrechtsplitsing_vve AS "betrokken_bij_appartementsrechtsplitsing_vve",
    brk_2_zakelijkerechten.vve_identificatie_ontstaan_uit_id AS "vve_identificatie_ontstaan_uit_id",
    brk_2_zakelijkerechten.vve_identificatie_betrokken_bij_id AS "vve_identificatie_betrokken_bij_id",
    brk_2_zakelijkerechten.begin_geldigheid AS "begin_geldigheid",
    brk_2_zakelijkerechten.eind_geldigheid AS "eind_geldigheid"
FROM
    brk_2_zakelijkerechten
    WHERE (brk_2_zakelijkerechten.datum_actueel_tot IS NULL OR brk_2_zakelijkerechten.datum_actueel_tot > now())
