#import "@preview/cetz:0.4.2": canvas, draw, tree

#set document(title: "Laboratorio 2 — Dispensa")
#set page(paper: "a4", margin: 2.2cm, numbering: "1")
#set text(lang: "it", size: 11pt)
#set par(justify: true)
#set heading(numbering: "1.1")
#show heading.where(level: 1): it => { pagebreak(weak: true); it }
#show raw.where(block: true): block.with(fill: luma(245), inset: 8pt, radius: 4pt, width: 100%)
#show raw.where(block: false): box.with(fill: luma(240), inset: (x: 3pt), outset: (y: 3pt), radius: 2pt)
#set table(stroke: 0.5pt + luma(180), inset: 6pt)
#show table.cell.where(y: 0): strong

#let blu = rgb("#3b6fd8")
#let verde = rgb("#2e9e5b")
#let grigio = luma(170)

// osservazione del prof, trappola
#let nota(body) = block(
  fill: rgb("#eef4ff"), stroke: (left: 3pt + blu),
  inset: 10pt, width: 100%, body,
)
// prerequisito non spiegato in aula, aggiunto su richiesta
#let base(titolo, body) = block(
  fill: rgb("#eefaf2"), stroke: (left: 3pt + verde),
  inset: 10pt, width: 100%,
)[*Da sapere — #titolo* #h(0.3em) #text(8pt, fill: verde)[(aggiunto, non spiegato in aula)] \ #body]

#let mono(s) = text(font: "DejaVu Sans Mono", s)
// conto in colonna: righe allineate a destra, riga sopra il risultato
#let conto(op: "+", sopra: (), ..righe) = {
  let r = righe.pos()
  let celle = ()
  for s in sopra { celle += ([], text(fill: grigio, mono(s))) }
  for (i, x) in r.slice(0, -1).enumerate() {
    if i == 2 { celle.push(grid.hline(start: 1, stroke: 0.5pt)) }
    celle += (if i == 1 { op } else { [] }, mono(x))
  }
  celle += (grid.hline(start: 1, stroke: 0.8pt), [], strong(mono(r.last())))
  box(grid(columns: 2, align: right, inset: (x: 2pt, y: 3pt), ..celle))
}
// passaggi etichettati: ((etichetta, bit), ...), riga sopra l'ultimo
#let passi(..righe) = {
  let r = righe.pos()
  let celle = ()
  for (i, (e, x)) in r.enumerate() {
    if i == r.len() - 1 { celle.push(grid.hline(stroke: 0.8pt)) }
    celle += (text(8pt, fill: gray, e), if i == r.len() - 1 { strong(mono(x)) } else { mono(x) })
  }
  box(grid(columns: 2, align: (left, right), inset: (x: 3pt, y: 3pt), ..celle))
}
// pila di livelli: ogni elemento è (testo, colore di sfondo)
#let pila(larghezza: 3.4cm, ..livelli) = stack(..livelli.pos().map(((t, c)) =>
  box(width: larghezza, inset: 5pt, stroke: 0.6pt, fill: c, align(center, text(9pt, t)))))
#let figura(corpo, didascalia) = figure(corpo, caption: didascalia, kind: image, supplement: none)

// sessione di terminale: ```sh ... ``` in riquadro scuro
#show raw.where(lang: "sh"): it => block(fill: rgb("#1f2330"), inset: 9pt, radius: 4pt, width: 100%, {
  set par(justify: false)
  show regex("#.*"): set text(fill: rgb("#8a93a6"))
  show regex("(?m)^\$"): set text(fill: rgb("#7ee787"))
  text(font: "DejaVu Sans Mono", size: 8.5pt, fill: rgb("#e6e6e6"), it.text)
})
// programma con stdin a sinistra e stdout a destra
#let flusso(sx, prog, dx, frecce: ("stealth", "stealth"), etichetta: none) = canvas(length: 0.6cm, {
  import draw: *
  content((0, 0), box(inset: 5pt, stroke: 0.6pt, fill: rgb("#fff3c4"), text(9pt, sx)))
  line((1.7, 0), (3.2, 0), mark: (end: frecce.at(0)))
  content((5, 0), box(inset: 7pt, stroke: 1pt + blu, fill: rgb("#eef4ff"), radius: 3pt, text(9pt, prog)))
  line((6.8, 0), (8.3, 0), mark: (end: frecce.at(1)))
  content((10, 0), box(inset: 5pt, stroke: 0.6pt, fill: rgb("#fff3c4"), text(9pt, dx)))
  if etichetta != none { content((5, -1), text(8pt, fill: gray, etichetta)) }
})

