create or replace view public.dataverkenner_kadastraleobjecten_kadastraleobjecten WITH (security_barrier) as
select 
brk_2_kadastraleobjecten.id as "id",
brk_2_kadastraleobjecten.identificatie as "identificatie",
brk_2_kadastraleobjecten.neuron_id as "neuron_id",
brk_2_kadastraleobjecten.volgnummer as "volgnummer",
brk_2_kadastraleobjecten.kadastrale_aanduiding as "kadastrale_aanduiding",
brk_2_kadastraleobjecten.begin_geldigheid as "begin_geldigheid",
brk_2_kadastraleobjecten.eind_geldigheid as "eind_geldigheid",
brk_2_kadastraleobjecten.aangeduid_door_brk_kadastralegemeentecode_id as "aangeduid_door_brk_kadastralegemeentecode_id",
brk_2_kadastraleobjecten.aangeduid_door_brk_kadastralesectie_id as "aangeduid_door_brk_kadastralesectie_id",
brk_2_kadastraleobjecten.indexletter as "indexletter",
brk_2_kadastraleobjecten.indexnummer as "indexnummer",
brk_2_kadastraleobjecten.aangeduid_door_brk_kadastralegemeente_id as "aangeduid_door_brk_kadastralegemeente_id",
brk_2_kadastraleobjecten.grootte as "grootte",
brk_2_kadastraleobjecten.koopsom as "koopsom",
brk_2_kadastraleobjecten.koopjaar as "koopjaar",
brk_2_kadastraleobjecten.soort_cultuur_onbebouwd_code as "soort_cultuur_onbebouwd_code",
brk_2_kadastraleobjecten.soort_cultuur_onbebouwd_omschrijving as "soort_cultuur_onbebouwd_omschrijving",
brk_2_kadastraleobjecten.soort_cultuur_bebouwd_code as "soort_cultuur_bebouwd_code",
brk_2_kadastraleobjecten.soort_cultuur_bebouwd_omschrijving as "soort_cultuur_bebouwd_omschrijving",
brk_2_kadastraleobjecten_hft_rel_mt_vot.hft_rel_mt_vot_identificatie as "heeft_een_relatie_met_bag_verblijfsobject_identificatie"
from brk_2_kadastraleobjecten
left join brk_2_kadastraleobjecten_hft_rel_mt_vot on brk_2_kadastraleobjecten.id = kadastraleobjecten_id;