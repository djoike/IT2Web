<!--#include virtual="/charts/includes/conn_create.asp"-->
<!--#include virtual="/charts/includes/basic_inc.asp"-->
<!--#include virtual="/charts/includes/head.asp"-->
<!--#include virtual="/charts/includes/menu.asp"-->
		<%
		profileId = request.querystring("profileId")
		if profileId&"" = "" then
			profileId = 0
		end if
		%>   	
    	<div class="container-fluid">
    		<div class="row">
    			<div class="col-sm-3 main-profile">
					<div class="panel panel-default">
						<!-- Default panel contents -->
						<div class="panel-heading">
							Profile
							<div class="pull-right">
								<button class="btn btn-sm refresh-button">
									<span class="glyphicon glyphicon-refresh"></span>
								</button>
								<button class="btn btn-sm maximize-button hidden-xs">
									<span class="glyphicon glyphicon-resize-full"></span>
								</button>
							</div>
						</div>
						<div class="resultcontainer"><div class="loader"></div></div>
					</div>
    			</div>
                <div class="col-sm-9 main-profile-graph">
                    <div class="panel panel-default profile-graph">
                        <!-- Default panel contents -->
                        <div class="panel-heading">
                            Graph
                            <div class="pull-right">
                                <button class="btn btn-sm refresh-button">
                                    <span class="glyphicon glyphicon-refresh"></span>
                                </button>
                                <button class="btn btn-sm maximize-button hidden-xs">
                                    <span class="glyphicon glyphicon-resize-full"></span>
                                </button>
                            </div>
                        </div>
                        <div id="main-profile-chart-container">
                            <canvas id="main-profile-chart" width="500" height="270"></canvas>
                        </div>
                        <div class="resultcontainer"></div>
                    </div>
                </div>
    		</div>
    	</div>
    	<script type="text/javascript">
    		__profileId = <%=profileId%>;
    		$(function(){
    			firstLoad();
    			bindEvents();
    		});


    		function firstLoad()
    		{
    			initProfileChart();
                loadProfile($('.main-profile').find('.resultcontainer'),__profileId,function(){bindEvents();initProfiler();});
    		}

    		function bindEvents()
    		{
    			
    			$('.btn-save').off('click').on('click',function(){saveProfile(__profileId,redirectIfNew)});
    			$('.btn-back').off('click').on('click',function(){window.history.back()});
    			$('.main-profile .btn.refresh-button').off('click').on('click',function(){loadProfile($('.main-profile').find('.resultcontainer'),__profileId,function(){bindEvents();initProfiler();})});
    		}
    		function redirectIfNew()
    		{
    			//if(__profileId == 0) //Comment out if we should redirect always
    			{
    				window.location.href = "/charts/pages/profiles.asp"
    			}
    		}

            var __profile = {};
            function initProfiler()
            {
                console.log("Initializing profiler...");
                
                resetProfiler();
                var profileText = $('[data-for="profileText"]').val();
                loadProfileFromText(profileText);

                console.log("Profiler initialized.");
            }

            function resetProfiler()
            {
                __profile = {};
            }

            function loadProfileFromText(profileText)
            {
                __profile = parseRawProfile(profileText);
                drawProfile(__profile);
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
                })

                dataObj.datasets.push({label:'Profile',data:[{"x":"1900-01-01T00:30:00.000","y":260}]});
                
                drawProfileGraph(dataObj);
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
                        progTime = step.stepTemperature - latestDataPoint.temperature; // Because it's 1 deg. per second
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
            function getDataPointJSON(datapoint)
            {
                var timeString = ("0" + Math.floor(datapoint.timeInSec / 60)).slice(-2) + ":" + ("0" + (datapoint.timeInSec % 60)).slice(-2);
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
    	</script>
<!--#include virtual="/charts/includes/foot.asp"-->
<!--#include virtual="/charts/includes/conn_close.asp"-->