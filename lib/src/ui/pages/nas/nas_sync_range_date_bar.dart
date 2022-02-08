import 'package:flutter/material.dart';

class NasSyncRangeDateBar extends StatefulWidget {
  //now -> date input field format datetime to only date
  final DateTime selectedDateFrom;
  final DateTime selectedDateTo; //date up to now including time
  final ValueChanged<DateTime>? onDateFromSaved;
  final ValueChanged<DateTime>? onDateToSaved;

  NasSyncRangeDateBar(
      {Key? key,
      DateTime? dateFrom,
      DateTime? dateTo,
      this.onDateFromSaved,
      this.onDateToSaved})
      : selectedDateFrom = DateUtils.dateOnly(dateFrom ?? DateTime.now()),
        selectedDateTo = dateTo ?? DateTime.now(),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _NasSyncRangeDateBarState();
}

class _NasSyncRangeDateBarState extends State<NasSyncRangeDateBar> {
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
            initialDate: widget.selectedDateFrom,
            onDateSaved: widget.onDateFromSaved,
            onDateSubmitted: widget.onDateFromSaved,
          ),
        ),
        Expanded(
          child: InputDatePickerFormField(
            firstDate: DateTime(2000, 01),
            lastDate: DateTime.now(),
            fieldHintText: 'date to',
            fieldLabelText: 'Date to',
            initialDate: widget.selectedDateTo,
            onDateSaved: widget.onDateToSaved,
            onDateSubmitted: widget.onDateToSaved,
          ),
        ),
      ],
    );
  }
}
