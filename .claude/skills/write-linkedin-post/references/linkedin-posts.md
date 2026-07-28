# LinkedIn corpus (Magnus Rødseth)

Verbatim posts pulled from his profile on 28.07.2026 via the `linkedin-mcp`
skill, newest first. Every post here is first-party. Reposts of other people's
content are excluded because they carry no voice signal.

> **The samples are real, the rules still win.** A couple of the older posts
> contain an em dash or an en dash (Eden Stack launch, Agentic Stack). Those
> predate the hard bans in `write-in-my-voice`. Mirror the rhythm and the warmth,
> never the dashes. See SKILL.md.

**Coverage caveat.** The MCP reported 27 activity items and rendered 12 on both
attempts, silently skipping feed items 6-16 and 21-23 (roughly 2 to 4 months
back). Ten first-party posts across four years survive here, including everything
from the last six months. Add to this file on refresh, do not replace it.

---

## Extracted mannerisms

**Hook**
- Standalone one-sentence first paragraph, always. This is the single most
  consistent structural fact about his posts.
- First person, concrete, understated. "et lite verktøy", "et lite hobbyprosjekt
  jeg syns er litt gøy", "noe så glamorøst som ukeshandelen min".
- Ends on `!` when it is good news, on `.` when it is information.

**Body**
- Paragraphs of one to three sentences, blank line between every one.
- "Kort fortalt:" to compress a project into one sentence.
- Emoji as bullet markers (📊 🧾 💸 🤖 ⚠️ 📋 🇳🇴) or `→` arrows. Never `-` or `*`.
- Numbers exact and early. 30 000 kr, 135 tester, 3 år, halvannen til to timer,
  ett minutt.
- English tech terms code-switched into Norwegian prose untranslated. "tech
  stacken", "agent harness", "realtime multiplayer", "out of the box",
  "long-running agents", "by popular demand".
- Named credit blocks in event posts, one person per line, each with the specific
  thing they covered.
- Real quotes in Norwegian quote marks. «Helvete så addicting».
- Self-deprecation near the end. "Selvsagt ser den litt ræva ut", "Litt flaut,
  men ærlig", "Jaja, det er VM, og Norge vinner kamper. 🤷"
- "Side note:" for a tangent he wants to keep but not build up to.

**Close**
- A question back to the reader, or a DM invite, or a link line.
- Link inline on a `👉` / `👉🏽` line, or "Lenke i kommentarfeltet 👇🏽".
- Thanks to hosts and organisers by name, with 🫶🏽 or similar.

**Emoji set** 🕺 🕺🏽 🤠 🫶🏽 🚀 👉 👉🏽 👇🏽 🔗 🤷 🥵 👋 and the bullet emoji.
One or two decorative ones per post. Never 🙏.

**Language** Norwegian in all ten posts, including the two aimed at an
international market (Eden Stack launch and Product Hunt).

---

## 1. EU AI Act breakdown (1 day, 17 reactions, 2 120 impressions)

Archetype: **Forklaring / nyhet**

