import 'package:d4_hierarchy/d4_hierarchy.dart';
import 'package:test/test.dart';

import 'equals_hierarchy_node.dart';

void main() {
  test("stratify() has the expected defaults", () {
    final s = Stratify.withDefaults();
    expect(s.id!({"id": "foo"}, 0, []), "foo");
    expect(s.parentId!({"parentId": "bar"}, 0, []), "bar");
  });

  test("stratify(data) returns the root node", () {
    final s = Stratify.withDefaults<Map<String, String>>();
    final root = s([
      {"id": "a"},
      {"id": "aa", "parentId": "a"},
      {"id": "ab", "parentId": "a"},
      {"id": "aaa", "parentId": "aa"}
    ]);
    expect(root, isA<HierarchyNode>());
    expect(
        root,
        EqualsHierarchyNode({
          "id": "a",
          "depth": 0,
          "height": 2,
          "data": {"id": "a"},
          "children": [
            {
              "id": "aa",
              "depth": 1,
              "height": 1,
              "data": {"id": "aa", "parentId": "a"},
              "children": [
                {
                  "id": "aaa",
                  "depth": 2,
                  "height": 0,
                  "data": {"id": "aaa", "parentId": "aa"}
                }
              ]
            },
            {
              "id": "ab",
              "depth": 1,
              "height": 0,
              "data": {"id": "ab", "parentId": "a"}
            }
          ]
        }));
  });

  test("stratify(data) does not require the data to be in topological order",
      () {
    final s = Stratify.withDefaults();
    final root = s([
      {"id": "aaa", "parentId": "aa"},
      {"id": "aa", "parentId": "a"},
      {"id": "ab", "parentId": "a"},
      {"id": "a"}
    ]);
    expect(
        root,
        EqualsHierarchyNode({
          "id": "a",
          "depth": 0,
          "height": 2,
          "data": {"id": "a"},
          "children": [
            {
              "id": "aa",
              "depth": 1,
              "height": 1,
              "data": {"id": "aa", "parentId": "a"},
              "children": [
                {
                  "id": "aaa",
                  "depth": 2,
                  "height": 0,
                  "data": {"id": "aaa", "parentId": "aa"}
                }
              ]
            },
            {
              "id": "ab",
              "depth": 1,
              "height": 0,
              "data": {"id": "ab", "parentId": "a"}
            }
          ]
        }));
  });

  test("stratify(data) preserves the input order of siblings", () {
    final s = Stratify.withDefaults();
    final root = s([
      {"id": "aaa", "parentId": "aa"},
      {"id": "ab", "parentId": "a"},
      {"id": "aa", "parentId": "a"},
      {"id": "a"}
    ]);
    expect(
        root,
        EqualsHierarchyNode({
          "id": "a",
          "depth": 0,
          "height": 2,
          "data": {"id": "a"},
          "children": [
            {
              "id": "ab",
              "depth": 1,
              "height": 0,
              "data": {"id": "ab", "parentId": "a"}
            },
            {
              "id": "aa",
              "depth": 1,
              "height": 1,
              "data": {"id": "aa", "parentId": "a"},
              "children": [
                {
                  "id": "aaa",
                  "depth": 2,
                  "height": 0,
                  "data": {"id": "aaa", "parentId": "aa"}
                }
              ]
            }
          ]
        }));
  });

  test("stratify(data) accepts an iterable", () {
    final s = Stratify.withDefaults();
    final root = s({
      {"id": "aaa", "parentId": "aa"},
      {"id": "ab", "parentId": "a"},
      {"id": "aa", "parentId": "a"},
      {"id": "a"}
    });
    expect(
        root,
        EqualsHierarchyNode({
          "id": "a",
          "depth": 0,
          "height": 2,
          "data": {"id": "a"},
          "children": [
            {
              "id": "ab",
              "depth": 1,
              "height": 0,
              "data": {"id": "ab", "parentId": "a"}
            },
            {
              "id": "aa",
              "depth": 1,
              "height": 1,
              "data": {"id": "aa", "parentId": "a"},
              "children": [
                {
                  "id": "aaa",
                  "depth": 2,
                  "height": 0,
                  "data": {"id": "aaa", "parentId": "aa"}
                }
              ]
            }
          ]
        }));
  });

  test("stratify(data) treats an empty parentId as the root", () {
    final s = Stratify.withDefaults();
    final root = s([
      {"id": "a", "parentId": ""},
      {"id": "aa", "parentId": "a"},
      {"id": "ab", "parentId": "a"},
      {"id": "aaa", "parentId": "aa"}
    ]);
    expect(
        root,
        EqualsHierarchyNode({
          "id": "a",
          "depth": 0,
          "height": 2,
          "data": {"id": "a", "parentId": ""},
          "children": [
            {
              "id": "aa",
              "depth": 1,
              "height": 1,
              "data": {"id": "aa", "parentId": "a"},
              "children": [
                {
                  "id": "aaa",
                  "depth": 2,
                  "height": 0,
                  "data": {"id": "aaa", "parentId": "aa"}
                }
              ]
            },
            {
              "id": "ab",
              "depth": 1,
              "height": 0,
              "data": {"id": "ab", "parentId": "a"}
            }
          ]
        }));
  });

  /*test(
      "stratify(data) does not treat a falsy but non-empty parentId as the root",
      () {
    final s = Stratify.withDefaults();
    final root = s([
      {"id": 0, "parentId": null},
      {"id": 1, "parentId": 0},
      {"id": 2, "parentId": 0}
    ]);
    expect(
        root,
        EqualsHierarchyNode({
          "id": "0",
          "depth": 0,
          "height": 1,
          "data": {"id": 0, "parentId": null},
          "children": [
            {
              "id": "1",
              "depth": 1,
              "height": 0,
              "data": {"id": 1, "parentId": 0}
            },
            {
              "id": "2",
              "depth": 1,
              "height": 0,
              "data": {"id": 2, "parentId": 0}
            }
          ]
        }));
  });*/

  test("stratify(data) throws an error if the data does not have a single root",
      () {
    final s = Stratify.withDefaults();
    expect(() {
      s([
        {"id": "a"},
        {"id": "b"}
      ]);
    },
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          "message",
          "multiple roots",
        )));
    expect(() {
      s([
        {"id": "a", "parentId": "a"}
      ]);
    },
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          "message",
          "no root",
        )));
    expect(() {
      s([
        {"id": "a", "parentId": "b"},
        {"id": "b", "parentId": "a"}
      ]);
    },
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          "message",
          "no root",
        )));
  });

  test("stratify(data) throws an error if the hierarchy is cyclical", () {
    final s = Stratify.withDefaults();
    expect(() {
      s([
        {"id": "root"},
        {"id": "a", "parentId": "a"}
      ]);
    },
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          "message",
          "cycle",
        )));
    expect(() {
      s([
        {"id": "root"},
        {"id": "a", "parentId": "b"},
        {"id": "b", "parentId": "a"}
      ]);
    },
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          "message",
          "cycle",
        )));
  });

  test("stratify(data) throws an error if multiple parents have the same id",
      () {
    final s = Stratify.withDefaults();
    expect(() {
      s([
        {"id": "a"},
        {"id": "b", "parentId": "a"},
        {"id": "b", "parentId": "a"},
        {"id": "c", "parentId": "b"}
      ]);
    },
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          "message",
          contains("ambiguous"),
        )));
  });

  test("stratify(data) throws an error if the specified parent is not found",
      () {
    final s = Stratify.withDefaults();
    expect(() {
      s([
        {"id": "a"},
        {"id": "b", "parentId": "c"}
      ]);
    },
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          "message",
          contains("missing"),
        )));
  });

  test("stratify(data) allows the id to be undefined for leaf nodes", () {
    final s = Stratify.withDefaults();
    final root = s([
      {"id": "a"},
      {"parentId": "a"},
      {"parentId": "a"}
    ]);
    expect(
        root,
        EqualsHierarchyNode({
          "id": "a",
          "depth": 0,
          "height": 1,
          "data": {"id": "a"},
          "children": [
            {
              "depth": 1,
              "height": 0,
              "data": {"parentId": "a"}
            },
            {
              "depth": 1,
              "height": 0,
              "data": {"parentId": "a"}
            }
          ]
        }));
  });

  test("stratify(data) allows the id to be non-unique for leaf nodes", () {
    final s = Stratify.withDefaults();
    final root = s([
      {"id": "a", "parentId": null},
      {"id": "b", "parentId": "a"},
      {"id": "b", "parentId": "a"}
    ]);
    expect(
        root,
        EqualsHierarchyNode({
          "id": "a",
          "depth": 0,
          "height": 1,
          "data": {"id": "a", "parentId": null},
          "children": [
            {
              "id": "b",
              "depth": 1,
              "height": 0,
              "data": {"id": "b", "parentId": "a"}
            },
            {
              "id": "b",
              "depth": 1,
              "height": 0,
              "data": {"id": "b", "parentId": "a"}
            }
          ]
        }));
  });

  test("stratify(data) coerces the id to a string, if not null and not empty",
      () {
    final s = Stratify.withDefaults();
    expect(
        s([
          {"id": _A()}
        ]).id,
        "a");
    expect(
        s([
          {"id": ""}
        ]).id,
        null);
    expect(
        s([
          {"id": null}
        ]).id,
        null);
    expect(s([{}]).id, null);
  });

  test("stratify(data) allows the id to be undefined for leaf nodes", () {
    final s = Stratify.withDefaults();
    final o = {"parentId": _A()};
    final root = s([
      {"id": "a"},
      o
    ]);
    expect(
        root,
        EqualsHierarchyNode({
          "id": "a",
          "depth": 0,
          "height": 1,
          "data": {"id": "a"},
          "children": [
            {"depth": 1, "height": 0, "data": o}
          ]
        }));
  });

  test("stratify.id(id) observes the specified id function", () {
    foo(d, _, __) => d["foo"];
    final s = Stratify.withDefaults()..id = foo;
    final root = s([
      {"foo": "a"},
      {"foo": "aa", "parentId": "a"},
      {"foo": "ab", "parentId": "a"},
      {"foo": "aaa", "parentId": "aa"}
    ]);
    expect(s.id, foo);
    expect(
        root,
        EqualsHierarchyNode({
          "id": "a",
          "depth": 0,
          "height": 2,
          "data": {"foo": "a"},
          "children": [
            {
              "id": "aa",
              "depth": 1,
              "height": 1,
              "data": {"foo": "aa", "parentId": "a"},
              "children": [
                {
                  "id": "aaa",
                  "depth": 2,
                  "height": 0,
                  "data": {"foo": "aaa", "parentId": "aa"}
                }
              ]
            },
            {
              "id": "ab",
              "depth": 1,
              "height": 0,
              "data": {"foo": "ab", "parentId": "a"}
            }
          ]
        }));
  });

  test("stratify.parentId(id) observes the specified parent id function", () {
    foo(d, _, __) => d["foo"];
    final s = Stratify.withDefaults()..parentId = foo;
    final root = s([
      {"id": "a"},
      {"id": "aa", "foo": "a"},
      {"id": "ab", "foo": "a"},
      {"id": "aaa", "foo": "aa"}
    ]);
    expect(s.parentId, foo);
    expect(
        root,
        EqualsHierarchyNode({
          "id": "a",
          "depth": 0,
          "height": 2,
          "data": {"id": "a"},
          "children": [
            {
              "id": "aa",
              "depth": 1,
              "height": 1,
              "data": {"id": "aa", "foo": "a"},
              "children": [
                {
                  "id": "aaa",
                  "depth": 2,
                  "height": 0,
                  "data": {"id": "aaa", "foo": "aa"}
                }
              ]
            },
            {
              "id": "ab",
              "depth": 1,
              "height": 0,
              "data": {"id": "ab", "foo": "a"}
            }
          ]
        }));
  });

  test("stratify.path(path) returns the root node", () {
    final root = (Stratify.withDefaults()..path = (d, _, __) => d["path"])([
      {"path": "/"},
      {"path": "/aa"},
      {"path": "/ab"},
      {"path": "/aa/aaa"}
    ]);
    expect(root, isA<HierarchyNode>());
    expect(
        root,
        EqualsHierarchyNode({
          "id": "/",
          "depth": 0,
          "height": 2,
          "data": {"path": "/"},
          "children": [
            {
              "id": "/aa",
              "depth": 1,
              "height": 1,
              "data": {"path": "/aa"},
              "children": [
                {
                  "id": "/aa/aaa",
                  "depth": 2,
                  "height": 0,
                  "data": {"path": "/aa/aaa"}
                }
              ]
            },
            {
              "id": "/ab",
              "depth": 1,
              "height": 0,
              "data": {"path": "/ab"}
            }
          ]
        }));
  });

  test("stratify.path(path) correctly handles single-character folders", () {
    final root = (Stratify.withDefaults()..path = (d, _, __) => d["path"])([
      {"path": "/"},
      {"path": "/d"},
      {"path": "/d/123"}
    ]);
    expect(root, isA<HierarchyNode>());
    expect(
        root,
        EqualsHierarchyNode({
          "id": "/",
          "depth": 0,
          "height": 2,
          "data": {"path": "/"},
          "children": [
            {
              "id": "/d",
              "depth": 1,
              "height": 1,
              "data": {"path": "/d"},
              "children": [
                {
                  "id": "/d/123",
                  "depth": 2,
                  "height": 0,
                  "data": {"path": "/d/123"}
                }
              ]
            }
          ]
        }));
  });

  test("stratify.path(path) correctly handles empty folders", () {
    final root = (Stratify.withDefaults()..path = (d, _, __) => d["path"])([
      {"path": "/"},
      {"path": "//"},
      {"path": "///"}
    ]);
    expect(root, isA<HierarchyNode>());
    expect(
        root,
        EqualsHierarchyNode({
          "id": "/",
          "depth": 0,
          "height": 2,
          "data": {"path": "/"},
          "children": [
            {
              "id": "//",
              "depth": 1,
              "height": 1,
              "data": {"path": "//"},
              "children": [
                {
                  "id": "///",
                  "depth": 2,
                  "height": 0,
                  "data": {"path": "///"}
                }
              ]
            }
          ]
        }));
  });

  test(
      "stratify.path(path) correctly handles single-character folders with trailing slashes",
      () {
    final root = (Stratify.withDefaults()..path = (d, _, __) => d["path"])([
      {"path": "/"},
      {"path": "/d/"},
      {"path": "/d/123/"}
    ]);
    expect(root, isA<HierarchyNode>());
    expect(
        root,
        EqualsHierarchyNode({
          "id": "/",
          "depth": 0,
          "height": 2,
          "data": {"path": "/"},
          "children": [
            {
              "id": "/d",
              "depth": 1,
              "height": 1,
              "data": {"path": "/d/"},
              "children": [
                {
                  "id": "/d/123",
                  "depth": 2,
                  "height": 0,
                  "data": {"path": "/d/123/"}
                }
              ]
            }
          ]
        }));
  });

  test("stratify.path(path) correctly handles imputed single-character folders",
      () {
    final root = (Stratify.withDefaults()..path = (d, _, __) => d["path"])([
      {"path": "/"},
      {"path": "/d/123"}
    ]);
    expect(root, isA<HierarchyNode>());
    expect(
        root,
        EqualsHierarchyNode({
          "id": "/",
          "depth": 0,
          "height": 2,
          "data": {"path": "/"},
          "children": [
            {
              "id": "/d",
              "depth": 1,
              "height": 1,
              "data": null,
              "children": [
                {
                  "id": "/d/123",
                  "depth": 2,
                  "height": 0,
                  "data": {"path": "/d/123"}
                }
              ]
            }
          ]
        }));
  });

  test("stratify.path(path) allows slashes to be escaped", () {
    final root = (Stratify.withDefaults()..path = (d, _, __) => d["path"])([
      {"path": "/"},
      {"path": "/aa"},
      {"path": "\\/ab"},
      {"path": "/aa\\/aaa"}
    ]);
    expect(root, isA<HierarchyNode>());
    expect(
        root,
        EqualsHierarchyNode({
          "id": "/",
          "depth": 0,
          "height": 1,
          "data": {"path": "/"},
          "children": [
            {
              "id": "/aa",
              "depth": 1,
              "height": 0,
              "data": {"path": "/aa"}
            },
            {
              "id": "/\\/ab",
              "depth": 1,
              "height": 0,
              "data": {"path": "\\/ab"}
            },
            {
              "id": "/aa\\/aaa",
              "depth": 1,
              "height": 0,
              "data": {"path": "/aa\\/aaa"}
            }
          ]
        }));
  });

  test("stratify.path(path) imputes internal nodes", () {
    final root = (Stratify.withDefaults()..path = (d, _, __) => d["path"])([
      {"path": "/aa/aaa"},
      {"path": "/ab"}
    ]);
    expect(root, isA<HierarchyNode>());
    expect(
        root,
        EqualsHierarchyNode({
          "id": "/",
          "depth": 0,
          "height": 2,
          "data": null,
          "children": [
            {
              "id": "/ab",
              "depth": 1,
              "height": 0,
              "data": {"path": "/ab"}
            },
            {
              "id": "/aa",
              "depth": 1,
              "height": 1,
              "data": null,
              "children": [
                {
                  "id": "/aa/aaa",
                  "depth": 2,
                  "height": 0,
                  "data": {"path": "/aa/aaa"}
                }
              ]
            }
          ]
        }));
  });

  test("stratify.path(path) allows duplicate leaf paths", () {
    final root = (Stratify.withDefaults()..path = (d, _, __) => d["path"])([
      {"path": "/aa/aaa", "number": 1},
      {"path": "/aa/aaa", "number": 2},
    ]);
    expect(root, isA<HierarchyNode>());
    expect(
        root,
        EqualsHierarchyNode({
          "id": "/aa",
          "depth": 0,
          "height": 1,
          "data": null,
          "children": [
            {
              "id": "/aa/aaa",
              "depth": 1,
              "height": 0,
              "data": {"path": "/aa/aaa", "number": 1}
            },
            {
              "id": "/aa/aaa",
              "depth": 1,
              "height": 0,
              "data": {"path": "/aa/aaa", "number": 2}
            }
          ]
        }));
  });

  test("stratify.path(path) does not allow duplicate internal paths", () {
    expect(() {
      (Stratify.withDefaults()..path = (d, _, __) => d["path"])([
        {"path": "/aa"},
        {"path": "/aa"},
        {"path": "/aa/aaa"},
        {"path": "/aa/aaa"},
      ]);
    },
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          "message",
          contains("ambiguous"),
        )));
  });

  test("stratify.path(path) implicitly adds leading slashes", () {
    final root = (Stratify.withDefaults()..path = (d, _, __) => d["path"])([
      {"path": ""},
      {"path": "aa"},
      {"path": "ab"},
      {"path": "aa/aaa"}
    ]);
    expect(root, isA<HierarchyNode>());
    expect(
        root,
        EqualsHierarchyNode({
          "id": "/",
          "depth": 0,
          "height": 2,
          "data": {"path": ""},
          "children": [
            {
              "id": "/aa",
              "depth": 1,
              "height": 1,
              "data": {"path": "aa"},
              "children": [
                {
                  "id": "/aa/aaa",
                  "depth": 2,
                  "height": 0,
                  "data": {"path": "aa/aaa"}
                }
              ]
            },
            {
              "id": "/ab",
              "depth": 1,
              "height": 0,
              "data": {"path": "ab"}
            }
          ]
        }));
  });

  test("stratify.path(path) implicitly trims trailing slashes", () {
    final root = (Stratify.withDefaults()..path = (d, _, __) => d["path"])([
      {"path": "/aa/"},
      {"path": "/ab/"},
      {"path": "/aa/aaa/"}
    ]);
    expect(root, isA<HierarchyNode>());
    expect(
        root,
        EqualsHierarchyNode({
          "id": "/",
          "depth": 0,
          "height": 2,
          "data": null,
          "children": [
            {
              "id": "/aa",
              "depth": 1,
              "height": 1,
              "data": {"path": "/aa/"},
              "children": [
                {
                  "id": "/aa/aaa",
                  "depth": 2,
                  "height": 0,
                  "data": {"path": "/aa/aaa/"}
                }
              ]
            },
            {
              "id": "/ab",
              "depth": 1,
              "height": 0,
              "data": {"path": "/ab/"}
            }
          ]
        }));
  });

  test("stratify.path(path) does not trim trailing slashes preceded by a slash",
      () {
    final root = (Stratify.withDefaults()..path = (d, _, __) => d["path"])([
      {"path": "/aa//"},
      {"path": "/b"}
    ]);
    expect(root, isA<HierarchyNode>());
    expect(
        root,
        EqualsHierarchyNode({
          "id": "/",
          "depth": 0,
          "height": 3,
          "data": null,
          "children": [
            {
              "id": "/b",
              "depth": 1,
              "height": 0,
              "data": {"path": "/b"}
            },
            {
              "id": "/aa",
              "depth": 1,
              "height": 2,
              "data": null,
              "children": [
                {
                  "id": "/aa/",
                  "depth": 2,
                  "height": 1,
                  "data": null,
                  "children": [
                    {
                      "id": "/aa//",
                      "depth": 3,
                      "height": 0,
                      "data": {"path": "/aa//"},
                    }
                  ]
                }
              ]
            }
          ]
        }));
  });

  test(
      "stratify.path(path) does not require the data to be in topological order",
      () {
    final root = (Stratify.withDefaults()..path = (d, _, __) => d["path"])([
      {"path": "/aa/aaa"},
      {"path": "/aa"},
      {"path": "/ab"}
    ]);
    expect(root, isA<HierarchyNode>());
    expect(
        root,
        EqualsHierarchyNode({
          "id": "/",
          "depth": 0,
          "height": 2,
          "data": null,
          "children": [
            {
              "id": "/aa",
              "depth": 1,
              "height": 1,
              "data": {"path": "/aa"},
              "children": [
                {
                  "id": "/aa/aaa",
                  "depth": 2,
                  "height": 0,
                  "data": {"path": "/aa/aaa"}
                }
              ]
            },
            {
              "id": "/ab",
              "depth": 1,
              "height": 0,
              "data": {"path": "/ab"}
            }
          ]
        }));
  });

  test("stratify.path(path) preserves the input order of siblings", () {
    final root = (Stratify.withDefaults()..path = (d, _, __) => d["path"])([
      {"path": "/ab"},
      {"path": "/aa"},
      {"path": "/aa/aaa"}
    ]);
    expect(root, isA<HierarchyNode>());
    expect(
        root,
        EqualsHierarchyNode({
          "id": "/",
          "depth": 0,
          "height": 2,
          "data": null,
          "children": [
            {
              "id": "/ab",
              "depth": 1,
              "height": 0,
              "data": {"path": "/ab"}
            },
            {
              "id": "/aa",
              "depth": 1,
              "height": 1,
              "data": {"path": "/aa"},
              "children": [
                {
                  "id": "/aa/aaa",
                  "depth": 2,
                  "height": 0,
                  "data": {"path": "/aa/aaa"}
                }
              ]
            }
          ]
        }));
  });

  test("stratify.path(path) accepts an iterable", () {
    final root = (Stratify.withDefaults()..path = (d, _, __) => d["path"])({
      {"path": "/ab"},
      {"path": "/aa"},
      {"path": "/aa/aaa"}
    });
    expect(root, isA<HierarchyNode>());
    expect(
        root,
        EqualsHierarchyNode({
          "id": "/",
          "depth": 0,
          "height": 2,
          "data": null,
          "children": [
            {
              "id": "/ab",
              "depth": 1,
              "height": 0,
              "data": {"path": "/ab"}
            },
            {
              "id": "/aa",
              "depth": 1,
              "height": 1,
              "data": {"path": "/aa"},
              "children": [
                {
                  "id": "/aa/aaa",
                  "depth": 2,
                  "height": 0,
                  "data": {"path": "/aa/aaa"}
                }
              ]
            }
          ]
        }));
  });
}

class _A {
  @override
  toString() {
    return "a";
  }
}
