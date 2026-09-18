# Laboratorio 2 — Dispensa

## Indice
1. [Lezione 1 — Comandi base e primo programma C](#lezione-1--comandi-base-e-primo-programma-c)
2. [Lezione 2 — File, metadati e redirezione](#lezione-2--file-metadati-e-redirezione)

---

## Lezione 1 — Comandi base e primo programma C

### Comandi base

| Comando | Descrizione |
|---|---|
| `pwd` | *print working directory*: stampa in quale cartella sei |
| `ls` | elenca il contenuto della directory corrente |
| `ls -l` | elenco in formato lungo (permessi, proprietario, dimensione, data) |
| `cd` | *change directory*: navigo in una directory |
| `mkdir` | *make directory*: crea una directory |
| `echo $?` | restituisce il valore di ritorno dell'ultimo comando eseguito |

Percorsi speciali con `cd`:
- `.` indica la directory corrente
- `..` indica la directory padre

### Compilazione

```bash
gcc -o first first.c                          # compila first.c e genera l'eseguibile first
gcc -Wall -Wextra -std=c11 -o first first.c   # con tutti i warning e standard C11
```

### Esempio di programma C

```c
#include <stdio.h>

int main() {
    puts("hello");                   // prende una stringa e va a capo
    printf("Risultato: %d\n", 5);    // stringa formattata, non va a capo da sola; funzione a parametri variabili
    return 0;
}
```

---

## Lezione 2 — File, metadati e redirezione

### `touch` e i metadati temporali

`touch`: se il file non esiste lo crea, se esiste ne aggiorna la data di modifica.

Tre metadati di un file:

| Metadato | Significato |
|---|---|
| `atime` | *access time*: ultimo accesso al file |
| `mtime` | *modification time*: ultima modifica del contenuto |
| `ctime` | *change time*: ultima modifica dei metadati |

`touch` aggiorna `atime` e `mtime` al tempo corrente. Poiché questo modifica i metadati, normalmente viene aggiornato anche `ctime`.

`stat`: restituisce informazioni su un file, tra cui `atime`, `mtime`, `ctime`.

### Copia e spostamento

`cp`: copia il contenuto di un file sorgente in un file destinazione.

- **Destinazione**: `mtime` e `ctime` aggiornati all'ora corrente (anche `atime` se il file viene creato). Con `-p`, `atime` e `mtime` vengono preservati dal sorgente (`ctime` no).
- **Sorgente**: `mtime` e `ctime` invariati; `atime` può essere aggiornato dalla lettura.

```bash
cp /tmp/ciao.txt ~/hello.txt   # copia ciao.txt da /tmp nella home, rinominandolo hello.txt
```

**Costo computazionale**
- Copia: **O(N)** — bisogna leggere tutti i byte del sorgente, il tempo cresce linearmente con la dimensione.
- Spostamento nello **stesso filesystem**: **O(1)** — nessun dato viene letto, si aggiornano solo i metadati (il percorso).
- Spostamento su **altro filesystem**: **O(N)** — il file viene copiato nel nuovo filesystem e poi cancellato dal vecchio.

### Cancellazione

| Comando | Descrizione |
|---|---|
| `rm` | cancella un file |
| `rmdir` | cancella una directory **vuota** |
| `rm -r` | cancella una directory con tutto il suo contenuto (file e sottodirectory) |

### Visualizzare file

| Comando | Descrizione |
|---|---|
| `cat` | stampa il contenuto di un file su stdout |
| `less` | come `cat`, ma permette di scorrere avanti/indietro e cercare |
| `head` | stampa le prime 10 righe |
| `tail` | stampa le ultime 10 righe |
| `head -n 5 file.txt` | stampa le prime 5 righe di `file.txt` |

### Wildcard (glob)

- `*` corrisponde a qualsiasi sequenza di caratteri. Es. `*.txt` = tutti i file che terminano in `.txt`.
- `?` corrisponde a **un solo** carattere qualsiasi. Es. `prova?.txt` corrisponde a `prova1.txt`, `provaA.txt`, …

> L'espansione è fatta **dalla shell**, non dal comando.
> Con `a.txt`, `b.txt`, `c.c` nella directory, `ls *.txt` diventa `ls a.txt b.txt`: `ls` non vede mai l'asterisco.

### Input / Output

**Redirigere lo standard output** con `>` (sovrascrive o crea il file):
```bash
ls > elenco.txt
```

**Aggiungere invece di sostituire** con `>>`:
```bash
echo "prima riga" > log.txt
echo "seconda riga" >> log.txt
cat log.txt
# prima riga
# seconda riga
```

**Redirigere lo standard input** con `<` (legge da file invece che da tastiera):
```bash
programma < dati.txt
```
