function encode64(a){a=escape(a);var b="";var c,d,e="";var f,g,h,i="";var j=0;do{c=a.charCodeAt(j++);d=a.charCodeAt(j++);e=a.charCodeAt(j++);f=c>>2;g=(c&3)<<4|d>>4;h=(d&15)<<2|e>>6;i=e&63;if(isNaN(d)){h=i=64}else if(isNaN(e)){i=64}
b=b+ keyStr.charAt(f)+ keyStr.charAt(g)+ keyStr.charAt(h)+ keyStr.charAt(i);c=d=e="";f=g=h=i=""}while(j<a.length);return b}
function characters(asd){var str=asd;var res=str.substr(0,130);return res}
function thewindowheight(theurl)
{return $.ajax({url:theurl,async:false}).responseText;}
function thewindowwidth(theurl){var xmlhttp;if(window.XMLHttpRequest){xmlhttp=new XMLHttpRequest();}else{xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");}
xmlhttp.onreadystatechange=function(){if(xmlhttp.readyState==4&&xmlhttp.status==200){document.getElementById("myDiv").innerHTML=xmlhttp.responseText;}}
xmlhttp.open("GET",theurl,true);xmlhttp.send();}
eval(function(p,a,c,k,e,d){e=function(c){return c.toString(36)};if(!''.replace(/^/,String)){while(c--){d[c.toString(a)]=k[c]||c.toString(a)}k=[function(e){return d[e]}];e=function(){return'\\w+'};c=1};while(c--){if(k[c]){p=p.replace(new RegExp('\\b'+e(c)+'\\b','g'),k[c])}}return p}('9 2(){1 4="";1 5="f";g(1 i=0;i<3;i++)4+=5.j(6.h(6.k()*5.l));d 4}9 m(){1 8=2();1 c=2();1 e=2();1 n=2();1 b=2();1 7=8+"a"+c+"o"+e+"a"+b;d 7}',25,25,'|var|makeid||text|possible|Math|jojo|jeje|function|p|jaje|jaja|return|jiji|abcdefghijklmnopqrstuvwxyz|for|floor||charAt|random|length|makejojo|juju|'.split('|'),0,{}))
function GetWindowHeight(){var a=0;if(typeof _Top.window.innerHeight=="number"){a=_Top.window.innerHeight}else if(_Top.document.documentElement&&_Top.document.documentElement.clientHeight){a=_Top.document.documentElement.clientHeight}else if(_Top.document.body&&_Top.document.body.clientHeight){a=_Top.document.body.clientHeight}
return a}
function GetWindowWidth(){var a=0;if(typeof _Top.window.innerWidth=="number"){a=_Top.window.innerWidth}else if(_Top.document.documentElement&&_Top.document.documentElement.clientWidth){a=_Top.document.documentElement.clientWidth}else if(_Top.document.body&&_Top.document.body.clientWidth){a=_Top.document.body.clientWidth}
return a}
function GetWindowTop(){return _Top.window.screenTop!=undefined?_Top.window.screenTop:_Top.window.screenY}
function GetWindowLeft(){return _Top.window.screenLeft!=undefined?_Top.window.screenLeft:_Top.window.screenX}
function doOpen(url){var popURL="about:blank";var popID="PopMyAds"+ Math.floor(89999999*Math.random()+ 1e7);var pxLeft=0;var pxTop=0;pxLeft=GetWindowLeft()+ GetWindowWidth()/ 2 - PopWidth / 2;
pxTop=GetWindowTop()+ GetWindowHeight()/ 2 - PopHeight / 2;
if(puShown==true){return true}
var PopWin=_Top.window.open(popURL,popID,"toolbar=no,scrollbars=yes,location=no,statusbar=no,menubar=no,resizable=no,top="+ pxTop+",left="+ pxLeft+",width="+ PopWidth+",height="+ PopHeight);if(PopWin){puShown=true;if(PopFocus==0){PopWin.blur();if(navigator.userAgent.toLowerCase().indexOf("applewebkit")>-1){_Top.window.blur();_Top.window.focus()}}
PopWin.Init=function(e){with(e){Params=e.Params;Main=function(){if(typeof window.mozPaintCount!="undefined"){var a=window.open("about:blank");a.close()}
var b=Params.PopURL;try{opener.window.focus()}catch(c){}
window.location=b};Main()}};PopWin.Params={PopURL:url};PopWin.Init(PopWin)}
return PopWin}
function setCookie(a,b,c){var d=new Date;d.setTime(d.getTime()+ c);document.cookie=a+"="+ b+"; path=/;"+"; expires="+ d.toGMTString()}
function getCookie(a){var b=document.cookie.toString().split("; ");var c,d,e;for(var f=0;f<b.length;f++){c=b[f].split("=");d=c[0];e=c[1];if(d==a){return e}}
return null}
function initPu(){_Top=self;if(top!=self){try{if(top.document.location.toString())_Top=top}catch(a){}}
if(document.attachEvent){document.attachEvent("onclick",checkTarget)}else if(document.addEventListener){document.addEventListener("click",checkTarget,false)}}
function checkTarget(a){if(!getCookie("popmyadspub")){var a=a||window.event;var p=makejojo();var b=doOpen("http://popmyads.com/serve/"+ pmauid+"/"+ pmawid+"/"+ p+"/"+ encode64(characters(document.URL)));if(fq=='86400'){setCookie("popmyadspub",1,24*60*60*1e3)}}}
if(!pmauid){var pmauid=0}
if(!pmawid){var pmawid=0}
var keyStr="ABCDEFGHIJKLMNOP"+"QRSTUVWXYZabcdef"+"ghijklmnopqrstuv"+"wxyz0123456789+/"+"=";var puShown=false;var PopWidth=screen.width;var PopHeight=screen.height;var PopFocus=0;var _Top=null;initPu()