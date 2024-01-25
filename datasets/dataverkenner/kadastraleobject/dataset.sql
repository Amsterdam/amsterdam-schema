create or replace view public.dataverkenner_kadastraleobject_kadastraleobject WITH (security_barrier) as
select 
brk_2_kadastraleobjecten.id as "id",
brk_2_kadastraleobjecten.identificatie as "identificatie",
brk_2_kadastraleobjecten.neuron_id as "neuron_id",
brk_2_kadastraleobjecten.volgnummer as "volgnummer",
brk_2_kadastraleobjecten.kadastrale_aanduiding as "kadastrale_aanduiding",
brk_2_kadastraleobjecten.begin_geldigheid as "begin_geldigheid",
brk_2_kadastraleobjecten.eind_geldigheid as "eind_geldigheid",
brk_2_kadastraleobjecten.aangeduid_door_brk_kadastralegemeentecode_id as "aangeduid_door_brk_kadastralegemeentecode_id",
brk_2_kadastraleobjecten.aangeduid_door_brk_kadastralegemeente_id as "gemeente",
brk_2_kadastraleobjecten.aangeduid_door_brk_kadastralesectie_id as "aangeduid_door_brk_kadastralesectie_id",
brk_2_kadastraleobjecten.indexletter as "indexletter",
brk_2_kadastraleobjecten.indexnummer as "indexnummer",
brk_2_kadastraleobjecten.aangeduid_door_brk_kadastralegemeente_id as "aangeduid_door_brk_kadastralegemeente_id",
brk_2_kadastraleobjecten.grootte as "grootte",
brk_2_kadastraleobjecten.perceelnummer as "perceelnummer",
brk_2_kadastraleobjecten.geometrie as "geometrie",
brk_2_kadastraleobjecten_is_ontstaan_uit_brk_kadastraalobject.id as "ont_uit_id",
brk_2_kadastraleobjecten_is_ontstaan_uit_brk_kadastraalobject.kadastraleobjecten_id as "ont_uit_kadastraleobjecten_id",
brk_2_kadastraleobjecten_is_ontstaan_uit_brk_kadastraalobject.kadastraleobjecten_identificatie as "ont_uit_kadastraleobjecten_identificatie",
brk_2_kadastraleobjecten_is_ontstaan_uit_brk_kadastraalobject.kadastraleobjecten_volgnummer as "ont_uit_kadastraleobjecten_volgnummer",
brk_2_kadastraleobjecten_is_ontstaan_uit_brk_kadastraalobject.is_ontstaan_uit_brk_kadastraalobject_id as "ont_uit_brk_kadastraalobject_id",
brk_2_kadastraleobjecten_is_ontstaan_uit_brk_kadastraalobject.is_ontstaan_uit_brk_kadastraalobject_identificatie as "ont_uit_brk_kadastraalobject_identificatie",
brk_2_kadastraleobjecten_is_ontstaan_uit_brk_kadastraalobject.is_ontstaan_uit_brk_kadastraalobject_volgnummer as "ont_uit_brk_kadastraalobject_volgnummer",
brk_2_kadastraleobjecten_is_ontstaan_uit_brk_kadastraalobject.begin_geldigheid as "ont_uit_begin_geldigheid",
brk_2_kadastraleobjecten_is_ontstaan_uit_brk_kadastraalobject.eind_geldigheid as "ont_uit_eind_geldigheid",
brk_2_kadastraleobjecten_hft_rel_mt_vot.hft_rel_mt_vot_identificatie as "heeft_een_relatie_met_bag_verblijfsobject_identificatie"
from brk_2_kadastraleobjecten
left join brk_2_kadastraleobjecten_is_ontstaan_uit_brk_kadastraalobject on brk_2_kadastraleobjecten.id = brk_2_kadastraleobjecten_is_ontstaan_uit_brk_kadastraalobject.kadastraleobjecten_id
left join brk_2_kadastraleobjecten_hft_rel_mt_vot on brk_2_kadastraleobjecten.id = brk_2_kadastraleobjecten_hft_rel_mt_vot.kadastraleobjecten_id
where brk_2_kadastraleobjecten.datum_actueel_tot is null
and brk_2_kadastraleobjecten_is_ontstaan_uit_brk_kadastraalobject.eind_geldigheid is null
and brk_2_kadastraleobjecten_hft_rel_mt_vot.eind_geldigheid is null;