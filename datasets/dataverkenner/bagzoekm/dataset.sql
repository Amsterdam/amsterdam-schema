CREATE MATERIALIZED VIEW IF NOT EXISTS public.dataverkenner_bagzoekm_bagzoek_v1 as
select
bag_nummeraanduidingen_v1.id as "id",
bag_nummeraanduidingen_v1.identificatie as "identificatie",
bag_nummeraanduidingen_v1.volgnummer as "volgnummer",
bag_nummeraanduidingen_v1.adresseert_verblijfsobject_identificatie as "adresseert_verblijfsobject_identificatie",
bag_nummeraanduidingen_v1.huisnummer as "huisnummer",
bag_nummeraanduidingen_v1.huisletter as "huisletter",
bag_nummeraanduidingen_v1.huisnummertoevoeging as "huisnummertoevoeging",
bag_nummeraanduidingen_v1.postcode as "postcode",
bag_nummeraanduidingen_v1.type_adres as "type_adres",
bag_nummeraanduidingen_v1.begin_geldigheid as "begin_geldigheid",
bag_nummeraanduidingen_v1.eind_geldigheid as "eind_geldigheid",
bag_openbareruimtes_v1.identificatie as "openbareruimte_identificatie",
bag_openbareruimtes_v1.naam as "openbareruimte_naam",
bag_openbareruimtes_v1.type_code as "openbareruimte_type_code",
bag_woonplaatsen_v1.naam as "woonplaats_naam",
bag_woonplaatsen_v1.identificatie as "woonplaats_identificatie",
bag_verblijfsobjecten_v1.id as "verblijfsobject_id",
bag_verblijfsobjecten_v1.identificatie as "verblijfsobject_identificatie",
bag_verblijfsobjecten_v1.volgnummer as "verblijfsobject_volgnummer",
bag_verblijfsobjecten_v1.geometrie as "verblijfsobject_geometrie"
from bag_nummeraanduidingen_v1
left join bag_openbareruimtes_v1 on bag_nummeraanduidingen_v1.ligt_aan_openbareruimte_id = bag_openbareruimtes_v1.id
left join bag_verblijfsobjecten_v1 on bag_nummeraanduidingen_v1.adresseert_verblijfsobject_id=bag_verblijfsobjecten_v1.id
left join bag_woonplaatsen_v1 on bag_nummeraanduidingen_v1.ligt_in_woonplaats_id = bag_woonplaatsen_v1.id
where bag_nummeraanduidingen_v1.eind_geldigheid is null
and bag_nummeraanduidingen_v1.status_omschrijving = 'Naamgeving uitgegeven'
and bag_openbareruimtes_v1.eind_geldigheid is null
and bag_openbareruimtes_v1.status_omschrijving = 'Naamgeving uitgegeven'
and bag_verblijfsobjecten_v1.eind_geldigheid is null
and bag_verblijfsobjecten_v1.status_omschrijving in ('Verblijfsobject gevormd','Verblijfsobject in gebruik (niet ingemeten)','Verblijfsobject in gebruik','Verblijfsobject buiten gebruik','Verbouwing verblijfsobject')
and bag_woonplaatsen_v1.eind_geldigheid is null
and bag_woonplaatsen_v1.status_omschrijving = 'Woonplaats aangewezen'
with no data;
