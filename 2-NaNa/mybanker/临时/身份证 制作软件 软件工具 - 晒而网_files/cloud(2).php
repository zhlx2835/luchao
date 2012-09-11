var _uly_gcc_delimit = {
	 c : function (_this){
		var res = screen.width+"x"+screen.height;
		var curl = _this.href;
		var ps = _this.getAttribute("cpos");
		var url = "http://log.css.aliyun.com/stat.gif?pui=pwb&ch=ss_drag&l=click&ft=block&purl=http%3A%2F%2Fcs12.phpwind.com%2Fcloud.php%3Fa%3Ddelimitjs%26charset%3Dgbk%26bid%3D145262%26sid%3D145262&os=Windows+XP+%28SP2%29&hid=134735923992218&sid=145262&bkt=0&cok=0849f15d6c0565d4b3&&curl="+escape(curl)+"&res="+escape(res)+"&ps="+ps+"&t="+Math.random()*9999;
		this.i(url);
	},
	i : function (url){
		try{
			new Image().src = url+"&_rd="+Math.random()*9999;
		}catch(ex){}
	}
};KISSY.ready(function(S){
	var Event = S.Event, DOM = S.DOM, DOC = document, config, tipsElm;		
	config = {
		container : '#pw_content', 			  
		sizeMax : 20 ,
		sizeMin : 1 ,
		searchURL : 'http://cs12.phpwind.com/cloud.php?a=delimit&charset=gbk&bid=145262&sid=145262',
		timeout: 400
	}
	function DesignatedWordSearch(config){
		var defaultsConfig, isSearch, nowClient, laterId;
		
		isSearch = true;
		
		defaultsConfig = {
			container : DOC.body ,
			sizeMax: Infinity , 
			sizeMin: 0 ,
			timeout: 400
		}		
		config = S.merge(defaultsConfig, config);	
		Event.add(config.container, 'mouseup', timeoutGetSel);
		
		function timeoutGetSel(e){
			nowClient = e;
			if(S.UA.ie === 6 || S.UA.ie === 7 || S.UA.ie === 8){
				e.button == 1 ? e.button = 0 : e.button = 2;
			}
			
			if(isSearch && !(DOM.get('#tips')) && e.button == 0 ){
				isSearch = false;
				laterId = S.later(function(){
					getSel(nowClient);
					isSearch = true;
				}, config.timeout);
			}			
		}
					
		function getSel(e){
			var t = window.getSelection ? window.getSelection() : ( document.getSelection ? document.getSelection() : ( document.selection ? document.selection.createRange().text : "" ));
			title = t.toString()
			if(title.length > config.sizeMin && title.length < config.sizeMax){	
				var loadingElm = loading();
				DOC.body.appendChild(loadingElm);
				position(loadingElm, e, 'loading');
				S.io({
					dataType:'jsonp',
					url: config.searchURL, 
					data:{
						title:title
					},
					success:function (data) {
						var liListNum;
						DOM.remove(loadingElm);
						tipsElm = createTemplate(data, title);
						DOC.body.appendChild(tipsElm);
						Event.add('#J_closep', 'click', closep);
						position(tipsElm, e, 'tips');		
						Event.add(DOC, 'mousedown', reset);
						Event.add('#J_afreshSearch', 'click', afreshSearch)
					}
				});
				S.io({
					dataType:'jsonp',
					url: 'http://log.css.aliyun.com/stat.gif?pui=pwb&ch=ss_drag&l=view&ft=block&purl=http%3A%2F%2Fcs12.phpwind.com%2Fcloud.php%3Fa%3Ddelimitjs%26charset%3Dgbk%26bid%3D145262%26sid%3D145262&os=Windows+XP+%28SP2%29&hid=134735923992218&sid=145262&bkt=0&cok=0849f15d6c0565d4b3&'+'&wd='+escape(title), 
					success:function (data) {}
				});					
			}
		}
		
		function reset(e){
			if(!DOM.contains('#tips',e.target)){
				DOM.remove(tipsElm);
				Event.detach(DOC, 'mousedown');	
			}				
		}
		
		function closep(){
			DOM.remove(tipsElm);
		}
		
		function createTemplate(data, title){
			var template, htmlStr, html, templateData;
			templateData = {
				title : title,
				moreHref : data.moreHref,
				searchResultHTML : data.searchResultHTML
			}	
			template = '<div id="tips" style="position:absolute"><div class="popout"><table cellspacing="0" cellpadding="0" border="0"><tbody><tr><td class="bgcorner1"></td><td class="pobg1"></td><td class="bgcorner2"></td></tr><tr><td class="pobg4"></td><td><div id="box_container" class="popoutContent"><div class="popTop cc">' +
								'<span class="fl w"  style="margin-right:5px;"><img src="http://cs12.phpwind.com/misc/delimit/alisearch_mini_logo.png" align="absmiddle" style="margin-right:5px;"><input type="text" value="{{title}}" id="J_afreshSearchValue" style="margin-right:3px;" /><input type="button" id="J_afreshSearch" value="搜索" /></span>' +
								'<span id="J_closep" class="adel cp">关闭</span>' +
								'</div>' +
								'<style>.pw_ulB em{color:red;}</style>' + 
									'<table width="100%" cellspacing="0" cellpadding="5">' +
										'<tbody>' +
											'<tr>' +
											'<td id="J_contentAfresh">' + 
													'{{#if searchResultHTML != ""}}<ul style="padding:0 10px 0 0;" class="pw_ulB">{{searchResultHTML}}</ul>{{#else}} <div style="padding-right:10px"><span style="font-size:14px;">抱歉，没有找到与"<span class="s1">{{title}}</span>"相关的全部。</span><br><br><p class="mb10 b">相关建议：</p><p class="mb5">&nbsp;&nbsp;&nbsp;看看选取的文字是否有误：</p><p>&nbsp;&nbsp;&nbsp;去掉可能不必要的字词，如“的”、“什么”等</p></div>{{/if}}' +
												'</td>' +
											'</tr>' +
										'</tbody>' +
								'</table><div id="J_moreContent">' +
									'{{#if moreHref != ""}}<div class="popBottom cc">' +
										'<a href="{{moreHref}}" class="s7 fr" target="_blank">更多内容</a>' +
								'</div>{{/if}}</div>' +
								'</div></td><td class="pobg2"></td></tr><tr><td class="bgcorner4"></td><td class="pobg3"></td><td class="bgcorner3"></td></tr></tbody></table></div></div>';
				
			
			htmlStr = S.Template(template).render(templateData);
			html = DOM.create(htmlStr);
			return html
		}
		
		function position(elm, e, type){
			var docWidth = DOM.docWidth() - 280;
			elm.style.display = 'block';								
			switch(type){
				case 'tips' :
					elm.style.top =  ((e.clientY + DOM.scrollTop() - 200) < 0 ? 0 : (e.clientY + DOM.scrollTop() - 200)) + 'px';
					elm.style.left = ((e.clientX + 20) < docWidth  ? e.clientX + 20 : e.clientX - 320) + 'px';
					break;
				case 'loading' :
					elm.style.top =  ((e.clientY + DOM.scrollTop() - 70) < 0 ? 0 : (e.clientY + DOM.scrollTop() - 70)) + 'px';
					elm.style.left = ((e.clientX + 20) < docWidth  ? e.clientX + 20 : e.clientX - 200) + 'px';
					break;
			}
		}
		
		function loading(){
			var template, htmlStr, html;
				template = '<div id="tips" style="position:absolute"><div class="popout"><table cellspacing="0" cellpadding="0" border="0"><tbody><tr><td class="bgcorner1"></td><td class="pobg1"></td><td class="bgcorner2"></td></tr><tr><td class="pobg4"></td><td><div id="box_container" class="popoutContent" style="padding:10px"><img align="absmiddle" alt="loading" src="http://cs10.phpwind.com/misc/delimit/loading.gif" style="margin-right:5px;">正在加载数据...</div></td><td class="pobg2"></td></tr><tr><td class="bgcorner4"></td><td class="pobg3"></td><td class="bgcorner3"></td></tr></tbody></table></div></div>';					
			htmlStr = S.Template(template).render();
			html = DOM.create(htmlStr);
			return html
			}
		function afreshSearch(){
			var loading, loadingHTML,
				contentAfresh = S.get('#J_contentAfresh'),
				moreContent = S.get('#J_moreContent'),
				value = S.get('#J_afreshSearchValue').value;
			
			loading = '<div style="padding:30px 80px;background:#fff;"><img align="absmiddle" alt="loading" src="http://cs10.phpwind.com/misc/delimit/loading.gif" style="margin-right:5px;">正在加载数据...</div>';
			loadingHTML = DOM.create(loading);
			contentAfresh.innerHTML = '';
			moreContent.innerHTML = '';
			contentAfresh.appendChild(loadingHTML);
			
			S.io({
					dataType:'jsonp',
					url: config.searchURL, 
					data:{
						title:value
					},
					success:function (data) {
						contentAfresh.innerHTML = '';
						if(data.searchResultHTML != ''){
							contentAfresh.appendChild(DOM.create('<ul style="padding:0 10px 0 0;" class="pw_ulB">'+ data.searchResultHTML +'</ul>'));
						}else{
							contentAfresh.appendChild(DOM.create('<div style="padding-right:10px"><span style="font-size:14px;">抱歉，没有找到与"<span class="s1">'+ value +'</span>"相关的全部。</span><br><br><p class="mb10 b">相关建议：</p><p class="mb5">&nbsp;&nbsp;&nbsp;看看选取的文字是否有误：</p><p>&nbsp;&nbsp;&nbsp;去掉可能不必要的字词，如“的”、“什么”等</p></div>'));
						}
						
						if(data.moreHref != ""){
							moreContent.appendChild(DOM.create('<div class="popBottom cc"><a href="'+ data.moreHref +'" class="s7 fr" target="_blank">更多内容</a></div>'));
						}					
					}
				});	
		}
	}
	DesignatedWordSearch(config);	
});


function _GT_CloudTracking_delimit(_this){
	var charset = document.charset ? document.charset : document.characterSet;
	var href = window.location.href;
	var curl = _this.href;
	var cpos = _this.getAttribute("cpos");
	var info = _this.getAttribute("info");
	try{
		new Image().src = "http://cs12.phpwind.com/trace.php?a=guesstrace&charset="+escape(charset)+"&purl="+escape(href)+"&curl="+escape(curl)+"&info="+escape(info)+"&cpos="+cpos;
	}catch(ex){}
	_uly_gcc_delimit.c(_this);
}