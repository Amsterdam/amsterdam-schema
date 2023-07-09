create or replace view public.dataverkenner_bagzoek_bagzoek WITH (security_barrier) as
select
bag_nummeraanduidingen.id as "id",
bag_nummeraanduidingen.identificatie as "identificatie",
bag_nummeraanduidingen.adresseert_verblijfsobject_identificatie as "adresseert_verblijfsobject_identificatie",
bag_nummeraanduidingen.huisnummer as "huisnummer",
bag_nummeraanduidingen.huisletter as "huisletter",
bag_nummeraanduidingen.huisnummertoevoeging as "huisnummertoevoeging",
bag_nummeraanduidingen.postcode as "postcode",
bag_nummeraanduidingen.type_adres as "type_adres",
bag_openbareruimtes.naam as "openbareruimte_naam",
bag_openbareruimtes.type_code as "openbareruimte_type_code",
bag_woonplaatsen.naam as "woonplaats_naam"
from bag_nummeraanduidingen
left join bag_openbareruimtes on bag_nummeraanduidingen.ligt_aan_openbareruimte_id = bag_openbareruimtes.id
left join bag_woonplaatsen on bag_nummeraanduidingen.ligt_in_woonplaats_id = bag_woonplaatsen.id
