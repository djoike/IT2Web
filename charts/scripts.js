////////////////////////////////////////////////////////////////////////////
// UTILITY  ////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
function secondsToMMSS(secs)
{
	return ("0" + Math.floor(secs / 60)).slice(-2) + ":" + ("0" + (secs % 60)).slice(-2);
}
function lefZ(number,minLength)
{
	var s = number+"";
	while (s.length < minLength) s = "0" + s;
	return s;
}

////////////////////////////////////////////////////////////////////////////
// COMMON PROFILE GRAPHING  ////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
function getElapsedPreductionByTemperature(temp)
{
   return  2.2631997788658467e+001 * Math.pow(temp,0)
        +  2.2495741681623960e-001 * Math.pow(temp,1)
        +  1.4724211125521899e-002 * Math.pow(temp,2)
        + -8.2862310284286634e-005 * Math.pow(temp,3)
        +  2.2091369327342341e-007 * Math.pow(temp,4);
}

function getDataPointJSON(datapoint)
{
    var timeString = secondsToMMSS(datapoint.timeInSec);
    var temperatureString = datapoint.temperature;

    return {"x":"1900-01-01T00:" + timeString + ".000","y": temperatureString };
}
function parseRawProfile(strRawProfile)
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
}
function convertProfileStepsToGraphDataSet(profile)
{
    var latestDataPoint = {
        timeInSec: 0,
        temperature: 0
    };

    var dataset = [];
    dataset.push(getDataPointJSON(latestDataPoint));

    
    var steps = profile.steps;
    for(var i = 0; i < steps.length;i++)
    {
        var step = steps[i];
        
        // Determine the correct progression point
        var progTime;
        var remainingTime;
        if(step.stepProgressionTime > 0)
        {
            //Create intermediary datapoint
            progTime = step.stepProgressionTime;
        }
        else
        {
        	var latestElapsed = getElapsedPreductionByTemperature(latestDataPoint.temperature);
        	var nextElapsed = getElapsedPreductionByTemperature(step.stepTemperature);
        	if((step.stepTemperature - latestDataPoint.temperature) > 0)
        	{
            	progTime = Math.round(nextElapsed - latestElapsed);
            }
            else
            {
            	progTime = -Math.round((step.stepTemperature - latestDataPoint.temperature) * 4);
            }
        }

        // Add the progression point
        var progressionPoint = {
            timeInSec: latestDataPoint.timeInSec + progTime,
            temperature: step.stepTemperature
        }
        dataset.push(getDataPointJSON(progressionPoint));
        latestDataPoint = progressionPoint; // Beware that it's not cloning the object here, but so far it's not needed to do that.

        //Check for remaining time
        remainingTime = step.stepTotalTime - progTime;
        if(remainingTime > 0)
        {
            var remainingPoint = {
                timeInSec: latestDataPoint.timeInSec + remainingTime,
                temperature: step.stepTemperature
            }
            dataset.push(getDataPointJSON(remainingPoint));
            latestDataPoint = remainingPoint; // Beware that it's not cloning the object here, but so far it's not needed to do that.
        }
    }
    return dataset;
}
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
var __roastGraphDataSets = {datasets: []};
var __roastGraphProfileDataPoints = [];
var __roastGraphCrackPoints;
function handleRoastDataAndDrawGraph(data)
{
	__roastGraphDataSets.datasets = [];
	for(var i = 0; i < data.data.length; i++)
	{
		__roastGraphDataSets.datasets.push({label:data.data[i].roastId,data:data.data[i].data,borderColor: "rgba(33,77,255,0.6)",pointRadius: 0,pointHitRadius: 10});
	}
	drawGraph(__roastGraphDataSets);
	
	if(data.data.length == 1)
	{
		var profileText = data.data[0].profileText;
		var profile = parseRawProfile(profileText);
		var profileData = convertProfileStepsToGraphDataSet(profile);
		__roastGraphProfileDataPoints = profileData;
	}
	else
	{
		__roastGraphProfileDataPoints = [];
	}
	handleRoastGraphProfileLoaded();

	__roastGraphCrackPoints = {"first":null,"second":null};
	if(data.crackPoints !== undefined)
	{
		var crackPoints = data.crackPoints;
		if(crackPoints.firstCrack.elapsed !== null)
		{
			var point = {
			    timeInSec: crackPoints.firstCrack.elapsed,
			    temperature: crackPoints.firstCrack.temp
			}
			var downLinePoint = {
			    timeInSec: crackPoints.firstCrack.elapsed,
			    temperature: 0
			}
			__roastGraphCrackPoints.first = [getDataPointJSON(point),getDataPointJSON(downLinePoint)];
		}
		if(crackPoints.secondCrack.elapsed !== null)
		{
			var point = {
			    timeInSec: crackPoints.secondCrack.elapsed,
			    temperature: crackPoints.secondCrack.temp
			}
			var downLinePoint = {
			    timeInSec: crackPoints.secondCrack.elapsed,
			    temperature: 0
			}
			__roastGraphCrackPoints.second = [getDataPointJSON(point),getDataPointJSON(downLinePoint)];
		}
	}
	handleRoastGraphCrackPointsLoaded();

	
	$('.main-roast-graph .loader').hide();
	$("#main-roast-chart-container").show();
}

