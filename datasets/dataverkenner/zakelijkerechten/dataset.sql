create or replace view public.dataverkenner_zakelijkerechten_zakelijkerechten WITH (security_barrier) as
SELECT
    z.id AS "id",
    z.identificatie AS "identificatie",
    z.volgnummer AS "volgnummer",
    z.rust_op_brk_kadastraal_object_identificatie AS "rust_op_brk_kadastraal_object_identificatie",
    z.aard_zakelijk_recht_omschrijving AS "aard_zakelijk_recht_omschrijving",
    z.betrokken_bij_appartementsrechtsplitsing_vve AS "betrokken_bij_appartementsrechtsplitsing_vve",
    z.begin_geldigheid AS "begin_geldigheid",
    z.eind_geldigheid AS "eind_geldigheid"
FROM 
    brk_2_zakelijkerechten z
INNER JOIN (
    SELECT
        rust_op_brk_kadastraal_object_identificatie,
        MAX(volgnummer) AS max_volgnummer
    FROM 
        brk_2_zakelijkerechten
    GROUP BY 
        rust_op_brk_kadastraal_object_identificatie
) AS subq ON z.rust_op_brk_kadastraal_object_identificatie = subq.rust_op_brk_kadastraal_object_identificatie
AND z.volgnummer = subq.max_volgnummer;
