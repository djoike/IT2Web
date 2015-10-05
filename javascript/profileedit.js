var profileEdit = {
	
	// **************************************  Basics
	
	// **************************************  END: Basics



	// **************************************  Profile loading, parsing etc.
	stepTemplate: "<li><span class='input-container'><input type='number' pattern='[0-9]*' class='step-temperature-input' value='{step-temperature}' />&nbsp;&deg;C</span><span class='input-container'><input type='number' pattern='[0-9]*' class='step-progression-time-input' value='{step-progression-time}' />&nbsp;s</span><span class='input-container last'><input type='number' pattern='[0-9]*' class='step-total-time-input' value='{step-total-time}' />&nbsp;s</span><span data-action='move'></span><span data-action='delete'></span><div class='cb'></div></li>",
	loadProfile: function(profileId)
	{
		function handleLoadProfile(data)
		{
			var containerElm = $('.container[data-type="edit-profile"] ul');
			var JSONObject = $.parseJSON(data);
			if(JSONObject.Profile)
			{
				containerElm.closest('.container').find('.headline-edit-container input').val(JSONObject.Profile.Name);
				if(JSONObject.Profile.ProfileText.length > 0)
				{
					var steps = profile.parseRawProfile(JSONObject.Profile.ProfileText).steps;
					$(steps).each(function(){
						console.log(this);
						var tmpHTML = profileEdit.stepTemplate.replace("{step-temperature}",this.stepTemperature).replace("{step-progression-time}",this.stepProgressionTime).replace("{step-total-time}",this.stepTotalTime);
						containerElm.append(tmpHTML);
					});
				}
			}
		}
		var dataObj = {"Action":InterfaceComActions.GetProfile,"ProfileId":profileId};
		$.ajax({
		    type: Methods.Test,
		    url: EndPoints.Test.GetProfile,
		    data: {"data":JSON.stringify(dataObj)},
		    success: handleLoadProfile
		});
	},
	// **************************************  END: Profile loading, parsing etc.




	// **************************************  Clicking/tapping events
	buttonTimer: null,
	initProfileEdit: function()
	{
		profileEdit.bindButtonEvents();
	},
	bindButtonEvents: function()
	{
		var strContainerElm = '.container[data-type="edit-profile"]';
		var eventStr = helpers.is_touch_device() ? 'touchend' : 'click';
		$('.button',strContainerElm).bind(eventStr,profileEdit.handleButtonClicked);
	},
	handleButtonClicked: function(event)
	{
		event.preventDefault();
		event.stopPropagation();
		
		var elm = $(this);
		console.log(elm);

		if(elm.hasClass('armed') || elm.attr('data-disable-arming'))
		{
			//First clear the timer — we'll manually clear the arming
			clearTimeout(profileEdit.buttonTimer);

			//Button-dependant code
			switch(elm.data('type'))
			{
				case "add-step":
					profileEdit.addStep();
					break;
				case "save-profile":
					profileEdit.saveProfile();
					break;
				case "back":
					common.goToFunction("ProfileList");
					break;
			}
			
			//Remove arming
			ui.disarmAll('list-of-profiles');
		}
		else
		{
			//Remove any other arming
			ui.disarmAll('list-of-profiles');

			//Arm this
			elm.addClass('armed');

			//Reset and add new timer for disarming
			clearTimeout(profileEdit.buttonTimer);
			profile.buttonTimer = setTimeout("ui.disarmAll('list-of-profiles');",3000);
		}
	},
	saveProfile: function()
	{

	},
	addStep: function()
	{

	}
	// **************************************  END: Clicking/tapping events

}














