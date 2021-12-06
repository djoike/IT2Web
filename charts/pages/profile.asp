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
                loadProfile($('.main-profile').find('.resultcontainer'),__profileId,function(){bindEvents();initProfiler();initSteps();});
    		}

    		function bindEvents()
    		{
    			
    			$('.btn-save').off('click').on('click',function(){saveProfile(__profileId,redirectIfNew)});
    			$('.btn-back').off('click').on('click',function(){window.history.back()});
    			$('.main-profile .btn.refresh-button').off('click').on('click',function(){loadProfile($('.main-profile').find('.resultcontainer'),__profileId,function(){bindEvents();initProfiler();initSteps();})});
    		}
    		function redirectIfNew()
    		{
    			//if(__profileId == 0) //Comment out if we should redirect always
    			{
    				window.location.href = "/charts/pages/profiles.asp"
    			}
    		}

    	</script>
<!--#include virtual="/charts/includes/foot.asp"-->
<!--#include virtual="/charts/includes/conn_close.asp"-->