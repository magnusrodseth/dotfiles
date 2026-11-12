# Document critique

En skill for å vurdere et dokument som nærmer seg ferdig. Den kontrollerer
oppgaveoppfyllelse, faglig sammenheng, kilder, språk, konsistens og formkrav.

Tilbakemeldingen kommer i chat med originalutdrag, begrunnelse og et konkret
forslag til forbedring. Skillen skiller mellom feil, faglige presiseringer og
valgfrie stilforslag. Den bevarer teksten og foreslår lokale endringer.

## Installasjon

Pakk ut zip-filen. Den inneholder mappen `document-critique` med `SKILL.md`
og de tilhørende referansefilene. Behold hele mappen samlet.

- **Claude Code:** Legg mappen i `~/.claude/skills/` for personlig bruk,
  eller `<prosjekt>/.claude/skills/` for bruk i ett prosjekt.
- **Codex eller Zed:** Legg mappen i `~/.agents/skills/`,
  eller `<prosjekt>/.agents/skills/` for bruk i ett prosjekt.
- **Andre chatverktøy:** Legg ved `SKILL.md`, relevante referansefiler,
  dokumentet og oppgaveteksten. Be agenten følge skillen.

Start en ny samtale etter installasjon. Skillen er ment å bli startet eksplisitt
av brukeren. Den har ingen obligatoriske scripts, API-nøkler eller nettleserutvidelser.

## Bruk

Legg ved dokumentet og oppgaveteksten eller en kort forklaring av formålet.
Oppgi pensum og referansestil hvis de skal kontrolleres.

> Bruk document-critique på vedlagte dokument. Vurder det opp mot oppgaveteksten,
> og sjekk norsk språk, tegnsetting og konsistens. Gi hele vurderingen i chat
> med originalutdrag og konkrete forbedringsforslag. Teksten er nesten ferdig,
> så bevar oppbygningen og foreslå bare nødvendige lokale endringer.

Hvis kommentarer i dokumentet også er ønsket:

> Legg også til kommentarene ved de aktuelle tekststedene i dette dokumentet.
> Bevar selve teksten og eksisterende kommentarer.

For et dokument uten oppgavetekst:

> Bruk document-critique på dette notatet. Formålet er å forklare beslutningen
> for prosjektgruppen. Vurder om begrunnelsen er forståelig og støttet av teksten,
> og foreslå konkrete rettelser i språk og konsistens.
