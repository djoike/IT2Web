var common = {
	





	// **************************************  Navigation between functions
	goToFunction: function(strFunctionName)
	{
		if(common.currentFunction != strFunctionName)
		{
			common.clearFunction(strFunctionName); //Clear data values

			$('.container').hide(); //Hide all
			$('.container').data('return-function','');
			common.endLoadingIndication();
			profile.incrementElapsed = false;

			switch(strFunctionName)
			{
				case "ProfileRoastPage":
					$('.container[data-type="roasting-with-profile"]').show();
					break;
				case "ManualRoastPage":
					$('.container[data-type="roasting-manually"]').show();
					break;
				case "EndingRoast":
					common.startLoadingIndication("Ending roast");
					break;
				case "ProfileList":
					common.stopStatusCalls();
					profileList.loadProfiles();
					$('.container[data-type="list-of-profiles"]').data('return-function',common.currentFunction).show();
					break;
				case "ProfileEdit":
					$('.container[data-type="edit-profile"]').show();
					break;					
			}
			common.currentFunction = strFunctionName;
		}
	},
	clearFunction: function(strFunctionName)
	{
		console.log(strFunctionName);
		var baseElement;
		switch(strFunctionName)
		{
			case "ProfileRoastPage":
				baseElement = $('.container[data-type="roasting-with-profile"]');
				break;
			case "ManualRoastPage":
				baseElement = $('.container[data-type="roasting-manually"]');
				break;
			case "EndingRoast":
				baseElement = $('.disable');
				break;
			case "ProfileList":
				baseElement = $('.container[data-type="list-of-profiles"]');
				break;
			case "ProfileEdit":
				baseElement = $('.container[data-type="edit-profile"]');
				break;
		}
		
		baseElement.find('[data-default-value]').each(function()
		{
			var elm = $(this);
			if(elm.is('input'))
			{
				elm.val(elm.data('default-value'));
			}
			else
			{
				elm.html(elm.data('default-value'));
			}
		});
	},
	// **************************************  END: Navigation between functions








	// **************************************  Status handling etc.
	statusTimer: undefined,
	statusTransporter: undefined,
	statusCallInterval: undefined,
	currentFunction: "",

	handleStatusJSON: function(JSONObject)
	{
		common.currentStatus = JSONObject.StatusCode;

		switch(parseInt(JSONObject.StatusCode))
		{
			case RoastStatus.NoCommunicationYet:
			case RoastStatus.RoasterOnlineReady:
			case RoastStatus.LoadProfile:
			case RoastStatus.ProfileLoading:
			case RoastStatus.ProfileLoaded:
			case RoastStatus.StartRoastingWithProfile:
			case RoastStatus.StartingRoastingWithProfile:
			case RoastStatus.RoastingWithProfile:
				common.goToFunction("ProfileRoastPage");
				profile.handleData(JSONObject);
				break;
			case RoastStatus.StartManualRoast:
			case RoastStatus.StartingManualRoast:
			case RoastStatus.RoastingManually:				
				common.goToFunction("ManualRoastPage");
				manual.handleData(JSONObject);
				break;
			case RoastStatus.EndRoast:
			case RoastStatus.EndingRoast:
				common.goToFunction("EndingRoast");
				break;
		}
	},

	initWebinterface: function()
	{
		common.statusCallInterval = statusCodeIntervals.default;
		common.startStatusCalls();
		common.bindEvents();
		profile.initProfile();
		manual.initManualPage();
		profileList.initProfileList();
		profileEdit.initProfileEdit();
	},
	getNewStatus: function()
	{
		function handleStatusSuccess(data)
		{
			var JSONFromData = $.parseJSON(data);
			common.handleStatusJSON(JSONFromData);
		}
		var dataObj = {"Action":InterfaceComActions.GetStatus};
		common.statusTransporter = $.ajax({
		    type: Methods.Test,
		    url: EndPoints.Test.GetStatus,
		    data: {"data":JSON.stringify(dataObj)},
		    success: handleStatusSuccess
		});
	},
	startStatusCalls: function()
	{
		common.handleStatusTick();
	},
	stopStatusCalls: function()
	{
		clearTimeout(common.statusTimer);
	},
	handleStatusTick: function()
	{
		if(typeof(common.statusTransporter)!="undefined")
		{
			if(common.statusTransporter.readyState != 4)
			{
				common.statusTransporter.abort();
			}
		}
		common.statusTimer = setTimeout(common.handleStatusTick,common.statusCallInterval);
		common.getNewStatus();
	},
	// **************************************  END: Status handling etc.






	// **************************************  Loading/disabling
	disablePage: function(strInfoText)
	{
		$('.disable h2').html(strInfoText);
		$('.disable').show();
	},
	enablePage: function()
	{
		$('.disable').hide();
	},
	startLoadingIndication: function(strCustomMessage)
	{
		$('body').attr('data-loading','1');
		common.disablePage(strCustomMessage ? strCustomMessage : 'Waiting for roaster...');
	},
	endLoadingIndication: function()
	{
		$('body').attr('data-loading','0');
		common.enablePage();
	},
	// **************************************  END: Loading/disabling


	// **************************************  Going to profile editing/selection
	headlineTimer: null,
	bindEvents: function()
	{
		var eventStr = helpers.is_touch_device() ? 'touchend' : 'click';
		$('h1').bind(eventStr,common.handleHeadlineClicked);
	},
	handleHeadlineClicked: function()
	{
		event.preventDefault();
		event.stopPropagation();
		
		var elm = $(this).closest('body');

		if(elm.hasClass('armed'))
		{
			//First clear the timer — we'll manually clear the arming
			clearTimeout(common.headlineTimer);

			//Go to profile editing here!
			common.goToFunction("ProfileList");
			
			//Remove arming
			ui.disarmAll();
		}
		else
		{
			//Remove any other arming
			ui.disarmAll();

			//Arm this
			elm.addClass('armed');

			//Reset and add new timer for disarming
			clearTimeout(profile.headlineTimer);
			profile.headlineTimer = setTimeout("ui.disarmAll();",3000);
		}
	}

	// **************************************  END: Going to profile editing/selection



}