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
2. "Il linguaggio C" (lez. 1, 3, 4, 5): dal sorgente all'eseguibile · com'è fatto un programma C · tipi e costanti · operatori ed espressioni · il controllo del flusso · array e tipi custom. Le parti sul C della lezione 1 (gcc, primo programma, printf) sono state spostate qui; la tabella dei placeholder di printf sta in fondo a "tipi e costanti", dopo che i tipi sono spiegati.

Lezioni 4-5: conversioni e casting stanno in "operatori ed espressioni" (con gli es. 3 e 4); scanf in fondo a "tipi e costanti", dopo i placeholder di printf; es. 1 e 2 in fondo a "il controllo del flusso"; es. 5, 6, 7, 8 dentro "array e tipi custom" come esempi. Non c'è una sezione "esercizi". Non si sa fin dove il prof sia arrivato in aula con gli esercizi (niente grezzo né registrazione): sono in dispensa tutti.

Blocchi del semestre (slide L01): Intro → C → Memoria → Strutture. Il prossimo capitolo si apre con la memoria (puntatori, heap).

Il grezzo della lezione 2 non aveva errori rispetto alle slide. Il costo O(1)/O(N) di cp/mv e i dettagli di `cp -p` vengono dal grezzo (detti in aula, non nelle slide).

## Refusi nelle slide

- L03 s.9: `./ eseguibile.out` con uno spazio di troppo.
- L03 s.21: `%` nell'elenco degli assegnamenti, è `%=`.
- L03 s.23: "int semplice sta per long int" è sbagliato: `long` da solo sta per `long int`; `int` è un tipo a sé (qui 4 byte contro gli 8 di `long`).
- L03 s.26: 1.34423424·10⁻⁵ = 0.0000134423424, non 0.000134423424.
- Dispensa (dalla L01): "gcc = GNU C Compiler" corretto in GNU Compiler Collection (L03 s.9).
- L04 s.16 / L05 s.3: `float reali1[n];` con `n` minuscola accanto a `#define N`: non messo in dispensa (array a dimensione variabile non spiegati).
- L05 s.5: `struct Studente s = {15, "Antonio"}` ha i valori in ordine inverso rispetto ai membri (`nome`, `eta`), forse apposta per mostrare il warning: l'output della slide è "Nome: T, Età: 0". In dispensa l'esempio è con `{"Antonio", 15}` (compilato: 24 byte) e una nota riporta il caso invertito.
- L05 s.9: `typedef char [] String;` non è C valido (sarebbe `typedef char String[N];`): non messo in dispensa.
- L05 s.19: manca `;` dopo `printf("Valori pari: %d\n", pari)`.
- L05 s.20: prodotto scalare fino a `a[n]*b[n]`, è `a[n-1]*b[n-1]`.
- L05 s.24: "richiedendolo se è diverso" → se è *uguale* a uno già immesso.
- L05 s.26-27 (soluzione es. 8): non fa il controllo sui codici duplicati chiesto dal testo; legge un'`eta` in più e filtra anche con `eta <= eta`, cosa che il testo non chiede; include `stdlib.h` senza usarla. In dispensa: versione che segue il testo (solo stipendio < media), senza controllo duplicati.
