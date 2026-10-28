#import "@preview/cetz:0.4.2": canvas, draw, tree

#set document(title: "Laboratorio 2 — Dispensa")
#set page(paper: "a4", margin: 2.2cm, numbering: "1")
#set text(lang: "it", size: 11pt)
#set par(justify: true)
#set heading(numbering: "1.1")
#show heading.where(level: 1): it => { pagebreak(weak: true); it }
#show raw.where(block: true): block.with(fill: luma(245), inset: 8pt, radius: 4pt, width: 100%, breakable: false)
#show table: set par(justify: false)
#show table: it => block(breakable: false, it)
#show grid: set par(justify: false)
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

// "cosa devi saper fare" all'inizio di un capitolo
#let obiettivi(..voci) = block(stroke: 1pt + luma(150), radius: 4pt, inset: 10pt, width: 100%)[
  *Cosa devi saper fare* #list(..voci.pos())]
// esercizio dalle slide del prof: solo consegna, niente soluzione
#let esercizio(titolo, body) = block(breakable: false, stroke: (left: 3pt + rgb("#e08a00")), fill: rgb("#fff6e6"), inset: 10pt, width: 100%)[
  *Esercizio — #titolo* \ #body]

// definizione di un concetto importante
#let viola = rgb("#7b4bb7")
#let definizione(titolo, body) = block(
  fill: rgb("#f4effc"), stroke: (left: 3pt + viola),
  inset: 10pt, width: 100%,
)[*Definizione — #titolo.* #body]

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

#obiettivi(
  [muoverti nel filesystem con percorsi assoluti e relativi (`pwd`, `ls`, `cd`, `.`, `..`, `~`);],
  [creare, copiare, spostare e cancellare file e directory, e dire quali timestamp cambiano;],
  [prevedere cosa fanno wildcard, redirezioni (`>`, `>>`, `<`, `2>`) e pipe `|`.],
)

== Il terminale e il filesystem

Si lavora dal *terminale*: una finestra in cui gira la *shell* (bash, zsh), il programma che legge i comandi e li esegue.

#grid(columns: (1fr, 1fr), gutter: 1.5em, align: horizon,
```sh
$ pwd
/home/studente/lab2
$ ls
appunti.txt  esercizi  hello.c
```,
[Il *prompt* (`$`) dice che la shell aspetta un comando. Non fa parte del comando e non è sempre `$`.])

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
  Parte da `/`, la *root*: ogni file o directory si raggiunge con un *percorso*, in cui `/` separa un livello dal successivo.

  File e directory sono oggetti diversi, ma nella stessa directory non possono avere lo stesso nome.

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

#esercizio[orientarsi][Stampare la directory corrente e il suo contenuto, creare una directory `lezione01`, entrarci e verificare di essere nel posto giusto. Comandi: `pwd`, `ls`, `mkdir`, `cd`.]

== Lavorare con i file

Per creare directory e file vuoti si usano `mkdir` e `touch`:

#grid(columns: (1fr, 1fr), gutter: 1em,
```sh
$ mkdir esercizi     # argomento = nome
$ touch appunti.txt  # file vuoto
```,
[`touch` in realtà nasce per *cambiare i timestamp* (gli orari registrati) di un file. Se il file non esiste lo crea: la creazione è una conseguenza utile, non lo scopo.])

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

#block(breakable: false)[Per guardare dentro un file non serve sempre un editor:

#table(
  columns: (auto, 1fr),
  [Comando], [Descrizione],
  [`cat`], [scrive tutto il contenuto del file sul terminale],
  [`less`], [per file lunghi: si scorre avanti e indietro e si cerca, senza riversare tutto sul terminale. *`q` per uscire*],
  [`head` / `tail`], [prime / ultime 10 righe. `head -n 5 dati.txt` = prime 5],
)]

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

La shell può collegare ogni flusso a qualcosa di diverso dal terminale. Le *redirezioni* lo collegano a un file:

#align(center, grid(columns: 2, gutter: 1.5em, row-gutter: 1.2em,
  flusso([tastiera], `ls`, [`elenco.txt`], etichetta: [`ls > elenco.txt` — crea o *sovrascrive*]),
  flusso([tastiera], `echo ...`, [`log.txt` + riga], etichetta: [`echo "..." >> log.txt` — *aggiunge* in fondo (_append_)]),
  flusso([`dati.txt`], `programma`, [schermo], etichetta: [`programma < dati.txt` — stdin dal file]),
  flusso([tastiera], `gcc errore.c`, text(fill: red)[`errori.txt`], etichetta: [`gcc errore.c 2> errori.txt` — solo *stderr*]),
))

```sh
$ ls > elenco.txt                 # sul terminale non compare niente
$ cat elenco.txt
appunti.txt
elenco.txt
esercizi
hello.c
$ echo "prima riga" > log.txt
$ echo "seconda riga" >> log.txt
$ cat log.txt
prima riga
seconda riga
```

#block(breakable: false, nota[Con `<` il programma continua a leggere da stdin: è *la shell* che ha collegato stdin al file, il programma non se ne accorge. \
`2>` redirige il file descriptor 2. Si separa stderr da stdout perché output normale ed errori hanno significati diversi e spesso si trattano in modo diverso.])

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

#esercizio[file e flussi][Partendo dalla home: creare la directory `lezione02` ed entrarci; creare tre file vuoti `a.c`, `b.c`, `note.txt`; mostrare solo i file `.c` e salvare quell'elenco in `sorgenti.txt`; aggiungere il contenuto di `sorgenti.txt` a `note.txt`; contare le righe di `note.txt`.]

= Il linguaggio C

#obiettivi(
  [compilare con `gcc`, separare le fasi (`-E`, `-c`, linking) e distinguere errori di compilazione, di linking e di esecuzione;],
  [dire tipo e valore di un'espressione: divisione intera, conversioni, casting, cortocircuito, `++` prefisso e postfisso;],
  [scrivere cicli, `if` e `switch`, e leggere e stampare con `scanf` e `printf`;],
  [usare array, matrici, `struct`, `enum` e `typedef`;],
  [scrivere funzioni con prototipo, dividere un programma in `.h` e `.c`, e dire dove vive e chi vede una variabile (`auto`, `extern`, `static`).],
)

== Dal sorgente all'eseguibile <compilazione>

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

La prima fase lavora solo sul testo: le direttive sostituiscono un nome con il contenuto che indica. Due usi:
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

Di solito le prime tre fasi si fanno con un solo comando, `gcc` (_GNU Compiler Collection_):

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
  Variabili globali e locali sono spiegate nella prossima sezione.

  Lo *stack* (pila) cresce e si svuota da solo: quando una funzione parte, le sue variabili locali vengono messe in cima; quando finisce, vengono tolte. L'*heap* è la memoria che il programma chiede esplicitamente mentre gira, e che resta finché non la restituisce (@allocazione).
])

Se qualcosa va storto, l'errore può arrivare in due momenti diversi:

#block(breakable: false, grid(columns: (1fr, 1fr), gutter: 1em,
[
```c
#include <stdio.h>

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

#box(stroke: 0.6pt + verde, inset: 8pt, width: 100%)[*Se non funziona, controlla* (sono gli errori banali che fanno perdere tempo):
  + sono nella directory giusta? (`pwd`)
  + il sorgente esiste, ed è quello che ho modificato? (`ls`)
  + ho ricompilato? ci sono errori o warning?
  + l'eseguibile è stato creato, e sto eseguendo quello giusto?]

#esercizio[il ciclo completo][Creare `hello.c`, compilarlo con i warning attivi ed eseguirlo; poi cambiare il messaggio, ricompilare e rieseguire.]

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

Graffe, commenti (`/* … */` e `//`) e punto e virgola sono come in JavaScript.

Per stampare ci sono due funzioni, `puts` e `printf`:

#table(columns: (auto, 1fr),
  [Funzione], [Cosa fa],
  [`puts("Laboratorio 2");`], [stampa una stringa *e va a capo*],
  [`printf("Risultato: %d\n", 42);`], [stringa *formattata*: `%d` viene sostituito dal valore. *Non va a capo da sola*: serve `\n`],
)

#nota[`printf` è una funzione a *numero variabile di parametri*: il primo è la stringa di formato, gli altri i valori da inserire al posto dei _placeholder_ `%d`, `%s`, …]

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

#esercizio[tre modifiche][Partendo da `hello.c`: stampare il proprio nome; stampare due righe con `printf`; introdurre una variabile intera e stamparne il valore.]

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
[Nei calcoli i valori `char` e `short` vengono prima convertiti in `int`. Quindi `a + 1` è un `int`, anche se `a` è `short`: 4 byte, non 2.]))

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

In fondo a ogni stringa il compilatore aggiunge `'\0'`, che segna dove finisce (@stringhe). Per questo `sizeof("ciao!\n")` vale 7: sei caratteri più il terminatore.
#align(center, canvas(length: 1cm, {
  import draw: *
  for (k, c) in ("c", "i", "a", "o", "!", "\\n", "\\0").enumerate() {
    rect((k * 0.8, 0), (k * 0.8 + 0.8, 0.6), stroke: 0.5pt, fill: if k == 6 { rgb("#fde2e2") } else { white })
    content((k * 0.8 + 0.4, 0.3), raw(c))
  }
}))

Ogni tipo ha il suo placeholder in `printf`, e *il placeholder deve essere compatibile con il tipo del valore*. Ognuno è fatto così:

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
  [`%hd`], [short], [`%Lf`], [long double],
)

`printf` scrive su stdout; per *leggere da stdin* c'è `scanf`, sempre nella libreria `stdio`. La stringa di formato è la stessa, ma dopo si passano gli *indirizzi* delle variabili in cui salvare i valori: `&a` è l'indirizzo di `a`.

#grid(columns: (1fr, 1fr), gutter: 1em, align: horizon,
```c
int a, b;
scanf("%d %d", &a, &b);   // due interi
printf("a = %d\n", a);
```,
nota[I placeholder sono gli stessi di `printf`, *tranne quello per `double`*: in `scanf` è `%lf`.])

#nota[Ogni carattere in più nella stringa di formato `scanf` *lo aspetta in input*: con `scanf("ciao%d", &n)` bisogna scrivere proprio `ciao` prima del numero. Per questo il prof chiede una `scanf` per variabile, con solo il placeholder.]

== Operatori e controllo del flusso

Operatori (`+ - * / %`, `== != < <= > >=`, `! && ||`, `= += -= …`, `++ --`), `if`/`else`, `while`, `do-while`, `for`, `break`, `continue` e `switch` si scrivono e funzionano come in JavaScript, cortocircuito di `&&` e `||` compreso. Le differenze sono nei *tipi*.

La prima: *tra due interi la divisione è intera*, la parte decimale si butta. In JavaScript `5 / 3` darebbe 1.666…

```c
5 / 3        // 1          divisione intera
5.0 / 3.0    // 1.666667   divisione tra reali
5 % 3        // 2          resto
```

Il risultato deve stare nel tipo dell'espressione: se è troppo grande (o troppo piccolo) per i byte a disposizione si ha *overflow* (o *underflow*), e il valore che esce è sbagliato.

