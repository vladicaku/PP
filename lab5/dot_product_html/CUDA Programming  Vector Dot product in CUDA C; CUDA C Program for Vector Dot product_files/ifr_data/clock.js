var timediff = 0;
function refhreshTimeDiff() {
	var start = new Date();
	$.ajax({
		complete: function(data, status) {
			var end = new Date();
			if (data && data.responseJSON && (status == "success" || status == "notmodified")) {
				timediff = end.getTime() - (end.getTime() - start.getTime()) / 2 - data.responseJSON.timestamp * 1000;
			}
		},
		dataType: 'json',
		type: "POST",
		url: BASE_URL + "/api/common/getGMT"
	});
}
if (typeof mode == "undefined" || (mode != 1 && mode != 2 && mode != 3 && mode != 4))
	mode = 1;
if (typeof cssA != "string")
	cssA = "";
function refreshClock() {
	var dobj = new Date(), hh, mm;
	if (typeof GMT !== "undefined") {
		dobj.setTime(dobj.getTime() + GMT * 3600000 + timediff);
		hh = dobj.getUTCHours();
		mm = dobj.getUTCMinutes();
	} else {
		hh = dobj.getHours();
		mm = dobj.getMinutes();
	}
	var apm = "";
	var ss = dobj.getSeconds();
	var pre = "";
	var post = "";
	if (mode == 2 || mode == 3 || mode == 4) {
		apm = " am";
		if (hh == 0) {
			hh = 12;
			apm = " am";
		} else if (hh == 12) {
			apm = " pm";
		} else if (hh > 12) {
			apm = " pm";
			hh = hh % 12;
		}
	}
	if (mode == 4)
		apm = "";
	if (mode == 3) {
		pre = "<span style=\"white-space:nowrap;\">";
		post = "</span>";
	}
	if (hh < 10)
		hh = "0" + hh;
	if (mm < 10)
		mm = "0" + mm;
	if (ss < 10)
		ss = "0" + ss;
	document.getElementById('clock').innerHTML = pre + "<a id=\"dwrClock\" href=\"http://www.dwebresources.com\" target=\"_blank\" style=\"text-decoration:none;" + cssA + "\">" + hh + ":" + mm + ":" + ss + apm + "</a>" + post;
}
function initClock() {
	var sample = [];
	sample[1] = "<a id=\"dwrClock\" href=\"http://www.dwebresources.com\" target=\"_blank\" style=\"text-decoration:none;\">88:88:88</a>";
	sample[2] = "<a id=\"dwrClock\" href=\"http://www.dwebresources.com\" target=\"_blank\" style=\"text-decoration:none;\">88:88:88 pm</a>";
	sample[3] = "<span style=\"white-space:nowrap;\"><a id=\"dwrClock\" href=\"http://www.dwebresources.com\" target=\"_blank\" style=\"text-decoration:none;\">88:88:88 pm</a></span>";
	sample[4] = "<a id=\"dwrClock\" href=\"http://www.dwebresources.com\" target=\"_blank\" style=\"text-decoration:none;\">88:88:88</a>";
	var i;
	document.getElementById('clock').innerHTML = sample[mode];
	var Width = document.compatMode === 'CSS1Compat' && !window.opera ? document.documentElement.clientWidth : document.body.clientWidth;
	var Height = document.compatMode === 'CSS1Compat' && !window.opera ? document.documentElement.clientHeight : document.body.clientHeight;
	for (i = 2; i < 300; i++) {
		document.body.style.fontSize = i + "px";
		var xWithScroll = document.getElementById("dwrClock").offsetWidth;
		var yWithScroll = document.getElementById("dwrClock").offsetHeight;
		if (Width <= xWithScroll || Height <= yWithScroll)
			break;
	}
	document.body.style.fontSize = (i - 1) + "px";
	document.body.style.overflow = 'hidden';
	refreshClock();
	setInterval(refreshClock, 500);
}
setTimeout(initClock, 500);
if (typeof GMT !== "undefined" && typeof BASE_URL != "undefined") {
	refhreshTimeDiff();
	setInterval(refhreshTimeDiff, 60000);
}
