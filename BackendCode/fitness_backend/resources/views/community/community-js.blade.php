<script>
    $(document).on('click','[data--confirmation--comment="true"]',function(e){
        e.preventDefault();
        var form = $(this).attr('data--submit');

        var title = $(this).attr('data-title');

        var message = $(this).attr('data-message');

        var ajaxtype = $(this).attr('data--ajax');
        if(form == 'confirm_form') {
            $('#confirm_form').attr('action', $(this).attr('href'));
        }
        let __this = this

        confirmationModal(form,title,message,ajaxtype,__this);
    });
    // remove previous bindings (prevents double firing)
    $(document).off('click', '[data-comment-form="ajax"]');
    $(document).on('click', '[data-comment-form="ajax"]', function(f) {
        $('form').validator('update');
        f.preventDefault();
        var current = $(this);
        current.addClass('disabled');

        var form = $(this).closest('form');
        var url  = form.attr('action');
        var fd   = new FormData(form[0]);

        $.ajax({
            type: "POST",
            url: url,
            data: fd, // serializes form's elements.
            success: function (e) {
                if (e.status === true) {

                    switch (e.event) {
                        case "submited":
                            showMessage(e.message);
                            $(".modal").modal('hide');
                            $('.dataTable').DataTable().ajax.reload( null, false );
                        break;

                        case "refresh":
                            window.location.reload();
                        break;

                        case "callback":
                            showMessage(e.message);
                            $(".modal").modal('hide');
                            location.reload();
                        break;

                        case "norefresh":
                            showMessage(e.message);
                            $(".modal").modal('hide');
                            getAssignList(e.type);
                        break;

                        case "report":
                            showMessage(e.message);
                            @if (Route::has('community'))
                            if($('.posting-card').length < 0){
                                window.location.href = "{{ route('community') }}";
                            }
                            @endif
                            $('#posting-'+e.posting_id).remove();
                            $(".modal").modal('hide');
                        break;

                        case "comment":
                            if (e.is_updated) {
                                $('.comment-'+e.id).html(e.data);
                            } else {
                                $('#append_comment_data').prepend(e.data);
                            }
                            $('.comment_id').val('');
                            $('.comment').val('');
                            scrollToComment('comment-' + e.id);
                        break;

                        case "commentreply":
                            $('.comment').val('');
                            const commentId = e.comment_id;
                            
                            const newReplyHtml = e.data;
                            
                            const replySection = $('#replyComment-' + commentId);
                            const replyList = $('#reply-comment-list-' + commentId);
                            const replyButton = $('[data-comment-id="' + commentId + '"].comment-reply');
                            const loadMoreButton = replySection.find('.load-more-replies');
                            const isVisible = replySection.hasClass('show');

                            $('.commentreply-'+e.id).replaceWith(e.data);
                            resetCommentForm('commentreply');
                            if ( e.is_updated ) {
                                return;
                            }
                            if( isVisible && loadMoreButton.length == 0) {
                                replyList.append(newReplyHtml);
                            } else {
                                
                                // replyButton.closest('#lreply-'+commentId).after(newReplyHtml);
                                let replyList = $('#lreply-' + commentId);

                                // Find all existing replies
                                let existingReplies = replyList.nextAll('[id^="commentreply-"]').last();
                                
                                if (existingReplies.length == 0) {
                                    replyList.after(newReplyHtml);
                                } else {
                                    existingReplies.after(newReplyHtml);
                                }
                            }
                        break;

                        default:
                            console.warn("Unhandled event type:", e.event);
                            break;
                    }
                }
                if (e.status == false) {
                    if (e.event == 'validation') {
                        errorMessage(e.message);
                        if( e.posting_id != undefined ) {
                            if( e.type != undefined && e.type == 'report' ) {
                                return;   
                            }
                            $('#posting-'+e.posting_id).remove();
                            $(".modal").modal('hide');
                        }
                    }
                }
            },
            error: function(error) {
            },
            cache: false,
            contentType: false,
            processData: false,
        });
        f.preventDefault(); // avoid to execute the actual submit of the form.
    });

    function confirmationModal(form,title = "{{ __('message.confirmation') }}",message = "{{ __('message.delete_msg') }}",ajaxtype=false,_this)
    {
        const storageDark = localStorage.getItem('theme');
        const theme = (storageDark == "light") ? 'material' : 'dark';
        $.confirm({
            content: message,
            type: '',
            title: title,
            buttons: {
                yes: {
                    action: function () {

                        if(ajaxtype == 'true') {
                            let url = _this;

                            let data = $('[data--submit="'+form+'"]').serializeArray();
                            $.post(url, data).then(response => {
                                if(response.status) {
                                    if (jQuery.inArray(response.event, [ 'comment', 'commentreply' ]) !== -1) {
                                        $('.'+response.event+"-"+response.id).remove();

                                        resetCommentForm(response.event);
                                        if( response.event == 'commentreply' && response.comment_reply_count == 0 ) {
                                            $('#view-reply-line-'+response.comment_id).remove();
                                        }
                                    }
                                    if( response.event == 'posting' ) {
                                        $('#posting-'+response.id).remove();
                                    }
                                    showMessage(response.message)
                                }
                                if(response.status == false){
                                    errorMessage(response.message)
                                }
                            })
                        } else {
                            if (form !== undefined && form){
                                $(document).find('[data--submit="'+form+'"]').submit();
                            }else{
                                return true;
                            }
                        }
                    }
                },
                no: {
                    action: function () {}
                },
            },
            theme: theme
        });
        return false;
    }

    function scrollToComment(commentId) {
        const modalBody = $('.modal-body');
        const comment = $('#' + commentId);

        if (modalBody.length && comment.length) {
            modalBody.animate({
                scrollTop: modalBody.scrollTop() + comment.position().top - 10
            }, 600);
        }
    }

    function errorMessage(message) {
        Swal.fire({
            icon: 'error',
            title: "{{ __('message.opps') }}",
            text: message,
            confirmButtonColor: "var(--bs-primary)",
            confirmButtonText: "{{ __('message.ok') }}"
        });
    }

    function showMessage(message) {
        Swal.fire({
            icon: 'success',
            title: "{{ __('message.done') }}",
            text: message,
            confirmButtonColor: "var(--bs-primary)",
            confirmButtonText: "{{ __('message.ok') }}"
        });
    }
</script>