Se in un'espressione ci sono tipi diversi, il C li converte da solo (*conversione implicita*): il tipo più "corto" viene trasformato in quello più "lungo", lungo questa scala (è la stessa promozione vista con `sizeof(a + 1)`).

#align(center, canvas(length: 1cm, {
  import draw: *
  let scala = ("char, short", "int", "long", "float", "double", "long double")
  for (k, t) in scala.enumerate() {
    content((k * 2.5, 0), box(width: 1.85cm, inset: 4pt, stroke: 0.6pt, radius: 2pt, fill: rgb("#eef4ff"), align(center, text(8pt, raw(t)))))
    if k < scala.len() - 1 { line((k * 2.5 + 1.0, 0), (k * 2.5 + 1.5, 0), mark: (end: "stealth"), stroke: 0.6pt) }
  }
}))

Nell'assegnamento invece *vince il tipo della variabile a sinistra*: se è più corto del valore, si può perdere informazione. Per scegliere noi il tipo c'è la *conversione esplicita*, con l'operatore di *casting*: `(tipo) espressione`. Con `int a = 5;`:

#align(center, table(columns: 3, align: (left, center, left),
  [Assegnamento], [`b` vale], [Perché],
  [`float b = a;`], [`5.000000`], [l'intero viene promosso a `float`],
  [`float b = a / 2;`], [`2.000000`], [due interi: divisione *intera*, e solo dopo la conversione],
  [`float b = a / 2.0;`], [`2.500000`], [`2.0` è reale: `a` viene convertito, divisione tra reali],
  [`float b = (float) a / 2;`], [`2.500000`], [il casting cambia il tipo di `a` *prima* della divisione],
  [`float b = (float) (a / 2);`], [`2.000000`], [qui il casting si applica al *risultato*: la divisione è già stata fatta fra interi],
))

Lo stesso casting serve nei due versi. Per avere il quoziente reale di due interi si converte un operando; per usare `%`, che vuole interi, su un valore letto come `float` lo si converte in `int`:

#grid(columns: (1.15fr, 1fr), gutter: 1em,
```c
int a, b;
scanf("%d %d", &a, &b);        // 7 2
printf("%d\n", a / b);           // 3
printf("%.2f\n", (float) a / b); // 3.50
```,
```c
float valore;
scanf("%f", &valore);   // 7.0
int n = (int) valore;
if (n % 2 == 0) puts("Pari");
else puts("Dispari");
```)

La seconda: in C *non c'è un tipo booleano di base*. *0 è falso, qualsiasi valore diverso da 0 è vero*, e un confronto o un operatore logico restituisce un `int`: *0 se falso, 1 se vero*. Le condizioni di `if` e dei cicli sono quindi numeri: `while (1)` è un ciclo infinito, `if (n)` vuol dire `if (n != 0)`.

#grid(columns: (auto, 1fr), gutter: 2em, align: horizon,
passi(("a = 7", "2 < a < 5"), ("prima 2 < a", "1 < 5"), ("risultato", "1  (vero!)")),
[*Trappola*: `2 < a < 5` *non* controlla che `a` stia fra 2 e 5. È `(2 < a) < 5`, e `2 < a` vale 0 o 1, sempre minore di 5. Si scrive `2 < a && a < 5`. Con `-Wall` gcc avvisa: `comparisons like 'X<=Y<=Z' do not have their mathematical meaning`.])

L'ultima riguarda lo `switch`: l'espressione deve essere *intera* (niente stringhe, a differenza di JS), e le etichette dei `case` costanti e diverse fra loro. Come in JavaScript, *senza `break` si prosegue nei `case` successivi*: con `c = 2`

#block(inset: (left: 1em), text(9pt, {
  set par(leading: 0.8em)
  text(fill: gray)[`case 1: puts("uno");`] + linebreak()
  [`case 2: puts("due");` #text(fill: blu)[← entra qui; niente `break`: prosegue ↓]] + linebreak()
  [`case 3: puts("tre"); break;` #text(fill: red)[→ esce]] + linebreak()
  text(fill: gray)[`default: puts("altro");`]
}))

stampa `due` e `tre`. Con `-Wextra` gcc avvisa: `this statement may fall through`.

#esercizio[sequenza terminata da 0][Leggere una sequenza di interi che termina con 0 (lo 0 non fa parte della sequenza). Stampare quanti numeri sono stati inseriti, quanti sono positivi, quanti negativi e la somma dei positivi.]

#esercizio[indovina il numero][Fissare nel programma un intero, per esempio 37. Chiedere ripetutamente un tentativo all'utente e stampare se è troppo grande, troppo piccolo o corretto; terminare quando il numero è indovinato.]

== Array e tipi custom

Un *array* è una collezione di valori *tutti dello stesso tipo*. Per definirlo bisogna conoscerne la *dimensione*; alla dichiarazione viene riservato uno spazio *contiguo* in memoria, di solito sullo stack. Si accede a un elemento con l'operatore `[]`: `a[i]`, con `i` che parte da 0.

#grid(columns: (1fr, auto), gutter: 1.5em, align: horizon,
```c
int interi[8];

#define N 100
double reali[N];   // dimensione con una macro
```,
canvas(length: 1cm, {
  import draw: *
  for k in range(8) {
    rect((k * 0.8, 0), (k * 0.8 + 0.8, 0.6), stroke: 0.5pt, fill: rgb("#eef4ff"))
    content((k * 0.8 + 0.4, -0.25), text(6.5pt, fill: gray, raw("[" + str(k) + "]")))
  }
  line((0, 0.75), (0, 0.9), (6.4, 0.9), (6.4, 0.75), stroke: 0.6pt + blu)
  content((3.2, 1.2), text(8pt, fill: blu)[`int interi[8]`: 8 interi uno dopo l'altro])
}))

Un array si scorre con un `for` sull'indice. Per esempio il *prodotto scalare* di due vettori, cioè la somma dei prodotti degli elementi con lo stesso indice:

#grid(columns: (1fr, 1fr), gutter: 1em, align: horizon,
```c
#define N 10
int a[N], b[N], prodotto = 0, i;

for (i = 0; i < N; i++)
    scanf("%d", &a[i]);     // leggo a
for (i = 0; i < N; i++)
    scanf("%d", &b[i]);     // leggo b
for (i = 0; i < N; i++)
    prodotto += a[i] * b[i];
```,
[`&a[i]` è l'indirizzo della cella `i`: `scanf` scrive lì.

`prodotto` alla fine vale \ `a[0]*b[0] + … + a[N-1]*b[N-1]`: \ l'ultimo indice è `N-1`, non `N`.])

#esercizio[invertire un array][Invertire un array `A` di 10 interi *senza array d'appoggio*: scambiare la prima cella con l'ultima, la seconda con la penultima, e così via. Poi stampare ogni elemento dell'array modificato.]

Un array può avere più dimensioni. `int a[3][3];` riserva 9 interi contigui, e si usa per rappresentare una *matrice*. In memoria non c'è una griglia: gli array a più dimensioni sono salvati *per righe*, una riga dopo l'altra.

#block(breakable: false, grid(columns: (1fr, auto), gutter: 1.5em, align: horizon,
[
```c
int a[3][2] = {{1,2},{3,4},{5,6}};

printf("%p\n", a);
printf("%p, %p, %p\n", a[0], a[1], a[2]);
```
```sh
0x7ffd2ba5ac10
0x7ffd2ba5ac10, 0x7ffd2ba5ac18, 0x7ffd2ba5ac20
```
],
canvas(length: 1cm, {
  import draw: *
  let colori = (rgb("#eef4ff"), rgb("#fff3c4"), rgb("#dff2e3"))
  for r in range(3) { for c in range(2) {
    let v = r * 2 + c + 1
    rect((c * 0.7, -r * 0.6), (c * 0.7 + 0.7, -r * 0.6 + 0.6), stroke: 0.5pt, fill: colori.at(r))
    content((c * 0.7 + 0.35, -r * 0.6 + 0.3), raw(str(v)))
    let x = 2.4 + (v - 1) * 0.7
    rect((x, -0.6), (x + 0.7, 0), stroke: 0.5pt, fill: colori.at(r))
    content((x + 0.35, -0.3), raw(str(v)))
  } }
  content((0.7, 0.9), text(7.5pt)[la matrice])
  content((4.5, 0.9), text(7.5pt)[in memoria])
  for (r, nome) in ("a = a[0]", "a[1]", "a[2]").enumerate() {
    let x = 2.4 + r * 1.4
    line((x, -1.0), (x, -0.65), mark: (end: "stealth"), stroke: 0.5pt)
    content((x + 0.1, -1.2), anchor: "west", text(7pt, raw(nome)))
    content((x + 0.1, -1.5), anchor: "west", text(6.5pt, fill: gray, raw("…" + ("c10", "c18", "c20").at(r))))
  }
})))

`a`, `a[0]`, `a[1]` e `a[2]` sono gli *indirizzi delle righe*: `a` coincide con `a[0]`, e ogni riga inizia 8 byte dopo la precedente, cioè 2 `int` da 4 byte. Per questo la *seconda dimensione* è importante: per trovare `a[i][j]` bisogna saltare `i` righe intere, e serve sapere quanto è lunga una riga. Le dimensioni possono essere anche più di due: `int a[3][4][2];`.

Una matrice si scorre con due `for` annidati, uno sulle righe e uno sulle colonne. Il prodotto scalare di prima, fra due matrici 10×10:

```c
int a[N][N], b[N][N], prodotto = 0, i, j;
// ... lettura: scanf("%d", &a[i][j]) dentro gli stessi due for
for (i = 0; i < N; i++)
    for (j = 0; j < N; j++)
        prodotto += a[i][j] * b[i][j];
```

Gli array tengono valori dello stesso tipo. Per mettere insieme valori di *tipo diverso* c'è la `struct`. La parola chiave `struct` *definisce un nuovo tipo, non dichiara una variabile*: la variabile si dichiara dopo. I pezzi si chiamano *membri* e si leggono con `variabile.membro`.

#block(breakable: false, grid(columns: (1fr, 1fr), gutter: 1em, align: horizon,
```c
#define LEN 20

struct Studente {     // il nuovo tipo
    char nome[LEN];
    int eta;
};

int main(void) {
    struct Studente s = {"Antonio", 15};

    printf("Nome: %s, Età: %d\n",
           s.nome, s.eta);
    printf("Dimensione: %zu\n",
           sizeof(s));
    return 0;
}
```,
[
```sh
$ ./main
Nome: Antonio, Età: 15
Dimensione: 24
```
#align(center, canvas(length: 1cm, {
  import draw: *
  rect((0, 0), (5, 0.6), stroke: 0.5pt, fill: rgb("#eef4ff")); content((2.5, 0.3), text(8pt)[`nome`: 20 byte])
  rect((5, 0), (6, 0.6), stroke: 0.5pt, fill: rgb("#fff3c4")); content((5.5, 0.3), text(8pt)[`eta`])
  content((5.5, -0.25), text(7pt, fill: gray)[4 byte])
  line((0, 0.75), (0, 0.9), (6, 0.9), (6, 0.75), stroke: 0.6pt + blu)
  content((3, 1.15), text(8pt, fill: blu)[`s`: 24 byte contigui])
}))
L'ordine dei membri nella definizione è l'ordine in memoria, e lo spazio di una variabile è contiguo. I valori fra graffe vanno *nello stesso ordine dei membri*.
]))

