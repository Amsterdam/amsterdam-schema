create or replace view public.dataverkenner_kadastraleobject_kadastraleobject_v0 WITH (security_barrier) as
select
brk_2_kadastraleobjecten_v2.id as "id",
brk_2_kadastraleobjecten_v2.identificatie as "identificatie",
brk_2_kadastraleobjecten_v2.neuron_id as "neuron_id",
brk_2_kadastraleobjecten_v2.volgnummer as "volgnummer",
brk_2_kadastraleobjecten_v2.kadastrale_aanduiding as "kadastrale_aanduiding",
brk_2_kadastraleobjecten_v2.begin_geldigheid as "begin_geldigheid",
brk_2_kadastraleobjecten_v2.eind_geldigheid as "eind_geldigheid",
brk_2_kadastraleobjecten_v2.aangeduid_door_brk_kadastralegemeentecode_id as "aangeduid_door_brk_kadastralegemeentecode_id",
brk_2_kadastraleobjecten_v2.aangeduid_door_brk_kadastralegemeente_id as "gemeente",
brk_2_kadastraleobjecten_v2.aangeduid_door_brk_kadastralesectie_id as "aangeduid_door_brk_kadastralesectie_id",
brk_2_kadastraleobjecten_v2.indexletter as "indexletter",
brk_2_kadastraleobjecten_v2.indexnummer as "indexnummer",
brk_2_kadastraleobjecten_v2.aangeduid_door_brk_kadastralegemeente_id as "aangeduid_door_brk_kadastralegemeente_id",
brk_2_kadastraleobjecten_v2.grootte as "grootte",
brk_2_kadastraleobjecten_v2.perceelnummer as "perceelnummer",
brk_2_kadastraleobjecten_v2.geometrie as "geometrie",
brk_2_kadastraleobjecten_is_ontstaan_uit_brk_kadastraalobje_v2.id as "ont_uit_id",
brk_2_kadastraleobjecten_is_ontstaan_uit_brk_kadastraalobje_v2.kadastraleobjecten_id as "ont_uit_kadastraleobjecten_id",
brk_2_kadastraleobjecten_is_ontstaan_uit_brk_kadastraalobje_v2.kadastraleobjecten_identificatie as "ont_uit_kadastraleobjecten_identificatie",
brk_2_kadastraleobjecten_is_ontstaan_uit_brk_kadastraalobje_v2.kadastraleobjecten_volgnummer as "ont_uit_kadastraleobjecten_volgnummer",
brk_2_kadastraleobjecten_is_ontstaan_uit_brk_kadastraalobje_v2.is_ontstaan_uit_brk_kadastraalobject_id as "ont_uit_brk_kadastraalobject_id",
brk_2_kadastraleobjecten_is_ontstaan_uit_brk_kadastraalobje_v2.is_ontstaan_uit_brk_kadastraalobject_identificatie as "ont_uit_brk_kadastraalobject_identificatie",
brk_2_kadastraleobjecten_is_ontstaan_uit_brk_kadastraalobje_v2.is_ontstaan_uit_brk_kadastraalobject_volgnummer as "ont_uit_brk_kadastraalobject_volgnummer",
brk_2_kadastraleobjecten_is_ontstaan_uit_brk_kadastraalobje_v2.begin_geldigheid as "ont_uit_begin_geldigheid",
brk_2_kadastraleobjecten_is_ontstaan_uit_brk_kadastraalobje_v2.eind_geldigheid as "ont_uit_eind_geldigheid",
brk_2_kadastraleobjecten_hft_rel_mt_vot_v2.hft_rel_mt_vot_identificatie as "heeft_een_relatie_met_bag_verblijfsobject_identificatie"
from brk_2_kadastraleobjecten_v2
left join brk_2_kadastraleobjecten_is_ontstaan_uit_brk_kadastraalobje_v2 on brk_2_kadastraleobjecten_v2.id = brk_2_kadastraleobjecten_is_ontstaan_uit_brk_kadastraalobje_v2.kadastraleobjecten_id
left join brk_2_kadastraleobjecten_hft_rel_mt_vot_v2 on brk_2_kadastraleobjecten_v2.id = brk_2_kadastraleobjecten_hft_rel_mt_vot_v2.kadastraleobjecten_id
where brk_2_kadastraleobjecten_v2.datum_actueel_tot is null
and brk_2_kadastraleobjecten_is_ontstaan_uit_brk_kadastraalobje_v2.eind_geldigheid is null
and brk_2_kadastraleobjecten_hft_rel_mt_vot_v2.eind_geldigheid is null;