function handleRoastGraphCrackPointsLoaded()
{
	if(__roastGraphCrackPoints.first !== null)
	{
		__roastGraphDataSets.datasets.push({
	        label:'First crack',
	        data:__roastGraphCrackPoints.first,
	        lineTension: 0,
	        borderColor: "rgba(255,0,0,0.6)",
	        pointRadius: 0,
	        pointHitRadius: 20
	    });
		
	}
	if(__roastGraphCrackPoints.second !== null)
	{
		__roastGraphDataSets.datasets.push({
	        label:'Second crack',
	        data:__roastGraphCrackPoints.second,
	        lineTension: 0,
	        borderColor: "rgba(255,60,255,0.6)",
	        pointRadius: 0,
	        pointHitRadius: 20
	    });
		
	}
	drawGraph(__roastGraphDataSets);
}

function handleRoastGraphProfileLoaded()
{
	if(__roastGraphProfileDataPoints.length > 0)
	{
		__roastGraphDataSets.datasets.push({
	        label:'Profile',
	        data:__roastGraphProfileDataPoints,
	        lineTension: 0,
	        borderColor: "rgba(251,118,75,0.6)",
	        pointRadius: 0,
	        pointHitRadius: 10
	    });
		drawGraph(__roastGraphDataSets);
	}
}

var myChart;
function initChart()
{
	var ctx = document.getElementById("main-roast-chart");
	myChart = new Chart(ctx, {
	    type: 'line',
	    options: {
	    	maintainAspectRatio: true,
	        scales: {
	            yAxes: [{
	                ticks: {
	                    beginAtZero:true,
	                    min: 0,
	                    stepSize: 10
	                }
	            }],
	            xAxes: [{
	                type: 'time',
	                position:"bottom",
	                time: {
                    	displayFormats: {
                        	minute: 'mm:ss'
                    	}
                	}
	            }]
	        },
	        legend: {display:false},
	        elements:{
	        	line: {
	        		fill: false
	        	}
	        }
	    }
	});
}
function drawGraph(data)
{
	myChart.data.datasets = data.datasets;
	myChart.update();
}

$(function(){
	$('.maximize-button').closest('.panel').data('maximized',false);
	$('.btn.maximize-button').on('click',toggleMaximizePanel);
});

