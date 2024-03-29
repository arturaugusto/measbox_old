
(function ($) {

    "use strict";

    var methods = {
        init: function (options) {

            var defaults = $.extend(true, {}, $.fn.markdownEditor.defaults, options),
                plugin = this,
                preview = false,
                fullscreen = false;

            // Replace the content of the div with our html
            plugin.addClass('md-container').html(editorHtml(this.text(), defaults));

            // If the Bootstrap tooltip library is loaded, initialize the tooltips of the toolbar
            if (typeof $().tooltip === 'function') {
                plugin.find('[data-mdtooltip="tooltip"]').tooltip({
                    container: 'body'
                });
            }

            var mdEditor = plugin.find('.md-editor'),
                mdPreview = plugin.find('.md-preview'),
                mdLoading = plugin.find('.md-loading');

            plugin.css({
                width: defaults.width
            });

            mdEditor.css({
                width: defaults.width,
                height: defaults.height,
                fontSize: defaults.fontSize
            });

            mdPreview.css({
                width: defaults.width,
                height: defaults.height
            });

            // Initialize Ace
            var editor = ace.edit(mdEditor[0]),
                snippetManager;

            editor.setTheme('ace/theme/' + defaults.theme);
            editor.getSession().setMode('ace/mode/markdown');
            editor.getSession().setUseWrapMode(true);

            editor.setHighlightActiveLine(false);
            editor.setShowPrintMargin(false);
            editor.renderer.setShowGutter(false);

            ace.config.loadModule('ace/ext/language_tools', function () {
                snippetManager = ace.require('ace/snippets').snippetManager;
                setShortcuts(editor, snippetManager);
            });


            // Image drag and drop and upload events
            if (defaults.imageUpload) {

                plugin.find('.md-input-upload').on('change', function() {
                    var files = $(this).get(0).files;

                    if (files.length) {
                        uploadFiles(defaults.uploadPath, $(this).get(0).files, editor, snippetManager, mdLoading);
                    }
                });

                plugin.on('dragenter', function (e) {
                    e.stopPropagation();
                    e.preventDefault();
                });

                plugin.on('dragover', function (e) {
                    e.stopPropagation();
                    e.preventDefault();
                });

                plugin.on('drop', function (e) {
                    e.preventDefault();
                    var files = e.originalEvent.dataTransfer.files;

                    uploadFiles(defaults.uploadPath, files, editor, snippetManager, mdLoading);
                });
            }

            // Window resize event
            if (defaults.fullscreen === true) {
                $(window).resize(function () {
                    if (fullscreen === true) {
                        if (preview === false) {
                            adjustFullscreenLayout(mdEditor);
                        } else {
                            adjustFullscreenLayout(mdPreview);
                        }
                    }
                });
            }

            // Toolbar events
            plugin.find('.md-btn').click(function () {
                var btnType = $(this).data('btn'),
                    selectedText = editor.session.getTextRange(editor.getSelectionRange());

                if (btnType === 'h1') {
                    insertBeforeText(editor, '#');

                } else if (btnType === 'h2') {
                    insertBeforeText(editor, '##');

                } else if (btnType === 'h3') {
                    insertBeforeText(editor, '###');

                } else if (btnType === 'ul') {
                    insertBeforeText(editor, '*');

                } else if (btnType === 'ol') {
                    insertBeforeText(editor, '1.');

                } else if (btnType === 'bold') {
                    editor.execCommand('bold');

                } else if (btnType === 'italic') {
                    editor.execCommand('italic');

                } else if (btnType === 'link') {
                    editor.execCommand('link');

                } else if (btnType === 'image') {
                    if (selectedText === '') {
                        snippetManager.insertSnippet(editor, '![${1:text}](http://$2)');
                    } else {
                        snippetManager.insertSnippet(editor, '![' + selectedText + '](http://$1)');
                    }

                } else if (btnType === 'edit') {
                    preview = false;

                    mdPreview.hide();
                    mdEditor.show();
                    plugin.find('.btn-edit').addClass('active');
                    plugin.find('.btn-preview').removeClass('active');

                    if (fullscreen === true) {
                        adjustFullscreenLayout(mdEditor);
                    }

                } else if (btnType === 'preview') {
                    preview = true;

                    mdPreview.html('<p style="text-align:center; font-size:16px">' + defaults.label.loading + '...</p>');

                    defaults.onPreview(editor.getSession().getValue(), function (content) {
                        mdPreview.html(content);
                    });

                    mdEditor.hide();
                    mdPreview.show();
                    plugin.find('.btn-preview').addClass('active');
                    plugin.find('.btn-edit').removeClass('active');

                    if (fullscreen === true) {
                        adjustFullscreenLayout(mdPreview);
                    }

                } else if (btnType === 'fullscreen') {

                    if (fullscreen === true) {
                        fullscreen = false;

                        $('body, html').removeClass('md-body-fullscreen');
                        plugin.removeClass('md-fullscreen');

                        mdEditor.css('height', defaults.height);
                        mdPreview.css('height', defaults.height);

                    } else {
                        fullscreen = true;

                        $('body, html').addClass('md-body-fullscreen');
                        plugin.addClass('md-fullscreen');

                        if (preview === false) {
                            adjustFullscreenLayout(mdEditor);
                        } else {
                            adjustFullscreenLayout(mdPreview);
                        }
                    }

                    editor.resize();
                }

                editor.focus();
            });

            return this;
        },
        content: function () {
            var editor = ace.edit(this.find('.md-editor')[0]);
            return editor.getSession().getValue();
        },
        onChange: function (cb) {
            var editor = ace.edit(this.find('.md-editor')[0]);
            editor.on('change', cb);
        }
    };

    $.fn.markdownEditor = function (options) {

        if (methods[options]) {
            return methods[options].apply(this, Array.prototype.slice.call(arguments, 1));

        } else if (typeof options === 'object' || ! options) {
            return methods.init.apply(this, arguments);

        } else {
            $.error('Method ' +  options + ' does not exist on jQuery.markdownEditor');
        }
    };

    function uploadFiles (url, files, editor, snippetManager, loading) {

        loading.show();

        var data = new FormData(),
            i = 0;

        for (i = 0; i < files.length; i++) {
            data.append('file' + i, files[i]);
        }

        $.ajax({
            url: url,
            type: 'POST',
            contentType: false,
            data: data,
            processData: false,
            cache: false,
            dataType: 'json'
        }).done (function (uploadedFiles) {

            var separation = '';
            if (uploadedFiles.length > 1) {
                separation = "\n";
            }

            for (var i = 0; i < uploadedFiles.length; i++) {
                snippetManager.insertSnippet(editor, '![](' + uploadedFiles[i] + ')' + separation);
            }

        }).always(function () {
            loading.hide();
        });
    }

    function adjustFullscreenLayout (mdPanel) {
        var hWindow = $(window).height(),
            tEditor = mdPanel.offset().top,
            hEditor;

        if(hWindow > tEditor) {
            hEditor = hWindow - tEditor;
            mdPanel.css('height', hEditor + 'px');
        }
    }

    function setShortcuts (editor, snippetManager) {
        editor.commands.addCommand({
            name: 'bold',
            bindKey: {win: 'Ctrl-B',  mac: 'Command-B'},
            exec: function (editor) {
                var selectedText = editor.session.getTextRange(editor.getSelectionRange());

                if (selectedText === '') {
                    snippetManager.insertSnippet(editor, '**${1:text}**');
                } else {
                    snippetManager.insertSnippet(editor, '**' + selectedText + '**');
                }
            },
            readOnly: false
        });

        editor.commands.addCommand({
            name: 'italic',
            bindKey: {win: 'Ctrl-I',  mac: 'Command-I'},
            exec: function (editor) {
                var selectedText = editor.session.getTextRange(editor.getSelectionRange());

                if (selectedText === '') {
                    snippetManager.insertSnippet(editor, '*${1:text}*');
                } else {
                    snippetManager.insertSnippet(editor, '*' + selectedText + '*');
                }
            },
            readOnly: false
        });

        editor.commands.addCommand({
            name: 'link',
            bindKey: {win: 'Ctrl-K',  mac: 'Command-K'},
            exec: function (editor) {
                var selectedText = editor.session.getTextRange(editor.getSelectionRange());

                if (selectedText === '') {
                    snippetManager.insertSnippet(editor, '[${1:text}](http://$2)');
                } else {
                    snippetManager.insertSnippet(editor, '[' + selectedText + '](http://$1)');
                }
            },
            readOnly: false
        });
    }

    function insertBeforeText (editor, string) {

        if (editor.getCursorPosition().column === 0) {
            editor.navigateLineStart();
            editor.insert(string + ' ');
        } else {
            editor.navigateLineStart();
            editor.insert(string + ' ');
            editor.navigateLineEnd();
        }
    }

    function editorHtml (content, options) {
        var html = '';

        html += '<div class="md-loading"><span class="md-icon-container"><span class="md-icon"></span></span></div>';
        html += '<div class="md-toolbar">';
            html += '<div class="btn-toolbar">';

                html += '<div class="btn-group">';
                    html += '<button type="button" data-mdtooltip="tooltip" title="' + options.label.btnHeader1 + '" class="md-btn btn btn-sm btn-default" data-btn="h1">H1</button>';
                    html += '<button type="button" data-mdtooltip="tooltip" title="' + options.label.btnHeader2 + '" class="md-btn btn btn-sm btn-default" data-btn="h2">H2</button>';
                    html += '<button type="button" data-mdtooltip="tooltip" title="' + options.label.btnHeader3 + '" class="md-btn btn btn-sm btn-default" data-btn="h3">H3</button>';
                html += '</div>'; // .btn-group

                html += '<div class="btn-group">';
                    html += '<button type="button" data-mdtooltip="tooltip" title="' + options.label.btnBold + '" class="md-btn btn btn-sm btn-default" data-btn="bold"><span class="glyphicon glyphicon-bold"></span></button>';
                    html += '<button type="button" data-mdtooltip="tooltip" title="' + options.label.btnItalic + '" class="md-btn btn btn-sm btn-default" data-btn="italic"><span class="glyphicon glyphicon-italic"></span></button>';
                html += '</div>'; // .btn-group

                html += '<div class="btn-group">';
                    html += '<button type="button" data-mdtooltip="tooltip" title="' + options.label.btnList + '" class="md-btn btn btn-sm btn-default" data-btn="ul"><span class="glyphicon glyphicon glyphicon-list"></span></button>';
                    html += '<button type="button" data-mdtooltip="tooltip" title="' + options.label.btnOrderedList + '" class="md-btn btn btn-sm btn-default" data-btn="ol"><span class="glyphicon glyphicon-th-list"></span></button>';
                html += '</div>'; // .btn-group

                html += '<div class="btn-group">';
                    html += '<button type="button" data-mdtooltip="tooltip" title="' + options.label.btnLink + '" class="md-btn btn btn-sm btn-default" data-btn="link"><span class="glyphicon glyphicon-link"></span></button>';
                    html += '<button type="button" data-mdtooltip="tooltip" title="' + options.label.btnImage + '" class="md-btn btn btn-sm btn-default" data-btn="image"><span class="glyphicon glyphicon-picture"></span></button>';
                    if (options.imageUpload === true) {
                        html += '<button type="button" data-mdtooltip="tooltip" title="' + options.label.btnUpload + '" class="btn btn-sm btn-default md-btn-file"><span class="glyphicon glyphicon-upload"></span><input class="md-input-upload" type="file" multiple accept=".jpg,.jpeg,.png,.gif"></button>';
                    }
                html += '</div>'; // .btn-group

                if (options.fullscreen === true) {
                    html += '<div class="btn-group pull-right">';
                        html += '<button type="button" class="md-btn btn btn-sm btn-default" data-btn="fullscreen"><span class="glyphicon glyphicon-fullscreen"></span> ' + options.label.btnFullscreen + '</button>';
                    html += '</div>'; // .btn-group
                }

                if (options.preview === true) {
                    html += '<div class="btn-group pull-right">';
                        html += '<button type="button" class="md-btn btn btn-sm btn-default btn-edit active" data-btn="edit"><span class="glyphicon glyphicon-pencil"></span> ' + options.label.btnEdit + '</button>';
                        html += '<button type="button" class="md-btn btn btn-sm btn-default btn-preview" data-btn="preview"><span class="glyphicon glyphicon-eye-open"></span> ' + options.label.btnPreview + '</button>';
                    html += '</div>'; // .btn-group
                }

            html += '</div>'; // .btn-toolbar
        html += '</div>'; // .md-toolbar

        html += '<div class="md-editor">' + $('<div>').text($.trim(content)).html() + '</div>';
        html += '<div class="md-preview" style="display:none"></div>';

        return html;
    }

    $.fn.markdownEditor.defaults = {
        width: '100%',
        height: '400px',
        fontSize: '14px',
        theme: 'tomorrow',
        fullscreen: true,
        imageUpload: false,
        uploadPath: '',
        preview: false,
        onPreview: function (content, callback) {
            callback(content);
        },
        label: {
            btnHeader1: 'Header 1',
            btnHeader2: 'Header 2',
            btnHeader3: 'Header 3',
            btnBold: 'Bold',
            btnItalic: 'Italic',
            btnList: 'Unordered list',
            btnOrderedList: 'Ordered list',
            btnLink: 'Link',
            btnImage: 'Insert image',
            btnUpload: 'Uplaod image',
            btnEdit: 'Edit',
            btnPreview: 'Preview',
            btnFullscreen: 'Fullscreen',
            loading: 'Loading'
        }
    };

}(jQuery));