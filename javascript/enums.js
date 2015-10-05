var	statusCodeIntervals = Object.freeze(
	{
		default: 50000,
		30:1000
	}
);
var RoastStatus = Object.freeze(
	{
		NoCommunicationYet: 0,
		RoasterOnlineReady: 30,
		LoadProfile: 105,
		ProfileLoading: 106,
		ProfileLoaded: 110,
		StartRoastingWithProfile: 115,
		StartingRoastingWithProfile: 120,
		RoastingWithProfile: 130,
		StartManualRoast: 205,
		StartingManualRoast: 210,
		RoastingManually: 220,
		EndRoast: 305,
		EndingRoast: 310,
		ErrorStatusCodesDoNotMatch: 401
	}
);
var InterfaceComActions = Object.freeze(
	{
		SetStatus: 10,
		SaveProfile: 20,
		GetProfile: 30,
		GetProfiles: 40,
		SetProfile: 50,
		GetRoastData: 60,
		GetStatus: 70,
		SetManualRoastTemperature: 80,
		GetManualRoastTemperature: 90,
		DeleteProfile: 100
	}
);

var EndPoints = Object.freeze(
	{
		Test:
		{
			GetStatus: "/getstatus.txt",
			SetStatus: "/getprofile.txt",
			SetManualRoastTemperature: "/getprofile.txt",
			GetProfile: "/getprofile.txt",
			DeleteProfile: "/getprofile.txt",
			SetProfile: "/getprofile.txt",
			GetProfiles: "/getprofiles.txt"
		},
		Live:
		{
			GetStatus: "http://192.168.1.219/IT2/RoastIO/InterfaceCom.aspx",
			SetStatus: "http://192.168.1.219/IT2/RoastIO/InterfaceCom.aspx",
			SetManualRoastTemperature: "http://192.168.1.219/IT2/RoastIO/InterfaceCom.aspx",
			GetProfile: "http://192.168.1.219/IT2/RoastIO/InterfaceCom.aspx",
			DeleteProfile: "http://192.168.1.219/IT2/RoastIO/InterfaceCom.aspx",
			SetProfile: "http://192.168.1.219/IT2/RoastIO/InterfaceCom.aspx",
			GetProfiles: "http://192.168.1.219/IT2/RoastIO/InterfaceCom.aspx"
		}
	}
);

var Methods = Object.freeze(
	{
		Test: "GET",
		Live: "POST"
	}
);