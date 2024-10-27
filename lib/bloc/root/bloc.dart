part of 'root.dart';

class Bloc extends flutter_bloc.Bloc<Event, State> {
  Graph get _initialGraph {
    final random = Random();

    Graph graph = Graph();

    final initialCharacterCode = 'a'.codeUnitAt(0);

    graph = graph
        .addVertices(
          List<String>.generate(
            7,
            (final index) => String.fromCharCode(initialCharacterCode + index),
          ),
        )
        .$1;

    final nodes = graph.nodes;

    (Node, Node, int) edge(final String from, final String to) => (
          nodes.firstWhere((final node) => node.name == from),
          nodes.firstWhere((final node) => node.name == to),
          random.nextInt(19) + 1
        );

    graph = graph.createEdges([
      edge('a', 'b'),
      edge('a', 'c'),
      edge('a', 'd'),
      edge('a', 'f'),
      edge('b', 'd'),
      edge('b', 'e'),
      edge('b', 'g'),
      edge('c', 'f'),
      edge('d', 'g'),
      edge('d', 'f'),
      edge('e', 'g'),
      edge('f', 'g'),
    ]).$1;

    return graph;
  }

  Bloc() : super(const State()) {
    on<Startup>((final event, final emit) {});
    on<RunAlgorithm>((final event, final emit) {
      final List<Graph> steps = [];
      final random = Random();

      final initialGraph = _initialGraph;

      steps.add(initialGraph);

      final initialVertex =
          initialGraph.nodes[random.nextInt(initialGraph.nodes.length)];

      Graph currentGraph = Graph();

      steps.add(currentGraph);

      currentGraph = currentGraph.addVertex(initialVertex);

      steps.add(currentGraph);

      while (!currentGraph.nodes.lengthCompare(initialGraph.nodes)) {
        final edges = initialGraph.edges
            .where((final edge) => !currentGraph.edges.contains(edge))
            .where(
              (final edge) => currentGraph.nodes.any(
                (final node) =>
                    edge.isConnectedTo(node) &&
                    !currentGraph.nodes.contains(edge.getOtherNode(node)),
              ),
            );

        final minimumWeightEdge = minBy(edges, (final edge) => edge.weight)!;

        currentGraph = currentGraph
            .addVertex(
              currentGraph.nodes.contains(minimumWeightEdge.vertices.$1)
                  ? minimumWeightEdge.vertices.$2
                  : minimumWeightEdge.vertices.$1,
            )
            .addEdge(minimumWeightEdge);

        steps.add(currentGraph);
      }

      emit(
        state.copyWith(
          currentStepIndex: () => 0,
          steps: () => steps.lock,
        ),
      );
    });
    on<ChangeCurrentStep>(
      (final event, final emit) =>
          emit(state.copyWith(currentStepIndex: () => event.index)),
    );
  }
}
