function onFailSoHard(e) {
    if (e.code == 1) {
        console.log('User denied access to their camera');
    } else {
        console.log('getUserMedia() not supported in your browser.');
    }
}

function getGeo() {
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(success, error);
    } else {
        alert("Not Supported!");
    }

    function success(position) {
        console.log(position.coords.latitude);
        console.log(position.coords.longitude);
    }

    function error(msg) {
        console.log(msg);
        console.log(typeof msg == 'string' ? msg : "error");
    }

    var watchId = navigator.geolocation.watchPosition(function (position) {
        console.log(position.coords.latitude);
        console.log(position.coords.longitude);
    });

    navigator.geolocation.clearWatch(watchId);
}

function quantizeValue(l) {
    var q = [25, 75, 125, 175, 225]
    var quantized = new Array();

    for (var i = 0; i < l.length; i += 1) {
        var value = -1;
        for (var j = 0; j < q.length; j += 1) {
            if (l[i] < q[j]) {
                value = q[j] - 25;
                quantized.push(value);
                break;
            }

        }

        if (value == -1) {
            value = 255;
            quantized.push(value);
        }

    }
    return quantized;
}


function colorToGray(pixels) {
    var grays = new Array();
    var zero_count = 0;
    for (var i = 0; i < pixels.length; i += 4) {
        //fourth layer is alpha
        av = Math.round((pixels[i] + pixels[i + 1] + pixels[i + 2]) / 3);
        if (av == NaN || av === NaN) {
            console.log('error ');
        } else if (av === 0) {
            zero_count += 1;
        }
        grays.push(av);
    }
    console.log('Zero count ' + zero_count);
    console.log('grey length ' + grays.length);
    return quantizeValue(grays);
}

function compareImage(image1, image2) {
    THRESHOLD_PERCENTAGE = 0.4
    RANGE = 50;

    function getEqualRange(v) {
        a = (v - RANGE) > 0 ? v - 10 : 0;
        b = (v + RANGE) < 255 ? v + 10 : 255;
        return [a, b];
    }

    gray1 = colorToGray(image1);

    gray2 = colorToGray(image2);
    console.log(Math.max(gray1) + " - " + Math.min(gray1));
    console.log(Math.max(gray2) + " - " + Math.min(gray2));
    diff_count = 0;

    thres = Math.round(gray1.length * THRESHOLD_PERCENTAGE)
    for (var i = 0; i < gray1.length; i += 1) {

        range1 = getEqualRange(gray1[i]);
        range2 = getEqualRange(gray2[i]);
        if (range2[1] < range1[0] || range2[0] > range1[1]) {
            diff_count += 1;
        }
    }

    console.log("number of difference pixel: " + diff_count + " with thres " + thres);
    if (diff_count < thres) {
        //return true if consider the same
        return true;
    }

    return false;
}


function scaleCompareImage() {
    console.log('invoke scale method');

    //scale captured image to original image
    var context2 = canvas2.getContext('2d');
    /*
	console.log(" ratio scale " + canvas2.width / canvas.width + " - " + canvas2.height / canvas.height);
	//context2.translate(canvas2.width / 2, canvas2.height / 2); 
	context2.scale(canvas2.width / canvas.width, canvas2.height / canvas.height);
	context2.save();
	canvas2.width = canvas.width;
	canvas2.height = canvas.height; 
	//compare
	*/

    var imageData1 = canvas.getContext('2d').getImageData(0, 0, canvas.width, canvas.height);
    var imageData2 = context2.getImageData(0, 0, canvas.width, canvas.height);
    //console.log(imageData1.data);
    //console.log(imageData2.data);
    return compareImage(imageData1.data, imageData2.data);


}

function closedEnough(rect) {
    //console.log('video width' + $(video).width() + ' - ' + $(video).height());
    if ($(video).width() / 4 < rect[2] && $(video).height() / 4 < rect[3]) {
    	
        return true;
        
    }
    return false;
}

function captureFaceImage(imageUrl, rect, painCanvas) {

    painCanvas.style.display = 'block';
    painCanvas.width = rect[2];
    painCanvas.height = rect[3];
    //img.width = rect[2];
    //img.height = rect[3];
    var imgCtx = painCanvas.getContext('2d');
    var imageObj = new Image();
    imageObj.onload = function () {
        imgCtx.drawImage(imageObj, rect[0], rect[1], rect[2], rect[3], 0, 0, rect[2], rect[3]);
    }
    imageObj.src = imageUrl;
}