#nota[#set par(justify: false)
Con l'ordine sbagliato, `{15, "Antonio"}`, il programma stampa `Nome: T, Età: 0`. Il compilatore avvisa: `incompatible pointer to integer conversion` (con un gcc recente è un errore, e l'eseguibile non viene creato).]

#nota[Il compilatore può inserire *padding* fra i campi, cioè byte vuoti, per rispettare vincoli di allineamento: `sizeof` di una `struct` può essere più della somma dei membri.]

Il secondo tipo custom è l'`enum`, un tipo *enumerativo*: un elenco di nomi, ognuno dei quali è una *costante intera*. Serve a rendere il codice più leggibile, per esempio nei `case` di uno `switch`. Di default i valori partono da 0 e crescono di 1; si possono cambiare, e da lì in poi si continua a contare.

#let valori-enum(voci) = {
  let (v, out) = (-1, ())
  for (nome, fisso) in voci { v = if fisso == none { v + 1 } else { fisso }; out.push((nome, v)) }
  out
}
#let tabella-enum(voci) = table(columns: voci.len(), align: center, inset: 4pt,
  ..valori-enum(voci).map(((n, _)) => text(8pt, raw(n))), ..valori-enum(voci).map(((_, v)) => raw(str(v))))
#let giorni = ("lunedi", "martedi", "mercoledi", "giovedi", "venerdi", "sabato", "domenica")

```c
enum giorni {lunedi, martedi, mercoledi, giovedi, venerdi, sabato, domenica};
```
#align(center, tabella-enum(giorni.map(g => (g, none))))
```c
enum giorni {lunedi = 1, martedi, mercoledi, giovedi = 7, venerdi, sabato, domenica};
```
#align(center, tabella-enum(giorni.map(g => (g, (lunedi: 1, giovedi: 7).at(g, default: none)))))

Infine `typedef` *dà un nuovo nome a un tipo esistente*: utile per nomi di tipo lunghi, o per averne uno più facile da ricordare. Senza `typedef` le parole `struct` ed `enum` vanno ripetute ogni volta che si dichiara una variabile.

#grid(columns: (1fr, 1fr), gutter: 1em,
```c
struct Studente { ... };
enum giorni { ... };

struct Studente s;   // senza typedef
enum giorni giorno;
```,
```c
typedef struct { ... } Studente;
typedef enum { ... } Giorni;

Studente s;          // con typedef
Giorni giorno;
```)

L'esempio che li usa tutti: l'anagrafe di `N` dipendenti. Di ognuno si leggono codice, età, stipendio e ruolo (0 dirigente, 1 quadro, 2 operaio, 3 impiegato); poi si stampano codice, età e ruolo di chi guadagna *meno dello stipendio medio*. I dipendenti stanno in un *array di struct*, il ruolo è un `enum`.

#block(breakable: false, grid(columns: (1fr, 1.25fr), gutter: 1em,
```c
#define N 10

typedef enum {
    dirigente,
    quadro,
    operaio,
    impiegato
} ruolo_t;

typedef struct {
    int id;
    int eta;
    float salario;
    ruolo_t ruolo;
} dipendente_t;
```,
```c
dipendente_t dipendenti[N];
int i, ruolo_dip;
float media = 0;

for (i = 0; i < N; i++) {
    scanf("%d", &dipendenti[i].id);
    scanf("%d", &dipendenti[i].eta);
    scanf("%f", &dipendenti[i].salario);
    scanf("%d", &ruolo_dip);
    dipendenti[i].ruolo = ruolo_dip;
    media += dipendenti[i].salario;
}
media /= N;
```))

`dipendenti[i].salario` si legge da sinistra: la cella `i` dell'array, e di quella il membro `salario`. La stampa usa uno `switch` sul ruolo, perché l'`enum` è un intero e `printf` stamperebbe solo il numero:

#block(breakable: false)[
```c
for (i = 0; i < N; i++)
    if (dipendenti[i].salario < media) {
        printf("%d %d ", dipendenti[i].id, dipendenti[i].eta);
        switch (dipendenti[i].ruolo) {
            case dirigente: printf("dirigente\n"); break;
            case quadro:    printf("quadro\n");    break;
            case operaio:   printf("operaio\n");   break;
            default:        printf("impiegato\n");
        }
    }
```
```sh
3 22 operaio
4 32 impiegato
```
]

== Funzioni e programmi su più file <funzioni>

Le funzioni si usano come in JavaScript, con due differenze: *tipo di ritorno e tipi dei parametri vanno scritti*, e non si possono definire funzioni dentro altre funzioni. La prima eseguita è sempre `main`.

#grid(columns: (1fr, 1fr), gutter: 1em, align: horizon,
```c
int max(int a, int b) {
    if (a > b) return a;
    return b;
}
void saluta(void) {   // niente valore
    puts("ciao");
}
```,
[
- i parametri attuali vengono convertiti al tipo dei formali (casting implicito), così come il valore di `return` al tipo di ritorno;
- se una funzione non `void` arriva in fondo *senza `return`*, chi usa il risultato legge un valore a caso.
])

#definizione[passaggio per valore][In C i parametri sono passati *per valore*: la funzione riceve una *copia*. Cambiare il parametro cambia la copia, non la variabile del chiamante. Vale anche per le `struct`, che in JavaScript invece sarebbero oggetti condivisi.]

#grid(columns: (1fr, auto), gutter: 1.5em, align: horizon,
```c
void azzera(int x) {
    x = 0;              // cambia la copia
}

int main(void) {
    int n = 5;
    azzera(n);
    printf("%d\n", n);  // 5
}
```,
canvas(length: 1cm, {
  import draw: *
  content((0, 1.2), text(8pt, fill: blu)[`main`])
  rect((-0.6, 0), (0.6, 0.7), fill: rgb("#eef4ff")); content((0, 0.35), [`5`]); content((0, -0.3), text(8pt)[`n`])
  content((3, 1.2), text(8pt, fill: verde)[`azzera`])
  rect((2.4, 0), (3.6, 0.7), fill: rgb("#dff2e3")); content((3, 0.35), [`0`]); content((3, -0.3), text(8pt)[`x`])
  line((0.7, 0.35), (2.3, 0.35), mark: (end: "stealth"), stroke: 0.6pt)
  content((1.5, 0.65), text(7pt)[copia])
  content((1.5, -0.9), text(7.5pt, fill: gray)[`x = 0` cambia solo la copia])
}))

Per cambiare davvero una variabile del chiamante servono i puntatori (@puntatori).

Il compilatore legge il file dall'alto in basso, e quando incontra una chiamata deve già sapere com'è fatta la funzione. Se la definizione sta più in basso, o in un altro file, si mette prima un *prototipo* (o *dichiarazione*): tipo di ritorno, nome e tipi dei parametri, senza corpo.

#grid(columns: (1fr, 1fr), gutter: 1em,
```c
int max(int, int);     // prototipo

int main(void) {
    printf("%d\n", max(3, 8));
}

int max(int a, int b) { // definizione
    if (a > b) return a;
    return b;
}
```,
table(columns: 2,
  [Manca], [Errore di chi],
  [la *dichiarazione*], [del *compilatore*: \ `implicit declaration of function 'max'`],
  [la *definizione*], [del *linker*: \ `undefined reference to 'max'`],
))

Questa differenza è la chiave dei programmi su *più file*. Per modularità e riuso il programma si divide in più file `.c`, che si compilano *separatamente* (ognuno diventa un `.o`) e poi il linker unisce. Le dichiarazioni di funzioni e costanti si raccolgono in un *file header* `.h`, incluso da chi le usa; le definizioni restano nei `.c`. `#include "max.h"`, con le virgolette, cerca il file nella directory corrente; con `< >` lo cerca fra le librerie di sistema.

#align(center, canvas(length: 1cm, {
  import draw: *
  let scatola(pos, t, c) = content(pos, box(inset: 5pt, stroke: 0.7pt, radius: 2pt, fill: c, text(8pt, t)))
  scatola((0, 1.2), [`max.h` \ `int max(int, int);`], rgb("#fff3c4"))
  scatola((-2.6, 0), [`main.c` \ `#include "max.h"`], rgb("#eef4ff"))
  scatola((2.6, 0), [`max.c` \ definizione di `max`], rgb("#eef4ff"))
  line((-1.3, 1.1), (-2.2, 0.45), mark: (end: "stealth"), stroke: 0.6pt)
  content((-2.3, 0.95), text(7pt, fill: gray)[incluso])
  scatola((-2.6, -1.4), [`main.o`], rgb("#dce8fb"))
  scatola((2.6, -1.4), [`max.o`], rgb("#dce8fb"))
  line((-2.6, -0.4), (-2.6, -1.1), mark: (end: "stealth")); content((-1.9, -0.75), text(7pt)[`gcc -c`])
  line((2.6, -0.4), (2.6, -1.1), mark: (end: "stealth")); content((3.3, -0.75), text(7pt)[`gcc -c`])
  scatola((0, -2.6), [eseguibile `main`], rgb("#dff2e3"))
  line((-2.0, -1.6), (-0.8, -2.4), mark: (end: "stealth")); line((2.0, -1.6), (0.8, -2.4), mark: (end: "stealth"))
  content((0, -1.8), text(7pt, fill: blu)[linker])
}))

```sh
$ gcc -Wall main.c max.c -o main    # compila i due file e li collega
```

Con le funzioni e i file cambia anche la vita delle variabili. Ogni variabile ha una *classe di memorizzazione*, che decide *dove* sta e *chi* la vede (lo scope visto in @compilazione e nella sezione sui programmi C):

#table(columns: (auto, auto, 1fr, 1fr),
  [Variabile], [Dove sta], [Chi la vede], [Quanto vive],
  [*locale* (classe `auto`, implicita)], [stack], [il suo blocco, fino alla `}`], [allocata all'ingresso del blocco, tolta all'uscita],
  [*globale* (`extern` implicito)], [dati statici], [il suo file; gli altri file se la dichiarano `extern`], [tutto il programma],
  [*globale `static`*], [dati statici], [*solo* il suo file], [tutto il programma],
  [*locale `static`*], [dati statici], [il suo blocco], [tutto il programma: *mantiene il valore fra una chiamata e l'altra*],
)

Le funzioni sono sempre globali: non si può definire una funzione dentro un'altra. `static` ha quindi due usi diversi: su una globale *impedisce l'uso da altri file*; su una locale la rende *persistente*.

L'esempio del prof li mostra tutti. `max.c` conta quante volte vince il primo numero (`countA`) e quante il secondo (`countB`); `main.c` legge coppie fino a due numeri uguali e alla fine vuole stampare `countA`:

