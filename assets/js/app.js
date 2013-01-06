$(document).ready(function() {    
    prettyPrint();
    
    getTwitters('tweet', { 
        id: 'Robert_Birnie', 
        count: 1, 
        enableLinks: true, 
        ignoreReplies: true, 
        clearContents: true,
        template: '%text% <a class="time" href="http://twitter.com/%user_screen_name%/statuses/%id_str%/">%time%</a>',
        callback: function () {
            $('#tweet').html(
                $('#tweet ul li').html()
            );
            
            $('#tweet').animate({
                'opacity':1
            });
        }
    });
});