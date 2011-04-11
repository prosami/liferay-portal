/**
 * Copyright (c) 2000-2011 Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */

package com.liferay.taglib.ui;

import com.liferay.portal.kernel.servlet.BrowserSnifferUtil;
import com.liferay.portal.kernel.util.Validator;
import com.liferay.portal.kernel.util.WebKeys;
import com.liferay.portal.model.Portlet;
import com.liferay.portal.util.PropsUtil;
import com.liferay.portal.util.PropsValues;
import com.liferay.taglib.util.IncludeTag;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;

/**
 * @author Brian Wing Shun Chan
 */
public class InputEditorTag extends IncludeTag {

	public void setConfigParams(Map<String, String> configParams) {
		_configParams = configParams;
	}

	public void setCssClass(String cssClass) {
		_cssClass = cssClass;
	}

	public void setEditorImpl(String editorImpl) {
		_editorImpl = editorImpl;
	}

	public void setHeight(String height) {
		_height = height;
	}

	public void setInitMethod(String initMethod) {
		_initMethod = initMethod;
	}

	public void setName(String name) {
		_name = name;
	}

	public void setOnChangeMethod(String onChangeMethod) {
		_onChangeMethod = onChangeMethod;
	}

	public void setToolbarSet(String toolbarSet) {
		_toolbarSet = toolbarSet;
	}

	public void setWidth(String width) {
		_width = width;
	}

	protected void cleanUp() {
		_configParams = null;
		_cssClass = null;
		_editorImpl = null;
		_height = null;
		_initMethod = "initEditor";
		_name = "editor";
		_onChangeMethod = null;
		_page = null;
		_toolbarSet = "liferay";
		_width = null;
	}

	protected String getPage() {
		return _page;
	}

	protected void setAttributes(HttpServletRequest request) {
		String cssClasses = "portlet ";

		Portlet portlet = (Portlet)request.getAttribute(WebKeys.RENDER_PORTLET);

		if (portlet != null) {
			cssClasses += portlet.getCssClassWrapper();
		}

		String editorImpl = _editorImpl;

		if (Validator.isNotNull(editorImpl)) {
			editorImpl = PropsUtil.get(editorImpl);
		}

		if (!BrowserSnifferUtil.isRtf(request)) {
			if (BrowserSnifferUtil.isSafari(request) &&
				BrowserSnifferUtil.isMobile(request)) {

				editorImpl = "simple";
			}
			else if (BrowserSnifferUtil.isSafari(request) &&
				(editorImpl.indexOf("simple") == -1)) {

				editorImpl = "tinymce_simple";
			}
			else {
				editorImpl = "simple";
			}
		}

		if (Validator.isNull(editorImpl)) {
			editorImpl = PropsValues.EDITOR_WYSIWYG_DEFAULT;
		}

		_page = "/html/js/editor/" + editorImpl + ".jsp";

		request.setAttribute(
			"liferay-ui:input-editor:configParams", _configParams);
		request.setAttribute("liferay-ui:input-editor:cssClass", _cssClass);
		request.setAttribute("liferay-ui:input-editor:cssClasses", cssClasses);
		request.setAttribute("liferay-ui:input-editor:editorImpl", editorImpl);
		request.setAttribute("liferay-ui:input-editor:height", _height);
		request.setAttribute("liferay-ui:input-editor:initMethod", _initMethod);
		request.setAttribute("liferay-ui:input-editor:name", _name);
		request.setAttribute(
			"liferay-ui:input-editor:onChangeMethod", _onChangeMethod);
		request.setAttribute("liferay-ui:input-editor:toolbarSet", _toolbarSet);
		request.setAttribute("liferay-ui:input-editor:width", _width);
	}

	private Map<String, String> _configParams;
	private String _cssClass;
	private String _editorImpl;
	private String _height;
	private String _initMethod = "initEditor";
	private String _name = "editor";
	private String _onChangeMethod;
	private String _page;
	private String _toolbarSet = "liferay";
	private String _width;

}