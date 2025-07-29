create or replace view public.dataverkenner_bagzoek_bagzoek_v1 WITH (security_barrier) as
select
bag_nummeraanduidingen.id as "id",
bag_nummeraanduidingen.identificatie as "identificatie",
bag_nummeraanduidingen.volgnummer as "volgnummer",
bag_nummeraanduidingen.adresseert_verblijfsobject_identificatie as "adresseert_verblijfsobject_identificatie",
bag_nummeraanduidingen.huisnummer as "huisnummer",
bag_nummeraanduidingen.huisletter as "huisletter",
bag_nummeraanduidingen.huisnummertoevoeging as "huisnummertoevoeging",
bag_nummeraanduidingen.postcode as "postcode",
bag_nummeraanduidingen.type_adres as "type_adres",
bag_nummeraanduidingen.begin_geldigheid as "begin_geldigheid",
bag_nummeraanduidingen.eind_geldigheid as "eind_geldigheid",
bag_openbareruimtes.identificatie as "openbareruimte_identificatie",
bag_openbareruimtes.naam as "openbareruimte_naam",
bag_openbareruimtes.type_code as "openbareruimte_type_code",
bag_woonplaatsen.naam as "woonplaats_naam",
bag_woonplaatsen.identificatie as "woonplaats_identificatie",
bag_verblijfsobjecten.id as "verblijfsobject_id",
bag_verblijfsobjecten.identificatie as "verblijfsobject_identificatie",
bag_verblijfsobjecten.volgnummer as "verblijfsobject_volgnummer",
bag_verblijfsobjecten.geometrie as "verblijfsobject_geometrie"
from bag_nummeraanduidingen
left join bag_openbareruimtes on bag_nummeraanduidingen.ligt_aan_openbareruimte_id = bag_openbareruimtes.id
left join bag_verblijfsobjecten on bag_nummeraanduidingen.adresseert_verblijfsobject_id=bag_verblijfsobjecten.id
left join bag_woonplaatsen on bag_nummeraanduidingen.ligt_in_woonplaats_id = bag_woonplaatsen.id
where bag_nummeraanduidingen.eind_geldigheid is null
and bag_nummeraanduidingen.status_omschrijving = 'Naamgeving uitgegeven'
and bag_openbareruimtes.eind_geldigheid is null
and bag_openbareruimtes.status_omschrijving = 'Naamgeving uitgegeven'
and bag_verblijfsobjecten.eind_geldigheid is null
and bag_verblijfsobjecten.status_omschrijving in ('Verblijfsobject gevormd', 'Verblijfsobject in gebruik (niet ingemeten)','Verblijfsobject in gebruik','Verblijfsobject buiten gebruik','Verbouwing verblijfsobject')
and bag_woonplaatsen.eind_geldigheid is null
and bag_woonplaatsen.status_omschrijving = 'Woonplaats aangewezen';
