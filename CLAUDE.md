# Laboratorio 2

Workflow generale: `../CLAUDE.md`.

- Docenti: Patrizio Dazzi (patrizio.dazzi@unipi.it), Luca Ferrucci (luca.ferrucci@unipi.it). Corso A, a.a. 2026-27, annuale, 12 CFU, 48 lezioni.
- Materiale su Teams/SharePoint, codice degli esempi su GitHub. Linguaggio C, ambiente UNIX, poi thread, processi, programmazione di sistema.
- Esame: 4 compitini durante l'anno, oppure scritto + progetto + orale.

## Grezzi di questo corso

Qui i grezzi sono **file `.c` in `lezioni/`**, con gli appunti nei commenti (`first.c` = lezione 1, `seconda.c` = lezione 2, `terza.c` = lezione 3, ancora vuoto). Si tengono così: sono anche codice compilabile. `lezioni/dispensa.md` è la vecchia versione Markdown della dispensa, non si aggiorna più.

## Mappa materiale ↔ lezione

| Lezione | Materiale (`slide/`) | Grezzo | Argomento |
|---|---|---|---|
| 1 | `L01_intro_e_ambiente.pdf` (92 slide) | `lezioni/first.c` | terminale, filesystem, comandi base, compilazione, primo programma C, printf |
| 2 | `L02_UNIX_base.pdf` (60 slide) | `lezioni/seconda.c` | ~ e file nascosti, touch e timestamp, cp/mv/rm, cat/less/head/tail, wildcard, tre flussi, redirezioni (anche 2>), pipe, argomenti con spazi |

## Capitoli della dispensa (per argomento)

Capitolo 1 "L'ambiente di lavoro: UNIX e primi programmi C" (lez. 1-2), con le sezioni: terminale e filesystem · dal sorgente al programma · il primo programma C · lavorare con i file · flussi, redirezione e pipe. Il prossimo capitolo si apre quando il corso passa al linguaggio C vero e proprio (nelle slide L01 i blocchi del semestre sono: Intro → C → Memoria → Strutture).

Il grezzo della lezione 2 non aveva errori rispetto alle slide. Il costo O(1)/O(N) di cp/mv e i dettagli di `cp -p` vengono dal grezzo (detti in aula, non nelle slide).
