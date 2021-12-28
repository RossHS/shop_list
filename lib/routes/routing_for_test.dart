import 'package:flutter/material.dart';
import 'package:rive/rive.dart';import 'package:flutter/services.dart';

class RoutingForTest extends StatelessWidget {
  const RoutingForTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StateMachineSkills();
  }
}

class _Body extends StatefulWidget {
  const _Body({Key? key}) : super(key: key);

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  /// Controller for playback
  late RiveAnimationController _controller;

  /// Is the animation currently playing?
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = StateMachineController(
      StateMachine(),
      onStateChange: (st1, st2) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 600,
          height: 600,
          child: RiveAnimation.asset(
            'assets/rive/skills_demo.riv',
            stateMachines: const ['Beginner', 'Intermediate', 'Expert'],
            controllers: [_controller],
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _controller.isActive = true;
          },
          child: const Text('ANIMATION'),
        ),
      ],
    );
  }
}

class SimpleStateMachine extends StatefulWidget {
  const SimpleStateMachine({Key? key}) : super(key: key);

  @override
  _SimpleStateMachineState createState() => _SimpleStateMachineState();
}

class _SimpleStateMachineState extends State<SimpleStateMachine> {
  SMITrigger? _bump;

  void _onRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(artboard, 'bumpy');
    artboard.addController(controller!);
    _bump = controller.findInput<bool>('bump') as SMITrigger;
  }

  void _hitBump() => _bump?.fire();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Animation'),
      ),
      body: Center(
        child: GestureDetector(
          child: RiveAnimation.network(
            'https://cdn.rive.app/animations/vehicles.riv',
            fit: BoxFit.cover,
            onInit: _onRiveInit,
          ),
          onTap: _hitBump,
        ),
      ),
    );
  }
}

/// An example showing how to drive a StateMachine via one numeric input.
class StateMachineSkills extends StatefulWidget {
  const StateMachineSkills({Key? key}) : super(key: key);

  @override
  _StateMachineSkillsState createState() => _StateMachineSkillsState();
}

class _StateMachineSkillsState extends State<StateMachineSkills> {
  /// Tracks if the animation is playing by whether controller is running.
  bool get isPlaying => _controller?.isActive ?? false;

  Artboard? _riveArtboard;
  StateMachineController? _controller;
  SMIInput<double>? _levelInput;

  @override
  void initState() {
    super.initState();

    // Load the animation file from the bundle, note that you could also
    // download this. The RiveFile just expects a list of bytes.
    rootBundle.load('assets/rive/themeselector.riv').then(
          (data) async {
        // Load the RiveFile from the binary data.
        final file = RiveFile.import(data);

        // The artboard is the root of the animation and gets drawn in the
        // Rive widget.
        final artboard = file.mainArtboard;
        var controller =
        StateMachineController.fromArtboard(artboard, 'State machine');
        if (controller != null) {
          artboard.addController(controller);
          _levelInput = controller.findInput('state');
        }
        setState(() => _riveArtboard = artboard);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text('Skills Machine'),
      ),
      body: Center(
        child: _riveArtboard == null
            ? const SizedBox()
            : Stack(
          children: [
            Positioned.fill(
              child: Rive(
                artboard: _riveArtboard!,
              ),
            ),
            Positioned.fill(
              bottom: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton(
                    child: const Text('IDLE 0'),
                    onPressed: () => _levelInput?.value = 0,
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    child: const Text('IDLE 1'),
                    onPressed: () => _levelInput?.value = 1,
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    child: const Text('IDLE 2'),
                    onPressed: () => _levelInput?.value = 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
