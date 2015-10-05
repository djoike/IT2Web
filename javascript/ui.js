var ui = {
	disarmAll: function(pageIdentifier)
	{
		if(pageIdentifier)
		{
			$('.armed','.container[data-type="' + pageIdentifier + '"]').removeClass('armed');
		}
		else
		{
			$('.armed').removeClass('armed');
		}
	}
}