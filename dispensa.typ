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

#let nota(body) = block(
  fill: rgb("#eef4ff"), stroke: (left: 3pt + rgb("#3b6fd8")),
  inset: 10pt, width: 100%, body,
)

#align(center)[
  #v(4cm)
  #text(24pt, weight: "bold")[Laboratorio 2]
  #v(0.3cm)
  #text(14pt)[Diego Stefanini]
]
#v(1cm)
#outline()

= Comandi base e primo programma C

== Comandi base

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

Percorsi speciali con `cd`:
- `.` indica la directory corrente
- `..` indica la directory padre

== Compilazione

```bash
gcc -o first first.c                          # compila first.c e genera l'eseguibile first
gcc -Wall -Wextra -std=c11 -o first first.c   # con tutti i warning e standard C11
```

== Esempio di programma C

```c
#include <stdio.h>

int main() {
    puts("hello");                  // prende una stringa e va a capo
    printf("Risultato: %d\n", 5);   // stringa formattata, non va a capo da sola
    return 0;
}
```

#nota[`printf` è una funzione a *numero variabile di parametri*: il primo è la stringa di formato, gli altri i valori da inserire al posto di `%d`, `%s`, …]

= File, metadati e redirezione

== `touch` e i metadati temporali

`touch`: se il file non esiste lo crea, se esiste ne aggiorna la data di modifica.

#table(
  columns: (auto, 1fr),
  [Metadato], [Significato],
  [`atime`], [_access time_: ultimo accesso al file],
  [`mtime`], [_modification time_: ultima modifica del contenuto],
  [`ctime`], [_change time_: ultima modifica dei metadati],
)

`touch` aggiorna `atime` e `mtime` al tempo corrente.

#nota[Aggiornare `atime` e `mtime` è già una modifica dei metadati, quindi normalmente cambia anche `ctime`.]

`stat`: restituisce informazioni su un file, tra cui `atime`, `mtime`, `ctime`.

== Copia e spostamento

`cp`: copia il contenuto di un file sorgente in un file destinazione.

- *Destinazione*: `mtime` e `ctime` aggiornati all'ora corrente (anche `atime` se il file viene creato). Con `-p`, `atime` e `mtime` vengono preservati dal sorgente (`ctime` no).
- *Sorgente*: `mtime` e `ctime` invariati; `atime` può essere aggiornato dalla lettura.

```bash
cp /tmp/ciao.txt ~/hello.txt   # copia ciao.txt da /tmp nella home, rinominandolo hello.txt
```

=== Costo computazionale

#table(
  columns: (auto, auto, 1fr),
  [Operazione], [Costo], [Perché],
  [Copia], [$O(N)$], [bisogna leggere tutti i byte del sorgente],
  [Spostamento, stesso filesystem], [$O(1)$], [si aggiornano solo i metadati (il percorso)],
  [Spostamento, altro filesystem], [$O(N)$], [copia nel nuovo filesystem + cancellazione dal vecchio],
)

== Cancellazione

#table(
  columns: (auto, 1fr),
  [Comando], [Descrizione],
  [`rm`], [cancella un file],
  [`rmdir`], [cancella una directory *vuota*],
  [`rm -r`], [cancella una directory con tutto il suo contenuto (file e sottodirectory)],
)

== Visualizzare file

#table(
  columns: (auto, 1fr),
  [Comando], [Descrizione],
  [`cat`], [stampa il contenuto di un file su stdout],
  [`less`], [come `cat`, ma permette di scorrere avanti/indietro e cercare],
  [`head`], [stampa le prime 10 righe],
  [`tail`], [stampa le ultime 10 righe],
  [`head -n 5 file.txt`], [stampa le prime 5 righe di `file.txt`],
)

== Wildcard (glob)

- `*` corrisponde a qualsiasi sequenza di caratteri. Es. `*.txt` = tutti i file che terminano in `.txt`.
- `?` corrisponde a *un solo* carattere qualsiasi. Es. `prova?.txt` corrisponde a `prova1.txt`, `provaA.txt`, …

#nota[L'espansione è fatta *dalla shell*, non dal comando. Con `a.txt`, `b.txt`, `c.c` nella directory, `ls *.txt` diventa `ls a.txt b.txt`: `ls` non vede mai l'asterisco.]

== Input / Output

*Redirigere lo standard output* con `>` (sovrascrive o crea il file):
```bash
ls > elenco.txt
```

*Aggiungere invece di sostituire* con `>>`:
```bash
echo "prima riga" > log.txt
echo "seconda riga" >> log.txt
cat log.txt
# prima riga
# seconda riga
```

*Redirigere lo standard input* con `<` (legge da file invece che da tastiera):
```bash
programma < dati.txt
```

== Pipe `|`

La pipe collega l'output di un comando all'input di un altro, senza passare per un file intermedio.

```bash
ls | less        # scorro l'elenco dei file con less
ls *.c | wc -l   # conta quanti file .c ci sono (wc -l conta le righe)
```

== Chi riceve gli argomenti?

La shell separa la riga in parole e avvia il programma passandogli gli argomenti.

#nota[Vedremo come un programma C accede a questi argomenti tramite `argc` e `argv`, i parametri della funzione `main`.]
