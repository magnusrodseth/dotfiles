# Blog / long-form voice (Magnus Rødseth)

His blog is Norwegian (bokmål) with English technical terms kept inline. This is a
distinct register from his DMs and emails: teacherly, opinionated, practical, and
emoji-free. Read this together with the **Hard bans** in SKILL.md - they apply here
in full.

**Gold exemplar:** the kode24 leserinnlegg below. He wrote/edited it with Claude
and confirmed it reads as him. When in doubt, match its rhythm and restraint.

## Intended tone (from his own blog docs)

- **"Profesjonell, pedagogisk, praktisk."** Depth over breadth.
- Assume a competent reader; do not flatter them.
- ~1000–1200 words for a standard post (5-min read); pillar posts run longer.
- Short paragraphs, 2–4 sentences. Prose over lists; use lists sparingly.
- Translate technical terms to Norwegian where it reads naturally
  (kontekstvindu, verktøykall, tilbakemeldingssløyfe), keep them English where
  that's the real term (CLI, OAuth, crate, context engineering).
- No hype words (revolusjonerende / game-changer / magisk). No cinematic leads,
  no didactic "det er verdt å merke seg" tics.

## Structure

- **Opening:** concrete and result-first, fitted to the actual subject. Not a
  grand claim. The kode24 open ("Jeg brukte en halvtime på oppsett...") is the
  model: state what happened and the numbers, then say what it means.
- **Section headers:** sentence-case Norwegian, often plain questions or honest
  labels: "Hvordan så eksperimentet ut?", "Hva ble resultatet?", "Hva sitter jeg
  igjen med?", "Jeg hater å sjekke skattemeldingen min".
- **Body:** 3–6 sections. Teach by showing the work: setup, what you gave the
  agent, what came back, what you'd actually use it for.
- **Close:** don't oversell, name the limits honestly, then a short disclaimer
  ("For ordens skyld: ..."), a bulleted resource/link list, and a third-person
  bio line ("Magnus Rødseth jobber i Capra og bygger ...").

## Voice in long-form

- **First-person "jeg" sparingly and meaningfully**, not narratively. Use it for
  real experience and genuine opinion.
- **Honest, doesn't oversell.** Signature moves (all allowed): "Jeg vil ikke
  overselge ...", "Med det sagt ...", "For ordens skyld ...", "Misforstå meg
  rett ...", and naming what the approach is *not* good for.
