import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Math;
import Toybox.FitContributor;


class AppView extends WatchUi.SimpleDataField {
	const SOLAR_FIELD_ID = 0;
	const SOLAR_AVG_FIELD_ID = 1;

	hidden var solar_field;
	hidden var solar_avg_field;

	hidden var solar_avg;
	hidden var solar_avg_count;
	hidden var solar_last;

	
    function initialize() {
		SimpleDataField.initialize();
		label = "SOLAR";

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

		solar_last = -1;
	}

	
    function onTimerReset() {
		solar_avg = 0;
		solar_avg_count = 0;
	}

	
    function compute_avg(info as Activity.Info, val as Numeric or Duration or String or Null) {
		if (info.timerState != Activity.TIMER_STATE_ON) {
			return;
		}

		solar_avg_count++;
		solar_avg += val;
		solar_avg_field.setData(Math.round(solar_avg.toFloat() / solar_avg_count));
	}

	
    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
		var stats = System.getSystemStats();
		var solar = stats.solarIntensity;
		if (solar == null) {
			return "---";
		} else if (solar < 0) {
			solar = 0;
		}

		if (solar != solar_last) {
			solar_field.setData(solar);
			solar_last = solar;
		}
        
		compute_avg(info, solar);

		return solar;
	}
}