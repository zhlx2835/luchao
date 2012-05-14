<%!

public boolean isInArray(String sCheck, String[] sList)
{
	boolean bRet;
	
	bRet = false;
	if (sCheck != null)
	{
		for (int i = 0; i < sList.length && !bRet; i++)
		{
			if (sCheck.equals(sList[i])) bRet = true;
		}
	}
	return bRet;
}

%>
