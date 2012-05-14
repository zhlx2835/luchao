<%@ page import="com.autonomy.aci.ActionParameter"%>
<%@ page import="com.autonomy.aci.exceptions.AciException"%>
<%@ page import="com.autonomy.aci.services.ParametricRetrievalFunctionality"%>
<%@ page import="com.autonomy.APSL.PortalService"%>
<%@ page import="com.autonomy.APSL.ServiceFactory"%>
<%@ page import="com.autonomy.portlet.constants.RetrievalConstants"%>
<%@ page import="com.autonomy.utilities.HTTPUtils"%>
<%@ page import="com.autonomy.utilities.StringUtils" %>
<%@ page import="com.autonomy.webapps.utils.parametric.ParametricFieldInfo"%>

<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Iterator"%>
<%@ page import="java.util.List"%>

<%

// Set up services
PortalService service = ServiceFactory.getService(request, response, RetrievalConstants.PORTLET_NAME);

if (service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_PARAMETRIC_INFO) != null)
{
	String modifiedFieldName = service.getRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_MODIFIED_FIELD));
	String newFieldValue     = service.getRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_PARAM_FIELD_PREFIX + modifiedFieldName));

	if (StringUtils.strValid(modifiedFieldName) && StringUtils.strValid(newFieldValue))
	{
		ParametricFieldInfo modifiedFieldInfo = findModifiedField(service, modifiedFieldName);
		modifiedFieldInfo.setSelectedValue(newFieldValue);
	}

	Iterator parametricFields = ((List)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_PARAMETRIC_INFO)).iterator();

	List values 		      = null;
	ParametricFieldInfo fieldInfo = null;

	while (parametricFields.hasNext())
	{
		fieldInfo = (ParametricFieldInfo)parametricFields.next();
		ParametricRetrievalFunctionality parametricFun = service.getIDOLService().useParametricRetrievalFunctionality();
		values = parametricFun.getQueryParametricFieldValues(fieldInfo.getIDOLFieldName(), requiredParametersList(service, fieldInfo.getIDOLFieldName()));
		values.add(0, service.readConfigParameter("ParametricField.topentry", "--- Select ---"));
		fieldInfo.setIDOLValues(values);
	}
}
%>

<%!

// Get the ArrayList of parameters for the parametric select boxes
private ArrayList requiredParametersList(PortalService service, String currentFieldName)
{
	String fieldName = null;
	String fieldValue = null;
	ParametricFieldInfo fieldInfo = null;

	ArrayList parameters = new ArrayList();

	parameters.add(new ActionParameter("text", "*"));

	// Need to set the encoding to UTF8 for the fieldtext
	parameters.add(new ActionParameter("languagetype", "genericUTF8"));
	parameters.add(new ActionParameter("anylanguage", "true"));

	// Sort parametric field values
	parameters.add(new ActionParameter("sort", "Alphabetical"));

	Iterator parametricFields = ((List)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_PARAMETRIC_INFO)).iterator();

	// Fieldtext parameter for restricting parametric fields
	StringBuffer fieldtext = new StringBuffer();

	while (parametricFields.hasNext())
	{
		fieldInfo  = (ParametricFieldInfo)parametricFields.next();
		fieldName  = fieldInfo.getIDOLFieldName();
		fieldValue = service.getRequestParameter(service.makeParameterName(RetrievalConstants.REQUEST_PARAM_PARAM_FIELD_PREFIX + fieldInfo.getDisplayName()));

		if (StringUtils.strValid(fieldValue)
		    && !fieldValue.trim().equals(service.readConfigParameter("ParametricField.topentry", "--- Select ---"))
		    && !fieldName.equals(currentFieldName))
		{
			// Add '+AND+' if there are some restrictions in the fieldtext already
			if(fieldtext.length() != 0)
			{
				fieldtext.append("+AND+");
			}
			fieldtext.append("MATCH{").append(HTTPUtils.URLEncode(fieldValue.trim(), "utf-8")).append("}:*/").append(fieldInfo.getIDOLFieldName());
		}
	}

	// Add restrictions if there are any
	if(fieldtext.length() != 0)
	{
		parameters.add(new ActionParameter("fieldtext", fieldtext.toString()));
	}

	return parameters;
}

private ParametricFieldInfo findModifiedField(PortalService service, String modifiedFieldName)
{
	ParametricFieldInfo modifiedField = null;
	Iterator parametricFields = ((List)service.getSessionAttribute(RetrievalConstants.SESSION_ATTRIB_PARAMETRIC_INFO)).iterator();
	while(parametricFields.hasNext() && modifiedField == null)
	{
			ParametricFieldInfo fieldInfo = (ParametricFieldInfo)parametricFields.next();
			if(modifiedFieldName.equals(fieldInfo.getDisplayName()))
			{
				modifiedField = fieldInfo;
			}
	}

	return modifiedField;
}

private void mylog(String s)
{
	System.out.println("updatePF.jsp: " + s);
}
%>
