<!--#include virtual="/charts/includes/conn_create.asp"-->
<!--#include virtual="/charts/includes/basic_inc.asp"-->
<!--#include virtual="/charts/includes/head.asp"-->
<!--#include virtual="/charts/includes/menu.asp"-->   	
    	<div class="container-fluid">
    		<div class="row">
    			<div class="col-xs-12 main-suppliers-list">
					<div class="panel panel-default">
						<!-- Default panel contents -->
						<div class="panel-heading">
							Supplier
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

						<div class="resultcontainer"><div class="loader"></div></div>
						<script type="text/javascript">
							$(function(){
								firstLoad();
								bindEvents();
							});


							function firstLoad()
							{
								//1. get roast table data
								loadSuppliers($('.main-suppliers-list').find('.resultcontainer'),bindEvents);
							}

							function bindEvents()
							{
								$('.btn.refresh-button').off('click').on('click',function(){loadSuppliers($('.main-suppliers-list').find('.resultcontainer'),bindEvents)});
								$('.main-suppliers-list .btn.add-button').off('click').on('click',function(){window.location.href="/charts/pages/supplier.asp"});
								$('.main-suppliers-list .glyphicon-remove').off('click').on('click',prepareDeleteSupplier);
							}
							function prepareDeleteSupplier(event)
							{
								var supplierId = $(this).closest('[data-supplier-id]').data('supplier-id');
								if(confirm("Are you sure you want to delete this supplier?"))
								{
									deleteSupplier(supplierId,function(){loadSuppliers($('.main-suppliers-list').find('.resultcontainer'),bindEvents)});
								}
							}
						</script>

					</div>
    			</div>
    		</div>
    	</div>
<!--#include virtual="/charts/includes/foot.asp"-->
<!--#include virtual="/charts/includes/conn_close.asp"-->