#grid(columns: (1fr, 1fr), gutter: 1em,
```c
// max.c
int countA = 0;
int countB = 0;

int max(int a, int b) {
    if (a > b) {
        countA++;
        return a;
    }
    countB++;
    return b;
}
```,
```c
// main.c
#include <stdio.h>
#include "max.h"

extern int countA;

int main(void) {
    int a = 0, b = 0;
    do {
        int a = 0;
        scanf("%d %d", &a, &b);
        printf("Max(%d,%d)=%d\n",
               a, b, max(a, b));
    } while (a != b);
    printf("a>b %d volte\n", countA);
}
```)

#table(columns: (auto, 1fr),
  [Versione], [Cosa succede],
  [senza `extern int countA;`], [errore del *compilatore*: `'countA' undeclared`. `main.c` non sa che `countA` esiste],
  [con `extern int countA;`], [compila: `extern` dice "esiste, ma è definita in un altro file"],
  [con `extern`, ma in `max.c` \ `static int countA = 0;`], [errore del *linker*: `undefined reference to 'countA'`. La `static` non si vede fuori da `max.c`],
)

#nota[*Quando ci fermiamo?* Dentro il `do` c'è un'altra `int a = 0`, che *copre* la `a` esterna. `scanf` scrive nella `a` interna, ma la condizione `a != b` sta fuori dal blocco e usa la `a` *esterna*, che resta 0. Quindi `3 3` *non* ferma il ciclo: si esce solo con `b = 0`.
```sh
3 3
Max(3,3)=3          # continua!
0 0
Max(0,0)=0
a>b 2 volte
```]

Ultima versione: i contatori diventano locali `static` dentro `max`, che li stampa a ogni chiamata. L'inizializzazione `= 0` avviene una volta sola, e le variabili non spariscono a fine chiamata: contano su tutte le chiamate.

#grid(columns: (2fr, 1fr), gutter: 1em, align: horizon,
```c
int max(int a, int b) {
    static int countA = 0;
    static int countB = 0;
    if (a > b) {
        countA++;
        printf("countA=%d, countB=%d\n",
               countA, countB);
        return a;
    }
    countB++;
    printf("countA=%d, countB=%d\n",
           countA, countB);
    return b;
}
```,
```sh
3 5
countA=0, countB=1
Max(3,5)=5
6 2
countA=1, countB=1
Max(6,2)=6
3 8
countA=1, countB=2
Max(3,8)=8
```)

Nota l'ordine delle righe: `countA=…` esce *prima* di `Max(…)`, perché i parametri di `printf` (fra cui `max(a, b)`) vengono calcolati prima che `printf` stampi.

= Puntatori e memoria

#obiettivi(
  [leggere e scrivere `&x`, `*p`, `p + i`, `a[i]`, e prevedere quando il compilatore dà errore (puntatore ↔ intero, tipi diversi, `void*`);],
  [scrivere una funzione che modifica le variabili del chiamante (passaggio per indirizzo);],
  [allocare con `malloc` e `calloc`, controllare `NULL`, liberare con `free`, e riconoscere memory leak e uso dopo `free`;],
  [costruire una matrice dinamica per righe e liberarla;],
  [lavorare con le stringhe: terminatore, `char s[]` contro `char *s`, `string.h`, `strtok`, `ctype.h`, lettura e conversione;],
  [usare un puntatore a funzione e `qsort`;],
  [cercare un errore con `stderr`, `assert`, `gdb` e `valgrind`.],
)

// riga di celle di memoria: ogni cella è (etichetta sotto, contenuto, colore)
#let celle(x0, y0, voci, w: 1.1) = {
  import draw: *
  for (k, (et, val, col)) in voci.enumerate() {
    let x = x0 + k * w
    rect((x, y0), (x + w, y0 + 0.6), stroke: 0.5pt, fill: col)
    content((x + w / 2, y0 + 0.3), text(8pt, val))
    content((x + w / 2, y0 - 0.25), text(6.5pt, fill: gray, et))
  }
}

== Puntatori <puntatori>

Tutto quello che sta in memoria, dati e istruzioni, ha un *valore* e un *indirizzo*: lo abbiamo già usato con `&a` in `scanf` e con `%p` in `printf`. Un indirizzo è un numero intero che dipende dalla macchina.

#definizione[puntatore][Un *puntatore* è una variabile che contiene un indirizzo di memoria. `int *p;` dichiara un puntatore a `int`: il *tipo* dice che cosa ci si aspetta di trovare a quell'indirizzo. Si inizializza con l'indirizzo di un'altra variabile, oppure con `NULL`, che vuol dire "nessun indirizzo".]

Il puntatore è a sua volta una variabile, quindi ha anche lui un indirizzo. Due operatori lo collegano alla variabile puntata:

#grid(columns: (1fr, auto), gutter: 1.5em, align: horizon,
table(columns: 2,
  [Operatore], [Cosa fa],
  [`&x`], [*indirizzo* di `x`],
  [`*p`], [*dereferenziazione*: il valore che sta all'indirizzo contenuto in `p`. Si può leggere e scrivere],
),
canvas(length: 1cm, {
  import draw: *
  circle((0, 0), radius: 0.4); content((0, 0), text(8pt)[`&i`]); content((0, 0.65), text(8pt)[`p`])
  rect((2.4, -0.35), (3.1, 0.35)); content((2.75, 0), [3]); content((2.75, 0.6), text(8pt)[`i`])
  line((0.4, 0), (2.4, 0), mark: (end: "stealth")); content((1.4, 0.3), text(8pt, fill: blu)[`p = &i`])
  rect((2.4, -1.65), (3.1, -0.95)); content((2.75, -1.3), [3]); content((2.75, -1.95), text(8pt)[`j`])
  content((0.6, -1.3), text(8pt, fill: blu)[`j = *p;`])
  content((1.4, -2.4), text(7.5pt, fill: gray)[equivale a `j = i`])
}))

Il cerchio è il puntatore `p`, che contiene l'indirizzo di `i` (la freccia); `j = *p` va a leggere *ciò che sta in quell'indirizzo*, cioè il 3 di `i`. Lo stesso vale in scrittura, e più puntatori possono puntare alla stessa variabile:

#grid(columns: (1.3fr, 1fr), gutter: 1em, align: horizon,
```c
double a = 0;
double *aPtr = &a, *aPtr1 = &a;

*aPtr = 10;
printf("%f\n", a);   // 10.000000
*aPtr1 = 20;
printf("%f\n", a);   // 20.000000
```,
[Nella dichiarazione l'asterisco va ripetuto per ogni puntatore: `double *aPtr, *aPtr1`. Nell'espressione `*aPtr = 10` invece l'asterisco è la dereferenziazione: scrive 10 *dentro `a`*.])

Un puntatore contiene un numero intero, ma *il C non lo tratta come un intero*: si usa nelle espressioni fra puntatori, non mescolato con altri tipi interi.

```c
int b = 1;
int c = 22;
int *a = &c;
*a = b + *a;    // ok: cambia c, che diventa 23
a = b + *a;     // NO: a è un puntatore, non un intero
*a = b + a;     // NO: b + a è un puntatore, e *a è un int
int *a = c;     // NO: a un puntatore non si assegna un intero
```

Le tre righe sbagliate danno errore: `makes pointer from integer without a cast` o `makes integer from pointer without a cast`.

#nota[*Il tipo del puntatore conta*: dice quanti byte leggere e come interpretarli. Puntare un `double` con un `int *` (o il contrario) dà il warning `incompatible pointer types` (con un gcc recente è un errore), e il valore letto è senza senso:
#grid(columns: (1fr, 1fr), gutter: 1em,
```c
int a = 15;
double *aPtr = &a;
printf("%f\n", *aPtr);  // 0.000000
```,
```c
double a = 15.6;
int *aPtr = &a;
printf("%d\n", *aPtr);  // 858993459
```)]

#nota[Dereferenziare un puntatore che vale `NULL`, o che punta a memoria non allocata, dà un *errore a tempo di esecuzione*: compila, ma quando gira termina con `Segmentation fault`.]

Ecco a cosa servono. I parametri di una funzione vengono allocati sullo stack della funzione chiamata, e sono copie (@funzioni). Ma se le si passa l'*indirizzo* di una variabile, la funzione può modificare quella variabile, anche se sta nell'ambiente del chiamante. È il *passaggio per indirizzo*, ed è il motivo per cui `scanf` vuole `&a`.

#grid(columns: (1fr, auto), gutter: 1.5em, align: horizon,
```c
void swap(int *x, int *y) {
    int var = *x;
    *x = *y;
    *y = var;
}

int main(void) {
    int a = 5, b = 10;
    printf("a=%d,b=%d\n", a, b);  // a=5,b=10
    swap(&a, &b);
    printf("a=%d,b=%d\n", a, b);  // a=10,b=5
}
```,
canvas(length: 1cm, {
  import draw: *
  content((0.55, 1.1), text(8pt, fill: blu)[stack di `main`])
  celle(-0.55, 0, (([`a`], [5 → 10], rgb("#eef4ff")), ([`b`], [10 → 5], rgb("#eef4ff"))), w: 1.1)
  content((0.55, -1.0), text(8pt, fill: verde)[stack di `swap`])
  celle(-0.55, -2.1, (([`x`], [`&a`], rgb("#dff2e3")), ([`y`], [`&b`], rgb("#dff2e3"))), w: 1.1)
  line((0, -1.5), (0, -0.05), mark: (end: "stealth"), stroke: 0.6pt + red)
  line((1.1, -1.5), (1.1, -0.05), mark: (end: "stealth"), stroke: 0.6pt + red)
}))

`x` e `y` sono copie degli *indirizzi* (le frecce rosse), ma `*x` e `*y` sono proprio `a` e `b`. Con `void swap(int x, int y)` lo scambio avverrebbe sulle copie, e `a`, `b` resterebbero 5 e 10.

== Array e puntatori <array-puntatori>

Un array è un insieme *contiguo* di elementi dello stesso tipo. `int a[10];` fa tre cose: crea una variabile `a`, alloca sullo stack 10 interi contigui, e mette in `a` l'indirizzo dell'inizio di quella zona. Per questo il prof dice che `a` è "in realtà un puntatore": vale `a == &a[0]`.

Dato l'indirizzo del primo elemento, gli altri si trovano con l'*aritmetica dei puntatori*. Sommare `i` a un puntatore vuol dire *avanzare di `i` elementi*, non di `i` byte: il compilatore moltiplica da solo per la dimensione del tipo.

#align(center, canvas(length: 1cm, {
  import draw: *
  for k in range(5) {
    let x = k * 1.6
    rect((x, 0), (x + 1.6, 0.6), stroke: 0.5pt, fill: rgb("#eef4ff"))
    content((x + 0.8, 0.3), text(8pt, raw("a[" + str(k) + "]")))
    content((x + 0.8, -0.25), text(6.5pt, fill: gray, raw("…ec" + str(k * 4))))
    content((x + 0.8, 0.95), text(8pt, fill: blu, raw(if k == 0 { "a" } else { "a + " + str(k) })))
  }
  content((9, 0.3), anchor: "west", text(8pt)[`int`: 4 byte ciascuno])
}))