function toggleMaximizePanel(event,elmTarget)
{
	if(elmTarget)
	{
		$btn = $([]);
		$cont = elmTarget;
	}
	else
	{
		$btn = $(this);
		$cont = $btn.closest('.panel');
	}
	bolMax = $cont.data('maximized');
	if(bolMax)
	{
		$cont.parent().find('.overlay').remove();
		$cont.data('maximized',false).attr('data-maximize',false);
		$btn.find('span').removeClass('glyphicon-resize-small').addClass('glyphicon-resize-full');
	}
	else
	{
		$cont.parent().prepend('<div class="overlay"></div>');
		$cont.data('maximized',true).attr('data-maximize',true);
		$btn.find('span').removeClass('glyphicon-resize-full').addClass('glyphicon-resize-small');
	}
}

function saveBeanAndRoastIntent(roastId, callback)
{
	var beanId = $('[data-for="beanId"]').val();
	var roastIntentId = $('[data-for="roastIntentId"]').val();
	var rawBeanWeight = $('[data-for="rawBeanWeight"]').val();
	var financialOwnerId = $('[data-for="financialOwnerId"]').val();
	var roastNote = $('[data-for="roastNote"]').val();

	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {function: "saveRoast",roastId: roastId, beanId: beanId, roastIntentId: roastIntentId, rawBeanWeight: rawBeanWeight, financialOwnerId: financialOwnerId, roastNote: roastNote},
	  success: callback
	});
}
function saveBeanAndBeanIntent(beanId, callback)
{
	var beanName = $('[data-for="beanName"]').val();
	var beanPrice = $('[data-for="beanPrice"]').val();
	var beanIntentId = $('[data-for="beanIntentId"]').val();
	var beanNote = $('[data-for="beanNote"]').val();
	var beanOwnerId = $('[data-for="beanOwnerId"]').val();
	var beanSupplierId = $('[data-for="beanSupplierId"]').val();
	var beanLocationId = $('[data-for="beanLocationId"]').val();
	var beanAmountPurchased = $('[data-for="beanAmountPurchased"]').val();
	var beanAmountAdjustment = $('[data-for="beanAmountAdjustment"]').val();
	var beanPurchaseDate = $('[data-for="beanPurchaseDate"]').val();

	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {
		  		function: "saveBean",
		  		beanId: beanId,
		  		beanName: beanName,
		  		beanPrice: beanPrice,
		  		beanIntentId: beanIntentId,
		  		beanNote: beanNote,
		  		beanOwnerId: beanOwnerId,
		  		beanSupplierId: beanSupplierId,
		  		beanLocationId: beanLocationId,
		  		beanAmountPurchased: beanAmountPurchased,
		  		beanAmountAdjustment: beanAmountAdjustment,
		  		beanPurchaseDate: beanPurchaseDate
	  		},
	  success: callback
	});
}
function loadBeans(elmTarget, callback)
{
	function handleBeansTableLoaded(data)
	{
		elmTarget.html(data);
		callback ? callback() : void(0);
	}

	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {function: "writeBeansTable"},
	  success: handleBeansTableLoaded,
	  dataType: 'html'
	});
}

function loadStock(elmTarget, callback)
{
	function handleStockLoaded(data)
	{
		elmTarget.html(data);
		callback ? callback() : void(0);
	}

	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {function: "writeStock"},
	  success: handleStockLoaded,
	  dataType: 'html'
	});
}

function loadBean(elmTarget, beanId, callback)
{
	function handleBeanLoaded(data)
	{
		elmTarget.html(data);
		callback ? callback() : void(0);
	}

	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {function: "writeBean",beanId: beanId},
	  success: handleBeanLoaded,
	  dataType: 'html'
	});
}

function deleteBean(beanId, callback)
{
	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {function: "deleteBean",beanId: beanId},
	  success: callback
	});
}

function deleteRoast(roastId, callback)
{
	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {function: "deleteRoast",roastId: roastId},
	  success: callback
	});
}


