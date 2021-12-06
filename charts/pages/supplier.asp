<!--#include virtual="/charts/includes/conn_create.asp"-->
<!--#include virtual="/charts/includes/basic_inc.asp"-->
<!--#include virtual="/charts/includes/head.asp"-->
<!--#include virtual="/charts/includes/menu.asp"-->
		<%
		supplierId = request.querystring("supplierId")
		if supplierId&"" = "" then
			supplierId = 0
		end if
		%>   	
    	<div class="container-fluid">
    		<div class="row">
    			<div class="col-xs-12 main-supplier">
					<div class="panel panel-default">
						<!-- Default panel contents -->
						<div class="panel-heading">
							Supplier
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
    		__supplierId = <%=supplierId%>;
    		$(function(){
    			firstLoad();
    			bindEvents();
    		});


    		function firstLoad()
    		{
    			loadSupplier($('.main-supplier').find('.resultcontainer'),__supplierId,bindEvents);
    		}

    		function bindEvents()
    		{
    			
    			$('.btn-save').off('click').on('click',function(){saveSupplier(__supplierId,redirectIfNew)});
    			$('.btn-back').off('click').on('click',function(){window.history.back()});
    			$('.main-supplier .btn.refresh-button').off('click').on('click',function(){loadSupplier($('.main-supplier').find('.resultcontainer'),__supplierId,bindEvents)});
    		}
    		function redirectIfNew()
    		{
    			//if(__supplierId == 0) //Comment out of we should redirect always
    			{
    				window.location.href = "/charts/pages/suppliers.asp"
    			}
    		}
    	</script>
<!--#include virtual="/charts/includes/foot.asp"-->
<!--#include virtual="/charts/includes/conn_close.asp"-->