#table(columns: (auto, auto, 1fr),
  [In C si scrive], [È uguale a], [Indirizzo in byte],
  [`a + i`], [`&a[i]`], [indirizzo di `a` + `i · sizeof(int)`],
  [`*(a + i)`], [`a[i]`], [],
  [`&a[i][j]`, matrice con `n_col` colonne], [], [indirizzo di `a` + `(i · n_col + j) · sizeof(int)`],
)

#nota[Attenzione a non moltiplicare due volte. In C si scrive `a + i`, *non* `a + i * sizeof(int)`: quest'ultimo avanzerebbe di `4i` elementi. La moltiplicazione per `sizeof` serve solo a calcolare l'indirizzo in byte, come nell'ultima colonna. Lo conferma la stampa: `a` e `a + 1` distano 4 byte.]

Quando si passa un array a una funzione *viene passato il puntatore al primo elemento*, non una copia. Quindi:
- un parametro di tipo puntatore si usa come un array: `int *v` e `int v[]` come parametro sono la stessa cosa, e `v[i]` funziona;
- la funzione *può modificare* l'array del chiamante;
- la funzione non sa quanto è lungo: la dimensione va passata a parte.

Per un array a più dimensioni bisogna scrivere *tutte le dimensioni tranne la prima*, perché servono per saltare le righe (come visto per le matrici): `int f(int a[][5][3]) {...}`.

#nota[`a` *non* è però una variabile puntatore come le altre. `sizeof(a)` dà 40 (tutto l'array), mentre `sizeof` di un `int *` dà 8. E `a` non si può riassegnare: `a = b;` fra due array dà `assignment to expression with array type`.]

== Allocazione statica e dinamica <allocazione>

Finora la memoria la decideva il compilatore. Vediamo meglio le zone in cui è divisa (@compilazione):

#grid(columns: (auto, 1fr), gutter: 1.5em, align: horizon,
pila(larghezza: 3cm,
  ([*codice*], rgb("#e6dcf2")),
  ([*dati statici*], rgb("#fff3c4")),
  ([*heap*], rgb("#dce8fb")),
  ([*stack*], rgb("#dff2e3")),
),
[
  - *dati statici*: quello che si sa già a tempo di compilazione, cioè le variabili globali e le locali `static`;
  - *stack*: un *record di attivazione* per ogni blocco di codice, comprese le chiamate di funzione, con lo spazio per le variabili locali;
  - *heap*: dati *dinamici*, allocati a tempo di esecuzione e raggiungibili tramite puntatori. È *frammentato*: i pezzi non sono per forza vicini.
])

Partiamo da due dichiarazioni:

#grid(columns: (1fr, auto), gutter: 1.5em, align: horizon,
[
- `int a;` alloca `sizeof(int)` byte. Il valore è *non definito*.
- `int *aPtr;` alloca `sizeof(int*)` byte per il puntatore. Sono non definiti sia il suo valore (a cosa punta) sia `*aPtr`.

Con l'*allocazione statica* le si collega a mano: `a = 10; aPtr = &a;` e ora `*aPtr` vale 10.],
canvas(length: 1cm, {
  import draw: *
  celle(0, 1.2, (([`a`], [`???`], rgb("#dff2e3")), ([`aPtr`], [`???`], rgb("#dff2e3"))), w: 1.3)
  line((1.95, 1.85), (2.4, 2.4), mark: (end: "stealth"), stroke: (dash: "dashed")); content((2.6, 2.6), text(8pt)[`??`])
  content((1.3, 0.55), text(7.5pt, fill: gray)[dopo le dichiarazioni])
  celle(0, -0.8, (([`a`], [`10`], rgb("#dff2e3")), ([`aPtr`], [`&a`], rgb("#dff2e3"))), w: 1.3)
  bezier((1.95, -0.15), (0.65, -0.15), (1.3, 0.25), mark: (end: "stealth"), stroke: 0.6pt + red)
  content((1.3, -1.45), text(7.5pt, fill: gray)[allocazione statica])
}))

L'*allocazione dinamica* invece chiede memoria nuova sull'heap mentre il programma gira, con le funzioni della libreria `stdlib.h`:

#grid(columns: (1fr, 1fr), gutter: 1em,
[```c
int *aPtr;
aPtr = (int*) malloc(sizeof(int));
```
`aPtr` ora punta a un `int` sull'heap; `*aPtr` resta *non definito* finché non ci scrivi.],
[```c
int *aPtr;
aPtr = (int*) calloc(1, sizeof(int));
```
Come sopra, ma la memoria è *inizializzata a 0*: `*aPtr` vale 0.])

#table(columns: (auto, 1fr),
  [Funzione], [Cosa fa],
  [`void *malloc(size_t n);`], [alloca `n` *byte* e restituisce l'indirizzo dove sono],
  [`void *calloc(size_t n, size_t size);`], [alloca un array di `n` oggetti grandi `size`, mette *0* in ogni posizione e restituisce l'indirizzo del primo],
  [`void free(void *p);`], [libera la memoria allocata con `malloc` o `calloc`],
)

Entrambe restituiscono:
- un puntatore `void*`, che va convertito con un casting al tipo giusto (`(int*)`);
- `NULL` se non riescono ad allocare: *bisogna sempre controllare* che il risultato sia `!= NULL` prima di usarlo.

`size_t` è il tipo intero senza segno restituito da `sizeof`.

#definizione[`void*`][Un `void*` è un *puntatore generico*: un indirizzo senza un tipo. Si usa anche nei prototipi di funzioni che devono accettare puntatori di qualsiasi tipo. Siccome non dice cosa c'è all'indirizzo, *non si può dereferenziare*: prima si fa il casting a un tipo concreto.]

#grid(columns: (1fr, 1fr), gutter: 1em,
```c
int a = 10;
void *aP = &a;
printf("%d\n", *aP);         // errore
```,
```c
int a = 10;
void *aP = &a;
printf("%d\n", *(int*)aP);   // 10
```)

La memoria dinamica resta occupata finché non la si libera con `free(aPtr);`, da fare quando l'oggetto non serve più. Gli errori comuni:
- *memory leak*: non liberare la memoria e poi perdere il puntatore. Quella memoria non si può più né usare né liberare, e se succede in un ciclo il programma può esaurire la memoria;
- liberare memoria allocata in modo statico (`free(&a)`);
- usare un puntatore dopo averlo liberato.

#table(columns: (1fr, 1fr),
  [Vantaggi dell'allocazione dinamica], [Svantaggi],
  [più controllo sulla memoria usata, meno spreco, programmi più generici (la dimensione si decide mentre gira), più modularità e passaggio di parametri più facile], [la gestione della memoria è in più, a carico tuo; rischio di memory leak],
)

== Array di puntatori e matrici dinamiche <matrici>

Una matrice `int b[N][M]` ha due limiti: `N` e `M` si decidono quando si scrive il programma, e una funzione che la riceve deve conoscere `M` (`int b[][M]`, @array-puntatori). Se le dimensioni si leggono da input servono una matrice costruita sull'heap e, per farla, un *array di puntatori*.

I puntatori sono variabili, quindi se ne possono fare array:
- `int *ps[10];` alloca 10 puntatori *non inizializzati*: bisogna assegnare un valore a ognuno;
- `int **ps = (int**) malloc(n * sizeof(int*));` alloca sull'heap `n` puntatori a `int`, non inizializzati; con `calloc(n, sizeof(int*))` partono tutti a `NULL`.

Il tipo `int **` si legge "puntatore a puntatore a `int`". Viene dalla regola di sempre: `malloc` restituisce l'indirizzo del primo elemento, quindi per elementi `int` serve un `int *`, per elementi `int *` serve un `int **`.

Ora si fa puntare ogni `ps[i]` a un array di `int` allocato a parte: ogni array è una riga. È la *matrice dinamica allocata per righe*:

```c
int **a = (int**) malloc(3 * sizeof(int*));   // 3 puntatori, uno per riga
for (int i = 0; i < 3; i++)
    a[i] = (int*) malloc(3 * sizeof(int));    // la riga i: 3 int
```

Nel disegno, a sinistra questa matrice, a destra `int b[3][3]` per confronto. In giallo i puntatori, in blu e verde gli `int`; in rosso lo stesso elemento `[1][2]` nelle due matrici.

#align(center, canvas(length: 1cm, {
  import draw: *
  let giallo = rgb("#fff3c4")
  let rosso = rgb("#f7c6c6")
  // a, sullo stack
  rect((0, 0), (0.9, 0.6), fill: rgb("#dff2e3"), stroke: 0.5pt)
  content((0.45, -0.3), text(8pt)[`a`, sullo stack])
  // array dei puntatori e righe, sull'heap
  rect((1.5, -2.6), (6.6, 1.9), stroke: (paint: gray, dash: "dashed", thickness: 0.5pt))
  content((4.05, 2.15), text(7.5pt, fill: gray)[heap])
  line((0.9, 0.3), (1.8, 0.3), mark: (end: "stealth"), stroke: 0.6pt + red)
  let dx = (0.8, 0, 0.5)
  for i in range(3) {
    let y = 0.6 - (i + 1) * 0.6
    rect((1.8, y), (2.7, y + 0.6), fill: giallo, stroke: 0.5pt)
    content((2.25, y + 0.3), text(7pt, raw("a[" + str(i) + "]")))
    let x = 3.4 + dx.at(i)
    let yr = 1.1 - i * 1.3
    for k in range(3) {
      let c = if i == 1 and k == 2 { rosso } else { rgb("#dce8fb") }
      rect((x + k * 0.6, yr), (x + k * 0.6 + 0.6, yr + 0.5), fill: c, stroke: 0.5pt)
    }
    content((x + 0.9, yr - 0.22), text(6.5pt, fill: gray)[riga #i])
    line((2.7, y + 0.3), (x, yr + 0.25), mark: (end: "stealth"), stroke: 0.6pt + red)
  }
  // b[3][3]: un blocco unico
  let x0 = 7.6
  content((x0 + 2.7, 0.9), text(7.5pt)[`int b[3][3]`])
  for k in range(9) {
    let c = if k == 5 { rosso } else { rgb("#dff2e3") }
    rect((x0 + k * 0.6, 0), (x0 + k * 0.6 + 0.6, 0.5), fill: c, stroke: 0.5pt)
  }
  for r in range(3) {
    let x = x0 + r * 1.8
    line((x + 0.05, -0.15), (x + 1.75, -0.15), stroke: 0.5pt + gray)
    content((x + 0.9, -0.4), text(6.5pt, fill: gray)[riga #r])
  }
}))

`a[1][2]` si legge in due passi, come `(a[1])[2]`:
+ `a[1]` è il secondo puntatore giallo: l'indirizzo della riga 1;
+ `[2]` su quell'indirizzo dà il terzo `int` della riga.

Con `b[1][2]` invece c'è un blocco unico: si salta una riga intera da 3 `int`, poi altri 2 `int`. Per questo il compilatore deve conoscere la lunghezza della riga, mentre con `a` gli indirizzi delle righe sono scritti nei puntatori gialli. Le differenze:

#table(columns: (auto, 1fr, 1fr),
  [], [`int b[N][M]`], [`int **a` allocata per righe],
  [dimensioni], [fisse, scritte nel programma], [decise mentre il programma gira],
  [in memoria], [un blocco unico, righe una dopo l'altra], [righe sparse sull'heap],
  [righe], [tutte lunghe `M`], [ognuna può avere una lunghezza diversa, senza sprechi],
  [parametro], [`int b[][M]`: serve `M`], [`int **a`: `M` non serve],
  [liberare], [non serve], [`free` di ogni riga, poi di `a`],
)

