CREATE MATERIALIZED VIEW IF NOT EXISTS public.dataverkenner_bagadresinformatiem_bagadresinformatie_v1 as
select
bag_nummeraanduidingen.id as "id",
bag_nummeraanduidingen.identificatie as "identificatie",
bag_nummeraanduidingen.volgnummer as "volgnummer",
bag_nummeraanduidingen.huisnummer as "huisnummer",
bag_nummeraanduidingen.huisletter as "huisletter",
bag_nummeraanduidingen.huisnummertoevoeging as "huisnummertoevoeging",
bag_nummeraanduidingen.postcode as "postcode",
bag_nummeraanduidingen.type_adresseerbaar_object_omschrijving as "type_adresseerbaar_object_omschrijving",
bag_nummeraanduidingen.type_adres as "type_adres",
bag_nummeraanduidingen.adresseert_verblijfsobject_identificatie as "adresseert_verblijfsobject_identificatie",
bag_nummeraanduidingen.begin_geldigheid as "begin_geldigheid",
bag_nummeraanduidingen.documentdatum as "documentdatum",
bag_nummeraanduidingen.documentnummer as "documentnummer",
bag_nummeraanduidingen.eind_geldigheid as "eind_geldigheid",
bag_openbareruimtes.identificatie as "openbareruimte_identificatie",
bag_openbareruimtes.volgnummer as "openbareruimte_volgnummer",
bag_openbareruimtes.type_omschrijving as "openbareruimte_type_omschrijving",
bag_openbareruimtes.naam as "openbareruimte_naam",
bag_woonplaatsen.identificatie as "woonplaats_identificatie",
bag_woonplaatsen.volgnummer as "woonplaats_volgnummer",
bag_woonplaatsen.naam as "woonplaats_naam",
bag_verblijfsobjecten.id as "verblijfsobject_id",
bag_verblijfsobjecten.identificatie as "verblijfsobject_identificatie",
bag_verblijfsobjecten.volgnummer as "verblijfsobject_volgnummer",
bag_verblijfsobjecten.geconstateerd as "verblijfsobject_geconstateerd",
bag_verblijfsobjecten.geometrie as "verblijfsobject_geometrie",
bag_verblijfsobjecten.oppervlakte as "verblijfsobject_oppervlakte",
bag_verblijfsobjecten.status_omschrijving as "verblijfsobject_status_omschrijving",
bag_verblijfsobjecten.gebruiksdoel_woonfunctie_omschrijving as "verblijfsobject_gebruiksdoel_woonfunctie_omschrijving",
bag_verblijfsobjecten.gebruiksdoel_gezondheidszorgfunctie_omschrijving as "verblijfsobject_gebruiksdoel_gezondheidszorgfunctie",
bag_verblijfsobjecten.aantal_eenheden_complex as "verblijfsobject_aantal_eenheden_complex",
bag_verblijfsobjecten.verdieping_toegang as "verblijfsobject_verdieping_toegang",
bag_verblijfsobjecten.aantal_bouwlagen as "verblijfsobject_aantal_bouwlagen",
bag_verblijfsobjecten.hoogste_bouwlaag as "verblijfsobject_hoogste_bouwlaag",
bag_verblijfsobjecten.laagste_bouwlaag as "verblijfsobject_laagste_bouwlaag",
bag_verblijfsobjecten.aantal_kamers as "verblijfsobject_aantal_kamers",
bag_verblijfsobjecten.eigendomsverhouding_omschrijving as "verblijfsobject_eigendomsverhouding_omschrijving",
bag_verblijfsobjecten.feitelijk_gebruik_omschrijving as "verblijfsobject_feitelijk_gebruik_omschrijving",
bag_verblijfsobjecten.redenopvoer_omschrijving as "verblijfsobject_redenopvoer_omschrijving",
bag_verblijfsobjecten.redenafvoer_omschrijving as "verblijfsobject_redenafvoer_omschrijving",
bag_onderzoeken.object_identificatie as "onderzoeken_object_identificatie",
bag_verblijfsobjecten.documentdatum as "verblijfsobject_documentdatum",
bag_verblijfsobjecten.documentnummer as "verblijfsobject_documentnummer",
bag_verblijfsobjecten.begin_geldigheid as "verblijfsobject_begin_geldigheid",
bag_verblijfsobjecten.eind_geldigheid as "verblijfsobject_eind_geldigheid",
bag_onderzoeken.volgnummer as "onderzoeken_volgnummer",
bag_onderzoeken.in_onderzoek as "onderzoeken_in_onderzoek",
bag_onderzoeken.begin_geldigheid as "onderzoeken_begin_geldigheid",
bag_onderzoeken.eind_geldigheid as "onderzoeken_eind_geldigheid",
bag_ligplaatsen.identificatie as "ligplaats_identificatie",
bag_ligplaatsen.volgnummer as "ligplaats_volgnummer",
bag_ligplaatsen.geconstateerd as "ligplaats_geconstateerd",
bag_ligplaatsen.status_omschrijving as "ligplaats_status_omschrijving",
bag_ligplaatsen.geometrie as "ligplaats_geometrie",
bag_ligplaatsen.begin_geldigheid as "ligplaats_begin_geldigheid",
bag_ligplaatsen.eind_geldigheid as "ligplaats_eind_geldigheid",
bag_ligplaatsen.documentdatum as "ligplaats_documentdatum",
bag_ligplaatsen.documentnummer as "ligplaats_documentnummer",
bag_standplaatsen.identificatie as "standplaats_identificatie",
bag_standplaatsen.volgnummer as "standplaats_volgnummer",
bag_standplaatsen.geconstateerd as "standplaats_geconstateerd",
bag_standplaatsen.status_omschrijving as "standplaats_status_omschrijving",
bag_standplaatsen.geometrie as "standplaats_geometrie",
bag_standplaatsen.begin_geldigheid as "standplaats_begin_geldigheid",
bag_standplaatsen.eind_geldigheid as "standplaats_eind_geldigheid",
bag_standplaatsen.documentdatum as "standplaats_documentdatum",
bag_standplaatsen.documentnummer as "standplaats_documentnummer",
gebieden_buurten.identificatie as "gebieden_buurt_identificatie",
gebieden_buurten.volgnummer as "gebieden_buurt_volgnummer",
gebieden_buurten.naam as "gebieden_buurt_naam",
gebieden_buurten.code as "gebieden_buurt_code",
gebieden_wijken.identificatie as "gebieden_wijk_identificatie",
gebieden_wijken.volgnummer as "gebieden_wijk_volgnummer",
gebieden_wijken.naam as "gebieden_wijk_naam",
gebieden_wijken.code as "gebieden_wijk_code",
gebieden_stadsdelen.identificatie as "gebieden_stadsdeel_identificatie",
gebieden_stadsdelen.volgnummer as "gebieden_stadsdeel_volgnummer",
gebieden_stadsdelen.naam as "gebieden_stadsdeel_naam",
gebieden_stadsdelen.code as "gebieden_stadsdeel_code",
gebieden_ggwgebieden.identificatie as "gebieden_ggwgebied_identificatie",
gebieden_ggwgebieden.volgnummer as "gebieden_ggwgebied_volgnummer",
gebieden_ggwgebieden.naam as "gebieden_ggwgebied_naam",
gebieden_ggwgebieden.code as "gebieden_ggwgebied_code",
gebieden_bouwblokken.identificatie as "gebieden_bouwblok_identificatie",
gebieden_bouwblokken.volgnummer as "gebieden_bouwblok_volgnummer",
gebieden_bouwblokken.code as "gebieden_bouwblok_code",
bag_panden.identificatie as "pand_identificatie",
bag_panden.volgnummer as "pand_volgnummer",
bag_verblijfsobjecten_gebruiksdoel.omschrijving as "gebruiksdoel_omschrijving",
bag_verblijfsobjecten_toegang.omschrijving as "toegang_omschrijving"
from bag_nummeraanduidingen
left join bag_openbareruimtes on bag_nummeraanduidingen.ligt_aan_openbareruimte_id = bag_openbareruimtes.id
left join bag_woonplaatsen on bag_nummeraanduidingen.ligt_in_woonplaats_id = bag_woonplaatsen.id
left join bag_verblijfsobjecten on bag_nummeraanduidingen.adresseert_verblijfsobject_id=bag_verblijfsobjecten.id
left join bag_ligplaatsen on bag_nummeraanduidingen.adresseert_ligplaats_id = bag_ligplaatsen.id
left join bag_standplaatsen on bag_nummeraanduidingen.adresseert_standplaats_id = bag_standplaatsen.id
left join bag_onderzoeken on bag_verblijfsobjecten.identificatie = bag_onderzoeken.object_identificatie
OR bag_standplaatsen.identificatie = bag_onderzoeken.object_identificatie
OR bag_ligplaatsen.identificatie = bag_onderzoeken.object_identificatie
left join gebieden_buurten on bag_verblijfsobjecten.ligt_in_buurt_id=gebieden_buurten.id
OR bag_standplaatsen.ligt_in_buurt_id = gebieden_buurten.id
OR bag_ligplaatsen.ligt_in_buurt_id = gebieden_buurten.id
left join gebieden_wijken on gebieden_buurten.ligt_in_wijk_id = gebieden_wijken.id
left join gebieden_stadsdelen on gebieden_wijken.ligt_in_stadsdeel_id = gebieden_stadsdelen.id
left join gebieden_ggwgebieden on gebieden_buurten.ligt_in_ggwgebied_id = gebieden_ggwgebieden.id
left join bag_verblijfsobjecten_ligt_in_panden on bag_verblijfsobjecten.id = bag_verblijfsobjecten_ligt_in_panden.verblijfsobjecten_id
left join bag_panden on bag_panden.id = bag_verblijfsobjecten_ligt_in_panden.ligt_in_panden_id
left join gebieden_bouwblokken on bag_panden.ligt_in_bouwblok_id=gebieden_bouwblokken.id
left join bag_verblijfsobjecten_gebruiksdoel on bag_nummeraanduidingen.adresseert_verblijfsobject_id=bag_verblijfsobjecten_gebruiksdoel.parent_id
left join bag_verblijfsobjecten_toegang on bag_nummeraanduidingen.adresseert_verblijfsobject_id=bag_verblijfsobjecten_toegang.parent_id with no data;
