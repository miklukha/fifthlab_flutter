import 'package:flutter/material.dart';

// дані збитків
class LossesData {
  final double lossesEmergencyDowntime;
  final double lossesPlannedDowntime;

  LossesData({
    this.lossesEmergencyDowntime = 0.0,
    this.lossesPlannedDowntime = 0.0,
  });

  LossesData copyWith({
    double? lossesEmergencyDowntime,
    double? lossesPlannedDowntime,
  }) {
    return LossesData(
      lossesEmergencyDowntime:
          lossesEmergencyDowntime ?? this.lossesEmergencyDowntime,
      lossesPlannedDowntime:
          lossesPlannedDowntime ?? this.lossesPlannedDowntime,
    );
  }
}

// результати розрахунків
class CalculationResults {
  final double mathExpectationLosses;

  CalculationResults({
    this.mathExpectationLosses = 0.0,
  });
}

class Calculator2Screen extends StatefulWidget {
  const Calculator2Screen({super.key});

  @override
  State<Calculator2Screen> createState() => _Calculator2ScreenState();
}

class _Calculator2ScreenState extends State<Calculator2Screen> {
  LossesData data = LossesData();
  CalculationResults? results;

  void updateData(String field, double value) {
    setState(() {
      switch (field) {
        case 'lossesEmergencyDowntime':
          data = data.copyWith(lossesEmergencyDowntime: value);
          break;
        case 'lossesPlannedDowntime':
          data = data.copyWith(lossesPlannedDowntime: value);
          break;
      }
    });
  }

  CalculationResults calculateResults(LossesData data) {
    // частота відмов
    const failureRate = 0.01;
    // середній час відновлення трансформатора напругою 35 кВ
    const recoveryTimeT = 45 * 0.001;
    // середній час планового простою трансформатора напругою 35 кВ
    const averageTime = 4 * 0.001;
    const pm = 5.12 * 1000;
    const tm = 6451;

    // математичне сподівання аварійного недовідпущення електроенергії
    final mathExpectationEmergency = failureRate * recoveryTimeT * pm * tm;

    // математичне сподівання планового недовідпущення електроенергії
    final mathExpectationPlanned = averageTime * pm * tm;

    // математичне сподівання збитків від переривання електропостачання
    final mathExpectationLosses =
        data.lossesEmergencyDowntime * mathExpectationEmergency +
            data.lossesPlannedDowntime * mathExpectationPlanned;

    return CalculationResults(
      mathExpectationLosses: mathExpectationLosses,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Калькулятор рахування збитків від перерв електропостачання',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                InputField(
                  label: 'Збитки (аварійні вимкнення)',
                  value: data.lossesEmergencyDowntime,
                  onChanged: (value) =>
                      updateData('lossesEmergencyDowntime', value),
                ),
                InputField(
                  label: 'Збитки (планові вимкнення)',
                  value: data.lossesPlannedDowntime,
                  onChanged: (value) =>
                      updateData('lossesPlannedDowntime', value),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[400],
                    ),
                    onPressed: () {
                      setState(() {
                        results = calculateResults(data);
                      });
                    },
                    child: const Text(
                      'Розрахувати',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.purple[400]!),
                    ),
                    child: Text(
                      'Повернутися',
                      style: TextStyle(
                        color: Colors.purple[400],
                      ),
                    ),
                  ),
                ),
                if (results != null) ResultsDisplay(results: results!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InputField extends StatefulWidget {
  final String label;
  final double value;
  final Function(double) onChanged;

  const InputField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  _InputFieldState createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value == 0.0 ? '' : widget.value.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant InputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      final selection = _controller.selection;
      _controller.text = widget.value == 0.0 ? '' : widget.value.toString();
      _controller.selection = selection;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: widget.label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          if (value.isEmpty) {
            widget.onChanged(0.0);
            return;
          }
          final number = double.tryParse(value);
          if (number != null) {
            widget.onChanged(number);
          }
        },
      ),
    );
  }
}

class ResultsDisplay extends StatelessWidget {
  final CalculationResults results;

  const ResultsDisplay({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Результати розрахунків:',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          // Додано SingleChildScrollView
          child: ResultSection(
            title: 'Результати:',
            items: {
              'Математичне сподівання збитків\nвід переривання електропостачання:':
                  ResultValue(results.mathExpectationLosses, ''),
            },
          ),
        ),
      ],
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const SizedBox(height: 16),
  //       Text(
  //         'Результати розрахунків:',
  //         style: Theme.of(context).textTheme.titleLarge,
  //       ),
  //       const SizedBox(height: 8),
  //       ResultSection(
  //         title: 'Результати:',
  //         items: {
  //           'Математичне сподівання збитків\nвід переривання електропостачання:':
  //               ResultValue(results.mathExpectationLosses, ''),
  //         },
  //       ),
  //     ],
  //   );
  // }
}

class ResultValue {
  final double value;
  final String? unit;

  const ResultValue(this.value, [this.unit]);
}

class ResultSection extends StatelessWidget {
  final String title;
  final Map<String, ResultValue> items;

  const ResultSection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Додано SingleChildScrollView
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          ...items.entries.map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(entry.key)), // Додано Expanded
                    Text(
                      '${entry.value.value.toStringAsFixed(4)} ${entry.value.unit}',
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
