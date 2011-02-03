/* Adapted from http://github.com/rails/jquery-ujs */

(function($) {
	// Triggers an event on an element and returns the event result
	function fire(obj, name, data) {
		var event = new $.Event(name);
		obj.trigger(event, data);
		return event.result !== false;
	}

	// Submits "remote" forms and links with ajax
	function handleRemote(element) {
		var method, url, data,
			dataType = element.attr('data-type') || ($.ajaxSettings && $.ajaxSettings.dataType);

		if (element.is('form')) {
			method = element.attr('method');
			url = element.attr('action');
			data = element.serializeArray();
			// memoized value from clicked submit button
			var button = element.data('ujs:submit-button');
			if (button) {
				data.push(button);
				element.data('ujs:submit-button', null);
			}
		} else {
			method = element.attr('data-method');
			url = element.attr('href');
			data = null;
		}

		$.ajax({
			url: url, type: method || 'GET', data: data, dataType: dataType,
			// stopping the "ajax:beforeSend" event will cancel the ajax request
			beforeSend: function(xhr, settings) {
				if (settings.dataType === undefined) {
					xhr.setRequestHeader('accept', '*/*;q=0.5, ' + settings.accepts.script);
				}
				return fire(element, 'ajax:beforeSend', [xhr, settings]);
			},
			success: function(data, status, xhr) {
				element.trigger('ajax:success', [data, status, xhr]);
			},
			complete: function(xhr, status) {
				element.trigger('ajax:complete', [xhr, status]);
			},
			error: function(xhr, status, error) {
				element.trigger('ajax:error', [xhr, status, error]);
			}
		});
	}

	function allowAction(element) {
		var message = element.attr('data-confirm');
		return !message || (fire(element, 'confirm') && confirm(message));
	}

	function requiredValuesMissing(form) {
		var missing = false;
		form.find('input[name][required]').each(function() {
			if (!$(this).val()) missing = true;
		});
		return missing;
	}

	$('a[data-confirm]').live('click.rails', function(e) {
		var link = $(this);
		if (!allowAction(link)) return false;
	});

	$('form').live('submit.rails', function(e) {
		var form = $(this), remote = form.attr('data-remote') != undefined;
		if (!allowAction(form)) return false;

		// skip other logic when required values are missing
		if (requiredValuesMissing(form)) return !remote;

		if (remote) {
			handleRemote(form);
			return false;
		}
	});

	$('form input[type=submit], form button[type=submit], form button:not([type])').live('click.rails', function() {
		var button = $(this);
		if (!allowAction(button)) return false;
		// register the pressed submit button
		var name = button.attr('name'), data = name ? {name:name, value:button.val()} : null;
		button.closest('form').data('ujs:submit-button', data);
	});
})( jQuery );