#align(center)[
  #v(4cm)
  #text(24pt, weight: "bold")[Laboratorio 2]
  #v(0.3cm)
  #text(14pt)[Diego Stefanini — prof. Patrizio Dazzi, Luca Ferrucci, a.a. 2026-27]
]
#v(1cm)
#outline()

= L'ambiente di lavoro: UNIX e primi programmi C

== Il terminale e il filesystem

=== Terminale e shell

#grid(columns: (1fr, 1fr), gutter: 1.5em, align: horizon,
```sh
$ pwd
/home/studente/lab2
$ ls
hello.c   appunti.txt
```,
[
  - *Terminale*: interfaccia testuale per dialogare con il sistema.
  - *Shell* (bash, zsh): il programma dentro il terminale che interpreta i comandi.
  - Il *prompt* (`$`) dice che la shell aspetta un comando. Non fa parte del comando e non è sempre `$`.
])

=== Il filesystem

#grid(columns: (auto, 1fr), gutter: 1.5em, align: horizon,
canvas(length: 0.8cm, {
  import draw: *
  tree.tree(
    ([`/`], ([`home`], ([`studente`], ([*`lab2`*], [`hello.c`], [`appunti.txt`], [`esercizi/`]))), [`etc`], [`usr`]),
    spread: 1.7, grow: 1.1,
    draw-node: (node, ..) => {
      let t = node.content
      content((), box(inset: 3pt, radius: 2pt, fill: if repr(t).contains("lab2") { rgb("#fff3c4") } else { white }, t))
    })
}),
[
  Il filesystem è un *albero*. Parte da `/`, la *root*: ogni file o directory si raggiunge con un *percorso*. `/` separa un livello dal successivo.

  File e directory sono oggetti diversi ma stanno nello stesso spazio dei nomi.

  In giallo la *directory corrente*.

  - `.` = la directory corrente
  - `..` = la directory padre
])

#table(
  columns: (auto, 1fr),
  [Comando], [Descrizione],
  [`pwd`], [_print working directory_: stampa in quale cartella sei],
  [`ls`], [elenca il contenuto della directory corrente],
  [`ls -l`], [elenco in formato lungo (permessi, proprietario, dimensione, data)],
  [`cd`], [_change directory_: navigo in una directory],
  [`mkdir`], [_make directory_: crea una directory],
  [`echo $?`], [restituisce il valore di ritorno dell'ultimo comando eseguito],
)

==== Percorsi assoluti e relativi

#grid(columns: (1fr, 1fr), gutter: 1em,
[*Relativo*: parte dalla directory corrente (es. `esercizi/es1.c`).
```sh
$ cd esercizi
$ pwd
/home/studente/lab2/esercizi
```],
[*Assoluto*: parte dalla root `/` (es. `/home/studente/lab2`).
```sh
$ cd /home/studente
$ pwd
/home/studente
```])

```sh
$ pwd
/home/studente/lab2
$ cd ..          # vado nel padre
$ pwd
/home/studente
```

==== La home e i file nascosti

#grid(columns: (1fr, 1fr), gutter: 1em,
[`~` = la *home* dell'utente corrente. `cd` senza argomenti porta di solito lì.
```sh
$ cd ~
$ pwd
/home/studente
```],
[Un nome che inizia con `.` è *nascosto*: `ls` non lo mostra, `ls -a` sì.
```sh
$ ls
appunti.txt  hello.c
$ ls -a
.  ..  .bashrc  appunti.txt  hello.c
```])

#nota["Nascosto" è solo una *convenzione sul nome*, non un tipo speciale di file.]

==== Leggere `ls -l`

