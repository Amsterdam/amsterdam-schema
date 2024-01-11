CREATE MATERIALIZED VIEW IF NOT EXISTS public.dataverkenner_aantekeningen_aantekeningen as
select 
brk_2_aantekeningenkadastraleobjecten.id as "id",
brk_2_aantekeningenkadastraleobjecten.identificatie as "identificatie",
brk_2_aantekeningenkadastraleobjecten.volgnummer as "volgnummer",
brk_2_aantekeningenkadastraleobjecten.aard_omschrijving as "aard_omschrijving",
brk_2_aantekeningenkadastraleobjecten.omschrijving as "omschrijving",
brk_2_aantekeningenkadastraleobjecten.hft_btrk_op_kot_identificatie as "hft_btrk_op_kot_identificatie",
brk_2_aantekeningenkadastraleobjecten.begin_geldigheid as "begin_geldigheid",
brk_2_aantekeningenkadastraleobjecten.eind_geldigheid as "eind_geldigheid"
from brk_2_aantekeningenkadastraleobjecten
WHERE datum_actueel_tot IS null
with no data;