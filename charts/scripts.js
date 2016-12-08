function reloadRoastsTable(elmTarget, callback)
{
	function handleRoastsTableLoaded(data)
	{
		elmTarget.html(data);
		callback ? callback() : void(0);
	}

	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {function: "writeRoastsTable"},
	  success: handleRoastsTableLoaded,
	  dataType: 'html'
	});
}

function loadRoast(elmTarget, roastId, callback)
{
	function handleRoastLoaded(data)
	{
		elmTarget.html(data);
		callback ? callback() : void(0);
	}

	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {function: "writeRoast",roastId: roastId},
	  success: handleRoastLoaded,
	  dataType: 'html'
	});
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

function handleRoastDataAndDrawGraph(data)
{
	var dataObj = {datasets: []}
	for(var i = 0; i < data.data.length; i++)
	{
		dataObj.datasets.push({label:data.data[i].roastId,data:data.data[i].data})
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

function toggleMaximizePanel(event)
{
	$btn = $(this);
	$cont = $btn.closest('.panel');
	bolMax = $cont.data('maximized');
	console.log($cont,bolMax);
	if(bolMax)
	{
		$cont.data('maximized',false).attr('data-maximize',false);
		$btn.find('span').removeClass('glyphicon-resize-small').addClass('glyphicon-resize-full');
	}
	else
	{
		$cont.data('maximized',true).attr('data-maximize',true);
		$btn.find('span').removeClass('glyphicon-resize-full').addClass('glyphicon-resize-small');
	}
}

function saveBeanAndRoastIntent(roastId)
{
	var beanId = $('[data-for="beanId"]').val();
	var roastIntentId = $('[data-for="roastIntentId"]').val();

	function handleRoastSaved(data)
	{
		//elmTarget.html(data);
		//callback();
	}

	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {function: "saveRoast",roastId: roastId, beanId: beanId, roastIntentId: roastIntentId},
	  success: handleRoastSaved
	});
}
function saveBeanAndBeanIntent(beanId, callback)
{
	var beanName = $('[data-for="beanName"]').val();
	var beanIntentId = $('[data-for="beanIntentId"]').val();

	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {function: "saveBean",beanId: beanId, beanName: beanName, beanIntentId: beanIntentId},
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