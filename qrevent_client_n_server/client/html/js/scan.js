var url = 'http://127.0.0.1:6543/api/identify';

var qrActions = function (data) {
    console.log(data.warning);
    if (data.warning == true) {
        $("#linkwarn").show();
    } else {
        $("#linkwarn").hide();
    }

    $("#p_verified").html(JSON.stringify(data.verified));
    $("#p_issued").html(data.issuer);

    $("#actions a").hide();

    $.each(data.actions, function (k, v) {
        $("#actions a#" + v).show();
    });

    $('#postp').show();
}

$(function () {
    var scanner = $("#scanner").WebcamQRCode({
        onError: function (error) {
            $('.alert-message strong').html('Error: ' + error);
        },
        webcamStopContent: function () {
            $('.alert-message strong').html('Scan stopped.');
        },
        onQRCodeDecode: function (data) {
            $(".putsomething").html(data);
            $("#submit-all").show();
            $("#clear-all").show();
        }
    });

    $("#clear-all").click(function (e) {
        e.preventDefault();
        $(".putsomething").html('');
        $("#clear-all").hide();
        $("#submit-all").hide();        
        $("#postp").hide();
    });

    $("#submit-all").click(function (e) {
        e.preventDefault();
        $.ajax({
            type: 'POST',
            dataType: 'jsonp',
            url: url,
            data: {qr: $(".putsomething").html()},
            success: function (data) {
                qrActions(data);
            }
        });       
    });

    $("#surf").click(function (e) {
        e.preventDefault();
        window.open($(".putsomething").html());
    });

    $("#tweet").click(function (e) {
        e.preventDefault();
        var link = 'http://twitter.com/share?url=/&text=' + $(".putsomething").html();
        window.open(link);
    });
});