L'ordine del `free` conta: prima le righe, poi l'array dei puntatori. Al contrario, dopo `free(a)` gli indirizzi delle righe non si possono più leggere, e le righe restano occupate per sempre (memory leak).

```c
for (int i = 0; i < 3; i++)
    free(a[i]);
free(a);
```

Un esempio del prof mette tutto insieme. Leggere `M`, `N` (con `M ≥ N ≥ 0`) e una matrice `M × M` allocata per righe; stampare la somma della sottomatrice `N × N` in alto a sinistra, con una funzione `int sum_submatrix(int **matrix, int n)`. Con `M = 4`, `N = 2` e righe `(1,2,3,4)`, `(5,6,7,8)`, `(9,10,11,12)`, `(13,14,15,16)` stampa `1 + 2 + 5 + 6 = 14`.

#[#show raw: set text(size: 0.9em)
#grid(columns: (1fr, 1.12fr), gutter: 0.8em,
```c
#include <stdio.h>
#include <stdlib.h>

int sum_submatrix(int **matrix, int n) {
    int i, j, sum = 0;
    for (i = 0; i < n; i++)
        for (j = 0; j < n; j++)
            sum += matrix[i][j];
    return sum;
}

int main(void) {
    int m, n, i, j;
    int **A;
    scanf("%d%d", &m, &n);
    if (m < 0 || n < 0 || n > m)
        return 1;
    if (m == 0) {
        printf("0\n");
        return 0;
    }
```,
```c
    A = malloc(m * sizeof(int *));
    if (A == NULL) return 1;
    for (i = 0; i < m; i++) {
        A[i] = malloc(m * sizeof(int));
        if (A[i] == NULL) {
            while (i > 0) free(A[--i]);
            free(A);
            return 1;
        }
    }
    for (i = 0; i < m; i++)
        for (j = 0; j < m; j++)
            if (scanf("%d", &A[i][j]) != 1) {
                for (i = 0; i < m; i++)
                    free(A[i]);
                free(A);
                return 1;
            }
    printf("%d\n", sum_submatrix(A, n));
    for (i = 0; i < m; i++) free(A[i]);
    free(A);
    return 0;
}
```)]

Le righe nuove:
- `malloc` è senza `(int**)`: in C un `void*` si converte da solo in qualunque puntatore, quindi il casting si può omettere;
- se fallisce la `malloc` della riga `i`, le righe da 0 a `i-1` sono già allocate e vanno liberate prima di uscire. `free(A[--i])` decrementa `i` *prima* di usarlo, quindi libera `A[i-1]`, …, `A[0]`; poi si libera `A`;
- `scanf` restituisce quanti valori ha letto: se non è 1 l'input è sbagliato, e prima di uscire si libera tutto.

#esercizio[diagonale][Leggere `M` e una matrice quadrata `M × M`, allocata dinamicamente per righe. Con una funzione, cambiare il segno degli elementi sulla diagonale principale e stampare la matrice, una riga per riga di output. `(1,2,3), (4,5,6), (7,8,9)` diventa `(-1,2,3), (4,-5,6), (7,8,-9)`.]

== Stringhe <stringhe>

In C non c'è un tipo stringa come in JavaScript: una *stringa è un array di `char` terminato da `'\0'`*, il carattere nullo (valore 0). Ogni funzione sulle stringhe va avanti finché non trova `'\0'`: è l'unico modo per sapere dove finiscono. Ci sono due modi di crearne una, e *non sono la stessa cosa*:

#grid(columns: (1fr, 1fr), gutter: 1em,
[```c
char s1[] = "ciao";
s1[2] = 'A';
printf("s1=%s\n", s1);   // s1=ciAo
```
Un *array* di 5 `char` sullo stack, inizializzato con una copia di `"ciao"`: si può modificare.],
[```c
char *s1 = "ciao";
s1[2] = 'A';             // crash
printf("s1=%s\n", s1);
```
Un *puntatore* a una stringa costante, che sta in una zona di sola lettura: scriverci fa terminare il programma.])

Attenzione a copiare: l'assegnamento fra puntatori copia *l'indirizzo*, non i caratteri, e da lì in poi i due nomi modificano lo stesso array. Per una copia vera si copiano i caratteri uno a uno, *terminatore compreso*:

#grid(columns: (1fr, 1fr), gutter: 1em,
[```c
char s1[] = "ciao";
char *s2 = s1;     // stesso array
s2[2] = 'A';
// s1=ciAo, s2=ciAo
```
#align(center, canvas(length: 1cm, {
  import draw: *
  celle(0, 0, ("ciao\\0".clusters().map(c => ([], raw(c), rgb("#eef4ff")))).slice(0, 4) + (([], raw("\\0"), rgb("#fde2e2")),), w: 0.5)
  content((-0.5, 1.0), text(8pt)[`s1`]); line((-0.3, 0.85), (0.1, 0.65), mark: (end: "stealth"), stroke: 0.5pt)
  content((0.9, 1.1), text(8pt)[`s2`]); line((0.8, 0.95), (0.3, 0.65), mark: (end: "stealth"), stroke: 0.5pt + red)
}))],
[```c
char s1[] = "ciao";
char s2[5];
int i = 0;
while (s1[i] != '\0') {
    s2[i] = s1[i];
    i++;
}
s2[i] = '\0';      // non dimenticarlo
s2[2] = 'A';       // s1=ciao, s2=ciAo
```])

Senza il `'\0'` finale, `printf("%s", s2)` continuerebbe a leggere la memoria dopo l'array. Le funzioni già pronte stanno in `string.h`:

#table(columns: (auto, 1fr),
  [Funzione], [Cosa fa],
  [`strlen(str)`], [lunghezza, *senza* il terminatore: `strlen("ciao")` = 4 (`sizeof` dell'array `"ciao"` = 5)],
  [`strcpy(dest, src)`], [copia `src` in `dest` e restituisce `dest`. `dest` deve essere abbastanza grande],
  [`strcmp(s1, s2)`], [confronto lessicografico: *negativo* se `s1` viene prima, *0* se uguali, *positivo* se dopo. Non si usa `==`, che confronterebbe gli indirizzi],
  [`strcat(dest, src)`], [aggiunge una copia di `src` in fondo a `dest`],
  [`strncpy`, `strncmp`, `strncat`], [come sopra, ma solo sui primi `n` caratteri],
  [`strtok(str, delim)`], [divide la stringa in *token* separati dai caratteri di `delim`],
)

`strtok` si usa in due tempi: la prima chiamata riceve la stringa, le successive `NULL` (vuol dire "continua da dove eri rimasto"). Restituisce un puntatore al token successivo, o `NULL` quando sono finiti. Per farlo *modifica la stringa originale*: sostituisce ogni separatore con `'\0'`, e `tok` punta dentro la stringa stessa.

#grid(columns: (1.2fr, 1fr), gutter: 1em, align: horizon,
```c
char s[100], *tok;
scanf("%[^\n]", s);         // 12,13,14,15
tok = strtok(s, ",");
printf("Token:%s\n", tok);
while ((tok = strtok(NULL, ",")) != NULL)
    printf("Token:%s\n", tok);
printf("Stringa:%s\n", s);
```,
```sh
Token:12
Token:13
Token:14
Token:15
Stringa:12
```)

