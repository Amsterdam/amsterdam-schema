CREATE MATERIALIZED VIEW IF NOT EXISTS public.dataverkenner_betrokkenbijm_betrokkenbij as
select kot.id as "id",
kot.identificatie as "identificatie",
kot.neuron_id as "neuron_id",
kot.volgnummer as "volgnummer",
kot.kadastrale_aanduiding as "kadastrale_aanduiding",
betrokken_bij.kadastraleobjecten_id as "betrokken_bij_kadastraleobjecten_id",
betrokken_bij.kadastraleobjecten_identificatie as "betrokken_bij_identificatie",
betrokken_bij.kadastraleobjecten_volgnummer as "betrokken_bij_volgnummer"
from brk_2_kadastraleobjecten kot
LEFT JOIN 
(SELECT *
FROM brk_2_kadastraleobjecten_is_ontstaan_uit_brk_kadastraalobject
WHERE eind_geldigheid IS NULL) betrokken_bij
ON kot.id=betrokken_bij.is_ontstaan_uit_brk_kadastraalobject_id
WHERE kot.datum_actueel_tot IS NULL
with no data
;