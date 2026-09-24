# Laboratorio 2

Workflow generale: `../CLAUDE.md`.

- Docenti: Patrizio Dazzi (patrizio.dazzi@unipi.it), Luca Ferrucci (luca.ferrucci@unipi.it). Corso A, a.a. 2026-27, annuale, 12 CFU, 48 lezioni.
- Materiale su Teams/SharePoint, codice degli esempi su GitHub. Linguaggio C, ambiente UNIX, poi thread, processi, programmazione di sistema.
- Esame: 4 compitini durante l'anno, oppure scritto + progetto + orale.

## Grezzi di questo corso

Qui i grezzi sono **file `.c` in `lezioni/`**, con gli appunti nei commenti (`first.c` = lezione 1, `seconda.c` = lezione 2, `terza.c` = lezione 3, rimasto vuoto). Si tengono così: sono anche codice compilabile. `lezioni/dispensa.md` è la vecchia versione Markdown della dispensa, non si aggiorna più.

## Mappa materiale ↔ lezione

| Lezione | Materiale (`slide/`) | Grezzo | Argomento |
|---|---|---|---|
| 1 | `L01_intro_e_ambiente.pdf` (92 slide) | `lezioni/first.c` | terminale, filesystem, comandi base, compilazione, primo programma C, printf |
| 2 | `L02_UNIX_base.pdf` (60 slide) | `lezioni/seconda.c` | ~ e file nascosti, touch e timestamp, cp/mv/rm, cat/less/head/tail, wildcard, tre flussi, redirezioni (anche 2>), pipe, argomenti con spazi |
| 3 | `L03 - Prgammazione C di base.pdf` (33 slide) | `lezioni/terza.c` vuoto: fatta solo dalle slide, tutte e 33 | fasi di compilazione (-E, -c, linking), memoria a runtime, struttura del programma, identificatori, variabili e scope, tipi e sizeof, char/ASCII, IEEE 754, costanti ed escape, operatori, cortocircuito, assegnamento, if, while/do-while/for, break/continue, switch |

## Capitoli della dispensa (per argomento)

1. "L'ambiente di lavoro UNIX" (lez. 1-2): terminale e filesystem · lavorare con i file · flussi, redirezione e pipe.
2. "Il linguaggio C" (lez. 1 e 3): dal sorgente all'eseguibile · com'è fatto un programma C · tipi e costanti · operatori ed espressioni · il controllo del flusso. Le parti sul C della lezione 1 (gcc, primo programma, printf) sono state spostate qui; la tabella dei placeholder di printf sta in fondo a "tipi e costanti", dopo che i tipi sono spiegati.

Blocchi del semestre (slide L01): Intro → C → Memoria → Strutture. Il prossimo capitolo si apre con la memoria (puntatori, heap).

Il grezzo della lezione 2 non aveva errori rispetto alle slide. Il costo O(1)/O(N) di cp/mv e i dettagli di `cp -p` vengono dal grezzo (detti in aula, non nelle slide).

## Refusi nelle slide

- L03 s.9: `./ eseguibile.out` con uno spazio di troppo.
- L03 s.21: `%` nell'elenco degli assegnamenti, è `%=`.
- L03 s.23: "int semplice sta per long int" è sbagliato: `long` da solo sta per `long int`; `int` è un tipo a sé (qui 4 byte contro gli 8 di `long`).
- L03 s.26: 1.34423424·10⁻⁵ = 0.0000134423424, non 0.000134423424.
- Dispensa (dalla L01): "gcc = GNU C Compiler" corretto in GNU Compiler Collection (L03 s.9).
