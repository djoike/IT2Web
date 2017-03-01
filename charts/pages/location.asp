<!--#include virtual="/charts/includes/conn_create.asp"-->
<!--#include virtual="/charts/includes/basic_inc.asp"-->
<!--#include virtual="/charts/includes/head.asp"-->
<!--#include virtual="/charts/includes/menu.asp"-->
		<%
		locationId = request.querystring("locationId")
		if locationId&"" = "" then
			locationId = 0
		end if
		%>   	
    	<div class="container-fluid">
    		<div class="row">
    			<div class="col-xs-12 main-location">
					<div class="panel panel-default">
						<!-- Default panel contents -->
						<div class="panel-heading">
							Location
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
    		</div>
    	</div>
    	<script type="text/javascript">
    		__locationId = <%=locationId%>;
    		$(function(){
    			firstLoad();
    			bindEvents();
    		});


    		function firstLoad()
    		{
    			loadLocation($('.main-location').find('.resultcontainer'),__locationId,bindEvents);
    		}

    		function bindEvents()
    		{
    			
    			$('.btn-save').off('click').on('click',function(){saveLocation(__locationId,redirectIfNew)});
    			$('.btn-back').off('click').on('click',function(){window.history.back()});
    			$('.main-location .btn.refresh-button').off('click').on('click',function(){loadLocation($('.main-location').find('.resultcontainer'),__locationId,bindEvents)});
    		}
    		function redirectIfNew()
    		{
    			//if(__locationId == 0) //Comment out of we should redirect always
    			{
    				window.location.href = "/charts/pages/locations.asp"
    			}
    		}
    	</script>
<!--#include virtual="/charts/includes/foot.asp"-->
<!--#include virtual="/charts/includes/conn_close.asp"-->