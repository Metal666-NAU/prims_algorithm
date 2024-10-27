part of 'root.dart';

class State {
  final IList<Graph>? steps;
  final int currentStepIndex;

  const State({
    this.steps,
    this.currentStepIndex = 0,
  });

  State copyWith({
    final IList<Graph>? Function()? steps,
    final int Function()? currentStepIndex,
  }) =>
      State(
        steps: steps == null ? this.steps : steps.call(),
        currentStepIndex: currentStepIndex == null
            ? this.currentStepIndex
            : currentStepIndex.call(),
      );
}
