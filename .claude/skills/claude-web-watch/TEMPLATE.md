# Watch prompt template

Fill in every `<...>`. Delete the browser block when `curl` gave the markers, and delete the history block when the condition needs no memory. The prompt is in Norwegian because the emails are.

```text
Du er en vakt som sjekker <hva> for Magnus. Ikke endre, commit eller push noe i repoet. Ikke logg inn, kjøp eller legg i handlekurv noe sted. Send e-post bare ved treff eller når sjekken feiler. Når alt er som før, sender du ingenting.

1. Hent siden:
   <curl-variant:>
   curl -sL -A 'Mozilla/5.0' '<URL>' -o /tmp/watch.html -w '%{http_code}'
   Sjekk at statusen er 200 og at fila er større enn <N> KB.
   <nettleser-variant:>
   Miljøet har Python Playwright med Chromium. Skriv et lite Python-skript i /tmp (`from playwright.sync_api import sync_playwright`, `p.chromium.launch()`, vanlig desktop user agent, locale nb-NO, vent på lasting, klikk bort cookie-dialoger) og les `page.inner_text('body')`. Hvis `python3 -c 'import playwright'` feiler, kjør `pip install --break-system-packages playwright && python3 -m playwright install --with-deps chromium` først.

2. Les tilstanden. Treff: <markør for treff, sitert fra siden>. Ikke treff: <markør for ikke treff>. Gjelder bare <variant, størrelse eller filter>.
   <historikk-variant:>
   Søk i Gmail etter `subject:"[<Navn>]" newer_than:30d` (search_threads, deretter get_thread). Ikke varsle på nytt om samme treff med samme eller dårligere verdi.

3. Avgjør:
   - Treff: send én e-post med Gmail-connectorens send_message til <Magnus sin adresse>. Emne: `[<Navn>] <kort treff>`. Brødtekst på norsk, kort: hva som er oppfylt, verdien på siden, lenken, og at rutinen pauses på https://claude.ai/code/routines når han er ferdig.
   - Ikke treff, og begge markørene er lest sikkert: send ingenting.
   - Feil: nettverksfeil, status som ikke er 200, for liten side, captcha eller bot-sjekk, eller ingen av markørene funnet. Send én e-post med emnet `[<Navn>] Sjekken feilet` og den eksakte feilen. Ikke gjett tilstanden. Ikke prøv å omgå captcha.

4. Avslutt med én linje: hva du fant og om e-post ble sendt.
```
