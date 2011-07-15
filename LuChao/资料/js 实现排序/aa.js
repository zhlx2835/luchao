function ieOrFireFox(ob)
{
    if (ob.textContent != null)
	return ob.textContent;
    var s = ob.innerText;
    return s.substring(0, s.length);
}

//���� tableId: ���id,iCol:�ڼ��� ��dataType��iCol��Ӧ������ʾ���ݵ���������
function sortAble(tableId, iCol, dataType) {
	var table = document.getElementById(tableId);
	var tbody = table.tBodies[0];
	var colRows = tbody.rows;
	var aTrs = new Array;
         //�����õ����з������飬����
	for (var i=0; i < colRows.length; i++) {
		aTrs[i] = colRows[i];
	}
                      
                 
	//�ж���һ�����е��к�������Ҫ���е��Ƿ�ͬһ����
	if (table.sortCol == iCol) {
		aTrs.reverse();
	} else {
		//�������ͬһ�У�ʹ�������sort����������������
		aTrs.sort(compareEle(iCol, dataType));
	}
        
	var oFragment = document.createDocumentFragment();
                
	for (var i=0; i < aTrs.length; i++) {
		oFragment.appendChild(aTrs[i]);
	}                
	tbody.appendChild(oFragment);
	//��¼���һ�������������
	table.sortCol = iCol;
}
//���е�����ת������Ӧ�Ŀ������е���������
function convert(sValue, dataType) {
	switch(dataType) {
	case "int":
		return parseInt(sValue);
	case "float":
		return parseFloat(sValue);
	case "date":
		return new Date(Date.parse(sValue));
	default:
		return sValue.toString();
    }
}
            
//��������iCol��ʾ��������dataType��ʾ���е���������
function compareEle(iCol, dataType) {
	return  function (oTR1, oTR2) {
		var vValue1 = convert(ieOrFireFox(oTR1.cells[iCol]), dataType);
		var vValue2 = convert(ieOrFireFox(oTR2.cells[iCol]), dataType);
		if (vValue1 < vValue2) {
			return -1;
		} else if (vValue1 > vValue2) {
			return 1;
		} else {
			return 0;
		}
       };
}