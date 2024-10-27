part of 'root.dart';

abstract class Event {
  const Event();
}

class Startup extends Event {
  const Startup();
}

class RunAlgorithm extends Event {
  const RunAlgorithm();
}

class ChangeCurrentStep extends Event {
  final int index;

  const ChangeCurrentStep(this.index);
}
