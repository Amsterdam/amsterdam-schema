create or replace view public.dataverkenner_isontstaanuit_isontstaanuit WITH (security_barrier) as
select kot.id as "id",
kot.identificatie as "identificatie",
kot.neuron_id as "neuron_id",
kot.volgnummer as "volgnummer",
kot.kadastrale_aanduiding as "kadastrale_aanduiding",
ontstaan_uit.is_ontstaan_uit_brk_kadastraalobject_identificatie AS "is_ontstaan_uit_kadastraalobjecten_identificatie",
ontstaan_uit.is_ontstaan_uit_brk_kadastraalobject_id AS "is_ontstaan_uit_kadastraalobjecten_id",
ontstaan_uit.is_ontstaan_uit_brk_kadastraalobject_volgnummer AS "is_ontstaan_uit_kadastraalobjecten_volgnummer"
from brk_2_kadastraleobjecten kot
LEFT JOIN 
(SELECT *
FROM brk_2_kadastraleobjecten_is_ontstaan_uit_brk_kadastraalobject
WHERE eind_geldigheid IS NULL) ontstaan_uit
ON  kot.id=ontstaan_uit.kadastraleobjecten_id
WHERE kot.datum_actueel_tot IS NULL;