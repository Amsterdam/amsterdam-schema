create or replace view public.dataverkenner_betrokkenbij_betrokkenbij WITH (security_barrier) as
select 
brk_2_kadastraleobjecten.id as "id",
brk_2_kadastraleobjecten.identificatie as "identificatie",
brk_2_kadastraleobjecten.neuron_id as "neuron_id",
brk_2_kadastraleobjecten.volgnummer as "volgnummer",
brk_2_kadastraleobjecten.kadastrale_aanduiding as "kadastrale_aanduiding",
brk_2_kadastraleobjecten.begin_geldigheid as "begin_geldigheid",
brk_2_kadastraleobjecten.eind_geldigheid as "eind_geldigheid",
brk_2_kadastraleobjecten_is_ontstaan_uit_brk_g_perceel.id as "betroken_bij_id",
brk_2_kadastraleobjecten_is_ontstaan_uit_brk_g_perceel.kadastraleobjecten_id as "betroken_bij_kadastraleobjecten_id",
brk_2_kadastraleobjecten_is_ontstaan_uit_brk_g_perceel.kadastraleobjecten_identificatie as "betroken_bij_identificatie",
brk_2_kadastraleobjecten_is_ontstaan_uit_brk_g_perceel.kadastraleobjecten_volgnummer as "betroken_bij_volgnummer",
brk_2_kadastraleobjecten_is_ontstaan_uit_brk_g_perceel.is_ontstaan_uit_brk_g_perceel_identificatie as "is_ontstaan_uit_brk_g_perceel_identificatie",
brk_2_kadastraleobjecten_is_ontstaan_uit_brk_g_perceel.begin_geldigheid as "betroken_bij_begin_geldigheid",
brk_2_kadastraleobjecten_is_ontstaan_uit_brk_g_perceel.eind_geldigheid as "betroken_bij_eind_geldigheid"
from brk_2_kadastraleobjecten
left join brk_2_kadastraleobjecten_is_ontstaan_uit_brk_g_perceel on brk_2_kadastraleobjecten.id = brk_2_kadastraleobjecten_is_ontstaan_uit_brk_g_perceel.kadastraleobjecten_id;