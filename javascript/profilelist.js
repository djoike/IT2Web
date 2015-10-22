var profileList = {
	
	// **************************************  Basics
	deleteProfile: function(profileId)
	{
		if(profileId)
		{
			var dataObj = {"Action":InterfaceComActions.DeleteProfile,"ProfileId":profileId};
			$.ajax({
			    type: Methods.Test,
			    url: EndPoints.Test.DeleteProfile,
			    data: {"data":JSON.stringify(dataObj)},
			    async: false 
			});
		}
	},
	pickProfile: function(profileId)
	{
		if(profileId)
		{
			var dataObj = {"Action":InterfaceComActions.SetProfile,"ProfileId":profileId};
			$.ajax({
			    type: Methods.Test,
			    url: EndPoints.Test.SetProfile,
			    data: {"data":JSON.stringify(dataObj)}
			});
		}
	},
	editProfile: function(profileId)
	{
		if(profileId)
		{
			profileEdit.loadProfile(profileId);
		}
		common.goToFunction("ProfileEdit")
	},
	// **************************************  END: Basics



	// **************************************  Profile loading, parsing etc.
	profileTemplate: "<li data-profile-id='{profile-id}'>{profile-name}<span data-action='pick'></span><span data-action='edit'></span><span data-action='delete'></span><div class='cb'></div></li>",
	loadProfiles: function()
	{
		function handleLoadProfiles(data)
		{
			var containerElm = $('.container[data-type="list-of-profiles"] ul');
			var JSONObject = $.parseJSON(data);
			if(JSONObject.Profiles)
			{
				if(JSONObject.Profiles.length > 0)
				{
					$(JSONObject.Profiles).each(function(){
						var tmpHTML = profileList.profileTemplate.replace("{profile-name}",this.Name).replace("{profile-id}",this.Id);
						containerElm.append(tmpHTML);
					});
				}
			}
		}
		var dataObj = {"Action":InterfaceComActions.GetProfiles};
		$.ajax({
		    type: Methods.Test,
		    url: EndPoints.Test.GetProfiles,
		    data: {"data":JSON.stringify(dataObj)},
		    success: handleLoadProfiles
		});
	},
	// **************************************  END: Profile loading, parsing etc.




	// **************************************  Clicking/tapping events
	initProfileList: function()
	{
		profileList.bindButtonEvents();
		profileList.bindProfileEvents();
	},
	bindButtonEvents: function()
	{
		var strContainerElm = '.container[data-type="list-of-profiles"]';
		var eventStr = helpers.is_touch_device() ? 'touchend' : 'click';
		$('.button',strContainerElm).bind(eventStr,profileList.handleButtonClicked);
	},
	bindProfileEvents: function()
	{
		var strContainerElm = '.container[data-type="list-of-profiles"]';
		var eventStr = helpers.is_touch_device() ? 'touchend' : 'click';
		$('span[data-action]',strContainerElm).live(eventStr,profileList.handleProfileFunctionClicked);
	},
	handleProfileFunctionClicked: function(event)
	{
		event.preventDefault();
		event.stopPropagation();
		
		var elm = $(this);
		var action = elm.data('action');
		var profileId = elm.closest('[data-profile-id]').data('profile-id');

		switch(action)
		{
			case "pick":
				profileList.pickProfile(profileId);
				profileList.returnToPreviousFunction();
				break;
			case "delete":
				profileList.deleteProfile(profileId);
				common.clearFunction("ProfileList"); //To clear the list of profiles
				profileList.loadProfiles(); //Load new list of profiles
				break;
			case "edit":
				profileList.editProfile(profileId);
				break;
		}
	},
	handleButtonClicked: function(event)
	{
		event.preventDefault();
		event.stopPropagation();
		
		var elm = $(this);

		if(elm.hasClass('armed') || elm.attr('data-disable-arming'))
		{
			//First clear the timer — we'll manually clear the arming
			clearTimeout(profileList.buttonTimer);

			//Button-dependant code
			switch(elm.data('type'))
			{
				case "new-profile":
					profileList.editProfile();
					break;
				case "back":
					profileList.returnToPreviousFunction();
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
			clearTimeout(profileList.buttonTimer);
			profile.buttonTimer = setTimeout("ui.disarmAll('list-of-profiles');",3000);
		}
	},
	returnToPreviousFunction: function()
	{
		common.startStatusCalls();
		common.goToFunction($('.container[data-type="list-of-profiles"]').data('return-function'));
	}
	// **************************************  END: Clicking/tapping events

}














