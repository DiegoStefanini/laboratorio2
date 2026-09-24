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
#show grid: it => block(breakable: false, it)  // affiancamenti mai spezzati tra due pagine

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
#outline(depth: 2)

= L'ambiente di lavoro UNIX

== Il terminale e il filesystem

Si lavora dal *terminale*: una finestra in cui gira la *shell*, il programma che legge i comandi e li esegue.

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

I comandi agiscono sul *filesystem*, un albero di directory e file:

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

Per indicare un file nell'albero si usa un *percorso*, assoluto o relativo:

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

Due casi speciali: la *home* e i *file nascosti*.

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

Con `ls -l` si vedono le informazioni su ogni file. Ecco come leggerle:

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

Ogni comando ha la stessa forma. Per esempio `gcc`, il compilatore C che si usa per tutto il corso:

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

Gli argomenti li prepara la shell: *spezza la riga in parole usando gli spazi* e avvia il programma passandogli gli argomenti. Se un nome contiene spazi, le *virgolette* lo tengono insieme come un solo argomento:

```sh
$ touch "appunti lezione.txt"     # un file, non due
$ cat "appunti lezione.txt"
```

#nota[Vedremo come un programma C legge questi argomenti con `argc` e `argv`, i parametri di `main`.]

== Lavorare con i file

Per creare directory e file vuoti si usano `mkdir` e `touch`:

#grid(columns: (1fr, 1fr), gutter: 1em,
```sh
$ mkdir esercizi     # argomento = nome
$ touch appunti.txt  # file vuoto
```,
[`touch` in realtà nasce per *cambiare i timestamp* di un file. Se il file non esiste lo crea: la creazione è una conseguenza utile, non lo scopo.])

Oltre al contenuto, per ogni file UNIX tiene tre marcature temporali (*timestamp*). `stat file` le mostra, insieme agli altri metadati.

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

Per copiare, spostare e cancellare:

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

Per guardare dentro un file non serve sempre un editor:

#table(
  columns: (auto, 1fr),
  [Comando], [Descrizione],
  [`cat`], [scrive tutto il contenuto del file su stdout],
  [`less`], [per file lunghi: si scorre avanti e indietro e si cerca, senza riversare tutto sul terminale. *`q` per uscire*],
  [`head` / `tail`], [prime / ultime 10 righe. `head -n 5 dati.txt` = prime 5],
)

Per lavorare su molti file insieme ci sono le *wildcard*, che espande la shell:

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

Ogni programma ha tre *flussi standard*:

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

Le *redirezioni* li collegano a un file invece che a tastiera e schermo:

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

La *pipe* `|` invece collega lo *stdout del primo* comando allo *stdin del secondo*.

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
*Micro-esercizio.* Partendo dalla home: creare `lezione02`, entrarci, creare `a.c`, `b.c`, `note.txt` vuoti, salvare l'elenco dei soli `.c` in `sorgenti.txt`, aggiungerlo a `note.txt`, contare le righe di `note.txt`.

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

= Il linguaggio C

== Dal sorgente all'eseguibile

Scrivere un programma C è un ciclo che si ripete:

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

Il passo centrale è la compilazione. C è un linguaggio *compilato*: il sorgente `.c` è un semplice file di testo, e per diventare un programma che gira attraversa *quattro fasi*.

