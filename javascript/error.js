var error = 
{
	// **************************************  Clicking/tapping events
	buttonTimer: null,
	sendTemperatureTimer: null,
	initErrorPage: function() 
	{
		error.bindButtonEvents();
	},
	bindButtonEvents: function()
	{
		var strContainerElm = '.container[data-type="error"]';
		var eventStr = helpers.is_touch_device() ? 'touchend' : 'click';
		$('.button',strContainerElm).bind(eventStr,error.handleButtonClicked);
	},
	handleButtonClicked: function(event)
	{
		event.preventDefault();
		event.stopPropagation();
		
		var elm = $(this);

		if(elm.hasClass('armed') || elm.attr('data-disable-arming'))
		{
			//First clear the timer — we'll manually clear the arming
			clearTimeout(error.buttonTimer);

			//console.log(elm.data('type'));

			//Button-dependant code
			switch(elm.data('type'))
			{
				case "master-reset":
					error.MasterReset();
					break;
			}
			
			if(!(elm.attr('data-disable-arming')=="true"))
			{
				//Remove arming
				ui.disarmAll('error');
			}
		}
		else
		{
			//Remove any other arming
			ui.disarmAll('error');

			//Arm this
			elm.addClass('armed');

			//Reset and add new timer for disarming
			clearTimeout(error.buttonTimer);
			error.buttonTimer = setTimeout("ui.disarmAll('error');",3000);
		}
	},
	// **************************************  END: Clicking/tapping events	
	MasterReset: function()
	{
		var dataObj = {"Action":InterfaceComActions.MasterReset};
		$.ajax({
		    type: Methods.Test,
		    url: EndPoints.Test.MasterReset,
		    data: {"data":JSON.stringify(dataObj)}
		});
	}
}