import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

class TrainingFilterDialog extends StatefulWidget {
  const TrainingFilterDialog(
      {super.key,
      required this.estilo,
      required this.masc,
      required this.fem,
      required this.periodo,
      required this.onConfirm});

  final String estilo;
  final bool masc;
  final bool fem;
  final (DateTime, DateTime) periodo;

  final void Function(
          String estilo, bool masc, bool fem, (DateTime, DateTime) periodo)
      onConfirm;

  @override
  State<TrainingFilterDialog> createState() => _TrainingFilterDialogState();
}

class _TrainingFilterDialogState extends State<TrainingFilterDialog> {
  TextEditingController _estiloController = TextEditingController();
  bool _masc = true;
  bool _fem = true;
  (DateTime min, DateTime max) _dateFilter = (
    DateTime.now().subtract(const Duration(days: 7)),
    DateTime.now().add(const Duration(hours: 1))
  );

  void _updateDateFilter() async {
    List<DateTime>? dateTimeList = await showOmniDateTimeRangePicker(
      context: context,
      is24HourMode: true,
      startInitialDate: _dateFilter.$1,
      endInitialDate: _dateFilter.$2,
    );

    if (dateTimeList != null && dateTimeList.length == 2) {
      setState(() {
        _dateFilter = (dateTimeList.first, dateTimeList.last);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _estiloController.text = widget.estilo;
    _masc = widget.masc;
    _fem = widget.fem;
    _dateFilter = widget.periodo;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Selecione os Filtros"),
      content: Container(
        width: MediaQuery.sizeOf(context).width * 0.9,
        height: MediaQuery.sizeOf(context).height * 0.7,
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(children: [
          const SizedBox(height: 20),
          TextFormField(
            controller: _estiloController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Estilo',
            ),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Checkbox(
                value: _masc,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _masc = value);
                  }
                }),
            const Text("Masculino")
          ]),
          Row(children: [
            Checkbox(
                value: _fem,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _fem = value);
                  }
                }),
            const Text("Feminino")
          ]),
          const SizedBox(height: 20),
          Row(children: [
            Text(
                "${DateFormat("dd/MM/yyyy").format(_dateFilter.$1)} - ${DateFormat("dd/MM/yyyy").format(_dateFilter.$2)}"),
            const SizedBox(width: 10),
            IconButton(
              onPressed: _updateDateFilter,
              icon: const Icon(Icons.edit_rounded),
            ),
          ]),
        ]),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancelar")),
        TextButton(
            onPressed: () {
              widget.onConfirm(
                  _estiloController.text, _masc, _fem, _dateFilter);
              Navigator.of(context).pop();
            },
            child: const Text("Ok")),
      ],
    );
  }
}