#align(center, canvas(length: 1cm, {
  import draw: *
  let scatole = (([`codice.c`], [sorgente]), ([`codiceP.c`], [preprocessato]), ([`codice.o`], [codice oggetto]), ([`eseguibile.out`], [eseguibile]), ([in memoria], [in esecuzione]))
  let fasi = (([1. preprocessing], [`gcc -E`]), ([2. compilazione], [`gcc -c`]), ([3. linking], [`gcc`]), ([4. caricamento], [`./`]))
  for (k, (nome, sotto)) in scatole.enumerate() {
    let x = k * 3.45
    content((x, 0), box(width: 2.55cm, inset: 5pt, stroke: 0.6pt, radius: 2pt,
      fill: if k == 0 { rgb("#fff3c4") } else { rgb("#eef4ff") },
      align(center, text(7.5pt)[#nome \ #text(6.5pt, fill: gray, sotto)])))
    if k < 4 {
      line((x + 1.33, 0), (x + 2.12, 0), mark: (end: "stealth"))
      let (f, c) = fasi.at(k)
      content((x + 1.72, 0.7), text(7pt, fill: blu, f))
      content((x + 1.72, -0.7), text(7pt, c))
    }
  }
  line((-1.2, 1.15), (-1.2, 1.3), (11.6, 1.3), (11.6, 1.15), stroke: 0.7pt + verde)
  content((5.2, 1.65), text(8pt, fill: verde)[`gcc codice.c -o eseguibile.out` fa le fasi 1-3 con un solo comando])
}))

+ *Preprocessing*: vengono eseguite le *direttive per il pre-processore*, le righe che iniziano con `#`.
+ *Compilazione*: il sorgente viene tradotto in *codice oggetto* `.o`.
+ *Linking*: i file oggetto vengono collegati in un unico *eseguibile*.
+ *Caricamento*: quando lo lanci, l'eseguibile viene copiato in memoria e parte.

#base[codice oggetto e linking][Il codice oggetto è il sorgente già tradotto in linguaggio macchina, ma non ancora eseguibile: gli mancano i pezzi che stanno altrove. Per esempio il codice di `printf` non è nel tuo file, sta nella libreria standard. Il *linker* mette insieme il tuo `.o` e questi pezzi, e ne esce un file che si può eseguire.]

La prima fase lavora solo sul testo. Le direttive vengono eseguite *prima* della compilazione vera e propria: sostituiscono dei nomi simbolici con il contenuto che indicano. Due usi:
- `#include <stdio.h>` *include un file*: al suo posto viene incollato il contenuto di una libreria come `stdio.h`, o di un altro file come `my_lib.c`;
- `#define NOME testo` *definisce una macro*: da lì in poi ogni `NOME` viene sostituito con `testo`. Serve per costanti o comandi semplici.

Con `gcc -E` ci si ferma dopo il preprocessing e si vede cosa arriva al compilatore:

#grid(columns: (1fr, 1.15fr), gutter: 1em, align: horizon,
```c
#include <stdio.h>
#define CONST_MESSAGE "Hello world\n"

int main(void) {
    printf(CONST_MESSAGE);
    return 0;
}
```,
```sh
$ gcc -E codice.c -o codiceP.c
$ wc -l codiceP.c
845 codiceP.c     # 7 righe diventate 845
$ tail -4 codiceP.c
int main(void) {
    printf("Hello world\n");
    return 0;
}
```)

Le righe in più sono il contenuto di `stdio.h`, incollato dall'`include`. In fondo c'è il nostro `main`, con `CONST_MESSAGE` già sostituita dal suo testo.

Di solito le fasi non si lanciano una per una: `gcc` (_GNU Compiler Collection_, il compilatore più diffuso) fa preprocessing, compilazione e linking con un solo comando.

```sh
$ gcc hello.c              # se va tutto bene non scrive niente
$ ls
a.out  hello.c             # senza -o l'eseguibile si chiama a.out
$ gcc -Wall -Wextra -std=c11 hello.c -o hello   # warning, C11, nome hello
$ ./hello
Hello, world!
$ echo $?
0
```

#table(columns: (auto, 1fr),
  [Pezzo], [Significato],
  [`-o hello`], [dà il nome all'eseguibile],
  [`-Wall -Wextra`], [attiva i warning: *non sono rumore*, spesso segnalano un errore vero],
  [`-pedantic`], [segnala tutto ciò che non rispetta alla lettera lo standard del C],
  [`-g`], [aggiunge all'eseguibile le informazioni per il _debugger_ (il programma che serve a cercare gli errori)],
  [`-std=c11`], [standard del C da usare (esistono C89, C95, C99, C11, C17, C23)],
  [`./hello`], ["esegui `hello` *che sta nella directory corrente*". La shell cerca i comandi in un elenco di directory, e quella corrente non c'è per forza],
  [`echo $?`], [stampa il valore restituito dall'ultimo programma. *0 = terminato correttamente*],
)

Le opzioni complete sono in `man gcc` e su #link("https://gcc.gnu.org/onlinedocs/gcc/")[gcc.gnu.org/onlinedocs/gcc]. Volendo, le fasi si possono anche separare:

```sh
$ gcc -E codice.c -o codiceP.c     # 1. solo preprocessing
$ gcc -c codice.c -o codice.o      # 1+2: si ferma al codice oggetto
$ gcc -c codiceP.c -o codice.o     # oppure: compila il file già preprocessato
$ gcc codice.o -o eseguibile.out   # 3. linking
$ ./eseguibile.out                 # 4. caricamento ed esecuzione
Hello world
```

Nella quarta fase l'eseguibile viene caricato in memoria, divisa in quattro zone:

#grid(columns: (auto, 1fr), gutter: 1.5em, align: horizon,
pila(larghezza: 3cm,
  ([*codice* \ le istruzioni], rgb("#e6dcf2")),
  ([*dati statici* \ variabili globali], rgb("#fff3c4")),
  ([*heap*], rgb("#dce8fb")),
  ([*stack* \ variabili locali], rgb("#dff2e3")),
),
[
  Ogni zona ha un compito. Il *codice* contiene le istruzioni del programma. I *dati statici* contengono le variabili globali, lo *stack* quelle locali: la differenza tra le due si vede nella prossima sezione.

  #base[stack e heap][Lo *stack* (pila) cresce e si svuota da solo: quando una funzione parte, le sue variabili locali vengono messe in cima; quando finisce, vengono tolte. L'*heap* è la memoria che il programma chiede esplicitamente mentre gira, e che resta finché non la restituisce.]
])

Se qualcosa va storto, l'errore può arrivare in due momenti diversi:

#block(breakable: false, grid(columns: (1fr, 1fr), gutter: 1em,
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
)))

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

