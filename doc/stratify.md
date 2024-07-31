Consider the following table of relationships:

Name  | Parent
------|--------
Eve   |
Cain  | Eve
Seth  | Eve
Enos  | Seth
Noam  | Seth
Abel  | Eve
Awan  | Eve
Enoch | Awan
Azura | Eve

These names are conveniently unique, so we can unambiguously represent the hierarchy as a CSV file:

```
name,parent
Eve,
Cain,Eve
Seth,Eve
Enos,Seth
Noam,Seth
Abel,Eve
Awan,Eve
Enoch,Awan
Azura,Eve
```

To parse the CSV using [csvParse](https://pub.dev/documentation/d4_dsv/latest/d4_dsv/csvParse.html):

```dart
final table = csvParse(text);
```

This returns an list of {*name*, *parent*} maps:

```json
[
  {"name": "Eve",   "parent": ""},
  {"name": "Cain",  "parent": "Eve"},
  {"name": "Seth",  "parent": "Eve"},
  {"name": "Enos",  "parent": "Seth"},
  {"name": "Noam",  "parent": "Seth"},
  {"name": "Abel",  "parent": "Eve"},
  {"name": "Awan",  "parent": "Eve"},
  {"name": "Enoch", "parent": "Awan"},
  {"name": "Azura", "parent": "Eve"}
]
```

To convert to a [hierarchy](https://pub.dev/documentation/d4_hierarchy/latest/topics/Hierarchies-topic.html):

```dart
final root = (Stratify()
  ..id = ((d, i, data) => d["name"])
  ..parentId = ((d, i, data) => d["parent"]))(table);
```

This hierarchy can now be passed to a hierarchical layout, such as [tree](https://pub.dev/documentation/d4_hierarchy/latest/topics/Tree-topic.html), for visualization.

The stratify operator also works with [delimited paths](https://pub.dev/documentation/d4_hierarchy/latest/d4_hierarchy/Stratify/path.html) as is common in file systems.