// jQuery File Tree Plugin
//

if (jQuery) (function($){
	
	$.extend($.fn, {
		fileTree: function(options, callback) {
		    // Defaults
		    var defaults = {
			script: 'test.json',
			root: '/',
			loadingMessage: 'Loading...'
		    };

		    // Expand the defaults with the supplied options
		    options = $.extend(defaults, options);

		    $(this).each(function() {
			var $this = $(this);

			$this.html('<ul class="jqueryFileTree start"><li class="wait">' + options.loadingMessage + '<li></ul>');

			//			$.ajax({
			//			    url: options.script
			//			}).done(
			//			    function (data) {
			
			var data = [{"name":"connectors","dir":true},{"name":"images","dir":true},{"name":"jqueryFileTree.css","dir":false},{"name":"jqueryFileTree.js","dir":false},{"name":"README.md","dir":false},{"name":"test.html","dir":false},{"name":"test.json","dir":false}];

			var listHtml = '';
			for (var i in data) {
			    if (data.hasOwnProperty(i)) {
				var item = data[i],
				classHtml = (item.dir?' class="dir"':'');
				console.log(item);
				listHtml += '<li' + classHtml + '>' + item.name + '</li>';
				console.log(listHtml);
			    }
			};
			$this.find('.start').html(listHtml);
//			    }
//			);
		    });
		}
	});
	
})(jQuery);