function handleAddRoastLoaded(elmTarget)
{
	var $container = elmTarget.closest('.panel');
	$container.show();
	toggleMaximizePanel(null,$container);
	$container.find('td.view-column a').off('click').on('click',handleAddRoastClick);
	$container.find('.btn-save').off('click').on('click',function(){endAddRoast(elmTarget)});
	$container.find('[data-toggle="tooltip"]').tooltip(); 
}
function handleAddRoastClick(event)
{
	var roastId = $(this).closest('[data-roast-id]').data('roast-id');
	addRoastIdToGraphed(roastId);
	$(this).closest('td').addClass('picked');
}
function addRoastIdToGraphed(roastId)
{
	__graphedRoasts.push(roastId);
}
function reloadRoastsTable(elmTarget, callback, __graphedRoasts)
{
	function handleRoastsTableLoaded(data)
	{
		elmTarget.html(data);
		callback ? callback() : void(0);
	}
	if(__graphedRoasts)
	{
		$.ajax({
		  url: '/charts/ajax/proxy.asp',
		  data: {function: "writeRoastsPicker", graphedRoasts: __graphedRoasts},
		  success: handleRoastsTableLoaded,
		  dataType: 'html'
		});
	}
	else
	{
		$.ajax({
		  url: '/charts/ajax/proxy.asp',
		  data: {function: "writeRoastsTable"},
		  success: handleRoastsTableLoaded,
		  dataType: 'html'
		});
	}
}

function loadRoast(elmTarget, roastId, callback)
{
	function handleRoastLoaded(data)
	{
		elmTarget.html(data);
		callback ? callback() : void(0);
		__rotate = 0;
	}

	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {function: "writeRoast",roastId: roastId},
	  success: handleRoastLoaded,
	  dataType: 'html'
	});
}

function startAddRoast(elmTarget)
{
	reloadRoastsTable(elmTarget,function(){handleAddRoastLoaded(elmTarget)},__graphedRoasts);
}
function endAddRoast(elmTarget)
{
	var $container = elmTarget.closest('.panel');
	$container.hide();
	toggleMaximizePanel(null,$container);
	loadDataForRoast(__graphedRoasts,handleRoastDataAndDrawGraph);
}


function loadDataForRoast(arrRoastIds, callback)
{
	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {function: "getRoastData",roastIds: arrRoastIds},
	  success: callback,
	  dataType: 'json',
	  method: 'POST'
	});
}

function startPreview()
{
	var $elm = $(this);
	if (this.files && this.files[0]) {
	    var reader = new FileReader();

	    reader.onload = function (e) {
	        $elm.closest('.form-group').find('img.live-thumb').attr('src', e.target.result);
	        $elm.closest('.form-group').find('.live-photo').show();
	    }

	    reader.readAsDataURL(this.files[0]);
	}
}

function incrementRotation()
{
	__rotate = __rotate == 0 ? 90 : (((__rotate/90)+1) * 90);
	__rotate = __rotate == 360 ? 0: __rotate;
	$(this).closest('.form-group').find('.rotate-degs').html('('+__rotate+'&deg;)');
}

function startUpload()
{
	var $elm = $('#file');
    var file_data = $elm.prop('files')[0];
    var form_data = new FormData();
    form_data.append('file', file_data);
    form_data.append('roast-id', __roastId);
    form_data.append('rotate', __rotate);
    $.ajax({
        url: '/charts/ajax/upload.asp', // point to server-side PHP script 
        dataType: 'text', // what to expect back from the PHP script
        cache: false,
        contentType: false,
        processData: false,
        data: form_data,
        type: 'post',
        success: function () {
            loadRoast($('.main-roast').find('.resultcontainer'),__roastId,bindEvents);
        },
        error: function (response) {
            alert(response);
        }
	});
}

