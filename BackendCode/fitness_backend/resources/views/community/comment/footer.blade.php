<div class="col-md-12">
    @if( auth()->check() )
        <span class="{{ isset($data) && $data['comment_user_name'] ? '' : 'd-none' }} comment-user-name">{{ $data['comment_user_name'] ?? '' }}</span>
        <a href="javascript:void(0);" class="remove-comment-reply {{ isset($data) && $data['comment_user_name'] ? '' : 'd-none' }}">
            <svg xmlns="http://www.w3.org/2000/svg" height="20px" viewBox="0 -960 960 960" width="20px" fill="#EA3323">
                <path d="m336-280 144-144 144 144 56-56-144-144 144-144-56-56-144 144-144-144-56 56 144 144-144 144 56 56ZM480-80q-83 0-156-31.5T197-197q-54-54-85.5-127T80-480q0-83 31.5-156T197-763q54-54 127-85.5T480-880q83 0 156 31.5T763-763q54 54 85.5 127T880-480q0 83-31.5 156T763-197q-54 54-127 85.5T480-80Z"/>
            </svg>
        </a>
        {{ html()->form('POST', route('save.comment.reply'))->attribute('class', 'comment-text d-flex align-items-center mt-1')->attribute('data-toggle', 'validator')->open() }} 
            
            <input type="hidden" name="comment_id" value="{{ $data['comment_id'] ?? '' }}" class="comment-id">
            <input type="hidden" name="posting_id" value="{{ $posting_id }}" class="posting-id">
            <input type="hidden" name="comment_type" value="{{ $data['type'] ?? 'comment' }}" class="comment-type">
            <input type="hidden" name="comment_reply_id" value="{{ $data['comment_reply_id'] ?? '' }}" class="comment-reply-id">
            
            <input type="text" name="comment" value="{{ $data['comment'] ?? '' }}" class="form-control rounded comment" required placeholder="{{ __('message.write_a_comment') }}">
            <div class="comment-attagement d-flex">
                <button type="submit" id="btn_submit" data-comment-form="ajax" class="btn btn-sm btn-primary font-size-12">
                    <svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" fill="currentColor">
                        <path d="M440-240v-368L296-464l-56-56 240-240 240 240-56 56-144-144v368h-80Z"/>
                    </svg>
                </button>
            </div>
        {{ html()->form()->close() }}
    @else
        <div class="d-flex justify-content-center">
            <a href="{{ route('frontend.signin') }}" class="btn btn-primary">
                {{ __('auth.sign_in') }}
            </a>
        </div>
    @endif
</div>
