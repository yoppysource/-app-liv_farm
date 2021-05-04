import 'package:flutter/material.dart';
import 'time_of_day_extension.dart';

enum DeliveryDefaultCase {
  isPossibleToBuyNow,
  tomorrowOpenHour,
  mondayOpenHour,
}

class DeliveryReservationCaluator {
  final DateTime now;
  final bool isOpenSaturday;
  final bool isOpenSunday;
  final bool isOpenToday;
  final String openHourStr;
  final String closeHourStr;

  DeliveryReservationCaluator(this.now, this.isOpenSaturday, this.isOpenSunday,
      this.isOpenToday, this.openHourStr, this.closeHourStr);

  Map<DateTime, List<TimeOfDay>> getDateTimePairedWithTimeOfDayList() {
    Map<DateTime, List<TimeOfDay>> dateTimePairedWithTimeOfDayList = {};
    if (isPossibleToBuyNow(this.now)) {
      TimeOfDay startTime =
          TimeOfDay(hour: now.hour + 1, minute: now.minute >= 30 ? 30 : 0);
      dateTimePairedWithTimeOfDayList[now] = [startTime, closeHour];
    } else if (TimeOfDay.fromDateTime(this.now).before(openHour) &&
        isOpenDay(this.now)) {
      dateTimePairedWithTimeOfDayList[now] = [openHour, closeHour];
    } else {
      dateTimePairedWithTimeOfDayList[getNextDateBySkippingHolidays(this.now)] =
          [openHour, closeHour];
    }
    DateTime secondDate = getNextDateBySkippingHolidays(
        dateTimePairedWithTimeOfDayList.keys.first);
    dateTimePairedWithTimeOfDayList[secondDate] = [openHour, closeHour];
    dateTimePairedWithTimeOfDayList[getNextDateBySkippingHolidays(secondDate)] =
        [openHour, closeHour];

    return dateTimePairedWithTimeOfDayList;
  }

  TimeOfDay get openHour => TimeOfDay(
      hour: int.parse(openHourStr.split(':')[0]),
      minute: int.parse(openHourStr.split(':')[1]));
  TimeOfDay get closeHour => TimeOfDay(
      hour: int.parse(closeHourStr.split(':')[0]),
      minute: int.parse(closeHourStr.split(':')[1]));

  DateTime getNextDateBySkippingHolidays(DateTime now) {
    final tomorrow = now.add(Duration(days: 1));
    if (tomorrow.weekday == 6 && isOpenSaturday == false)
      return getNextDateBySkippingHolidays(tomorrow);
    if (tomorrow.weekday == 7 && isOpenSunday == false)
      return getNextDateBySkippingHolidays(tomorrow);
    return tomorrow;
  }

  bool isOpenDay(DateTime now) {
    if (!isOpenToday) return false;
    if (now.weekday == 6 && isOpenSaturday == false) return false;
    if (now.weekday == 7 && isOpenSunday == false) return false;
    return true;
  }

  bool isPossibleToBuyNow(DateTime now) {
    if (!isOpenToday) return false;
    if (now.weekday == 6 && isOpenSaturday == false) return false;
    if (now.weekday == 7 && isOpenSunday == false) return false;
    TimeOfDay nowTimeOfDay = TimeOfDay(hour: now.hour, minute: now.minute);
    return (nowTimeOfDay.after(this.openHour) &&
        nowTimeOfDay.before(this.closeHour));
  }
}