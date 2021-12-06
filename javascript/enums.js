var	statusCodeIntervals = Object.freeze(
	{
		default: 1000,
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
		RemoveProfile: 145,
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
		DeleteProfile: 100,
		MasterReset: 110,
		RemoveProfile: 120,
		SetFirstCrack: 130,
        SetSecondCrack: 140
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
			GetProfiles: "/getprofiles.txt",
			SaveProfile: "/getprofiles.txt",
			MasterReset: "/getprofiles.txt",
			RemoveProfile: "/getprofiles.txt",
			SetCracks: "/getprofiles.txt"
		},
		Live:
		{
			GetStatus: "http://webinterface.il-torrefattore.dk/RoastIO/InterfaceCom.aspx",
			SetStatus: "http://webinterface.il-torrefattore.dk/RoastIO/InterfaceCom.aspx",
			SetManualRoastTemperature: "http://webinterface.il-torrefattore.dk/RoastIO/InterfaceCom.aspx",
			GetProfile: "http://webinterface.il-torrefattore.dk/RoastIO/InterfaceCom.aspx",
			DeleteProfile: "http://webinterface.il-torrefattore.dk/RoastIO/InterfaceCom.aspx",
			SetProfile: "http://webinterface.il-torrefattore.dk/RoastIO/InterfaceCom.aspx",
			GetProfiles: "http://webinterface.il-torrefattore.dk/RoastIO/InterfaceCom.aspx",
			SaveProfile: "http://webinterface.il-torrefattore.dk/RoastIO/InterfaceCom.aspx",
			MasterReset: "http://webinterface.il-torrefattore.dk/RoastIO/InterfaceCom.aspx",
			RemoveProfile: "http://webinterface.il-torrefattore.dk/RoastIO/InterfaceCom.aspx",
			SetCracks: "http://webinterface.il-torrefattore.dk/RoastIO/InterfaceCom.aspx"
		}
	}
);

var Methods = Object.freeze(
	{
		Test: "GET",
		Live: "POST"
	}
);