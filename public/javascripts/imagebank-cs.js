/* DO NOT MODIFY. This file was compiled Mon, 31 Jan 2011 02:40:26 GMT from
 * /Users/scotthedstrom/Sites/dreamcatcher/app/coffee/imagebank-cs.coffee
 */

(function() {
  var Nav;
  window.IB || (window.IB = {});
  window.ImageBank = (function() {
    function ImageBank() {
      new Nav();
    }
    return ImageBank;
  })();
  Nav = (function() {
    function Nav() {
      var config;
      config = {
        over: function() {
          return $(this).find('.nav-expand').fadeIn();
        },
        sensitivity: 20,
        interval: 30,
        out: function() {
          return $(this).find('.nav-expand').fadeOut();
        }
      };
      $('#IB_browse li').hoverIntent(config);
      $('#IB_browse li').find('.nav-expand p').unbind();
      $('#IB_browse li').find('.nav-expand p').click(function() {
        return loadArtistList($(this).text());
      });
      $('#IB_browse li').find('span').unbind();
      $('#IB_browse li').find('span').click(function() {
        if ($(this).text() === 'Photos') {
          return loadCategoryList("Photo");
        } else {
          return loadCategoryList($(this).text());
        }
      });
    }
    return Nav;
  })();
}).call(this);
