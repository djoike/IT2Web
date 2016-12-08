<!--#include virtual="/charts/includes/conn_create.asp"-->
<!--#include virtual="/charts/includes/basic_inc.asp"-->
<!--#include virtual="/charts/includes/head.asp"-->
<!--#include virtual="/charts/includes/menu.asp"-->
		<%
		beanId = request.querystring("beanId")
		if beanId&"" = "" then
			beanId = 0
		end if
		%>   	
    	<div class="container-fluid">
    		<div class="row">
    			<div class="col-xs-12 main-bean">
					<div class="panel panel-default">
						<!-- Default panel contents -->
						<div class="panel-heading">
							Bean
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
    		__beanId = <%=beanId%>;
    		$(function(){
    			firstLoad();
    			bindEvents();
    		});


    		function firstLoad()
    		{
    			loadBean($('.main-bean').find('.resultcontainer'),__beanId,bindEvents);
    		}

    		function bindEvents()
    		{
    			
    			$('.btn-save').off('click').on('click',function(){saveBeanAndBeanIntent(__beanId,redirectIfNew)});
    			$('.btn-back').off('click').on('click',function(){window.history.back()});
    			$('.main-bean .btn.refresh-button').off('click').on('click',function(){loadBean($('.main-bean').find('.resultcontainer'),__beanId,bindEvents)});
    		}
    		function redirectIfNew()
    		{
    			//if(__beanId == 0)
    			{
    				window.location.href = "/charts/pages/beans.asp"
    			}
    		}
    	</script>
<!--#include virtual="/charts/includes/foot.asp"-->
<!--#include virtual="/charts/includes/conn_close.asp"-->