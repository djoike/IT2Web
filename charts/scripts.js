function reloadRoastsTable(elmTarget)
{
	function handleRoastsTableLoaded(data)
	{
		elmTarget.html(data);
	}

	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {function: "writeRoastsTable"},
	  success: handleRoastsTableLoaded,
	  dataType: 'html'
	});
}

function loadRoast(elmTarget, roastId)
{
	function handleRoastLoaded(data)
	{
		elmTarget.html(data);
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
                        	minute: ' mm '
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