function captureAndAuthenticate(coords) {
    //capture the face image
    if (startMonitor && !faceDetected) {
        var tmpCanvas = document.createElement('canvas');
        tmpCanvas.width = video.videoWidth;
        tmpCanvas.height = video.videoHeight;
        var ctx = tmpCanvas.getContext('2d');
        ctx.drawImage(video, 0, 0);
        //img.src = canvas.toDataURL('image/webp');
        captureFaceImage(tmpCanvas.toDataURL('image/webp'), coords, canvas2);
        var checkAuth = setInterval(function () {
            var auth = scaleCompareImage();
            if (auth) {
                $('#notification').removeClass();
                $('#notification').addClass('alert alert-success');
                $('#notification').text('Authorized...');
                //continue to monitor
                faceDetected = false;


            } else {
                $('#notification').removeClass();
                $('#notification').addClass('alert alert-error');
                $('#notification').text('Not authorized. Taking SOME ACTION ...');
            }
            clearInterval(checkAuth);

        }, 1000);

        faceDetected = true;
    }


}


function tick() {
    $('#hl').remove();
    window.webkitRequestAnimationFrame(tick);

    if (video.readyState === video.HAVE_ENOUGH_DATA) {
        $(video).objectdetect("all", {
            scaleMin: 3,
            scaleFactor: 1.1,
            classifier: objectdetect.frontalface
        }, function (coords) {
            if (coords[0]) {
                coords = smoother.smooth(coords[0]);
                //console.log(coords);
                face = coords;
                $(this).highlight(coords, "red");

                if (closedEnough(coords)) {
                    captureAndAuthenticate(coords);
                }


            }
        });
    }
}

$.fn.highlight = function (rect, color) {
    $("<div />", {
        "id": "hl",
        "css": {
            "border": "2px solid " + color,
            "position": "absolute",
            "left": ($(this).offset().left + rect[0]) + "px",
            "top": ($(this).offset().top + rect[1]) + "px",
            "width": rect[2] + "px",
            "height": rect[3] + "px"
        }
    }).appendTo("body");
}
$.fn.recording = function (color) {
    $("<div />", {
        "id": "rec",
        "css": {
            "border-radius": "50%",
            "color": color,
            "position": "absolute",
            "left": ($(this).offset().left + 10) + "px",
            "top": ($(this).offset().top + 10) + "px",
            "width": "20px",
            "height": "20px"
        }
    }).appendTo("body");
}
var face;
var video;
var img;
var canvas;
var canvas2;
var smoother = new Smoother(0.85, [0, 0, 0, 0, 0]);
var faceDetected = false;
var faceSampled = false;
var startMonitor = false;



function runVideo() {
    video = document.querySelector('#screenshot-stream');
    var button = document.querySelector('#screenshot-button');
    canvas = document.querySelector('#screenshot-canvas');
    canvas2 = document.querySelector('#screenshot2-canvas');
    img = document.querySelector('#screenshot');
    var ctx = canvas.getContext('2d');
    var localMediaStream = null;

    function sizeCanvas() {
        setTimeout(function () {
            canvas.width = video.videoWidth;
            canvas.height = video.videoHeight;
            canvas2.width = video.videoWidth;
            canvas2.height = video.videoHeight;
            //img.height = video.videoHeight;
            //img.width = video.videoWidth;
        }, 50);
    }

    function snapshot() {
        var tmpCanvas = document.createElement('canvas');
        tmpCanvas.width = video.videoWidth;
        tmpCanvas.height = video.videoHeight;
        var ctx = tmpCanvas.getContext('2d');
        ctx.drawImage(video, 0, 0);
        //img.src = canvas.toDataURL('image/webp');
        captureFaceImage(tmpCanvas.toDataURL('image/webp'), face, canvas);
        faceSampled = true;
    }
    button.addEventListener('click', function (e) {
        if (localMediaStream) {
            snapshot();
            return;
        }
        if (navigator.getUserMedia) {
            navigator.getUserMedia('video', function (stream) {
                video.src = stream;
                localMediaStream = stream;
                sizeCanvas();
                button.textContent = 'Take Shot';
            }, onFailSoHard);
        } else if (navigator.webkitGetUserMedia) {
            navigator.webkitGetUserMedia({
                video: true
            }, function (stream) {
                video.src = window.webkitURL.createObjectURL(stream);
                window.webkitRequestAnimationFrame(tick);
                localMediaStream = stream;
                sizeCanvas();
                button.textContent = 'Take Shot';
            }, onFailSoHard);
        } else {
            onFailSoHard({
                target: video
            });
        }
    }, false);
    video.addEventListener('click', snapshot, false);
    document.querySelector('#screenshot-stop-button').addEventListener('click', function (e) {
        video.pause();
        localMediaStream.stop();
    }, false);

    //button to start monitor for intruder
    document.querySelector('#monitor-button').addEventListener('click', function (e) {

        if ($('#screenshot-canvas').css('display') != "none") {

            startMonitor = true;
            $(this).recording('red');
            $('#monitor-button').text('Stop Monitor');
            $('#screenshot-canvas').css('display', 'none');

        } else {
            startMonitor = false;
            $('#monitor-button').text('Start Monitor');
        }
    }, false);

}



var readyStateCheckInterval = setInterval(function () {
    if (document.readyState === "complete") {
        getGeo();
        runVideo();
        clearInterval(readyStateCheckInterval);
    }
}, 10);
