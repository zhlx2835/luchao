			window.name = "mainFrame";
			function getDate()
			{
				var IE = navigator.appName.indexOf("Microsoft") != -1;
				var IE4 = IE && navigator.appVersion.indexOf("4.") != -1;
				var IE3 = IE && navigator.appVersion.indexOf("2.") != -1;
				var Netscape = navigator.appName.indexOf("Netscape") != -1;
				var sDate = "";

				now = new Date()
				if(0 == now.getDay())
					sDate += "Sun,&nbsp;"
				else if(1 == now.getDay())
					sDate += "Mon,&nbsp;";
				else if(2 == now.getDay())
					sDate += "Tue,&nbsp;";
				else if(3 == now.getDay())
					sDate += "Wed,&nbsp;";
				else if(4 == now.getDay())
					sDate += "Thu,&nbsp;";
				else if(5 == now.getDay())
					sDate += "Fri,&nbsp;";
				else if(6 == now.getDay())
					sDate += "Sat,&nbsp;";

				now = new Date();
				sDate += now.getDate();

				if(0 == now.getMonth())
					sDate += "&nbsp;Jan ";
				else if(1 == now.getMonth())
					sDate += "&nbsp;Feb&nbsp;";
				else if(2 == now.getMonth())
					sDate += "&nbsp;Mar&nbsp;";
				else if(3 == now.getMonth())
					sDate += "&nbsp;Apr&nbsp;";
				else if(4 == now.getMonth())
					sDate += "&nbsp;May&nbsp;";
				else if(5 == now.getMonth())
					sDate += "&nbsp;Jun&nbsp;";
				else if(6 == now.getMonth())
					sDate += "&nbsp;Jul&nbsp;";
				else if(7 == now.getMonth())
					sDate += "&nbsp;Aug&nbsp;";
				else if(8 == now.getMonth())
					sDate += "&nbsp;Sep&nbsp;";
				else if(9 == now.getMonth())
					sDate += "&nbsp;Oct&nbsp;";
				else if(10 == now.getMonth())
					sDate += "&nbsp;Nov&nbsp;";
				else if(11 == now.getMonth())
					sDate += "&nbsp;Dec&nbsp;";

				if(IE4 || Netscape)
					sDate += now.getFullYear();
				else
					sDate += now.getYear()+1900;

				return sDate;
			}

			function jf_confirmDeletePortlet(fForm)
			{
				bCnfrm = confirm('Are you sure you want to remove this portlet?');
				if(bCnfrm)
				{
					fForm.submit();
				}
			}

			function jf_isValidString(sString)
			{
				for(i = 0; i < sString.length; i++)
				{
					cToValidate = sString.charAt(i);
					if(cToValidate == "<%="<"%>" || cToValidate == "<%=">"%>" || cToValidate == "\"")
					{
						return false;
					}
				}
				return true;
			}

			function jf_confirmDeleteAgent(fForm)
			{
				bCnfrm = confirm('Are you sure you want to delete this agent?');
				return bCnfrm;
			}

			function selectAll(objCheckboxes, bChecked)
			{
				if(objCheckboxes.type == "checkbox")
				{
					//One checkbox as opposed to an array of them
					//
					objCheckboxes.checked = bChecked;
				}
				else
				{
					for(i = 0; i < objCheckboxes.length; i++)
					{
						objCheckboxes[i].checked = bChecked;
					}
				}
			}

			function imgswap( theImage, bColour )
			{
				if( !bColour )
				{
					var n = theImage.src.lastIndexOf("_col.");
					if( n > -1)
						theImage.src = theImage.src.substring(0, n) + theImage.src.substring(n+4);
				}
				else
				{
					var n = theImage.src.lastIndexOf(".");
					if( n > -1)
						theImage.src = theImage.src.substring(0, n) + "_col" + theImage.src.substring(n);
						
				}
			}
