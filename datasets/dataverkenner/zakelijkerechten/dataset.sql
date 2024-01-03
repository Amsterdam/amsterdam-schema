create or replace view public.dataverkenner_zakelijkerechten_zakelijkerechten WITH (security_barrier) as
SELECT
    z.id AS "id",
    z.identificatie AS "identificatie",
    z.volgnummer AS "volgnummer",
    z.rust_op_brk_kadastraal_object_identificatie AS "rust_op_brk_kadastraal_object_identificatie",
    z.aard_zakelijk_recht_omschrijving AS "aard_zakelijk_recht_omschrijving",
    z.betrokken_bij_appartementsrechtsplitsing_vve AS "betrokken_bij_appartementsrechtsplitsing_vve",
    z.vve_identificatie_ontstaan_uit_id AS "vve_identificatie_ontstaan_uit_id",
    z.vve_identificatie_betrokken_bij_id AS "vve_identificatie_betrokken_bij_id",
    z.begin_geldigheid AS "begin_geldigheid",
    z.eind_geldigheid AS "eind_geldigheid"
FROM 
    brk_2_zakelijkerechten z
    WHERE (z.datum_actueel_tot IS NULL OR z.datum_actueel_tot > now());
