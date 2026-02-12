CREATE MATERIALIZED VIEW IF NOT EXISTS public.dataverkenner_kadastraleobjectm_kadastraleobject_v1 as
WITH verblijfsobjecten as
     (
              select
                       kadastraleobjecten_id
                     , array_agg(hft_rel_mt_vot_identificatie) as vots
              from
                       brk_2_kadastraleobjecten_hft_rel_mt_vot_v2
              WHERE eind_geldigheid IS null
              group by
                       kadastraleobjecten_id
     )
select
brk_2_kadastraleobjecten_v2.id as "id",
brk_2_kadastraleobjecten_v2.identificatie as "identificatie",
brk_2_kadastraleobjecten_v2.neuron_id as "neuron_id",
brk_2_kadastraleobjecten_v2.volgnummer as "volgnummer",
brk_2_kadastraleobjecten_v2.kadastrale_aanduiding as "kadastrale_aanduiding",
brk_2_kadastraleobjecten_v2.begin_geldigheid as "begin_geldigheid",
brk_2_kadastraleobjecten_v2.eind_geldigheid as "eind_geldigheid",
brk_2_kadastraleobjecten_v2.aangeduid_door_brk_kadastralegemeentecode_id as "aangeduid_door_brk_kadastralegemeentecode_id",
brk_2_kadastraleobjecten_v2.aangeduid_door_brk_kadastralegemeente_id as "aangeduid_door_brk_kadastralegemeente_id",
brk_2_kadastraleobjecten_v2.aangeduid_door_brk_kadastralesectie_id as "aangeduid_door_brk_kadastralesectie_id",
brk_2_kadastraleobjecten_v2.indexletter as "indexletter",
brk_2_kadastraleobjecten_v2.indexnummer as "indexnummer",
brk_2_kadastraleobjecten_v2.aangeduid_door_brk_gemeente_id as "aangeduid_door_brk_gemeente_id",
brk_2_gemeentes_v1.naam  as "aangeduid_door_brk_gemeente",
brk_2_kadastraleobjecten_v2.grootte as "grootte",
brk_2_kadastraleobjecten_v2.perceelnummer as "perceelnummer",
brk_2_kadastraleobjecten_v2.soort_cultuur_onbebouwd_omschrijving as "soort_cultuur_onbebouwd_omschrijving",
brk_2_kadastraleobjecten_v2.soort_cultuur_bebouwd_omschrijving as "soort_cultuur_bebouwd_omschrijving",
brk_2_kadastraleobjecten_v2.koopsom as "koopsom",
brk_2_kadastraleobjecten_v2.koopjaar as "koopjaar",
brk_2_kadastraleobjecten_v2.indicatie_meer_objecten as "indicatie_meer_objecten",
brk_2_kadastraleobjecten_v2.soort_grootte_omschrijving as "soort_grootte_omschrijving",
brk_2_kadastraleobjecten_v2.toestandsdatum as "toestandsdatum",
brk_2_kadastraleobjecten_v2.in_onderzoek as "in_onderzoek",
brk_2_kadastraleobjecten_v2.indicatie_voorlopige_kadastrale_grens as "indicatie_voorlopige_kadastrale_grens",
verblijfsobjecten.vots::_VARCHAR as "heeft_een_relatie_met_bag_verblijfsobject_identificaties",
brk_2_kadastraleobjecten_v2.geometrie
from brk_2_kadastraleobjecten_v2
LEFT JOIN verblijfsobjecten ON brk_2_kadastraleobjecten_v2.id=verblijfsobjecten.kadastraleobjecten_id
LEFT JOIN brk_2_gemeentes_v1 ON brk_2_kadastraleobjecten_v2.aangeduid_door_brk_gemeente_id=brk_2_gemeentes_v1.id
where brk_2_kadastraleobjecten_v2.datum_actueel_tot is null
AND brk_2_gemeentes_v1.eind_geldigheid IS NULL
with no data;
