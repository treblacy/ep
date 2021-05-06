# ep prints and helps edit elements of PATH

ep prints the elements of PATH one per line. Editing is also possible when
combined with a shell's eval and command substitution features.

To print elements one per line:

```
ep print
```

If `PATH=/usr/local/bin:/usr/bin:/bin`, the output is:

```
/usr/local/bin
/usr/bin
/bin
```

To edit: The following `ep` commands help with editing PATH by outputting the
desired new “`PATH=...`” string to stdout.  This alone changes nothing, but you
can add command substitution and eval to cause changes.  The following examples
use Bourne shell syntax.

To add an element at the front:

```
eval $(ep prepend /usr/local/ghcup/bin)
```

To add an element at the end:

```
eval $(ep append /usr/local/ghcup/bin)
```

To delete an element—first match by string equality:

```
eval $(ep delete /usr/local/ghcup/bin)
```

To help with arbitrary editing, `ep read` reads elements from stdin, expecting
one element per line, and composes them into a `PATH=...` string.  (So, dual and
inverse of `ep print` in most senses.)  You can combine this with `ep print` and
a line-oriented stream editor.  Example:

```
eval $(ep print | sed -e s/jdk7/jdk8/ | ep read)
```

For manual editing, you can also start with `ep print > tmpfile`, edit tmpfile,
then `eval $(ep read < tmpfile)`.  The line-oriented format is more ergonomic to
work with than one huge colon-separated line.

`ep read -b` additionally dumps the old `PATH=...` string to stderr for your
backup purposes.

In a future version, this `-b` flag will also be added to the other editing
commands.