- **Accountability refrain:** the human stays responsible ("jeg satt klar til å
  gripe inn", "Kall det heller veiledet autonomi"). This is a real theme, but
  phrase it plainly - not as an "it's not X, it's Y" punchline.
- **Direct opinion** is welcome and stated flat ("Jeg vil ikke overselge denne
  måten å lage ny programvare på").
- **Rhetorical questions** are fine, especially as section headers.
- **Dry, light humor** with real personality (the beer/VM aside in the exemplar).
- **Teaching moves:** parenthetical glosses of English terms (allowed -
  "inferens (det å la en modell kjøre og produsere et svar)"), before/after, and
  realistic code blocks with English comments. Mask real data in shared output.

## Punctuation & surface

- **No em dashes.** Colons (to introduce a list/explanation), parentheses, and
  plain sentences do the work. Spaced double-hyphen `--` only inside link lists.
- **No emoji in prose.** Section icons or in-code pointers only, and even those
  rarely. The running text is emoji-free.
- Correct æ/ø/å throughout. Underscore-italics for single-word emphasis is fine,
  used lightly.

---

## Gold exemplar - kode24 leserinnlegg (verbatim, endorsed)

**Kan en AI-agent bygge og publisere en ekte bank-CLI mens jeg er på jobb?**

Jeg brukte en halvtime på oppsett. Halvannen til to timer senere lå det en publisert pakke på crates.io og et ferdig repo jeg bare kunne dele. Jeg skrev ingenting av koden for hånd selv. Her er hva jeg mener det forteller om hvordan vi bygger programvare nå.

**Jeg hater å sjekke skattemeldingen min**

Jeg ville samle hele privatøkonomien min på ett sted, og jeg ville sjekke at skattemeldingen faktisk stemte: at renter, inntekter og saldoer var riktig rapportert. Samtidig hadde jeg lyst til å la en AI-agent hjelpe meg med å optimalisere økonomien.

Problemet var at agenten ikke kunne se banktallene mine. Jeg måtte enten grave manuelt i nettbanken eller taste inn alt for hånd.

SpareBank 1 har et personlig bank-API for utviklere. Så det jeg egentlig trengte var en liten CLI som agenten kunne kjøre: hente kontoer og transaksjoner, og gjøre overføringer mellom mine egne kontoer.

**Hvordan så eksperimentet ut?**

Jeg vil gjerne dele hvordan arbeidsprosessen for å lage dette verktøyet var. Jeg skrev ikke koden selv. Jeg satte opp agenten, og lot den gjøre jobben.

I rundt 30 minutter ga jeg den alt jeg kunne tenke meg at den ville trenge:

* OpenAPI-spesifikasjonen til SpareBank 1, så agenten hadde fasiten på hvert eneste endepunkt.
* En /playwriter-økt så den kunne navigere utviklerportalen i min egen nettleser, og curl for å teste kall mot ekte endepunkter.
* /goal, Claude Code sin innebygde måte å sette et mål og la agenten jobbe mot det i en sløyfe til det er nådd.
* /find-docs og context7 for å hente fram oppdatert dokumentasjon underveis i stedet for å gjette på API-er den var usikker på.
* /tdd, en skill som fikk agenten til å teste seg selv underveis.

Hele poenget var å gi den nok kontekst og nok verktøy til å jobbe i en sløyfe på egen hånd: skrive litt kode, teste den mot det ekte API-et, se hva som feilet, fikse det, og gjenta til alt virket ende-til-ende.

Så logget jeg inn med BankID én gang, og lot Claude Code jobbe i halvannen til to timer. Mens den holdt på, var jeg på jobb som vanlig, så dette tok veldig lite kognitiv last fra meg etter at jeg hadde tilrettelagt for agenten.

**Hva ble resultatet?**

Det agenten kom tilbake med, heter sb1. En CLI skrevet i Rust.

En morsom observasjon underveis: Rust har ord på seg for å være vanskelig å komme i gang med for nye utviklere, med alle særegenhetene og det språkspesifikke. Den terskelen blir kraftig senket når du jobber med en agent, men bare hvis målet ditt er å få noe ferdig, og ikke å lære noe nytt du ikke kan eller forstår fra før. Skal du faktisk lære deg et nytt språk, i dette tilfellet Rust, hopper denne måten å jobbe på over mange av de viktige stegene i læringen.

Vil du ha en grundigere teknisk gjennomgang, av BankID over OAuth 2.0, hvordan banktokenet lagres trygt, og hvordan verktøyet er bygget for å brukes av agenter, ligger alt i GitHub-repoet nederst i innlegget.

Slik ser en oversikt ut i terminalen. --mask skjuler beløp og kontonumre, nettopp for at man trygt skal kunne dele et skjermbilde som dette:

```
$ sb1 summary --months 2 --mask

Financial summary  (2 month(s): 2026-04-24 → 2026-06-23)

Net worth
  NOK: kr *****
  assets kr *****   liabilities -kr *****

Cash flow (internal transfers excluded)
  income     kr *****
  spending  -kr *****
  net        kr *****
  savings rate: ***%
  monthly avg: in kr *****, out kr *****
```

Apropos "skills": jeg distribuerer dem gjennom skills.sh, et åpent register for slike agent-ferdigheter. Har du en skills/-mappe i repoet ditt, kan hvem som helst hente dem inn i sin egen agent med én kommando:

```
npx skills add magnusrodseth/sparebank1-cli
```

Da får agenten deres de samme instruksjonene som min: hvordan logge inn, hvordan lese kontoer og transaksjoner, og hvordan gjøre overføringer på en trygg måte.

**Hva jeg faktisk har brukt den til**

Jeg har selvfølgelig allerede tatt den i bruk i hverdagen. Det morsomste eksempelet så langt: jeg ga agenten min tilgang både til sb1 og til forbruket mitt fra REMA 1000 (jeg har en liknende CLI for det), og ba den gå gjennom alt jeg hadde brukt de siste 60 dagene og si fra om det var noe åpenbart å spare på.

Den kom tilbake med en full gjennomgang. Konklusjonen var rett og slett at jeg kanskje kunne trappe litt ned på antall øl jeg kjøper når jeg er ute på byen. Jaja, VM pågår jo, så jeg kan ikke la en agent bestemme hvor gøy jeg har det når Norge vinner kamper.

Litt flaut, men ærlig. Men det er liksom hele poenget med dette verktøyet: når økonomien er noe en agent kan resonnere over, slipper jeg å gjøre den kjedelige gjennomgangen selv.

**Hva sitter jeg igjen med?**

Jeg vil ikke overselge denne måten å lage ny programvare på. Agenten jobbet ikke helt alene. Jeg ga den konteksten, verktøyene og BankID-innloggingen, og jeg satt klar til å gripe inn hvis den gikk i feil retning. Kall det heller veiledet autonomi.

Men det er fortsatt et markant skifte i hvordan kode produseres og ny programvare distribueres. Jeg gikk fra idé til en publisert crate på crates.io og et repo klart til deling, fra jeg kom på jobb til jeg gikk til lunsj, uten å skrive koden for hånd. Mesteparten av jobben min var å tenke klart om hva jeg ville ha, og å gi agenten nok til at den kunne teste seg selv.

For ordens skyld: sb1 er et personlig og uoffisielt verktøy, ikke laget av eller tilknyttet SpareBank 1. Du registrerer din egen utvikler-app og bruker bare dine egne data, så det passer best for utviklere. Det er åpen kildekode og gratis.

* Kode: https://github.com/magnusrodseth/sparebank1-cli
* Pakke: https://crates.io/crates/sparebank1-cli

________________

Magnus Rødseth jobber i Capra og bygger for tiden agentiske AI-verktøy for Gjensidige.