== Com'è fatto un programma C

C segue il *paradigma imperativo*: il programma è una sequenza di istruzioni che, una dopo l'altra, cambiano i valori in memoria. Ed è *strutturato a blocchi*: il programma è una collezione di *funzioni*, e l'esecuzione parte sempre dalla funzione `main`. Un file C ha tre parti, in quest'ordine:

#grid(columns: (1.2fr, 1fr), gutter: 1em, align: horizon,
```c
#include <stdio.h>   // 1. direttive

int globalA;         // 2. globali

int main(void) {     // 3. funzioni
    puts("Hello!");
    return 0;
}
```,
[
  #set par(justify: false)
  1. *direttive per il pre-processore*: `#include <stdio.h>` rende disponibili le funzioni di input/output (come `puts`);
  2. *dichiarazioni globali*: variabili visibili in tutto il programma;
  3. *funzioni*: `main` prende niente (`void`) e restituisce un intero (`int`). `return 0` la termina e restituisce 0 al sistema operativo.
])

Le *graffe* `{ }` delimitano un blocco. Indentazione e nomi sensati non sono obbligatori, ma il programma deve essere leggibile. Per questo servono i *commenti*: testo racchiuso fra `/*` e `*/` (anche su più righe), oppure da `//` a fine riga. Il compilatore li ignora.

#nota[I commenti sono molto importanti: documenta *sempre* cosa fa un'istruzione, un blocco o una funzione, per ricordartelo quando rileggi.]

Per stampare ci sono due funzioni, `puts` e `printf`:

#table(columns: (auto, 1fr),
  [Funzione], [Cosa fa],
  [`puts("Laboratorio 2");`], [stampa una stringa *e va a capo*],
  [`printf("Risultato: %d\n", 42);`], [stringa *formattata*: `%d` viene sostituito dal valore. *Non va a capo da sola*: serve `\n`],
)

#nota[`printf` è una funzione a *numero variabile di parametri*: il primo è la stringa di formato, gli altri i valori da inserire al posto dei _placeholder_ `%d`, `%s`, … Tutti i placeholder sono nella sezione sui tipi.]

Mettendo insieme i pezzi:

#grid(columns: (1.3fr, 1fr), gutter: 1em, align: horizon,
```c
#include <stdio.h>

int main(void) {
    int x = 21;   // una variabile

    puts("Laboratorio 2");
    puts("Lezione 1");
    printf("2 * %d = %d\n", x, 2 * x);

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

I nomi che scegli tu (di variabili, funzioni, tipi) sono *identificatori*: sequenze di lettere, cifre e `_` che iniziano con una lettera o con `_`. Le *parole chiave* del linguaggio (`int`, `return`, `while`, …) sono riservate e non si possono usare come nomi.

#let parole-chiave = ("int", "char", "float", "double", "void", "if", "else", "while", "for", "return")
#let identificatore(s) = s.match(regex("^[A-Za-z_][A-Za-z0-9_]*$")) != none and s not in parole-chiave
#align(center, table(columns: 3, align: (left, center, left),
  [Nome], [Valido], [Perché],
  ..(("somma", [lettere]), ("_tmp", [inizia con `_`]), ("x1", [la cifra non è all'inizio]),
     ("1x", [inizia con una cifra]), ("mia-var", [`-` non è ammesso]), ("int", [parola chiave])).map(((s, p)) =>
    (raw(s), if identificatore(s) { text(fill: verde)[sì] } else { text(fill: red)[no] }, p)).flatten()
))

Nel programma di sopra `x` è una *variabile*: una *locazione di memoria* che contiene un *valore modificabile* di un certo *tipo*. L'insieme dei valori di tutte le variabili in un certo momento è lo *stato del programma*.

#grid(columns: (1fr, 1fr), gutter: 1.5em, align: horizon,
```c
int a;        // dichiarazione
int a = 1;    // con valore iniziale
```,
[La *dichiarazione* dice al compilatore il tipo, e quindi *quanta memoria* riservare.])

A ogni variabile è associato un *indirizzo*: un numero intero che indica dove si trova in memoria.

#align(center, canvas(length: 1cm, {
  import draw: *
  for k in range(8) {
    let x = k * 0.9
    rect((x, 0), (x + 0.9, 0.6), stroke: 0.5pt, fill: if k >= 2 and k < 6 { rgb("#eef4ff") } else { white })
    content((x + 0.45, -0.25), text(6.5pt, fill: gray, str(998 + k)))
  }
  content((3.6, 0.3), [`1`])
  line((1.8, 0.75), (1.8, 0.9), (5.4, 0.9), (5.4, 0.75), stroke: 0.6pt + blu)
  content((3.6, 1.2), text(8pt, fill: blu)[`int a` occupa più byte (qui 4)])
  line((1.8, -0.9), (1.85, -0.45), mark: (end: "stealth"), stroke: 0.5pt)
  content((1.8, -1.15), text(8pt)[indirizzo di `a` = 1000])
  content((7.9, 0.3), anchor: "west", text(8pt, fill: gray)[memoria: un byte per casella])
}))

Una variabile però non è utilizzabile ovunque. Lo *scoping* è la regione del programma in cui una variabile è dichiarata, definita e utilizzabile: fuori da lì non è visibile. In C lo scoping è *statico*: viene deciso *a tempo di compilazione*, guardando dove sta la dichiarazione nel testo.

#grid(columns: (1fr, 1fr), gutter: 1em,
box(stroke: 0.6pt + rgb("#b36b00"), inset: 8pt, width: 100%)[*Globale*: dichiarata fuori da ogni blocco e funzione. Sta nei *dati statici* ed è visibile nell'intero programma.],
box(stroke: 0.6pt + verde, inset: 8pt, width: 100%)[*Locale*: dichiarata dentro un blocco o una funzione. Sta sullo *stack* ed è visibile nel blocco e nei blocchi annidati dentro.])

Una variabile locale in un blocco annidato può *coprire* una variabile con lo stesso nome, globale o di un blocco più esterno:

#let regione(titolo, colore, corpo) = block(stroke: 0.8pt + colore, radius: 4pt, inset: 6pt, width: 100%, below: 0pt)[#text(7.5pt, fill: colore, titolo) #corpo]
#grid(columns: (1.4fr, 1fr), gutter: 1em, align: horizon,
[
```c
int g = 1;              // globale

