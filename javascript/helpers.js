var helpers = {
	is_touch_device: function()
	{
		return 'ontouchstart' in window || 'onmsgesturechange' in window;
	},
	formatSecondsToMinutes: function(seconds)
	{
		return Math.floor(seconds/60) + ':' + helpers.lefZ(seconds%60,2);
	},
	lefZ: function(number,minLength)
	{
		var s = number+"";
    	while (s.length < minLength) s = "0" + s;
    	return s;
	},
	switchToStatus: function(statusCode)
	{
		var dataObj = {"Action":InterfaceComActions.SetStatus,"StatusCode":statusCode};
		$.ajax({
		    type: Methods.Test,
		    //url: '/getprofile.txt',
		    url: EndPoints.Test.SetStatus,
		    data: {"data":JSON.stringify(dataObj)}
		});
	}
}