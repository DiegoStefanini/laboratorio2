# Laboratorio 2

Workflow generale: `../CLAUDE.md`.

- Docenti: Patrizio Dazzi (patrizio.dazzi@unipi.it), Luca Ferrucci (luca.ferrucci@unipi.it). Corso A, a.a. 2026-27, annuale, 12 CFU, 48 lezioni.
- Materiale su Teams/SharePoint, codice degli esempi su GitHub. Linguaggio C, ambiente UNIX, poi thread, processi, programmazione di sistema.
- Esame: 4 compitini durante l'anno, oppure scritto + progetto + orale.

## Regola di stile di questo corso

La dispensa deve essere **corta**: il lettore conosce già JavaScript. Quello che in C funziona come in JS (if, cicli, switch, operatori, funzioni e `return`, ricorsione) va in una riga o in una tabella. Le parti che a chi viene da JS non sono scontate (tipi e `sizeof`, divisione intera, 0/1 come booleani, compilazione e linking, `.h`/`extern`/`static`, puntatori, memoria, `malloc`/`free`, stringhe come array con `'\0'`, input con `scanf`) si spiegano per bene, anche più lunghe.

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
| 6 | `L06 - Prima esercitazione.mp4` (47 min), trascrizione in `slide/registrazioni/L06.txt` | nessuno | esercizi della L05 fatti in aula (indovina il numero, quoziente con casting, prodotto scalare). Nuovo: `(float)(a/b)` sbagliato, una `scanf` per variabile |
| 7 | `L07 - Funzioni, classi di memorizzazione e scoping.pdf` (21) | nessuno | funzioni, prototipo, errore compilatore vs linker, passaggio per valore, auto/extern/static, `.h`, esempio `max.c`/`max.h` con `countA` |
| 8 | `L08 - Puntatori e array.pdf` (29) | nessuno | puntatori, `&` e `*`, NULL, tipi, swap per indirizzo, array e aritmetica, zone di memoria, malloc/calloc/free, void*, array di puntatori, matrici dinamiche |
| 9 | `L09 - Allocazione dinamica di memoria.pdf` (18) | nessuno | ripete le slide 14-29 della L08 |
| 10 | `L10.pdf` (24) | nessuno | puntatori a struct e `->`, liste concatenate, puntatori a funzione, qsort, stringhe, string.h, strtok, ctype.h, lettura e conversione |
| 11 | `L11.pdf` (33) | nessuno | debugging: stderr, assert/NDEBUG, gdb, valgrind; esercizi su matrici dinamiche e merge sort di studenti |
| 12 | `L12.pdf` (28) | nessuno | esercizi su stringhe (strcat, anagrammi, LCP, suffissi con qsort), lista di studenti, albero binario di ricerca |

## Capitoli della dispensa (per argomento)

1. "L'ambiente di lavoro UNIX" (lez. 1-2): terminale e filesystem · lavorare con i file · flussi, redirezione e pipe.
2. "Il linguaggio C" (lez. 1, 3-7): dal sorgente all'eseguibile · com'è fatto un programma C · tipi e costanti · operatori e controllo del flusso · array e tipi custom · funzioni e programmi su più file.
3. "Puntatori e memoria" (lez. 8-12): puntatori · array e puntatori · allocazione statica e dinamica · array di puntatori e matrici dinamiche · stringhe · puntatori a funzioni · trovare gli errori.
4. "Strutture dati" (lez. 10-12): puntatori a struct (con il merge sort della L11) · liste concatenate · alberi binari di ricerca.
5. Riepilogo (appendice): errori, puntatori, classi di memorizzazione, trappole.

Tutti gli esercizi del prof sono nella dispensa (anche i micro-esercizi di L01-L02), ognuno subito dopo l'argomento che serve. Quelli la cui soluzione del prof sta nel testo come esempio (quoziente, pari/dispari, prodotto scalare, anagrafe, `sum_submatrix`) non hanno box; gli altri sono `#esercizio` con la sola consegna.

Fin qui: lezione 12. **Compitino 1: 3 novembre 2026, domande a risposta multipla.**
