import 'package:flutter/material.dart';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_force_directed_graph/flutter_force_directed_graph.dart';

import '../bloc/root/root.dart' as root;
import '../data/graph.dart' as graph;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(final context) => _pageRoot(
        _runAlgorithmPanel,
        _runBreakdownPanel,
      );

  Widget _pageRoot(
    final Widget Function(BuildContext) runAlgorithmPanel,
    final Widget Function(
      BuildContext,
      graph.Graph,
      List<graph.Graph>,
    ) runBreakdownPanel,
  ) =>
      Scaffold(
        body: BlocBuilder<root.Bloc, root.State>(
          buildWhen: (final previous, final current) =>
              previous.steps != current.steps,
          builder: (final context, final state) {
            final steps = state.steps?.unlock;

            return steps == null
                ? runAlgorithmPanel(context)
                : runBreakdownPanel(
                    context,
                    steps.first,
                    steps.skip(1).followedBy([steps.last]).toList(),
                  );
          },
        ),
      );

  Widget _runAlgorithmPanel(final BuildContext context) => Center(
        child: FilledButton(
          onPressed: () =>
              context.read<root.Bloc>().add(const root.RunAlgorithm()),
          child: const Text('Run algorithm'),
        ),
      );

  Widget _runBreakdownPanel(
    final BuildContext context,
    final graph.Graph initialGraph,
    final List<graph.Graph> steps,
  ) {
    final fdGraph = ForceDirectedGraph<graph.Node>(
      config: const GraphConfig(
        length: 20,
        repulsion: 200,
        repulsionRange: 300,
        damping: 0.95,
      ),
    );

    final nodeMap = {
      for (final node in initialGraph.nodes) node: Node<graph.Node>(node),
    };

    nodeMap.values.forEach(fdGraph.addNode);

    for (final edge in initialGraph.edges) {
      fdGraph.addEdge(
        Edge(nodeMap[edge.vertices.$1]!, nodeMap[edge.vertices.$2]!),
      );
    }

    final forceDirectedGraphController =
        ForceDirectedGraphController(graph: fdGraph);

    WidgetsBinding.instance.addPostFrameCallback(
      (final timeStamp) => forceDirectedGraphController.center(),
    );

    final theme = Theme.of(context);

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    children: [
                      Expanded(
                        child: ForceDirectedGraphWidget(
                          controller: forceDirectedGraphController,
                          nodesBuilder: (final context, final node) =>
                              BlocBuilder<root.Bloc, root.State>(
                            buildWhen: (final previous, final current) =>
                                previous.currentStepIndex !=
                                current.currentStepIndex,
                            builder: (final context, final state) {
                              final currentStep = steps[state.currentStepIndex];
                              final previousStep =
                                  steps.getOrNull(state.currentStepIndex - 1);

                              final isInCurrentStep =
                                  currentStep.nodes.contains(node);
                              final isInPreviousStep =
                                  previousStep?.nodes.contains(node) ?? true;

                              final accentColor =
                                  isInCurrentStep && !isInPreviousStep
                                      ? theme.colorScheme.secondary
                                      : theme.colorScheme.primary;

                              return Container(
                                width: 100,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: accentColor.withAlpha(
                                    isInCurrentStep ? 255 : 127,
                                  ),
                                ),
                                child: Text(
                                  node.name,
                                  style:
                                      theme.textTheme.headlineMedium?.copyWith(
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ),
                              );
                            },
                          ),
                          edgesBuilder: (
                            final context,
                            final a,
                            final b,
                            final distance,
                          ) =>
                              BlocBuilder<root.Bloc, root.State>(
                            buildWhen: (final previous, final current) =>
                                previous.currentStepIndex !=
                                current.currentStepIndex,
                            builder: (final context, final state) {
                              final currentStep = steps[state.currentStepIndex];

                              final previousStep =
                                  steps.getOrNull(state.currentStepIndex - 1);

                              final edge = initialGraph.getEdge(a, b);

                              final isInCurrentStep =
                                  currentStep.edges.contains(edge);
                              final isInPreviousStep =
                                  previousStep?.edges.contains(edge) ?? true;

                              final accentColor =
                                  isInCurrentStep && !isInPreviousStep
                                      ? theme.colorScheme.secondary
                                      : theme.colorScheme.primary;

                              return Stack(
                                alignment: Alignment.center,
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: distance,
                                    height: 4,
                                    color: accentColor.withAlpha(
                                      currentStep.edges.contains(edge)
                                          ? 127
                                          : 63,
                                    ),
                                  ),
                                  SizedBox(
                                    width: distance,
                                    child: Center(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 30),
                                        child: Text(
                                          '${edge.weight}',
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      Center(
                        child: BlocBuilder<root.Bloc, root.State>(
                          buildWhen: (final previous, final current) =>
                              previous.currentStepIndex !=
                              current.currentStepIndex,
                          builder: (final context, final state) {
                            final currentStep = steps[state.currentStepIndex];

                            final weights = currentStep.edges
                                .map((final edge) => edge.weight)
                                .toList();

                            final totalWeight = weights.fold(
                              0,
                              (final weight1, final weight2) =>
                                  weight1 + weight2,
                            );

                            return Text(
                              'Tree weight: ${weights.isEmpty ? '0' : '${weights.join(' + ')} = $totalWeight'}',
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 6),
                    child: Text(
                      'Select step:',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22)
                              .copyWith(top: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                              steps.length,
                              (final index) => Text('$index'),
                            ),
                          ),
                        ),
                        BlocBuilder<root.Bloc, root.State>(
                          buildWhen: (final previous, final current) =>
                              previous.currentStepIndex !=
                              current.currentStepIndex,
                          builder: (final context, final state) => Slider(
                            value: state.currentStepIndex.toDouble(),
                            min: 0,
                            max: steps.length.toDouble() - 1,
                            divisions: steps.length - 1,
                            onChanged: (final value) => context
                                .read<root.Bloc>()
                                .add(root.ChangeCurrentStep(value.round())),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      context.read<root.Bloc>().add(const root.RunAlgorithm()),
                  child: const Text('Re-run'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