#align(center, canvas(length: 1cm, {
  import draw: *
  let c = "12,13,14,15".clusters()
  celle(0, 0, c.enumerate().map(((k, x)) => if x == "," { ([], raw("\\0"), rgb("#fde2e2")) } else { ([#k], raw(x), rgb("#eef4ff")) }) + (([], raw("\\0"), rgb("#fde2e2")),), w: 0.6)
  for (k, n) in ((0, "1°"), (3, "2°"), (6, "3°"), (9, "4°")) {
    line((k * 0.6 + 0.3, 1.1), (k * 0.6 + 0.3, 0.65), mark: (end: "stealth"), stroke: 0.6pt + blu)
    content((k * 0.6 + 0.3, 1.3), text(7pt, fill: blu)[`tok` #n])
  }
  content((3.6, -0.75), text(7.5pt, fill: gray)[dopo `strtok`: le virgole sono diventate `'\0'`, quindi `s` ora è solo `"12"`])
}))

Per questo `Stringa:12` alla fine, e per questo `strtok` su `char *s = "12,13,14,15"` (sola lettura) dà `Segmentation fault`.

Per i singoli caratteri c'è `ctype.h`. Le funzioni di controllo restituiscono un valore *diverso da zero* se la condizione è vera:

#table(columns: (auto, 1fr),
  [Funzione], [Vero se `c` è…],
  [`isalpha(c)`, `isupper(c)`, `islower(c)`], [una lettera, maiuscola, minuscola],
  [`isdigit(c)`, `isalnum(c)`, `isspace(c)`], [una cifra, cifra o lettera, uno spazio bianco],
  [`toupper(c)`, `tolower(c)`], [convertono il carattere se possono, altrimenti lo restituiscono uguale: `toupper('7')` = `'7'`],
)

Per leggere caratteri e stringhe, e per convertire una stringa in numero:

#table(columns: (auto, 1fr),
  [Funzione], [Cosa fa],
  [`scanf("%c", &c)`], [un carattere],
  [`scanf("%s", s)`], [una parola: si ferma al primo spazio. Niente `&`: `s` è già un indirizzo],
  [`scanf("%[^\n]", s)`], [tutta la riga fino all'a capo, spazi compresi],
  [`getchar()`], [un carattere da stdin],
  [`fgets(str, num, stream)`], [al più `num-1` caratteri da `stream` (per la tastiera `stdin`), poi aggiunge `'\0'`],
  [`sscanf(s, format, ...)`], [come `scanf`, ma legge dalla stringa `s` invece che da stdin],
  [`atoi(str)`, `atol(str)`, `atof(str)`], [stringa → `int`, `long`, `double` (in `stdlib.h`)],
)

#nota[Con `scanf("%s", s)` nessuno controlla la lunghezza: se la parola è più lunga dell'array, si scrive oltre la fine. Nelle soluzioni del prof si limita con la larghezza: `scanf("%1000s", buffer)` con `char buffer[1001]` (uno in più per il `'\0'`).]

#esercizio[concatenazione][Leggere lunghezza e contenuto di due stringhe (al più 1000 caratteri), allocando per ciascuna esattamente lo spazio indicato più il terminatore. Scrivere `char* my_strcat1(char *s1, char *s2)`, che alloca una *nuova* stringa con la concatenazione, senza usare `strcat` o `strncat`, e stamparla. Lunghezze 10 e 3, stringhe `ciaoatutti` e `voi` → `ciaoatuttivoi`.]

#esercizio[anagrammi][Scrivere `int anagramma(char *s1, char *s2)`, che restituisce 1 se le due stringhe sono anagrammi e 0 altrimenti, e un programma che la usa. Suggerimento: contare in array di 256 elementi le occorrenze di ogni carattere (indice `(unsigned char) s[i]`). `pizza` e `pazzi` sono anagrammi.]

#esercizio[prefisso comune][`LCP(s1, s2)` è la lunghezza del più lungo prefisso comune a `s1` e `s2`. Leggere `n` e poi `n` stringhe di al più 500 caratteri; per ogni `0 < i < n` stampare `LCP(S[i-1], S[i])`. `LCP(AABB, AAZZ) = 2`, `LCP(mississippi, missi) = 5`, `LCP(laboratorio, laboratoriale) = 10`.]

== Puntatori a funzioni <puntatori-funzione>

In JavaScript una funzione è un valore e si passa come qualsiasi altro. In C le funzioni *non sono variabili*, ma se ne può prendere un *puntatore*, da passare come parametro o da usare per chiamare la funzione:

#grid(columns: (1.2fr, 1fr), gutter: 1em, align: horizon,
```c
int sum(int x, int y) { return x + y; }
int mul(int x, int y) { return x * y; }

int main(void) {
    int (*f)(int, int);
    f = sum;
    printf("%d\n", (*f)(3, 6));     // 9
    f = mul;
    printf("%d\n", (*f)(3, 6));     // 18

    int (*g[2])(int, int) = {sum, mul};
    printf("%d\n", (*g[1])(3, 6));  // 18
}
```,
[
`int (*f)(int, int)` si legge: `f` è un puntatore a una funzione che prende due `int` e restituisce un `int`. Le parentesi attorno a `*f` servono: `int *f(int, int)` sarebbe invece il prototipo di una funzione che restituisce un `int *`.

Il nome di una funzione, da solo, è il suo indirizzo: `f = sum`. `g` è un *array di puntatori a funzioni*.
])

L'uso tipico è `qsort` di `stdlib.h`, che ordina un array di *qualsiasi tipo*. Per essere generica usa `void*` e si fa passare la funzione di confronto:

```c
void qsort(void *base, size_t num, size_t size,
           int (*compar)(const void *, const void *));
```

- `base` è l'array, `num` il numero di elementi, `size` la dimensione di un elemento: `qsort` non conosce il tipo, quindi sposta blocchi di `size` byte;
- `compar` riceve gli *indirizzi* di due elementi e restituisce, come `strcmp`, un numero negativo, zero o positivo.

#grid(columns: (1.2fr, 1fr), gutter: 1em, align: horizon,
```c
int compInt(const void *a, const void *b) {
    int *ac = (int *) a;
    int *bc = (int *) b;
    return *ac - *bc;
}

int a[5] = {17, 9, 2, 43, 0};
qsort(a, 5, sizeof(int), compInt);
// 0 2 9 17 43
```,
[È lo stesso schema di `array.sort((a, b) => a - b)` in JavaScript. La differenza è che `compInt` riceve dei `void*`, e deve prima convertirli al tipo vero per poterli dereferenziare. `const` dice che la funzione non modificherà gli elementi.])

#esercizio[suffissi ordinati][Leggere una stringa di al più 1000 caratteri e stampare tutti i suoi suffissi, uno per riga, in ordine lessicografico. Si può usare `qsort`. Da `ciao`: `ao`, `ciao`, `iao`, `o`.]

== Trovare gli errori <debugging>

Il primo modo di cercare un errore è stampare i valori delle variabili. Ma `printf` scrive su `stdout`, che è *bufferizzato*: il testo può restare in un buffer invece di comparire subito, e se il programma termina per un errore quella stampa va persa. `stderr` invece non aspetta, e `fprintf` permette di scegliere il flusso:

```c
fprintf(stderr, "Messaggio\n");
```

Durante lo sviluppo si può controllare che lo stato sia quello atteso con la macro `assert` di `assert.h`. Riceve un'espressione intera: se è vera l'esecuzione continua, se è falsa stampa un errore su `stderr` e *termina subito*.

#grid(columns: (1fr, 1.2fr), gutter: 1em, align: horizon,
```c
#include <stdio.h>
#include <assert.h>

int main(void) {
    int x;
    scanf("%d", &x);
    assert(x > 0);
    printf("Hai inserito %d\n", x);
}
```,
[
```sh
$ ./main
-3
main: main.c:7: main: Assertion `x > 0' failed.
```
Per disattivare tutti gli `assert` si definisce la macro `NDEBUG` *prima* dell'`include`: `#define NDEBUG`. Allora con `-3` il programma stampa `Hai inserito -3`.
])

Stampe e `assert` non bastano sui programmi grandi. Ci sono due strumenti, e per entrambi si compila con `-g`:

```sh
$ gcc -g -Wall -pedantic main.c -o main
$ gdb main                              # gdb [opzioni] eseguibile
$ valgrind --leak-check=full ./main     # valgrind ./eseguibile [argomenti]
```

*gdb* esegue il programma in modo controllato: lo si ferma in certi punti per guardare le variabili.
- un *breakpoint* è un punto del codice dove fermarsi;
- un *watchpoint* è una variabile da sorvegliare: il programma si ferma quando cambia. Funziona solo dentro lo scope della variabile.

#table(columns: (auto, 1fr),
  [Comando gdb], [Cosa fa],
  [`run` / `quit`], [avvia il programma / chiude gdb],
  [`b 6`, `b main.c:6`, `b push`], [breakpoint alla riga 6, alla riga 6 di `main.c`, alla prima istruzione della funzione `push`],
  [`watch a`], [watchpoint sulla variabile `a`],
  [`delete n`, `enable n`, `disable n`], [toglie, attiva, disattiva il breakpoint o watchpoint numero `n`],
  [`p x`, `p &x`], [stampa il valore di `x`, il suo indirizzo],
  [`p a[3]@5`], [stampa 5 valori dell'array `a` a partire da `a[3]`],
  [`bt`], [_backtrace_: la pila dei record di attivazione (chi ha chiamato chi)],
  [`x`], [stampa il contenuto di un indirizzo di memoria],
  [`continue`], [riparte fino al prossimo breakpoint],
  [`next`], [un'istruzione avanti, *senza entrare* nelle funzioni chiamate],
  [`step`], [un'istruzione avanti, *entrando* nelle chiamate],
  [`finish`], [fino all'uscita dalla funzione corrente],
)

#align(center, canvas(length: 1cm, {
  import draw: *
  rect((0, 0), (2.4, 0.6), fill: rgb("#dce8fb")); content((0.5, 0.3), text(7pt)[`main`])
  rect((2.4, 0), (2.7, 0.6), fill: rgb("#f5b7b1")); content((2.55, 0.3), text(6pt)[BP])
  rect((2.7, 0), (6, 0.6), fill: rgb("#dce8fb"))
  rect((6, 0), (9, 0.6), fill: rgb("#dff2e3")); content((7.5, 0.3), text(7pt)[funzione `f`])
  rect((9, 0), (10, 0.6), fill: rgb("#dce8fb")); content((9.5, 0.3), text(7pt)[`main`])
  rect((10, 0), (10.3, 0.6), fill: rgb("#f5b7b1")); content((10.15, 0.3), text(6pt)[BP])
  rect((10.3, 0), (10.8, 0.6), fill: rgb("#dce8fb"))
  content((2.55, 1.2), text(7pt)[`run`]); line((2.55, 1.0), (2.55, 0.65), mark: (end: "stealth"))
  content((5.6, 1.2), text(7pt)[`next`]); line((5.6, 1.0), (5.6, 0.65), mark: (end: "stealth"))
  bezier((5.9, 0.65), (9.1, 0.65), (7.5, 1.8), mark: (end: "stealth"), stroke: 0.6pt + blu); content((7.5, 1.6), text(7pt, fill: blu)[`next` salta `f`])
  content((6.1, -0.5), text(7pt)[`step`]); line((6.1, -0.3), (6.1, -0.05), mark: (end: "stealth"))
  bezier((7.5, -0.05), (9.1, -0.05), (8.3, -0.7), mark: (end: "stealth"), stroke: 0.6pt + verde); content((8.3, -0.85), text(7pt, fill: verde)[`finish`])
  bezier((2.8, -0.05), (10.1, -0.05), (6.5, -1.9), mark: (end: "stealth"), stroke: 0.6pt + red); content((4.2, -1.3), text(7pt, fill: red)[`continue`: al prossimo BP])
}))

Lo schema mostra un'esecuzione: la barra è il programma nel tempo, BP sono i breakpoint. `run` parte e si ferma al primo BP. `next` avanza di un'istruzione, e se l'istruzione chiama `f` la esegue tutta in un colpo. `step` invece entra in `f`, e da dentro `finish` porta all'uscita. `continue` corre fino al prossimo BP.

*valgrind* esegue il programma tenendo traccia di *tutti gli accessi alla memoria*, e stampa un messaggio quando la memoria è usata male: variabili non inizializzate, stack overflow, memory leak (con `--leak-check=full`). Nessuno dei due strumenti entra nel codice di una libreria già compilata: le funzioni vanno testate prima di metterle in una libreria.

= Strutture dati

#obiettivi(
  [allocare una `struct` sull'heap e usarne i campi con `->`;],
  [costruire, scorrere e liberare una lista concatenata, inserendo in testa e in coda;],
  [inserire in un albero binario di ricerca, visitarlo in ordine e liberarlo, con funzioni ricorsive.],
)

== Liste concatenate <liste>

In JavaScript oggetti e array crescono da soli e la memoria la libera il garbage collector. In C una struttura che cresce si costruisce a mano: ogni pezzo è una `struct` allocata con `malloc`, e i pezzi sono collegati da puntatori.

Per prima cosa serve un puntatore a `struct`. Per esempio una pila (`Stack`, un array più un intero) allocata sull'heap:

#grid(columns: (1fr, 1fr), gutter: 1em, align: horizon,
```c
typedef struct {
    int elements[N];
    int n;
} Stack;

Stack *s = (Stack*) malloc(sizeof(Stack));
s->n = 0;
```,
[Ai campi si accede con l'operatore *`->`*: `s->n` è una scorciatoia per `(*s).n`, cioè "il campo `n` della `struct` puntata da `s`". Le parentesi servono perché `.` lega più di `*`: `*s.n` vorrebbe dire `*(s.n)`.

`.` si usa su una `struct`, `->` su un *puntatore* a `struct`.])

#esercizio[ordinare con merge sort][Allocare dinamicamente un array di puntatori a `struct Studente` (matricola ed età), leggere numero e dati degli studenti, ordinare l'array per matricola con Merge Sort e stamparlo, poi liberare tutta la memoria. Si ordinano i *puntatori*: `array[k] = L[i]` sposta un indirizzo, non la `struct`.]

