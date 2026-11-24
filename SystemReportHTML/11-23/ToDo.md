Update CSS for registry

## CoPilot Reply
---

place each registry-values table inside a horizontally scrollable container. This prevents the Value name, Type, and Data headers from wrapping.

### Replace the existing registry table CSS

Find:

```CSS
.registry-values {
margin-top: 8px;
border-collapse: collapse;
width: 100%;
font-size: 12px;
}
```
Replace it with:

```CSS
.registry-values {
margin-top: 8px;
border-collapse: collapse;
width: max-content;
min-width: 100%;
font-size: 12px;
table-layout: auto;
}
 
.registry-values th {
white-space: nowrap;
}
 
.registry-values td {
white-space: nowrap;
}
 
.registry-values td.registry-value-data {
min-width: 400px;
}
```
Add a horizontal-scroll wrapper

### Add this CSS:

```CSS
.registry-table-scroll {
width: 100%;
max-width: 100%;
overflow-x: auto;
overflow-y: hidden;
margin-top: 8px;
scrollbar-gutter: stable;
}
```
In `createRegistryNode()`, find:

```JavaScript
info.appendChild(table);
```

Replace it with:

```JavaScript
const tableScroll = createElement('div', 'registry-table-scroll');
tableScroll.appendChild(table);
info.appendChild(tableScroll);
```

### Optional: allow only the data column to wrap

If registry data can be extremely long, use this instead:

```CSS
.registry-values th,
.registry-values td:not(.registry-value-data) {
white-space: nowrap;
}
 
.registry-values td.registry-value-data {
min-width: 400px;
max-width: 900px;
white-space: pre-wrap;
overflow-wrap: break-word;
}
```

This preserves readable headers while allowing long registry data to wrap after the table reaches 900 pixels.


## Fic unrenderable Triangles

from copilot

---

Easiest fix: use HTML entities

Replace:

```JavaScript
hasChildren ? '▶' : '•'
```
with:

```JavaScript
hasChildren ? '\u25B6' : '\u2022'
```
and:

```JavaScript
button.textContent = open ? '▼' : '▶';
```

with:

```JavaScript
button.textContent = open ? '\u25BC' : '\u25B6';
```
This avoids copy/paste encoding problems.

Better fix: use ASCII text

For maximum compatibility:

```JavaScript
hasChildren ? '+' : '-'
```
and

```JavaScript
button.textContent = open ? '-' : '+';
```
No Unicode at all.
