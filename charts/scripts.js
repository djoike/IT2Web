function handleRoastDataAndDrawGraph(data)
{
	var dataObj = {datasets: []}
	for(var i = 0; i < data.data.length; i++)
	{
		dataObj.datasets.push({label:data.data[i].roastId,data:data.data[i].data,borderColor: "rgba(33,77,255,0.2)"});
	}
	drawGraph(dataObj);
	$('.main-roast-graph .loader').hide();
	$("#main-roast-chart-container").show();
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

	function handleRoastSaved(data)
	{
		//elmTarget.html(data);
		//callback();
	}

	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {function: "saveRoast",roastId: roastId, beanId: beanId, roastIntentId: roastIntentId, rawBeanWeight: rawBeanWeight, financialOwnerId: financialOwnerId},
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

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////





