> Fellesferien er over, og den første fristen i EU AI Act som faktisk betyr noe for utviklere, er om under en uke. Samtidig ble den største fristen nettopp skjøvet til desember 2027.
>
> 2. august skrus håndhevingen på. Fra da av kan tilsynsmyndighetene i hvert land faktisk gi bøter til dem som bryter reglene. Utsettelsen kom med en endringspakke som ble publisert forrige uke og trer i kraft i dag. Den gjelder de strengeste kravene, altså de som treffer AI på sensitive områder.
>
> Jeg har brukt litt tid på å nøste i hva dette faktisk betyr for et utviklingsteam. Kortversjonen er roligere enn overskriftene tilsier, så hvis du nettopp er tilbake fra sommerferie, kan du senke skuldrene noenlunde.
>
> 🤖 Kodeassistenten din er ikke høyrisiko. Regelverket har en liste over hvilke bruksområder som teller som høyrisiko, og den handler om rekruttering, kredittvurdering, utdanning og kritisk infrastruktur. Vanlig utviklerassistanse står ikke der. Du må etter alt å dømme heller ikke watermarke AI-generert kode.
>
> ⚠️ Dersom organisasjonen din bruker AI til å vurdere hvor godt de ansatte gjør jobben sin, eller til å fordele oppgaver ut fra personlige egenskaper og atferd, havner dere i den strengeste kategorien. Et konkret eksempel er å hente tall om hvordan utviklerne jobber fra GitHub og pøse dem inn i et lederdashboard som vurderer enkeltpersoner.
>
> 📋 Dersom teamet ditt bruker modeller gjennom et API, er dere hva regelverket kaller en "deployer", altså den som tar systemet i bruk. De tunge pliktene ligger hos den som har laget modellen. Dere arver dem ikke ved å bruke API-et, og heller ikke ved vanlig fine-tuning, altså å videre trene en modell på egne data.
>
> 🇳🇴 Norge er strengt tatt ikke bundet ennå. Regelverket er ikke tatt inn i EØS-avtalen, som er det som gjør EU-regler gjeldende hos oss, og den norske KI-loven er ikke lagt frem for Stortinget. Men selger du produktet ditt inn i EU, gjelder reglene deg allerede, uansett hvor selskapet ditt ligger.
>
> Det som faktisk treffer 2. august, er kravene til åpenhet i artikkel 50. Brukerne skal vite at de snakker med en AI, og innhold som er generert av AI skal merkes slik at programvare kan kjenne det igjen. Har produktet ditt en chatbot eller lager det innhold for brukere i EU, er det verdt en sjekk denne uka.
>
> Hvordan står det til hos dere? Jeg er nysgjerrig på om dette faktisk er på radaren rundt om i Norge, eller om det er en av de tingene som drukner i backlogen.
>
> 👉🏽 Les hele gjennomgangen her: https://lnkd.in/ecPxeZqA

---

## 2. Claude Fable game with Lars Tønder (2 weeks, 47 reactions, 6 768 impressions)

Archetype: **Bygg / ship**, playful variant. Note the curiosity-question hook and
the "Side note:" tangent.

> Hvor langt kan du egentlig ta Claude Fable på én dag? Jeg og Lars Tønder lekte oss i går.
>
> Resultatet er et spill i nettleseren, inspirert av Attack on Titan. Du svinger deg gjennom en middelalderby på gass og wire, litt som Spider-Man, og feller monstre. Jo raskere du flyr, jo hardere treffer du, og jo mer poeng får du.
>
> Alt er laget av Claude Fable: fysikken, grafikken, lyden, til og med multiplayer-delen. Tech stacken er TypeScript, Three.js og Cloudflare Workers. Min jobb var å ha det gøy: prate om spillmekanikkene jeg ville ha, teste underveis og si ifra når noe føltes feil. Og vi rakk til og med realtime multiplayer samme dag! Del en kode med opptil tre venner, så havner dere i samme by mot de samme monstrene, og etter kampen kåres lagets MVP.
>
> Dommen fra sjefstesteren Lars: «Helvete så addicting» og «Jeg er på ekte mind blown av hvor gøy det er å treffe riktig». Resten av tilbakemeldingene var stort sett «OOOOOUF» og andre ordlyder.
>
> En siste ting, i anledning morgendagens kvartfinale: Vår kjære Erling Braut Haaland gjemmer seg i spillet, og det gjør Harry Kane også. Kudos til den første som poster et skjermbilde av dem i kommentarfeltet!
>
> Spillet er gratis, og det er ingenting å installere: Link til nettsiden i kommentarfeltet 🔗 Hvor mange runder klarer du å overleve?
>
> Side note: Videoen i posten er også laget med AI. Claude fikk råopptakene mine, Gemini så gjennom dem og plukket ut øyeblikkene med tidsstempler, og ffmpeg og Remotion klipte og satte det hele sammen. Selvsagt ser den litt ræva ut, men det var et morsomt eksperiment.