int main(void) {
    int x = 5;          // locale a main
    {
        int g = 2;  // copre la g globale
        printf("g = %d, x = %d\n", g, x);
    }
    printf("g = %d\n", g);
    return 0;
}
```
```sh
$ ./scope
g = 2, x = 5     # dentro il blocco
g = 1            # fuori
```],
text(8.5pt, regione([programma — vede `g = 1`], rgb("#b36b00"),
  regione([`main` — vede `g = 1` e `x`], blu,
    regione([blocco interno — vede `x` e la *sua* `g = 2`], verde)[\ la `g` globale qui è coperta]))))

== Tipi e costanti

C è *strongly typed*: ogni espressione e ogni variabile ha un tipo, noto al compilatore. I tipi di base sono quattro:

#table(columns: (auto, 1fr),
  [Tipo], [Contiene],
  [`char`], [un intero grande *un byte*],
  [`int`], [numeri interi: `123`, `-45`, `0`; anche costanti carattere come `'a'` o `'1'`],
  [`float`], [numeri reali],
  [`double`], [numeri reali in *precisione doppia*],
)

Si possono modificare con quattro *qualifier*:
- `short` e `long` qualificano gli interi: `short int a;`. Da soli stanno per `short int` e `long int`. `long` può qualificare anche `double`;
- `signed` e `unsigned` qualificano `char` e `int`: `unsigned` = solo valori ≥ 0.

Quanti byte occupa ogni tipo *dipende dalla macchina*: il C garantisce solo `short` ≤ `int` ≤ `long`. Per saperlo si usa l'operatore `sizeof`, che restituisce la dimensione in byte:

#grid(columns: (1fr, auto), gutter: 1.5em, align: horizon,
[
```c
int main(void) {
    int a = sizeof(int);
    printf("%d\n", a);    // stampa 4
    return 0;
}
```
Misurate così su questo computer (Linux a 64 bit):],
canvas(length: 0.5cm, {
  import draw: *
  let tipi = (("char", 1), ("short", 2), ("int", 4), ("long", 8), ("float", 4), ("double", 8))
  for (i, (t, n)) in tipi.enumerate() {
    let y = -i * 0.85
    content((-0.3, y + 0.3), anchor: "east", text(9pt, raw(t)))
    for k in range(n) {
      rect((k * 0.8, y), (k * 0.8 + 0.8, y + 0.6), stroke: 0.5pt,
        fill: if i < 4 { rgb("#eef4ff") } else { rgb("#fff3c4") })
    }
    content((n * 0.8 + 0.3, y + 0.3), anchor: "west", text(8pt)[#n byte])
  }
}))

`sizeof` si applica anche alle *espressioni*, e lì c'è una sorpresa (`%zu` è il placeholder di `printf` per il risultato di `sizeof`):

#block(breakable: false, grid(columns: (1fr, 1fr), gutter: 1em, align: horizon,
```c
short int a = 1;
printf("%zu\n", sizeof(a));      // 2
printf("%zu\n", sizeof(a + 1));  // 4
```,
base[promozione a `int`][Nei calcoli, i valori `char` e `short` vengono prima convertiti in `int`. Quindi `a + 1` è un `int`, anche se `a` è `short`: 4 byte, non 2.]))

Il `char` è un intero, ma si usa per i *caratteri*. La tabella *ASCII* assegna un carattere a ogni valore che sta in un byte:

#align(center, grid(columns: 5, gutter: 5pt,
  ..("a", "b", "*", "A", "0").map(c => box(stroke: 0.6pt, inset: 5pt, width: 1.5cm, radius: 2pt,
    align(center)[#raw("'" + c + "'") \ #text(9pt, fill: blu, str(str.to-unicode(c)))]))))

Quindi `'a'` e `97` sono lo stesso numero: cambia solo come lo stampi (`%c` o `%d`). Nota `'0'` = 48: il carattere zero non è il numero zero.

#base[`'a'` non è un `char`][Una costante carattere come `'a'` in C ha tipo `int`: `sizeof('a')` dà 4, mentre `sizeof(char)` dà 1. Il valore è lo stesso (97), solo che occupa più spazio finché non lo metti in una variabile `char`.]

I reali `float` e `double` sono rappresentati in *notazione scientifica*, secondo lo standard *IEEE 754*. Tre componenti: il *bit di segno*, l'*esponente* e la *mantissa*, normalizzata in modo che la parte intera sia 1. Per esempio $1.34423424 dot 10^(-5)$ rappresenta $0.0000134423424$.

#base[quanti bit per ogni parte][In un `float` (32 bit) le tre parti sono grandi così; in un `double` (64 bit) sono 1, 11 e 52 bit.
#align(center, canvas(length: 0.42cm, {
  import draw: *
  let parti = (("segno", 1, rgb("#fde2e2")), ("esponente", 8, rgb("#fff3c4")), ("mantissa", 23, rgb("#eef4ff")))
  let x = 0
  for (nome, n, c) in parti {
    rect((x, 0), (x + n * 0.9, 0.9), fill: c, stroke: 0.6pt)
    content((x + n * 0.45, 0.45), text(7.5pt)[#n])
    content((x + n * 0.45, -0.5), text(7.5pt, nome))
    x += n * 0.9
  }
}))]

*Non tutti i numeri sono rappresentabili*: i bit sono finiti, quindi molti numeri vengono approssimati al più vicino disponibile. Anche 0.1:

```sh
$ ./reali                          # printf("%.20f\n", 0.1);
0.10000000000000000555
```

Le *costanti* sono valori non modificabili scritti direttamente nel codice: interi, in virgola mobile, caratteri e stringhe.

#table(columns: (auto, 1fr),
  [Costante], [Esempi],
  [intera o in virgola mobile, anche con segno], [`1`, `-32`, `3.15`],
  [intera in ottale (inizia con `0`) o esadecimale (inizia con `0x`)], [`014`, `0x3A`],
  [carattere, tra apici singoli], [`'a'`, `'\n'`],
  [stringa, tra apici doppi], [`"ciao!\n"`],
)

Tutte le costanti in virgola mobile sono `double`.

#base[ottale ed esadecimale][Sono lo stesso numero scritto in base 8 o in base 16 invece che in base 10. In esadecimale le cifre dopo il 9 sono `A`=10, `B`=11, …, `F`=15.
- `014` = $1 dot 8 + 4 = 12$
- `0x3A` = $3 dot 16 + 10 = 58$
Attenzione: lo `0` iniziale non è decorativo. `010` vale 8, non 10.]

Il carattere `\` è un carattere speciale di *escape*: insieme al carattere dopo indica un carattere che non si può scrivere direttamente, perché non stampabile o già usato dalla sintassi.

#align(center, table(columns: 4, align: center,
  [`'\n'`], [`'\t'`], [`'\0'`], [`'\\'`],
  [a capo], [tabulazione], [carattere nullo (codice 0)], [la barra `\` stessa],
))

Le costanti stringa sono memorizzate come *array di caratteri*, cioè caratteri uno dopo l'altro in memoria:

#base[il terminatore `'\0'`][In fondo a ogni stringa il compilatore aggiunge `'\0'`, che segna dove finisce. Per questo `sizeof("ciao!\n")` vale 7: sei caratteri più il terminatore.
#align(center, canvas(length: 1cm, {
  import draw: *
  for (k, c) in ("c", "i", "a", "o", "!", "\\n", "\\0").enumerate() {
    rect((k * 0.8, 0), (k * 0.8 + 0.8, 0.6), stroke: 0.5pt, fill: if k == 6 { rgb("#fde2e2") } else { white })
    content((k * 0.8 + 0.4, 0.3), raw(c))
  }
}))]

Ora che i tipi sono chiari si può completare `printf`: ogni tipo ha il suo placeholder, e *il placeholder deve essere compatibile con il tipo del valore*. Ognuno è fatto così:

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
  [`%lld`], [long long (ancora più lungo)], [`%p`], [indirizzo di memoria],
  [`%zu`], [`size_t`: il risultato di `sizeof`], [`%%`], [il carattere %],
)

== Operatori ed espressioni

Gli operatori combinano valori e variabili in *espressioni*. Sono di quattro famiglie:

#block(breakable: false, table(columns: (auto, 1fr),
  [Famiglia], [Operatori],
  [aritmetici], [`+`, `-`, `*`, `/`, `%`],
  [logici e di confronto], [`!`, `&&`, `||` fra valori booleani; `==`, `!=`, `>`, `>=`, `<`, `<=` fra valori numerici],
  [di assegnamento], [`=`, `+=`, `-=`, `*=`, `/=`, `%=`],
  [incremento e decremento], [`++`, `--`],
))

Gli *aritmetici* sono addizione, sottrazione, moltiplicazione, divisione e modulo (il resto della divisione). Il risultato dipende dal tipo degli operandi: tra due interi la divisione è *intera*, la parte decimale si butta.

#grid(columns: (1fr, auto), gutter: 1.5em, align: horizon,
```c
5 / 3        // 1          divisione intera
5.0 / 3.0    // 1.666667   divisione tra reali
5 % 3        // 2          resto
```,
canvas(length: 1cm, {
  import draw: *
  for k in range(5) { circle((k * 0.6, 0), radius: 0.22, fill: if k < 3 { rgb("#eef4ff") } else { rgb("#fde2e2") }) }
  line((-0.25, -0.35), (-0.25, -0.4), (1.45, -0.4), (1.45, -0.35), stroke: 0.8pt + blu)
  content((0.6, -0.75), text(8pt, fill: blu)[un gruppo da 3: `5 / 3` = 1])
  line((1.55, 0.35), (1.55, 0.4), (2.65, 0.4), (2.65, 0.35), stroke: 0.8pt + red)
  content((2.1, 0.75), text(8pt, fill: red)[avanzano 2: `5 % 3` = 2])
}))

Il risultato deve stare nel tipo dell'espressione: se è troppo grande (o troppo piccolo) per i byte a disposizione si ha *overflow* (o *underflow*), e il valore che esce è sbagliato.

Gli operatori *logici* sono tutti binari tranne `!`. In C *non esiste un tipo booleano primitivo tradizionale*: si usano i numeri. *0 è falso, qualsiasi valore diverso da 0 è vero*. Il risultato di un operatore logico o di confronto è sempre *0 se falso, 1 se vero*:

#let cv(b) = if b { "1" } else { "0" }
#align(center, table(columns: 5, align: center,
  [`a`], [`b`], [`!a`], [`a && b`], [`a || b`],
  ..for a in (0, 5) { for b in (0, -3) {
    (str(a), str(b), cv(a == 0), cv(a != 0 and b != 0), cv(a != 0 or b != 0)).map(raw)
  } }
))

`&&` e `||` hanno una *valutazione cortocircuitata*: la valutazione si ferma appena il risultato è noto. Se in `a && b` la `a` vale 0, il risultato è già 0 e `b` non viene nemmeno calcolata; se in `a || b` la `a` è diversa da 0, il risultato è già 1. Così si ottiene un risultato anche quando la parte dopo darebbe errore:

#align(center, canvas(length: 1cm, {
  import draw: *
  content((0, 0), box(inset: 5pt, stroke: 0.8pt + verde, fill: rgb("#dff2e3"), radius: 2pt)[`b != 0`])
  content((2.1, 0), text(12pt)[`&&`])
  content((4.5, 0), box(inset: 5pt, stroke: 0.6pt + gray, radius: 2pt, text(fill: gray)[`a / b > 2`]))
  line((3.5, -0.3), (5.5, 0.3), stroke: 1pt + red)
  content((0, -0.9), box(width: 3.4cm, align(center, text(8pt)[con `b = 0` vale 0, \ quindi tutto vale 0 …])))
  content((4.5, -0.9), box(width: 4.2cm, align(center, text(8pt, fill: red)[… e questa non si calcola: \ niente divisione per 0])))
}))

Attenzione a scrivere i confronti come in matematica. `2 < a < 5` *non* controlla che `a` sia tra 2 e 5: equivale a `(2 < a) < 5`, e `2 < a` vale 0 o 1, che è sempre minore di 5. Con `a = 7`:

#grid(columns: (auto, 1fr), gutter: 2em, align: horizon,
passi(("a = 7", "2 < a < 5"), ("prima 2 < a", "1 < 5"), ("risultato", "1  (vero!)")),
[La forma corretta è `2 < a && a < 5`, che con `a = 7` dà 0. Con `-Wall` il compilatore se ne accorge:
```sh
warning: comparisons like 'X<=Y<=Z' do not have their
mathematical meaning [-Wparentheses]
```])

L'*assegnamento* ha la forma `variabile = parte_destra`. La parte destra è un'espressione, che può essere a sua volta un assegnamento: l'assegnamento stesso restituisce il valore assegnato. Per questo si può scrivere l'*assegnamento multiplo*, che è *associativo da destra*: si esegue partendo dall'ultimo.

#grid(columns: (1fr, auto), gutter: 1.5em, align: horizon,
```c
a = b = c = 0;   // a = (b = (c = 0))
a += 5;          // a = a + 5
a = 3 + 4 * 2;   // 11: prima il calcolo
```,
canvas(length: 1cm, {
  import draw: *
  let nomi = ("a", "b", "c")
  for (k, n) in nomi.enumerate() {
    content((k * 1.8, 0), box(inset: 4pt, stroke: 0.6pt, raw(n + " = 0")))
    content((k * 1.8, -0.5), text(7pt, fill: gray)[#(3 - k)°])
  }
  content((5.1, 0), [`0`])
  for k in range(3) { line((k * 1.8 + 1.7, 0.45), (k * 1.8 + 0.2, 0.45), mark: (end: "stealth"), stroke: 0.6pt + blu) }
  content((2.5, 0.85), text(7.5pt, fill: blu)[il valore viaggia da destra a sinistra])
}))

Gli operatori di assegnamento hanno *priorità più bassa* degli altri: nell'ultima riga prima si calcola tutta la parte destra, poi si assegna.

#nota[Attenzione: i tipi devono essere *compatibili*, sia dentro l'espressione sia tra l'espressione e la variabile a cui viene assegnato il valore.]

`++` e `--` aumentano o diminuiscono di 1. La posizione conta quando il valore viene usato:

#align(center, table(columns: 3, align: (left, left, center),
  [Con `a = 5`], [Cosa fa], [Risultato],
  [`x = ++a;`], [prima incrementa, poi restituisce il *nuovo* valore], [`x = 6`, `a = 6`],
  [`x = a++;`], [restituisce il valore *attuale*, poi incrementa], [`x = 5`, `a = 6`],
))

== Il controllo del flusso

Le istruzioni di un blocco vengono eseguite in ordine. I *comandi* condizionali e i cicli cambiano quest'ordine, e decidono guardando un'espressione: come per gli operatori logici, *diversa da 0 = vera, 0 = falsa*.

// schema a blocchi: ogni nodo è una scatola di larghezza fissa
#let nodo(pos, t, fill: rgb("#eef4ff")) = draw.content(pos, box(width: 1.9cm, inset: 4pt, stroke: 0.6pt, radius: 3pt, fill: fill, align(center, text(7.5pt, t))))
#let cond(pos, t) = nodo(pos, t, fill: rgb("#fff3c4"))
#let freccia(..punti) = draw.line(..punti, mark: (end: "stealth"), stroke: 0.6pt)
#let etichetta(pos, t) = draw.content(pos, text(7pt, fill: gray, t))

#grid(columns: (1fr, auto), gutter: 1.5em, align: horizon,
[
```c
if (espressione)
    comando;
