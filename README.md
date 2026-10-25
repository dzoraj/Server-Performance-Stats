# Terminal System Monitor: Command Notes
https://roadmap.sh/projects/server-stats

Notes on the key commands used in the monitoring script.

## Table of Contents

1. [Cursor control: `echo -e "\033[1A\r\c"`](#1-cursor-control-echo--e-033-1ar-c)
2. [Pattern matching with `awk`](#2-pattern-matching-with-awk)
3. [Reading CPU data with `top -b -n 1`](#3-reading-cpu-data-with-top--b--n-1)
4. [The main loop](#4-the-main-loop)

---

## 1. Cursor control: `echo -e "\033[1A\r\c"`

```bash
echo -e "\033[1A\r\c"
```

This line moves the cursor up one line and parks it at the start of that line, ready to be overwritten.

### The command: `echo -e`

| Part   | Meaning                                                                                                                                              |
| ------ | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| `echo` | Prints whatever follows.                                                                                                                             |
| `-e`   | Enables interpretation of backslash escape sequences. Without it, the terminal would print the literal text `\033[1A\r\c` instead of acting on it. |

### The control sequence: `\033[1A`

| Part  | Meaning                                                                                                                                                      |
| ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `\033` | The ASCII **Escape** character (octal `033`, hex `1B`, decimal `27`). It tells the terminal that what follows is a control instruction, not text to display. |
| `[`   | The **Control Sequence Introducer (CSI)**, which marks the start of an ANSI command.                                                                          |
| `1`   | The count: how many times to apply the command.                                                                                                               |
| `A`   | The command code for **CUU** (Cursor Up).                                                                                                                     |

Together, `\033[1A` means: *"Move the cursor up by 1 line."*

> To move up several lines, change the count. For example, `\033[18A` moves up 18 lines.

### The reset: `\r`

`\r` is a **carriage return**. Moving up with `A` keeps the cursor's horizontal position (if it was 20 characters across, it stays 20 characters across on the line above). `\r` snaps it back to **column 0**, the far-left edge of the screen.

### The suppressor: `\c`

`\c` **suppresses the trailing newline**. Normally `echo` ends its output with `\n`, which drops the cursor to a fresh line. `\c` tells `echo` to stop right there, so the cursor stays at the start of the top line, ready for the next loop iteration to overwrite it.

### Summary

When the shell runs this line, it:

1. Reads the escape signal (`\033`).
2. Moves the cursor up 1 line (`[1A`).
3. Snaps the cursor to the far left (`\r`).
4. Refuses to drop down a line (`\c`).

---

## 2. Pattern matching with `awk`

```bash
awk '/^pattern/ { action }'
```

In `awk`, a regular expression enclosed in forward slashes acts as a **filter**. Every input line is tested against the pattern, and the `{ action }` runs only on lines that match.

### Syntax components

| Component             | Meaning                                                                                                                                                                      |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `/ ... /`             | Delimiters that enclose a regular expression.                                                                                                                                 |
| `^`                   | Anchor meaning "start of the line". The pattern must appear at the very beginning, not somewhere in the middle.                                                              |
| Literal text          | Ordinary characters inside the slashes are matched character for character.                                                                                                  |
| `\` (backslash)       | Escapes special regex characters such as `(`, `)`, `.`, `*`, `?`, `[`, `]` so they are treated as plain text. For example, `/%Cpu\(s\)/` matches the literal text `%Cpu(s)`. |

### Fields: `$1`, `$2`, `$8`, ...

In `awk`, `$` followed by a number means **column number** (field number). By default, fields are separated by whitespace.

For example, take this line from `top`:

```text
%Cpu(s):  0.2 us,  0.1 sy,  0.0 ni, 99.6 id,  0.0 wa,  0.0 hi,  0.1 si,  0.0 st
```

| Field | Value      |
| ----- | ---------- |
| `$1`  | `%Cpu(s):` |
| `$2`  | `0.2`      |
| `$3`  | `us,`      |
| `$4`  | `0.1`      |
| `$5`  | `sy,`      |
| `$6`  | `0.0`      |
| `$7`  | `ni,`      |
| `$8`  | `99.6` ← **idle (`id`) percentage** |
| `$9`  | `id,`      |

Because `$8` is the idle percentage, total CPU usage is `100 - $8`:

```bash
top -b -n 1 | awk '/%Cpu\(s\)/ {print 100 - $8}'
```

---

## 3. Reading CPU data with `top -b -n 1`

```bash
top -b -n 1
```

| Flag | Name           | Meaning                                                                                                                                                                                         |
| ---- | -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `-b` | **Batch mode** | Runs `top` as a plain text stream instead of an interactive program. It removes screen-clearing formatting and prints straight down the terminal, which is required when piping into `grep` or `awk`. |
| `-n` | **Iterations** | Sets how many times `top` refreshes before exiting. `-n 1` means "run once and quit", so the script doesn't hang waiting for input.                                                             |

---

## 4. The main loop

```bash
while true; do
    # ... commands ...
    sleep 2
done
```

| Part                  | Meaning                                                                                                                                      |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `while true; do ... done` | Creates an infinite loop that repeats everything inside it.                                                                              |
| `sleep 2`             | Pauses for 2 seconds between iterations so the script doesn't run hundreds of `top` commands per second. Use `1` for faster or `5` for slower refreshes. |

**To stop the loop**, press `Ctrl + C`.
