# Laboratorio 2

Workflow generale: `../CLAUDE.md`.

- Docenti: Patrizio Dazzi (patrizio.dazzi@unipi.it), Luca Ferrucci (luca.ferrucci@unipi.it). Corso A, a.a. 2026-27, annuale, 12 CFU, 48 lezioni.
- Materiale su Teams/SharePoint, codice degli esempi su GitHub. Linguaggio C, ambiente UNIX, poi thread, processi, programmazione di sistema.
- Esame: 4 compitini durante l'anno, oppure scritto + progetto + orale.

## Grezzi di questo corso

Qui i grezzi sono **file `.c` in `lezioni/`**, con gli appunti nei commenti (`first.c` = lezione 1, `seconda.c` = lezione 2, `quarta.c` vuoto; `terza.c` non c'è più; lezioni 3-5 fatte solo dalle slide). Si tengono così: sono anche codice compilabile. `lezioni/dispensa.md` è la vecchia versione Markdown della dispensa, non si aggiorna più.

## Mappa materiale ↔ lezione

| Lezione | Materiale (`slide/`) | Grezzo | Argomento |
|---|---|---|---|
| 1 | `L01_intro_e_ambiente.pdf` (92 slide) | `lezioni/first.c` | terminale, filesystem, comandi base, compilazione, primo programma C, printf |
| 2 | `L02_UNIX_base.pdf` (60 slide) | `lezioni/seconda.c` | ~ e file nascosti, touch e timestamp, cp/mv/rm, cat/less/head/tail, wildcard, tre flussi, redirezioni (anche 2>), pipe, argomenti con spazi |
| 3 | `L03 - Prgammazione C di base.pdf` (33 slide) | nessuno: fatta solo dalle slide, tutte e 33 | fasi di compilazione (-E, -c, linking), memoria a runtime, struttura del programma, identificatori, variabili e scope, tipi e sizeof, char/ASCII, IEEE 754, costanti ed escape, operatori, cortocircuito, assegnamento, if, while/do-while/for, break/continue, switch |
| 4 | `L04 - Programmazione C di base II.pdf` (17 slide) | `lezioni/quarta.c` vuoto: solo slide | s. 4-10 ripetono la L03 (if, cicli, break/continue, switch, tipi); nuovo: conversioni implicite ed esplicite, casting, divisione intera/reale; array monodimensionali |
| 5 | `L05 - Array e tipi custom, prima esercitazione.pdf` (27 slide) | nessuno: solo slide | array, struct (memoria, padding), array bidimensionali e indirizzi delle righe, enum, typedef, printf (`h`, `l`, `L`, ampiezza) e scanf (`&`, `%lf`), esercizi 1-8 con soluzione |

## Capitoli della dispensa (per argomento)

1. "L'ambiente di lavoro UNIX" (lez. 1-2): terminale e filesystem · lavorare con i file · flussi, redirezione e pipe.
2. "Il linguaggio C" (lez. 1, 3, 4, 5): dal sorgente all'eseguibile · com'è fatto un programma C · tipi e costanti · operatori ed espressioni · il controllo del flusso · array e tipi custom.

Gli esercizi della L05 stanno dentro gli argomenti come esempi: non c'è una sezione "esercizi".

Blocchi del semestre (slide L01): Intro → C → Memoria → Strutture. Il prossimo capitolo si apre con la memoria (puntatori, heap).