function deletePicture()
{
	if(confirm("Er du sikker?"))
	{
		function handlePicDeleted(data)
		{
			loadRoast($('.main-roast').find('.resultcontainer'),__roastId,bindEvents);
		}

		$.ajax({
		  url: '/charts/ajax/proxy.asp',
		  data: {function: "deletePicture",roastId: __roastId},
		  success: handlePicDeleted
		});
	}
}

////////////////////////////////////////////////////////////////////////////
// BEAN OWNERS /////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
function loadBeanOwners(elmTarget, callback)
{
	function handleBeanOwnersTableLoaded(data)
	{
		elmTarget.html(data);
		callback ? callback() : void(0);
	}

	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {function: "writeBeanOwnersTable"},
	  success: handleBeanOwnersTableLoaded,
	  dataType: 'html'
	});
}

function loadBeanOwner(elmTarget, beanOwnerId, callback)
{
	function handleBeanOwnerLoaded(data)
	{
		elmTarget.html(data);
		callback ? callback() : void(0);
	}

	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {function: "writeBeanOwner",beanOwnerId: beanOwnerId},
	  success: handleBeanOwnerLoaded,
	  dataType: 'html'
	});
}

function deleteBeanOwner(beanOwnerId, callback)
{
	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {function: "deleteBeanOwner",beanOwnerId: beanOwnerId},
	  success: callback
	});
}
function saveBeanOwner(beanOwnerId, callback)
{
	var beanOwnerName = $('[data-for="beanOwnerName"]').val();
	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {function: "saveBeanOwner",beanOwnerId: beanOwnerId, beanOwnerName: beanOwnerName},
	  success: callback
	});
}
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////
// LOCATIONS ///////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
function loadLocations(elmTarget, callback)
{
	function handleLocationsTableLoaded(data)
	{
		elmTarget.html(data);
		callback ? callback() : void(0);
	}

	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {function: "writeLocationsTable"},
	  success: handleLocationsTableLoaded,
	  dataType: 'html'
	});
}

function loadLocation(elmTarget, locationId, callback)
{
	function handleLocationLoaded(data)
	{
		elmTarget.html(data);
		callback ? callback() : void(0);
	}

	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {function: "writeLocation",locationId: locationId},
	  success: handleLocationLoaded,
	  dataType: 'html'
	});
}

function deleteLocation(locationId, callback)
{
	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {function: "deleteLocation",locationId: locationId},
	  success: callback
	});
}
function saveLocation(locationId, callback)
{
	var locationName = $('[data-for="locationName"]').val();
	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {function: "saveLocation",locationId: locationId, locationName: locationName},
	  success: callback
	});
}
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////
// SUPPLIERS ///////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
function loadSuppliers(elmTarget, callback)
{
	function handleSuppliersTableLoaded(data)
	{
		elmTarget.html(data);
		callback ? callback() : void(0);
	}

	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {function: "writeSuppliersTable"},
	  success: handleSuppliersTableLoaded,
	  dataType: 'html'
	});
}

function loadSupplier(elmTarget, supplierId, callback)
{
	function handleSupplierLoaded(data)
	{
		elmTarget.html(data);
		callback ? callback() : void(0);
	}

	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {function: "writeSupplier",supplierId: supplierId},
	  success: handleSupplierLoaded,
	  dataType: 'html'
	});
}

function deleteSupplier(supplierId, callback)
{
	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {function: "deleteSupplier",supplierId: supplierId},
	  success: callback
	});
}
function saveSupplier(supplierId, callback)
{
	var supplierName = $('[data-for="supplierName"]').val();
	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {function: "saveSupplier",supplierId: supplierId, supplierName: supplierName},
	  success: callback
	});
}
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////
// BALANCE /////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
function loadBalance(elmTarget, callback)
{
	function handleBalanceTableLoaded(data)
	{
		elmTarget.html(data);
		callback ? callback() : void(0);
	}

	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {function: "writeBalanceTable"},
	  success: handleBalanceTableLoaded,
	  dataType: 'html'
	});
}
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////
// PROFILES ////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
function loadProfiles(elmTarget, callback)
{
	function handleProfilesTableLoaded(data)
	{
		elmTarget.html(data);
		callback ? callback() : void(0);
	}

	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {function: "writeProfilesTable"},
	  success: handleProfilesTableLoaded,
	  dataType: 'html'
	});
}

