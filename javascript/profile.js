var profile = {
	
	// **************************************  Basics
	activeProfile: null,
	handleData: function(JSONObject)
	{
		var strContainerElm = '.container[data-type="roasting-with-profile"]';
		//Handle what we have available
		//We should always have temperature
		//If the roast is started we should have elapsed (this is also how we determine if it's started)
		//If we have elapsed but no profile is loaded, we should separately load it
		if(JSONObject.CurrentTemp)
		{
			$('.element[data-type="current-temperature"] .datacontainer',strContainerElm).html(JSONObject.CurrentTemp.toFixed(1).toString().replace('.',',')+' &deg;C');
		}
		if(JSONObject.ProfileId > 0)
		{
			if(profile.activeProfile == null || profile.activeProfile.ProfileId != JSONObject.ProfileId)
			{
				profile.loadActiveProfile(JSONObject.ProfileId);
			}
		}
		else
		{
			profile.activeProfile == null;
		}
		
		profile.updateElapsed(JSONObject.ElapsedTime);
		
		if(profile.activeProfile)
		{
			profile.lastElapsedReadTimeStamp = Date.now();
			profile.latestElapsed = JSONObject.ElapsedTime;
			profile.incrementElapsed = true;

			var profileName = profile.activeProfile.Name;
			var roastingStatusObject = profile.getCurrentStepDataObj(JSONObject.ElapsedTime, profile.activeProfile);
			
			$('h1',strContainerElm).html(profileName);
			profile.insertData(roastingStatusObject);
		}
		
		switch(common.currentStatus)
		{
			case RoastStatus.ProfileLoaded:
				$('.button[data-type="end-roast"]',strContainerElm).show();
				$('.button[data-type="start-roast"]',strContainerElm).show();
				break;
			case RoastStatus.LoadProfile:
			case RoastStatus.ProfileLoading:
			case RoastStatus.StartRoastingWithProfile:
			case RoastStatus.StartingRoastingWithProfile:
			case RoastStatus.RoastingWithProfile:
				$('.button[data-type="end-roast"]',strContainerElm).show();
				$('.button[data-type="start-roast"]',strContainerElm).hide();
				break;
			case RoastStatus.NoCommunicationYet:
			case RoastStatus.RoasterOnlineReady:
			default:
				$('.button[data-type="end-roast"]',strContainerElm).hide();
				$('.button[data-type="start-roast"]',strContainerElm).hide();				
				break;
		}
	},
	insertData: function(roastingStatusObject)
	{
		var strContainerElm = '.container[data-type="roasting-with-profile"]';

		$('.element[data-type="target-temperature"] .datacontainer',strContainerElm).html(roastingStatusObject.currentTargetTemperature.toFixed(1).toString().replace('.',',')+' &deg;C');
		$('.element[data-type="status"] .datacontainer .data[data-type="step-number"]',strContainerElm).html('Step '+roastingStatusObject.currentStepNumber);
		$('.element[data-type="status"] .datacontainer .data[data-type="remain-for-adjust"]',strContainerElm).html(helpers.formatSecondsToMinutes(roastingStatusObject.progressionTimeRemaining));
		$('.element[data-type="status"] .datacontainer .data[data-type="remain-for-step"]',strContainerElm).html(helpers.formatSecondsToMinutes(roastingStatusObject.totalTimeRemaining));
		$('.element[data-type="status"] .datacontainer .data[data-type="step-temperature"]',strContainerElm).html(roastingStatusObject.stepTargetTemperature.toString().replace('.',',')+' &deg;C');
	},
	updateElapsed: function(elapsedSeconds)
	{
		var strContainerElm = '.container[data-type="roasting-with-profile"]';
		$('.element[data-type="elapsed-time"] .datacontainer',strContainerElm).html(helpers.formatSecondsToMinutes(elapsedSeconds));
	},
	// **************************************  END: Basics












	// **************************************  Profile loading, parsing etc.
	lastElapsedReadTimeStamp: null,
	latestElapsed: null,
	incrementElapsed: false,
	loadActiveProfile: function(ProfileId)
	{
		function handleLoadActiveProfileSuccess(data)
		{
			var JSONObject = $.parseJSON(data);
			console.log(JSONObject);
			if(JSONObject.Profile)
			{
				if(JSONObject.Profile.ProfileText.length > 10)
				{
					profile.activeProfile = 
						{
							"Name": JSONObject.Profile.Name,
							"ProfileId": JSONObject.Profile.Id,
							"Profile": profile.parseRawProfile(JSONObject.Profile.ProfileText)
						};
				}
			}
			console.log("New profile loaded successfully");
		}
		var dataObj = {"Action":InterfaceComActions.GetProfile,"ProfileId":ProfileId};
		$.ajax({
		    type: Methods.Test,
		    url: EndPoints.Test.GetProfile,
		    data: {"data":JSON.stringify(dataObj)},
		    success: handleLoadActiveProfileSuccess
		});
	},
	parseRawProfile: function(strRawProfile)
	{
		var stepArray = strRawProfile.split("#");
		var jsonObj = {"steps":[]};

		if(stepArray[stepArray.length-1]=="")
		{
			//Remove empty element at end
			stepArray.pop();
		}

		for(var i = 0; i<stepArray.length; i++)
		{
			var currentStepArray = stepArray[i].split("-");
			var jsonElm = {
				"stepno":i,
				"stepTemperature":parseInt(currentStepArray[0]),
				"stepProgressionTime":parseInt(currentStepArray[1]),
				"stepTotalTime":parseInt(currentStepArray[2])
			};
			jsonObj.steps.push(jsonElm);
		}
		return jsonObj;
	},
	getCurrentStepDataObj: function(elapsedSeconds, activeProfile)
	{
		console.log("Doing calculation based on elapsed", elapsedSeconds);
		profileObj = activeProfile.Profile;
		var returnObj = 
		{
			"currentTargetTemperature": 0,
			"currentStepNumber": 0,
			"progressionTimeRemaining": 0,
			"totalTimeRemaining": 0,
			"stepTargetTemperature": 0
		}
		for(i = 0; i < profileObj.steps.length; i++) //Loop steps in profile
		{
			if(elapsedSeconds < profileObj.steps[i].stepTotalTime) // This is a test to see if "this" step is the current step
			{
				returnObj.currentStepNumber = i+1;
				returnObj.totalTimeRemaining = profileObj.steps[i].stepTotalTime - elapsedSeconds;
				returnObj.stepTargetTemperature = profileObj.steps[i].stepTemperature;

				if(elapsedSeconds < profileObj.steps[i].stepProgressionTime)
				{

					var prevStepTemp = 0;
					if(i > 0)
					{
						prevStepTemp = profileObj.steps[i-1].stepTemperature;
					}
					returnObj.progressionTimeRemaining = profileObj.steps[i].stepProgressionTime - elapsedSeconds;	
					returnObj.currentTargetTemperature = ((profileObj.steps[i].stepTemperature - prevStepTemp) * (elapsedSeconds / profileObj.steps[i].stepProgressionTime)) + prevStepTemp;
					break;
				}
				else
				{
					returnObj.progressionTimeRemaining = 0;
					returnObj.currentTargetTemperature = profileObj.steps[i].stepTemperature; //Return the temperature of the step.
					break;
				}
			}
			else
			{
				elapsedSeconds -= profileObj.steps[i].stepTotalTime; //Subtract the seconds of this step, from the elapsed time, so the elapsed keeps decreasing until we match a step
			}
		}
		return returnObj;
	},
	handleElapsedTick: function()
	{
		if(profile.incrementElapsed && common.currentFunction == "ProfileRoastPage" && profile.lastElapsedReadTimeStamp > 0 && profile.latestElapsed > 0 && profile.activeProfile != null)
		{
			var currentElapsed = profile.latestElapsed + Math.round((Date.now() - profile.lastElapsedReadTimeStamp)/1000);
			var roastingStatusObject = profile.getCurrentStepDataObj(currentElapsed, profile.activeProfile);
			
			profile.updateElapsed(currentElapsed);
			profile.insertData(roastingStatusObject);
		}
		setTimeout(profile.handleElapsedTick,1000);
	},
	// **************************************  END: Profile loading, parsing etc.




	// **************************************  Clicking/tapping events
	buttonTimer: null,
	initProfile: function()
	{
		profile.bindButtonEvents();
		setTimeout(profile.handleElapsedTick,1000);
	},
	bindButtonEvents: function()
	{
		var strContainerElm = '.container[data-type="roasting-with-profile"]';
		var eventStr = helpers.is_touch_device() ? 'touchend' : 'click';
		$('.button',strContainerElm).bind(eventStr,profile.handleButtonClicked);
	},
	handleButtonClicked: function(event)
	{
		event.preventDefault();
		event.stopPropagation();
		
		var elm = $(this);

		if(elm.hasClass('armed') || elm.attr('data-disable-arming'))
		{
			//First clear the timer — we'll manually clear the arming
			clearTimeout(profile.buttonTimer);

			//Button-dependant code
			switch(elm.data('type'))
			{
				case "manual-override":
					helpers.switchToStatus(RoastStatus.StartManualRoast);
					break;
				case "end-roast":
					helpers.switchToStatus(RoastStatus.EndRoast);
					break;
				case "start-roast":
					helpers.switchToStatus(RoastStatus.StartRoastingWithProfile);
					break;
			}
			
			//Remove arming
			ui.disarmAll('roasting-with-profile');
		}
		else
		{
			//Remove any other arming
			ui.disarmAll('roasting-with-profile');

			//Arm this
			elm.addClass('armed');

			//Reset and add new timer for disarming
			clearTimeout(profile.buttonTimer);
			profile.buttonTimer = setTimeout("ui.disarmAll('roasting-with-profile');",3000);
		}
	}
	// **************************************  END: Clicking/tapping events



}