#align(center, canvas(length: 1cm, {
  import draw: *
  let campi = (("d", "tipo: d = directory, - = file", red), ("rwxr-xr-x", "permessi", blu), ("studente", "proprietario", black),
    ("studenti", "gruppo", black), ("64", "dimensione (byte)", black), ("Sep 15 09:10", "ultima modifica", black), ("esercizi", "nome", verde))
  let x = 0
  for (k, (t, d, c)) in campi.enumerate() {
    let w = t.len() * 0.2 + 0.3
    content((x + w / 2, 0), text(fill: c, raw(t)))
    let y = if calc.rem(k, 2) == 0 { -0.8 } else { -1.5 }
    line((x + w / 2, -0.25), (x + w / 2, y + 0.2), stroke: 0.4pt + gray)
    content((x + w / 2, y), text(7pt, fill: c, d))
    x += w + 0.25
  }
}))

=== Com'è fatto un comando

#align(center, canvas(length: 1cm, {
  import draw: *
  let pezzi = (("gcc", "comando", 0, 1.2), ("-Wall", "opzione", 1.6, 1.4), ("hello.c", "argomento", 3.4, 1.8), ("-o hello", "opzione + argomento", 5.6, 2.2))
  for (t, d, x, w) in pezzi {
    content((x + w / 2, 0), text(14pt, raw(t)))
    line((x + 0.1, -0.35), (x + w - 0.1, -0.35), stroke: 1pt + blu)
    content((x + w / 2, -0.75), text(8pt, fill: blu, d))
  }
}))

Le *opzioni* modificano il comportamento del comando. Se non ricordi come si usa: `gcc --help` (sintesi rapida) oppure `man gcc` (manuale UNIX).

==== Chi riceve gli argomenti?

La shell *spezza la riga in parole usando gli spazi* e avvia il programma passandogli gli argomenti. Se un nome contiene spazi, le *virgolette* lo tengono insieme come un solo argomento:

```sh
$ touch "appunti lezione.txt"     # un file, non due
$ cat "appunti lezione.txt"
```

#nota[Vedremo come un programma C legge questi argomenti con `argc` e `argv`, i parametri di `main`.]

== Dal sorgente al programma

=== Il ciclo di lavoro

#grid(columns: (auto, 1fr), gutter: 1.5em, align: horizon,
canvas(length: 0.9cm, {
  import draw: *
  let passi = ("modifica", "compila", "esegui", "osserva")
  let pos = ((0, 1.5), (2, 0), (0, -1.5), (-2, 0))
  for (k, p) in pos.enumerate() {
    let q = pos.at(calc.rem(k + 1, 4))
    line((p.at(0) * 0.75 + q.at(0) * 0.25, p.at(1) * 0.75 + q.at(1) * 0.25), (p.at(0) * 0.25 + q.at(0) * 0.75, p.at(1) * 0.25 + q.at(1) * 0.75), mark: (end: "stealth"))
    content(p, box(inset: 5pt, stroke: 0.8pt + blu, fill: rgb("#eef4ff"), radius: 3pt, text(9pt, passi.at(k))))
  }
}),
[
  Il programma non nasce nell'editor: nasce da questo ciclo, ripetuto.

  #nota[*modifica ≠ compilazione ≠ esecuzione.* Se cambi il sorgente e non ricompili, stai eseguendo il vecchio programma.]
])

=== Compilare ed eseguire

C è un linguaggio *compilato*: il sorgente `.c` va trasformato in un file binario prima di poterlo eseguire.

