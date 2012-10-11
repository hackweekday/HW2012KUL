jQuery ->
	$('#hosts').dataTable
		sPaginationType: "full_numbers"
		bJQueryUI: true
		bProcessing: true
		bServerSide: true
		sAjaxSource: $('#hosts').data('source')

  

    	



	