Una `struct` può contenere un puntatore a una `struct` del suo stesso tipo (*self-referential struct*). È quello che serve per una *lista concatenata*: ogni elemento contiene un valore e il riferimento all'elemento *successivo*; la lista si gestisce tenendo un puntatore al *primo* elemento, la testa (`head`). L'ultimo ha `next = NULL`.

#grid(columns: (1fr, auto), gutter: 1.5em, align: horizon,
```c
struct n {
    int val;
    struct n *next;
};
typedef struct n Node;
```,
canvas(length: 1cm, {
  import draw: *
  for (k, v) in ("9", "10", "11").enumerate() {
    let x = k * 2.2
    rect((x, 0), (x + 0.8, 0.6), fill: rgb("#dff2e3")); content((x + 0.4, 0.3), text(9pt, v))
    rect((x + 0.8, 0), (x + 1.6, 0.6), fill: rgb("#dff2e3"))
    if k < 2 { line((x + 1.2, 0.3), (x + 2.2, 0.3), mark: (end: "stealth")) } else { content((x + 1.2, 0.3), text(6.5pt)[`NULL`]) }
  }
  content((-0.4, 1.0), text(8pt)[`head`]); line((-0.3, 0.85), (0.2, 0.62), mark: (end: "stealth"))
  content((0.4, -0.3), text(6.5pt, fill: gray)[`val`]); content((1.2, -0.3), text(6.5pt, fill: gray)[`next`])
}))

Nella `struct` va scritto `struct n *next` e non `Node *next`, perché il nome `Node` nasce solo con il `typedef` dopo. L'esempio del prof costruisce questa lista con tre nodi locali e la stampa:

#grid(columns: (1.2fr, 1fr), gutter: 1em, align: horizon,
```c
Node *head = NULL;           // lista vuota

Node elem;
elem.val = 10;
elem.next = NULL;
head = &elem;                // un elemento

Node elem1;                  // in coda
elem1.val = 11;
elem1.next = NULL;
elem.next = &elem1;

Node elem2;                  // in testa
elem2.val = 9;
elem2.next = head;
head = &elem2;
```,
[
```c
Node *l = head;
while (l != NULL) {
    printf("%d ", l->val);
    l = l->next;
}
// 9 10 11
```
- *in testa*: il nuovo nodo punta alla vecchia testa, poi diventa la testa;
- *in coda*: l'ultimo nodo, che puntava a `NULL`, punta al nuovo;
- *scorrere*: un puntatore `l` parte dalla testa e segue `next` finché non trova `NULL`.
])

Con nodi locali la lista muore con la funzione. Una lista vera alloca ogni nodo con `malloc`. Nella soluzione del prof a un esercizio, ogni nodo è uno studente:

```c
typedef struct Studente {
    int matricola;
    int eta;
    struct Studente *next;
} Studente;

Studente* aggiungiStudente(Studente *head, int matricola, int eta) {
    Studente *nuovo = (Studente *) malloc(sizeof(Studente));
    if (nuovo == NULL) return head;
    nuovo->matricola = matricola;
    nuovo->eta = eta;
    nuovo->next = NULL;
    if (head == NULL) return nuovo;      // lista vuota: diventa la testa
    Studente *temp = head;
    while (temp->next != NULL)           // cerco l'ultimo
        temp = temp->next;
    temp->next = nuovo;
    return head;
}

void liberaLista(Studente *head) {
    Studente *temp;
    while (head != NULL) {
        temp = head;
        head = head->next;    // prima avanzo...
        free(temp);           // ...poi libero
    }
}
```

Due punti non scontati:
+ `aggiungiStudente` *restituisce la testa*, e chi la chiama assegna il risultato alla sua testa (`head = aggiungiStudente(head, …)`). Serve perché se la lista era vuota la testa cambia, e la funzione ha solo una copia di `head`.
+ In `liberaLista` l'ordine conta: dopo `free(temp)` leggere `temp->next` sarebbe un uso dopo `free`.

L'alternativa al valore restituito è il passaggio per indirizzo della testa, come in `swap`. Il `main` del prof lo fa con la funzione di test:

#grid(columns: (1.5fr, 1fr), gutter: 1em, align: horizon,
```c
void testLista(Studente **lista) {
    *lista = aggiungiStudente(*lista,
                              1, 23);
    *lista = aggiungiStudente(*lista,
                              2, 21);
    stampaLista(*lista);
}

int main(void) {
    Studente *lista = NULL;
    testLista(&lista);
    liberaLista(lista);
}
```,
[`lista` è un `Studente *`; il suo indirizzo `&lista` è uno `Studente **`. Dentro `testLista`, `*lista` *è* la variabile `lista` del `main`, quindi assegnarle una nuova testa cambia proprio quella.])

#esercizio[lista di studenti][Completare il programma: `stampaLista`; `ordinaPerEta`, che ordina la lista per età crescente con un bubble sort che scambia i *valori* dei nodi (non i puntatori); `estraiPerEta`, che restituisce una *nuova* lista con gli studenti dell'età letta da tastiera. Alla fine liberare entrambe le liste.]

== Alberi binari di ricerca <alberi>

Lo stesso schema con *due* puntatori per nodo dà un albero binario. In un *albero binario di ricerca* ogni nodo ha a sinistra solo valori minori e a destra solo valori maggiori o uguali. Nell'esercizio del prof i nodi sono studenti ordinati per età: i più giovani a sinistra, i più anziani a destra. Inserimento, stampa e liberazione sono *ricorsivi*.

#grid(columns: (1.6fr, 1fr), gutter: 1em, align: horizon,
```c
typedef struct Studente {
    int matricola;
    int eta;
    struct Studente *left;
    struct Studente *right;
} Studente;

Studente* inserisciStudente(Studente *radice,
                            int matricola,
                            int eta) {
    if (radice == NULL)    // posto vuoto: qui
        return creaNodo(matricola, eta);
    if (eta < radice->eta)
        radice->left = inserisciStudente(
            radice->left, matricola, eta);
    else
        radice->right = inserisciStudente(
            radice->right, matricola, eta);
    return radice;
}
```,
canvas(length: 1cm, {
  import draw: *
  let nodo(p, t) = { circle(p, radius: 0.35, fill: rgb("#eef4ff")); content(p, text(8pt, t)) }
  line((0, 0), (-1.2, -1.2)); line((0, 0), (1.2, -1.2))
  line((-1.2, -1.2), (-0.6, -2.4)); line((1.2, -1.2), (0.6, -2.4))
  nodo((0, 0), [22]); nodo((-1.2, -1.2), [20]); nodo((1.2, -1.2), [25])
  nodo((-0.6, -2.4), [21]); nodo((0.6, -2.4), [23])
  content((0, -3.2), text(7.5pt, fill: gray)[inseriti: 22, 20, 25, 21, 23])
}))

`creaNodo` alloca il nodo con `malloc` e mette `left` e `right` a `NULL`. Come per la lista, `inserisciStudente` restituisce la radice, che cambia solo quando l'albero è vuoto: si chiama `radice = inserisciStudente(radice, m, e);`. Nel disegno, 21 va a sinistra di 22 (è minore) e poi a destra di 20 (è maggiore).

#grid(columns: (1fr, 1fr), gutter: 1em,
```c
void stampaInOrder(Studente *radice) {
    if (radice == NULL) return;
    stampaInOrder(radice->left);
    printf("%d %d\n", radice->matricola,
                     radice->eta);
    stampaInOrder(radice->right);
}
```,
```c
void liberaAlbero(Studente *radice) {
    if (radice == NULL) return;
    liberaAlbero(radice->left);
    liberaAlbero(radice->right);
    free(radice);
}
```)

La visita *in ordine* (sinistra, nodo, destra) stampa le età in ordine crescente: 20, 21, 22, 23, 25. In `liberaAlbero` il nodo si libera *per ultimo*: liberato prima, i suoi `left` e `right` non si potrebbero più leggere.

#esercizio[albero di studenti][Leggere coppie matricola/età e inserirle nell'albero, fermandosi quando la matricola è 0. Stampare gli studenti in ordine di età, poi quelli di un'età letta da tastiera (`stampaEta`, ricorsiva), e liberare la memoria.]

#set heading(numbering: none)
= Riepilogo

#table(columns: (auto, 1fr, 1fr),
  [Errore], [Quando], [Esempio],
  [di compilazione], [sintassi, tipi incompatibili, nome non dichiarato], [`expected ';'`, `'countA' undeclared`, `implicit declaration of function`, `makes pointer from integer without a cast`],
  [del linker], [manca la *definizione* di qualcosa di dichiarato], [`undefined reference to 'max'` (anche se è `static` in un altro file)],
  [di esecuzione], [compila ma si comporta male], [`Segmentation fault`: `NULL`, memoria non allocata, scrivere su `char *s = "…"`],
)

#table(columns: (auto, 1fr),
  [Scrittura], [Significato],
  [`int *p;`], [puntatore a `int`, valore non definito],
  [`p = &x;` / `*p = 5;`], [`p` punta a `x` / scrive 5 in `x`],
  [`a + i`, `*(a + i)`], [`&a[i]`, `a[i]` (avanza di `i` *elementi*)],
  [`int **m`], [puntatore a puntatore: array di righe, o indirizzo di un puntatore da modificare],
  [`s->campo`], [`(*s).campo`],
  [`void *`], [puntatore generico: casting prima di dereferenziare],
  [`int (*f)(int, int)`], [puntatore a funzione],
)

#table(columns: (auto, auto, 1fr),
  [Variabile], [Dove], [Visibile / durata],
  [locale], [stack], [nel blocco / fino alla `}`],
  [locale `static`], [dati statici], [nel blocco / tutto il programma, mantiene il valore],
  [globale], [dati statici], [nel file, e negli altri con `extern` / tutto il programma],
  [globale `static`], [dati statici], [solo nel suo file / tutto il programma],
  [`malloc`, `calloc`], [heap], [tramite puntatore / fino a `free`],
)

*Trappole*
- `5 / 2` vale 2; `(float) a / b` divide fra reali, `(float) (a / b)` no.
- `2 < a < 5` è sempre vero; `switch` senza `break` prosegue nel `case` dopo.
- `scanf` vuole gli indirizzi (`&x`, ma non per un array di `char`) e `%lf` per i `double`.
- Una variabile in un blocco interno copre quella esterna, e la condizione del `do-while` vede quella esterna.
- `a + i` e non `a + i * sizeof(int)`; `sizeof` di un array ≠ `sizeof` di un puntatore.
- `char s[] = "ciao"` si modifica, `char *s = "ciao"` no; `s2 = s1` copia l'indirizzo; le stringhe si confrontano con `strcmp`, non con `==`.
- `strtok` modifica la stringa; `strlen` non conta `'\0'`, ma lo spazio da allocare sì (`n + 1`).
- Controllare `!= NULL` dopo `malloc`; liberare le righe prima dell'array di righe, il nodo dopo aver letto `next`.
