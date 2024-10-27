import 'package:fast_immutable_collections/fast_immutable_collections.dart';

class Graph {
  final IList<Node> nodes;
  final IList<Edge> edges;

  Graph({
    final IList<Node>? nodes,
    final IList<Edge>? edges,
  })  : nodes = nodes ?? const <Node>[].lock,
        edges = edges ?? const <Edge>[].lock;

  (Graph, Node) createVertex(final String name) {
    final newNode = Node(name: name);

    return (
      copyWith(nodes: () => nodes.add(newNode)),
      newNode,
    );
  }

  Graph addVertex(final Node node) => copyWith(
        nodes: () => nodes.add(node),
      );

  Graph removeVertex(final Node node) => copyWith(
        nodes: () => nodes.remove(node),
        edges: () => edges
            .whereNot(
              (final edge) => edge.isConnectedTo(node),
            )
            .toIList(),
      );

  (Graph, Iterable<Node>) addVertices(final List<String> names) {
    final newNodes = nodes.addAll(names.map((final name) => Node(name: name)));

    return (
      copyWith(nodes: () => newNodes.toIList()),
      newNodes,
    );
  }

  (Graph, Edge) createEdge(
    final Node from,
    final Node to,
    final int weight,
  ) {
    final newEdge = Edge(
      vertices: (from, to),
      weight: weight,
    );

    return (
      copyWith(
        edges: () => edges.add(newEdge),
      ),
      newEdge
    );
  }

  Graph addEdge(final Edge edge) => copyWith(
        edges: () => edges.add(edge),
      );

  (Graph, Iterable<Edge>) createEdges(
    final List<(Node from, Node to, int weight)> edges,
  ) {
    final newEdges = edges.map(
      (final edge) => Edge(vertices: (edge.$1, edge.$2), weight: edge.$3),
    );

    return (
      copyWith(
        edges: () => this.edges.addAll(newEdges),
      ),
      newEdges
    );
  }

  Graph removeEdge(final Edge edge) =>
      copyWith(edges: () => edges.remove(edge));

  Graph removeEdges(final List<Edge> edges) =>
      copyWith(edges: () => this.edges.removeAll(edges));

  Edge getEdge(final Node a, final Node b) => edges.firstWhere(
        (final edge) => edge.isConnectedTo(a) && edge.isConnectedTo(b),
      );

  Graph copyWith({
    final IList<Node> Function()? nodes,
    final IList<Edge> Function()? edges,
  }) =>
      Graph(
        nodes: nodes == null ? this.nodes : nodes(),
        edges: edges == null ? this.edges : edges(),
      );
}

class Node {
  final String name;

  const Node({required this.name});
}

class Edge {
  final (Node, Node) vertices;
  final int weight;

  const Edge({
    required this.vertices,
    required this.weight,
  });

  Node getOtherNode(final Node node) =>
      vertices.$1 == node ? vertices.$2 : vertices.$1;

  bool isConnectedTo(final Node node) =>
      vertices.$1 == node || vertices.$2 == node;
}