---

## 3. kode24 story about sb1 (1 month, 128 reactions, 15 799 impressions)

Archetype: **Omtale**, story path. His best reach.

> Forrige uke delte jeg et lite verktøy som lar AI-agenten min jobbe trygt med mine egne banktall i SpareBank 1. Nå ønsket kode24 at jeg forteller historien om hvordan det ble til. 🕺🏽
>
> Jeg skrev ikke en eneste linje av koden for hånd. Jeg brukte en halvtime på å gi agenten alt den kunne trenge: OpenAPI-spesifikasjonen til banken, en Playwright-økt så den kunne navigere utviklerportalen i min egen nettleser, /goal så den jobbet mot et mål i en sløyfe, og en TDD-skill så den testet seg selv underveis. Så logget jeg inn med BankID én gang og lot den jobbe i to-ish timer mens jeg satt på jobb som vanlig. Fra idé til en publisert pakke og et repo klart til deling, før lunsj.
>
> At kode24 ville publisere dette, forteller meg noe om hvor nysgjerrigheten ligger nå. Jeg opplever at vi nå har etablert at disse modellene er skikkelig gode på å produsere kode. Da blir neste steg hvor langt du kan dytte konteksten du gir agenten, og hvor godt du rigger agenten for å jobbe autonomt over lengre tid.
>
> Og så er det rett og slett gøy. Midt i all AI-fatigue er det fint å bli minnet på at man kan leke seg med dette. Det morsomste eksempelet så langt er da jeg ga agenten tilgang til både banken og REMA-forbruket mitt og ba den finne noe å spare på. Den foreslo at jeg kanskje kjøper litt for mange pils når jeg er ute. Jaja, det er VM, og Norge vinner kamper. 🤷
>
> 👉🏽 Les saken her: https://lnkd.in/eHzHMXh7

---

## 4. sb1 launch (1 month, 119 reactions, 13 comments, 13 532 impressions)

Archetype: **Bygg / ship**. The reference implementation for this archetype.

> Jeg har laget et lite verktøy for å snakke med banken min gjennom AI-agenter!
>
> Dette er nok ikke for alle. Men er du SpareBank 1-kunde og bruker AI-agenter i hverdagen, er dette kanskje noe for deg.
>
> Det startet med et helt konkret behov: jeg ville samle hele privatøkonomien min på ett sted og sjekke at skattemeldingen faktisk stemte, at alle tall var riktig rapportert. Samtidig hadde jeg lyst til å utforske hvordan jeg kunne optimalisere økonomien min ved hjelp av AI-agenter.
>
> Problemet var at agenten ikke kunne se banktallene mine, og jeg måtte enten grave manuelt i nettbanken eller taste inn alt for hånd. Det ville jeg gjøre noe med.
>
> sb1 lar deg, og AI-agenten din, hente data rett fra SpareBank 1 sitt personlige bank-API:
>
> 📊 Se kontoer, saldoer og transaksjoner
> 🧾 Eksportere transaksjoner til CSV eller regneark
> 💸 Gjøre overføringer mellom dine egne kontoer (alltid med bekreftelse først)
> 🤖 Få en finansiell oversikt: nettoformue, månedlig kontantstrøm, kategorier og abonnementer
>
> Du logger inn én gang med BankID. Alt kjører lokalt på din egen maskin, og tokenet til banken lagres trygt i nøkkelringen din (eller i 1Password). Ingenting sendes til en tredjepart.
>
> Verktøyet er bygget med AI-agenter i tankene, og det følger med ferdige "skills" som lærer agenten å bruke verktøyet trygt. I praksis kan du spørre agenten din ting som "hvor ble det av pengene forrige måned, hvor mye har jeg brukt på pils denne måneden, hvilke abonnementer betaler jeg for, og hvor kan jeg spare?" og la den finne svaret i dine egne tall.
>
> Et annet eksempel som passer perfekt for en agent: skattemeldingen. Be agenten gå gjennom hele årets transaksjoner og sjekke at alt stemmer mot årsoppgaver og skattemelding, at renter, inntekter og saldoer faktisk er riktig rapportert. Det er nettopp den typen kjedelig, men viktig gjennomgang jeg helst slipper å gjøre manuelt.
>
> Dette er et personlig og uoffisielt verktøy. Det er ikke laget av eller tilknyttet SpareBank 1. Du registrerer din egen utvikler-app og bruker kun dine egne data, og er derfor best egnet for utviklere. Det er åpen kildekode og gratis.
>
> 👉 Last ned, installer og se koden her: https://lnkd.in/eQrsSUcJ