#align(center, canvas(length: 0.6cm, {
  import draw: *
  content((0, 0), box(inset: 6pt, stroke: 0.6pt, fill: rgb("#fff3c4"))[`hello.c` \ #text(7pt)[sorgente]])
  line((1.9, 0), (4.2, 0), mark: (end: "stealth")); content((3.05, 0.6), text(8pt, fill: blu)[`gcc`])
  content((6, 0), box(inset: 6pt, stroke: 0.6pt, fill: rgb("#eef4ff"))[`hello` \ #text(7pt)[eseguibile]])
  line((7.8, 0), (10.1, 0), mark: (end: "stealth")); content((8.95, 0.6), text(8pt, fill: blu)[`./hello`])
  content((12.3, 0), box(inset: 6pt, stroke: 0.6pt)[`Hello, world!` \ #text(7pt)[e `$?` = 0]])
}))

```sh
$ gcc hello.c              # se va tutto bene non scrive niente
$ ls
a.out  hello.c             # senza -o l'eseguibile si chiama a.out
$ gcc -Wall -Wextra -std=c11 hello.c -o hello   # warning attivi, standard C11, nome "hello"
$ ./hello
Hello, world!
$ echo $?
0
```

#table(columns: (auto, 1fr),
  [Pezzo], [Significato],
  [`-o hello`], [dà il nome all'eseguibile],
  [`-Wall -Wextra`], [attiva i warning: *non sono rumore*, spesso segnalano un errore vero],
  [`-std=c11`], [standard del C (esistono C89, C95, C99, C11, C17, C23). `gcc` = GNU C Compiler],
  [`./hello`], ["esegui `hello` *che sta nella directory corrente*". La shell cerca i comandi in un elenco di directory, e quella corrente non c'è per forza],
  [`echo $?`], [stampa il valore restituito dall'ultimo programma. *0 = terminato correttamente*],
)

=== Quando qualcosa va storto

#grid(columns: (1fr, 1fr), gutter: 1em,
[
```c
int main(void) {
    puts("Hello, world!")   // manca ;
    return 0;
}
```
```sh
hello.c:4:26: error: expected ';' before 'return'
```
*File, riga, messaggio*: usali. Correggi *dall'alto verso il basso*: un solo errore può generare molti messaggi dopo.
],
table(columns: 2,
  [Errore di compilazione], [Errore di esecuzione],
  [il programma *non viene costruito*], [l'eseguibile esiste ma *si comporta male* o termina in modo inatteso],
))

#grid(columns: (1fr, 1fr), gutter: 1em,
box(stroke: 0.6pt + red, inset: 8pt, width: 100%)[*3 errori banali che fanno perdere tempo*
  + essere nella directory sbagliata;
  + modificare un file e compilarne un altro;
  + dimenticare di ricompilare.],
box(stroke: 0.6pt + verde, inset: 8pt, width: 100%)[*Diagnosi minima*
  + sono nella directory giusta?
  + il sorgente esiste?
  + ci sono errori o warning?
  + l'eseguibile è stato creato?
  + sto eseguendo quello giusto?])

*Routine utile*: `pwd` → `ls` → `gcc ...` → `./programma`.

== Il primo programma C

=== I pezzi

#grid(columns: (1.3fr, 1fr), inset: (x: 6pt, y: 4pt),
  [
```c
#include <stdio.h>

int main(void) {
    puts("Hello!");
    return 0;
}
```],
  align(horizon)[
    1. `#include <stdio.h>`: rende disponibili le funzioni di input/output (come `puts`)
    2. `main`: da qui parte il programma. Prende niente (`void`), restituisce un intero (`int`)
    3. `puts("Hello!")`: un'operazione
    4. `return 0`: termina `main` e restituisce 0 al sistema operativo
  ],
)

Le *graffe* `{ }` delimitano un blocco. I commenti (`// fino a fine riga`, `/* su più righe */`) sono per le persone: il compilatore li ignora. Indentazione e nomi sensati non sono obbligatori in C, ma il programma deve essere leggibile.

=== Stampare: `puts` e `printf`

#table(columns: (auto, 1fr),
  [Funzione], [Cosa fa],
  [`puts("Laboratorio 2");`], [stampa una stringa *e va a capo*],
  [`printf("Risultato: %d\n", 42);`], [stringa *formattata*: `%d` viene sostituito dal valore. *Non va a capo da sola*: serve `\n`],
)

#nota[`printf` è una funzione a *numero variabile di parametri*: il primo è la stringa di formato, gli altri i valori da inserire al posto di `%d`, `%s`, …  Il placeholder deve essere compatibile con il tipo del valore.]

==== Dentro un placeholder

#align(center, canvas(length: 1cm, {
  import draw: *
  let pezzi = (("%", "inizio", red), ("0", "flag: zeri iniziali", blu), ("8", "larghezza minima", verde), (".2", "precisione: 2 decimali", rgb("#b36b00")), ("f", "tipo: double", red))
  let x = 0
  for (k, (t, d, c)) in pezzi.enumerate() {
    let w = if t.len() > 1 { 0.9 } else { 0.6 }
    content((x + w / 2, 0), text(22pt, fill: c, raw(t)))
    let y = -0.9 - calc.rem(k, 2) * 0.55
    line((x + w / 2, -0.4), (x + w / 2, y + 0.18), stroke: 0.4pt + gray)
    content((x + w / 2, y), text(8pt, fill: c, d))
    x += w + 0.9
  }
}))
#align(center, text(9pt)[`printf("%08.2f", 3.14);` → `00003.14` #h(1em) — forma generale: `%[flags][width][.precision][length]specifier`])

