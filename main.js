var tag = document.createElement('script');
		tag.src = 'https://www.youtube.com/player_api';
var firstScriptTag = document.getElementsByTagName('script')[0];
		firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
var tv,
		playerDefaults = {autoplay: 0, autohide: 1, modestbranding: 0, rel: 0, showinfo: 0, controls: 0, disablekb: 1, enablejsapi: 0, iv_load_policy: 3};
var vid = [
      {'videoId': '3fb3sx2Ovic', 'suggestedQuality': 'hd720'}
		];
		// randomVid = Math.floor(Math.random() * vid.length),
  //   currVid = randomVid;
  // currVid = 0;

// $('.hi em:last-of-type').html(vid.length);

function onYouTubePlayerAPIReady(){
  var tv_height = $('.tv').height();
  var tv_width = $('.tv').width();
  tv = new YT.Player('tv', {height: tv_height, width: tv_width, events: {'onReady': onPlayerReady, 'onStateChange': onPlayerStateChange}, playerVars: playerDefaults});
}

function onPlayerReady(){
  tv.loadVideoById(vid[0]);
  tv.mute();
}

function onPlayerStateChange(e) {
  if (e.data === 1 || e.data === 3){
    $('#tv').addClass('active');
    // $('.hi em:nth-of-type(2)').html(currVid + 1);
  } else if (e.data === 0){
    $('#tv').removeClass('active');
    tv.loadVideoById(vid[0]);
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