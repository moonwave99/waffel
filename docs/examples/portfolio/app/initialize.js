module.exports = function(options){
  console.log('App initialised with options:', options);
  
  var container = document.querySelector('.masonry-container');
  container && new Masonry( container, {
    itemSelector: '.picture',
		columnWidth : '.picture',
    gutter: 0
  });

  $('.picture img').unveil(100, function(){
    var $this = $(this).load(function(){
      $this.closest('.picture').toggleClass('loaded', true);
    });    
  });
  
  enquire.register("screen and (min-width: 768px)", {
  	match : function() {
      $('a[rel="lightbox"]').fluidbox({
        closeTrigger: [
          { selector: 'window', event: 'resize scroll' }
        ]        
      }).on('openstart', function(){
        $(this).closest('.picture').addClass('fluidbox-open');
      }).on('closeend', function(){
        $(this).closest('.picture').removeClass('fluidbox-open');        
      })
  	}
  });  
};