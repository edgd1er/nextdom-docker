/* This file is part of Jeedom.
*
* Jeedom is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Jeedom is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Jeedom. If not, see <http://www.gnu.org/licenses/>.
*/

/* This file is part of NextDom.
*
* NextDom is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* NextDom is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with NextDom. If not, see <http://www.gnu.org/licenses/>.
*
* @Support <https://www.nextdom.org>
* @Email   <admin@nextdom.org>
* @Authors/Contributors: Sylvaner, Byackee, cyrilphoenix71, ColonelMoutarde, edgd1er, slobberbone, Astral0, DanoneKiD
*/

/* JS file for all that talk INIT */

/**
 * Init of page, master of all inits
 */
function initPage(){
    initTableSorter();
    initReportMode();
    $.initTableFilter();
    initRowOverflow();
    initHelp();
    initTextArea();
    $('.nav-tabs a').on('click',function (e) {
        var scrollHeight = $(document).scrollTop();
        $(this).tab('show');
        $(window).scrollTop(scrollHeight);
        setTimeout(function() {
            $(window).scrollTop(scrollHeight);
        }, 0);
    });
}

/**
 * Init of text area
 */
function initTextArea(){
    $('body').on('change keyup keydown paste cut', 'textarea.autogrow', function () {
        $(this).height(0).height(this.scrollHeight);
    });
}

/**
 * Init of row-overflow classe
 */
 function initRowOverflow() {
     var hWindow = $(window).outerHeight() - $('header').outerHeight() - $('#div_alert').outerHeight()-5;
     if($('#div_alert').outerHeight() > 0){
         hWindow -= 10;
     }
     if($('.row-overflow').attr('data-offset') != undefined){
         hWindow -= $('.row-overflow').attr('data-offset');
     }
     $('.row-overflow > div').css('padding-top','0px').height(hWindow).css('overflow-y', 'auto').css('overflow-x', 'hidden').css('padding-top','5px');
 }

 /**
  * Init of report mode
  */
 function initReportMode() {
     if (getUrlVars('report') == 1) {
         $('header').hide();
         $('footer').hide();
         $('#div_mainContainer').css('margin-top', '-50px');
         $('#wrap').css('margin-bottom', '0px');
         $('.reportModeVisible').show();
         $('.reportModeHidden').hide();
     }
 }

 /**
  * Init of tablesorter fields
  */
 function initTableSorter() {
     $(".tablesorter").each(function () {
         var widgets = ['uitheme', 'filter', 'zebra', 'resizable'];
         $(".tablesorter").tablesorter({
             theme: "bootstrap",
             widthFixed: true,
             headerTemplate: '{content} {icon}',
             widgets: widgets,
             widgetOptions: {
                 filter_ignoreCase: true,
                 resizable: true,
                 stickyHeaders_offset: $('header.navbar-fixed-top').height(),
                 zebra: ["", ""],
             }
         });
     });
 }

 /**
  * Init of help fields, add ? icon
  */
 function initHelp(){
     $('.help').each(function(){
         if($(this).attr('data-help') != undefined){
             $(this).append(' <sup><i class="fas fa-question-circle tooltips text-normal" title="'+$(this).attr('data-help')+'" style="color:grey;"></i></sup>');
         }
     });
 }
