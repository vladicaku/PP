var e=this;Math.random();var l=function(a,b){var c=a.split("."),d=e;c[0]in d||!d.execScript||d.execScript("var "+c[0]);for(var f;c.length&&(f=c.shift());)c.length||void 0===b?d=d[f]?d[f]:d[f]={}:d[f]=b},n=function(a,b){function c(){}c.prototype=b.prototype;a.o=b.prototype;a.prototype=new c;a.m=function(a,c,g){for(var k=Array(arguments.length-2),h=2;h<arguments.length;h++)k[h-2]=arguments[h];return b.prototype[c].apply(a,k)}};var p=function(a){if(Error.captureStackTrace)Error.captureStackTrace(this,p);else{var b=Error().stack;b&&(this.stack=b)}a&&(this.message=String(a))};n(p,Error);var aa=function(a,b){for(var c=a.split("%s"),d="",f=Array.prototype.slice.call(arguments,1);f.length&&1<c.length;)d+=c.shift()+f.shift();return d+c.join("%s")},q=String.prototype.trim?function(a){return a.trim()}:function(a){return a.replace(/^[\s\xa0]+|[\s\xa0]+$/g,"")},t=function(a,b){return a<b?-1:a>b?1:0};Math.random();var u=function(a,b){b.unshift(a);p.call(this,aa.apply(null,b));b.shift()};n(u,p);var w=function(a,b,c){if(!a){var d="Assertion failed";if(b)var d=d+(": "+b),f=Array.prototype.slice.call(arguments,2);throw new u(""+d,f||[]);}};var x;a:{var y=e.navigator;if(y){var z=y.userAgent;if(z){x=z;break a}}x=""}var A=function(a){return-1!=x.indexOf(a)};var B=function(){return A("Opera")||A("OPR")},C=function(){return(A("Chrome")||A("CriOS"))&&!B()&&!A("Edge")};var ba=B(),D=A("Trident")||A("MSIE"),ca=A("Edge"),E=A("Gecko")&&!(-1!=x.toLowerCase().indexOf("webkit")&&!A("Edge"))&&!(A("Trident")||A("MSIE"))&&!A("Edge"),G=-1!=x.toLowerCase().indexOf("webkit")&&!A("Edge"),da=G&&A("Mobile"),ea=function(){var a=x;if(E)return/rv\:([^\);]+)(\)|;)/.exec(a);if(ca)return/Edge\/([\d\.]+)/.exec(a);if(D)return/\b(?:MSIE|rv)[: ]([^\);]+)(\)|;)/.exec(a);if(G)return/WebKit\/(\S+)/.exec(a)},H=function(){var a=e.document;return a?a.documentMode:void 0},I=function(){if(ba&&e.opera){var a;
var b=e.opera.version;try{a=b()}catch(c){a=b}return a}a="";(b=ea())&&(a=b?b[1]:"");return D&&(b=H(),b>parseFloat(a))?String(b):a}(),J={},K=function(a){if(!J[a]){for(var b=0,c=q(String(I)).split("."),d=q(String(a)).split("."),f=Math.max(c.length,d.length),g=0;0==b&&g<f;g++){var k=c[g]||"",h=d[g]||"",m=RegExp("(\\d*)(\\D*)","g"),F=RegExp("(\\d*)(\\D*)","g");do{var r=m.exec(k)||["","",""],v=F.exec(h)||["","",""];if(0==r[0].length&&0==v[0].length)break;b=t(0==r[1].length?0:parseInt(r[1],10),0==v[1].length?
0:parseInt(v[1],10))||t(0==r[2].length,0==v[2].length)||t(r[2],v[2])}while(0==b)}J[a]=0<=b}},L=e.document,fa=L&&D?H()||("CSS1Compat"==L.compatMode?parseInt(I,10):5):void 0;var M;if(!(M=!E&&!D)){var N;if(N=D)N=9<=fa;M=N}M||E&&K("1.9.1");D&&K("9");!A("Android")||C()||A("Firefox")||B();C();var ga=A("Safari")&&!(C()||A("Coast")||B()||A("Edge")||A("Silk")||A("Android"))&&!(A("iPhone")&&!A("iPod")&&!A("iPad")||A("iPad")||A("iPod"));var P=function(a){var b=window;if(da&&ga&&b){b.focus();var c=0,d=null,d=b.setInterval(function(){a.closed||5==c?(b.clearInterval(d),O(a)):(a.close(),c++)},150)}else a.close(),O(a)},O=function(a){if(!a.closed&&a.document&&a.document.body)if(a=a.document.body,w(null!=a,"goog.dom.setTextContent expects a non-null value for node"),"textContent"in a)a.textContent="Please close this window.";else if(3==a.nodeType)a.data="Please close this window.";else if(a.firstChild&&3==a.firstChild.nodeType){for(;a.lastChild!=
a.firstChild;)a.removeChild(a.lastChild);a.firstChild.data="Please close this window."}else{for(var b;b=a.firstChild;)a.removeChild(b);w(a,"Node cannot be null or undefined.");a.appendChild((9==a.nodeType?a:a.ownerDocument||a.document).createTextNode("Please close this window."))}};var Q,R=function(a){a=a||[];for(var b=[],c=0,d=a.length;c<d;++c){var f=String(a[c]||"");f&&b.push(f)}if(!b.length)return null;Q?Q.reset.call(Q):Q=shindig.sha1();Q.update.call(Q,b.join(" "));return Q.digestString.call(Q).toLowerCase()},ha=function(a,b,c){this.i=String(a||"");this.f=String(b||"");this.a=String(c||"");this.b={};this.j=this.l=this.g=this.h="";this.c=null};
ha.prototype.evaluate=function(){var a={},b="";try{b=String(document.cookie||"")}catch(c){}for(var b=b.split("; ").join(";").split(";"),d=0,f=b.length;d<f;++d){var g=b[d],k=g.indexOf("=");-1!=k?a[g.substr(0,k)]=g.substr(k+1):a[g]=null}this.b=a;if(this.b.SID)if(this.f=this.f.split(".")[0].split("@")[0],a="",a=0==this.i.indexOf("https://")?"SAPISID":"APISID",this.g=String(this.b[a]||""))if(a="",a=0==gadgets.rpc.getOrigin(String(window.location.href)).indexOf("https://")?"SAPISID":"APISID",this.h=String(this.b[a]||
"")){b=String(this.b.LSOLH||"").split(":");d=b.length;if(1==d||4==d)this.l=b[0];if(3==d||4==d)a=String(b[d-3]||""),b=String(b[d-1]||""),(d=R([a,this.h]).substr(0,4))&&d==b&&(this.j=a);this.a&&(a=this.a.indexOf("."),-1!=a&&(a=this.a.substr(0,a)||"",this.a=a+"."+R([this.g,this.i,this.f,this.l,this.j,a]).substr(0,4)));a=R([this.g,this.i,this.f,this.a]);this.a&&(a=a+"."+this.a);this.c=a}else this.c="";else this.c=""};
var ia=function(a,b,c){a=new ha(a,b,c);a.evaluate();return a},S=function(a,b,c){c=c||ja(this);var d=null;if(a){a=String(a);var f=a.indexOf(".");-1!=f&&(d=a.substr(f+1))}b=ia(c,b,d).c;if(null==a||""==a)a=b==a;else if(null==b||b.length!=a.length)a=!1;else{d=c=0;for(f=a.length;d<f;++d)c|=a.charCodeAt(d)^b.charCodeAt(d);a=0==c}return a},T=function(a,b,c){c=c||ja(this);c=ia(c);if(String(a)!=c.c)throw Error("Unauthorized request");b=String(b);a=parseInt(b,10);String(a)==b&&0<=a?(b=c.j)?(b=b.split("|"),
a=b.length<=a?null:b[a]||null):a=null:a=null;return a},ja=function(a){a=String(a.origin||"");if(!a)throw Error("RPC has no origin.");return a};l("checkSessionState",S);l("getVersionInfo",T);var U,V,W,X,Y,Z,ka=window,la=(window.location.href||ka.location.href).match(/.*(\?|#|&)usegapi=([^&#]+)/)||[];
"1"===decodeURIComponent(la[la.length-1]||"")?(W=function(a,b,c,d,f,g){U.send(b,f,d,g||gapi.iframes.CROSS_ORIGIN_IFRAMES_FILTER)},X=function(a,b){U.register(a,b,gapi.iframes.CROSS_ORIGIN_IFRAMES_FILTER)},Y=function(a){var b=/^(?:https?:\/\/)?[0-9.\-A-Za-z]+(?::\d+)?/.exec(a),b=gapi.iframes.makeWhiteListIframesFilter([b?b[0]:null]);W("..","oauth2callback",gadgets.rpc.getAuthToken(".."),void 0,a,b)},V=function(){ma()},Z=function(){W("..","oauth2relayReady",gadgets.rpc.getAuthToken(".."));X("check_session_state",
na);X("get_versioninfo",oa)}):(W=function(a,b,c,d,f){gadgets.rpc.call(a,b+":"+c,d,f)},X=function(a,b){gadgets.rpc.register(a,b)},Y=function(a){gadgets.rpc.getTargetOrigin("..")==gadgets.rpc.getOrigin(a)&&W("..","oauth2callback",gadgets.rpc.getAuthToken(".."),void 0,a)},V=function(){Z()},Z=function(){W("..","oauth2relayReady",gadgets.rpc.getAuthToken(".."));X("check_session_state",S);X("get_versioninfo",T)});
var ma=function(){var a=Z;window.gapi.load("gapi.iframes",function(){U=gapi.iframes.getContext().getParentIframe();a()})},pa=function(a){window.setTimeout(function(){Y(a)},1)},na=function(a){var b,c;a&&(b=a.session_state,c=a.client_id);return S(b,c,U.getOrigin())},oa=function(a){return T(a.xapisidHash,a.sessionIndex,U.getOrigin())};l("oauth2callback",pa);
l("oauth2verify",function(a,b){var c=window.open("javascript:void(0);",a),d;if(c&&!c.closed&&(d=c.oauth2callbackUrl))return window.timeoutMap=window.timeoutMap||{},window.realSetTimeout=window.realSetTimeout||window.setTimeout,window.setTimeout=function(a,b){try{var d=a,h=!1,m;a=function(){if(!h){h=!0;try{window.timeoutMap[String(m)]=void 0,delete window.timeoutMap[String(m)]}catch(a){}return d.call(this)}};var F=c.setTimeout(a,b);m=window.realSetTimeout(a,b);window.timeoutMap[String(m)]=F;return m}catch(r){}return window.realSetTimeout(a,
b)},window.realClearTimeout=window.realClearTimeout||window.clearTimeout,window.clearTimeout=function(a){try{var b=window.timeoutMap[String(a)];b&&c.clearTimeout(b)}catch(d){}try{window.timeoutMap[String(a)]=void 0,delete window.timeoutMap[String(a)]}catch(h){}window.realClearTimeout(a)},pa(String(d)),"keep_open"!=b&&P(c),!0;c&&!c.closed&&P(c);return!1});window.addEventListener?window.addEventListener("load",V,!1):window.attachEvent("onload",V);