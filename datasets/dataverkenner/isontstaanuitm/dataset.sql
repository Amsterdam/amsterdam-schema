CREATE MATERIALIZED VIEW IF NOT EXISTS public.dataverkenner_isontstaanuitm_isontstaanuit AS
SELECT 
kot.id AS "id",
kot.identificatie AS "identificatie",
kot.neuron_id AS "neuron_id",
kot.volgnummer AS "volgnummer",
kot.kadastrale_aanduiding AS "kadastrale_aanduiding",
ontstaan_uit.is_ontstaan_uit_brk_kadastraalobject_identificatie AS "is_ontstaan_uit_kadastraalobjecten_identificatie",
ontstaan_uit.is_ontstaan_uit_brk_kadastraalobject_id AS "is_ontstaan_uit_kadastraalobjecten_id",
ontstaan_uit.is_ontstaan_uit_brk_kadastraalobject_volgnummer AS "is_ontstaan_uit_kadastraalobjecten_volgnummer",
kot2.kadastrale_aanduiding AS "is_ontstaan_uit_kadastrale_aanduiding"
FROM brk_2_kadastraleobjecten kot
LEFT JOIN 
  (SELECT *
   FROM brk_2_kadastraleobjecten_is_ontstaan_uit_brk_kadastraalobject
   WHERE eind_geldigheid IS NULL) ontstaan_uit
LEFT JOIN brk_2_kadastraleobjecten kot2 ON ontstaan_uit.is_ontstaan_uit_brk_kadastraalobject_id=kot2.id 
ON  kot.id=ontstaan_uit.kadastraleobjecten_id
WHERE kot.datum_actueel_tot IS NULL
AND kot2.datum_actueel_tot IS NULL
WITH NO DATA;