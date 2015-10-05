var manual = 
{
	handleData: function(JSONObject)
	{
		var strContainerElm = '.container[data-type="roasting-manually"]';
		if(JSONObject.CurrentTemp)
		{
			$('.element[data-type="current-temperature"] .datacontainer',strContainerElm).html(JSONObject.CurrentTemp.toFixed(1).toString().replace('.',',')+' &deg;C');
		}
		if(JSONObject.ElapsedTime)
		{
			manual.updateElapsed(JSONObject.ElapsedTime);
		}
		if(JSONObject.ManualTargetTemp)
		{
			manual.updateManualTargetTemperature(JSONObject.ManualTargetTemp);
		}
	},
	updateManualTargetTemperature: function(temperature)
	{
			var strContainerElm = '.container[data-type="roasting-manually"]';
			$('.element[data-type="target-temperature"] .datacontainer',strContainerElm).html(temperature.toString().replace('.',',')+' &deg;C');
			$('.element[data-type="target-temperature"] span',strContainerElm).html(temperature);
	},
	updateElapsed: function(elapsedSeconds)
	{
		var strContainerElm = '.container[data-type="roasting-manually"]';
		$('.element[data-type="elapsed-time"] .datacontainer',strContainerElm).html(helpers.formatSecondsToMinutes(elapsedSeconds));
	},
	getLatestTargetTemp: function()
	{
		var strContainerElm = '.container[data-type="roasting-manually"]';
		var elmHTML = $('.element[data-type="target-temperature"] span',strContainerElm).html();
		return elmHTML ? parseInt(elmHTML) : 0;
	},
	modifyInterfaceTargetTemperature: function(modifyValue)
	{
		var latestTemp = manual.getLatestTargetTemp();
		var newTemp = latestTemp + modifyValue;
		if(newTemp >= 0)
		{
			clearTimeout(common.statusTimer);
			common.statusTimer = setTimeout(common.handleStatusTick,common.statusCallInterval);
			manual.updateManualTargetTemperature(newTemp);

			clearTimeout(manual.sendTemperatureTimer);
			manual.sendTemperatureTimer = setTimeout("manual.sendTargetTemperature("+newTemp+");",400);
		}
	},
	sendTargetTemperature:function(temperatureToSend)
	{
		var dataObj = {"Action":InterfaceComActions.SetManualRoastTemperature,"ManualTargetTemp":temperatureToSend};
		$.ajax({
		    type: Methods.Test,
		    url: EndPoints.Test.SetManualRoastTemperature,
		    data: {"data":JSON.stringify(dataObj)}
		});
	},




	// **************************************  Clicking/tapping events
	buttonTimer: null,
	sendTemperatureTimer: null,
	initManualPage: function() 
	{
		manual.bindButtonEventsManual();
	},
	bindButtonEventsManual: function()
	{
		var strContainerElm = '.container[data-type="roasting-manually"]';
		var eventStr = helpers.is_touch_device() ? 'touchend' : 'click';
		$('.button',strContainerElm).bind(eventStr,manual.handleButtonClicked);
	},
	handleButtonClicked: function(event)
	{
		event.preventDefault();
		event.stopPropagation();
		
		var elm = $(this);

		if(elm.hasClass('armed') || elm.attr('data-disable-arming'))
		{
			//First clear the timer — we'll manually clear the arming
			clearTimeout(manual.buttonTimer);

			//console.log(elm.data('type'));

			//Button-dependant code
			switch(elm.data('type'))
			{
				case "temperature-decrease":
					var amount = $(this).data('amount');
					manual.modifyInterfaceTargetTemperature(amount);
					elm.addClass('armed');
					setTimeout("ui.disarmAll('roasting-manually');",100);
					break;
				case "temperature-increase":
					var amount = $(this).data('amount');
					manual.modifyInterfaceTargetTemperature(amount);
					elm.addClass('armed');
					setTimeout("ui.disarmAll('roasting-manually');",100);
					break;
				case "end-roast":
					helpers.switchToStatus(RoastStatus.EndRoast);
					break;
			}
			
			if(!(elm.attr('data-disable-arming')=="true"))
			{
				//Remove arming
				ui.disarmAll('roasting-manually');
			}
		}
		else
		{
			//Remove any other arming
			ui.disarmAll('roasting-manually');

			//Arm this
			elm.addClass('armed');

			//Reset and add new timer for disarming
			clearTimeout(manual.buttonTimer);
			manual.buttonTimer = setTimeout("ui.disarmAll('roasting-manually');",3000);
		}
	}
	// **************************************  END: Clicking/tapping events	
}