---

## 5. Velo Labs housewarming (1 month, 103 reactions, 8 424 impressions)

Archetype: **Arrangement**, recap. The credit block is the model.

> I går fikk jeg stå foran et rom fullt av AI-entusiaster og snakke om noe så glamorøst som ukeshandelen min.
>
> Velo Labs inviterte til housewarming om det nyeste i AI-verden, og jeg fikk vise frem et lite hobbyprosjekt jeg syns er litt gøy.
>
> Kort fortalt: en personlig handle-motor drevet av Claude Code. Den leser ukas tilbud, foreslår middager basert på hva som er på salg og matpreferanser, og fyller handlelista. Jeg godkjenner, og Claude handler.
>
> Det er egentlig et lite vindu inn i hvordan jeg mener dagligvarehandel bør se ut i nær framtid: du planlegger ikke uka fra scratch, men heller godkjenner et forslag en agent allerede har laget basert på dine handlemønstre. Kommer butikkene til å bygge for det, eller finner kundene sine egne veier dit først?
>
> Det var også veldig gøy å høre andre snakke om kule ting som beveger seg der ute:
>
> Christian Skovly-Guttormsen snakket om Nordic Semiconductor sin nye MCP, og hvordan legal tech ser ut fremover.
> Simen Myhre Waitz (Velo Labs) snakket om Willy, AI-agenten deres som er med overalt.
> Kristian Kvalsvik snakket om "den agentiske livsstilen", drevet av tale-til-tekst, agenter og kunnskapsgrafer.
>
> Stor takk til Velo Labs for strålende vertskap 🫶🏽

---

## 6. Hackathon win (featured, 180 reactions, 7 comments)

Archetype: **Arrangement**, win. His highest reaction count.

> Jeg og laget mitt kom på 1. plass og vant 30 000 kr i vårt første hackathon! 🕺🏽🤠
>
> Oslo Enhanced Hackathon ble arrangert av Knowit, og oppgaven var å bygge et verktøy som automatisk oversetter TypeScript til Python. Ingen LLM-er var lov i selve oversettelsen. Løsningen ble målt på en testsuite med 135 tester og kodekvalitet.
>
> Vi bygde et agent harness inspirert av Karpathy sitt autoresearch-konsept. Kort fortalt endrer agenten koden, kjører testene, beholder forbedringer, forkaster regresjoner, og gjentar. Loop etter loop etter loop. Uten å spørre oss om lov. Mennesket skriver "protokollen", ikke koden. Agenten gjør resten. Det funker veldig bra når man har et spesifikt og målbart problem som skal løses.
>
> Når autoresearch foreslo alternative tilnærminger til de vanskeligste problemene, paralleliserte vi arbeidet mellom alle på laget for å utforske raskere.
>
> Se bildet for en enkel visualisering av loopen 👇
>
> Med meg på laget: Julian Grande Sebastian Sole Erlend Sorknes Marcus Ruud
>
> Takk til Knowit for godt opplegg, gøy oppgave og god mat på Oslo Enhanced Hackathon. Dette ga mersmak!