function loadProfile(elmTarget, profileId, callback)
{
	function handleProfileLoaded(data)
	{
		elmTarget.html(data);
		callback ? callback() : void(0);
	}

	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {function: "writeProfile",profileId: profileId},
	  success: handleProfileLoaded,
	  dataType: 'html'
	});
}

function deleteProfile(profileId, callback)
{
	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {function: "deleteProfile",profileId: profileId},
	  success: callback
	});
}
function saveProfile(profileId, callback)
{
	var profileName = $('[data-for="profileName"]').val();
	var profileText = $('[data-for="profileText"]').val();
	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {function: "saveProfile",profileId: profileId, profileName: profileName, profileText: profileText},
	  success: callback
	});
}

var myChartProfile;
function initProfileChart()
{
	var ctx = document.getElementById("main-profile-chart");
	myChartProfile = new Chart(ctx, {
	    type: 'line',
	    options: {
	    	animation: {
	    		duration: 0
	    	},
	    	maintainAspectRatio: true,
	        scales: {
	            yAxes: [{
	                ticks: {
	                    beginAtZero:true,
	                    min: 0,
	                    stepSize: 10
	                }
	            }],
	            xAxes: [{
	                type: 'time',
	                position:"bottom",
	                time: {
                    	displayFormats: {
                        	minute: 'mm:ss'
                    	}
                	}
	            }]
	        },
	        legend: {display:false},
	        elements:{
	        	line: {
	        		fill: false
	        	}
	        }
	    }
	});
}
function drawProfileGraph(data)
{
	myChartProfile.data.datasets = data.datasets;
	myChartProfile.update();
}

var __profile = {};
function initProfiler()
{
    resetProfiler();
    var profileText = $('[data-for="profileText"]').val();
    loadProfileFromText(profileText);
}

function resetProfiler()
{
    __profile = {};
}

function loadProfileFromText(profileText)
{
    __profile = parseRawProfile(profileText);
    //drawProfile(__profile);
    //renderProfileSteps(__profile);
}

function bindStepEvents()
{
	$('.stepsContainer .step input')
		.off('input')
		.off('change')
		.on('input',handleStepInput)
		.on('change',reDrawProfile)
		.on('change',function(){handleStepChangeValidate(this)});
	$('.stepsContainer a.remove').off('click').on('click',handleStepRemoveClick);
}

function handleStepRemoveClick()
{
	var elm = $(this);
	removeStep(elm);
}

function removeStep(elm)
{
	var elmRemove = elm.closest('.step');
	elmRemove.remove();
	reDrawProfile();
}

function handleStepChangeValidate(elm)
{
	var elm = $(elm);
	var val = elm.val();

	if(elm.is('[data-type="time"]'))
	{
		if(elm.is('[data-value-for="prog"]'))
		{
			var otherElm = elm.closest('table').find('[data-value-for="total"]');
			var otherVal = otherElm.val();
			if(val > otherVal)
			{
				otherElm.val(val);
				var newVal = secondsToMMSS(val);
				otherElm.closest('tr').find('.value span').html(newVal);
				reDrawProfile();
			}
		}
		else
		{
			var otherElm = elm.closest('table').find('[data-value-for="prog"]');
			var otherVal = otherElm.val();
			if(val < otherVal)
			{
				otherElm.val(val);
				var newVal = secondsToMMSS(val);
				otherElm.closest('tr').find('.value span').html(newVal);
				reDrawProfile();
			}
		}
	}

	//Always run through temps
	for(var i = 0; i < __profile.steps.length; i++)
	{
		if(__profile.steps[i].stepProgressionTime === 0)
		{
			var currentTotal = __profile.steps[i].stepTotalTime;
			var currentTemp = __profile.steps[i].stepTemperature;
			var lastTemp = i > 0 ? __profile.steps[i-1].stepTemperature : 0;
			var elapsed = currentTemp - lastTemp > 0 ? Math.round(getElapsedPreductionByTemperature(currentTemp) - getElapsedPreductionByTemperature(lastTemp)) : -Math.round((currentTemp - lastTemp) * 4);
			if(elapsed > currentTotal)
			{
				var elmTotal = $($('.stepsContainer .step [data-value-for="total"]')[i]);
				elmTotal.val(elapsed);
				handleStepInput(elmTotal, true);
			}
		}
	}
}