else
    comando;
```
Se l'espressione è diversa da 0 si esegue il primo comando, altrimenti quello dell'`else`. L'`else` si può omettere, e gli `if` si possono annidare uno dentro l'altro.
],
canvas(length: 1cm, {
  import draw: *
  freccia((0, 0.9), (0, 0.3))
  cond((0, 0), [`espressione` ≠ 0 ?])
  freccia((-0.5, -0.3), (-1.1, -1.0)); etichetta((-1.05, -0.5), [sì])
  freccia((0.5, -0.3), (1.1, -1.0)); etichetta((1.05, -0.5), [no])
  nodo((-1.1, -1.3), [comando])
  nodo((1.1, -1.3), [comando dell'`else`])
  line((-1.1, -1.6), (-1.1, -2.0), (1.1, -2.0), (1.1, -1.6), stroke: 0.6pt)
  freccia((0, -2.0), (0, -2.5))
}))

I *cicli* ripetono un blocco di codice finché l'espressione resta diversa da 0; quando diventa 0 si prosegue dopo il ciclo. Il C ne ha tre:

#align(center, grid(columns: 3, gutter: 2.5em,
[```c
while (espressione)
    comando;
```],
[```c
do
    comando;
while (espressione);
```],
[```c
for (espressione1;
     espressione2;
     espressione3)
    comando;