---

## 7. CapraCon talk recap (featured, 103 reactions, 8 comments)

Archetype: **Arrangement**, recap with a DM close.

> På fredag hadde jeg en av de morsomste faglige dagene jeg kan huske 🕺🧠
>
> På CapraCon snakket jeg om noe jeg har bygget for meg selv: en AI-drevet «second brain». Et hvelv av notater som en agent strukturerer, kobler og henter tilbake. Også vibe-codet jeg en mobilapp på noen timer slik at jeg kan snakke med hjernen min på trikken hjem fra jobb.
>
> Veldig gøy å få prate til en sal fylt til randen, og holde workshop om det samme der vi hjalp folk sette opp dette selv! At så mange ville bruke en fredag ettermiddag på dette var virkelig gøy.
>
> Det viktigste er at du ikke trenger å være utvikler for å gjøre dette. En agent, en mappe på maskinen og litt nysgjerrighet er nok.
>
> Kjenner du deg litt nysgjerrig på dette, eller noe helt annet om agentisk AI? Send meg en DM, så tar jeg gjerne en prat!

---

## 8. Ukas koder i Kode24 (featured, 102 reactions, 8 comments)

Archetype: **Omtale**, teaser path. The shortest post in the corpus and the model
for the teaser length.

> Ukas koder i Kode24. Det er ganske stas.
>
> Jeg fikk snakke om alt fra hvordan vi gir huset ditt en stemme hos Gjensidige, til hvorfor du bør ha empati for AI-modellen du bruker.
>
> Vil du høre meg yappe om agentisk koding, skaperglede og hvorfor jeg håper 2026 blir året Norge faktisk blir AI-first? Lenke i kommentarfeltet 👇🏽

---

## 9. AI-demoer / Capra AI-fagsamling (5 months, 46 reactions, 9 325 impressions)

Archetype: **Mening** running into an **Arrangement** promo.

> Ærlig talt, de fleste AI-demoer du ser om dagen er litt meningsløse.
>
> De ser kule ut i en kontrollert video, men de overlever sjelden møtet med virkeligheten.
>
> Hos oss i Gjensidige bygger vi det som faktisk kjører i produksjon.
> Det vi har lært er at kode er blitt billig, men god programvare? Det er fortsatt dyrt. Og det krever mye mer enn bare prompting.
>
> Jeg jobber i et lite, kjapt team midt i en av Norges største organisasjoner. Vi itererer på løsninger med ekte data, ekte brukere og de kravene som følger med å være et selskap folk stoler på. Hver dag prøver vi å finne balansen mellom å bevege oss i 100 km/t og det å passe inn i det store maskineriet som er Gjensidige.
>
> Det mest spennende er egentlig ikke teknologien i seg selv. Det er arbeidsmåtene.
>
> Vi har lært mye om teknologien, men enda mer om hvordan vi endrer måten vi jobber på. Hvordan vi bruker AI individuelt og som team, og hvordan vi som et lite team kan shippe fort i en stor organisasjon uten å miste kontrollen.
>
> Dette skal vi prate om 18. mars på Capras åpne AI-fagsamling.
>
> Jeg gleder meg skikkelig, og vi er i veldig godt selskap:
>
> Patrick Skjennum (CTO i Vaskeladden) snakker om det økende gapet mellom utviklere nå som AI endrer spillereglene.
>
> Joachim Fainberg (CTO i The Forecasting Company) viser hvordan de bruker AI i arbeidsflyten for å bygge i rekordfart.
>
> Rune Lind (AI-evangelist i Capra) forteller hvordan de kobler AI-agenter direkte på teamets interne dokumentasjon hos NAV.
>
> Tid og sted: 18. mars kl. 15:00 til 18:00. Torggata 2, 4, 0180 Oslo.
>
> Det er åpent for alle som er nysgjerrige på hvordan AI ser ut når støvet har lagt seg og man faktisk skal levere noe som funker.
>
> Håper vi ses! Lenke til påmelding ligger i kommentarfeltet.

