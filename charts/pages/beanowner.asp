<!--#include virtual="/charts/includes/conn_create.asp"-->
<!--#include virtual="/charts/includes/basic_inc.asp"-->
<!--#include virtual="/charts/includes/head.asp"-->
<!--#include virtual="/charts/includes/menu.asp"-->
		<%
		beanOwnerId = request.querystring("beanOwnerId")
		if beanOwnerId&"" = "" then
			beanOwnerId = 0
		end if
		%>   	
    	<div class="container-fluid">
    		<div class="row">
    			<div class="col-xs-12 main-bean-owner">
					<div class="panel panel-default">
						<!-- Default panel contents -->
						<div class="panel-heading">
							Bean owner
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
    		__beanOwnerId = <%=beanOwnerId%>;
    		$(function(){
    			firstLoad();
    			bindEvents();
    		});


    		function firstLoad()
    		{
    			loadBeanOwner($('.main-bean-owner').find('.resultcontainer'),__beanOwnerId,bindEvents);
    		}

    		function bindEvents()
    		{
    			
    			$('.btn-save').off('click').on('click',function(){saveBeanOwner(__beanOwnerId,redirectIfNew)});
    			$('.btn-back').off('click').on('click',function(){window.history.back()});
    			$('.main-bean-owner .btn.refresh-button').off('click').on('click',function(){loadBeanOwner($('.main-bean-owner').find('.resultcontainer'),__beanOwnerId,bindEvents)});
    		}
    		function redirectIfNew()
    		{
    			//if(__beanOwnerId == 0) //Comment out of we should redirect always
    			{
    				window.location.href = "/charts/pages/beanowners.asp"
    			}
    		}
    	</script>
<!--#include virtual="/charts/includes/foot.asp"-->
<!--#include virtual="/charts/includes/conn_close.asp"-->