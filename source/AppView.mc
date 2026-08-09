import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Math;
import Toybox.FitContributor;


class AppView extends WatchUi.SimpleDataField {
	const BATTERY_FIELD_ID = 0;
	const SOLAR_FIELD_ID = 1;
	const SOLAR_AVG_FIELD_ID = 2;

	hidden var has_battery;
	hidden var has_solar;

	hidden var battery_field;
	hidden var solar_field;
	hidden var solar_avg_field;

	hidden var solar_avg;
	hidden var solar_avg_count;

	hidden var battery_last;
	hidden var solar_last;

	
    function initialize() {
		SimpleDataField.initialize();
		label = "SOLAR";

		battery_field = createField(
				"battery",
				BATTERY_FIELD_ID,
				FitContributor.DATA_TYPE_UINT8,
				{:mesgType=>FitContributor.MESG_TYPE_RECORD, :units=>"%"});

		solar_field = createField(
				"solar",
				SOLAR_FIELD_ID,
				FitContributor.DATA_TYPE_UINT8,
				{:mesgType=>FitContributor.MESG_TYPE_RECORD, :units=>"%"});

		solar_avg_field = createField(
				"solar_avg",
				SOLAR_AVG_FIELD_ID,
				FitContributor.DATA_TYPE_UINT8,
				{:mesgType=>FitContributor.MESG_TYPE_SESSION, :units=>"%"});

		solar_avg = 0;
		solar_avg_count = 0;

		battery_last = -1;
		solar_last = -1;

		var stats = System.getSystemStats();
		has_battery = stats has :battery;
		has_solar = stats has :solarIntensity;
	}

	
    function onTimerReset() {
		solar_avg = 0;
		solar_avg_count = 0;
	}


	function save_battery(battery_current as Numeric or Null) {
		if (battery_current != null && battery_current != battery_last) {
			battery_field.setData(battery_current);
			battery_last = battery_current;
		}
	}


	function save_solar(solar as Numeric or String or Null) {
		if (solar != solar_last) {
			solar_field.setData(solar);
			solar_last = solar;
		}
	}

	
    function save_solar_avg(info as Activity.Info, val as Numeric or Duration or String or Null) {
		if (info.timerState != Activity.TIMER_STATE_ON) {
			return;
		}

		solar_avg_count++;
		solar_avg += val;
		solar_avg_field.setData(Math.round(solar_avg.toFloat() / solar_avg_count));
	}

	
    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
		var stats = System.getSystemStats();
		var battery = has_battery ? stats.battery.toNumber() : null;
		var solar = has_solar ? stats.solarIntensity.toNumber() : null;

		if (solar == null) {
			return "---";
		} else if (solar < 0) {
			solar = 0;
		}

		save_battery(battery);
		save_solar(solar);
		save_solar_avg(info, solar);

		return solar;
	}
}