#table(columns: 4,
  [Interi], [], [Altri tipi], [],
  [`%d`, `%i`], [int con segno], [`%f`], [double],
  [`%u`], [unsigned int], [`%e`, `%E`], [notazione scientifica],
  [`%x`, `%X`], [esadecimale], [`%g`, `%G`], [formato compatto],
  [`%o`], [ottale], [`%c`], [carattere],
  [`%ld`], [long], [`%s`], [stringa],
  [`%lld`], [long long], [`%p`], [puntatore],
  [`%zu`], [size_t], [`%%`], [il carattere %],
)

=== Mettiamo insieme i pezzi

#grid(columns: (1.3fr, 1fr), gutter: 1em, align: horizon,
```c
#include <stdio.h>

int main(void) {
    int x = 21;                         // una variabile

    puts("Laboratorio 2");
    puts("Lezione 1");
    printf("2 * %d = %d\n", x, 2 * x);  // due placeholder

    return 0;
}
```,
```sh
$ gcc -Wall -Wextra -std=c11 lezione01.c -o lezione01
$ ./lezione01
Laboratorio 2
Lezione 1
2 * 21 = 42
```)

== Lavorare con i file

=== Creare: `mkdir` e `touch`

#grid(columns: (1fr, 1fr), gutter: 1em,
```sh
$ mkdir esercizi     # argomento = nome
$ touch appunti.txt  # file vuoto
```,
[`touch` in realtà nasce per *cambiare i timestamp* di un file. Se il file non esiste lo crea: la creazione è una conseguenza utile, non lo scopo.])

=== I timestamp

Per ogni file UNIX tiene tre marcature temporali. `stat file` le mostra, insieme agli altri metadati.

#table(
  columns: (auto, 1fr),
  [Metadato], [Significato],
  [`atime`], [_access time_: ultimo accesso al *contenuto*],
  [`mtime`], [_modification time_: ultima modifica del *contenuto*],
  [`ctime`], [_change time_: ultima modifica dei *metadati*],
)

#nota[`ctime` vuol dire *change* time, *non* "creation time". Alcuni filesystem moderni salvano anche il tempo di creazione (_birth time_), ma non fa parte dei tre timestamp UNIX classici.]

*A cosa servono*: backup incrementali, sincronizzazione, diagnostica, cercare i file modificati di recente, e ricompilare solo ciò che è cambiato. `make` (lo vedremo più avanti) confronta i timestamp per decidere se ricompilare.

