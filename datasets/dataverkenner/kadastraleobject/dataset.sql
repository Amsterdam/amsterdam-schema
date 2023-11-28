create or replace view public.dataverkenner_kadastraleobject_kadastraleobject WITH (security_barrier) as
select 
z.id as "id",
z.identificatie as "identificatie",
z.volgnummer as "volgnummer",
z.koopsom as "koopsom",
z.koopjaar as "koopjaar",
z.soort_cultuur_onbebouwd_code as "soort_cultuur_onbebouwd_code",
z.soort_cultuur_onbebouwd_omschrijving as "soort_cultuur_onbebouwd_omschrijving",
z.soort_cultuur_bebouwd_code as "soort_cultuur_bebouwd_code",
z.soort_cultuur_bebouwd_omschrijving as "soort_cultuur_bebouwd_omschrijving",
a.begin_geldigheid as "ont_uit_begin_geldigheid",
a.eind_geldigheid as "ont_uit_eind_geldigheid",
b.hft_rel_mt_vot_identificatie as "heeft_een_relatie_met_bag_verblijfsobject_identificatie"
from brk_2_kadastraleobjecten z
left join brk_2_kadastraleobjecten_is_ontstaan_uit_brk_kadastraalobject a on z.id = a.kadastraleobjecten_id
left join brk_2_kadastraleobjecten_hft_rel_mt_vot b on z.id = b.kadastraleobjecten_id;