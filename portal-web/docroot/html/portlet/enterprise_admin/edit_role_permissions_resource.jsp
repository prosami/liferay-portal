<%
/**
 * Copyright (c) 2000-2009 Liferay, Inc. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
%>

<%@ include file="/html/portlet/enterprise_admin/init.jsp" %>

<%
Role role = (Role)request.getAttribute("edit_role_permissions.jsp-role");

String portletResource = (String)request.getAttribute("edit_role_permissions.jsp-portletResource");

String curPortletResource = (String)request.getAttribute("edit_role_permissions.jsp-curPortletResource");
String curModelResource = (String)request.getAttribute("edit_role_permissions.jsp-curModelResource");
String curModelResourceName = (String)request.getAttribute("edit_role_permissions.jsp-curModelResourceName");

List curActions = ResourceActionsUtil.getResourceActions(curPortletResource, curModelResource);

curActions = ListUtil.sort(curActions, new ActionComparator(company.getCompanyId(), locale));

List guestUnsupportedActions = ResourceActionsUtil.getResourceGuestUnsupportedActions(curPortletResource, curModelResource);

List<String> headerNames = new ArrayList<String>();

headerNames.add("action");

if (role.getType() == RoleConstants.TYPE_REGULAR) {
	headerNames.add("scope");
	headerNames.add(StringPool.BLANK);
}

SearchContainer searchContainer = new SearchContainer(renderRequest, null, null, SearchContainer.DEFAULT_CUR_PARAM, SearchContainer.DEFAULT_DELTA, renderResponse.createRenderURL(), headerNames, "there-are-no-actions-available-for-selection");

searchContainer.setRowChecker(new ResourceActionRowChecker(renderResponse));

int total = curActions.size();

searchContainer.setTotal(total);

searchContainer.setResults(curActions);

List resultRows = searchContainer.getResultRows();

for (int i = 0; i < curActions.size(); i++) {
	String actionId = (String)curActions.get(i);

	if (role.getName().equals(RoleConstants.GUEST) && guestUnsupportedActions.contains(actionId)) {
		continue;
	}

	String curResource = null;

	if (Validator.isNull(curModelResource)) {
		curResource = curPortletResource;
	}
	else {
		curResource = curModelResource;
	}

	String target = curResource + actionId;

	List groups = Collections.EMPTY_LIST;
	String groupIds = ParamUtil.getString(request, "groupIds" + target, null);
	long[] groupIdsArray = StringUtil.split(groupIds, 0L);

	List groupNames = new ArrayList();

	int scope;

	if (role.getType() == RoleConstants.TYPE_REGULAR) {
		LinkedHashMap groupParams = new LinkedHashMap();

		List rolePermissions = new ArrayList();

		rolePermissions.add(curResource);
		rolePermissions.add(new Integer(ResourceConstants.SCOPE_GROUP));
		rolePermissions.add(actionId);
		rolePermissions.add(new Long(role.getRoleId()));

		groupParams.put("rolePermissions", rolePermissions);

		groups = GroupLocalServiceUtil.search(company.getCompanyId(), null, null, groupParams, QueryUtil.ALL_POS, QueryUtil.ALL_POS);

		groupIdsArray = new long[groups.size()];

		for (int j = 0; j < groups.size(); j++) {
			Group group = (Group)groups.get(j);

			groupIdsArray[j] = group.getGroupId();

			groupNames.add(group.getName());
		}

		if (groups.isEmpty()) {
			scope = ResourceConstants.SCOPE_COMPANY;
		}
		else {
			scope = ResourceConstants.SCOPE_GROUP;
		}
	}
	else {
		scope = ResourceConstants.SCOPE_GROUP_TEMPLATE;
	}

	boolean supportsFilterByGroup = false;

	if (role.getType() == RoleConstants.TYPE_REGULAR) {
		if (!ResourceActionsUtil.isPortalModelResource(curResource) && !portletResource.equals(PortletKeys.PORTAL)) {
			supportsFilterByGroup = true;
		}
	}

	ResultRow row = new ResultRow(new Object[] {role, actionId, curResource, target, scope, supportsFilterByGroup, groups, groupIdsArray, groupNames}, target, i);

	row.addText(ResourceActionsUtil.getAction(pageContext, actionId));

	if (role.getType() == RoleConstants.TYPE_REGULAR) {
		row.addJSP("/html/portlet/enterprise_admin/edit_role_permissions_resource_scope.jsp");
		row.addJSP("right", SearchEntry.DEFAULT_VALIGN, "/html/portlet/enterprise_admin/edit_role_permissions_resource_action.jsp");
	}

	resultRows.add(row);
	%>

<%
}
%>

<liferay-ui:search-iterator searchContainer="<%= searchContainer %>" paginate="<%= false %>" />