create or replace view public.dataverkenner_zakelijkerechten_zakelijkerechten WITH (security_barrier) as
select 
brk_2_zakelijkerechten.id as "id",
brk_2_zakelijkerechten.identificatie as "identificatie",
brk_2_zakelijkerechten.volgnummer as "volgnummer",
brk_2_zakelijkerechten.rust_op_brk_kadastraal_object_identificatie as "rust_op_brk_kadastraal_object_identificatie",
brk_2_zakelijkerechten.aard_zakelijk_recht_omschrijving as "aard_zakelijk_recht_omschrijving",
brk_2_zakelijkerechten.begin_geldigheid as "begin_geldigheid",
brk_2_zakelijkerechten.eind_geldigheid as "eind_geldigheid"
from brk_2_zakelijkerechten