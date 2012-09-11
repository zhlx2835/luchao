var _uly_gcc_pop = {
	 c : function (_this){
		var res = screen.width+"x"+screen.height;
		var curl = _this.href;
		var ps = _this.getAttribute("cpos");
		var url = "http://log.css.aliyun.com/stat.gif?pui=pwb&ch=wpr_pop&l=click&ft=block&purl=http%3A%2F%2Fcs12.phpwind.com%2Fcloud.php%3Fa%3Dpop%26charset%3Dgbk%26bid%3D145262%26sid%3D145262%26fid%3D3%26uid%3D3%26tid%3D270%26title%3D%25C9%25ED%25B7%25DD%25D6%25A4%2520%25D6%25C6%25D7%25F7%25C8%25ED%25BC%25FE%26v%3D1.1&os=Windows+XP+%28SP2%29&hid=134736181242701&sid=145262&bkt=0&cok=0849f15d6c0565d4b3&&curl="+escape(curl)+"&res="+escape(res)+"&ps="+ps+"&t="+Math.random()*9999;
		this.i(url);
	},
	i : function (url){
		try{
			new Image().src = url+"&_rd="+Math.random()*9999;
		}catch(ex){}
	}
};document.write('\
<link href="http://cs12.phpwind.com/misc/pop/css.css?v=1" rel="stylesheet" type="text/css" />\
<div class="aliSh_pop_like" id="aliSh_pop_like">\
	<h2 id="aliSh_slide_handler"><a href="javascript:;" class="aliSh_close" id="aliSh_pop_toggle">关闭</a>猜你喜欢</strong></h2>	<div class="aliSh_pop_content_left" id="aliSh_pop_content">\
	<ul>\
		<li><a onmousedown="_GT_Pop_CloudTracking(this)" target="_blank" href="http://www.eqishare.com/read.php?tid=486" cpos="1" info="MTEyNTJfMTQ1MjYyXzE0NTI2Ml8zXzQ4Nl9ndWVzc3BvcA==" title="2012美国最新火爆票房科幻巨作《普罗米修斯》【DVD-MKV....">2012美国最新火爆票房科幻巨作《普罗米修斯》【DVD-MKV....</a></li><li><a onmousedown="_GT_Pop_CloudTracking(this)" target="_blank" href="http://www.eqishare.com/read.php?tid=484" cpos="2" info="MTA1NV8xNDUyNjJfMTQ1MjYyXzNfNDg0X2d1ZXNzcG9w" title="《复仇者联盟》中英字幕高清版下载地址">《复仇者联盟》中英字幕高清版下载地址</a></li><li><a onmousedown="_GT_Pop_CloudTracking(this)" target="_blank" href="http://www.eqishare.com/read.php?tid=482" cpos="3" info="MTU5OTRfMTQ1MjYyXzE0NTI2Ml8zXzQ4Ml9ndWVzc3BvcA==" title="猎豹浏览器-全球首款双核安全浏览器">猎豹浏览器-全球首款双核安全浏览器</a></li><li><a onmousedown="_GT_Pop_CloudTracking(this)" target="_blank" href="http://www.eqishare.com/read.php?tid=479" cpos="4" info="MTY3NDdfMTQ1MjYyXzE0NTI2Ml8zXzQ3OV9ndWVzc3BvcA==" title="《听风者》2012最新梁朝伟、周迅悬疑剧情大片【高清1280完整版BD...">《听风者》2012最新梁朝伟、周迅悬疑剧情大片【高清1280完整版BD...</a></li><li><a onmousedown="_GT_Pop_CloudTracking(this)" target="_blank" href="http://www.eqishare.com/read.php?tid=474" cpos="5" info="NDMwOF8xNDUyNjJfMTQ1MjYyXzNfNDc0X2d1ZXNzcG9w" title="王全安导演陈忠实编剧陈忠实长篇小说《白鹿原》改编 高清下载...">王全安导演陈忠实编剧陈忠实长篇小说《白鹿原》改编 高清下载...</a></li>	</ul>\
	</div>\
	</div>');

function _GT_Pop_CloudTracking(_this){
	var charset = document.charset ? document.charset : document.characterSet;
	var href = window.location.href;
	var curl = _this.href;
	var cpos = _this.getAttribute("cpos");
	var info = _this.getAttribute("info");
	try{
		new Image().src = "http://cs12.phpwind.com/trace.php?a=guesstrace&charset="+escape(charset)+"&purl="+escape(href)+"&curl="+escape(curl)+"&info="+escape(info)+"&cpos="+cpos;
	}catch(ex){}
	_uly_gcc_pop.c(_this);
}


