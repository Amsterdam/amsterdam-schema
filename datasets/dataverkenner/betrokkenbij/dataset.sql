create or replace view public.dataverkenner_betrokkenbij_betrokkenbij WITH (security_barrier) as
SELECT
    kot1.id,
    kot1.identificatie,
    kot1.volgnummer,
    kot1.kadastrale_aanduiding,
    kot1.neuron_id,
    ontstaan_uit.kadastraleobjecten_id AS betrokken_bij_kadastraleobjecten_id,
    ontstaan_uit.kadastraleobjecten_identificatie AS betrokken_bij_identificatie,
    ontstaan_uit.kadastraleobjecten_volgnummer AS betrokken_bij_volgnummer,
    kot2.kadastrale_aanduiding AS betrokken_bij_kadastrale_aanduiding
FROM brk_2_kadastraleobjecten_is_ontstaan_uit_brk_kadastraalobject ontstaan_uit
LEFT JOIN brk_2_kadastraleobjecten kot1 ON ontstaan_uit.is_ontstaan_uit_brk_kadastraalobject_id ::TEXT=kot1.id::TEXT
LEFT JOIN brk_2_kadastraleobjecten  kot2  ON ontstaan_uit.kadastraleobjecten_id ::TEXT=kot2.id ::TEXT
WHERE ontstaan_uit.eind_geldigheid IS NULL
AND kot1.datum_actueel_tot IS NULL
AND kot2.datum_actueel_tot IS NULL;