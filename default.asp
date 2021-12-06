<!DOCTYPE html>
<html>
	<head>
		<title></title>
        <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.6.3/jquery.min.js"></script>
        <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.16/jquery-ui.min.js"></script>
        <script type="text/javascript" src="javascript/jquery.ui.touch-punch.min.js"></script>
        <script src="javascript/enums.js?rnd=<%=rnd%>"></script>
        <script src="javascript/helpers.js?rnd=<%=rnd%>"></script>
        <script src="javascript/ui.js?rnd=<%=rnd%>"></script>
        <script src="javascript/profile.js?rnd=<%=rnd%>"></script>
        <script src="javascript/profilelist.js?rnd=<%=rnd%>"></script>
        <script src="javascript/profileedit.js?rnd=<%=rnd%>"></script>
        <script src="javascript/manual.js?rnd=<%=rnd%>"></script>
        <script src="javascript/error.js?rnd=<%=rnd%>"></script>
        <script src="javascript/common.js?rnd=<%=rnd%>"></script>
		<script src="https://use.typekit.net/scx7can.js"></script>
		<script>try{Typekit.load();}catch(e){}</script>
		<style type="text/css">
			h1, h2 { padding:0; margin:0; font-weight: normal; }
			body {
				padding:5vw;
				margin:0;
				background:url('images/bg.png');
				background-size:250px;
				font-family:"bebas-neue";
				color:#FFF;
				text-shadow: 0px -0.3vw 0px rgba(0, 0, 0, 1);
			}
			body.armed .container {
				opacity: 0.5;
			}
			ul, li
			{
				margin:0;
				padding:0;
				list-style: none;
			}
			.cb {clear:both;float:none;}
			.spacer-s1 {
				height:8vw;
				clear:both;
				float: none;
			}
			.container {
				
			}
			.container * {
				/*-webkit-touch-callout: none;
    			-webkit-user-select: none;
				user-select: none;*/
			}
			.container[data-type="roasting-with-profile"] {
				display:none;
			}
			.container[data-type="roasting-manually"] {
				display:none;
			}
			.container[data-type="list-of-profiles"] {
				display:none;
			}
			.container[data-type="edit-profile"] {
				display:none;
			}
			.container[data-type="error"] {
				display:none;
			}
			.container h1 {
				font-size: 13vw;
				margin-bottom:5vw;
			}
			.element {
				width: 41vw;
			}
			.element h2 {
				margin-bottom:2vw;
				font-size:5.9vw;
			}
			.element .datacontainer {
				width: 40.6vw;
				height: 15.6vw;
				border:0.2vw solid #FFF;
				border-radius:1vw;
				background-color:#2a2a2a;
				text-align: center;
				font-size:12vw;
				padding-top: 2vw;
				text-shadow:none;
			}
			.element.fullwidth {
				width: 90vw;
			}
			.element.fullwidth .datacontainer
			{
				width:89.6vw;
			}
			.element[data-type="current-temperature"], .element[data-type="target-temperature"] {
				float:left;

			}
			.element[data-type="elapsed-time"] {
				float:right;
			}
			.element[data-type="elapsed-time"] h2 {
				text-align: right;
			}
			.element .datacontainer .data {
				font-size:5.9vw;

			}
			.element .datacontainer .data[data-type="step-number"],
			.element .datacontainer .data[data-type="step-temperature"],
			.element .datacontainer .data[data-type="label-top"],
			.element .datacontainer .data[data-type="label-bottom"] {
				text-align: left;
				float:left;
				width: 37%;
				padding-left:3vw;
			}
			.element .datacontainer .data[data-type="remain-for-adjust"],
			.element .datacontainer .data[data-type="remain-for-step"],
			.element .datacontainer .data[data-type="roaster-target-temperature"] {
				text-align: right;
				float:right;
				width: 37%;
				padding-right:3vw;
			}
			div.element[data-type="status"] {
				float:right;
			}
			div.element[data-type="status"] h2 {
				text-align: right;
			}
			div.element[data-type="status"] .datacontainer {
				padding-top:2.5vw;
				height:15.1vw;
			}
			.button {
				width: 40.6vw;
				height: 15.6vw;
				border:0.2vw solid #FFF;
				border-radius:1vw;
				text-align: center;
				font-size:12vw;
				padding-top: 2vw;
				text-shadow:none;
				background: linear-gradient(to bottom, #444 0%,#2a2a2a 100%);
				display:block;
				transition: border-color 0.4s;
				position:relative;
			}
			.button .label {
				position: relative;
			}
			.button .armedbg {
				opacity:0;
				position: absolute;
				background: linear-gradient(to bottom, #5b5b5b 0%,#333333 100%);
				top:0;
				left:0;
				width: 100%;
				height: 100%;
				transition: opacity 0.4s;
				border-radius: inherit;
			}
			.button.armed {
				
			}
			.button.armed .armedbg {
				opacity: 1;
			}
			.button[data-type="manual-override"] {
				border-color:#d3e8be;
				width: 90vw;
			}
			.button[data-type="manual-override"].armed {
				border-color:#96dd4e;
			}
			.button[data-type="end-roast"] {
				float:left;
				width:89.6vw;
			}
			.button[data-type="start-roast"], .button[data-type="end-roast"] {
				margin-top:8vw;
			}
			.container[data-type="roasting-with-profile"] .button[data-type="end-roast"]
			{
				display: none;
			}
			.container[data-type="roasting-with-profile"] div.remove-profile
			{
				display: block;
				position:absolute;
				width: 6vw;
				height: 6vw;
				background: transparent center no-repeat;
				background-size: cover;
				right: 5vw;
				top: 8vw;
			}
			.button[data-type="end-roast"].armed {
				border-color:#e56a6a;
			}
			.button[data-type="start-roast"] {
				float:left;
				width:89.6vw;
				display: none;
			}
			.button[data-type="start-roast"].armed {
				border-color:#96dd4e;
			}
			.button[data-type="master-reset"] {
				float:left;
				width:89.6vw;
			}
			.button[data-type="master-reset"].armed {
				border-color:#e56a6a;
			}
			.button[data-type="new-profile"], .button[data-type="save-profile"] {
				float:left;
				border-color:#96dd4e;
			}
			.button[data-type="back"] {
				float:right;
			}
			.button[data-type="add-step"] {
				width:90vw;
			}
			.disable {
				display:none;
				width:100%;
				height:100%;
				background-color:rgba(0,0,0,0.7);
				position: fixed;
				top:0;
				left:0;
				z-index: 2;
			}
			.disable span {
				display:none;
				width:30vw;
				height: 30vw;
				background: transparent url(/images/loading.gif) center top no-repeat;
				background-size: cover;
				position:absolute;
				top:50vh;
				left:35vw;
			}
			body[data-loading="1"] .disable span
			{
				display: block;
			}
			.disable h2 {
				position: relative;
				font-size: 15vw;
				text-align: center;
				padding-top:23vh;
			}

			/* Manual roasting view */
			.container[data-type="roasting-manually"] .element[data-type="target-temperature"] {

				
			}
			.container[data-type="roasting-manually"] .element[data-type="target-temperature"] .datacontainer {
				width: 89.6vw;
			}
			.container[data-type="roasting-manually"] .element[data-type="target-temperature"] span {
				display: none;
			}
			.button[data-type="temperature-decrease"] {
				border-color:#bed6e8;
				float:left;
				width: 22.25vw;
				font-size: 10vw;
				padding-top: 3.2vw;
				height: 14.4vw;
			}
			.button[data-type="temperature-decrease"][data-amount="-10"] {
				border-radius: 1vw 0vw 0vw 1vw;
				border-right: 0vw;
			}
			.button[data-type="temperature-decrease"][data-amount="-1"],.button[data-type="temperature-increase"][data-amount="1"] {
				border-radius: 0vw;
			}
			.button[data-type="temperature-decrease"][data-amount="-1"] {
				border-right: 0vw;
			}
			.button[data-type="temperature-increase"][data-amount="10"] {
				border-radius: 0vw 1vw 1vw 0vw;
				border-left: 0vw;
			}
			.button[data-type="temperature-decrease"] .label {
				/*font-weight: bold;
				font-size: 15vw;
				top:-1.4vw;*/
			}
			.button[data-type="temperature-increase"] {
				float:left;
				border-color:#ffd3d3;
				width: 22.25vw;
				font-size: 10vw;
				padding-top: 3.2vw;
				height: 14.4vw;
			}
			.button[data-type="temperature-increase"] .label {
				/*font-size:25vw;
				top:-7vw;*/
			}
			.container[data-type="roasting-manually"] .button[data-type="temperature-decrease"] .armedbg,
			.container[data-type="roasting-manually"] .button[data-type="temperature-increase"] .armedbg {
				transition: none;
			}
			.container[data-type="list-of-profiles"] .element[data-type="profile-list"] .datacontainer,
			.container[data-type="edit-profile"] .element[data-type="step-list"] .datacontainer {
				text-align: left;
				height: auto;
				padding:4vw;
				width: 81.6vw;
			}

			.container[data-type="list-of-profiles"] .element[data-type="profile-list"] .datacontainer ul {

			}
			.container[data-type="list-of-profiles"] .element[data-type="profile-list"] .datacontainer li,
			.container[data-type="edit-profile"] .element[data-type="step-list"] .datacontainer li {
				display: block;
				font-size:8vw;
				padding-bottom:2vw;
				margin-bottom:2vw;
				border-bottom:0.2vw solid #aaa;

			}
			.container[data-type="edit-profile"] .element[data-type="step-list"] .datacontainer li {
				padding-bottom: 4vw;
			}
			.container[data-type="list-of-profiles"] .element[data-type="profile-list"] .datacontainer li:last-child,
			.container[data-type="edit-profile"] .element[data-type="step-list"] .datacontainer li:last-child {
				border-bottom:none;
				padding-bottom:0;
				margin-bottom:0;
			}
			.container[data-type="list-of-profiles"] .element[data-type="profile-list"] .datacontainer li span,
			.container[data-type="edit-profile"] .element[data-type="step-list"] .datacontainer li span[data-action="delete"],
			.container[data-type="edit-profile"] .element[data-type="step-list"] .datacontainer li span[data-action="move"] {
				display: block;
				float:right;
				width: 6vw;
				height: 6vw;
				background: transparent center no-repeat;
				background-size: cover;
				margin-left:4vw;
				position: relative;
				top: 1vw;
			}
			.container[data-type="edit-profile"] .element[data-type="step-list"] .datacontainer li span[data-action="delete"] {
				margin-left:0;
				top: 3vw;
			}
			.container[data-type="edit-profile"] .element[data-type="step-list"] .datacontainer li span[data-action="move"] {
				width: 8vw;
				height: 8vw;
				margin-left:2vw;
				top:2vw;
			}
			.container .element[data-type="profile-list"] .datacontainer li span[data-action="delete"], .container[data-type="edit-profile"] .element[data-type="step-list"] .datacontainer li span[data-action="delete"], .container[data-type="roasting-with-profile"] div.remove-profile  {
				background-image:url('data:image/svg+xml;utf8,<svg version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="95.939px" height="95.939px" viewBox="0 0 95.939 95.939" style="enable-background:new 0 0 95.939 95.939;" xml:space="preserve"><g>	<path style="fill:#a76565;" d="M62.819,47.97l32.533-32.534c0.781-0.781,0.781-2.047,0-2.828L83.333,0.586C82.958,0.211,82.448,0,81.919,0 c-0.53,0-1.039,0.211-1.414,0.586L47.97,33.121L15.435,0.586c-0.75-0.75-2.078-0.75-2.828,0L0.587,12.608 c-0.781,0.781-0.781,2.047,0,2.828L33.121,47.97L0.587,80.504c-0.781,0.781-0.781,2.047,0,2.828l12.02,12.021 c0.375,0.375,0.884,0.586,1.414,0.586c0.53,0,1.039-0.211,1.414-0.586L47.97,62.818l32.535,32.535 c0.375,0.375,0.884,0.586,1.414,0.586c0.529,0,1.039-0.211,1.414-0.586l12.02-12.021c0.781-0.781,0.781-2.048,0-2.828L62.819,47.97 z"/></g></svg>');
			}
			.container .element[data-type="profile-list"] .datacontainer li span[data-action="edit"] {
				background-image:url('data:image/svg+xml;utf8,<svg version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="485.219px" height="485.22px" viewBox="0 0 485.219 485.22" style="enable-background:new 0 0 485.219 485.22;" xml:space="preserve"><g> <path style="fill:#FFF;" d="M467.476,146.438l-21.445,21.455L317.35,39.23l21.445-21.457c23.689-23.692,62.104-23.692,85.795,0l42.886,42.897 C491.133,84.349,491.133,122.748,467.476,146.438z M167.233,403.748c-5.922,5.922-5.922,15.513,0,21.436 c5.925,5.955,15.521,5.955,21.443,0L424.59,189.335l-21.469-21.457L167.233,403.748z M60,296.54c-5.925,5.927-5.925,15.514,0,21.44 c5.922,5.923,15.518,5.923,21.443,0L317.35,82.113L295.914,60.67L60,296.54z M338.767,103.54L102.881,339.421 c-11.845,11.822-11.815,31.041,0,42.886c11.85,11.846,31.038,11.901,42.914-0.032l235.886-235.837L338.767,103.54z M145.734,446.572c-7.253-7.262-10.749-16.465-12.05-25.948c-3.083,0.476-6.188,0.919-9.36,0.919 c-16.202,0-31.419-6.333-42.881-17.795c-11.462-11.491-17.77-26.687-17.77-42.887c0-2.954,0.443-5.833,0.859-8.703 c-9.803-1.335-18.864-5.629-25.972-12.737c-0.682-0.677-0.917-1.596-1.538-2.338L0,485.216l147.748-36.986 C147.097,447.637,146.36,447.193,145.734,446.572z"/></g></svg>');
			}
			.container .element[data-type="profile-list"] .datacontainer li span[data-action="pick"] {
				background-image:url('data:image/svg+xml;utf8,<svg version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="415.582px" height="415.582px" viewBox="0 0 415.582 415.582" style="enable-background:new 0 0 415.582 415.582;" xml:space="preserve"><g><path style="fill:#FFF;" d="M411.47,96.426l-46.319-46.32c-5.482-5.482-14.371-5.482-19.853,0L152.348,243.058l-82.066-82.064 c-5.48-5.482-14.37-5.482-19.851,0l-46.319,46.32c-5.482,5.481-5.482,14.37,0,19.852l138.311,138.31 c2.741,2.742,6.334,4.112,9.926,4.112c3.593,0,7.186-1.37,9.926-4.112L411.47,116.277c2.633-2.632,4.111-6.203,4.111-9.925 C415.582,102.628,414.103,99.059,411.47,96.426z"/></g></svg>');
			}
			.container[data-type="edit-profile"] .element[data-type="step-list"] .datacontainer li span[data-action="move"] {
				background-image:url('data:image/svg+xml;utf8,<svg version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 32 32" style="enable-background:new 0 0 32 32;" xml:space="preserve"><g><g id="move_x5F_vertical_x5F_alt2"> <path style="fill:#FFF;" d="M16,0C7.164,0,0,7.164,0,16s7.164,16,16,16s16-7.164,16-16S24.836,0,16,0z M18,22h2l-4,4l-4-4h2V10 h-2l4-4l4,4h-2V22z"/></g></g></svg>');
			}
			.headline-edit-container input {
				width: 90vw;
				background-color:transparent;
				font-family: "bebas-neue";
				color:#FFF;
				font-size: 13vw;
				border:none;
				border-bottom:0.5vw #FFF solid;
				margin:0;
				padding:0;
				margin-bottom:4vw;
				border-radius: 0;
			}
			.container[data-type="edit-profile"] .datacontainer li input {
				width: 12.5vw;
				background-color:transparent;
				font-family: "bebas-neue";
				color:#FFF;
				font-size: 10vw;
				border:none;
				border-bottom:0.5vw #FFF solid;
				margin:0;
				padding:0;
				border-radius: 0;
			}
			.container[data-type="edit-profile"] .datacontainer li span.input-container {
				display: block;
				float:left;
				margin-right: 5vw;
			}
			.container[data-type="edit-profile"] .datacontainer li span.input-container.last {
				margin-right: 0;
			}
			.crack-container {
				margin-top: 8vw;
			}
			.crack-container .button {
				float:right;
			}
			.crack-container .button:first-child {
				float:left;
			}
		</style>
	</head>
	<body>
		<div class="disable"><h2 data-default-value=""></h2><span></span></div>
		<div class="container" data-type="roasting-with-profile">
			<div class="remove-profile" data-visible-on-clear="false" data-disable-arming="true" data-type="remove-profile"></div>
			<h1 data-default-value="No profile loaded">No profile loaded</h1>
			<div class="element" data-type="current-temperature">
				<h2>Temperature</h2>
				<div class="datacontainer" data-default-value="&ndash; &deg;C">&ndash; &deg;C</div>
			</div>
			<div class="element" data-type="elapsed-time">
				<h2>Elapsed time</h2>
				<div class="datacontainer" data-default-value="-:&ndash;">-:&ndash;</div>
			</div>
			<div class="spacer-s1"></div>
			<div class="element" data-type="target-temperature">
				<h2>Target temperature</h2>
				<div class="datacontainer" data-default-value="&ndash; &deg;C">&ndash; &deg;C</div>
			</div>
			<div class="element" data-type="status">
				<h2>Status</h2>
				<div class="datacontainer">
					<div class="data" data-type="step-number" data-default-value="Step -">Step -</div>
					<div class="data" data-type="remain-for-adjust" data-default-value="-:--">-:--</div>
					<div class="data" data-type="step-temperature" data-default-value="&ndash; &deg;C">&ndash; &deg;C</div>
					<div class="data" data-type="remain-for-step" data-default-value="-:--">-:--</div>
				</div>
			</div>
			<div class="spacer-s1"></div>
			<div class="button" data-type="manual-override"><div class="armedbg"></div><div class="label">Manual</div></div>
			<div class="crack-container">
				<div class="button" data-type="first-crack" data-visible-on-clear="false"><div class="armedbg"></div><div class="label">1st</div></div>
				<div class="button" data-type="second-crack" data-visible-on-clear="false"><div class="armedbg"></div><div class="label">2nd</div></div>
				<div class="cb"></div>
			</div>
			<div class="button" data-type="start-roast" data-visible-on-clear="false"><div class="armedbg"></div><div class="label">Start roast</div></div>
			<div class="button" data-type="end-roast" data-visible-on-clear="false"><div class="armedbg"></div><div class="label">End roast</div></div>
			<div class="cb"></div>
		</div>
		<div class="container" data-type="roasting-manually">
			<h1>Manual control</h1>
			<div class="element" data-type="current-temperature">
				<h2>Temperature</h2>
				<div class="datacontainer" data-default-value="&ndash; &deg;C">&ndash; &deg;C</div>
			</div>
			<div class="element" data-type="elapsed-time">
				<h2>Elapsed time</h2>
				<div class="datacontainer" data-default-value="-:--">-:--</div>
			</div>
			<div class="spacer-s1"></div>
			<div class="element" data-type="target-temperature">
				<h2>Target temperature</h2>
				<div class="datacontainer" data-default-value="&ndash; &deg;C">&ndash; &deg;C</div>
				<span data-default-value=""></span>
			</div>
			<div class="spacer-s1"></div>
			<div class="button" data-type="temperature-decrease" data-amount="-10" data-disable-arming="true"><div class="armedbg"></div><div class="label">-10</div></div>
			<div class="button" data-type="temperature-decrease" data-amount="-1" data-disable-arming="true"><div class="armedbg"></div><div class="label">-1</div></div>
			<div class="button" data-type="temperature-increase" data-amount="1" data-disable-arming="true"><div class="armedbg"></div><div class="label">+1</div></div>
			<div class="button" data-type="temperature-increase" data-amount="10" data-disable-arming="true"><div class="armedbg"></div><div class="label">+10</div></div>
			<div class="button" data-type="end-roast"><div class="armedbg"></div><div class="label">End roast</div></div>
			<div class="cb"></div>
		</div>
		<div class="container" data-type="list-of-profiles">
			<h1>Profiles</h1>
			<div class="button" data-type="new-profile" data-disable-arming="true"><div class="armedbg"></div><div class="label">New</div></div>
			<div class="button" data-type="back" data-disable-arming="true"><div class="armedbg"></div><div class="label">Back</div></div>
			<div class="spacer-s1"></div>
			<div class="element fullwidth" data-type="profile-list">
				<div class="datacontainer">
					<ul data-default-value=""></ul>
				</div>
			</div>
		</div>
		<div class="container" data-type="edit-profile">
			<div class="headline-edit-container">
				<input type="text" name="profileName" placeholder="Enter profile name" data-default-value="" />
				<input type="hidden" name="profileId" value="" data-default-value="" />
			</div>
			<div class="spacer-s1"></div>
			<div class="button" data-type="add-step" data-disable-arming="true"><div class="armedbg"></div><div class="label">Add step</div></div>
			<div class="spacer-s1"></div>
			<div class="button" data-type="save-profile" data-disable-arming="true"><div class="armedbg"></div><div class="label">Save</div></div>
			<div class="button" data-type="back"><div class="armedbg"></div><div class="label">Back</div></div>
			<div class="spacer-s1"></div>
			<div class="element fullwidth" data-type="step-list">
				<div class="datacontainer">
					<ul data-default-value=""></ul>
				</div>
			</div>
		</div>
		<div class="container" data-type="error">
			<h1>Error has occurred</h1>
			<div class="button" data-type="master-reset"><div class="armedbg"></div><div class="label">Reset system</div></div>
		</div>
		<script type="text/javascript">
			$(document).ready(function(){
				common.initWebinterface();
			});
		</script>
	</body>
</html>