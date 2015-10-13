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
				var contElm = containerElm.closest('.container');
				contElm.find('.headline-edit-container input[type="text"]').val(JSONObject.Profile.Name);
				contElm.find('.headline-edit-container input[type="hidden"]').val(JSONObject.Profile.Id);
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
		profileEdit.bindProfileEvents();
	},
	bindButtonEvents: function()
	{
		var strContainerElm = '.container[data-type="edit-profile"]';
		var eventStr = helpers.is_touch_device() ? 'touchend' : 'click';
		$('.button',strContainerElm).bind(eventStr,profileEdit.handleButtonClicked);
	},	
	bindProfileEvents: function()
	{
		var strContainerElm = '.container[data-type="edit-profile"]';
		var eventStr = helpers.is_touch_device() ? 'touchend' : 'click';
		$('ul li span[data-action="delete"]',strContainerElm).live(eventStr,profileEdit.removeStep);
		$('ul',strContainerElm).sortable({handle:'span[data-action="move"]',axis:"y"});
	},
	removeStep: function(event)
	{
		event.preventDefault();
		event.stopPropagation();
		
		var elm = $(this);

		elm.closest('li').remove();
	},
	handleButtonClicked: function(event)
	{
		event.preventDefault();
		event.stopPropagation();
		
		var elm = $(this);

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
			ui.disarmAll('edit-profile');
		}
		else
		{
			//Remove any other arming
			ui.disarmAll('edit-profile');

			//Arm this
			elm.addClass('armed');

			//Reset and add new timer for disarming
			clearTimeout(profileEdit.buttonTimer);
			profileEdit.buttonTimer = setTimeout("ui.disarmAll('edit-profile');",3000);
		}
	},
	getProfileText: function()
	{
		//000-000-010#000-000-020#
		var profileText = "";	
		$('.container[data-type="edit-profile"] ul li').each(function(){
			var container = $(this);
			profileText += profileEdit.getStepAsString(container);
		});
		return profileText;
	},
	getProfileObject: function()
	{
		var object = {};
		var container = $('.container[data-type="edit-profile"]'); 
		
		var id = container.find('input[type="hidden"]').val();
		var name = container.find('input[type="text"]').val();
		object.Id = id.length > 0 ? id : 0;
		object.Name = name;
		object.ProfileText = profileEdit.getProfileText();

		return object;
	},
	isValidProfile: function()
	{
		var profileValid = true;
		var steps = $('.container[data-type="edit-profile"] ul li');
		steps.each(function(){
			var container = $(this);
			var stepText = profileEdit.getStepAsString(container);
			if(stepText.match("[0-9]{3}-[0-9]{3}-[0-9]{3}#").length != 1)
			{
				profileValid = false;
			}
		});
		return profileValid && steps.length > 0;
	},
	saveProfile: function()
	{
		if(profileEdit.isValidProfile())
		{
			var dataObj = {"Action":InterfaceComActions.SaveProfile,"Profile":profileEdit.getProfileObject()};
			$.ajax({
			    type: Methods.Test,
			    url: EndPoints.Test.SaveProfile,
			    data: {"data":JSON.stringify(dataObj)},
			    success: function(){common.goToFunction("ProfileList")}
			});
		}
		else
		{
			alert("The profile is not valid");
		}
	},
	addStep: function()
	{
		var containerElm = $('.container[data-type="edit-profile"] ul');
		var tmpHTML = profileEdit.stepTemplate.replace("{step-temperature}",'').replace("{step-progression-time}",'').replace("{step-total-time}",'');
		containerElm.append(tmpHTML);
	},
	getStepAsString: function(stepElement)
	{
		var stepText = "";
		stepText += helpers.lefZ(stepElement.find('.step-temperature-input').val(),3);
		stepText += "-";
		stepText += helpers.lefZ(stepElement.find('.step-progression-time-input').val(),3);
		stepText += "-";
		stepText += helpers.lefZ(stepElement.find('.step-total-time-input').val(),3);
		stepText += "#";

		return stepText;
	}
	// **************************************  END: Clicking/tapping events

}