Note the "kode er blitt billig, men god programvare? Det er fortsatt dyrt"
construction. That is a rhetorical-question punchline of the kind the hard bans
now discourage. Do not reproduce it.

---

## 10. Eden Stack launch (5 months, 157 reactions, 62 comments, 15 782 impressions)

Archetype: **Bygg / ship**, product launch. Highest comment count in the corpus,
driven by the keyword-in-comments mechanic.

> Etter å ha bygget AI-native applikasjoner i 3 år, har jeg nå pakket alt jeg har lært inn i ett produkt.
>
> Eden Stack er en produksjonsklar startpakke for moderne SaaS:
>
> → AI-funksjoner brukerne forventer (chatbot med tool calling, web-søk, deep research, dokumentbehandling, long-running agents, etc.)
> → Alt en SaaS trenger (auth, betalinger, workspaces, invitasjoner) — fungerer out of the box
> → Agentic development workflow (30+ Claude skills + MCP-oppsett)
>
> Jeg bygde dette fordi jeg var lei av å sette opp det samme om og om igjen, og fordi jeg like gjerne kan dele det med andre. I tillegg forventer brukere i dag støtte for AI-funksjoner som standard.
>
> EDIT: By popular demand fortsetter jeg å sende ut heavily discounted rabattkoder til alle som skriver «EDEN» i kommentarfeltet — tilgang til hele templaten. 🚀
>
> Del gjerne med en venn, utvikler eller noen som har en gründer-spire i magen!
>
> Eneste jeg ber om: gi meg ærlig feedback etter du har fått prøvd det.
>
> https://eden-stack.com/

Contains two em dashes. Older style, superseded by the hard bans.

---

## 11. Eden Stack on Product Hunt (5 months, 94 reactions, 7 951 impressions)

Archetype: **Bygg / ship**, follow-up day. Shows how he does a second post on the
same thing without repeating himself.

> I dag lanserer jeg Eden Stack på Product Hunt! 🚀
>
> Fyyy søren for en respons og for et engasjement forrige uke!! Det virker som dette kanskje traff en nerve hos flere.
>
> Takk til alle som testet og ga tilbakemelding. Nå er det klart for å deles med litt flere enn min krets på LinkedIn.
>
> Hvis du har ett minutt til overs, betyr en upvote på Product Hunt mye for synligheten: https://lnkd.in/evjs_fHq
>
> Eden Stack er en produksjonsklar startpakke for AI-native SaaS — les mer på https://eden-stack.com/.

---

## 12. Agentic Stack blog series launch (6 months, 47 reactions, 5 436 impressions)

Archetype: **Forklaring / nyhet** promoting long-form. Shows the "ask the audience
what to write next" close.

> Hvordan bygger vi egentlig med AI i dag – utover bare enkle prompts?
>
> Første del av min nye bloggserie "The Agentic Stack" er ute. Den er skrevet både for utviklere og for nysgjerrige business-folk som vil forstå mekanikken bak buzzwordene.
>
> Vi starter med det grunnleggende: Fra statiske instrukser til dynamiske agenter som jobber autonomt. Jeg vet mange utviklere kjenner godt til dette, men hold ut, for senere kommer de spennende greiene som er gøy å yappe om på inn- og utpust. 🥵
>
> Jeg har en plan for veien videre, men vil gjerne høre fra deg: Hva savner du innsikt i? Verktøy? Sammenligninger? Sikkerhet? Arbeidsmetodikk? Noe helt annet?
>
> Kommenter gjerne, så tar jeg det med videre! 👋
>
> Les bloggen her: https://lnkd.in/ecar6naN

Contains an en dash in the hook. Older style, superseded.
