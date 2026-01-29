CREATE MATERIALIZED VIEW IF NOT EXISTS public.dataverkenner_aantekeningenm_aantekeningen_v1 as
select
brk_2_aantekeningenkadastraleobjecten_v1.id as "id",
brk_2_aantekeningenkadastraleobjecten_v1.identificatie as "identificatie",
brk_2_aantekeningenkadastraleobjecten_v1.volgnummer as "volgnummer",
brk_2_aantekeningenkadastraleobjecten_v1.aard_omschrijving as "aard_omschrijving",
brk_2_aantekeningenkadastraleobjecten_v1.omschrijving as "omschrijving",
brk_2_aantekeningenkadastraleobjecten_v1.hft_btrk_op_kot_identificatie as "hft_btrk_op_kot_identificatie",
brk_2_aantekeningenkadastraleobjecten_v1.begin_geldigheid as "begin_geldigheid",
brk_2_aantekeningenkadastraleobjecten_v1.eind_geldigheid as "eind_geldigheid"
from brk_2_aantekeningenkadastraleobjecten_v1
WHERE datum_actueel_tot IS null
with no data;

SELECT cron.schedule('dataverkenner_aantekeningenm_aantekeningen_refresh', '40 22 * * *', 'REFRESH MATERIALIZED VIEW public.dataverkenner_aantekeningenm_aantekeningen_v1');