```],
canvas(length: 1cm, {
  import draw: *
  freccia((0, 0.9), (0, 0.3))
  cond((0, 0), [`espressione` ≠ 0 ?])
  freccia((0, -0.3), (0, -1.0)); etichetta((0.25, -0.65), [sì])
  nodo((0, -1.3), [comando])
  freccia((-0.95, -1.3), (-1.3, -1.3), (-1.3, 0), (-0.95, 0))
  freccia((0.95, 0), (1.3, 0), (1.3, -2.1)); etichetta((1.15, 0.2), [no])
  etichetta((1.3, -2.3), [fuori])
}),
canvas(length: 1cm, {
  import draw: *
  freccia((0, 0.9), (0, 0.3))
  nodo((0, 0), [comando])
  freccia((0, -0.3), (0, -1.0))
  cond((0, -1.3), [`espressione` ≠ 0 ?])
  freccia((-0.95, -1.3), (-1.3, -1.3), (-1.3, 0), (-0.95, 0)); etichetta((-1.5, -0.65), [sì])
  freccia((0, -1.6), (0, -2.1)); etichetta((0.25, -1.85), [no])
  etichetta((0, -2.3), [fuori])
}),
canvas(length: 1cm, {
  import draw: *
  freccia((0, 1.9), (0, 1.6))
  nodo((0, 1.3), [`espressione1`])
  freccia((0, 1.0), (0, 0.3))
  cond((0, 0), [`espressione2` ≠ 0 ?])
  freccia((0, -0.3), (0, -1.0)); etichetta((0.25, -0.65), [sì])
  nodo((0, -1.3), [comando])
  freccia((0, -1.6), (0, -2.0))
  nodo((0, -2.3), [`espressione3`])
  freccia((-0.95, -2.3), (-1.3, -2.3), (-1.3, 0), (-0.95, 0))
  freccia((0.95, 0), (1.3, 0), (1.3, -3.0)); etichetta((1.15, 0.2), [no])
  etichetta((1.3, -3.2), [fuori])
}),
))

Il `while` controlla l'espressione *prima* di ogni giro: se è falsa subito, il corpo non viene mai eseguito. Il `do-while` la controlla *dopo*: il corpo viene eseguito *almeno una volta*. Esempio: stampare le cifre di un numero, dall'ultima alla prima. `n % 10` è l'ultima cifra, `n /= 10` la toglie.

#block(breakable: false, grid(columns: (1fr, auto), gutter: 1.5em, align: horizon,
```c
int n = 12345;
while (n > 0) {
    printf("%d\n", n % 10);
    n /= 10;
}
```,
{
  let righe = ()
  let n = 12345
  while n > 0 {
    righe += (str(n), str(calc.rem(n, 10)), str(calc.quo(n, 10)))
    n = calc.quo(n, 10)
  }
  table(columns: 3, align: right, [`n`], [stampa `n % 10`], [poi `n` diventa], ..righe.map(raw), [`0`], table.cell(colspan: 2)[`n > 0` falso: fine])
}))

Nel `for`, `espressione1` viene valutata *una sola volta*, prima del primo giro. Poi, finché `espressione2` è vera, si esegue il corpo, e alla fine di ogni giro si valuta `espressione3`. È quindi solo un modo compatto di scrivere un `while`. Ognuna delle tre espressioni si può omettere, come la prima qui a destra:

#grid(columns: (0.8fr, 0.8fr, 1.4fr), gutter: 1em,
```c
for (e1; e2; e3)
    comando;
