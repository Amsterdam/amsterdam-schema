create or replace view public.dataverkenner_kadastraleobjecten_kadastraleobjecten WITH (security_barrier) as
select 
brk_kadastraleobjecten.id as "id",
brk_kadastraleobjecten.identificatie as "identificatie",
brk_kadastraleobjecten.neuron_id as "neuron_id",
brk_kadastraleobjecten.volgnummer as "volgnummer",
brk_kadastraleobjecten.kadastrale_aanduiding as "kadastrale_aanduiding",
brk_kadastraleobjecten.begin_geldigheid as "begin_geldigheid",
brk_kadastraleobjecten.eind_geldigheid as "eind_geldigheid"
from brk_kadastraleobjecten
left join brk_kadastraleobjecten_hft_rel_mt_vot on brk_kadastraleobjecten.id = kadastraleobjecten_id