Chi aggiorna cosa (✓ = portato all'ora corrente):

#let si = text(fill: verde, weight: "bold")[✓]
#let no = text(fill: gray)[—]
#align(center, table(columns: 4, align: center,
  [Operazione], [`atime`], [`mtime`], [`ctime`],
  [`touch file`], si, si, [#si #text(8pt)[(cambiare i tempi è già \ una modifica dei metadati)]],
  [`touch -a file`], si, no, si,
  [`touch -m file`], no, si, si,
  [`cp`: destinazione], [#si #text(8pt)[solo se creato]], si, si,
  [`cp -p`: destinazione], text(8pt)[copiato dal sorgente], text(8pt)[copiato dal sorgente], si,
  [`cp`: sorgente], [#si #text(8pt)[può, per la lettura]], no, no,
))

=== Copiare, spostare, cancellare

#grid(columns: (1fr, 1fr), gutter: 1em,
[*`cp sorgente destinazione`* (_copy_): l'originale resta al suo posto.
```sh
$ cp hello.c copia.c
$ cp /tmp/ciao.txt ~/hello.txt   # copia e rinomina
```],
[*`mv`* (_move_): un comando, *due usi*.
```sh
$ mv copia.c esempio.c      # rinomina
$ mv esempio.c esercizi/    # sposta
```])

#block(breakable: false, grid(columns: (1fr, 1fr), gutter: 1em, align: horizon,
canvas(length: 0.55cm, {
  import draw: *
  content((0, 3), anchor: "west", text(8pt)[*copia* — $O(N)$])
  for k in range(6) { rect((k * 0.6, 1.8), (k * 0.6 + 0.6, 2.4), fill: rgb("#eef4ff")) }
  line((3.8, 2.1), (5.2, 2.1), mark: (end: "stealth"))
  for k in range(6) { rect((5.4 + k * 0.6, 1.8), (6 + k * 0.6, 2.4), fill: rgb("#eef4ff")) }
  content((4.5, 1.3), text(7pt)[legge e riscrive ogni byte])
  content((0, 0), anchor: "west", text(8pt)[*sposta* (stesso filesystem) — $O(1)$])
  for k in range(6) { rect((k * 0.6, -1.2), (k * 0.6 + 0.6, -0.6), fill: rgb("#eef4ff")) }
  content((3.9, -0.9), anchor: "west", text(8pt)[cambia solo il *percorso* nei metadati])
}),
table(columns: (auto, auto),
  [Operazione], [Costo],
  [copia], [$O(N)$],
  [sposta, stesso filesystem], [$O(1)$],
  [sposta, altro filesystem], [$O(N)$: copia + cancella],
)))

#table(
  columns: (auto, 1fr),
  [Comando], [Descrizione],
  [`rm`], [cancella un file (_remove_)],
  [`rmdir`], [cancella una directory *vuota*],
  [`rm -r`], [cancella una directory con tutto il contenuto. `-r` = *ricorsivamente*: attraversa tutto ciò che c'è dentro],
)

#nota[`rm` *non* sposta nel cestino: da terminale la cancellazione è in genere *definitiva*.]

=== Guardare dentro i file

Non serve sempre un editor:

#table(
  columns: (auto, 1fr),
  [Comando], [Descrizione],
  [`cat`], [scrive tutto il contenuto del file su stdout],
  [`less`], [per file lunghi: si scorre avanti e indietro e si cerca, senza riversare tutto sul terminale. *`q` per uscire*],
  [`head` / `tail`], [prime / ultime 10 righe. `head -n 5 dati.txt` = prime 5],
)

=== Wildcard: le espande la shell

#grid(columns: (1fr, 1fr), gutter: 1em,
[- `*` = *zero o più* caratteri qualsiasi
 - `?` = *esattamente un* carattere],
```sh
$ ls *.c
hello.c  main.c  prova.c
$ ls prova?.c
prova1.c  prova2.c  provaA.c
```)

#align(center, canvas(length: 0.6cm, {
  import draw: *
  content((0, 0), box(inset: 5pt, stroke: 0.6pt)[`ls *.c`])
  line((1.8, 0), (4.4, 0), mark: (end: "stealth")); content((3.1, 0.7), text(8pt, fill: blu)[la shell espande])
  content((4.6, 0), anchor: "west", box(inset: 5pt, stroke: 0.6pt, fill: rgb("#eef4ff"))[`ls hello.c main.c prova.c`])
  line((13.4, 0), (14.8, 0), mark: (end: "stealth"))
  content((15.6, 0), box(inset: 5pt, stroke: 0.6pt, fill: rgb("#fff3c4"))[`ls`])
  content((7, -1.1), text(8pt, fill: gray)[l'espansione avviene *prima* che `ls` parta: `ls` non vede mai l'asterisco])
}))

== Flussi: redirezione e pipe

=== I tre flussi standard