(function(){
	var addEvent = document.addEventListener ? function(el,type,callback){
			  el.addEventListener( type, callback, !1 );
			} : function(el,type,callback){
			  el.attachEvent( "on" + type, callback );
			}
	function setCookie(name,value,day){
		var exp=new Date();
		exp.setTime(exp.getTime()+day*24*60*60*1000);
		document.cookie=name+"="+escape(value)+";expires="+exp.toGMTString();
	}
	function getCookie(name){
		var arr=document.cookie.match(new RegExp("(^| )"+name+"=([^;]*)(;|$)"));
		if(arr!=null){
			return unescape(arr[2]);
		}
		return null;
	}
	function delCookie(name){
		var exp=new Date();
		exp.setTime(exp.getTime()-1);
		var cval=getCookie(name);
		if(cval!=null){
			document.cookie=name+"="+cval+";expires="+exp.toGMTString();
		}
	}
	function getStyle(ele,style){
		if(document.defaultView){
			return document.defaultView.getComputedStyle(ele,null)[style];
		}else{
			return ele.currentStyle[style];
		}
	}
	var PopCloudSearch=function(opt){
		if(!opt){
			return false;
		}
		this.obj=document.getElementById(opt.obj);
		this.content=document.getElementById(opt.content);
		this.toggleBtn=document.getElementById(opt.toggleBtn);
		this.cookieName='cloud_search';
		this.cookieValue=1;
		this.day=1;
		this.mode=opt.mode;//妯″紡  pop  slide
		this.defaultView=opt.defaultView;
		this.currentView=opt.currentView;
		this.gw=opt.gw;
		this.gh=opt.gh;
		this.inter=null;
	}
	PopCloudSearch.prototype={
		init:function(){
			var self=this;
			if(getCookie(this.cookieName)==null){
				//this.content.style.width=(this.mode=="pop")?this.gw:0+"px";
				this.content.style.marginLeft=(this.mode=="pop")?0:this.gw+"px";
				this.content.style.height=this.gh+"px";
			}else{
				//this.content.style.width=this.gw+"px";
				this.content.style.marginLeft=0;
				this.content.style.height=(this.mode=="pop")?0:this.gh+"px";
				this.currentView=(this.mode=="pop")?"close":"open";
				this.toggleBtn.className=(this.mode=="pop")?"aliSh_open":"aliSh_close";
				if(this.mode=="slide"){
					this.toggleBtn.getElementsByTagName("em")[0].innerHTML="&lt;&lt;";
				}
			}
				var handler=document.getElementById("aliSh_slide_handler");
				addEvent(handler,"click",function(){
					if(self.inter){
						clearTimeout(self.inter);
					}
					if(self.currentView=="close"){
						self.show();
						self.toggleBtn.className="aliSh_close";
						self.currentView="open";
					}else{
						self.hide();
						self.toggleBtn.className="aliSh_open";
						self.currentView="close";
					}
				})
		},
		show:function(){
			if(this.mode=="slide"){
				setCookie(this.cookieName,this.cookieValue,this.day);
			}else{
				delCookie(this.cookieName);
			}
			this.toggleBtn.className="aliSh_close";
			if(this.mode=="pop"){
				this.run(this.content,this.gw,this.gh,50);
				this.toggleBtn.innerHTML="鍏抽棴";
			}else if(this.mode=="slide"){
				this.run(this.content,0,this.gh,50);
				this.toggleBtn.getElementsByTagName("em")[0].innerHTML="&lt;&lt;";
			}
		},
		hide:function(){
			if(this.mode=="pop"){
				setCookie(this.cookieName,this.cookieValue,this.day);
			}else{
				delCookie(this.cookieName);
			}
			var w=parseInt(getStyle(this.content,"width"));
			this.toggleBtn.className="aliSh_open";
			if(this.mode=="pop"){
				this.run(this.content,this.gw,0,50);
				this.toggleBtn.innerHTML="鎵撳紑";
			}else if(this.mode=="slide"){
				this.run(this.content,this.gw,this.gh,50);
				this.toggleBtn.getElementsByTagName("em")[0].innerHTML="&gt;&gt;";
			}
		},
		run:function(obj,fw,fh,interval){
			var self=this;
			var xpos=parseInt(getStyle(obj,"marginLeft"));
			var ypos=parseInt(getStyle(obj,"height"));
			if(xpos==fw&&ypos==fh){
				return false;
			}
			if(xpos>fw){
				var dist=Math.ceil((fw-xpos)/3);
				xpos=xpos+dist;
			}
			if(xpos<fw){
				var dist=Math.ceil((fw-xpos)/3);
				xpos=xpos+dist;
			}
			if(xpos<self.gw+3&&xpos>self.gw){
				obj.style.marginLeft=self.gw+"px";
				return false;
			}
			if(ypos>fh){
				var dist=Math.ceil((fh-ypos)/3);
				ypos=ypos+dist;
			}
			if(ypos<fh){
				var dist=Math.ceil((fh-ypos)/3);
				ypos=ypos+dist;
			}
			if(ypos<3&&ypos>0){
				ypos=0
			}
			obj.style.marginLeft=xpos+"px";
			obj.style.height=ypos+"px";
			self.inter=setTimeout(function(){
					self.run(obj,fw,fh,interval);
				},interval);
		}
	}
	var height = 25 + 5 * 21;
	var popConf={gw:0,gh:height,obj:"aliSh_pop_like",content:"aliSh_pop_content",toggleBtn:"aliSh_pop_toggle",mode:"pop",defaultView:"close",currentView:"close"};
	var slideConf={gw:-160,gh:height,obj:"aliSh_pop_like_left",content:"aliSh_pop_like_left",toggleBtn:"aliSh_pop_toggle",mode:"slide",defaultView:"close",currentView:"close"};
	new PopCloudSearch(popConf).init();
	_uly_gcc_pop.i("http://log.css.aliyun.com/stat.gif?pui=pwb&ch=wpr_pop&l=view&ft=block&purl=http%3A%2F%2Fcs12.phpwind.com%2Fcloud.php%3Fa%3Dpop%26charset%3Dgbk%26bid%3D145262%26sid%3D145262%26fid%3D3%26uid%3D3%26tid%3D270%26title%3D%25C9%25ED%25B7%25DD%25D6%25A4%2520%25D6%25C6%25D7%25F7%25C8%25ED%25BC%25FE%26v%3D1.1&os=Windows+XP+%28SP2%29&hid=134736181242701&sid=145262&bkt=0&cok=0849f15d6c0565d4b3&");
})()

