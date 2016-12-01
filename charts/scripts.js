function reloadRoastsTable(elmTarget)
{
	function handleRoastsTableLoaded(data)
	{
		elmTarget.html(data);
	}

	$.ajax({
	  url: '/charts/ajax/proxy.asp',
	  data: {function: "writeRoastsTable"},
	  success: handleRoastsTableLoaded,
	  dataType: 'html'
	});
}