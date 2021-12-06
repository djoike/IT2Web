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
								<button class="btn btn-sm maximize-button hidden-xs">
									<span class="glyphicon glyphicon-resize-full"></span>
								</button>
							</div>
						</div>
						<div class="resultcontainer"><div class="loader"></div></div>

					</div>
    			</div>
    			<div class="col-sm-9 main-roast-graph">
					<div class="panel panel-default roast-graph">
						<!-- Default panel contents -->
						<div class="panel-heading">
							Graph
							<div class="pull-right">
								<button class="btn btn-sm add-button">
									<span class="glyphicon glyphicon-plus"></span>
								</button>
								<button class="btn btn-sm refresh-button">
									<span class="glyphicon glyphicon-refresh"></span>
								</button>
								<button class="btn btn-sm maximize-button hidden-xs">
									<span class="glyphicon glyphicon-resize-full"></span>
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
    		<div class="row">
    			<div class="col-xs-12 main-secondary-roast">
					<div class="panel panel-default secondary-roast">
						<!-- Default panel contents -->
						<div class="panel-heading">
							Pick additional roasts
							<div class="pull-right">
								<button class="btn btn-sm close-button">
									<span class="glyphicon glyphicon-remove"></span>
								</button>
							</div>
						</div>
						<div class="resultcontainer clearfix"><div class="loader"></div></div>

					</div>
    			</div>
    		</div>
    	</div>
    	<script type="text/javascript">
    		__roastId = <%=roastId%>;
    		__graphedRoasts = [<%=roastId%>];
    		__rotate = 0;
    		$(function(){
    			firstLoad();
    			bindEvents();
    		});


    		function firstLoad()
    		{
    			//1. get roast
    			loadRoast($('.main-roast').find('.resultcontainer'),__roastId,bindEvents);
    			initChart();
    			loadDataForRoast(__graphedRoasts,handleRoastDataAndDrawGraph);
    			//drawGraph();
    		}

    		function bindEvents()
    		{
    			$('.main-secondary-roast .btn.close-button').off('click').on('click',function(){endAddRoast($('.main-secondary-roast').find('.resultcontainer'))});
    			$('.btn-save').off('click').on('click',saveRoast);
    			$('.btn-back').off('click').on('click',function(){window.history.back()});
    			$('.main-roast .btn.refresh-button').off('click').on('click',function(){loadRoast($('.main-roast').find('.resultcontainer'),__roastId,bindEvents)});
    			$('.main-roast-graph .btn.add-button').off('click').on('click',function(){startAddRoast($('.main-secondary-roast').find('.resultcontainer'))});
    			$('.main-roast-graph .btn.refresh-button').off('click').on('click',function(){loadDataForRoast(__graphedRoasts,handleRoastDataAndDrawGraph)});
    			$('#file').on('change',startPreview);
    			$('.btn-rotate').on('click',incrementRotation);
    			$('.btn-upload').on('click',startUpload);
    			$('.btn-delete').on('click',deletePicture);
    		}
    		function saveRoast()
    		{
    			$('.btn-save').slideUp();
    			saveBeanAndRoastIntent(__roastId, handleRoastSaved)
    		}
    		function handleRoastSaved()
    		{
				$('.btn-save').slideDown();
    		}
    	</script>
<!--#include virtual="/charts/includes/foot.asp"-->
<!--#include virtual="/charts/includes/conn_close.asp"-->