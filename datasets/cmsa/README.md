Toelichtende documentatie bij CMSA-data
===

Versie van oktober 2022.
Algemeen
---
De data uit de Crowd Monitoring Systeem Amsterdam (CMSA)-sensoren leveren informatie uit de 
openbare ruimte over aantallen passanten. Deze informatie wordt in de operatie gebruikt ter
ondersteuning bij drukte management. En bij analyses om een beeld te krijgen bij de ontwikkeling
van drukte in de tijd.

De volgende doelen zijn daarbij leidend:
* Het vermijden en beheersen van onveilige situaties (veiligheid);
* Een goede voetgangersbereikbaarheid van publieksfuncties en goede doorstroming van het
verkeer in een groter gebied rond de drukke locaties (bereikbaarheid en doorstroming);
* Een kwalitatief hoogwaardige openbare ruimte waarin voetgangers zich welkom, veilig en
comfortabel voelen (kwaliteit en comfort).
* Bij de sensor worden passages gemeten. Hierbij worden geen unieke kenmerken van een passant
opgeslagen. Het is dus niet mogelijk om passanten te volgen. Ook is het daarom niet mogelijk om
unieke bezoekers van een gebied te rapporteren.

Bij de sensor worden passages gemeten. Hierbij worden geen unieke kenmerken van een passant
opgeslagen. Het is dus niet mogelijk om passanten te volgen. Ook is het daarom niet mogelijk om
unieke bezoekers van een gebied te rapporteren.

Privacyverklaring van het CMSA
---
Via deze link is meer achtergrondinformatie te vinden over de doelstelling, de grondslagen en de
(technische werking van de) sensoren.
https://www.amsterdam.nl/privacy/specifieke/privacyverklaring-parkeren-verkeer-bouw/crowd-monitoring-systeem-amsterdam/

Overzicht van de sensorlocaties
---
https://maps.Amsterdam.nl/CMSA

Hier is ook zichtbaar of de sensor actief is of niet, middels het selectievak links onderin.
Niet-actieve sensoren zijn sensoren die inmiddels verwijderd zijn.

Open data
---
Via een API<sup>[1](#f1)</sup> wordt door Amsterdam gestructureerd ingewonnen data publiek beschikbaar
gemaakt als dataset, geaggregeerd op uurniveau.

https://api.data.amsterdam.nl/v1/crowdmonitor/passanten/

Via onderstaande API is op te vragen waar de sensoren staan of gestaan hebben.
https://api.data.amsterdam.nl/waarnemingen/mensen/telcameras/v1/sensor/

Niet alle sensoren in deze API leveren (actuele) data. Dat kan de volgende redenen hebben:
* Het veld “actief” heeft de waarde “Nee”
  * De sensor is niet meer actief, en levert dus geen actuele data meer.
* Het veld “is_public” heeft dan de waarde “false”
  * Data komt uit sensoren van partners. De gemeente Amsterdam is geen eigenaar van
die data. De gemeente kan deze data dan raadplegen maar mag dit niet verder
verspreiden.
  * Data uit sensoren die een korte periode hangen.
  * Sensoren zijn nog niet gevalideerd.

Bereik data
---
Vanaf 2019 wordt in Amsterdam structureel passanten geteld, vooral in het Wallengebied, het
winkelgebied Centrum en bij de IJveren. Het drukte monitoren met het CMSA is (in 2018)
begonnen als pilot, waarbij is onderzocht wat de toegevoegde waarde van de informatie uit de
sensoren is, hoe de data op verschillende manieren kan bijdragen en goed de sensoren zelf zijn.
Vanaf augustus 2019 is overgegaan op een structurele inzet van metingen en opslag van drukte
data.

Publiek beschikbare data en de nauwkeurigheid van Sensoren
---
De sensordata komt direct beschikbaar via api.data.amsterdam.nl. Deze sensordata blijkt over het
algemeen betrouwbaar en (voldoende) nauwkeurig. Om de nauwkeurigheid van de sensoren
definitief (achteraf) vast te stellen worden de sensoren steekproefsgewijs gevalideerd. Hiertoe
wordt per sensor op meerdere momenten, met verschillende omstandigheden (qua weer, drukte,
licht/donker) de data gevalideerd met de werkelijke situatie. Hieruit blijkt dat sensoren onderling
soms verschillend presteren, en de data (mede) daardoor niet altijd 1 op 1 met elkaar te vergelijken
is. Met het toepassen van correctiefactoren voor de verschillende typen sensoren op dezelfde
wegvakken worden de sensoren onderling vergelijkbaar, ook als de sensor zelf vervangen is. Dit
resulteert in definitieve datasets. Deze definitieve datasets worden door de gemeente gebruikt
voor analyses. Zie als voorbeeld het rapport Drukte in het Wallengebied Zomer 2018 – zomer 2019.
De eventuele correctiefactoren worden dus achteraf toegepast. Dat is een praktische keuze,
waarbij leidend is de wens om de data zo spoedig mogelijk beschikbaar te stellen aan het publiek.

Disclaimer
---
Rapportages van de Gemeente Amsterdam zijn leidend.
De Gemeente Amsterdam voert nabewerkingen op de beschikbaar gestelde ruwe data uit. De
gegenereerde rapportages door de Gemeente Amsterdam leveren dus andere intensiteiten op dan
de ruwe data. Dit heeft te maken met een aantal zaken, waaronder;
* Correctiefactoren t.g.v. validaties als hiervoor beschreven.
* Sensoren zijn tussentijds vervangen, vanwege aanbestedingsregels en/of verbeterde
sensortechnieken.
* Aantallen van minder dan 15 passanten per uur worden niet in de API weergegeven. Wanneer
er minder dan 15 passanten per uur langs de sensor zijn gekomen wordt ‘0’ gerapporteerd.
* Er zitten soms onderbrekingen of afwijkingen in de dataset, bijvoorbeeld door een
sensorstoring of omgevingsfactoren (zoals werkzaamheden voor de sensor) waardoor de
sensor afwijkende data rapporteert.

Aan de dataset kunnen geen rechten worden ontleend. De gebruiker van de data wordt verzocht
om ook zelf een plausibiliteitscheck te doen op de cijfers. Mocht u fouten tegenkomen neem dan
contact op met LVMA@amsterdam.nl

Begrippen
---
* CMSA: Crowd Monitoring Systeem Amsterdam
* LVMA: Langzaam Verkeer Monitoringssysteem Amsterdam
(Fietsers kunnen ook worden geteld, sinds 2021 is het programma CMSA hernoemd naar
LVMA. Hierdoor lopen naamgevingen nog door elkaar heen.)

<b id="f1">1</b> API: application programming interface. Dit wordt gebruikt om op een geformaliseerde manier gegevens uit te
wisselen tussen applicaties of diensten. Zie ook: https://api.data.amsterdam.nl/v1/docs/#
