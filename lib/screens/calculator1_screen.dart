import 'package:flutter/material.dart';

// дані систем
class SystemData {
  final int lengthPL110;
  final int connectionN;

  SystemData({
    this.lengthPL110 = 0,
    this.connectionN = 0,
  });

  SystemData copyWith({
    int? lengthPL110,
    int? connectionN,
  }) {
    return SystemData(
      lengthPL110: lengthPL110 ?? this.lengthPL110,
      connectionN: connectionN ?? this.connectionN,
    );
  }
}

// результати розрахунків
class CalculationResults {
  final double failureRate;
  final double recoveryTime;
  final double emergencyDowntime;
  final double plannedDowntime;
  final double failureRateBoth;
  final double failureRateWithSection;

  CalculationResults({
    this.failureRate = 0.0,
    this.recoveryTime = 0.0,
    this.emergencyDowntime = 0.0,
    this.plannedDowntime = 0.0,
    this.failureRateBoth = 0.0,
    this.failureRateWithSection = 0.0,
  });
}

class Calculator1Screen extends StatefulWidget {
  const Calculator1Screen({super.key});

  @override
  State<Calculator1Screen> createState() => _Calculator1ScreenState();
}

class _Calculator1ScreenState extends State<Calculator1Screen> {
  SystemData data = SystemData();
  CalculationResults? results;

  void updateData(String field, int value) {
    setState(() {
      switch (field) {
        case 'lengthPL110':
          data = data.copyWith(lengthPL110: value);
        case 'connectionN':
          data = data.copyWith(connectionN: value);
      }
    });
  }

  CalculationResults calculateResults(SystemData data) {
    // частоти відмов
    const failureRateV110 = 0.01; // В-110 кВ (елегазовий)
    const failureRateV10 = 0.02; // В-10 кВ (малооливний)
    const failureRateT110 = 0.015; // Т-110 кВ
    final failureRatePL110 = 0.007 * data.lengthPL110; // ПЛ-110 кВ
    final failureRate10 = 0.03 * data.connectionN; // збірні шини 10кВ

    // тривалості відновлення
    const recoveryTimeV110 = 30.0; // В-110 кВ (елегазовий)
    const recoveryTimeV10 = 15.0; // В-10 кВ (малооливний)
    const recoveryTimeT110 = 100.0; // Т-110 кВ
    const recoveryTimePL110 = 10.0; // ПЛ-110 кВ
    const recoveryTime10 = 2.0; // збірні шини 10кВ

    // найбільше значення коефіцієнта планового простою (в даному випадку для Т-110 кВ)
    const plannedDowntimeMax = 43.0;

    // частота відмов одноколової системи - сума частот відмов одноколової системи
    final failureRate = failureRateV110 +
        failureRateV10 +
        failureRateT110 +
        failureRatePL110 +
        failureRate10;

    // середня тривалість відновлення
    final recoveryTime = (failureRateV110 * recoveryTimeV110 +
            failureRatePL110 * recoveryTimePL110 +
            failureRateT110 * recoveryTimeT110 +
            failureRateV10 * recoveryTimeV10 +
            failureRate10 * recoveryTime10) /
        failureRate;

    // кофіцієнт аварійного простою одноколової системи
    final emergencyDowntime = failureRate * recoveryTime / 8760;

    // кофіцієнт планового простою одноколової системи
    final plannedDowntime = 1.2 * plannedDowntimeMax / 8760;

    // частота відмов одночасно двох кіл двоколової системи
    final failureRateBoth =
        2 * failureRate * (emergencyDowntime + plannedDowntime);

    // частота відмов двоколової системи з урахуванням секційного вимикача
    final failureRateWithSection = failureRateBoth + failureRateV10;

    return CalculationResults(
      failureRate: failureRate,
      recoveryTime: recoveryTime,
      emergencyDowntime: emergencyDowntime,
      plannedDowntime: plannedDowntime,
      failureRateBoth: failureRateBoth,
      failureRateWithSection: failureRateWithSection,
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
                  'Калькулятор порівняння надійності систем електропередачі',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Одноколова система містить: елегазовий вимикач 100 кВ, ПЛ-110 кВ довжиною 10 км, трансформатор 110/10 кВ, ввідний вимикач 10 кВ і 6 приєднань 10 кВ.',
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Двоколова система складається з двох ідентичних одноколових і секційного вимикача 10 кВ.',
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 16),
                InputField(
                  label: 'Довжина ПЛ-110 кВ, км',
                  value: data.lengthPL110,
                  onChanged: (value) => updateData('lengthPL110', value),
                ),
                InputField(
                  label: 'Кількість приєднань 10 кВ',
                  value: data.connectionN,
                  onChanged: (value) => updateData('connectionN', value),
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
  final int value;
  final Function(int) onChanged;

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
      text: widget.value == 0 ? '' : widget.value.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant InputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      final selection = _controller.selection;
      _controller.text = widget.value == 0 ? '' : widget.value.toString();
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
            widget.onChanged(0);
            return;
          }
          final number = int.tryParse(value);
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
        ResultSection(
          title: 'Частота відмов:',
          items: {
            'одноколової системи': ResultValue(results.failureRate, 'рік-1'),
            'одночасно двох кіл \nдвоколової системи':
                ResultValue(results.failureRateBoth, 'рік-1'),
            'двоколової системи з \n(секційний вимикач)':
                ResultValue(results.failureRateWithSection, 'рік-1'),
          },
        ),
        ResultSection(
          title: 'Кофіцієнт простою одноколової системи:',
          items: {
            'аварійного:': ResultValue(results.emergencyDowntime),
            'планового:': ResultValue(results.plannedDowntime),
          },
        ),
        ResultSection(
          title: 'Середня тривалість відновлення:',
          items: {
            '': ResultValue(results.recoveryTime, 'год'),
          },
        ),
      ],
    );
  }
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
    return Column(
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
                  Text(entry.key),
                  Text(
                    '${entry.value.value.toStringAsFixed(4)} ${entry.value.unit ?? ""}',
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