```,
```c
e1;
while (e2) {
    comando;
    e3;
}
```,
```c
int n = 12345;
for (; n > 0; n /= 10)
    printf("%d\n", n % 10);
```)

#nota[Attenzione: un ciclo può *non terminare mai*, se l'espressione non diventa mai 0.]

Due istruzioni cambiano il giro dall'interno:
- `break` causa l'*uscita immediata* dal ciclo (o dallo `switch`) che la contiene;
- `continue` *termina il giro corrente* e passa al successivo. Può comparire solo in `for`, `while` e `do-while`.

#grid(columns: (1fr, 1fr), gutter: 1em,
[
```c
int a = 0;
while (1) {            // sempre vero
    if (a == 10) break;
    a++;
}                      // qui a vale 10
```
Il ciclo `while (1)` non finirebbe mai: è il `break` che lo chiude.],
[
```c
for (int k = 0; k < 5; k++) {
    if (k == 2) continue;
    printf("%d ", k);
}                      // 0 1 3 4
```
Con `k = 2` il `printf` viene saltato, ma il ciclo va avanti.])

Infine lo `switch`, un'istruzione condizionale a *scelta multipla*. L'espressione deve essere di tipo *intero*; ogni `case` ha un'etichetta costante, e le etichette devono essere *uniche*. Il controllo salta all'etichetta uguale al valore dell'espressione, o a `default` se nessuna corrisponde.

#grid(columns: (1fr, 1fr), gutter: 1em, align: horizon,
```c
switch (espressione) {
    case espr_costante:
        comando;
        break;
    case espr_costante:
        comando;
        break;
    default:
        comando;
}
```,
[
Il `break` qui è essenziale: *senza `break` vengono eseguite anche le istruzioni dei `case` successivi*. Con `c = 2`:
#block(inset: (left: 1em), text(9pt, {
  set par(leading: 0.8em)
  text(fill: gray)[`case 1: puts("uno");`] + linebreak()
  [`case 2: puts("due");` #text(fill: blu)[← entra qui; niente `break`: prosegue ↓]] + linebreak()
  [`case 3: puts("tre"); break;` #text(fill: red)[→ esce]] + linebreak()
  text(fill: gray)[`default: puts("altro");`]
}))
Stampa `due` e poi `tre`. Con `-Wextra` gcc avvisa: `this statement may fall through`.])