function reDrawProfile()
{
	var profileText = stepsToProfileText();
	$('[data-for="profileText"]').val(profileText);
	__profile = parseRawProfile(profileText);
	drawProfile(__profile);
}

function stepsToProfileText()
{
	var profileText = "";
	var tempArr = $('.stepsContainer .step [data-value-for="temp"]');
	var progArr = $('.stepsContainer .step [data-value-for="prog"]');
	var totalArr = $('.stepsContainer .step [data-value-for="total"]');
	for(var i = 0; i < tempArr.length; i++)
	{
		profileText += getStepString(tempArr[i].value,progArr[i].value,totalArr[i].value);
	}
	return profileText;
}

function getStepString(temp,prog,total)
{
	return 	lefZ(temp,3) +
			"-" +
			lefZ(prog,3) +
			"-" +
			lefZ(total,3) +
			"#";
}

function handleStepInput(elm, isElm)
{
	if(isElm == undefined)
	{
		elm = $(this);
	}
	var val = elm.val();
	var newVal = val;
	var type = elm.data('type');
	if(type == "temp")
	{
		newVal += "&deg;";
	}
	else if(type == "time")
	{
		newVal = secondsToMMSS(newVal);
	}
	elm.closest('tr').find('.value span').html(newVal);
	reDrawProfile();
}

function drawProfile(profile)
{

    var dataset = convertProfileStepsToGraphDataSet(profile);

    var dataObj = {datasets: []}
    dataObj.datasets.push({
        label:'Profile',
        data:dataset,
        lineTension: 0,
        borderColor: "rgba(251,118,75,0.6)"
    });

    dataObj.datasets.push({label:'Profile',data:[{"x":"1900-01-01T00:25:00.000","y":260}],borderColor: "rgba(255,255,255,0.0)",backgroundColor: "rgba(255,255,255,0.0)"});
    
    drawProfileGraph(dataObj);
}

function initSteps()
{
	var steps = __profile.steps;

	for(var i = 0; i < steps.length; i++)
	{
		addStepHTML(steps[i].stepTemperature, steps[i].stepProgressionTime, steps[i].stepTotalTime);
	}

	bindStepEvents();
	drawProfile(__profile);
}

function addNewStep()
{
	var iMaxStep = __profile.steps.length-1;
	var temp = 200;
	if(iMaxStep >= 0)
	{
		temp = __profile.steps[iMaxStep].stepTemperature;
	}
	addStepHTML(temp, 330, 330);
	bindStepEvents();

	reDrawProfile();
}

function addStepHTML(temp, prog, total)
{
	var elm = $('.stepTemplateContainer .step').clone();

	// Temp
	elm.find('[data-value-for="temp"]').val(temp);
	elm.find('[data-for="temp"]').html(temp + "&deg;");

	// Prog
	elm.find('[data-value-for="prog"]').val(prog);
	elm.find('[data-for="prog"]').html(secondsToMMSS(prog));

	// Total
	elm.find('[data-value-for="total"]').val(total);
	elm.find('[data-for="total"]').html(secondsToMMSS(total));

	$('.stepsContainer').append(elm);
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////





















