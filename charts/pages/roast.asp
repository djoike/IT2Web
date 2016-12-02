<!--#include virtual="/charts/includes/conn_create.asp"-->
<!--#include virtual="/charts/includes/basic_inc.asp"-->
<!--#include virtual="/charts/includes/head.asp"-->
<!--#include virtual="/charts/includes/menu.asp"-->
		<%
		roastId = request.querystring("roastId")
		%>   	
    	<div class="container-fluid">
    		<div class="row">
    			<div class="col-sm-3 main-roast">
					<div class="panel panel-default">
						<!-- Default panel contents -->
						<div class="panel-heading">
							Roast
							<div class="pull-right">
								<button class="btn btn-sm refresh-button">
									<span class="glyphicon glyphicon-refresh"></span>
								</button>
							</div>
						</div>
						<div class="resultcontainer"><div class="loader"></div></div>

					</div>
    			</div>
    			<div class="col-sm-9 main-roast-graph">
					<div class="panel panel-default">
						<!-- Default panel contents -->
						<div class="panel-heading">
							Graph
							<div class="pull-right">
								<button class="btn btn-sm refresh-button">
									<span class="glyphicon glyphicon-refresh"></span>
								</button>
							</div>
						</div>
						<div id="main-roast-chart-container">
							<canvas id="main-roast-chart" width="500" height="270"></canvas>
						</div>
						<div class="resultcontainer"><div class="loader"></div></div>

					</div>
    			</div>
    		</div>
    	</div>
    	<script type="text/javascript">
    		__roastId = <%=roastId%>;
    		$(function(){
    			firstLoad();
    			bindEvents();
    		});


    		function firstLoad()
    		{
    			//1. get roast
    			loadRoast($('.main-roast').find('.resultcontainer'),__roastId);
    			initChart();
    			loadDataForRoast([__roastId],handleRoastDataAndDrawGraph);
    			//drawGraph();
    		}

    		function bindEvents()
    		{
    			//$('.btn.refresh-button').on('click',function(){reloadRoastsTable($('.main-roast-list').find('.resultcontainer'))});
    		}
    	</script>
<!--#include virtual="/charts/includes/foot.asp"-->
<!--#include virtual="/charts/includes/conn_close.asp"-->