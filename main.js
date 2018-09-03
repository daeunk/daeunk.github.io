var tag = document.createElement('script');
		tag.src = 'https://www.youtube.com/player_api';
var firstScriptTag = document.getElementsByTagName('script')[0];
		firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
var tv,
		playerDefaults = {autoplay: 0, autohide: 1, modestbranding: 0, rel: 0, showinfo: 0, controls: 0, disablekb: 1, enablejsapi: 0, iv_load_policy: 3};
var vid = [
      {'videoId': 'BYFe2KVGBDI', 'startSeconds': 13, 'endSeconds': 18, 'suggestedQuality': 'hd720'},
			{'videoId': '6QZzw7E0Q7I', 'startSeconds': 63, 'endSeconds': 67, 'suggestedQuality': 'hd720'},
      {'videoId': 'lZvB19FN_i0', 'startSeconds': 288, 'endSeconds': 300, 'suggestedQuality': 'hd720'},
			{'videoId': '6QZzw7E0Q7I', 'startSeconds': 231, 'endSeconds': 238, 'suggestedQuality': 'hd720'},
			{'videoId': 'u5xAyLdedjo', 'startSeconds': 0, 'endSeconds': 5, 'suggestedQuality': 'hd720'}
		],
		// randomVid = Math.floor(Math.random() * vid.length),
  //   currVid = randomVid;
  currVid = 0;

// $('.hi em:last-of-type').html(vid.length);

function onYouTubePlayerAPIReady(){
  var tv_height = $('.tv').height();
  var tv_width = $('.tv').width();
  tv = new YT.Player('tv', {height: tv_height, width: tv_width, events: {'onReady': onPlayerReady, 'onStateChange': onPlayerStateChange}, playerVars: playerDefaults});
  var tv_container = document.getElementsByClassName('tv')[0];
  var x = $('.tv').height()
  console.log(x);
  tv.height = $('.tv').height();
  tv.width = $('.tv').width();
  console.log
}

function onPlayerReady(){
  tv.loadVideoById(vid[currVid]);
  tv.mute();
}

function onPlayerStateChange(e) {
  if (e.data === 1){
    $('#tv').addClass('active');
    // $('.hi em:nth-of-type(2)').html(currVid + 1);
  } else if (e.data === 2){
    $('#tv').removeClass('active');
    if(currVid === vid.length - 1){
      currVid = 0;
    } else {
      currVid++;  
    }
    tv.loadVideoById(vid[currVid]);
    console.log(currVid, vid[currVid].videoId, vid[currVid].startSeconds);
    // tv.seekTo(vid[currVid].startSeconds);
  }
}

// function vidRescale(){

//   var w = $(window).width()+200,
//     h = $(window).height()+200;

//   if (w/h > 16/9){
//     tv.setSize(w, w/16*9);
//     $('.tv .screen').css({'left': '0px'});
//   } else {
//     tv.setSize(h/9*16, h);
//     $('.tv .screen').css({'left': -($('.tv .screen').outerWidth()-w)/2});
//   }
// }

// $(window).on('load resize', function(){
//   vidRescale();
// });

// $('.hi span:first-of-type').on('click', function(){
//   $('#tv').toggleClass('mute');
//   $('.hi em:first-of-type').toggleClass('hidden');
//   if($('#tv').hasClass('mute')){
//     tv.mute();
//   } else {
//     tv.unMute();
//   }
// });

// $('.hi span:last-of-type').on('click', function(){
//   $('.hi em:nth-of-type(2)').html('~');
//   tv.pauseVideo();
// });
