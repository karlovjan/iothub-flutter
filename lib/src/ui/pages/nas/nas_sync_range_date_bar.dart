import 'package:flutter/material.dart';

class NasSyncRangeDateBar extends StatelessWidget {
  //TODO mam to predelat na Stateful widget?
  //now -> date input field format datetime to only date
  DateTime _selectedDateFrom;
  DateTime _selectedDateTo; //date up to now including time

  NasSyncRangeDateBar({Key? key, DateTime? dateFrom, DateTime? dateTo})
      : _selectedDateFrom = DateUtils.dateOnly(dateFrom ?? DateTime.now()),
        _selectedDateTo = dateTo ?? DateTime.now(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InputDatePickerFormField(
            firstDate: DateTime(2000, 01),
            lastDate: DateTime.now(),
            fieldHintText: 'date from',
            fieldLabelText: 'Date from',
            initialDate: _selectedDateFrom,
            onDateSaved: (value) => _selectedDateFrom = value,
          ),
        ),
        Expanded(
          child: InputDatePickerFormField(
            firstDate: DateTime(2000, 01),
            lastDate: DateTime.now(),
            fieldHintText: 'date to',
            fieldLabelText: 'Date to',
            initialDate: _selectedDateTo,
            onDateSaved: (value) => _selectedDateTo = value,
          ),
        ),
      ],
    );
  }

  DateTime get dateFrom => _selectedDateFrom;

  DateTime get dateTo => _selectedDateTo;
}