#grid(columns: (1fr, auto), gutter: 1.5em, align: horizon,
table(columns: 3,
  [n.], [Flusso], [Di solito],
  [0], [`stdin` — standard input], [dalla tastiera],
  [1], [`stdout` — standard output], [sul terminale],
  [2], [`stderr` — standard error], [sul terminale],
),
canvas(length: 0.6cm, {
  import draw: *
  rect((0, -1), (4, 1), radius: 0.2, fill: rgb("#eef4ff"), stroke: 1pt + blu)
  content((2, 0), [programma])
  line((-2.5, 0), (-0.1, 0), mark: (end: "stealth")); content((-1.3, 0.45), text(8pt)[0 stdin])
  line((4.1, 0.4), (6.5, 0.4), mark: (end: "stealth")); content((5.3, 0.85), text(8pt)[1 stdout])
  line((4.1, -0.4), (6.5, -0.4), mark: (end: "stealth"), stroke: red); content((5.3, -0.85), text(8pt, fill: red)[2 stderr])
}))

La shell può collegare ciascun flusso a qualcosa di diverso dal terminale.

=== Redirezioni

#align(center, grid(columns: 2, gutter: 1.5em, row-gutter: 1.2em,
  flusso([tastiera], `ls`, [`elenco.txt`], etichetta: [`ls > elenco.txt` — crea o *sovrascrive*]),
  flusso([tastiera], `echo ...`, [`log.txt` + riga], etichetta: [`echo "..." >> log.txt` — *aggiunge* in fondo (_append_)]),
  flusso([`dati.txt`], `programma`, [schermo], etichetta: [`programma < dati.txt` — stdin dal file]),
  flusso([tastiera], `gcc errore.c`, text(fill: red)[`errori.txt`], etichetta: [`gcc errore.c 2> errori.txt` — solo *stderr*]),
))

```sh
$ ls > elenco.txt                 # sul terminale non compare niente
$ cat elenco.txt
hello.c
$ echo "prima riga" > log.txt
$ echo "seconda riga" >> log.txt
$ cat log.txt
prima riga
seconda riga
```

#nota[Con `<` il programma continua a leggere da stdin: è *la shell* che ha collegato stdin al file, il programma non se ne accorge. \
`2>` redirige il file descriptor 2. Si separa stderr da stdout perché output normale ed errori hanno significati diversi e spesso si trattano in modo diverso.]

=== La pipe `|`

Collega lo *stdout del primo* comando allo *stdin del secondo*.

#align(center, canvas(length: 0.6cm, {
  import draw: *
  content((0, 0), box(inset: 7pt, stroke: 1pt + blu, fill: rgb("#eef4ff"), radius: 3pt, text(9pt)[`ls *.c`]))
  line((1.7, 0), (3.6, 0), mark: (end: "stealth"), stroke: 1.5pt + red); content((2.65, 0.5), text(10pt, fill: red)[`|`])
  content((5.2, 0), box(inset: 7pt, stroke: 1pt + blu, fill: rgb("#eef4ff"), radius: 3pt, text(9pt)[`wc -l`]))
  line((6.8, 0), (8.3, 0), mark: (end: "stealth"))
  content((9.4, 0), box(inset: 5pt, stroke: 0.6pt, fill: rgb("#fff3c4"), text(9pt)[`3`]))
  content((0, -1.1), text(7pt)[1. la shell espande `*.c`])
  content((0, -1.6), text(7pt)[2. `ls` produce l'elenco])
  content((6.6, -1.1), text(7pt)[3. la pipe lo passa a `wc`])
  content((6.6, -1.6), text(7pt)[4. `wc -l` conta le righe])
}))

#grid(columns: (1fr, 1fr), gutter: 1em,
[*Con un file temporaneo*
```sh
$ ls > tmp.txt
$ wc -l < tmp.txt
```],
[*Con la pipe*: niente file in mezzo
```sh
$ ls | wc -l
$ ls | less      # scorro l'elenco
```])

#nota[*Idea UNIX*: piccoli programmi che si combinano per costruire operazioni più complesse.]

#block(breakable: false)[
=== Micro-esercizio

Partendo dalla home: creare `lezione02`, entrarci, creare `a.c`, `b.c`, `note.txt` vuoti, salvare l'elenco dei soli `.c` in `sorgenti.txt`, aggiungerlo a `note.txt`, contare le righe di `note.txt`.

```sh
$ mkdir lezione02
$ cd lezione02
$ touch a.c b.c note.txt
$ ls *.c > sorgenti.txt
$ cat sorgenti.txt >> note.txt
$ wc -l < note.txt
2
```
]
