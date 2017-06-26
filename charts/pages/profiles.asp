<!--#include virtual="/charts/includes/conn_create.asp"-->
<!--#include virtual="/charts/includes/basic_inc.asp"-->
<!--#include virtual="/charts/includes/head.asp"-->
<!--#include virtual="/charts/includes/menu.asp"-->   	
    	<div class="container-fluid">
    		<div class="row">
    			<div class="col-xs-12 main-profiles-list">
					<div class="panel panel-default">
						<!-- Default panel contents -->
						<div class="panel-heading">
							Profiles
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
								loadProfiles($('.main-profiles-list').find('.resultcontainer'),bindEvents);
							}

							function bindEvents()
							{
								$('.btn.refresh-button').off('click').on('click',function(){loadProfiles($('.main-profiles-list').find('.resultcontainer'),bindEvents)});
								$('.main-profiles-list .btn.add-button').off('click').on('click',function(){window.location.href="/charts/pages/profile.asp"});
								$('.main-profiles-list .glyphicon-remove').off('click').on('click',prepareDeleteProfile);
							}
							function prepareDeleteProfile(event)
							{
								var profileId = $(this).closest('[data-profile-id]').data('profile-id');
								if(confirm("Are you sure you want to delete this profile?"))
								{
									deleteProfile(profileId,function(){loadProfiles($('.main-profiles-list').find('.resultcontainer'),bindEvents)});
								}
							}
						</script>

					</div>
    			</div>
    		</div>
    	</div>
<!--#include virtual="/charts/includes/foot.asp"-->
<!--#include virtual="/charts/includes/conn_close.asp"-->